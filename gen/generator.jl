using Clang.Generators
using MacroTools: @capture, postwalk, prettify
using PROJ_jll: artifact_dir
using JuliaFormatter: format

"create an optional argument expression"
kw(name, val) = Expr(:kw, name, val)

renames = Dict(:PJ_COORD => :Coord, :PROJ_STRING_LIST => :(Ptr{Cstring}))

function rewrite(ex::Expr)
    if @capture(ex, function fname_(fargs__)
        @ccall lib_.cname_(cargs__)::rettype_
    end)
        fargs′ = copy(fargs)
        # if ctx is the first argument, put it at the end as an optional argument
        if !isempty(fargs) && fargs[1] == :ctx
            fargs′ = circshift!(fargs′, fargs, -1)
            fargs′[end] = kw(:ctx, :C_NULL)
        end

        # make certain function arguments optional
        if fname === :proj_coord
            fargs′ = [kw(:x, 0.0), kw(:y, 0.0), kw(:z, 0.0), kw(:t, Inf)]
        elseif fname in (:proj_create_crs_to_crs, :proj_create_crs_to_crs_from_pj)
            fargs′[3] = kw(:area, :C_NULL)
        elseif fname === :proj_create_from_wkt
            fargs′[3] = kw(:out_warnings, :C_NULL)
            fargs′[4] = kw(:out_grammar_errors, :C_NULL)
        elseif fname === :proj_identify
            # put options behind out_confidence so we can make it optional
            fargs′ = reverse!(fargs′, 3, 4)
        end
        for (i, arg) in enumerate(fargs′)
            if arg === :options
                fargs′[i] = kw(:options, :C_NULL)
            end
        end

        # bind the ccall such that we can easily wrap it
        cc = :(@ccall $lib.$cname($(cargs...))::$rettype)
        cc′ = if rettype in [:Cstring, :(Ptr{Cstring})]
            :(aftercare($cc))
        else
            cc
        end

        # stitch the modified function expression back together
        f = :(function $fname($(fargs′...))
            $cc′
        end) |> prettify

        # rename some things
        f = postwalk(x -> get(renames, x, x), f)

        return f
    end
    return ex
end

function rewrite!(dag::ExprDAG)
    for node in get_nodes(dag)
        map!(rewrite, node.exprs, node.exprs)
    end
end


cd(@__DIR__)

include_dir = normpath(artifact_dir, "include")

# wrapper generator options
options = load_options(joinpath(@__DIR__, "generator.toml"))

args = get_default_args()
push!(args, "-I$include_dir")

headers = [joinpath(include_dir, "proj.h"), joinpath(include_dir, "geodesic.h")]

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx, BUILDSTAGE_NO_PRINTING)
rewrite!(ctx.dag)
build!(ctx, BUILDSTAGE_PRINTING_ONLY)

# run JuliaFormatter on the whole package
format(joinpath(@__DIR__, ".."))
