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

Base.inv(cs::CRS2CRS) = CRS2CRS(cs.rep, inv(cs.direction))

function Base.inv(dir::PJ_DIRECTION)
    return if dir == PJ_IDENT
        PJ_IDENT
    elseif dir == PJ_FWD
        PJ_INV
    else
        PJ_FWD
    end
end

function CoordinateTransformations.transform_deriv(cs::CRS2CRS, x)
    coord = proj_coord(x...)
    factors = proj_factors(cs.rep, coord)
    return [factors.dx_dlam factors.dx_dphi; factors.dy_dlam factors.dy_dphi]
end

function (transformation::CRS2CRS)(x)
    coord = if length(x) == 2
        PJ_COORD(x[1], x[2],    0,    0)
    elseif length(x) == 3
        PJ_COORD(x[1], x[2], x[3],    0)
    elseif length(x) == 4
        PJ_COORD(x[1], x[2], x[3], x[4])
    else
        error("Input must have length 2, 3 or 4! Found $(length(x)).")
    end

    xyzt = proj_trans(transformation.rep, transformation.direction, coord).xyzt

    return if length(x) == 2
        T(xyzt.x, xyzt.y)
    elseif length(x) == 3
        T(xyzt.x, xyzt.y, xyzt.z)
    elseif length(x) == 4
        T(xyzt.x, xyzt.y, xyzt.z, xyzt.t)
    else
        error("Input must have length 2, 3 or 4! Found $(length(x)).")
    end
end

function (transformation::CRS2CRS)(coord::PJ_COORD)
    return proj_trans(transformation.rep, transformation.direction, coord)
end
