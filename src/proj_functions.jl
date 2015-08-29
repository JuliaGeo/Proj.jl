@doc "Return true if the projection is a geographic coordinate system (lon,lat)" ->
is_latlong(proj::Projection) = _is_latlong(proj.rep)

@doc "Return true if the projection is a geocentric coordinate system" ->
is_geocent(proj::Projection) = _is_geocent(proj.rep)

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
