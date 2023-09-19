"""
    Transformation(source_crs, target_crs; always_xy=false, direction = PJ_FWD, area=C_NULL, ctx=C_NULL)
    Transformation(pipeline; always_xy=false, direction = PJ_FWD, area=C_NULL, ctx=C_NULL)

Create a Transformation that is a pipeline between two known coordinate reference systems.
Transformation implements the
[CoordinateTransformations.jl](https://github.com/JuliaGeometry/CoordinateTransformations.jl)
API.

To do the transformation on coordinates, call an instance of this struct like a function.
See below for an example. These functions accept either 2 to 4 numbers, or 1 collection of 2
to 4 numbers, with the first two required numbers representing x and y coordinates. Number 3
is the elevation (defaults to 0), and number 4 is the time in years (defaults to Inf).

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

`pipeline` can be a PROJ pipeline string, like "+proj=pipeline +step +proj=unitconvert ...".

`always_xy` can optionally fix the axis orderding to x,y or lon,lat order. By default it is
`false`, meaning the order is defined by the authority in charge of a given coordinate
reference system, as explained in [this PROJ FAQ
entry](https://proj.org/faq.html#why-is-the-axis-ordering-in-proj-not-consistent).

`direction` can be one of (`PJ_FWD`, `PJ_IDENT`, `PJ_INV`), which correspond to forward
(source to target), identity (do nothing) and inverse (target to source) transformations.

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

# Examples
```julia
julia> trans = Proj.Transformation("EPSG:4326", "EPSG:28992", always_xy=true)
Transformation
    source: WGS 84 (with axis order normalized for visualization)
    target: Amersfoort / RD New

julia> trans(5.39, 52.16)  # this is in lon,lat order, since we set always_xy to true
(155191.3538124342, 463537.1362732911)
```
"""
mutable struct Transformation <: CoordinateTransformations.Transformation
    pj::Ptr{PJ}
    direction::PJ_DIRECTION
    function Transformation(pj::Ptr{PJ}, direction::PJ_DIRECTION = PJ_FWD)
        trans = new(pj, direction)
        finalizer(trans) do trans
            trans.pj = proj_destroy(trans.pj)
        end
        return trans
    end
end

function Transformation(
    source_crs::AbstractString,
    target_crs::AbstractString;
    always_xy::Bool = false,
    direction::PJ_DIRECTION = PJ_FWD,
    area::Ptr{PJ_AREA} = C_NULL,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
)
    pj = proj_create_crs_to_crs(source_crs, target_crs, area, ctx)
    pj = always_xy ? normalize_axis_order!(pj; ctx) : pj
    return Transformation(pj, direction)
end

function Transformation(
    source_crs::GFT.CoordinateReferenceSystemFormat,
    target_crs::GFT.CoordinateReferenceSystemFormat;
    always_xy::Bool = false,
    direction::PJ_DIRECTION = PJ_FWD,
    area::Ptr{PJ_AREA} = C_NULL,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
)
    return Transformation(
        CRS(source_crs).pj,
        CRS(target_crs).pj;
        always_xy,
        direction,
        area,
        ctx,
    )
end

function Transformation(
    pipeline::AbstractString;
    always_xy::Bool = false,
    direction::PJ_DIRECTION = PJ_FWD,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
)
    pj = proj_create(pipeline, ctx)
    if Bool(proj_is_crs(pj))
        throw(ArgumentError("""Cannot create a Transformation from a single CRS.
        Pass either one pipeline or a source and target CRS.
        CRS given: $(repr(pipeline))"""))
    end
    pj = always_xy ? normalize_axis_order!(pj; ctx) : pj
    return Transformation(pj, direction)
end

function Transformation(
    source_crs::Ptr{PJ},
    target_crs::Ptr{PJ};
    always_xy::Bool = false,
    direction::PJ_DIRECTION = PJ_FWD,
    area::Ptr{PJ_AREA} = C_NULL,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
)
    pj = proj_create_crs_to_crs_from_pj(source_crs, target_crs, area, ctx)
    pj = always_xy ? normalize_axis_order!(pj; ctx) : pj
    return Transformation(pj, direction)
end

function Transformation(
    source_crs::CRS,
    target_crs::CRS;
    always_xy::Bool = false,
    direction::PJ_DIRECTION = PJ_FWD,
    area::Ptr{PJ_AREA} = C_NULL,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
)
    return Transformation(source_crs.pj, target_crs.pj; always_xy, direction, area, ctx)
end

