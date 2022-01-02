mutable struct PJ_AREA end

struct P5_FACTORS
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

mutable struct PJconsts end

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
    gridname::NTuple{32, Cchar}
    filename::NTuple{260, Cchar}
    format::NTuple{8, Cchar}
    lowerleft::PJ_LP
    upperright::PJ_LP
    n_lon::Cint
    n_lat::Cint
    cs_lon::Cdouble
    cs_lat::Cdouble
end

struct PJ_INIT_INFO
    name::NTuple{32, Cchar}
    filename::NTuple{260, Cchar}
    version::NTuple{32, Cchar}
    origin::NTuple{32, Cchar}
    lastupdate::NTuple{16, Cchar}
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

@cenum PJ_LOG_LEVEL::UInt32 begin
    PJ_LOG_NONE = 0
    PJ_LOG_ERROR = 1
    PJ_LOG_DEBUG = 2
    PJ_LOG_TRACE = 3
    PJ_LOG_TELL = 4
    PJ_LOG_DEBUG_MAJOR = 2
    PJ_LOG_DEBUG_MINOR = 3
end

# typedef void ( * PJ_LOG_FUNCTION ) ( void * , int , const char * )
const PJ_LOG_FUNCTION = Ptr{Cvoid}

mutable struct pj_ctx end

const PJ_CONTEXT = pj_ctx

function proj_context_create()
    @ccall libproj.proj_context_create()::Ptr{PJ_CONTEXT}
end

function proj_context_destroy(ctx)
    @ccall libproj.proj_context_destroy(ctx::Ptr{PJ_CONTEXT})::Ptr{PJ_CONTEXT}
end

function proj_context_clone(ctx)
    @ccall libproj.proj_context_clone(ctx::Ptr{PJ_CONTEXT})::Ptr{PJ_CONTEXT}
end

# typedef const char * ( * proj_file_finder ) ( PJ_CONTEXT * ctx , const char * , void * user_data )
const proj_file_finder = Ptr{Cvoid}

function proj_context_set_file_finder(ctx, finder, user_data)
    @ccall libproj.proj_context_set_file_finder(ctx::Ptr{PJ_CONTEXT}, finder::proj_file_finder, user_data::Ptr{Cvoid})::Cvoid
end

function proj_context_set_search_paths(ctx, count_paths, paths)
    @ccall libproj.proj_context_set_search_paths(ctx::Ptr{PJ_CONTEXT}, count_paths::Cint, paths::Ptr{Cstring})::Cvoid
end

function proj_context_set_ca_bundle_path(ctx, path)
    @ccall libproj.proj_context_set_ca_bundle_path(ctx::Ptr{PJ_CONTEXT}, path::Cstring)::Cvoid
end

function proj_context_use_proj4_init_rules(ctx, enable)
    @ccall libproj.proj_context_use_proj4_init_rules(ctx::Ptr{PJ_CONTEXT}, enable::Cint)::Cvoid
end

function proj_context_get_use_proj4_init_rules(ctx, from_legacy_code_path)
    @ccall libproj.proj_context_get_use_proj4_init_rules(ctx::Ptr{PJ_CONTEXT}, from_legacy_code_path::Cint)::Cint
end

mutable struct PROJ_FILE_HANDLE end

@cenum PROJ_OPEN_ACCESS::UInt32 begin
    PROJ_OPEN_ACCESS_READ_ONLY = 0
    PROJ_OPEN_ACCESS_READ_UPDATE = 1
    PROJ_OPEN_ACCESS_CREATE = 2
end

struct PROJ_FILE_API
    version::Cint
    open_cbk::Ptr{Cvoid}
    read_cbk::Ptr{Cvoid}
    write_cbk::Ptr{Cvoid}
    seek_cbk::Ptr{Cvoid}
    tell_cbk::Ptr{Cvoid}
    close_cbk::Ptr{Cvoid}
    exists_cbk::Ptr{Cvoid}
    mkdir_cbk::Ptr{Cvoid}
    unlink_cbk::Ptr{Cvoid}
    rename_cbk::Ptr{Cvoid}
end

function proj_context_set_fileapi(ctx, fileapi, user_data)
    @ccall libproj.proj_context_set_fileapi(ctx::Ptr{PJ_CONTEXT}, fileapi::Ptr{PROJ_FILE_API}, user_data::Ptr{Cvoid})::Cint
end

function proj_context_set_sqlite3_vfs_name(ctx, name)
    @ccall libproj.proj_context_set_sqlite3_vfs_name(ctx::Ptr{PJ_CONTEXT}, name::Cstring)::Cvoid
end

mutable struct PROJ_NETWORK_HANDLE end

# typedef PROJ_NETWORK_HANDLE * ( * proj_network_open_cbk_type ) ( PJ_CONTEXT * ctx , const char * url , unsigned long long offset , size_t size_to_read , void * buffer , size_t * out_size_read , size_t error_string_max_size , char * out_error_string , void * user_data )
const proj_network_open_cbk_type = Ptr{Cvoid}

# typedef void ( * proj_network_close_cbk_type ) ( PJ_CONTEXT * ctx , PROJ_NETWORK_HANDLE * handle , void * user_data )
const proj_network_close_cbk_type = Ptr{Cvoid}

# typedef const char * ( * proj_network_get_header_value_cbk_type ) ( PJ_CONTEXT * ctx , PROJ_NETWORK_HANDLE * handle , const char * header_name , void * user_data )
const proj_network_get_header_value_cbk_type = Ptr{Cvoid}

# typedef size_t ( * proj_network_read_range_type ) ( PJ_CONTEXT * ctx , PROJ_NETWORK_HANDLE * handle , unsigned long long offset , size_t size_to_read , void * buffer , size_t error_string_max_size , char * out_error_string , void * user_data )
const proj_network_read_range_type = Ptr{Cvoid}

function proj_context_set_network_callbacks(ctx, open_cbk, close_cbk, get_header_value_cbk, read_range_cbk, user_data)
    @ccall libproj.proj_context_set_network_callbacks(ctx::Ptr{PJ_CONTEXT}, open_cbk::proj_network_open_cbk_type, close_cbk::proj_network_close_cbk_type, get_header_value_cbk::proj_network_get_header_value_cbk_type, read_range_cbk::proj_network_read_range_type, user_data::Ptr{Cvoid})::Cint
end

function proj_context_set_enable_network(ctx, enabled)
    @ccall libproj.proj_context_set_enable_network(ctx::Ptr{PJ_CONTEXT}, enabled::Cint)::Cint
end

function proj_context_is_network_enabled(ctx)
    @ccall libproj.proj_context_is_network_enabled(ctx::Ptr{PJ_CONTEXT})::Cint
end

function proj_context_set_url_endpoint(ctx, url)
    @ccall libproj.proj_context_set_url_endpoint(ctx::Ptr{PJ_CONTEXT}, url::Cstring)::Cvoid
end

function proj_context_get_url_endpoint(ctx)
    @ccall libproj.proj_context_get_url_endpoint(ctx::Ptr{PJ_CONTEXT})::Cstring
end

function proj_context_get_user_writable_directory(ctx, create)
    @ccall libproj.proj_context_get_user_writable_directory(ctx::Ptr{PJ_CONTEXT}, create::Cint)::Cstring
end

function proj_grid_cache_set_enable(ctx, enabled)
    @ccall libproj.proj_grid_cache_set_enable(ctx::Ptr{PJ_CONTEXT}, enabled::Cint)::Cvoid
end

function proj_grid_cache_set_filename(ctx, fullname)
    @ccall libproj.proj_grid_cache_set_filename(ctx::Ptr{PJ_CONTEXT}, fullname::Cstring)::Cvoid
end

