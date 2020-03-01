#=
This script creates the Artifact.toml that will lazily provide the proj-datumgrid resources.
For more information see https://proj.org/resource_files.html

The resources will be downloaded from GitHub releases from this URL:
    https://github.com/OSGeo/proj-datumgrid/releases
With as a fallback option the OSGeo website:
    https://download.osgeo.org/proj/

To update to newer versions of one of the proj-datumgrid bundles, update the entry in the
datumgrids vector below, updating the version and sha256_hash. Then run this script again,
move the newly generated Artifact.toml over the one in the root of this package, and make
a pull request with the updated Artifact.toml.

Note that as of writing, this script will download about 1 GB of data.
=#

using Pkg.Artifacts
using BinaryProvider

# this file will be either created, or appended to
artifacts_toml = joinpath(@__DIR__, "Artifacts.toml")

datumgrids = [
    (name="proj-datumgrid", version=v"1.8", sha256_hash="3ff6618a0acc9f0b9b4f6a62e7ff0f7bf538fb4f74de47ad04da1317408fcc15"),
    (name="proj-datumgrid-europe", version=v"1.6", sha256_hash="af2f4f364d84eb9d5ca23403f8540ae8daee54ec900903bc92d48afb1ed285f8"),
    (name="proj-datumgrid-north-america", version=v"1.4", sha256_hash="95a6cdcdc078caed412ea66d3fdd2f699286336d5ca6c98bffb2d7132585ce40"),
    (name="proj-datumgrid-oceania", version=v"1.2", sha256_hash="952c43886c9ed6a098c308de61161a00cbe83fbb0f6e9e43c0c25c323bb06a4c"),
    (name="proj-datumgrid-world", version=v"1.0", sha256_hash="a488a5a69d1af6ec2ee83a2c64c52adac52e6dbfafe883f0341340009a9f40ba"),
]

for datumgrid in datumgrids
    # get the elements we need to build the correct URL
    name = datumgrid.name
    version = string(datumgrid.version.major, '.', datumgrid.version.minor)
    if name == "proj-datumgrid"
        tag = version
    else
        region = replace(name, "proj-datumgrid-"=>"")
        tag = string(region, '-', version)
    end
    sha = datumgrid.sha256_hash
    url1 = "https://github.com/OSGeo/proj-datumgrid/releases/download/$tag/$name-$version.tar.gz"
    url2 = "https://download.osgeo.org/proj/$name-$version.tar.gz"
    download_info = [(url1, sha), (url2, sha)]

    # download the package and save the hash
    proj_hash = create_artifact() do artifact_dir
        download_verify_unpack(url1, sha, artifact_dir, verbose=true, ignore_existence=true)
    end

    # add the new entry to the Artifact.toml together with the download info
    bind_artifact!(artifacts_toml, name, proj_hash; download_info=download_info, lazy=true, force=true)

    @info "created artifact" name version proj_hash artifacts_toml
end
