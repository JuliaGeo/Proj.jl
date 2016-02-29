VERSION >= v"0.4.0-dev+6521" && __precompile__(true)  # BinDeps is a little slow

module Proj4


using BinDeps
@BinDeps.load_dependencies

@linux_only begin
	push!(Libdl.DL_LOAD_PATH, dirname(Proj4.libproj[1][end]))
end
const libproj_str = "libproj"    # there must be a better way...

export Projection, # proj_types.jl
       transform, transform!,  # proj_functions.jl
       is_latlong, is_geocent, compare_datums, spheroid_params,
       xy2lonlat, xy2lonlat!, lonlat2xy, lonlat2xy!

include("projection_codes.jl") # ESRI and EPSG projection strings
include("proj_capi.jl") # low-level C-facing functions (corresponding to src/proj_api.h)

function _version()
    m = match(r"(\d+).(\d+).(\d+),.+", _get_release())
    VersionNumber(parse(Int, m[1]), parse(Int, m[2]), parse(Int, m[3]))
end

@doc "Parsed version number for the underlying version of libproj" ->
const version = _version()

# Detect underlying libproj support for geodesic calculations
const has_geodesic_support = version >= v"4.9.0"

if has_geodesic_support
    export geod_direct, geod_inverse, geod_destination, geod_distance
    include("proj_geodesic.jl") # low-level C-facing functions (corresponding to src/geodesic.h)
end

include("proj_types.jl") # type definitions for proj objects
include("proj_functions.jl") # user-facing proj functions

@doc "Get a global error string in human readable form" ->
error_message() = _strerrno()

end # module