function proj_grid_cache_set_max_size(ctx, max_size_MB)
    @ccall libproj.proj_grid_cache_set_max_size(ctx::Ptr{PJ_CONTEXT}, max_size_MB::Cint)::Cvoid
end

function proj_grid_cache_set_ttl(ctx, ttl_seconds)
    @ccall libproj.proj_grid_cache_set_ttl(ctx::Ptr{PJ_CONTEXT}, ttl_seconds::Cint)::Cvoid
end

function proj_grid_cache_clear(ctx)
    @ccall libproj.proj_grid_cache_clear(ctx::Ptr{PJ_CONTEXT})::Cvoid
end

function proj_is_download_needed(ctx, url_or_filename, ignore_ttl_setting)
    @ccall libproj.proj_is_download_needed(ctx::Ptr{PJ_CONTEXT}, url_or_filename::Cstring, ignore_ttl_setting::Cint)::Cint
end

function proj_download_file(ctx, url_or_filename, ignore_ttl_setting, progress_cbk, user_data)
    @ccall libproj.proj_download_file(ctx::Ptr{PJ_CONTEXT}, url_or_filename::Cstring, ignore_ttl_setting::Cint, progress_cbk::Ptr{Cvoid}, user_data::Ptr{Cvoid})::Cint
end

function proj_create(ctx, definition)
    @ccall libproj.proj_create(ctx::Ptr{PJ_CONTEXT}, definition::Cstring)::Ptr{PJ}
end

function proj_create_argv(ctx, argc, argv)
    @ccall libproj.proj_create_argv(ctx::Ptr{PJ_CONTEXT}, argc::Cint, argv::Ptr{Cstring})::Ptr{PJ}
end

function proj_create_crs_to_crs(ctx, source_crs, target_crs, area)
    @ccall libproj.proj_create_crs_to_crs(ctx::Ptr{PJ_CONTEXT}, source_crs::Cstring, target_crs::Cstring, area::Ptr{PJ_AREA})::Ptr{PJ}
end

function proj_create_crs_to_crs_from_pj(ctx, source_crs, target_crs, area, options)
    @ccall libproj.proj_create_crs_to_crs_from_pj(ctx::Ptr{PJ_CONTEXT}, source_crs::Ptr{PJ}, target_crs::Ptr{PJ}, area::Ptr{PJ_AREA}, options::Ptr{Cstring})::Ptr{PJ}
end

function proj_normalize_for_visualization(ctx, obj)
    @ccall libproj.proj_normalize_for_visualization(ctx::Ptr{PJ_CONTEXT}, obj::Ptr{PJ})::Ptr{PJ}
end

function proj_assign_context(pj, ctx)
    @ccall libproj.proj_assign_context(pj::Ptr{PJ}, ctx::Ptr{PJ_CONTEXT})::Cvoid
end

function proj_destroy(P)
    @ccall libproj.proj_destroy(P::Ptr{PJ})::Ptr{PJ}
end

function proj_area_create()
    @ccall libproj.proj_area_create()::Ptr{PJ_AREA}
end

function proj_area_set_bbox(area, west_lon_degree, south_lat_degree, east_lon_degree, north_lat_degree)
    @ccall libproj.proj_area_set_bbox(area::Ptr{PJ_AREA}, west_lon_degree::Cdouble, south_lat_degree::Cdouble, east_lon_degree::Cdouble, north_lat_degree::Cdouble)::Cvoid
end

function proj_area_destroy(area)
    @ccall libproj.proj_area_destroy(area::Ptr{PJ_AREA})::Cvoid
end

@cenum PJ_DIRECTION::Int32 begin
    PJ_FWD = 1
    PJ_IDENT = 0
    PJ_INV = -1
end

function proj_angular_input(P, dir)
    @ccall libproj.proj_angular_input(P::Ptr{PJ}, dir::PJ_DIRECTION)::Cint
end

function proj_angular_output(P, dir)
    @ccall libproj.proj_angular_output(P::Ptr{PJ}, dir::PJ_DIRECTION)::Cint
end

function proj_degree_input(P, dir)
    @ccall libproj.proj_degree_input(P::Ptr{PJ}, dir::PJ_DIRECTION)::Cint
end

function proj_degree_output(P, dir)
    @ccall libproj.proj_degree_output(P::Ptr{PJ}, dir::PJ_DIRECTION)::Cint
end

function proj_trans(P, direction, coord)
    @ccall libproj.proj_trans(P::Ptr{PJ}, direction::PJ_DIRECTION, coord::PJ_COORD)::PJ_COORD
end

function proj_trans_array(P, direction, n, coord)
    @ccall libproj.proj_trans_array(P::Ptr{PJ}, direction::PJ_DIRECTION, n::Csize_t, coord::Ptr{PJ_COORD})::Cint
end

function proj_trans_generic(P, direction, x, sx, nx, y, sy, ny, z, sz, nz, t, st, nt)
    @ccall libproj.proj_trans_generic(P::Ptr{PJ}, direction::PJ_DIRECTION, x::Ptr{Cdouble}, sx::Csize_t, nx::Csize_t, y::Ptr{Cdouble}, sy::Csize_t, ny::Csize_t, z::Ptr{Cdouble}, sz::Csize_t, nz::Csize_t, t::Ptr{Cdouble}, st::Csize_t, nt::Csize_t)::Csize_t
end

function proj_trans_bounds(context, P, direction, xmin, ymin, xmax, ymax, out_xmin, out_ymin, out_xmax, out_ymax, densify_pts)
    @ccall libproj.proj_trans_bounds(context::Ptr{PJ_CONTEXT}, P::Ptr{PJ}, direction::PJ_DIRECTION, xmin::Cdouble, ymin::Cdouble, xmax::Cdouble, ymax::Cdouble, out_xmin::Ptr{Cdouble}, out_ymin::Ptr{Cdouble}, out_xmax::Ptr{Cdouble}, out_ymax::Ptr{Cdouble}, densify_pts::Cint)::Cint
end

function proj_coord(x, y, z, t)
    @ccall libproj.proj_coord(x::Cdouble, y::Cdouble, z::Cdouble, t::Cdouble)::PJ_COORD
end

function proj_roundtrip(P, direction, n, coord)
    @ccall libproj.proj_roundtrip(P::Ptr{PJ}, direction::PJ_DIRECTION, n::Cint, coord::Ptr{PJ_COORD})::Cdouble
end

function proj_lp_dist(P, a, b)
    @ccall libproj.proj_lp_dist(P::Ptr{PJ}, a::PJ_COORD, b::PJ_COORD)::Cdouble
end

function proj_lpz_dist(P, a, b)
    @ccall libproj.proj_lpz_dist(P::Ptr{PJ}, a::PJ_COORD, b::PJ_COORD)::Cdouble
end

function proj_xy_dist(a, b)
    @ccall libproj.proj_xy_dist(a::PJ_COORD, b::PJ_COORD)::Cdouble
end

function proj_xyz_dist(a, b)
    @ccall libproj.proj_xyz_dist(a::PJ_COORD, b::PJ_COORD)::Cdouble
end

function proj_geod(P, a, b)
    @ccall libproj.proj_geod(P::Ptr{PJ}, a::PJ_COORD, b::PJ_COORD)::PJ_COORD
end

function proj_context_errno(ctx)
    @ccall libproj.proj_context_errno(ctx::Ptr{PJ_CONTEXT})::Cint
end

function proj_errno(P)
    @ccall libproj.proj_errno(P::Ptr{PJ})::Cint
end

function proj_errno_set(P, err)
    @ccall libproj.proj_errno_set(P::Ptr{PJ}, err::Cint)::Cint
end

function proj_errno_reset(P)
    @ccall libproj.proj_errno_reset(P::Ptr{PJ})::Cint
