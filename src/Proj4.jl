module Proj4

const libproj = "libproj"

export Projection, # proj_types.jl
       transform2, transform2!, transform3, transform3!, transform, transform!,  # proj_functions.jl
       is_latlong, is_geocent, is_identical, spheroid_params,
       xy2lonlat, xy2lonlat!, lonlat2xy, lonlat2xy!,
       geod_direct, geod_inverse, destination, ellps_distance

include("projection_codes.jl") # ESRI and EPSG projection strings
include("proj_capi.jl") # low-level C-facing functions (corresponding to src/proj_api.h)
include("proj_geodesic.jl") # low-level C-facing functions (corresponding to src/geodesic.h)
include("proj_types.jl") # type definitions for proj objects
include("proj_functions.jl") # user-facing proj functions

@doc "Get a global error string in human readable form" ->
error_message() = _strerrno()

@doc "Get a string describing the underlying version of libproj in use" ->
version() = _get_release()

end # module
