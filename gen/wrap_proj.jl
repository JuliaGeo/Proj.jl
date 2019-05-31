#=
Run this file to regenerate `proj_c.jl` and `proj_common.jl`.

It expects a PROJ install in the deps folder, run `build Proj4` in Pkg mode
if these are not in place.

The wrapped PROJ version and provided PROJ version should be kept in sync.
So when updating the PROJBuilder provided version, also rerun this wrapper.
This way we ensure that the provided library has the same functions available
as the wrapped one. Furthermore this makes sure constants in `proj_common.jl`
like `PROJ_VERSION_PATCH`, which are just literals, are correct.
=#

using Clang

includedir = normpath(joinpath(@__DIR__, "..", "deps", "usr", "include"))
headerfiles = [joinpath(includedir, "proj.h")]

wc = init(; headers = headerfiles,
            output_file = joinpath(@__DIR__, "proj_c.jl"),
            common_file = joinpath(@__DIR__, "proj_common.jl"),
            clang_includes = [includedir, CLANG_INCLUDE],
            clang_args = ["-I", includedir],
            header_wrapped = (root, current) -> root == current,
            header_library = x -> "libproj",
            clang_diagnostics = true,
            )

run(wc)
