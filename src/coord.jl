const Coord = SVector{4, Float64}

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
    coord = SVector{4, Float64}(coord[1], coord[2], coord[3], Inf)
    p = proj_trans(trans.pj, PJ_FWD, coord)
    return T(p)
end

function (trans::Transformation)(coord)
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
