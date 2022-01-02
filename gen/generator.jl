using Clang.Generators
using MacroTools
import PROJ_jll

function rewrite!(x::Expr)
end

function rewrite!(dag::ExprDAG)
    for node in get_nodes(dag)
        for expr in get_exprs(node)
            rewrite!(expr)
        end
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