#=
Run this file to regenerate `proj_c.jl` and `proj_common.jl`.

It expects a PROJ install in the deps folder, run `build Proj4` in Pkg mode
if these are not in place.

The wrapped PROJ version and provided PROJ version should be kept in sync.
So when updating the PROJBuilder provided version, also rerun this wrapper.
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
=#

using Clang  # needs a post 0.9.1 release with #231 and #232
using MacroTools
using EzXML

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

"Rewrite expressions in the ways listed at the top of this file."
function rewriter(x::Expr)
    if @capture(x,
        function f_(fargs__)
            ccall(fname_, rettype_, argtypes_, argvalues__)
        end
    )
        # it is a function wrapper around a ccall
        n = length(fargs)
        # keep track of how we order arguments, such that we can do the same in the docs
        argpos = collect(1:n)

        fargs2 = copy(fargs)
        if !isempty(fargs)
            # ctx is always the first argument
            if fargs[1] === :ctx
                fargs2[1] = :(ctx = C_NULL)
                # keyword arguments must follow positional ones
                argpos = circshift(argpos, -1)
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
        x2, argpos
    else
        # do not modify expressions that are no ccall function wrappers
        # argument positions do not apply, but something still needs to be returned
        argpos = nothing
        x, argpos
    end
end

# parse GDAL's Doxygen XML file
const doc = readxml(xmlpath)

# should be here if you pkg> build Proj4
includedir = normpath(joinpath(@__DIR__, "..", "deps", "usr", "include"))
headerfiles = [joinpath(includedir, "proj.h")]

wc = init(; headers = headerfiles,
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
