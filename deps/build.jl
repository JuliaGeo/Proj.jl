using BinDeps

@BinDeps.setup

#@BinDeps.if_install begin

libproj = library_dependency("libproj", aliases = ["libproj"])
const libproj_ver = "4.9.1"

@linux_only begin
	
	# AptGet's LibProj is old
	#provides(AptGet, "libproj0", libproj, os = :Linux)  

	# so download a newer version
	provides(Sources, URI("http://download.osgeo.org/proj/proj-$(libproj_ver).tar.gz"), libproj, os = :Linux)

	# build it from source
	prefix   = joinpath(BinDeps.depsdir(libproj), "usr")
	srcdir   = joinpath(BinDeps.depsdir(libproj), "src", "proj-$(libproj_ver)")
	builddir = joinpath(BinDeps.depsdir(libproj), "builds", "libproj-$(libproj_ver)_version")
	provides(BuildProcess,
		(@build_steps begin
			GetSources(libproj)
			CreateDirectory(builddir)
			@build_steps begin
				CreateDirectory(prefix)
				println(srcdir)
				cd(srcdir)
				FileRule(joinpath(prefix,"lib","libproj.so"), @build_steps begin
					#`./configure --prefix="$prefix"`
					`./configure`   # installs to usr/local/lib by default
					`make`
					`make install`
					srcdir
				end)
			end
		end),libproj, os = :Linux)
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
