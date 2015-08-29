## Types

# Projection context.  TODO: Will this be exposed?
#type Context
#    rep::Ptr{Void} # Pointer to internal projCtx struct
#end

@doc """
Cartographic projection type
""" ->
type Projection
    #ctx::Context   # Projection context object
    rep::Ptr{Void} # Pointer to internal projPJ struct
    
    # [geod]: a structure containing the parameters of the spheroid
    # some of the fields in [geod] are mildly duplicative of the information
    # available in [rep], which can be exposed only through _get_spheroid_defn

    # It's needed as an argument for computing great circle distances though,
    # and for most applications, users will only have to deal with a small number
    # of projection objects, and so we precompute it for each Projection
    geod::geod_geodesic
end

function Projection(proj_ptr::Ptr{Void})
    proj = Projection(proj_ptr,
                      geod_geodesic(_get_spheroid_defn(proj_ptr)...))
    finalizer(proj, freeProjection)
    proj
end

@doc """
Construct a projection from a string in proj.4 "plus format"

The projection string `proj_string` is defined in the proj.4 format,
with each part of the projection specification prefixed with '+' character.
For example:

    `wgs84 = Projection("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")`
""" ->
Projection(proj_string::ASCIIString) = Projection(_init_plus(proj_string))

function freeProjection(proj::Projection)
    _free(proj.rep)
    proj.rep = C_NULL
end

# Pretty printing
Base.print(io::IO, proj::Projection) = print(io, strip(_get_def(proj)))
Base.show(io::IO, proj::Projection) = print(io, "Projection(\"$proj\")")
