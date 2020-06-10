"""
    CRS2CRS(source, target, [direction = PJ_FWD]; area = C_NULL, normalize = true)

Constructs a coordinate system transformation from `source` to `target`.  The source and target CRS may be Strings or [`Projection`](@ref)s.

CRS2CRS objects are callable, and transformations are performed by
calling them on point-like types.  They also satisfy the
[CoordinateTransformations.jl](https://github.com/JuliaGeometry/CoordinateTransformations.jl) interface.  As such, they can be
inverted through `Base.inv`.

```julia
# Construct a projection from lon-lat coordinates
# to the Winkel Tripel projection
cs = CRS2CRS("+proj=lonlat", "+proj=wintri")
# construct a projectable coordinate
a = proj_coord(0, 0)
b = cs(a) # projected coordinate
```
## Extended help

You can get more information on this by calling `Proj4.proj_pj_info(cs.rep)` for a `CRS2CRS` object `cs`.  This will return a `PJ_FACTORS` struct, which you can inspect using `unsafe_string` on its fields.  You can also get a WKT representation
by calling `Proj4.proj_as_wkt(cs)`

"""
mutable struct CRS2CRS <: CoordinateTransformations.Transformation
    rep::Ptr{Cvoid}
    direction::PJ_DIRECTION
end

function CRS2CRS(source::String, target::String, direction::PJ_DIRECTION = PJ_FWD; area = C_NULL, normalize = true)

    pj_init = proj_create_crs_to_crs(source, target, area)

    obj = if normalize
        pj_normalized = proj_normalize_for_visualization(pj_init)
        proj_destroy(pj_init)
        CRS2CRS(pj_normalized, direction)
    else
        CRS2CRS(pj_init, direction)
    end

    finalizer(obj) do obj
        proj_destroy(obj.rep)
    end

    return obj
end

function CRS2CRS(source::Projection, target::Projection, direction::PJ_DIRECTION = PJ_FWD; area = C_NULL, normalize = true)
    return CRS2CRS(
        sprint(print, source),
        sprint(print, target),
        direction;
        area = area,
        normalize = true
    )
end

function Base.inv(dir::PJ_DIRECTION)
    return if dir == PJ_IDENT
        PJ_IDENT
    elseif dir == PJ_FWD
        PJ_INV
    else
        PJ_FWD
    end
end
Base.inv(cs::CRS2CRS) = CRS2CRS(cs.rep, inv(cs.direction))

function (transformation::CRS2CRS)(x)
    # if `x` is too long, this will throw
    # a methoderror (there are 0, 1, 2, 3, and 4-arg)
    # versions of the PJ_COORD constructor.
    coord = PJ_COORD(x...)

    xyzt = (proj_trans(transformation.rep, transformation.direction, coord).xyzt)::PJ_XYZT

    return if length(x) == 2
        T(xyzt.x, xyzt.y)
    elseif length(x) == 3
        T(xyzt.x, xyzt.y, xyzt.z)
    elseif length(x) == 4
        T(xyzt.x, xyzt.y, xyzt.z, xyzt.t)
    end
end

function (transformation::CRS2CRS)(coord::PJ_COORD)::PJ_COORD
    return proj_trans(transformation.rep, transformation.direction, coord)
end


# These are specializations for vectors and tuples, which
# cannot be constructed directly as `f(x...)`.
function (transformation::CRS2CRS)(vec::Vector{T}) where T <: Real
    l = length(vec)
    @assert l ≤ 4 "The length of the input vector must be ≤ 4!  Found $l"
    @assert l ≥ 1 "The length of the input vector must be ≥ 1!  Found $l"

    coord = PJ_COORD(vec...)::PJ_COORD
    xyzt = (transformation(coord).xyzt)::PJ_XYZT

    if l == 1
        return Float64[xyzt.x]
    elseif l == 2
        return Float64[xyzt.x, xyzt.y]
    elseif l == 3
        return Float64[xyzt.x, xyzt.y, xyzt.z]
    elseif l == 4
        return Float64[xyzt.x, xyzt.y, xyzt.z, xyzt.t]
    end
end

function (transformation::CRS2CRS)(vec::NTuple{N, T}) where N where T <: Real
    @assert N ≤ 4 "The length of the input tuple must be ≤ 4!  Found $l"
    @assert N ≥ 1 "The length of the input tuple must be ≥ 1!  Found $l"

    coord = PJ_COORD(vec...)::PJ_COORD
    xyzt = (transformation(coord).xyzt)::PJ_XYZT

    if N == 1
        return (xyzt.x,)
    elseif N == 2
        return (xyzt.x, xyzt.y)
    elseif N == 3
        return (xyzt.x, xyzt.y, xyzt.z)
    elseif N == 4
        return (xyzt.x, xyzt.y, xyzt.z, xyzt.t)
    end
end

# Dispatches for informational functions
# (these mostly just forward `cs -> cs.rep`)

proj_as_wkt(cs::CRS2CRS, type::PJ_WKT_TYPE, ctx = C_NULL, options = C_NULL) = proj_as_wkt(cs.rep, type, ctx, options)
proj_factors(cs::CRS2CRS, coord::PJ_COORD) = proj_factors(cs.rep, coord)
