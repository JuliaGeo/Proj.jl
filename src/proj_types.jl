## Types

# Projection context.  TODO: Will this be exposed?
#type Context
#    rep::Ptr{Cvoid} # Pointer to internal projCtx struct
#end

"""
Cartographic projection type
"""
mutable struct Projection
    #ctx::Context   # Projection context object
    rep::Ptr{Cvoid} # Pointer to internal projPJ struct

    # [geod]: a structure containing the parameters of the spheroid
    # some of the fields in [geod] are mildly duplicative of the information
    # available in [rep], which can be exposed only through _get_spheroid_defn
    geod::_geodesic
end

function Projection(proj_ptr::Ptr{Cvoid})
    proj = Projection(proj_ptr, null_geodesic())
    finalizer(freeProjection, proj)
    proj
end

"""
Construct a projection from a string in proj.4 "plus format"

The projection string `proj_string` is defined in the proj.4 format,
with each part of the projection specification prefixed with '+' character.
For example:

    `wgs84 = Projection("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")`
"""
Projection(proj_string::String) = Projection(_init_plus(proj_string))

function freeProjection(proj::Projection)
    _free(proj.rep)
    proj.rep = C_NULL
end

# Pretty printing
Base.print(io::IO, proj::Projection) = print(io, strip(_get_def(proj.rep)))
Base.show(io::IO, proj::Projection) = print(io, "Projection(\"$proj\")")

# Broadcast override
Base.Broadcast.broadcastable(p::Projection) = Ref(p)