end

function proj_errno_restore(P, err)
    @ccall libproj.proj_errno_restore(P::Ptr{PJ}, err::Cint)::Cint
end

function proj_errno_string(err)
    @ccall libproj.proj_errno_string(err::Cint)::Cstring
end

function proj_context_errno_string(ctx, err)
    @ccall libproj.proj_context_errno_string(ctx::Ptr{PJ_CONTEXT}, err::Cint)::Cstring
end

function proj_log_level(ctx, log_level)
    @ccall libproj.proj_log_level(ctx::Ptr{PJ_CONTEXT}, log_level::PJ_LOG_LEVEL)::PJ_LOG_LEVEL
end

function proj_log_func(ctx, app_data, logf)
    @ccall libproj.proj_log_func(ctx::Ptr{PJ_CONTEXT}, app_data::Ptr{Cvoid}, logf::PJ_LOG_FUNCTION)::Cvoid
end

function proj_factors(P, lp)
    @ccall libproj.proj_factors(P::Ptr{PJ}, lp::PJ_COORD)::PJ_FACTORS
end

function proj_info()
    @ccall libproj.proj_info()::PJ_INFO
end

function proj_pj_info(P)
    @ccall libproj.proj_pj_info(P::Ptr{PJ})::PJ_PROJ_INFO
end

function proj_grid_info(gridname)
    @ccall libproj.proj_grid_info(gridname::Cstring)::PJ_GRID_INFO
end

function proj_init_info(initname)
    @ccall libproj.proj_init_info(initname::Cstring)::PJ_INIT_INFO
end

function proj_list_operations()
    @ccall libproj.proj_list_operations()::Ptr{PJ_OPERATIONS}
end

function proj_list_ellps()
    @ccall libproj.proj_list_ellps()::Ptr{PJ_ELLPS}
end

function proj_list_units()
    @ccall libproj.proj_list_units()::Ptr{PJ_UNITS}
end

function proj_list_angular_units()
    @ccall libproj.proj_list_angular_units()::Ptr{PJ_UNITS}
end

function proj_list_prime_meridians()
    @ccall libproj.proj_list_prime_meridians()::Ptr{PJ_PRIME_MERIDIANS}
end

function proj_torad(angle_in_degrees)
    @ccall libproj.proj_torad(angle_in_degrees::Cdouble)::Cdouble
end

function proj_todeg(angle_in_radians)
    @ccall libproj.proj_todeg(angle_in_radians::Cdouble)::Cdouble
end

function proj_dmstor(is, rs)
    @ccall libproj.proj_dmstor(is::Cstring, rs::Ptr{Cstring})::Cdouble
end

function proj_rtodms(s, r, pos, neg)
    @ccall libproj.proj_rtodms(s::Cstring, r::Cdouble, pos::Cint, neg::Cint)::Cstring
end

function proj_cleanup()
    @ccall libproj.proj_cleanup()::Cvoid
end

const PROJ_STRING_LIST = Ptr{Cstring}

@cenum PJ_GUESSED_WKT_DIALECT::UInt32 begin
    PJ_GUESSED_WKT2_2019 = 0
    PJ_GUESSED_WKT2_2018 = 0
    PJ_GUESSED_WKT2_2015 = 1
    PJ_GUESSED_WKT1_GDAL = 2
    PJ_GUESSED_WKT1_ESRI = 3
    PJ_GUESSED_NOT_WKT = 4
end

@cenum PJ_CATEGORY::UInt32 begin
    PJ_CATEGORY_ELLIPSOID = 0
    PJ_CATEGORY_PRIME_MERIDIAN = 1
    PJ_CATEGORY_DATUM = 2
    PJ_CATEGORY_CRS = 3
    PJ_CATEGORY_COORDINATE_OPERATION = 4
    PJ_CATEGORY_DATUM_ENSEMBLE = 5
end

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
    PJ_TYPE_TEMPORAL_DATUM = 25
    PJ_TYPE_ENGINEERING_DATUM = 26
    PJ_TYPE_PARAMETRIC_DATUM = 27
end

@cenum PJ_COMPARISON_CRITERION::UInt32 begin
    PJ_COMP_STRICT = 0
    PJ_COMP_EQUIVALENT = 1
    PJ_COMP_EQUIVALENT_EXCEPT_AXIS_ORDER_GEOGCRS = 2
end

@cenum PJ_WKT_TYPE::UInt32 begin
    PJ_WKT2_2015 = 0
    PJ_WKT2_2015_SIMPLIFIED = 1
    PJ_WKT2_2019 = 2
    PJ_WKT2_2018 = 2
    PJ_WKT2_2019_SIMPLIFIED = 3
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
    PROJ_GRID_AVAILABILITY_KNOWN_AVAILABLE = 3
end

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
    celestial_body_name::Cstring
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
    celestial_body_name::Cstring
end

struct PROJ_UNIT_INFO
    auth_name::Cstring
    code::Cstring
    name::Cstring
    category::Cstring
    conv_factor::Cdouble
    proj_short_name::Cstring
    deprecated::Cint
end

struct PROJ_CELESTIAL_BODY_INFO
    auth_name::Cstring
    name::Cstring
end

mutable struct PJ_OBJ_LIST end

function proj_string_list_destroy(list)
    @ccall libproj.proj_string_list_destroy(list::PROJ_STRING_LIST)::Cvoid
end

function proj_context_set_autoclose_database(ctx, autoclose)
    @ccall libproj.proj_context_set_autoclose_database(ctx::Ptr{PJ_CONTEXT}, autoclose::Cint)::Cvoid
end

function proj_context_set_database_path(ctx, dbPath, auxDbPaths, options)
    @ccall libproj.proj_context_set_database_path(ctx::Ptr{PJ_CONTEXT}, dbPath::Cstring, auxDbPaths::Ptr{Cstring}, options::Ptr{Cstring})::Cint
end

function proj_context_get_database_path(ctx)
    @ccall libproj.proj_context_get_database_path(ctx::Ptr{PJ_CONTEXT})::Cstring
end

function proj_context_get_database_metadata(ctx, key)
    @ccall libproj.proj_context_get_database_metadata(ctx::Ptr{PJ_CONTEXT}, key::Cstring)::Cstring
end

function proj_context_get_database_structure(ctx, options)
    @ccall libproj.proj_context_get_database_structure(ctx::Ptr{PJ_CONTEXT}, options::Ptr{Cstring})::PROJ_STRING_LIST
end

function proj_context_guess_wkt_dialect(ctx, wkt)
    @ccall libproj.proj_context_guess_wkt_dialect(ctx::Ptr{PJ_CONTEXT}, wkt::Cstring)::PJ_GUESSED_WKT_DIALECT
end

function proj_create_from_wkt(ctx, wkt, options, out_warnings, out_grammar_errors)
    @ccall libproj.proj_create_from_wkt(ctx::Ptr{PJ_CONTEXT}, wkt::Cstring, options::Ptr{Cstring}, out_warnings::Ptr{PROJ_STRING_LIST}, out_grammar_errors::Ptr{PROJ_STRING_LIST})::Ptr{PJ}
end

function proj_create_from_database(ctx, auth_name, code, category, usePROJAlternativeGridNames, options)
    @ccall libproj.proj_create_from_database(ctx::Ptr{PJ_CONTEXT}, auth_name::Cstring, code::Cstring, category::PJ_CATEGORY, usePROJAlternativeGridNames::Cint, options::Ptr{Cstring})::Ptr{PJ}
end

function proj_uom_get_info_from_database(ctx, auth_name, code, out_name, out_conv_factor, out_category)
    @ccall libproj.proj_uom_get_info_from_database(ctx::Ptr{PJ_CONTEXT}, auth_name::Cstring, code::Cstring, out_name::Ptr{Cstring}, out_conv_factor::Ptr{Cdouble}, out_category::Ptr{Cstring})::Cint
