# The following functions are generally named after the associated C API
# functions, but without the pj prefix.

immutable ProjUV
    u::Cdouble
    v::Cdouble
end

@doc "forward projection from Lat/Lon to X/Y (only supports 2 dimensions)" ->
function _fwd!(lonlat::Vector{Cdouble}, proj_ptr::Ptr{Void})
    xy = ccall((:pj_fwd, libproj), ProjUV, (ProjUV, Ptr{Void}), ProjUV(lonlat[1], lonlat[2]), proj_ptr)
    lonlat[1] = xy.u; lonlat[2] = xy.v
    lonlat
end

@doc "Row-wise projection from Lat/Lon to X/Y (only supports 2 dimensions)" ->
function _fwd!(lonlat::Array{Cdouble,2}, proj_ptr::Ptr{Void})
    for i=1:size(lonlat,1)
        xy = ccall((:pj_fwd, libproj), ProjUV, (ProjUV, Ptr{Void}),
                   ProjUV(lonlat[i,1], lonlat[i,2]), proj_ptr)
        lonlat[i,1] = xy.u; lonlat[i,2] = xy.v
    end
    lonlat
end

@doc "inverse projection from X/Y to Lat/Lon (only supports 2 dimensions)" ->
function _inv!(xy::Vector{Cdouble}, proj_ptr::Ptr{Void})
    lonlat = ccall((:pj_inv, libproj), ProjUV, (ProjUV, Ptr{Void}),
                   ProjUV(xy[1], xy[2]), proj_ptr)
    xy[1] = lonlat.u; xy[2] = lonlat.v
    xy
end

@doc "Row-wise projection from X/Y to Lat/Lon (only supports 2 dimensions)" ->
function _inv!(xy::Array{Cdouble,2}, proj_ptr::Ptr{Void})
    for i=1:size(xy,1)
        lonlat = ccall((:pj_inv, libproj), ProjUV, (ProjUV, Ptr{Void}),
                       ProjUV(xy[i,1], xy[i,2]), proj_ptr)
        xy[i,1] = lonlat.u; xy[i,2] = lonlat.v
    end
    xy
end

function _init_plus(proj_string::ASCIIString)
    proj_ptr = ccall((:pj_init_plus, libproj), Ptr{Void}, (Cstring,), proj_string)
    if proj_ptr == C_NULL
        # TODO: use context?
        error("Could not parse projection: \"$proj_string\": $(_strerrno())")
    end
    proj_ptr
end

@doc "Free C datastructure associated with a projection. For internal use!" ->
function _free(proj_ptr::Ptr{Void})
    @assert proj_ptr != C_NULL
    ccall((:pj_free, libproj), Void, (Ptr{Void},), proj_ptr)
end

@doc "Get human readable error string from proj.4 error code" ->
function _strerrno(code::Cint)
    bytestring(ccall((:pj_strerrno, libproj), Cstring, (Cint,), code))
end

@doc "Get global errno string in human readable form" ->
function _strerrno()
    _strerrno(unsafe_load(ccall((:pj_get_errno_ref, libproj), Ptr{Cint}, ())))
end

@doc "Get projection definition string in the proj.4 plus format" ->
function _get_def(proj_ptr::Ptr{Void})
    @assert proj_ptr != C_NULL
    opts = 0 # Apparently obsolete argument, not used in current proj source
    bytestring(ccall((:pj_get_def, libproj), Cstring, (Ptr{Void}, Cint), proj_ptr, opts))
end

@doc "Low level interface to libproj transform, C_NULL can be passed in for z, if it's 2-dimensional" ->
function _transform!(src_ptr::Ptr{Void}, dest_ptr::Ptr{Void}, point_count::Int, point_stride::Int,
                     x::Ptr{Cdouble}, y::Ptr{Cdouble}, z::Ptr{Cdouble})
    @assert src_ptr != C_NULL && dest_ptr != C_NULL
    err = ccall((:pj_transform, libproj), Cint, (Ptr{Void}, Ptr{Void}, Clong, Cint, Ptr{Cdouble}, Ptr{Cdouble},
                Ptr{Cdouble}), src_ptr, dest_ptr, Clong(point_count), Cint(point_stride), x, y, z)
    err != 0 && error("transform error: $(_strerrno(err))")
