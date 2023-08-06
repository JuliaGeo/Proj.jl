"""
    CRS(crs)

Create a CRS. `crs` can be:
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

function CRS(crs::GFT.CoordinateReferenceSystemFormat, ctx::Ptr{PJ_CONTEXT} = C_NULL)
    crs = proj_create(convert(String, crs), ctx)
    return CRS(crs)
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
    code = parse(Int, str)
    return GFT.EPSG(code)
end

Base.convert(T::Type{<:GFT.CoordinateReferenceSystemFormat}, crs::CRS) = T(crs)
Base.convert(::Type{CRS}, crs::GFT.CoordinateReferenceSystemFormat) = CRS(crs)

# Maybe enable later, based on https://github.com/JuliaGeo/GeoFormatTypes.jl/issues/21
# Base.convert(T::Type{<:GFT.CoordinateReferenceSystemFormat}, crs::GFT.CoordinateReferenceSystemFormat) = T(CRS(crs))




"""
    identify(obj; authority = nothing, options = nothing)

Returns the a list of matching reference CRS or nothing, and the confidence values (0-100) 
or nothing. This is a high level interface to proj_identify.

Inputs:
   obj -- Object of type CRS. Must not be NULL
   authority [nothing] -- Authority name, or NULL for all authorities (e.g. "EPSG")
   allmatches [false] -- if true return all matches, if false return top match
   options -- Placeholder for future options. Should be set to nothing.
"""
function identify(obj; authority=nothing, allmatches=false, options=nothing)

    out_confidence = Ref(Ptr{Cint}(C_NULL))
    if isnothing(authority)
        #set authority to C_NULL
        authority = C_NULL
    end

    if isnothing(options)
        #set authority to C_NULL
        options = C_NULL
    end

    pj_list = Proj.proj_identify(obj, authority, out_confidence, options)

    # was a match found?
    if pj_list == C_NULL
        crs_ref = nothing
        confidence = nothing
    else
        if allmatches
            # return all results
            cnt = Proj.proj_list_get_count(pj_list)
            crs_ref = [Proj.CRS(Proj.proj_list_get(pj_list, i)) for i = 0:(cnt-1)]
            confidence = [unsafe_load(out_confidence[], i) for i = 1:cnt]
        else
            # only return top results
            crs_ref = Proj.CRS(Proj.proj_list_get(pj_list, 0))
            confidence = unsafe_load(out_confidence[], 1)
        end
    end

    return crs_ref, confidence
end