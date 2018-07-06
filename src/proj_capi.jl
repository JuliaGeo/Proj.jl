# For use in geodesic routines

abstract type _geodesic end

mutable struct null_geodesic <: _geodesic
end

# The following functions are generally named after the associated C API
# functions, but without the pj prefix.

struct ProjUV
    u::Cdouble
    v::Cdouble
end

"forward projection from Lat/Lon to X/Y (only supports 2 dimensions)"
function _fwd!(lonlat::Vector{Cdouble}, proj_ptr::Ptr{Cvoid})
    xy = ccall((:pj_fwd, libproj), ProjUV, (ProjUV, Ptr{Cvoid}), ProjUV(lonlat[1], lonlat[2]), proj_ptr)
    _errno() == 0 || error("forward projection error: $(_strerrno())")
    lonlat[1] = xy.u; lonlat[2] = xy.v
    lonlat
end

"Row-wise projection from Lat/Lon to X/Y (only supports 2 dimensions)"
function _fwd!(lonlat::Array{Cdouble,2}, proj_ptr::Ptr{Cvoid})
    for i=1:size(lonlat,1)
        xy = ccall((:pj_fwd, libproj), ProjUV, (ProjUV, Ptr{Cvoid}),
                   ProjUV(lonlat[i,1], lonlat[i,2]), proj_ptr)
        lonlat[i,1] = xy.u; lonlat[i,2] = xy.v
    end
    _errno() == 0 || error("forward projection error: $(_strerrno())")
    lonlat
end

"inverse projection from X/Y to Lat/Lon (only supports 2 dimensions)"
function _inv!(xy::Vector{Cdouble}, proj_ptr::Ptr{Cvoid})
    lonlat = ccall((:pj_inv, libproj), ProjUV, (ProjUV, Ptr{Cvoid}),
                   ProjUV(xy[1], xy[2]), proj_ptr)
    _errno() == 0 || error("inverse projection error: $(_strerrno())")
    xy[1] = lonlat.u; xy[2] = lonlat.v
    xy
end

"Row-wise projection from X/Y to Lat/Lon (only supports 2 dimensions)"
function _inv!(xy::Array{Cdouble,2}, proj_ptr::Ptr{Cvoid})
    for i=1:size(xy,1)
        lonlat = ccall((:pj_inv, libproj), ProjUV, (ProjUV, Ptr{Cvoid}),
                       ProjUV(xy[i,1], xy[i,2]), proj_ptr)
        xy[i,1] = lonlat.u; xy[i,2] = lonlat.v
    end
    _errno() == 0 || error("inverse projection error: $(_strerrno())")
    xy
end

function _init_plus(proj_string::String)
    proj_ptr = ccall((:pj_init_plus, libproj), Ptr{Cvoid}, (Cstring,), proj_string)
    if proj_ptr == C_NULL
        # TODO: use context?
        error("Could not parse projection: \"$proj_string\": $(_strerrno())")
    end
    proj_ptr
end

"Free C datastructure associated with a projection. For internal use!"
function _free(proj_ptr::Ptr{Cvoid})
    @assert proj_ptr != C_NULL
    ccall((:pj_free, libproj), Cvoid, (Ptr{Cvoid},), proj_ptr)
end

"Get human readable error string from proj.4 error code"
function _strerrno(code::Cint)
    unsafe_string(ccall((:pj_strerrno, libproj), Cstring, (Cint,), code))
end

"Get global errno string in human readable form"
function _strerrno()
    _strerrno(_errno())
end

"Get error number"
function _errno()
    unsafe_load(ccall((:pj_get_errno_ref, libproj), Ptr{Cint}, ()))
end

"Get projection definition string in the proj.4 plus format"
function _get_def(proj_ptr::Ptr{Cvoid})
    @assert proj_ptr != C_NULL
    opts = 0 # Apparently obsolete argument, not used in current proj source
    unsafe_string(ccall((:pj_get_def, libproj), Cstring, (Ptr{Cvoid}, Cint), proj_ptr, opts))
