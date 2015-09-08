module Proj4

const libproj = "libproj"

export Projection, # proj_types.jl
       transform, transform!,  # proj_functions.jl
       is_latlong, is_geocent, compare_datums, spheroid_params,
       xy2lonlat, xy2lonlat!, lonlat2xy, lonlat2xy!

include("projection_codes.jl") # ESRI and EPSG projection strings
include("proj_capi.jl") # low-level C-facing functions (corresponding to src/proj_api.h)

__m = match(r"(\d+).(\d+).(\d+),.+", _get_release())
version_release = parse(Int, __m[1])
version_major  = parse(Int, __m[2])
version_minor = parse(Int, __m[3])
if version_release >= 4 && version_major >= 9 && version_minor >= 1
    export geod_direct, geod_inverse, geod_destination, geod_distance
    include("proj_geodesic.jl") # low-level C-facing functions (corresponding to src/geodesic.h)
end

include("proj_types.jl") # type definitions for proj objects
include("proj_functions.jl") # user-facing proj functions

@doc "Get a global error string in human readable form" ->
error_message() = _strerrno()

@doc "Get a string describing the underlying version of libproj in use" ->
version() = _get_release()

end # module
