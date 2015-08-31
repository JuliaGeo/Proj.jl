@doc "Return true if the projection is a geographic coordinate system" ->
is_latlong(proj::Projection) = _is_latlong(proj.rep)

@doc "Return true if the projection is a geocentric coordinate system" ->
is_geocent(proj::Projection) = _is_geocent(proj.rep)

@doc "Returns true if the datums for the two projections are identical" ->
compare_datums(p1::Projection, p2::Projection) = _compare_datums(p1.rep, p2.rep)

@doc """
Return the definition of the spheroid as a tuple (a, es), where
    
    a = major_axis
    es = eccentricity squared

""" ->
spheroid_params(proj::Projection) = _get_spheroid_defn(proj.rep)

@doc """
Returns the forward projection from LatLon to XY in the given projection,
modifying the input lonlat inplace (only supports 2 dimensions)""" ->
function lonlat2xy!(lonlat::Vector{Float64}, proj::Projection, radians::Bool=false)
    !radians && (lonlat[:] = deg2rad(lonlat))
    _fwd!(lonlat, proj.rep)
end

function lonlat2xy!(lonlat::Array{Float64,2}, proj::Projection, radians::Bool=false)
    if !radians
        for i in eachindex(lonlat)
            lonlat[i] = deg2rad(lonlat[i])
        end
    end
    _fwd!(lonlat, proj.rep)
end

@doc "Returns the forward projection from LonLat to XY in the given projection (only supports 2 dimensions)" ->
lonlat2xy(lonlat::Vector{Float64}, proj::Projection, radians::Bool=false) =
    lonlat2xy!(copy(lonlat), proj, radians)
lonlat2xy(lonlat::Array{Float64,2}, proj::Projection, radians::Bool=false) =
    lonlat2xy!(copy(lonlat), proj, radians)

@doc """
Returns the inverse projection from XY to LonLat in the given projection,
modifying the input xy inplace (only supports 2 dimensions)""" ->
function xy2lonlat!(xy::Vector{Float64}, proj::Projection, radians::Bool=false)
    _inv!(xy, proj.rep)
    !radians && (xy[1:2] = rad2deg(xy[1:2]))
    xy
end

function xy2lonlat!(xy::Array{Float64,2}, proj::Projection, radians::Bool=false)
    _inv!(xy, proj.rep)
    if !radians
        for i in eachindex(xy)
            xy[i] = rad2deg(xy[i])
        end
    end
    xy
end

@doc "Returns the inverse projection from XY to LatLon in the given projection (only supports 2 dimensions)" ->
xy2lonlat(xy::Vector{Float64}, proj::Projection, radians::Bool=false) = xy2lonlat!(copy(xy), proj, radians)
xy2lonlat(xy::Array{Float64,2}, proj::Projection, radians::Bool=false) = xy2lonlat!(copy(xy), proj, radians)

@doc """
Transform between geographic or projected coordinate systems

Args:

    src      - Source coordinate system definition
    dest     - Destination coordinate system definition
    position - An Nx2 or Nx3 array of coordinates to be transformed in place.
               For geographic coordinate systems, the first two columns are
               the *longitude* and *latitude*, in that order.
    radians  - If true, treat geographic lon,lat coordinates as radians on
               input and output.

Returns:

    position - Transformed position
""" ->
function transform2!(src::Projection, dest::Projection, position::Array{Float64,2}, radians::Bool=false)
    !radians && is_latlong(src) && (position[:,1:2] = deg2rad(position[:,1:2]))
    _transform2!(src.rep, dest.rep, position[:,1:2])
    !radians && is_latlong(dest) && (position[:,1:2] = rad2deg(position[:,1:2]))
    position
end
transform2(src::Projection, dest::Projection, position::Array{Float64,2}, radians::Bool=false) =
    transform2!(src, dest, copy(position[:,1:2]), radians)

function transform2!(src::Projection, dest::Projection, position::Vector{Float64}, radians::Bool=false)
    !radians && is_latlong(src) && (position[1:2] = deg2rad(position))
    _transform2!(src.rep, dest.rep, position)
    !radians && is_latlong(dest) && (position[1:2] = rad2deg(position))
    position
end
transform2(src::Projection, dest::Projection, position::Vector{Float64}, radians::Bool=false) =
    transform2!(src, dest, copy(position), radians)

function transform3!(src::Projection, dest::Projection, position::Array{Float64,2}, radians::Bool=false)
    !radians && is_latlong(src) && (position[:,1:3] = deg2rad(position[:,1:3]))
    _transform3!(src.rep, dest.rep, position[:,1:3])
    !radians && is_latlong(dest) && (position[:,1:3] = rad2deg(position[:,1:3]))
    position
