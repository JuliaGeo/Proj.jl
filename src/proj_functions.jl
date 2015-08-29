@doc "Return true if the projection is a geographic coordinate system (lon,lat)" ->
is_latlong(proj::Projection) = _is_latlong(proj.rep)

@doc "Return true if the projection is a geocentric coordinate system" ->
is_geocent(proj::Projection) = _is_geocent(proj.rep)

@doc "Return true if the projection is a geocentric coordinate system" ->
is_identical(p1::Projection, p2::Projection) = _compare_datums(p1.rep, p2.rep)

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
function transform!(src::Projection, dest::Projection, position::Array{Float64,2}; radians::Bool=false)
    !radians && is_latlong(src) && (position[:,1:2] = deg2rad(position[:,1:2]))
    _transform!(src.rep, dest.rep, position)    
    !radians && is_latlong(dest) && (position[:,1:2] = rad2deg(position[:,1:2]))
    position
end
transform(src::Projection, dest::Projection, position::Array{Float64,2}; radians::Bool=false) =
    transform!(src, dest, copy(position), radians=radians)
transform{T <: Real}(src::Projection, dest::Projection, position::Array{T,2}; radians::Bool=false) =
    transform!(src, dest, @compat(map(Float64,position)), radians=radians)

transform!(src::Projection, dest::Projection, position::Vector{Float64}; radians::Bool=false) =
    transform!(src, dest, reshape(position,(1,length(position))), radians=radians)
transform(src::Projection, dest::Projection, position::Vector{Float64}; radians::Bool=false) =
    transform!(src, dest, copy(reshape(position,(1,length(position)))), radians=radians)
transform{T <: Real}(src::Projection, dest::Projection, position::Vector{T}; radians::Bool=false) =
    transform!(src, dest, reshape(@compat(map(Float64,position)),(1,length(position))), radians=radians)

@doc """
Return the lat/long coordinate system on which a projection is based.
If the coordinate system passed in is latlong, a clone of the same will be returned.
""" ->
latlong_projection(proj::Projection) = Projection(_latlong_from_proj(proj.rep))

@doc "This function converts cartesian (xyz) geocentric coordinates into geodetic (lat/long/alt) coordinates" ->
geoc2geod!(xyz::Array{Float64,2}, proj::Projection) = _geocentric_to_geodetic!(proj.geod.a, proj.geod.e2, xyz)
geoc2geod(xyz::Array{Float64,2}, proj::Projection) = geoc2geod!(copy(xyz), proj)
geoc2geod!(xyz::Vector{Float64}, proj::Projection) = geoc2geod!(reshape(xyz,(1,length(xyz))), proj)
geoc2geod(xyz::Vector{Float64}, proj::Projection) = geoc2geod!(copy(xyz), proj)

@doc "This function converts geodetic (lat/long/alt) coordinates into cartesian (xyz) geocentric coordinates" ->
geod2geoc!(lla::Array{Float64,2}, proj::Projection) = _geodetic_to_geocentric!(proj.geod.a, proj.geod.e2, lla)
geod2geoc(lla::Array{Float64,2}, proj::Projection) = geod2geoc!(copy(lla), proj)
geod2geoc!(lla::Vector{Float64}, proj::Projection) = geod2geoc!(reshape(lla,(1,length(xyz))), proj)
geod2geoc(lla::Vector{Float64}, proj::Projection) = geod2geoc!(copy(lla), proj)

@doc "Returns the destination along the ellipsoid in the given projection" ->
destination(position::Array{Float64,2}, azi::Float64, dist::Float64, proj::Projection) = geod_direct(proj.geod, position, azi, dist)[1]
destination(position::Vector{Float64}, azi::Float64, dist::Float64, proj::Projection) = geod_direct(proj.geod, position, azi, dist)[1]

@doc "Returns the distance between the two points along the ellipsoid in the given projection" ->
ellps_distance(p1::Vector{Float64}, p2::Vector{Float64}, proj::Projection) = geod_inverse(proj.geod, p1, p2)[1]
ellps_distance(p1::Array{Float,2}, p2::Array{Float,2}, proj::Projection) = geod_inverse(proj.geod, p1, p2)[1]
