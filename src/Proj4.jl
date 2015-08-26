module Proj4

export transform, Projection

## Types

# Projection context.  TODO: Will this be exposed?
type Context
    rep::Ptr{Void} # Pointer to internal projCtx struct
end

"""
Cartographic projection type
"""
type Projection
    #ctx::Context   # Projection context object
    rep::Ptr{Void} # Pointer to internal projPJ struct
end



## Low-level interface pieces
const libproj = "libproj"

"Free C datastructure associated with a projection.  For internal use only!"
function _free(proj::Projection)
    @assert proj.rep != C_NULL
    ccall((:pj_free, libproj), Void, (Ptr{Void},), proj.rep)
    proj.rep = C_NULL
end

"Get human readable error string from proj.4 error code"
function _strerrno(code::Cint)
    bytestring(ccall((:pj_strerrno, libproj), Cstring, (Cint,), code))
end

"Get global errno string in human readable form"
function _strerrno()
    _strerrno(unsafe_load(ccall((:pj_get_errno_ref, libproj), Ptr{Cint}, ())))
end

"Get projection definition string in the proj.4 plus format"
function _get_def(proj::Projection)
    @assert proj.rep != C_NULL
    opts = 0 # Apparently obsolete argument, not used in current proj source
    bytestring(ccall((:pj_get_def, libproj), Cstring, (Ptr{Void}, Cint), proj.rep, opts))
end

"""Low level interface to libproj transform, allowing user to specify strides"""
function _transform!(src::Projection, dest::Projection, point_count, point_stride, x, y, z)
    @assert src.rep != C_NULL && dest.rep != C_NULL
    ccall((:pj_transform, libproj), Cint,
          (Ptr{Void}, Ptr{Void}, Clong, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}),
          src.rep, dest.rep, point_count, point_stride, x, y, z)
end



## High level interface

"""
Construct a projection from a string in proj.4 "plus format"

The projection string `proj_string` is defined in the proj.4 format,
with each part of the projection specification prefixed with '+' character.
For example:

    `wgs84 = Projection("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")`
"""
function Projection(proj_string::String)
    proj = Projection(ccall((:pj_init_plus, libproj), Ptr{Void}, (Ptr{UInt8},), proj_string))
    if proj.rep == C_NULL
        # TODO: use context?
        error("Could not parse projection string: \"$proj_string\": $(_strerrno())")
    end
    finalizer(proj, _free)
    proj
end


"""
Show a projection in human readable form
"""
function Base.show(io::IO, proj::Projection)
    defstr = strip(_get_def(proj))
    print(io, "Projection(\"$defstr\")")
end


"""
Return true if the projection is a geographic coordinate system (lon,lat)
"""
function is_latlong(proj::Projection)
    @assert proj.rep != C_NULL
    ccall((:pj_is_latlong, libproj), Cint, (Ptr{Void},), proj.rep) != 0
end


"""
Transform between geographic or projected coordinate systems

Args:
    src      - Source coordinate system definition
    dest     - Destination coordinate system definition
    position - An Nx2 or Nx3 array of coordinates to be transformed in place.

    radians  - If true, treat geographic lon,lat coordinates as radians on
               input and output.

Returns:
    position - Transformed position
"""
function transform!(src::Projection, dest::Projection, position::Array{Float64,2}; radians::Bool=false)
    npoints = size(position,1)
    ncomps = size(position,2)
    if ncomps != 2 && ncomps != 3
        error("position must be Nx2 or Nx3")
    end
    if !radians && is_latlong(src)
        position[:,1:2] = deg2rad(position[:,1:2])
    end
    P = pointer(position)
    x = P
    y = P + sizeof(Cdouble)*npoints
    z = ncomps < 3 ? C_NULL : P + 2*sizeof(Cdouble)*npoints
    err = _transform!(src, dest, npoints, 1, x, y, z)
    if err != 0
        error("transform error: $(_strerrno(err))")
    end
    if !radians && is_latlong(dest)
        position[:,1:2] = rad2deg(position[:,1:2])
    end
    position
end


"""
Transform between geographic or projected coordinate systems

See transform! for details.
"""
function transform(src::Projection, dest::Projection, position::Array{Float64,2}; radians::Bool=false)
    transform!(src, dest, copy(position), radians=radians)
end

function transform{T}(src::Projection, dest::Projection, position::Array{T,2}; radians::Bool=false)
    transform(src, dest, map(Float64, position), radians=radians)
end


# Hacky globals for debugging
wgs84 = Projection("+proj=longlat +datum=WGS84 +no_defs")
zone56 = Projection("+proj=utm +zone=56 +south +datum=WGS84 +units=m +no_defs")

end # module
