const Coord = SVector{4, Float64}

mutable struct Transformation <: CoordinateTransformations.Transformation
    pj::Ptr{PJ}
    function Transformation(pj::Ptr{PJ})
        tr = new(pj)
        finalizer(tr) do tr
            tr.pj = proj_destroy(tr.pj)
        end
        return tr
    end
end

function Transformation(
    source_crs::AbstractString,
    target_crs::AbstractString;
    area::Ptr{PJ_AREA} = C_NULL,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
    normalize::Bool = false,
)
    pj = proj_create_crs_to_crs(source_crs, target_crs)
    pj = normalize ? normalize_axis_order!(pj, ctx) : pj
    return Transformation(pj)
end

function Transformation(
    source_crs::Ptr{PJ},
    target_crs::Ptr{PJ};
    area::Ptr{PJ_AREA} = C_NULL,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
    normalize::Bool = false,
)
    pj = proj_create_crs_to_crs_from_pj(source_crs, target_crs)
    pj = normalize ? normalize_axis_order!(pj, ctx) : pj
    return Transformation(pj)
end

function Base.show(io::IO, tr::Transformation)
    source_crs = proj_get_source_crs(tr.pj)
    target_crs = proj_get_target_crs(tr.pj)
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
    normalize_axis_order!(pj::Ptr{PJ}, ctx = C_NULL)

Call proj_normalize_for_visualization on an object, and return the new object after freeing
the input object.
"""
function normalize_axis_order!(pj::Ptr{PJ}, ctx = C_NULL)
    pj_for_gis = proj_normalize_for_visualization(pj, ctx)
    proj_destroy(pj)
    return pj_for_gis
end

function Base.inv(tr::Transformation, ctx = C_NULL)
    pj_inv = proj_coordoperation_create_inverse(tr.pj, ctx)
    return Transformation(pj_inv)
end

function (tr::Transformation)(coord::SVector{2,<:Real})
    coord = SVector{4, Float64}(coord[1], coord[2], 0.0, Inf)
    p = proj_trans(tr.pj, PJ_FWD, coord)
    return SVector{2,Float64}(p[1], p[2])
end

function (tr::Transformation)(coord::SVector{3,<:Real})
    coord = SVector{4, Float64}(coord[1], coord[2], coord[3], Inf)
    p = proj_trans(tr.pj, PJ_FWD, coord)
    return SVector{3,Float64}(p[1], p[2], p[3])
end

function (tr::Transformation)(coord::SVector{4,<:Real})
    return proj_trans(tr.pj, PJ_FWD, coord)
end

function (tr::Transformation)(coord)
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

    p = proj_trans(tr.pj, PJ_FWD, coord)

    if n == 2
        return SVector{2, Float64}(p[1], p[2])
    elseif n == 3
        return SVector{3, Float64}(p[1], p[2], p[3])
    else
        return p
    end
end
