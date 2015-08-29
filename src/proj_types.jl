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
end

@doc """
Construct a projection from a string in proj.4 "plus format"

The projection string `proj_string` is defined in the proj.4 format,
with each part of the projection specification prefixed with '+' character.
For example:

    `wgs84 = Projection("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")`
""" ->
function Projection(proj_string::ASCIIString)
    proj = Projection(_init_plus(proj_string))
    finalizer(proj, freeProjection)
    proj
end

function freeProjection(proj::Projection)
    _free(proj.rep)
    proj.rep = C_NULL
end

# Pretty printing
Base.print(io::IO, proj::Projection) = print(io, strip(_get_def(proj)))
Base.show(io::IO, proj::Projection) = print(io, "Projection(\"$proj\")")
