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
    (name="proj-datumgrid-europe", version=v"1.5", sha256_hash="70d47c31b6c34a323cd47176ffccf77b439e450e51805646d8560d605eee38df"),
    (name="proj-datumgrid-north-america", version=v"1.3", sha256_hash="d30713ab673038a6add28e98c4e7ce1bfbacd803966d32700d082731268c9910"),
    (name="proj-datumgrid-oceania", version=v"1.1", sha256_hash="63a844c294c9f29b29e25eea01d6da0ff3596be7c8660afb17090c3bc4045ae3"),
    (name="proj-datumgrid-world", version=v"1.0", sha256_hash="a488a5a69d1af6ec2ee83a2c64c52adac52e6dbfafe883f0341340009a9f40ba"),
]

for datumgrid in datumgrids
    # get the elements we need to build the correct URL
    name = datumgrid.name
    version = string(datumgrid.version.major, '.', datumgrid.version.minor)
    if name == "proj-datumgrid"
        tag = version
        lazy = false  # this one is required for a functional proj
    else
        region = replace(name, "proj-datumgrid-"=>"")
        tag = string(region, '-', version)
        lazy = true
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
    bind_artifact!(artifacts_toml, name, proj_hash; download_info=download_info, lazy=lazy, force=true)

    @info "created artifact" name version proj_hash artifacts_toml
end
