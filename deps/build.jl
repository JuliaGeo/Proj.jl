using BinDeps

@BinDeps.setup

libproj_min_ver = v"4.9.0" # First verison with supporting the geodesic API

# Validate the version of the C library.  This is somewhat duplicated
# code, but has to happen here in the setup stage before any of the other code
# is loaded.
function validate_proj_version(libname, handle)
    pj_get_release = Libdl.dlsym_e(handle, :pj_get_release)
    pj_get_release != C_NULL || return false
    verstr = unsafe_string(ccall(pj_get_release, Cstring, ()))
    m = match(r"(\d+).(\d+).(\d+),.+", verstr)
    m !== nothing || return false
    ver = VersionNumber(parse(Int, m[1]), parse(Int, m[2]), parse(Int, m[3]))
    ver >= libproj_min_ver
end

libproj = library_dependency("libproj", validate=validate_proj_version)


# Provide a BuildProcess for linux, since the package manager provided libproj
# can be woefully old.
src_url = "http://download.osgeo.org/proj"
libproj_src_ver = v"4.9.2"
libproj_name = "proj-$(libproj_src_ver).tar.gz"
provides(Sources, URI("$src_url/$libproj_name"), libproj, os = :Unix)
prefix   = joinpath(BinDeps.depsdir(libproj), "usr")
srcdir   = joinpath(BinDeps.depsdir(libproj), "src", "proj-$(libproj_src_ver)")
builddir = joinpath(BinDeps.depsdir(libproj), "builds", "libproj-$(libproj_src_ver)_version")
libdir   = joinpath(prefix, "lib")
provides(BuildProcess,
    (@build_steps begin
        GetSources(libproj)
        CreateDirectory(builddir)
        @build_steps begin
            ChangeDirectory(builddir)
            FileRule(joinpath(libdir, "libproj.so"),
                     @build_steps begin
                         ChangeDirectory(srcdir)
                         `./configure --prefix=$(prefix)`
                         `make`
                         `make install`
                     end
            )
        end
    end),
    libproj,
    os = :Unix,
)


if is_apple()
    using Homebrew
    provides(Homebrew.HB, "proj", libproj, os = :Darwin)
end


# Create deps/deps.jl
# TODO(chris.foster): BinDeps.@load_dependencies doesn't work as advertised, so
# we're using @install instead.  See
# https://github.com/JuliaLang/BinDeps.jl/issues/196
@BinDeps.install Dict(:libproj => :libproj)
