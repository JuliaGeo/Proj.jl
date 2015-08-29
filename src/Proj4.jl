module Proj4

if VERSION < v"0.4.0-dev"
    using Docile
end
using Compat

const libproj = "libproj"

export Projection, # proj_types.jl
       transform, transform!, # proj_functions.jl
       is_latlong, is_geocent

include("projection_codes.jl") # ESRI and EPSG projection strings
include("proj_capi.jl") # low-level C-facing functions
include("proj_types.jl") # type definitions for proj objects
include("proj_functions.jl") # user-facing proj functions

@doc "Get a global error string in human readable form" ->
error_message() = _strerrno()

@doc "Get a string describing the underlying version of libproj in use" ->
version() = _get_release()

end # module
