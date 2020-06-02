# Automatically generated using Clang.jl


# Skipping MacroDefinition: PROJ_DLL __attribute__ ( ( visibility ( "default" ) ) )

const PROJ_VERSION_MAJOR = 6
const PROJ_VERSION_MINOR = 1
const PROJ_VERSION_PATCH = 0
const PJ_DEFAULT_CTX = 0

struct PJ_XYZT
    x::Cdouble
    y::Cdouble
    z::Cdouble
    t::Cdouble
end

struct PJ_COORD
    xyzt::PJ_XYZT
end

const PJ_AREA = Cvoid

struct PJ_FACTORS
    meridional_scale::Cdouble
    parallel_scale::Cdouble
    areal_scale::Cdouble
    angular_distortion::Cdouble
    meridian_parallel_angle::Cdouble
    meridian_convergence::Cdouble
    tissot_semimajor::Cdouble
    tissot_semiminor::Cdouble
    dx_dlam::Cdouble
    dx_dphi::Cdouble
    dy_dlam::Cdouble
    dy_dphi::Cdouble
end

const PJ_FACTORS = P5_FACTORS
const PJconsts = Cvoid
const PJ = PJconsts

struct PJ_INFO
    major::Cint
    minor::Cint
    patch::Cint
    release::Cstring
    version::Cstring
    searchpath::Cstring
    paths::Ptr{Cstring}
    path_count::Csize_t
end

struct PJ_PROJ_INFO
    id::Cstring
    description::Cstring
    definition::Cstring
    has_inverse::Cint
    accuracy::Cdouble
end

struct PJ_LP
    lam::Cdouble
    phi::Cdouble
end

struct PJ_GRID_INFO
    gridname::NTuple{32, UInt8}
    filename::NTuple{260, UInt8}
    format::NTuple{8, UInt8}
    lowerleft::PJ_LP
    upperright::PJ_LP
    n_lon::Cint
    n_lat::Cint
    cs_lon::Cdouble
    cs_lat::Cdouble
end

struct PJ_INIT_INFO
    name::NTuple{32, UInt8}
    filename::NTuple{260, UInt8}
    version::NTuple{32, UInt8}
    origin::NTuple{32, UInt8}
    lastupdate::NTuple{16, UInt8}
end

struct PJ_LIST
    id::Cstring
    proj::Ptr{Cvoid}
    descr::Ptr{Cstring}
end

const PJ_OPERATIONS = PJ_LIST

struct PJ_ELLPS
    id::Cstring
    major::Cstring
    ell::Cstring
    name::Cstring
end

struct PJ_UNITS
    id::Cstring
    to_meter::Cstring
    name::Cstring
    factor::Cdouble
end

struct PJ_PRIME_MERIDIANS
    id::Cstring
    defn::Cstring
end

struct PJ_UVWT
    u::Cdouble
    v::Cdouble
    w::Cdouble
    t::Cdouble
end

struct PJ_LPZT
    lam::Cdouble
    phi::Cdouble
    z::Cdouble
    t::Cdouble
end

struct PJ_OPK
    o::Cdouble
    p::Cdouble
    k::Cdouble
end

struct PJ_ENU
    e::Cdouble
    n::Cdouble
    u::Cdouble
end

struct PJ_GEOD
    s::Cdouble
    a1::Cdouble
    a2::Cdouble
end

struct PJ_UV
    u::Cdouble
    v::Cdouble
end

struct PJ_XY
    x::Cdouble
    y::Cdouble
end

struct PJ_XYZ
    x::Cdouble
    y::Cdouble
    z::Cdouble
end

struct PJ_UVW
    u::Cdouble
    v::Cdouble
    w::Cdouble
end

struct PJ_LPZ
    lam::Cdouble
    phi::Cdouble
    z::Cdouble
end

@cenum PJ_LOG_LEVEL::UInt32 begin
    PJ_LOG_NONE = 0
    PJ_LOG_ERROR = 1
    PJ_LOG_DEBUG = 2
    PJ_LOG_TRACE = 3
    PJ_LOG_TELL = 4
    PJ_LOG_DEBUG_MAJOR = 2
    PJ_LOG_DEBUG_MINOR = 3
end


const PJ_LOG_FUNCTION = Ptr{Cvoid}
const projCtx_t = Cvoid
const PJ_CONTEXT = projCtx_t
const proj_file_finder = Ptr{Cvoid}

@cenum PJ_DIRECTION::Int32 begin
    PJ_FWD = 1
    PJ_IDENT = 0
    PJ_INV = -1
end


"Type representing a NULL terminated list of NULL-terminate strings"
const PROJ_STRING_LIST = Ptr{Cstring}

"Guessed WKT \"dialect\""
@cenum PJ_GUESSED_WKT_DIALECT::UInt32 begin
    PJ_GUESSED_WKT2_2018 = 0
    PJ_GUESSED_WKT2_2015 = 1
    PJ_GUESSED_WKT1_GDAL = 2
    PJ_GUESSED_WKT1_ESRI = 3
    PJ_GUESSED_NOT_WKT = 4
end


"Object category"
@cenum PJ_CATEGORY::UInt32 begin
    PJ_CATEGORY_ELLIPSOID = 0
    PJ_CATEGORY_PRIME_MERIDIAN = 1
    PJ_CATEGORY_DATUM = 2
    PJ_CATEGORY_CRS = 3
    PJ_CATEGORY_COORDINATE_OPERATION = 4
end


