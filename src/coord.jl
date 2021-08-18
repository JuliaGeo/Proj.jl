const Coord = SVector{4, Float64}
const Coord234 = Union{SVector{2, Float64}, SVector{3, Float64}, SVector{4, Float64}}

"""
    Transformation(source_crs, target_crs; area=C_NULL, ctx=C_NULL, always_xy=false)

Create a Transformation that is a pipeline between two known coordinate reference systems.
Transformation implements the
[CoordinateTransformations.jl](https://github.com/JuliaGeometry/CoordinateTransformations.jl)
API.

`source_crs` and `target_crs` can be:
- a "AUTHORITY:CODE", like EPSG:25832. When using that syntax for a source CRS, the created
  pipeline will expect that the coordinates respect the axis order and axis unit of the
  official definition (so for example, for EPSG:4326, with latitude first and longitude
  next, in degrees). Similarly, when using that syntax for a target CRS, output values will
  be emitted according to the official definition of this CRS. This behavior can be
  overruled by passing `always_xy=true`.
- a PROJ string, like "+proj=longlat +datum=WGS84". When using that syntax, the axis order
  and unit for geographic CRS will be longitude, latitude, and the unit degrees.
- the name of a CRS as found in the PROJ database, e.g "WGS84", "NAD27", etc.
- more generally any string accepted by `proj_create` representing a CRS
- besides an `AbstractString`, it can also accept a `Ptr{PJ}`, pointing to a CRS that was
  already created with `proj_create`

`area` sets the "area of use" for the Transformation. When it is supplied, the more accurate
transformation between two given systems can be chosen. When no area of use is specific and
several coordinate operations are possible depending on the area of use, this function will
internally store those candidate coordinate operations in the return PJ object. Each
subsequent coordinate transformation will then select the appropriate coordinate operation
by comparing the input coordinates with the area of use of the candidate coordinate
operations. The `area` pointer needs to be created using `proj_area_create`, filled using
`proj_area_set_bbox`, and destroyed using `proj_area_destroy`.

`ctx` determines the threading context. By default it is set to the global context. For
thread safety, use separate contexts created with `proj_context_create` or
`proj_context_clone`, and destroyed with `proj_context_destroy`.

`always_xy` can optionally fix the axis orderding to x,y or lon,lat order. By default it is
`false`, meaning the order is defined by the authority in charge of a given coordinate
reference system, as explained in [this PROJ FAQ
entry](https://proj.org/faq.html#why-is-the-axis-ordering-in-proj-not-consistent).

# Examples
```julia
julia> trans = Proj4.Transformation("EPSG:4326", "EPSG:28992", always_xy=true)
Transformation
    source: WGS 84 (with axis order normalized for visualization)
    target: Amersfoort / RD New

julia> trans((5.39, 52.16))  # this is in lon,lat order, since we set always_xy to true
2-element StaticArrays.SVector{2, Float64} with indices SOneTo(2):
 155191.3538124342
 463537.1362732911
```
"""
mutable struct Transformation <: CoordinateTransformations.Transformation
    pj::Ptr{PJ}
    function Transformation(pj::Ptr{PJ})
        trans = new(pj)
        finalizer(trans) do trans
            trans.pj = proj_destroy(trans.pj)
        end
        return trans
    end
end

function Transformation(
    source_crs::AbstractString,
    target_crs::AbstractString;
    area::Ptr{PJ_AREA} = C_NULL,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
    always_xy::Bool = false,
)
    pj = proj_create_crs_to_crs(source_crs, target_crs, area, ctx)
    pj = always_xy ? normalize_axis_order!(pj; ctx=ctx) : pj
    return Transformation(pj)
end

function Transformation(
    source_crs::Ptr{PJ},
    target_crs::Ptr{PJ};
    area::Ptr{PJ_AREA} = C_NULL,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
    always_xy::Bool = false,
)
    pj = proj_create_crs_to_crs_from_pj(source_crs, target_crs, area, ctx)
    pj = always_xy ? normalize_axis_order!(pj; ctx=ctx) : pj
    return Transformation(pj)
end

