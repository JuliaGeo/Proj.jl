
# Constructors and null Constructors

# geod_geodesic

"""
    Proj._null(geod_*)

A null initializer which returns an object of the given type, 
with all floats set to NaN, and all integers set to 0.

Available types are `geod_geodesic`, `geod_geodesicline`.
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

function _null(::Type{Proj.geod_geodesicline})
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
        lats[i], lons[i], _ = geod_position_relative(inverse_line, (i-1)/npoints)
    end

    return lats, lons
end
# lines(GeoMakie.coastlines(); linewidth = 0.5, axis = (; aspect = DataAspect(), title = "Geodesic path from JFK to SIN"))
# lines!(lons, lats; linewidth = 1.5)