"Object type"
@cenum PJ_TYPE::UInt32 begin
    PJ_TYPE_UNKNOWN = 0
    PJ_TYPE_ELLIPSOID = 1
    PJ_TYPE_PRIME_MERIDIAN = 2
    PJ_TYPE_GEODETIC_REFERENCE_FRAME = 3
    PJ_TYPE_DYNAMIC_GEODETIC_REFERENCE_FRAME = 4
    PJ_TYPE_VERTICAL_REFERENCE_FRAME = 5
    PJ_TYPE_DYNAMIC_VERTICAL_REFERENCE_FRAME = 6
    PJ_TYPE_DATUM_ENSEMBLE = 7
    PJ_TYPE_CRS = 8
    PJ_TYPE_GEODETIC_CRS = 9
    PJ_TYPE_GEOCENTRIC_CRS = 10
    PJ_TYPE_GEOGRAPHIC_CRS = 11
    PJ_TYPE_GEOGRAPHIC_2D_CRS = 12
    PJ_TYPE_GEOGRAPHIC_3D_CRS = 13
    PJ_TYPE_VERTICAL_CRS = 14
    PJ_TYPE_PROJECTED_CRS = 15
    PJ_TYPE_COMPOUND_CRS = 16
    PJ_TYPE_TEMPORAL_CRS = 17
    PJ_TYPE_ENGINEERING_CRS = 18
    PJ_TYPE_BOUND_CRS = 19
    PJ_TYPE_OTHER_CRS = 20
    PJ_TYPE_CONVERSION = 21
    PJ_TYPE_TRANSFORMATION = 22
    PJ_TYPE_CONCATENATED_OPERATION = 23
    PJ_TYPE_OTHER_COORDINATE_OPERATION = 24
end

@cenum PJ_COMPARISON_CRITERION::UInt32 begin
    PJ_COMP_STRICT = 0
    PJ_COMP_EQUIVALENT = 1
    PJ_COMP_EQUIVALENT_EXCEPT_AXIS_ORDER_GEOGCRS = 2
end


"WKT version"
@cenum PJ_WKT_TYPE::UInt32 begin
    PJ_WKT2_2015 = 0
    PJ_WKT2_2015_SIMPLIFIED = 1
    PJ_WKT2_2018 = 2
    PJ_WKT2_2018_SIMPLIFIED = 3
    PJ_WKT1_GDAL = 4
    PJ_WKT1_ESRI = 5
end

@cenum PROJ_CRS_EXTENT_USE::UInt32 begin
    PJ_CRS_EXTENT_NONE = 0
    PJ_CRS_EXTENT_BOTH = 1
    PJ_CRS_EXTENT_INTERSECTION = 2
    PJ_CRS_EXTENT_SMALLEST = 3
end

@cenum PROJ_GRID_AVAILABILITY_USE::UInt32 begin
    PROJ_GRID_AVAILABILITY_USED_FOR_SORTING = 0
    PROJ_GRID_AVAILABILITY_DISCARD_OPERATION_IF_MISSING_GRID = 1
    PROJ_GRID_AVAILABILITY_IGNORED = 2
end


"PROJ string version"
@cenum PJ_PROJ_STRING_TYPE::UInt32 begin
    PJ_PROJ_5 = 0
    PJ_PROJ_4 = 1
end

@cenum PROJ_SPATIAL_CRITERION::UInt32 begin
    PROJ_SPATIAL_CRITERION_STRICT_CONTAINMENT = 0
    PROJ_SPATIAL_CRITERION_PARTIAL_INTERSECTION = 1
end

@cenum PROJ_INTERMEDIATE_CRS_USE::UInt32 begin
    PROJ_INTERMEDIATE_CRS_USE_ALWAYS = 0
    PROJ_INTERMEDIATE_CRS_USE_IF_NO_DIRECT_TRANSFORMATION = 1
    PROJ_INTERMEDIATE_CRS_USE_NEVER = 2
end

@cenum PJ_COORDINATE_SYSTEM_TYPE::UInt32 begin
    PJ_CS_TYPE_UNKNOWN = 0
    PJ_CS_TYPE_CARTESIAN = 1
    PJ_CS_TYPE_ELLIPSOIDAL = 2
    PJ_CS_TYPE_VERTICAL = 3
    PJ_CS_TYPE_SPHERICAL = 4
    PJ_CS_TYPE_ORDINAL = 5
    PJ_CS_TYPE_PARAMETRIC = 6
    PJ_CS_TYPE_DATETIMETEMPORAL = 7
    PJ_CS_TYPE_TEMPORALCOUNT = 8
    PJ_CS_TYPE_TEMPORALMEASURE = 9
end


struct PROJ_CRS_INFO
    auth_name::Cstring
    code::Cstring
    name::Cstring
    type::PJ_TYPE
    deprecated::Cint
    bbox_valid::Cint
    west_lon_degree::Cdouble
    south_lat_degree::Cdouble
    east_lon_degree::Cdouble
    north_lat_degree::Cdouble
    area_name::Cstring
    projection_method_name::Cstring
end

struct PROJ_CRS_LIST_PARAMETERS
    types::Ptr{PJ_TYPE}
    typesCount::Csize_t
    crs_area_of_use_contains_bbox::Cint
    bbox_valid::Cint
    west_lon_degree::Cdouble
    south_lat_degree::Cdouble
    east_lon_degree::Cdouble
    north_lat_degree::Cdouble
    allow_deprecated::Cint
end

const PJ_OBJ_LIST = Cvoid
const PJ_OPERATION_FACTORY_CONTEXT = Cvoid
