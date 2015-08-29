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

# e.g. a = 6378137, c = 1/298.257223563
function geod_init(a::Cdouble, f::Cdouble)
    g = geod_geodesic()
    ccall((:geod_init, "libproj"), Void, (Ptr{Void},Cdouble,Cdouble),
          pointer_from_objref(g), a, f)
    g
end

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

function geod_distance(g::geod_geodesic, lat1::Cdouble, lon1::Cdouble, lat2::Cdouble, lon2::Cdouble)
    dist = Ref{Cdouble}() # the distance between point 1 and point 2 (meters)
    ccall((:geod_inverse, "libproj"), Void, (Ptr{Void},Cdouble,Cdouble,Cdouble,
          Cdouble,Ptr{Cdouble},Ptr{Cdouble},Ptr{Cdouble}),
          pointer_from_objref(g), lat1, lon1, lat2, lon2, dist, C_NULL, C_NULL)
    dist[]
end
geod_distance(g::geod_geodesic, p1::Vector{Cdouble}, p2::Vector{Cdouble}) = geod_inverse(g, p1[1], p1[2], p2[1], p2[2])
geod_distance(g::geod_geodesic, p1::Array{Cdouble,2}, p2::Array{Cdouble,2}) = geod_inverse(g, p1[1], p1[2], p2[1], p2[2])