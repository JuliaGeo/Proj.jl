using BinDeps

@BinDeps.setup

libproj = library_dependency("libproj", aliases = ["libproj"])

@linux_only begin
    provides(AptGet, "libproj0", libproj, os = :Linux)
end

@osx_only begin
    if Pkg.installed("Homebrew") === nothing
        error("Homebrew package not installed, please run Pkg.add(\"Homebrew\")")
    end
    using Homebrew
    provides(Homebrew.HB, "proj", libproj, os = :Darwin)
end

@BinDeps.install
