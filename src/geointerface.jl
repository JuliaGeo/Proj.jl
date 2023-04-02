using GeoInterface

const GI = GeoInterface

# Coord is a PointTrait
GI.isgeometry(::Type{Coord}) = true
GI.geomtrait(::Coord) = GI.PointTrait()
GI.x(::PointTrait, c::Coord) = c.x # TODO: these may have the wrong order for some CRS. 
GI.y(::PointTrait, c::Coord) = c.y 
GI.z(::PointTrait, c::Coord{3}) = c.z
GI.is3d(::PointTrait, c::Coord{2}) = false
GI.is3d(::PointTrait, c::Coord{3}) = true
GI.ismeasured(::PointTrait, c::Coord) = false
function GI.getcoord(::PointTrait, c::Coord{N}, i::Int) where N
    checkbounds(1:N, i)
    @inbounds c[i]
end
GI.getcoord(::PointTrait, c::Coord{2}) = (c.x, c.y)
GI.getcoord(::PointTrait, c::Coord{3}) = (c.x, c.y, c.z)
coordnames(::PointTrait, ::Coord{2}) = (:X, :Y)
coordnames(::PointTrait, ::Coord{3}) = (:X, :Y, :Z)

"""
    reproject(geometry, source_crs, target_crs)
    reproject(geometry; [source_crs,] target_crs)

Reproject any GeoInterface.jl compatible `geometry` from `source_crs` to `target_crs`.

The returned object will be constructed from `GeoInterface.WrapperGeometry`
geometries, wrapping views of `Proj.Coord`.
"""
function reproject(geom; source_crs=nothing, target_crs, kw...)
    source_crs = isnothing(source_crs) ? GeoInterface.crs(geom) : source_crs
    isnothing(source_crs) && throw(ArgumentError("geom has no crs attatched. Pass a `source_crs` keyword"))
    reproject(geom, source_crs, target_crs; kw...)
end
function reproject(geom, source_crs, target_crs; time=Inf, always_xy=true)
    wrapped_geom, coords = if GI.is3d(geom)
        reconstruct(geom; crs=target_crs) do p
            Proj.Coord{3}(GI.x(p), GI.y(p), GI.z(p); time)
        end
    else
        reconstruct(geom; crs=target_crs) do p
            Proj.Coord{2}(GI.x(p), GI.y(p); time)
        end
    end
    source_crs1 = convert(Proj.CRS, source_crs)
    target_crs1 = convert(Proj.CRS, target_crs)
    trans = Proj.Transformation(source_crs1, target_crs1; always_xy)
    err = Proj.proj_trans_array(trans.pj, Proj.PJ_FWD, length(coords), coords)
    err == 0 || error("Proj error $err")
    # crs = target_crs isa GFT.GeoFormat ? target_crs : convert(WellKnownText, crs)
    return wrapped_geom
end


"""
    reconstruct(f::Function, geom)
    reconstruct(geometry, points::AbstractVector)

Reconstruct GeoInterface compatible `geometry` from the `PointTrait` geometries
in `points`, or from the result of function `f` over the points in `geom`.

The returned object will be constructed from `GeoInterface.WrapperGeometry`
geometries, wrapping views into the `points` vector. Otherwise, the structure and
GeoInterface traits will be the same as for `geometry`.

This is a lazy operation, only allocating for outer wrappers of nested geometries.
Later changes to the `points` vector *will* affect the returned geometry.

`GeoInterface.npoint(geometry) == length(points)` must be `true`.
"""
function reconstruct(f, geom; crs=nothing)
    p1 = f(first(GI.getpoint(geom)))
    T = typeof(p1)
    isgeometry(T) || throw(ArgumentError("points of type $(T) are not GeoInterface.jl compatible objects"))
    trait = GI.trait(p1)
    trait isa PointTrait || throw(ArgumentError("can only reconstruct from an array of points, got $trait"))
    points = Vector{T}(undef, GI.npoint(geom))
    n, geom = _reconstruct!(f, points, geom, 0, crs)
    @assert n == GI.npoint(geom)
    return geom, points
end

_reconstruct!(f, points, geom, n::Int, crs) = _reconstruct!(f, points, GI.trait(geom), geom, n::Int, crs)
# Nested geometries. We need to reconstruct their child geoms.
function _reconstruct!(f, points, trait::AbstractGeometryTrait, geom, n, crs)
    T = GI.geointerface_geomtype(trait)
    geoms = map(GI.getgeom(geom)) do childgeom
        childcrs = nothing # We dont pass the CRS down, the type gets too complicated
        n, reconstructed_childgeom = _reconstruct!(f, points, GI.trait(childgeom), childgeom, n, crs)
        reconstructed_childgeom
    end
    return n, T(geoms; crs)
end
# Bottom-level geometries that can wrap a vector of points.
function _reconstruct!(f, points, 
    trait::Union{GI.LineTrait,GI.LineStringTrait,GI.LinearRingTrait,GI.MultiPointTrait}, 
    geom, n, crs
)
    T = GI.geointerface_geomtype(trait)
    npoints = GI.npoint(geom)
    v = view(points, n + 1:n + npoints)
    v .= f.(GI.getpoint(geom))
    wrapped_geom = if GI.is3d(geom)
        GI.ismeasured(geom) ? T{true,true}(v; crs) : T{true,false}(v; crs)
    else
        GI.ismeasured(geom) ? T{false,true}(v; crs) : T{false,false}(v; crs)
    end
    return n + npoints, wrapped_geom
end
# Points
function _reconstruct!(f, points, ::GI.PointTrait, geom, n, crs)
    n += 1
    points[n] = f(point)
    wrapped_point = if GI.is3d(geom)
        GI.ismeasured(geom) ? GI.Point{true,true}(points[n]) : GI.Point{true,false}(points[n])
    else
        GI.ismeasured(geom) ? GI.Point{false,true}(points[n]) : GI.Point{false,false}(points[n])
    end
    return n, wrapped_point
end