end

"Low level interface to libproj transform, C_NULL can be passed in for z, if it's 2-dimensional"
function _transform!(src_ptr::Ptr{Cvoid}, dest_ptr::Ptr{Cvoid}, point_count::Integer, point_stride::Integer,
                     x::Ptr{Cdouble}, y::Ptr{Cdouble}, z::Ptr{Cdouble})
    @assert src_ptr != C_NULL && dest_ptr != C_NULL
    err = ccall((:pj_transform, libproj), Cint, (Ptr{Cvoid}, Ptr{Cvoid}, Clong, Cint, Ptr{Cdouble}, Ptr{Cdouble},
                Ptr{Cdouble}), src_ptr, dest_ptr, point_count, point_stride, x, y, z)
    err != 0 && error("transform error: $(_strerrno(err))")
end

function _transform!(src_ptr::Ptr{Cvoid}, dest_ptr::Ptr{Cvoid}, position::Vector{Cdouble})
    @assert src_ptr != C_NULL && dest_ptr != C_NULL
    ndim = length(position)
    @assert ndim >= 2

    x = pointer(position)
    y = x + sizeof(Cdouble)
    z = (ndim == 2) ? Ptr{Cdouble}(C_NULL) : x + 2*sizeof(Cdouble)

    _transform!(src_ptr, dest_ptr, 1, 1, x, y, z)
    position
end
function _transform!(src_ptr::Ptr{Cvoid}, dest_ptr::Ptr{Cvoid}, position::Array{Cdouble,2})
    @assert src_ptr != C_NULL && dest_ptr != C_NULL
    npoints, ndim = size(position)
    @assert ndim >= 2

    x = pointer(position)
    y = x + sizeof(Cdouble)*npoints
    z = (ndim == 2) ? Ptr{Cdouble}(C_NULL) : x + 2*sizeof(Cdouble)*npoints

    _transform!(src_ptr, dest_ptr, npoints, 1, x, y, z)
    position
end

function _is_latlong(proj_ptr::Ptr{Cvoid})
    @assert proj_ptr != C_NULL
    ccall((:pj_is_latlong, libproj), Cint, (Ptr{Cvoid},), proj_ptr) != 0
end

function _is_geocent(proj_ptr::Ptr{Cvoid})
    @assert proj_ptr != C_NULL
    ccall((:pj_is_geocent, libproj), Cint, (Ptr{Cvoid},), proj_ptr) != 0
end

"Get a string describing the underlying version of libproj in use"
function _get_release()
    unsafe_string(ccall((:pj_get_release, libproj), Cstring, ()))
end

"""
Fetch the internal definition of the spheroid as a tuple (a, es), where

    a = major_axis
    es = eccentricity squared

"""
function _get_spheroid_defn(proj_ptr::Ptr{Cvoid})
    major_axis = Ref{Cdouble}()
    eccentricity_squared = Ref{Cdouble}()
    ccall((:pj_get_spheroid_defn, libproj), Cvoid, (Ptr{Cvoid}, Ptr{Cdouble}, Ptr{Cdouble}),
          proj_ptr, major_axis, eccentricity_squared)
    major_axis[], eccentricity_squared[]
end

"Returns true if the two datums are identical, otherwise false."
function _compare_datums(p1_ptr::Ptr{Cvoid}, p2_ptr::Ptr{Cvoid})
    Bool(ccall((:pj_compare_datums, libproj), Cint, (Ptr{Cvoid}, Ptr{Cvoid}), p1_ptr, p2_ptr))
end

# Unused/untested

# """
# Return the lat/long coordinate system on which a projection is based.
# If the coordinate system passed in is latlong, a clone of the same will be returned.
# """
# function _latlong_from_proj(proj_ptr::Ptr{Void})
#     ccall((:pj_latlong_from_proj, libproj), Ptr{Void}, (Ptr{Void},), proj_ptr)
# end