function Base.show(io::IO, trans::Transformation)


    dir = trans.direction
    direction_str = dir == PJ_FWD ? "forward" : dir == PJ_IDENT ? "identity" : "inverse"

    info = proj_pj_info(trans.pj)
    type = unsafe_string(info.id)
    if type == "unknown"
        source_crs = proj_get_source_crs(trans.pj)
        target_crs = proj_get_target_crs(trans.pj)
        source_info = proj_pj_info(source_crs)
        target_info = proj_pj_info(target_crs)
        source_description = unsafe_string(source_info.description)
        target_description = unsafe_string(target_info.description)

        print(
            io,
            """Transformation $type
                source: $source_description
                target: $target_description
                direction: $direction_str
            """,
        )
    else
        description = unsafe_string(info.description)
        definition = unsafe_string(info.definition)
        print(
            io,
            """Transformation $type
                description: $description
                definition: $definition
                direction: $direction_str
            """,
        )
    end
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
    always_xy::Bool = false,
    area::Ptr{PJ_AREA} = C_NULL,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
)
    source_crs = proj_get_source_crs(trans.pj)
    target_crs = proj_get_target_crs(trans.pj)

    return Transformation(
        source_crs,
        target_crs;
        direction = inv(trans.direction),
        area,
        ctx,
        always_xy,
    )
end

function (trans::Transformation)(x, y)::NTuple{2,Float64}
    p = proj_trans(trans.pj, trans.direction, (x, y))
    return p.x, p.y
end

function (trans::Transformation)(x, y, z)::NTuple{3,Float64}
    p = proj_trans(trans.pj, trans.direction, (x, y, z))
    return p.x, p.y, p.z
end

function (trans::Transformation)(x, y, z, t)::NTuple{4,Float64}
    p = proj_trans(trans.pj, trans.direction, (x, y, z, t))
    return p.x, p.y, p.z, p.t
end

function (trans::Transformation)(coord::Coord)::NTuple{4,Float64}
    p = proj_trans(trans.pj, trans.direction, coord)
    return p.x, p.y, p.z, p.t
end

function (trans::Transformation)(coord::NTuple234)::NTuple234
    n = length(coord)
    p = proj_trans(trans.pj, trans.direction, coord)
    return if n == 2
        p.x, p.y
    elseif n == 3
        p.x, p.y, p.z
    else
        p.x, p.y, p.z, p.t
    end
end

function (trans::Transformation)(coord)
    (GI.isgeometry(coord) && GI.geomtrait(coord)) == GI.PointTrait() ||
        throw(ArgumentError("Argument is not a Point geometry"))
    c = GI.convert(Coord, GI.PointTrait(), coord)
    p = proj_trans(trans.pj, trans.direction, c)
    n = GI.ncoord(coord)
    if n == 2
        return p.x, p.y
    elseif n == 3
        return p.x, p.y, p.z
    else
        return p.x, p.y, p.z, p.t
    end
end

"""
    Proj.bounds(trans::Transformation, (xmin, xmax), (ymin,ymax); densify_pts=21) -> ((bxmin, bxmax), (bymin, bymax))

Transform boundary densifying the edges to account for nonlinear transformations along
these edges and extracting the outermost bounds. Returns a tuple of tuples of the bounding
rectangle.

See [`proj_trans_bounds`](https://proj.org/development/reference/functions.html#c.proj_trans_bounds)
"""
function bounds(
    trans::Transformation,
    (xmin, xmax),
    (ymin, ymax);
    densify_pts = 21,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
)
    out_xmin = Ref{Float64}(NaN)
    out_xmax = Ref{Float64}(NaN)
    out_ymin = Ref{Float64}(NaN)
    out_ymax = Ref{Float64}(NaN)
    proj_trans_bounds(
        ctx,
        trans.pj,
        trans.direction,
        xmin,
        ymin,
        xmax,
        ymax,
        out_xmin,
        out_ymin,
        out_xmax,
        out_ymax,
        densify_pts,
    )
    return (out_xmin[], out_xmax[]), (out_ymin[], out_ymax[])
end

function CoordinateTransformations.compose(
    trans1::Transformation,
    trans2::Transformation;
    always_xy::Bool = false,
    area::Ptr{PJ_AREA} = C_NULL,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
)
    # create a new Transformation from trans1 source to trans2 target
    # can also be typed as trans1 ∘ trans2, typed with \circ
    # a → b ∘ c → d doesn't make much sense if b != c, though we don't enforce it

    source_crs =
        trans1.direction == PJ_FWD ? proj_get_source_crs(trans1.pj) :
        proj_get_target_crs(trans1.pj)
    target_crs =
        trans2.direction == PJ_FWD ? proj_get_target_crs(trans2.pj) :
        proj_get_source_crs(trans2.pj)
    return Transformation(source_crs, target_crs; area, ctx, always_xy)
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

function with_network(f::Function; active::Bool = true, ctx::Ptr{Proj.PJ_CONTEXT} = C_NULL)
    as_before = Proj.network_enabled(ctx)
    Proj.enable_network!(active, ctx)
    try
        f()
    finally
        Proj.enable_network!(as_before, ctx)
    end
end

function Base.inv(direction::PJ_DIRECTION)
    return if direction == PJ_FWD
        PJ_INV
    elseif direction == PJ_IDENT
        PJ_IDENT
    else
        PJ_FWD
    end
end