end

function proj_grid_get_info_from_database(ctx, grid_name, out_full_name, out_package_name, out_url, out_direct_download, out_open_license, out_available)
    @ccall libproj.proj_grid_get_info_from_database(ctx::Ptr{PJ_CONTEXT}, grid_name::Cstring, out_full_name::Ptr{Cstring}, out_package_name::Ptr{Cstring}, out_url::Ptr{Cstring}, out_direct_download::Ptr{Cint}, out_open_license::Ptr{Cint}, out_available::Ptr{Cint})::Cint
end

function proj_clone(ctx, obj)
    @ccall libproj.proj_clone(ctx::Ptr{PJ_CONTEXT}, obj::Ptr{PJ})::Ptr{PJ}
end

function proj_create_from_name(ctx, auth_name, searchedName, types, typesCount, approximateMatch, limitResultCount, options)
    @ccall libproj.proj_create_from_name(ctx::Ptr{PJ_CONTEXT}, auth_name::Cstring, searchedName::Cstring, types::Ptr{PJ_TYPE}, typesCount::Csize_t, approximateMatch::Cint, limitResultCount::Csize_t, options::Ptr{Cstring})::Ptr{PJ_OBJ_LIST}
end

function proj_get_type(obj)
    @ccall libproj.proj_get_type(obj::Ptr{PJ})::PJ_TYPE
end

function proj_is_deprecated(obj)
    @ccall libproj.proj_is_deprecated(obj::Ptr{PJ})::Cint
end

function proj_get_non_deprecated(ctx, obj)
    @ccall libproj.proj_get_non_deprecated(ctx::Ptr{PJ_CONTEXT}, obj::Ptr{PJ})::Ptr{PJ_OBJ_LIST}
end

function proj_is_equivalent_to(obj, other, criterion)
    @ccall libproj.proj_is_equivalent_to(obj::Ptr{PJ}, other::Ptr{PJ}, criterion::PJ_COMPARISON_CRITERION)::Cint
end

function proj_is_equivalent_to_with_ctx(ctx, obj, other, criterion)
    @ccall libproj.proj_is_equivalent_to_with_ctx(ctx::Ptr{PJ_CONTEXT}, obj::Ptr{PJ}, other::Ptr{PJ}, criterion::PJ_COMPARISON_CRITERION)::Cint
end

function proj_is_crs(obj)
    @ccall libproj.proj_is_crs(obj::Ptr{PJ})::Cint
end

function proj_get_name(obj)
    @ccall libproj.proj_get_name(obj::Ptr{PJ})::Cstring
end

function proj_get_id_auth_name(obj, index)
    @ccall libproj.proj_get_id_auth_name(obj::Ptr{PJ}, index::Cint)::Cstring
end

function proj_get_id_code(obj, index)
    @ccall libproj.proj_get_id_code(obj::Ptr{PJ}, index::Cint)::Cstring
end

function proj_get_remarks(obj)
    @ccall libproj.proj_get_remarks(obj::Ptr{PJ})::Cstring
end

function proj_get_scope(obj)
    @ccall libproj.proj_get_scope(obj::Ptr{PJ})::Cstring
end

function proj_get_area_of_use(ctx, obj, out_west_lon_degree, out_south_lat_degree, out_east_lon_degree, out_north_lat_degree, out_area_name)
    @ccall libproj.proj_get_area_of_use(ctx::Ptr{PJ_CONTEXT}, obj::Ptr{PJ}, out_west_lon_degree::Ptr{Cdouble}, out_south_lat_degree::Ptr{Cdouble}, out_east_lon_degree::Ptr{Cdouble}, out_north_lat_degree::Ptr{Cdouble}, out_area_name::Ptr{Cstring})::Cint
end

function proj_as_wkt(ctx, obj, type, options)
    @ccall libproj.proj_as_wkt(ctx::Ptr{PJ_CONTEXT}, obj::Ptr{PJ}, type::PJ_WKT_TYPE, options::Ptr{Cstring})::Cstring
end

function proj_as_proj_string(ctx, obj, type, options)
    @ccall libproj.proj_as_proj_string(ctx::Ptr{PJ_CONTEXT}, obj::Ptr{PJ}, type::PJ_PROJ_STRING_TYPE, options::Ptr{Cstring})::Cstring
end

function proj_as_projjson(ctx, obj, options)
    @ccall libproj.proj_as_projjson(ctx::Ptr{PJ_CONTEXT}, obj::Ptr{PJ}, options::Ptr{Cstring})::Cstring
end

function proj_get_source_crs(ctx, obj)
    @ccall libproj.proj_get_source_crs(ctx::Ptr{PJ_CONTEXT}, obj::Ptr{PJ})::Ptr{PJ}
end

function proj_get_target_crs(ctx, obj)
    @ccall libproj.proj_get_target_crs(ctx::Ptr{PJ_CONTEXT}, obj::Ptr{PJ})::Ptr{PJ}
end

function proj_identify(ctx, obj, auth_name, options, out_confidence)
    @ccall libproj.proj_identify(ctx::Ptr{PJ_CONTEXT}, obj::Ptr{PJ}, auth_name::Cstring, options::Ptr{Cstring}, out_confidence::Ptr{Ptr{Cint}})::Ptr{PJ_OBJ_LIST}
end

function proj_get_geoid_models_from_database(ctx, auth_name, code, options)
    @ccall libproj.proj_get_geoid_models_from_database(ctx::Ptr{PJ_CONTEXT}, auth_name::Cstring, code::Cstring, options::Ptr{Cstring})::PROJ_STRING_LIST
end

function proj_int_list_destroy(list)
    @ccall libproj.proj_int_list_destroy(list::Ptr{Cint})::Cvoid
end

function proj_get_authorities_from_database(ctx)
    @ccall libproj.proj_get_authorities_from_database(ctx::Ptr{PJ_CONTEXT})::PROJ_STRING_LIST
end

function proj_get_codes_from_database(ctx, auth_name, type, allow_deprecated)
    @ccall libproj.proj_get_codes_from_database(ctx::Ptr{PJ_CONTEXT}, auth_name::Cstring, type::PJ_TYPE, allow_deprecated::Cint)::PROJ_STRING_LIST
end

function proj_get_celestial_body_list_from_database(ctx, auth_name, out_result_count)
    @ccall libproj.proj_get_celestial_body_list_from_database(ctx::Ptr{PJ_CONTEXT}, auth_name::Cstring, out_result_count::Ptr{Cint})::Ptr{Ptr{PROJ_CELESTIAL_BODY_INFO}}
end

function proj_celestial_body_list_destroy(list)
    @ccall libproj.proj_celestial_body_list_destroy(list::Ptr{Ptr{PROJ_CELESTIAL_BODY_INFO}})::Cvoid
end

function proj_get_crs_list_parameters_create()
    @ccall libproj.proj_get_crs_list_parameters_create()::Ptr{PROJ_CRS_LIST_PARAMETERS}
end

function proj_get_crs_list_parameters_destroy(params)
    @ccall libproj.proj_get_crs_list_parameters_destroy(params::Ptr{PROJ_CRS_LIST_PARAMETERS})::Cvoid
end

function proj_get_crs_info_list_from_database(ctx, auth_name, params, out_result_count)
    @ccall libproj.proj_get_crs_info_list_from_database(ctx::Ptr{PJ_CONTEXT}, auth_name::Cstring, params::Ptr{PROJ_CRS_LIST_PARAMETERS}, out_result_count::Ptr{Cint})::Ptr{Ptr{PROJ_CRS_INFO}}
end

