
# Constructors and null Constructors

# geod_geodesic

"""
    Proj._null(geod_*)

A null initializer which returns an object of the given type, 
with all floats set to NaN, and all integers set to 0.

Available types are `geod_geodesic`, `geod_geodesicline, `geod_polygon`.
"""
function _null(::Type{geod_geodesic})
    return geod_geodesic(
        NaN64, NaN64, NaN64, NaN64, NaN64, NaN64, NaN64, NaN64, NaN64,
        ntuple(_ -> NaN64, Val(6)),
        ntuple(_ -> NaN64, Val(15)),
        ntuple(_ -> NaN64, Val(21)),
    )
end

function geod_geodesic(equatorial_radius::Real, flattening::Real)
    obj = _null(geod_geodesic)
    geod_init(Ref(obj), Cdouble(equatorial_radius), Cdouble(flattening))
    return obj
end

# geod_geodesicline

function _null(::Type{geod_geodesicline})
    return geod_geodesicline(
        (NaN64 for _ in 1:30)...,
        ntuple(_ -> NaN64, 7), ntuple(_ -> NaN64, 7), ntuple(_ -> NaN64, 7), ntuple(_ -> NaN64, 6), ntuple(_ -> NaN64, 6),
        Cuint(0)
    )
end

function geod_directline(g::geod_geodesic, lat1, lon1, azi1, s12, caps::Cuint = UInt32(0))
    obj = _null(geod_geodesicline)
    geod_directline(
        pointer_from_objref(obj),
        pointer_from_objref(g), 
        lat1, lon1, azi1, s12, caps
    )
    return obj
end

function geod_inverseline(g::geod_geodesic, lat1, lon1, lat2, lon2, caps::Cuint = UInt32(0))
    obj = _null(geod_geodesicline)
    geod_inverseline(
        pointer_from_objref(obj),
        pointer_from_objref(g), 
        lat1, lon1, lat2, lon2, caps
    )
    return obj
end

# returns according to the C order (y, x, az).  Do we want this to return by the Julian order (x, y, azi)?  
# If so, should this be a new function?
function geod_position(line::geod_geodesicline, s12::Real)
    lat = Ref{Cdouble}(NaN64)
    lon = Ref{Cdouble}(NaN64)
    azi = Ref{Cdouble}(NaN64)

    geod_position(pointer_from_objref(line), s12, lat, lon, azi)

    return lat[], lon[], azi[]
end

"""
    geod_position_relative(line::geod_geodesicline, relative_arclength::Real)

Returns `(lat, lon, azimuth)` at the `relative_arclength` between the line's start and end point.  
`relative_arclength` can be any real value, but values along the line should be between 0 and 1.
"""
function geod_position_relative(line::geod_geodesicline, relative_arclength::Real)
    return geod_position(line, line.s13 * relative_arclength)
end

function geod_setdistance(l::geod_geodesicline, s13::Real)
    geod_setdistance(pointer_from_objref(l), Cdouble(l13))
end

function geod_genposition(l::geod_geodesicline, flags::Union{Cuint, geod_flags}, s12_a12)
    plat2 = Ref{Cdouble}(NaN64)
    plon2 = Ref{Cdouble}(NaN64)
    pazi2 = Ref{Cdouble}(NaN64)
    ps12 = Ref{Cdouble}(NaN64)
    pm12 = Ref{Cdouble}(NaN64)
    pM12 = Ref{Cdouble}(NaN64)
    pM21 = Ref{Cdouble}(NaN64)
    pS12 = Ref{Cdouble}(NaN64)

    geod_genposition(pointer_from_objref(l), flags, s12_a12, plat2, plon2, pazi2, ps12, pm12, pM12, pM21, pS12)

    return (plat2[], plon2[], pazi2[], ps12[], pm12[], pM12[], pM21[], pS12[])

end


