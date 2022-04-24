#=
Run this file to regenerate `proj_c.jl` and `proj_common.jl`.

The wrapped PROJ version and provided PROJ version should be kept in sync.
So when updating the provided PROJ_jll version, also rerun this wrapper.
This way we ensure that the provided library has the same functions available
as the wrapped one. Furthermore this makes sure constants in `proj_common.jl`
like `PROJ_VERSION_PATCH`, which are just literals, are correct.

Several custom transformations are applied that should make using this package more convenient.
- docstrings are added, created from PROJ Doxygen XML output
- functions that return a Cstring are wrapped in unsafe_string to return a String
- functions that return a Ptr{Cstring} are wrapped in unsafe_loadstringlist to return a Vector{String}
- context arguments become keyword arguments, defaulting to C_NULL meaning default context

These transformations are based on the code developed for GDAL.jl, see
https://github.com/JuliaGeo/GDAL.jl/blob/master/gen/README.md for more information
on how to construct the PROJ Doxygen XML file needed here.

If Doxygen gives errors, it helps to turn off Latex and HTML output:
    GENERATE_LATEX         = NO
    GENERATE_HTML          = NO
    GENERATE_XML           = YES
=#

using Clang
using MacroTools
using MacroTools: postwalk
using EzXML
using PROJ_jll

const xmlpath = joinpath(@__DIR__, "doxygen.xml")

# several functions for building docstrings
include(joinpath(@__DIR__, "doc.jl"))


"""
Custom rewriter for Clang.jl's C wrapper

Gets called with all expressions in a header file, or all expressiong in a common file.
If available, it adds docstrings before every expression, such that Clang.jl prints them
on top of the expression. The expressions themselves get sent to `rewriter(::Expr)`` for
further treatment.
"""
function rewriter(xs::Vector)
    rewritten = Any[]
    for x in xs
        # Clang.jl inserts strings like "# Skipping MacroDefinition: X"
        # keep these to get a sense of what we are missing
        if x isa String
            push!(rewritten, x)
            continue
        elseif x.head == :struct && x.args[2] in coord_union
            continue
        end
        @assert x isa Expr

        x2, argpos = rewriter(x)
        name = cname(x)
        node = findnode(name, doc)
        docstr = node === nothing ? "" : build_docstring(node, argpos)
        isempty(docstr) || push!(rewritten, addquotes(docstr))
        push!(rewritten, x2)
    end
    rewritten
end

"Make the arg at position i a keyword and move it to the back in the argpos permutation"
function keywordify!(fargs2, argpos, i)
    if i === nothing
        return nothing
    else
        arg = fargs2[i]
        fargs2[i] = Expr(:kw, arg, :C_NULL)
        # in optpos is does not have to be at i anymore if it already was moved
        argoptpos = findfirst(==(i), argpos)
        splice!(argpos, argoptpos)
        push!(argpos, i)  # add it to the end
    end
end

"Rewrite expressions using the transformations listed at the top of this file"
function rewriter(x::Expr)
    if @capture(x, function f_(fargs__)
        ccall(fname_, rettype_, argtypes_, argvalues__)
    end)
        # it is a function wrapper around a ccall
        n = length(fargs)
        # keep track of how we order arguments, such that we can do the same in the docs
        argpos = collect(1:n)

        fargs2 = copy(fargs)
        if !isempty(fargs)
            # make area optional
            if f in (:proj_create_crs_to_crs, :proj_create_crs_to_crs_from_pj)
                optpos = findfirst(==(:area), fargs)
                keywordify!(fargs2, argpos, optpos)
            elseif f === :proj_coord
                # proj_coord(x, y, z, t) to proj_coord(x = 0.0, y = 0.0, z = 0.0, t = Inf)
                fargs2[1] = Expr(:kw, :x, 0.0)
                fargs2[2] = Expr(:kw, :y, 0.0)
                fargs2[3] = Expr(:kw, :z, 0.0)
                fargs2[4] = Expr(:kw, :t, Inf)
            end
            # ctx is always the first argument
            if fargs[1] === :ctx
                keywordify!(fargs2, argpos, 1)
            end
            # make all options optional
            optpos = findfirst(==(:options), fargs)
            keywordify!(fargs2, argpos, optpos)
            if f === :proj_create_from_wkt
                optpos = findfirst(==(:out_warnings), fargs)
                keywordify!(fargs2, argpos, optpos)
                optpos = findfirst(==(:out_grammar_errors), fargs)
                keywordify!(fargs2, argpos, optpos)
            end
            # apply the argument ordering permutation
            fargs2 = fargs2[argpos]
        end

        # bind the ccall such that we can easily wrap it
        cc = :(ccall($fname, $rettype, $argtypes, $(argvalues...)))

        cc2 = if rettype == :Cstring
            :(aftercare($cc))
        elseif rettype == :(Ptr{Cstring})
            :(aftercare($cc))
        else
            cc
        end

        # stitch the modified function expression back together
        x2 = :(function $f($(fargs2...))
            $cc2
        end) |> prettify

        # rename PJ_COORD to Coord
        x3 = postwalk(x -> x === :PJ_COORD ? :Coord : x, x2)
        return x3, argpos
    else
        # do not modify expressions that are no ccall function wrappers
        # argument positions do not apply, but something still needs to be returned
        return x, nothing
    end
end

# parse PROJ's Doxygen XML file
const doc = readxml(xmlpath)

includedir = joinpath(PROJ_jll.artifact_dir, "include")
headerfiles = [joinpath(includedir, "proj.h")]

# PJ_COORD becomes `Coord <: FieldVector{4, Float64}` and the rest is left out altogether
# https://proj.org/development/reference/datatypes.html#c.PJ_COORD
const coord_union = [
    :PJ_COORD,
    :PJ_XYZT,
    :PJ_UVWT,
    :PJ_LPZT,
    :PJ_GEOD,
    :PJ_OPK,
    :PJ_ENU,
    :PJ_XYZ,
    :PJ_UVW,
    :PJ_LPZ,
    :PJ_XY,
    :PJ_UV,
]

wc = init(;
    headers = headerfiles,
    output_file = joinpath(@__DIR__, "..", "src", "proj_c.jl"),
    common_file = joinpath(@__DIR__, "..", "src", "proj_common.jl"),
    clang_includes = [includedir, CLANG_INCLUDE],
    clang_args = ["-I", includedir],
    header_wrapped = (root, current) -> root == current,
    header_library = x -> "libproj",
    clang_diagnostics = true,
    rewriter = rewriter,
)

run(wc)

# delete Clang.jl helper files
rm(joinpath(@__DIR__, "..", "src", "LibTemplate.jl"))
rm(joinpath(@__DIR__, "..", "src", "ctypes.jl"))
