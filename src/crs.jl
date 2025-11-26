"""
    CRS(crs)

Create a coordinate reference system. `crs` can be:
- a proj-string,
- a WKT string,
- an object code (like "EPSG:4326", "urn:ogc:def:crs:EPSG::4326", "urn:ogc:def:coordinateOperation:EPSG::1671"),
- an Object name. e.g "WGS 84", "WGS 84 / UTM zone 31N". In that case as uniqueness is not guaranteed, heuristics are applied to determine the appropriate best match.
- a OGC URN combining references for compound coordinate reference systems (e.g "urn:ogc:def:crs,crs:EPSG::2393,crs:EPSG::5717" or custom abbreviated syntax "EPSG:2393+5717"),
- a OGC URN combining references for concatenated operations (e.g. "urn:ogc:def:coordinateOperation,coordinateOperation:EPSG::3895,coordinateOperation:EPSG::1618")
- a PROJJSON string. The jsonschema is at https://proj.org/schemas/v0.4/projjson.schema.json
- a compound CRS made from two object names separated with " + ". e.g. "WGS 84 + EGM96 height"
- a GeoFormatTypes CoordinateReferenceSystemFormat such as EPSG or ProjString
"""
mutable struct CRS
    pj::Ptr{PJ}
    function CRS(crs::Ptr{PJ})
        crs = new(crs)
        finalizer(crs) do crs
            crs = proj_destroy(crs)
        end
        return crs
    end
end

function CRS(crs::AbstractString, ctx::Ptr{PJ_CONTEXT} = C_NULL)
    crs = proj_create(crs, ctx)
    @assert Bool(proj_is_crs(crs)) "Not a CRS:\n$crs"
    return CRS(crs)
end

const MaybeGFTCRS = Union{GFT.CRS,GFT.Unknown,GFT.Extended}

function CRS(
    crs::Union{GFT.CoordinateReferenceSystemFormat,GFT.MixedFormat{<:MaybeGFTCRS}},
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
)
    crs_str = convert(String, crs)
    # For ProjString format, ensure +type=crs is present if it's a proj-string definition
    # This is needed because proj_create() creates a projection (not a CRS) without it
    if crs isa GFT.ProjString && startswith(crs_str, "+proj=") && !contains(crs_str, "+type=crs")
        crs_str = crs_str * " +type=crs"
    end
    pj = proj_create(crs_str, ctx)
    @assert Bool(proj_is_crs(pj)) "Not a CRS:\n$pj"
    return CRS(pj)
end

function Base.show(io::IO, crs::CRS)
    info = proj_pj_info(crs)
    description = unsafe_string(info.description)
    definition = unsafe_string(info.definition)
    print(
        io,
        """CRS
            description: $description
            definition: $definition
        """,
    )
end

Base.unsafe_convert(::Type{Ptr{Cvoid}}, c::CRS) = c.pj

function is_type(crs::CRS, types::NTuple{N,PJ_TYPE}) where {N}
    if is_compound(crs)
        mapreduce(Fix2(is_type, types), |, crs, init = false)
    elseif is_bound(crs)
        is_type(proj_get_source_crs(crs), types)
    else
        proj_get_type(crs) in types
    end
end

function Base.iterate(crs::CRS, i = 0)
    is_compound(crs) || return nothing
    pt = proj_crs_get_sub_crs(crs, i)
    if pt == C_NULL
        return nothing
    else
        return CRS(pt), i + 1
    end
end
Base.IteratorSize(::Type{CRS}) = Base.SizeUnknown()
Base.eltype(::Type{CRS}) = CRS

function is_geographic(crs::CRS)
    is_type(
        crs,
        (PJ_TYPE_GEOGRAPHIC_CRS, PJ_TYPE_GEOGRAPHIC_2D_CRS, PJ_TYPE_GEOGRAPHIC_3D_CRS),
    )
end

function is_projected(crs::CRS)
    is_type(crs, (PJ_TYPE_PROJECTED_CRS,))
end

function is_compound(crs::CRS)
    proj_get_type(crs) == PJ_TYPE_COMPOUND_CRS
end

function is_bound(crs::CRS)
    proj_get_type(crs) == PJ_TYPE_BOUND_CRS
end

function GFT.WellKnownText2(
    crs::CRS;
    type::PJ_WKT_TYPE = PJ_WKT2_2019,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
)
    return GFT.WellKnownText2(GFT.CRS(), proj_as_wkt(crs, type, ctx))
end

function GFT.WellKnownText(
    crs::CRS;
    type::PJ_WKT_TYPE = PJ_WKT1_GDAL,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
)
    return GFT.WellKnownText(GFT.CRS(), proj_as_wkt(crs, type, ctx))
end

function GFT.ESRIWellKnownText(
    crs::CRS;
    type::PJ_WKT_TYPE = PJ_WKT1_ESRI,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
)
    return GFT.ESRIWellKnownText(GFT.CRS(), proj_as_wkt(crs, type, ctx))
end

function GFT.ProjString(
    crs::CRS;
    type::PJ_PROJ_STRING_TYPE = PJ_PROJ_5,
    ctx::Ptr{PJ_CONTEXT} = C_NULL,
)
    return GFT.ProjString(proj_as_proj_string(crs, type, ctx))
end

function GFT.ProjJSON(crs::CRS; ctx::Ptr{PJ_CONTEXT} = C_NULL)
    return GFT.ProjJSON(proj_as_projjson(crs, ctx))
end

function GFT.EPSG(crs::CRS)
    str = proj_get_id_code(crs)
    if isnothing(str)
        error("Could not parse $crs to EPSG code; it probably does not correspond to one.")
    end
    code = parse(Int, str)
    return GFT.EPSG(code)
end

Base.convert(T::Type{<:GFT.CoordinateReferenceSystemFormat}, crs::CRS) = T(crs)
Base.convert(::Type{CRS}, crs::GFT.CoordinateReferenceSystemFormat) = CRS(crs)
Base.convert(T::Type{<:GFT.MixedFormat}, crs::CRS) = T(crs)
Base.convert(::Type{CRS}, crs::GFT.MixedFormat{<:MaybeGFTCRS}) = CRS(crs)

# Maybe enable later, based on https://github.com/JuliaGeo/GeoFormatTypes.jl/issues/21
# Base.convert(T::Type{<:GFT.CoordinateReferenceSystemFormat}, crs::GFT.CoordinateReferenceSystemFormat) = T(CRS(crs))

"""
    identify(crs::CRS; auth_name = nothing)

Returns a list of matching reference CRS and confidence values (0-100).

# Arguments
- `crs::CRS`: Coordinate reference system
- `auth_name=nothing`: Authority name, or nothing for all authorities (e.g. "EPSG")
"""
function identify(
    crs::CRS;
    auth_name = nothing,
)::Vector{@NamedTuple{crs::CRS, confidence::Int32}}

    out_confidence = Ref(Ptr{Cint}(C_NULL))
    if isnothing(auth_name)
        # set authority to C_NULL
        auth_name = C_NULL
    end

    pj_list = proj_identify(crs, auth_name, out_confidence)
    list = NamedTuple{(:crs, :confidence),Tuple{CRS,Int32}}[]

    # was a match found?
    if pj_list != C_NULL
        n = proj_list_get_count(pj_list)
        for i = 1:n
            crs = CRS(proj_list_get(pj_list, i - 1))
            confidence = unsafe_load(out_confidence[], i)
            push!(list, (; crs, confidence))
        end
        proj_int_list_destroy(out_confidence[])
    end
    return list
end
