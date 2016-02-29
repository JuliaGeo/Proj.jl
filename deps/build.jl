using BinDeps

@BinDeps.setup

#@BinDeps.if_install begin

libproj = library_dependency("libproj", aliases = ["libproj"])


@linux_only begin

	
	
	# AptGet's LibProj is old
	#provides(AptGet, "libproj0", libproj, os = :Linux)  

	# so download a newer version
	libsrc = "http://download.osgeo.org/proj"
	libproj_ver = "4.9.1" # from source http://download.osgeo.org/proj/
	libproj_name = "proj-$(libproj_ver).tar.gz"

	# and build it from source
	prefix   = joinpath(BinDeps.depsdir(libproj), "usr")
	srcdir   = joinpath(BinDeps.depsdir(libproj), "src", "proj-$(libproj_ver)")
	builddir = joinpath(BinDeps.depsdir(libproj), "builds", "libproj-$(libproj_ver)_version")
	libdir   = joinpath(prefix, "lib")

	provides(Sources, URI(joinpath(libsrc, libproj_name)), libproj, os = :Linux, installed_libpath=libdir)

	provides(BuildProcess,
		(@build_steps begin
			GetSources(libproj)
			CreateDirectory(builddir)
			@build_steps begin
				ChangeDirectory(builddir)
				FileRule(joinpath(libdir, "libproj.so"), 
				@build_steps begin
					`$(srcdir)/configure --prefix=$(prefix)`
					`make`
					#`sudo make install`
				end)
			end
		end), libproj, os = :Linux, installed_libpath=libdir)
end

@osx_only begin
    if Pkg.installed("Homebrew") === nothing
        error("Homebrew package not installed, please run Pkg.add(\"Homebrew\")")
    end
    using Homebrew
    provides(Homebrew.HB, "proj", libproj, os = :Darwin)
end

@BinDeps.install

#end
