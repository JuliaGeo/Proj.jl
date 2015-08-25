module Proj4

export transform, ProjPJ

const libproj = "libproj"

## Types

# Projection type (rename?)
type ProjPJ
    rep::Ptr{Void}
end

function ProjPJ(proj_string::String)
    ProjPJ(ccall((:pj_init_plus, libproj), Ptr{Void}, (Ptr{UInt8},), proj_string))
end


# Projection context (rename?)
type ProjCtx
    rep::Ptr{Void}
end


## Low-level interface stuff
function strerrno(code::Cint)
    bytestring(ccall((:pj_strerrno, "libproj"), Cstring, (Cint,), code))
end

function _transform!(src::ProjPJ, dest::ProjPJ, point_count, point_stride, x, y, z)
    ccall((:pj_transform, libproj), Cint,
          (Ptr{Void}, Ptr{Void}, Clong, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}),
          src.rep, dest.rep, point_count, point_stride, x, y, z)
end

function get_def(proj::ProjPJ)
    options = 0 # TODO: What is this?
    bytestring(ccall((:pj_get_def, libproj), Cstring, (Ptr{Void}, Cint), proj.rep, options))
end


## High level interface

"""
Show a projection in human readable form
"""
function Base.show(io::IO, proj::ProjPJ)
    defstr = strip(get_def(proj))
    print(io, "ProjPJ(\"$defstr\")")
end


"""
Return true if the projection is a geographic coordinate system (lon,lat)
"""
function is_latlong(proj::ProjPJ)
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
function transform!(src::ProjPJ, dest::ProjPJ, position::Array{Float64,2}; radians::Bool=false)
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
        error("transform error: $(strerrno(err))")
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
function transform(src::ProjPJ, dest::ProjPJ, position::Array{Float64,2}; radians::Bool=false)
    transform!(src, dest, copy(position), radians=radians)
end

function transform{T}(src::ProjPJ, dest::ProjPJ, position::Array{T,2}; radians::Bool=false)
    transform(src, dest, map(Float64, position), radians=radians)
end


# Hacky globals for debugging
#wgs84 = ProjPJ("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
#zone56 = ProjPJ("+proj=utm +zone=56 +south +ellps=WGS84 +datum=WGS84 +units=m +no_defs")

end