function proj_crs_info_list_destroy(list)
    @ccall libproj.proj_crs_info_list_destroy(list::Ptr{Ptr{PROJ_CRS_INFO}})::Cvoid
end

function proj_get_units_from_database(ctx, auth_name, category, allow_deprecated, out_result_count)
    @ccall libproj.proj_get_units_from_database(ctx::Ptr{PJ_CONTEXT}, auth_name::Cstring, category::Cstring, allow_deprecated::Cint, out_result_count::Ptr{Cint})::Ptr{Ptr{PROJ_UNIT_INFO}}
end

function proj_unit_list_destroy(list)
    @ccall libproj.proj_unit_list_destroy(list::Ptr{Ptr{PROJ_UNIT_INFO}})::Cvoid
end

mutable struct PJ_INSERT_SESSION end

function proj_insert_object_session_create(ctx)
    @ccall libproj.proj_insert_object_session_create(ctx::Ptr{PJ_CONTEXT})::Ptr{PJ_INSERT_SESSION}
end

function proj_insert_object_session_destroy(ctx, session)
    @ccall libproj.proj_insert_object_session_destroy(ctx::Ptr{PJ_CONTEXT}, session::Ptr{PJ_INSERT_SESSION})::Cvoid
end

function proj_get_insert_statements(ctx, session, object, authority, code, numeric_codes, allowed_authorities, options)
    @ccall libproj.proj_get_insert_statements(ctx::Ptr{PJ_CONTEXT}, session::Ptr{PJ_INSERT_SESSION}, object::Ptr{PJ}, authority::Cstring, code::Cstring, numeric_codes::Cint, allowed_authorities::Ptr{Cstring}, options::Ptr{Cstring})::PROJ_STRING_LIST
end

function proj_suggests_code_for(ctx, object, authority, numeric_code, options)
    @ccall libproj.proj_suggests_code_for(ctx::Ptr{PJ_CONTEXT}, object::Ptr{PJ}, authority::Cstring, numeric_code::Cint, options::Ptr{Cstring})::Cstring
end

function proj_string_destroy(str)
    @ccall libproj.proj_string_destroy(str::Cstring)::Cvoid
end

mutable struct PJ_OPERATION_FACTORY_CONTEXT end

function proj_create_operation_factory_context(ctx, authority)
    @ccall libproj.proj_create_operation_factory_context(ctx::Ptr{PJ_CONTEXT}, authority::Cstring)::Ptr{PJ_OPERATION_FACTORY_CONTEXT}
end

function proj_operation_factory_context_destroy(ctx)
    @ccall libproj.proj_operation_factory_context_destroy(ctx::Ptr{PJ_OPERATION_FACTORY_CONTEXT})::Cvoid
end

function proj_operation_factory_context_set_desired_accuracy(ctx, factory_ctx, accuracy)
    @ccall libproj.proj_operation_factory_context_set_desired_accuracy(ctx::Ptr{PJ_CONTEXT}, factory_ctx::Ptr{PJ_OPERATION_FACTORY_CONTEXT}, accuracy::Cdouble)::Cvoid
end

function proj_operation_factory_context_set_area_of_interest(ctx, factory_ctx, west_lon_degree, south_lat_degree, east_lon_degree, north_lat_degree)
    @ccall libproj.proj_operation_factory_context_set_area_of_interest(ctx::Ptr{PJ_CONTEXT}, factory_ctx::Ptr{PJ_OPERATION_FACTORY_CONTEXT}, west_lon_degree::Cdouble, south_lat_degree::Cdouble, east_lon_degree::Cdouble, north_lat_degree::Cdouble)::Cvoid
end

function proj_operation_factory_context_set_crs_extent_use(ctx, factory_ctx, use)
    @ccall libproj.proj_operation_factory_context_set_crs_extent_use(ctx::Ptr{PJ_CONTEXT}, factory_ctx::Ptr{PJ_OPERATION_FACTORY_CONTEXT}, use::PROJ_CRS_EXTENT_USE)::Cvoid
end

function proj_operation_factory_context_set_spatial_criterion(ctx, factory_ctx, criterion)
    @ccall libproj.proj_operation_factory_context_set_spatial_criterion(ctx::Ptr{PJ_CONTEXT}, factory_ctx::Ptr{PJ_OPERATION_FACTORY_CONTEXT}, criterion::PROJ_SPATIAL_CRITERION)::Cvoid
end

function proj_operation_factory_context_set_grid_availability_use(ctx, factory_ctx, use)
    @ccall libproj.proj_operation_factory_context_set_grid_availability_use(ctx::Ptr{PJ_CONTEXT}, factory_ctx::Ptr{PJ_OPERATION_FACTORY_CONTEXT}, use::PROJ_GRID_AVAILABILITY_USE)::Cvoid
end

function proj_operation_factory_context_set_use_proj_alternative_grid_names(ctx, factory_ctx, usePROJNames)
    @ccall libproj.proj_operation_factory_context_set_use_proj_alternative_grid_names(ctx::Ptr{PJ_CONTEXT}, factory_ctx::Ptr{PJ_OPERATION_FACTORY_CONTEXT}, usePROJNames::Cint)::Cvoid
end

function proj_operation_factory_context_set_allow_use_intermediate_crs(ctx, factory_ctx, use)
    @ccall libproj.proj_operation_factory_context_set_allow_use_intermediate_crs(ctx::Ptr{PJ_CONTEXT}, factory_ctx::Ptr{PJ_OPERATION_FACTORY_CONTEXT}, use::PROJ_INTERMEDIATE_CRS_USE)::Cvoid
end

function proj_operation_factory_context_set_allowed_intermediate_crs(ctx, factory_ctx, list_of_auth_name_codes)
    @ccall libproj.proj_operation_factory_context_set_allowed_intermediate_crs(ctx::Ptr{PJ_CONTEXT}, factory_ctx::Ptr{PJ_OPERATION_FACTORY_CONTEXT}, list_of_auth_name_codes::Ptr{Cstring})::Cvoid
end

function proj_operation_factory_context_set_discard_superseded(ctx, factory_ctx, discard)
    @ccall libproj.proj_operation_factory_context_set_discard_superseded(ctx::Ptr{PJ_CONTEXT}, factory_ctx::Ptr{PJ_OPERATION_FACTORY_CONTEXT}, discard::Cint)::Cvoid
end

function proj_operation_factory_context_set_allow_ballpark_transformations(ctx, factory_ctx, allow)
    @ccall libproj.proj_operation_factory_context_set_allow_ballpark_transformations(ctx::Ptr{PJ_CONTEXT}, factory_ctx::Ptr{PJ_OPERATION_FACTORY_CONTEXT}, allow::Cint)::Cvoid
end

function proj_create_operations(ctx, source_crs, target_crs, operationContext)
    @ccall libproj.proj_create_operations(ctx::Ptr{PJ_CONTEXT}, source_crs::Ptr{PJ}, target_crs::Ptr{PJ}, operationContext::Ptr{PJ_OPERATION_FACTORY_CONTEXT})::Ptr{PJ_OBJ_LIST}
end

function proj_list_get_count(result)
    @ccall libproj.proj_list_get_count(result::Ptr{PJ_OBJ_LIST})::Cint
end

function proj_list_get(ctx, result, index)
    @ccall libproj.proj_list_get(ctx::Ptr{PJ_CONTEXT}, result::Ptr{PJ_OBJ_LIST}, index::Cint)::Ptr{PJ}
end

function proj_list_destroy(result)
    @ccall libproj.proj_list_destroy(result::Ptr{PJ_OBJ_LIST})::Cvoid
end

function proj_get_suggested_operation(ctx, operations, direction, coord)
    @ccall libproj.proj_get_suggested_operation(ctx::Ptr{PJ_CONTEXT}, operations::Ptr{PJ_OBJ_LIST}, direction::PJ_DIRECTION, coord::PJ_COORD)::Cint
