immutable Cdouble6
    x1::Cdouble
    x2::Cdouble
    x3::Cdouble
    x4::Cdouble
    x5::Cdouble
    x6::Cdouble
end

immutable Cdouble15
    x1::Cdouble
    x2::Cdouble
    x3::Cdouble
    x4::Cdouble
    x5::Cdouble
    x6::Cdouble
    x7::Cdouble
    x8::Cdouble
    x9::Cdouble
    x10::Cdouble
    x11::Cdouble
    x12::Cdouble
    x13::Cdouble
    x14::Cdouble
    x15::Cdouble
end

immutable Cdouble21
    x1::Cdouble
    x2::Cdouble
    x3::Cdouble
    x4::Cdouble
    x5::Cdouble
    x6::Cdouble
    x7::Cdouble
    x8::Cdouble
    x9::Cdouble
    x10::Cdouble
    x11::Cdouble
    x12::Cdouble
    x13::Cdouble
    x14::Cdouble
    x15::Cdouble
    x16::Cdouble
    x17::Cdouble
    x18::Cdouble
    x19::Cdouble
    x20::Cdouble
    x21::Cdouble
end

type geod_geodesic
    a::Cdouble
    f::Cdouble
    f1::Cdouble
    e2::Cdouble
    ep2::Cdouble
    n::Cdouble
    b::Cdouble
    c2::Cdouble
    etol2::Cdouble

    # Arrays of parameters must be expanded manually,
    # currently (either inline, or in an immutable helper-type)
    # In the future, some of these restrictions may be reduced/eliminated.
    A3x::Cdouble6
    C3x::Cdouble15
    C4x::Cdouble21

    geod_geodesic() = new()
end

@doc """
Construct an ellipsoid of revolution with
    equatorial radius a,
    polar semi-axis b,
    flattening f,
    third flattening n,
    eccentricity-squared es

given by the formulas

    f = (a − b)/a = 1 − sqrt(1-es)
    n = (a − b)/(a + b) = f /(2 − f)
    es = (a^2 − b^2)/a^2 = f(2 − f)

Reference: equations (1)-(3) of 
    Algorithms for geodesics (arXiv:1109.4448v2 [physics.geo-ph] 28 Mar 2012)
""" ->
geod_geodesic(a::Cdouble, f::Cdouble) = geod_geodesic(geod_init(a,f))
geod_geodesic(a::Cdouble, es::Cdouble) = geod_geodesic(a, sqrt(1-es))

function geod_init(a::Cdouble, f::Cdouble)
    g = geod_geodesic()
    ccall((:geod_init, "libproj"), Void, (Ptr{Void},Cdouble,Cdouble),
          pointer_from_objref(g), a, f)
    g
end

@doc """
Solve the direct geodesic problem.

Args:

    g        - the geod_geodesic object specifying the ellipsoid.
    lat      - latitude (degrees) ∈ [-90, 90]
    lon      - longitude (degrees) ∈ [-540, 540) 
    azimuth  - azimuth (degrees) ∈ [-540, 540)
    distance - distance to move, from (lat,lon) in the direction of the given azimuth; can be negative
   
Returns:

    latlon   - destination after moving for [distance] metres in [azimuth] direction.
    azi      - forward azimuth (degrees) at destination [latlon].

Remarks:

    If either point is at a pole, the azimuth is defined by keeping the longitude fixed,
    writing lat = 90 +/- eps, and taking the limit as eps -> 0+. An arc length greater than 180deg
    signifies a geodesic which is not a shortest path.
""" ->
function geod_direct(g::geod_geodesic, lat::Cdouble, lon::Cdouble, azimuth::Cdouble, distance::Cdouble)
    latlon = Array(Cdouble,2) # the coordinates of the destination
    p = pointer(latlon)
    azi = Ref{Cdouble}() # the (forward) azimuth at the destination
    ccall((:geod_direct, "libproj"), Void, (Ptr{Void},Cdouble,Cdouble,Cdouble,
          Cdouble,Ptr{Cdouble},Ptr{Cdouble},Ptr{Cdouble}),
          pointer_from_objref(g), lat, lon, azimuth, distance, p, p+sizeof(Cdouble), azi)
    latlon, azi
end
geod_direct(g::geod_geodesic, latlon::Vector{Cdouble}, azi::Cdouble, dist::Cdouble) = geod_direct(g, latlon[1], latlon[2], azi, dist)
geod_direct(g::geod_geodesic, latlon::Array{Cdouble,2}, azi::Cdouble, dist::Cdouble) = geod_direct(g, latlon[1], latlon[2], azi, dist)


@doc """
Solve the inverse geodesic problem.

Args:

    g       - the geod_geodesic object specifying the ellipsoid.
    lat1    - latitude of point 1 (degrees) ∈ [-90, 90]
    lon1    - longitude of point 1 (degrees) ∈ [-540, 540) 
    lat2    - latitude of point 2 (degrees) ∈ [-90, 90]
    lon2    - longitude of point 2 (degrees) ∈ [-540, 540) 

Returns:

    dist    - distance between point 1 and point 2 (meters).
    azi1    - azimuth at point 1 (degrees) ∈ [-180, 180)
    azi2    - (forward) azimuth at point 2 (degrees) ∈ [-180, 180)

Remarks:

    If either point is at a pole, the azimuth is defined by keeping the longitude fixed,
    writing lat = 90 +/- eps, and taking the limit as eps -> 0+.
""" ->
function geod_inverse(g::geod_geodesic, lat1::Cdouble, lon1::Cdouble, lat2::Cdouble, lon2::Cdouble)
    dist = Ref{Cdouble}() # the distance between point 1 and point 2 (meters)
    azi1 = Ref{Cdouble}() # the azimuth at point 1 (degrees)
    azi2 = Ref{Cdouble}() # the (forward) azimuth at point 2 (degrees)
    ccall((:geod_inverse, "libproj"), Void, (Ptr{Void},Cdouble,Cdouble,Cdouble,
          Cdouble,Ptr{Cdouble},Ptr{Cdouble},Ptr{Cdouble}),
          pointer_from_objref(g), lat1, lon1, lat2, lon2, dist, azi1, azi2)
    dist[], azi1[], azi2[]
end
geod_inverse(g::geod_geodesic, p1::Vector{Cdouble}, p2::Vector{Cdouble}) = geod_inverse(g, p1[1], p1[2], p2[1], p2[2])
geod_inverse(g::geod_geodesic, p1::Array{Cdouble,2}, p2::Array{Cdouble,2}) = geod_inverse(g, p1[1], p1[2], p2[1], p2[2])