end
transform3(src::Projection, dest::Projection, position::Array{Float64,2}, radians::Bool=false) =
    transform3!(src, dest, copy(position[:,1:3]), radians)

function transform3!(src::Projection, dest::Projection, position::Vector{Float64}, radians::Bool=false)
    !radians && is_latlong(src) && (position[1:3] = deg2rad(position))
    _transform3!(src.rep, dest.rep, position)
    !radians && is_latlong(dest) && (position[1:3] = rad2deg(position))
    position
end
transform3(src::Projection, dest::Projection, position::Vector{Float64}, radians::Bool=false) =
    transform3!(src, dest, copy(position), radians)

function transform!(src::Projection, dest::Projection, position::Array{Float64,2}, radians::Bool=false)
    ndim = size(position,2)
    ndim == 2 && return transform2!(src, dest, position, radians)
    ndim == 3 && return transform3!(src, dest, position, radians)
    error("position must be Nx2 or Nx3")
end
transform!(src::Projection, dest::Projection, position::Array{Float64,2}, radians::Bool=false) =
    transform!(src, dest, copy(position), radians)

function transform!(src::Projection, dest::Projection, position::Vector{Float64}, radians::Bool=false)
    ndim = length(position)
    ndim == 2 && return transform2!(src, dest, position, radians)
    ndim == 3 && return transform3!(src, dest, position, radians)
    error("position must be 2 or 3-dimensional")
end
transform(src::Projection, dest::Projection, position::Vector{Float64}, radians::Bool=false) =
    transform!(src, dest, copy(position), radians)

# Unused/untested
# @doc """
# Return the lat/long coordinate system on which a projection is based.
# If the coordinate system passed in is latlong, a clone of the same will be returned.
# """ ->
# latlong_projection(proj::Projection) = Projection(_latlong_from_proj(proj.rep))

@doc """
Solve the direct geodesic problem.

Args:

    position - coordinates of starting location, modified in-place to [dest] (described below)
    azimuth  - azimuth (degrees) ∈ [-540, 540)
    distance - distance (metres) to move from (lat,lon); can be negative
    proj     - the given projection whose ellipsoid we move along
   
Returns:

    dest     - destination after moving for [distance] metres in [azimuth] direction.
    azi      - forward azimuth (degrees) at destination [dest].
""" ->
function geod_direct!(position::Vector{Float64}, azimuth::Float64, distance::Float64, proj::Projection)
    xy2lonlat!(position, proj)
    dest, azi = _geod_direct!(proj.geod, position, azimuth, distance)
    lonlat2xy!(dest, proj), azi
end

@doc """
Solve the direct geodesic problem.

Args:

    lonlat   - latitude, longitude (degrees) ∈ [-90, 90]
    azimuth  - azimuth (degrees) ∈ [-540, 540)
    distance - distance (metres) to move from (lat,lon); can be negative
    proj     - the given projection whose ellipsoid we move along
   
Returns:

    dest     - destination after moving for [distance] metres in [azimuth] direction.
    azi      - forward azimuth (degrees) at destination [dest].

""" ->
geod_direct(position::Vector{Float64}, azimuth::Float64, distance::Float64, proj::Projection) = 
    geod_direct!(copy(position), azimuth, distance, proj)

@doc "Returns the destination by moving along the ellipsoid in the given projection" ->
destination!(position::Vector{Float64}, azi::Float64, dist::Float64, proj::Projection) = geod_direct!(position, azi, dist, proj)[1]
destination(position::Vector{Float64}, azi::Float64, dist::Float64, proj::Projection) = destination!(copy(position), azi, dist, proj)

@doc """
Solve the inverse geodesic problem.

Args:

    xy1     - coordinates of point 1 in the given projection
    xy2     - coordinates of point 2 in the given projection
    proj    - the given projection whose ellipsoid we move along

Returns:

    dist    - distance between point 1 and point 2 (meters).
    azi1    - azimuth at point 1 (degrees) ∈ [-180, 180)
    azi2    - (forward) azimuth at point 2 (degrees) ∈ [-180, 180)

Remarks:

    If either point is at a pole, the azimuth is defined by keeping the longitude fixed,
    writing lat = 90 +/- eps, and taking the limit as eps -> 0+.
""" ->
geod_inverse(xy1::Vector{Float64}, xy2::Vector{Float64}, proj::Projection) =
    _geod_inverse(proj.geod, xy2lonlat(xy1, proj), xy2lonlat(xy2, proj))

@doc "Returns the distance between the two points in the given projection" ->
ellps_distance(p1::Vector{Float64}, p2::Vector{Float64}, proj::Projection) = geod_inverse(p1, p2, proj)[1]
