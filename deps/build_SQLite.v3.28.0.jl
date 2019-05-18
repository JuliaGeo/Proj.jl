using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libsqlite3"], :libsqlite),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaDatabases/SQLiteBuilder/releases/download/v0.10.0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/SQLite.v3.28.0.aarch64-linux-gnu.tar.gz", "e8bb76f8a86a943d59215b8ec8b2308b08a48c78df5238210e65657da86c67b4"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/SQLite.v3.28.0.aarch64-linux-musl.tar.gz", "41b396e4e3843daed5de52eb0b884de6815e1aeab686fa4742c15c37ffe2a255"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/SQLite.v3.28.0.arm-linux-gnueabihf.tar.gz", "9810741a754f22320ac6cdb5e3723bcd5ba0fef301675282dcc616b1ab2b6a6e"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/SQLite.v3.28.0.arm-linux-musleabihf.tar.gz", "c973b1187e2c8de468f0b19a4a5d04e3b276e21c59bee09811418ae15cb83d10"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/SQLite.v3.28.0.i686-linux-gnu.tar.gz", "246e50c4412f69a8b127caa5e94d90f1e8674d365e64af42f02c29958fe2ea01"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/SQLite.v3.28.0.i686-linux-musl.tar.gz", "2028945661a8bd71dcf1b434b5743e9fe4a3e1f74f6ab6c3ae713d212d2670d1"),
    Windows(:i686) => ("$bin_prefix/SQLite.v3.28.0.i686-w64-mingw32.tar.gz", "a098ed658fb5f3b1194bb880d03069461c98f4179962784de8ee52d406635d44"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/SQLite.v3.28.0.powerpc64le-linux-gnu.tar.gz", "08b8c016d7acb22db0d884cf8c6e992a99158cd6749ef1dd37f0202a4c7e6ade"),
    MacOS(:x86_64) => ("$bin_prefix/SQLite.v3.28.0.x86_64-apple-darwin14.tar.gz", "046f597b79c53cbfbfd94d6b36fc2e8f2ba77284f10e026464c753a895661b70"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/SQLite.v3.28.0.x86_64-linux-gnu.tar.gz", "79e1a43df65ed22a3d3401b0607711a570f27f9caeb9d57d3e8ec90384461dd3"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/SQLite.v3.28.0.x86_64-linux-musl.tar.gz", "9267775482078afecde24aa894d165e04123ff47895a01f5047a7333505009a0"),
    FreeBSD(:x86_64) => ("$bin_prefix/SQLite.v3.28.0.x86_64-unknown-freebsd11.1.tar.gz", "45268da994d260fb322b1e75d4c500c61dd4936de9964911fa98edbde3db08e0"),
    Windows(:x86_64) => ("$bin_prefix/SQLite.v3.28.0.x86_64-w64-mingw32.tar.gz", "74cc63b003b85de0c0e8406b44310f6443f5f52f40ab61a28829a0e6dfbb4936"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)