end

function proj_crs_is_derived(ctx, crs)
    @ccall libproj.proj_crs_is_derived(ctx::Ptr{PJ_CONTEXT}, crs::Ptr{PJ})::Cint
end

function proj_crs_get_geodetic_crs(ctx, crs)
    @ccall libproj.proj_crs_get_geodetic_crs(ctx::Ptr{PJ_CONTEXT}, crs::Ptr{PJ})::Ptr{PJ}
end

function proj_crs_get_horizontal_datum(ctx, crs)
    @ccall libproj.proj_crs_get_horizontal_datum(ctx::Ptr{PJ_CONTEXT}, crs::Ptr{PJ})::Ptr{PJ}
end

function proj_crs_get_sub_crs(ctx, crs, index)
    @ccall libproj.proj_crs_get_sub_crs(ctx::Ptr{PJ_CONTEXT}, crs::Ptr{PJ}, index::Cint)::Ptr{PJ}
end

function proj_crs_get_datum(ctx, crs)
    @ccall libproj.proj_crs_get_datum(ctx::Ptr{PJ_CONTEXT}, crs::Ptr{PJ})::Ptr{PJ}
end

function proj_crs_get_datum_ensemble(ctx, crs)
    @ccall libproj.proj_crs_get_datum_ensemble(ctx::Ptr{PJ_CONTEXT}, crs::Ptr{PJ})::Ptr{PJ}
end

function proj_crs_get_datum_forced(ctx, crs)
    @ccall libproj.proj_crs_get_datum_forced(ctx::Ptr{PJ_CONTEXT}, crs::Ptr{PJ})::Ptr{PJ}
end

function proj_datum_ensemble_get_member_count(ctx, datum_ensemble)
    @ccall libproj.proj_datum_ensemble_get_member_count(ctx::Ptr{PJ_CONTEXT}, datum_ensemble::Ptr{PJ})::Cint
end

function proj_datum_ensemble_get_accuracy(ctx, datum_ensemble)
    @ccall libproj.proj_datum_ensemble_get_accuracy(ctx::Ptr{PJ_CONTEXT}, datum_ensemble::Ptr{PJ})::Cdouble
end

function proj_datum_ensemble_get_member(ctx, datum_ensemble, member_index)
    @ccall libproj.proj_datum_ensemble_get_member(ctx::Ptr{PJ_CONTEXT}, datum_ensemble::Ptr{PJ}, member_index::Cint)::Ptr{PJ}
end

function proj_dynamic_datum_get_frame_reference_epoch(ctx, datum)
    @ccall libproj.proj_dynamic_datum_get_frame_reference_epoch(ctx::Ptr{PJ_CONTEXT}, datum::Ptr{PJ})::Cdouble
end

function proj_crs_get_coordinate_system(ctx, crs)
    @ccall libproj.proj_crs_get_coordinate_system(ctx::Ptr{PJ_CONTEXT}, crs::Ptr{PJ})::Ptr{PJ}
end

function proj_cs_get_type(ctx, cs)
    @ccall libproj.proj_cs_get_type(ctx::Ptr{PJ_CONTEXT}, cs::Ptr{PJ})::PJ_COORDINATE_SYSTEM_TYPE
end

function proj_cs_get_axis_count(ctx, cs)
    @ccall libproj.proj_cs_get_axis_count(ctx::Ptr{PJ_CONTEXT}, cs::Ptr{PJ})::Cint
end

function proj_cs_get_axis_info(ctx, cs, index, out_name, out_abbrev, out_direction, out_unit_conv_factor, out_unit_name, out_unit_auth_name, out_unit_code)
    @ccall libproj.proj_cs_get_axis_info(ctx::Ptr{PJ_CONTEXT}, cs::Ptr{PJ}, index::Cint, out_name::Ptr{Cstring}, out_abbrev::Ptr{Cstring}, out_direction::Ptr{Cstring}, out_unit_conv_factor::Ptr{Cdouble}, out_unit_name::Ptr{Cstring}, out_unit_auth_name::Ptr{Cstring}, out_unit_code::Ptr{Cstring})::Cint
end

function proj_get_ellipsoid(ctx, obj)
    @ccall libproj.proj_get_ellipsoid(ctx::Ptr{PJ_CONTEXT}, obj::Ptr{PJ})::Ptr{PJ}
end

function proj_ellipsoid_get_parameters(ctx, ellipsoid, out_semi_major_metre, out_semi_minor_metre, out_is_semi_minor_computed, out_inv_flattening)
    @ccall libproj.proj_ellipsoid_get_parameters(ctx::Ptr{PJ_CONTEXT}, ellipsoid::Ptr{PJ}, out_semi_major_metre::Ptr{Cdouble}, out_semi_minor_metre::Ptr{Cdouble}, out_is_semi_minor_computed::Ptr{Cint}, out_inv_flattening::Ptr{Cdouble})::Cint
end

function proj_get_celestial_body_name(ctx, obj)
    @ccall libproj.proj_get_celestial_body_name(ctx::Ptr{PJ_CONTEXT}, obj::Ptr{PJ})::Cstring
end

function proj_get_prime_meridian(ctx, obj)
    @ccall libproj.proj_get_prime_meridian(ctx::Ptr{PJ_CONTEXT}, obj::Ptr{PJ})::Ptr{PJ}
end

function proj_prime_meridian_get_parameters(ctx, prime_meridian, out_longitude, out_unit_conv_factor, out_unit_name)
    @ccall libproj.proj_prime_meridian_get_parameters(ctx::Ptr{PJ_CONTEXT}, prime_meridian::Ptr{PJ}, out_longitude::Ptr{Cdouble}, out_unit_conv_factor::Ptr{Cdouble}, out_unit_name::Ptr{Cstring})::Cint
end

function proj_crs_get_coordoperation(ctx, crs)
    @ccall libproj.proj_crs_get_coordoperation(ctx::Ptr{PJ_CONTEXT}, crs::Ptr{PJ})::Ptr{PJ}
end

function proj_coordoperation_get_method_info(ctx, coordoperation, out_method_name, out_method_auth_name, out_method_code)
    @ccall libproj.proj_coordoperation_get_method_info(ctx::Ptr{PJ_CONTEXT}, coordoperation::Ptr{PJ}, out_method_name::Ptr{Cstring}, out_method_auth_name::Ptr{Cstring}, out_method_code::Ptr{Cstring})::Cint
end

function proj_coordoperation_is_instantiable(ctx, coordoperation)
    @ccall libproj.proj_coordoperation_is_instantiable(ctx::Ptr{PJ_CONTEXT}, coordoperation::Ptr{PJ})::Cint
end

function proj_coordoperation_has_ballpark_transformation(ctx, coordoperation)
    @ccall libproj.proj_coordoperation_has_ballpark_transformation(ctx::Ptr{PJ_CONTEXT}, coordoperation::Ptr{PJ})::Cint
end

function proj_coordoperation_get_param_count(ctx, coordoperation)
    @ccall libproj.proj_coordoperation_get_param_count(ctx::Ptr{PJ_CONTEXT}, coordoperation::Ptr{PJ})::Cint
end

function proj_coordoperation_get_param_index(ctx, coordoperation, name)
    @ccall libproj.proj_coordoperation_get_param_index(ctx::Ptr{PJ_CONTEXT}, coordoperation::Ptr{PJ}, name::Cstring)::Cint
end