end

function _transform2!(src_ptr::Ptr{Void}, dest_ptr::Ptr{Void}, position::Vector{Cdouble}, npoints::Int=1)
    @assert src_ptr != C_NULL && dest_ptr != C_NULL
    x = pointer(position)
    y = x + sizeof(Cdouble)*npoints
    _transform!(src_ptr, dest_ptr, npoints, 1, x, y, Ptr{Cdouble}(C_NULL))
    position
end
_transform2!(src_ptr::Ptr{Void}, dest_ptr::Ptr{Void}, position::Array{Cdouble,2}) =
    _transform2!(src_ptr, dest_ptr, vec(position), size(position,1))

function _transform3!(src_ptr::Ptr{Void}, dest_ptr::Ptr{Void}, position::Vector{Cdouble}, npoints::Int=1)
    @assert src_ptr != C_NULL && dest_ptr != C_NULL
    x = pointer(position)
    y = x + sizeof(Cdouble)*npoints
    z = x + 2*sizeof(Cdouble)*npoints
    _transform!(src_ptr, dest_ptr, npoints, 1, x, y, z)
    position
end
_transform3!(src_ptr::Ptr{Void}, dest_ptr::Ptr{Void}, position::Array{Cdouble,2}) =
    _transform3!(src_ptr, dest_ptr, vec(position))

function _transform!(src_ptr::Ptr{Void}, dest_ptr::Ptr{Void}, position::Vector{Cdouble}, npoints=1)
    ndim = size(position, 2)
    ndim == 2 && return _transform2!(src_ptr, dest_ptr, position)
    ndim == 3 && return _transform3!(src_ptr, dest_ptr, position)
    error("position must be Nx2 or Nx3")
end
_transform!(src_ptr::Ptr{Void}, dest_ptr::Ptr{Void}, position::Array{Cdouble,2}) =
    _transform!(src_ptr, dest_ptr, vec(position), size(position,1))

function _is_latlong(proj_ptr::Ptr{Void})
    @assert proj_ptr != C_NULL
    ccall((:pj_is_latlong, libproj), Cint, (Ptr{Void},), proj_ptr) != 0
end

function _is_geocent(proj_ptr::Ptr{Void})
    @assert proj_ptr != C_NULL
    ccall((:pj_is_geocent, libproj), Cint, (Ptr{Void},), proj_ptr) != 0
end

@doc "Get a string describing the underlying version of libproj in use" ->
function _get_release()
    bytestring(ccall((:pj_get_release, libproj), Cstring, ()))
end

@doc """
Fetch the internal definition of the spheroid as a tuple (a, es), where
    
    a = major_axis
    es = eccentricity squared

""" ->
function _get_spheroid_defn(proj_ptr::Ptr{Void})
    major_axis = Ref{Cdouble}()
    eccentricity_squared = Ref{Cdouble}()
    ccall((:pj_get_spheroid_defn, libproj), Void, (Ptr{Void}, Ptr{Cdouble}, Ptr{Cdouble}),
          proj_ptr, major_axis, eccentricity_squared)
    major_axis[], eccentricity_squared[]
end

@doc "Returns true if the two datums are identical, otherwise false." ->
function _compare_datums(p1_ptr::Ptr{Void}, p2_ptr::Ptr{Void})
    Bool(ccall((:pj_compare_datums, libproj), Cint, (Ptr{Void}, Ptr{Void}), p1_ptr, p2_ptr))
end

# Unused/untested

# @doc """
# Return the lat/long coordinate system on which a projection is based.
# If the coordinate system passed in is latlong, a clone of the same will be returned.
# """ ->
# function _latlong_from_proj(proj_ptr::Ptr{Void})
#     ccall((:pj_latlong_from_proj, libproj), Ptr{Void}, (Ptr{Void},), proj_ptr)
# end
