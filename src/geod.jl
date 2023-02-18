
# Constructors and null Constructors

# geod_geodesic

function _null(::Type{geod_geodesic})
    return geod_geodesic(
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        ntuple(_ -> 0.0, Val(6)),
        ntuple(_ -> 0.0, Val(15)),
        ntuple(_ -> 0.0, Val(21)),
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
        (0 for _ in 1:30)...,
        ntuple(_ -> 0.0, 7), ntuple(_ -> 0.0, 7), ntuple(_ -> 0.0, 7), ntuple(_ -> 0.0, 6), ntuple(_ -> 0.0, 6),
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

    return geod_position(pointer_from_objref(line), s12, lat, lon, azi)

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