function proj_coordoperation_get_param(ctx, coordoperation, index, out_name, out_auth_name, out_code, out_value, out_value_string, out_unit_conv_factor, out_unit_name, out_unit_auth_name, out_unit_code, out_unit_category)
    @ccall libproj.proj_coordoperation_get_param(ctx::Ptr{PJ_CONTEXT}, coordoperation::Ptr{PJ}, index::Cint, out_name::Ptr{Cstring}, out_auth_name::Ptr{Cstring}, out_code::Ptr{Cstring}, out_value::Ptr{Cdouble}, out_value_string::Ptr{Cstring}, out_unit_conv_factor::Ptr{Cdouble}, out_unit_name::Ptr{Cstring}, out_unit_auth_name::Ptr{Cstring}, out_unit_code::Ptr{Cstring}, out_unit_category::Ptr{Cstring})::Cint
end

function proj_coordoperation_get_grid_used_count(ctx, coordoperation)
    @ccall libproj.proj_coordoperation_get_grid_used_count(ctx::Ptr{PJ_CONTEXT}, coordoperation::Ptr{PJ})::Cint
end

function proj_coordoperation_get_grid_used(ctx, coordoperation, index, out_short_name, out_full_name, out_package_name, out_url, out_direct_download, out_open_license, out_available)
    @ccall libproj.proj_coordoperation_get_grid_used(ctx::Ptr{PJ_CONTEXT}, coordoperation::Ptr{PJ}, index::Cint, out_short_name::Ptr{Cstring}, out_full_name::Ptr{Cstring}, out_package_name::Ptr{Cstring}, out_url::Ptr{Cstring}, out_direct_download::Ptr{Cint}, out_open_license::Ptr{Cint}, out_available::Ptr{Cint})::Cint
end

function proj_coordoperation_get_accuracy(ctx, obj)
    @ccall libproj.proj_coordoperation_get_accuracy(ctx::Ptr{PJ_CONTEXT}, obj::Ptr{PJ})::Cdouble
end

function proj_coordoperation_get_towgs84_values(ctx, coordoperation, out_values, value_count, emit_error_if_incompatible)
    @ccall libproj.proj_coordoperation_get_towgs84_values(ctx::Ptr{PJ_CONTEXT}, coordoperation::Ptr{PJ}, out_values::Ptr{Cdouble}, value_count::Cint, emit_error_if_incompatible::Cint)::Cint
end

function proj_coordoperation_create_inverse(ctx, obj)
    @ccall libproj.proj_coordoperation_create_inverse(ctx::Ptr{PJ_CONTEXT}, obj::Ptr{PJ})::Ptr{PJ}
end

function proj_concatoperation_get_step_count(ctx, concatoperation)
    @ccall libproj.proj_concatoperation_get_step_count(ctx::Ptr{PJ_CONTEXT}, concatoperation::Ptr{PJ})::Cint
end

function proj_concatoperation_get_step(ctx, concatoperation, i_step)
    @ccall libproj.proj_concatoperation_get_step(ctx::Ptr{PJ_CONTEXT}, concatoperation::Ptr{PJ}, i_step::Cint)::Ptr{PJ}
end

struct geod_geodesic
    a::Cdouble
    f::Cdouble
    f1::Cdouble
    e2::Cdouble
    ep2::Cdouble
    n::Cdouble
    b::Cdouble
    c2::Cdouble
    etol2::Cdouble
    A3x::NTuple{6, Cdouble}
    C3x::NTuple{15, Cdouble}
    C4x::NTuple{21, Cdouble}
end

struct geod_geodesicline
    lat1::Cdouble
    lon1::Cdouble
    azi1::Cdouble
    a::Cdouble
    f::Cdouble
    salp1::Cdouble
    calp1::Cdouble
    a13::Cdouble
    s13::Cdouble
    b::Cdouble
    c2::Cdouble
    f1::Cdouble
    salp0::Cdouble
    calp0::Cdouble
    k2::Cdouble
    ssig1::Cdouble
    csig1::Cdouble
    dn1::Cdouble
    stau1::Cdouble
    ctau1::Cdouble
    somg1::Cdouble
    comg1::Cdouble
    A1m1::Cdouble
    A2m1::Cdouble
    A3c::Cdouble
    B11::Cdouble
    B21::Cdouble
    B31::Cdouble
    A4::Cdouble
    B41::Cdouble
    C1a::NTuple{7, Cdouble}
    C1pa::NTuple{7, Cdouble}
    C2a::NTuple{7, Cdouble}
    C3a::NTuple{6, Cdouble}
    C4a::NTuple{6, Cdouble}
    caps::Cuint
end

struct geod_polygon
    lat::Cdouble
    lon::Cdouble
    lat0::Cdouble
    lon0::Cdouble
    A::NTuple{2, Cdouble}
    P::NTuple{2, Cdouble}
    polyline::Cint
    crossings::Cint
    num::Cuint
end

function geod_init(g, a, f)
    @ccall libproj.geod_init(g::Ptr{geod_geodesic}, a::Cdouble, f::Cdouble)::Cvoid
end

function geod_direct(g, lat1, lon1, azi1, s12, plat2, plon2, pazi2)
    @ccall libproj.geod_direct(g::Ptr{geod_geodesic}, lat1::Cdouble, lon1::Cdouble, azi1::Cdouble, s12::Cdouble, plat2::Ptr{Cdouble}, plon2::Ptr{Cdouble}, pazi2::Ptr{Cdouble})::Cvoid
end

function geod_gendirect(g, lat1, lon1, azi1, flags, s12_a12, plat2, plon2, pazi2, ps12, pm12, pM12, pM21, pS12)
    @ccall libproj.geod_gendirect(g::Ptr{geod_geodesic}, lat1::Cdouble, lon1::Cdouble, azi1::Cdouble, flags::Cuint, s12_a12::Cdouble, plat2::Ptr{Cdouble}, plon2::Ptr{Cdouble}, pazi2::Ptr{Cdouble}, ps12::Ptr{Cdouble}, pm12::Ptr{Cdouble}, pM12::Ptr{Cdouble}, pM21::Ptr{Cdouble}, pS12::Ptr{Cdouble})::Cdouble
end

function geod_inverse(g, lat1, lon1, lat2, lon2, ps12, pazi1, pazi2)
    @ccall libproj.geod_inverse(g::Ptr{geod_geodesic}, lat1::Cdouble, lon1::Cdouble, lat2::Cdouble, lon2::Cdouble, ps12::Ptr{Cdouble}, pazi1::Ptr{Cdouble}, pazi2::Ptr{Cdouble})::Cvoid
end

function geod_geninverse(g, lat1, lon1, lat2, lon2, ps12, pazi1, pazi2, pm12, pM12, pM21, pS12)
    @ccall libproj.geod_geninverse(g::Ptr{geod_geodesic}, lat1::Cdouble, lon1::Cdouble, lat2::Cdouble, lon2::Cdouble, ps12::Ptr{Cdouble}, pazi1::Ptr{Cdouble}, pazi2::Ptr{Cdouble}, pm12::Ptr{Cdouble}, pM12::Ptr{Cdouble}, pM21::Ptr{Cdouble}, pS12::Ptr{Cdouble})::Cdouble
end

function geod_lineinit(l, g, lat1, lon1, azi1, caps)
    @ccall libproj.geod_lineinit(l::Ptr{geod_geodesicline}, g::Ptr{geod_geodesic}, lat1::Cdouble, lon1::Cdouble, azi1::Cdouble, caps::Cuint)::Cvoid
end

function geod_directline(l, g, lat1, lon1, azi1, s12, caps)
    @ccall libproj.geod_directline(l::Ptr{geod_geodesicline}, g::Ptr{geod_geodesic}, lat1::Cdouble, lon1::Cdouble, azi1::Cdouble, s12::Cdouble, caps::Cuint)::Cvoid
end