"""
    geod_path(geodesic::geod_geodesic, lat1, lon1, lat2, lon2, npoints = 1000)

Returns a tuple of vectors representing longitude and latitude.

## Example

```julia
geod = Proj.geod_geodesic(6378137, 1/298.257223563)
lats, lons = Proj.geod_path(geod, 40.64, -73.78, 1.36, 103.99)
```
"""
function geod_path(geodesic::geod_geodesic, lat1, lon1, lat2, lon2, npoints = 1000; caps = Cuint(0))
    inverse_line = geod_inverseline(geodesic, lat1, lon1, lat2, lon2, caps)

    lats = zeros(Float64, npoints)
    lons = zeros(Float64, npoints)

    for i in 1:npoints
        lats[i], lons[i], _ = geod_position_relative(inverse_line, (i-1)/(npoints-1))
    end

    return lats, lons
end
# lines(GeoMakie.coastlines(); linewidth = 0.5, axis = (; aspect = DataAspect(), title = "Geodesic path from JFK to SIN"))
# lines!(lons, lats; linewidth = 1.5)


# Polygon interface


# geod_polygon

function _null(::Type{geod_polygon})
    return geod_polygon(
        NaN64, NaN64, NaN64, NaN64,
        (NaN64, NaN64), (NaN64, NaN64),
        Cint(0), Cint(0), Cint(0)
    )
end

function geod_polygon_init(p::geod_polygon, polylinep::Int = 1)
    polylinep_Cint = Cint(polylinep)
    @assert polylinep_Cint == polylinep "Your integer is too large and there will be an under/overflow error.  Please pass an Cint."
    geod_polygon_init(pointer_from_objref(p, polylinep_Cint))
    return p
end

geod_polygon_clear(p::geod_polygon) = geod_polygon_clear(pointer_from_objref(p))

function geod_polygon_addpoint(g::geod_geodesic, p::geod_polygon, lat::Real, lon::Real)
    geod_polygon_addpoint(pointer_from_objref(g), pointer_from_objref(p), Cdouble(lat), Cdouble(lon))
    return p
end

function geod_polygon_addedge(g::geod_geodesic, p::geod_polygon, azi::Real, s::Real)
    geod_polygon_addedge(pointer_from_objref(g), pointer_from_objref(p), Cdouble(azi), Cdouble(s))
    return p
end

"""
    geod_polygon_compute(g::geod_geodesic, p::geod_polygon, reverse::Bool = false, sign::Bool = true)

Returns a tuple of `(area, perimeter)` in m² and m respectively.  Area is only returned if `polyline` is nonzero in the call to `geod_polygon_init`.
"""
function geod_polygon_compute(g::geod_geodesic, p::geod_polygon, reverse::Bool = false, sign::Bool = true)
    # initializing to zero makes the return not happen for that value, so we need to initialize to 1
    pA = Ref{Cdouble}(1e0)
    pP = Ref{Cdouble}(1e0)
    
    n = geod_polygon_compute(pointer_from_objref(g), pointer_from_objref(p), Cint(reverse), Cint(sign), pA, pP)

    return (pA[], pP[])
end

"""
    geod_polygonarea(g::geod_geodesic, lats::AbstractVector{<: Real}, lons::AbstractVector{<: Real})

    Simple interface to compute the geodesic area of a polygon.  
Returns a tuple of `(area, perimeter)` in m² and m respectively.
"""
function geod_polygonarea(g::geod_geodesic, lats::AbstractVector{<: Real}, lons::AbstractVector{<: Real})
    @assert length(lats) == length(lons)
    c_lats = convert(Vector{Cdouble}, lats)
    c_lons = convert(Vector{Cdouble}, lons)

    pA = Ref{Cdouble}(1e0)
    pP = Ref{Cdouble}(1e0)
    
    geod_polygonarea(pointer_from_objref(g), c_lats, c_lons, length(lats), pA, pP)

    return (pA[], pP[])

end

# TODO: add geod_polygon_addpoint and geod_polygon_addedge