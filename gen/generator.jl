using Clang.Generators
using MacroTools
import PROJ_jll

function rewrite(ex::Expr)
    if @capture(ex,
        function fname_(fargs__)
            @ccall lib_.cname_(cargs__)::rettype_
        end
    )
        fargs′ = fargs
        # ctx argument goes last and becomes optional
        if !isempty(fargs) && namify(first(fargs)) == :ctx
            fargs′ = circshift(fargs, -1)
            fargs′[end] = Expr(:kw, :ctx, :C_NULL)
        end

        # bind the ccall such that we can easily wrap it
        cc = :(@ccall $lib.$cname($(cargs...))::$rettype)
        cc′ = rettype == :Cstring ? :(unsafe_string($cc)) : cc

        # stitch the modified function expression back together
        return :(function $fname($(fargs′...))
            $cc′
        end) |> prettify

    end
    return ex
end

function rewrite!(dag::ExprDAG)
    for node in get_nodes(dag)
        map!(rewrite, node.exprs, node.exprs)
    end
end


cd(@__DIR__)

include_dir = normpath(PROJ_jll.artifact_dir, "include")

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