function geod_gendirectline(l, g, lat1, lon1, azi1, flags, s12_a12, caps)
    @ccall libproj.geod_gendirectline(l::Ptr{geod_geodesicline}, g::Ptr{geod_geodesic}, lat1::Cdouble, lon1::Cdouble, azi1::Cdouble, flags::Cuint, s12_a12::Cdouble, caps::Cuint)::Cvoid
end

function geod_inverseline(l, g, lat1, lon1, lat2, lon2, caps)
    @ccall libproj.geod_inverseline(l::Ptr{geod_geodesicline}, g::Ptr{geod_geodesic}, lat1::Cdouble, lon1::Cdouble, lat2::Cdouble, lon2::Cdouble, caps::Cuint)::Cvoid
end

function geod_position(l, s12, plat2, plon2, pazi2)
    @ccall libproj.geod_position(l::Ptr{geod_geodesicline}, s12::Cdouble, plat2::Ptr{Cdouble}, plon2::Ptr{Cdouble}, pazi2::Ptr{Cdouble})::Cvoid
end

function geod_genposition(l, flags, s12_a12, plat2, plon2, pazi2, ps12, pm12, pM12, pM21, pS12)
    @ccall libproj.geod_genposition(l::Ptr{geod_geodesicline}, flags::Cuint, s12_a12::Cdouble, plat2::Ptr{Cdouble}, plon2::Ptr{Cdouble}, pazi2::Ptr{Cdouble}, ps12::Ptr{Cdouble}, pm12::Ptr{Cdouble}, pM12::Ptr{Cdouble}, pM21::Ptr{Cdouble}, pS12::Ptr{Cdouble})::Cdouble
end

function geod_setdistance(l, s13)
    @ccall libproj.geod_setdistance(l::Ptr{geod_geodesicline}, s13::Cdouble)::Cvoid
end

function geod_gensetdistance(l, flags, s13_a13)
    @ccall libproj.geod_gensetdistance(l::Ptr{geod_geodesicline}, flags::Cuint, s13_a13::Cdouble)::Cvoid
end

function geod_polygon_init(p, polylinep)
    @ccall libproj.geod_polygon_init(p::Ptr{geod_polygon}, polylinep::Cint)::Cvoid
end

function geod_polygon_clear(p)
    @ccall libproj.geod_polygon_clear(p::Ptr{geod_polygon})::Cvoid
end

function geod_polygon_addpoint(g, p, lat, lon)
    @ccall libproj.geod_polygon_addpoint(g::Ptr{geod_geodesic}, p::Ptr{geod_polygon}, lat::Cdouble, lon::Cdouble)::Cvoid
end

function geod_polygon_addedge(g, p, azi, s)
    @ccall libproj.geod_polygon_addedge(g::Ptr{geod_geodesic}, p::Ptr{geod_polygon}, azi::Cdouble, s::Cdouble)::Cvoid
end

function geod_polygon_compute(g, p, reverse, sign, pA, pP)
    @ccall libproj.geod_polygon_compute(g::Ptr{geod_geodesic}, p::Ptr{geod_polygon}, reverse::Cint, sign::Cint, pA::Ptr{Cdouble}, pP::Ptr{Cdouble})::Cuint
end

function geod_polygon_testpoint(g, p, lat, lon, reverse, sign, pA, pP)
    @ccall libproj.geod_polygon_testpoint(g::Ptr{geod_geodesic}, p::Ptr{geod_polygon}, lat::Cdouble, lon::Cdouble, reverse::Cint, sign::Cint, pA::Ptr{Cdouble}, pP::Ptr{Cdouble})::Cuint
end

function geod_polygon_testedge(g, p, azi, s, reverse, sign, pA, pP)
    @ccall libproj.geod_polygon_testedge(g::Ptr{geod_geodesic}, p::Ptr{geod_polygon}, azi::Cdouble, s::Cdouble, reverse::Cint, sign::Cint, pA::Ptr{Cdouble}, pP::Ptr{Cdouble})::Cuint
end

function geod_polygonarea(g, lats, lons, n, pA, pP)
    @ccall libproj.geod_polygonarea(g::Ptr{geod_geodesic}, lats::Ptr{Cdouble}, lons::Ptr{Cdouble}, n::Cint, pA::Ptr{Cdouble}, pP::Ptr{Cdouble})::Cvoid
end

@cenum geod_mask::UInt32 begin
    GEOD_NONE = 0
    GEOD_LATITUDE = 128
    GEOD_LONGITUDE = 264
    GEOD_AZIMUTH = 512
    GEOD_DISTANCE = 1025
    GEOD_DISTANCE_IN = 2051
    GEOD_REDUCEDLENGTH = 4101
    GEOD_GEODESICSCALE = 8197
    GEOD_AREA = 16400
    GEOD_ALL = 32671
end

@cenum geod_flags::UInt32 begin
    GEOD_NOFLAGS = 0
    GEOD_ARCMODE = 1
    GEOD_LONG_UNROLL = 32768
end

# Skipping MacroDefinition: PROJ_DLL __attribute__ ( ( visibility ( "default" ) ) )

const PROJ_VERSION_MAJOR = 8

const PROJ_VERSION_MINOR = 2

const PROJ_VERSION_PATCH = 0

const PROJ_VERSION_NUMBER = PROJ_COMPUTE_VERSION(PROJ_VERSION_MAJOR, PROJ_VERSION_MINOR, PROJ_VERSION_PATCH)

const PJ_DEFAULT_CTX = 0

const PROJ_ERR_INVALID_OP = 1024

const PROJ_ERR_INVALID_OP_WRONG_SYNTAX = PROJ_ERR_INVALID_OP + 1

const PROJ_ERR_INVALID_OP_MISSING_ARG = PROJ_ERR_INVALID_OP + 2

const PROJ_ERR_INVALID_OP_ILLEGAL_ARG_VALUE = PROJ_ERR_INVALID_OP + 3

const PROJ_ERR_INVALID_OP_MUTUALLY_EXCLUSIVE_ARGS = PROJ_ERR_INVALID_OP + 4

const PROJ_ERR_INVALID_OP_FILE_NOT_FOUND_OR_INVALID = PROJ_ERR_INVALID_OP + 5

const PROJ_ERR_COORD_TRANSFM = 2048

const PROJ_ERR_COORD_TRANSFM_INVALID_COORD = PROJ_ERR_COORD_TRANSFM + 1

const PROJ_ERR_COORD_TRANSFM_OUTSIDE_PROJECTION_DOMAIN = PROJ_ERR_COORD_TRANSFM + 2

const PROJ_ERR_COORD_TRANSFM_NO_OPERATION = PROJ_ERR_COORD_TRANSFM + 3

const PROJ_ERR_COORD_TRANSFM_OUTSIDE_GRID = PROJ_ERR_COORD_TRANSFM + 4

const PROJ_ERR_COORD_TRANSFM_GRID_AT_NODATA = PROJ_ERR_COORD_TRANSFM + 5

const PROJ_ERR_OTHER = 4096

const PROJ_ERR_OTHER_API_MISUSE = PROJ_ERR_OTHER + 1

const PROJ_ERR_OTHER_NO_INVERSE_OP = PROJ_ERR_OTHER + 2

const PROJ_ERR_OTHER_NETWORK_ERROR = PROJ_ERR_OTHER + 3

const GEODESIC_VERSION_MAJOR = 1

const GEODESIC_VERSION_MINOR = 52

const GEODESIC_VERSION_PATCH = 0

const GEODESIC_VERSION = GEODESIC_VERSION_NUM(GEODESIC_VERSION_MAJOR, GEODESIC_VERSION_MINOR, GEODESIC_VERSION_PATCH)

# Skipping MacroDefinition: GEOD_DLL __attribute__ ( ( visibility ( "default" ) ) )