function Base.show(io::IO, trans::Transformation)
    source_crs = proj_get_source_crs(trans.pj)
    target_crs = proj_get_target_crs(trans.pj)
    source_info = proj_pj_info(source_crs)
    target_info = proj_pj_info(target_crs)
    source_description = unsafe_string(source_info.description)
    target_description = unsafe_string(target_info.description)
    print(io, """
    Transformation
        source: $source_description
        target: $target_description""")
end

"""
    normalize_axis_order!(pj::Ptr{PJ}; ctx = C_NULL)

Call proj_normalize_for_visualization on an object, and return the new object after freeing
the input object.
"""
function normalize_axis_order!(pj::Ptr{PJ}; ctx = C_NULL)
    pj_for_gis = proj_normalize_for_visualization(pj, ctx)
    proj_destroy(pj)
    return pj_for_gis
end

function Base.inv(
    trans::Transformation;
    area::Ptr{PJ_AREA} = C_NULL,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
    always_xy::Bool = false,
)
    target_crs = proj_get_source_crs(trans.pj)
    source_crs = proj_get_target_crs(trans.pj)
    return Transformation(source_crs, target_crs; area=area, ctx=ctx, always_xy=always_xy)
end

function (trans::Transformation)(coord::StaticVector{2,<:AbstractFloat})
    T = similar_type(coord)
    coord = SVector{4, Float64}(coord[1], coord[2], 0.0, Inf)
    p = proj_trans(trans.pj, PJ_FWD, coord)
    return T(p[1], p[2])
end

function (trans::Transformation)(coord::StaticVector{3,<:AbstractFloat})
    T = similar_type(coord)
    coord = SVector{4, Float64}(coord[1], coord[2], coord[3], Inf)
    p = proj_trans(trans.pj, PJ_FWD, coord)
    return T(p[1], p[2], p[3])
end

function (trans::Transformation)(coord::StaticVector{4,<:AbstractFloat})
    T = similar_type(coord)
    coord = SVector{4, Float64}(coord[1], coord[2], coord[3], coord[4])
    p = proj_trans(trans.pj, PJ_FWD, coord)
    return T(p)
end

function (trans::Transformation)(coord)::Coord234
    # avoid splatting for performance
    n = length(coord)
    coord = if n == 2
        proj_coord(coord[1], coord[2])
    elseif n == 3
        proj_coord(coord[1], coord[2], coord[3])
    elseif n == 4
        proj_coord(coord[1], coord[2], coord[3], coord[4])
    else
        throw(ArgumentError("input should be length 2, 3 or 4"))
    end

    p = proj_trans(trans.pj, PJ_FWD, coord)

    if n == 2
        return SVector{2, Float64}(p[1], p[2])
    elseif n == 3
        return SVector{3, Float64}(p[1], p[2], p[3])
    else
        return p
    end
end

function CoordinateTransformations.compose(
    trans1::Transformation,
    trans2::Transformation;
    area::Ptr{PJ_AREA} = C_NULL,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
    always_xy::Bool = false,
)
    # create a new Transformation from trans1 source to trans2 target
    # can also be typed as trans1 ∘ trans2, typed with \circ
    # a → b ∘ c → d doesn't make much sense if b != c, though we don't enforce it
    source_crs = proj_get_source_crs(trans1.pj)
    target_crs = proj_get_target_crs(trans2.pj)
    return Transformation(source_crs, target_crs; area=area, ctx=ctx, always_xy=always_xy)
end

"""
    enable_network!(active::Bool = true, ctx::Ptr{PJ_CONTEXT} = C_NULL)::Bool

Enable PROJ network access, if `active` is true, disable it if it is false. Optionally pass
a context to set it for that context, instead of the global one.

Returns true if network access is possible.
"""
function enable_network!(active::Bool = true, ctx::Ptr{PJ_CONTEXT} = C_NULL)
    enabled = proj_context_set_enable_network(Cint(active), ctx)
    return Bool(enabled)
end

"""
    network_enabled(ctx::Ptr{PJ_CONTEXT} = C_NULL)::Bool

Returns true if PROJ network access is enabled, false otherwise. Optionally pass a context
to check for that context, instead of the global one.
"""
function network_enabled(ctx::Ptr{PJ_CONTEXT} = C_NULL)
    enabled = proj_context_is_network_enabled(ctx)
    return Bool(enabled)
end
