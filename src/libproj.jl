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
"""Callback to resolve a filename to a full path"""
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

"""
    PROJ_OPEN_ACCESS

Open access / mode

| Enumerator                           | Note                                                                                        |
| :----------------------------------- | :------------------------------------------------------------------------------------------ |
| PROJ\\_OPEN\\_ACCESS\\_READ\\_ONLY   | Read-only access. Equivalent to "rb"                                                        |
| PROJ\\_OPEN\\_ACCESS\\_READ\\_UPDATE | Read-update access. File should be created if not existing. Equivalent to "r+b"             |
| PROJ\\_OPEN\\_ACCESS\\_CREATE        | Create access. File should be truncated to 0-byte if already existing. Equivalent to "w+b"  |
"""
@cenum PROJ_OPEN_ACCESS::UInt32 begin
    PROJ_OPEN_ACCESS_READ_ONLY = 0
    PROJ_OPEN_ACCESS_READ_UPDATE = 1
    PROJ_OPEN_ACCESS_CREATE = 2
end

"""
    PROJ_FILE_API

File API callbacks

| Field        | Note                                                                                          |
| :----------- | :-------------------------------------------------------------------------------------------- |
| version      | Version of this structure. Should be set to 1 currently.                                      |
| open\\_cbk   | Open file. Return NULL if error                                                               |
| read\\_cbk   | Read sizeBytes into buffer from current position and return number of bytes read              |
| write\\_cbk  | Write sizeBytes into buffer from current position and return number of bytes written          |
| seek\\_cbk   | Seek to offset using whence=SEEK\\_SET/SEEK\\_CUR/SEEK\\_END. Return TRUE in case of success  |
| tell\\_cbk   | Return current file position                                                                  |
| close\\_cbk  | Close file                                                                                    |
| exists\\_cbk | Return TRUE if a file exists                                                                  |
| mkdir\\_cbk  | Return TRUE if directory exists or could be created                                           |
| unlink\\_cbk | Return TRUE if file could be removed                                                          |
| rename\\_cbk | Return TRUE if file could be renamed                                                          |
"""
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
"""
Network access: open callback

Should try to read the size\\_to\\_read first bytes at the specified offset of the file given by URL url, and write them to buffer. *out\\_size\\_read should be updated with the actual amount of bytes read (== size\\_to\\_read if the file is larger than size\\_to\\_read). During this read, the implementation should make sure to store the HTTP headers from the server response to be able to respond to [`proj_network_get_header_value_cbk_type`](@ref) callback.

error\\_string\\_max\\_size should be the maximum size that can be written into the out\\_error\\_string buffer (including terminating nul character).

### Returns
a non-NULL opaque handle in case of success.
"""
const proj_network_open_cbk_type = Ptr{Cvoid}

# typedef void ( * proj_network_close_cbk_type ) ( PJ_CONTEXT * ctx , PROJ_NETWORK_HANDLE * handle , void * user_data )
"""Network access: close callback"""
const proj_network_close_cbk_type = Ptr{Cvoid}

# typedef const char * ( * proj_network_get_header_value_cbk_type ) ( PJ_CONTEXT * ctx , PROJ_NETWORK_HANDLE * handle , const char * header_name , void * user_data )
"""Network access: get HTTP headers"""
const proj_network_get_header_value_cbk_type = Ptr{Cvoid}

# typedef size_t ( * proj_network_read_range_type ) ( PJ_CONTEXT * ctx , PROJ_NETWORK_HANDLE * handle , unsigned long long offset , size_t size_to_read , void * buffer , size_t error_string_max_size , char * out_error_string , void * user_data )
"""
Network access: read range

Read size\\_to\\_read bytes from handle, starting at offset, into buffer. During this read, the implementation should make sure to store the HTTP headers from the server response to be able to respond to [`proj_network_get_header_value_cbk_type`](@ref) callback.

error\\_string\\_max\\_size should be the maximum size that can be written into the out\\_error\\_string buffer (including terminating nul character).

### Returns
the number of bytes actually read (0 in case of error)
"""
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

"""
    proj_create(ctx, definition)

Doxygen\\_Suppress
"""
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

"""
    proj_assign_context(pj, ctx)

Doxygen\\_Suppress
"""
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

"""
    proj_coord(x, y, z, t)

Doxygen\\_Suppress
"""
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

"""Type representing a NULL terminated list of NULL-terminate strings."""
const PROJ_STRING_LIST = Ptr{Cstring}

"""
    PJ_GUESSED_WKT_DIALECT

Guessed WKT "dialect".

| Enumerator                 | Note                                             |
| :------------------------- | :----------------------------------------------- |
| PJ\\_GUESSED\\_WKT2\\_2019 | WKT2_2019                                        |
| PJ\\_GUESSED\\_WKT2\\_2018 | Deprecated alias for PJ\\_GUESSED\\_WKT2\\_2019  |
| PJ\\_GUESSED\\_WKT2\\_2015 | WKT2_2015                                        |
| PJ\\_GUESSED\\_WKT1\\_GDAL | WKT1                                             |
| PJ\\_GUESSED\\_WKT1\\_ESRI | ESRI variant of WKT1                             |
| PJ\\_GUESSED\\_NOT\\_WKT   | Not WKT / unrecognized                           |
"""
@cenum PJ_GUESSED_WKT_DIALECT::UInt32 begin
    PJ_GUESSED_WKT2_2019 = 0
    PJ_GUESSED_WKT2_2018 = 0
    PJ_GUESSED_WKT2_2015 = 1
    PJ_GUESSED_WKT1_GDAL = 2
    PJ_GUESSED_WKT1_ESRI = 3
    PJ_GUESSED_NOT_WKT = 4
end

"""
    PJ_CATEGORY

Object category.
"""
@cenum PJ_CATEGORY::UInt32 begin
    PJ_CATEGORY_ELLIPSOID = 0
    PJ_CATEGORY_PRIME_MERIDIAN = 1
    PJ_CATEGORY_DATUM = 2
    PJ_CATEGORY_CRS = 3
    PJ_CATEGORY_COORDINATE_OPERATION = 4
    PJ_CATEGORY_DATUM_ENSEMBLE = 5
end

"""
    PJ_TYPE

Object type.

| Enumerator                                 | Note                                                                                                                                |
| :----------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------- |
| PJ\\_TYPE\\_CRS                            | Abstract type, not returned by [`proj_get_type`](@ref)()                                                                            |
| PJ\\_TYPE\\_GEODETIC\\_CRS                 |                                                                                                                                     |
| PJ\\_TYPE\\_GEOCENTRIC\\_CRS               |                                                                                                                                     |
| PJ\\_TYPE\\_GEOGRAPHIC\\_CRS               | [`proj_get_type`](@ref)() will never return that type, but PJ\\_TYPE\\_GEOGRAPHIC\\_2D\\_CRS or PJ\\_TYPE\\_GEOGRAPHIC\\_3D\\_CRS.  |
| PJ\\_TYPE\\_GEOGRAPHIC\\_2D\\_CRS          |                                                                                                                                     |
| PJ\\_TYPE\\_GEOGRAPHIC\\_3D\\_CRS          |                                                                                                                                     |
| PJ\\_TYPE\\_VERTICAL\\_CRS                 |                                                                                                                                     |
| PJ\\_TYPE\\_PROJECTED\\_CRS                |                                                                                                                                     |
| PJ\\_TYPE\\_COMPOUND\\_CRS                 |                                                                                                                                     |
| PJ\\_TYPE\\_TEMPORAL\\_CRS                 |                                                                                                                                     |
| PJ\\_TYPE\\_ENGINEERING\\_CRS              |                                                                                                                                     |
| PJ\\_TYPE\\_BOUND\\_CRS                    |                                                                                                                                     |
| PJ\\_TYPE\\_OTHER\\_CRS                    |                                                                                                                                     |
| PJ\\_TYPE\\_CONVERSION                     |                                                                                                                                     |
| PJ\\_TYPE\\_TRANSFORMATION                 |                                                                                                                                     |
| PJ\\_TYPE\\_CONCATENATED\\_OPERATION       |                                                                                                                                     |
| PJ\\_TYPE\\_OTHER\\_COORDINATE\\_OPERATION |                                                                                                                                     |
| PJ\\_TYPE\\_TEMPORAL\\_DATUM               |                                                                                                                                     |
| PJ\\_TYPE\\_ENGINEERING\\_DATUM            |                                                                                                                                     |
| PJ\\_TYPE\\_PARAMETRIC\\_DATUM             |                                                                                                                                     |
"""
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

"""
    PJ_COMPARISON_CRITERION

Comparison criterion.

| Enumerator                                               | Note                                                                                                                                                                                                                                                                                        |
| :------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| PJ\\_COMP\\_STRICT                                       | All properties are identical.                                                                                                                                                                                                                                                               |
| PJ\\_COMP\\_EQUIVALENT                                   | The objects are equivalent for the purpose of coordinate operations. They can differ by the name of their objects, identifiers, other metadata. Parameters may be expressed in different units, provided that the value is (with some tolerance) the same once expressed in a common unit.  |
| PJ\\_COMP\\_EQUIVALENT\\_EXCEPT\\_AXIS\\_ORDER\\_GEOGCRS | Same as EQUIVALENT, relaxed with an exception that the axis order of the base CRS of a DerivedCRS/ProjectedCRS or the axis order of a GeographicCRS is ignored. Only to be used with DerivedCRS/ProjectedCRS/GeographicCRS                                                                  |
"""
@cenum PJ_COMPARISON_CRITERION::UInt32 begin
    PJ_COMP_STRICT = 0
    PJ_COMP_EQUIVALENT = 1
    PJ_COMP_EQUIVALENT_EXCEPT_AXIS_ORDER_GEOGCRS = 2
end

"""
    PJ_WKT_TYPE

WKT version.

| Enumerator                    | Note                                                                    |
| :---------------------------- | :---------------------------------------------------------------------- |
| PJ\\_WKT2\\_2015              | cf osgeo::proj::io::WKTFormatter::Convention::WKT2                      |
| PJ\\_WKT2\\_2015\\_SIMPLIFIED | cf osgeo::proj::io::WKTFormatter::Convention::WKT2\\_SIMPLIFIED         |
| PJ\\_WKT2\\_2019              | cf osgeo::proj::io::WKTFormatter::Convention::WKT2\\_2019               |
| PJ\\_WKT2\\_2018              | Deprecated alias for PJ\\_WKT2\\_2019                                   |
| PJ\\_WKT2\\_2019\\_SIMPLIFIED | cf osgeo::proj::io::WKTFormatter::Convention::WKT2\\_2019\\_SIMPLIFIED  |
| PJ\\_WKT2\\_2018\\_SIMPLIFIED | Deprecated alias for PJ\\_WKT2\\_2019                                   |
| PJ\\_WKT1\\_GDAL              | cf osgeo::proj::io::WKTFormatter::Convention::WKT1\\_GDAL               |
| PJ\\_WKT1\\_ESRI              | cf osgeo::proj::io::WKTFormatter::Convention::WKT1\\_ESRI               |
"""
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

"""
    PROJ_CRS_EXTENT_USE

Specify how source and target CRS extent should be used to restrict candidate operations (only taken into account if no explicit area of interest is specified.

| Enumerator                       | Note                                                                           |
| :------------------------------- | :----------------------------------------------------------------------------- |
| PJ\\_CRS\\_EXTENT\\_NONE         | Ignore CRS extent                                                              |
| PJ\\_CRS\\_EXTENT\\_BOTH         | Test coordinate operation extent against both CRS extent.                      |
| PJ\\_CRS\\_EXTENT\\_INTERSECTION | Test coordinate operation extent against the intersection of both CRS extent.  |
| PJ\\_CRS\\_EXTENT\\_SMALLEST     | Test coordinate operation against the smallest of both CRS extent.             |
"""
@cenum PROJ_CRS_EXTENT_USE::UInt32 begin
    PJ_CRS_EXTENT_NONE = 0
    PJ_CRS_EXTENT_BOTH = 1
    PJ_CRS_EXTENT_INTERSECTION = 2
    PJ_CRS_EXTENT_SMALLEST = 3
end

"""
    PROJ_GRID_AVAILABILITY_USE

Describe how grid availability is used.

| Enumerator                                                             | Note                                                                                                                                                                                  |
| :--------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| PROJ\\_GRID\\_AVAILABILITY\\_USED\\_FOR\\_SORTING                      | Grid availability is only used for sorting results. Operations where some grids are missing will be sorted last.                                                                      |
| PROJ\\_GRID\\_AVAILABILITY\\_DISCARD\\_OPERATION\\_IF\\_MISSING\\_GRID | Completely discard an operation if a required grid is missing.                                                                                                                        |
| PROJ\\_GRID\\_AVAILABILITY\\_IGNORED                                   | Ignore grid availability at all. Results will be presented as if all grids were available.                                                                                            |
| PROJ\\_GRID\\_AVAILABILITY\\_KNOWN\\_AVAILABLE                         | Results will be presented as if grids known to PROJ (that is registered in the grid\\_alternatives table of its database) were available. Used typically when networking is enabled.  |
"""
@cenum PROJ_GRID_AVAILABILITY_USE::UInt32 begin
    PROJ_GRID_AVAILABILITY_USED_FOR_SORTING = 0
    PROJ_GRID_AVAILABILITY_DISCARD_OPERATION_IF_MISSING_GRID = 1
    PROJ_GRID_AVAILABILITY_IGNORED = 2
    PROJ_GRID_AVAILABILITY_KNOWN_AVAILABLE = 3
end

"""
    PJ_PROJ_STRING_TYPE

PROJ string version.

| Enumerator    | Note                                                           |
| :------------ | :------------------------------------------------------------- |
| PJ\\_PROJ\\_5 | cf osgeo::proj::io::PROJStringFormatter::Convention::PROJ\\_5  |
| PJ\\_PROJ\\_4 | cf osgeo::proj::io::PROJStringFormatter::Convention::PROJ\\_4  |
"""
@cenum PJ_PROJ_STRING_TYPE::UInt32 begin
    PJ_PROJ_5 = 0
    PJ_PROJ_4 = 1
end

"""
    PROJ_SPATIAL_CRITERION

Spatial criterion to restrict candidate operations.

| Enumerator                                          | Note                                                                                |
| :-------------------------------------------------- | :---------------------------------------------------------------------------------- |
| PROJ\\_SPATIAL\\_CRITERION\\_STRICT\\_CONTAINMENT   | The area of validity of transforms should strictly contain the are of interest.     |
| PROJ\\_SPATIAL\\_CRITERION\\_PARTIAL\\_INTERSECTION | The area of validity of transforms should at least intersect the area of interest.  |
"""
@cenum PROJ_SPATIAL_CRITERION::UInt32 begin
    PROJ_SPATIAL_CRITERION_STRICT_CONTAINMENT = 0
    PROJ_SPATIAL_CRITERION_PARTIAL_INTERSECTION = 1
end

"""
    PROJ_INTERMEDIATE_CRS_USE

Describe if and how intermediate CRS should be used

| Enumerator                                                          | Note                                                                                       |
| :------------------------------------------------------------------ | :----------------------------------------------------------------------------------------- |
| PROJ\\_INTERMEDIATE\\_CRS\\_USE\\_ALWAYS                            | Always search for intermediate CRS.                                                        |
| PROJ\\_INTERMEDIATE\\_CRS\\_USE\\_IF\\_NO\\_DIRECT\\_TRANSFORMATION | Only attempt looking for intermediate CRS if there is no direct transformation available.  |
| PROJ\\_INTERMEDIATE\\_CRS\\_USE\\_NEVER                             |                                                                                            |
"""
@cenum PROJ_INTERMEDIATE_CRS_USE::UInt32 begin
    PROJ_INTERMEDIATE_CRS_USE_ALWAYS = 0
    PROJ_INTERMEDIATE_CRS_USE_IF_NO_DIRECT_TRANSFORMATION = 1
    PROJ_INTERMEDIATE_CRS_USE_NEVER = 2
end

"""
    PJ_COORDINATE_SYSTEM_TYPE

Type of coordinate system.
"""
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

"""
    PROJ_CRS_INFO

Structure given overall description of a CRS.

This structure may grow over time, and should not be directly allocated by client code.

| Field                      | Note                                                                                                                   |
| :------------------------- | :--------------------------------------------------------------------------------------------------------------------- |
| auth\\_name                | Authority name.                                                                                                        |
| code                       | Object code.                                                                                                           |
| name                       | Object name.                                                                                                           |
| type                       | Object type.                                                                                                           |
| deprecated                 | Whether the object is deprecated                                                                                       |
| bbox\\_valid               | Whereas the west\\_lon\\_degree, south\\_lat\\_degree, east\\_lon\\_degree and north\\_lat\\_degree fields are valid.  |
| west\\_lon\\_degree        | Western-most longitude of the area of use, in degrees.                                                                 |
| south\\_lat\\_degree       | Southern-most latitude of the area of use, in degrees.                                                                 |
| east\\_lon\\_degree        | Eastern-most longitude of the area of use, in degrees.                                                                 |
| north\\_lat\\_degree       | Northern-most latitude of the area of use, in degrees.                                                                 |
| area\\_name                | Name of the area of use.                                                                                               |
| projection\\_method\\_name | Name of the projection method for a projected CRS. Might be NULL evenfor projected CRS in some cases.                  |
| celestial\\_body\\_name    | Name of the celestial body of the CRS (e.g. "Earth").  \\since 8.1                                                     |
"""
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

"""
    PROJ_CRS_LIST_PARAMETERS

Structure describing optional parameters for proj\\_get\\_crs\\_list();

This structure may grow over time, and should not be directly allocated by client code.

| Field                                   | Note                                                                                                                                                                                                                                                         |
| :-------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| types                                   | Array of allowed object types. Should be NULL if all types are allowed                                                                                                                                                                                       |
| typesCount                              | Size of types. Should be 0 if all types are allowed                                                                                                                                                                                                          |
| crs\\_area\\_of\\_use\\_contains\\_bbox | If TRUE and bbox\\_valid == TRUE, then only CRS whose area of use entirely contains the specified bounding box will be returned. If FALSE and bbox\\_valid == TRUE, then only CRS whose area of use intersects the specified bounding box will be returned.  |
| bbox\\_valid                            | To set to TRUE so that west\\_lon\\_degree, south\\_lat\\_degree, east\\_lon\\_degree and north\\_lat\\_degree fields are taken into account.                                                                                                                |
| west\\_lon\\_degree                     | Western-most longitude of the area of use, in degrees.                                                                                                                                                                                                       |
| south\\_lat\\_degree                    | Southern-most latitude of the area of use, in degrees.                                                                                                                                                                                                       |
| east\\_lon\\_degree                     | Eastern-most longitude of the area of use, in degrees.                                                                                                                                                                                                       |
| north\\_lat\\_degree                    | Northern-most latitude of the area of use, in degrees.                                                                                                                                                                                                       |
| allow\\_deprecated                      | Whether deprecated objects are allowed. Default to FALSE.                                                                                                                                                                                                    |
| celestial\\_body\\_name                 | Celestial body of the CRS (e.g. "Earth"). The default value, NULL, means no restriction  \\since 8.1                                                                                                                                                         |
"""
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

"""
    PROJ_UNIT_INFO

Structure given description of a unit.

This structure may grow over time, and should not be directly allocated by client code.

\\since 7.1

| Field               | Note                                                                                                                                                                                                       |
| :------------------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| auth\\_name         | Authority name.                                                                                                                                                                                            |
| code                | Object code.                                                                                                                                                                                               |
| name                | Object name. For example "metre", "US survey foot", etc.                                                                                                                                                   |
| category            | Category of the unit: one of "linear", "linear\\_per\\_time", "angular", "angular\\_per\\_time", "scale", "scale\\_per\\_time" or "time"                                                                   |
| conv\\_factor       | Conversion factor to apply to transform from that unit to the corresponding SI unit (metre for "linear", radian for "angular", etc.). It might be 0 in some cases to indicate no known conversion factor.  |
| proj\\_short\\_name | PROJ short name, like "m", "ft", "us-ft", etc... Might be NULL                                                                                                                                             |
| deprecated          | Whether the object is deprecated                                                                                                                                                                           |
"""
struct PROJ_UNIT_INFO
    auth_name::Cstring
    code::Cstring
    name::Cstring
    category::Cstring
    conv_factor::Cdouble
    proj_short_name::Cstring
    deprecated::Cint
end

"""
    PROJ_CELESTIAL_BODY_INFO

Structure given description of a celestial body.

This structure may grow over time, and should not be directly allocated by client code.

\\since 8.1

| Field       | Note                              |
| :---------- | :-------------------------------- |
| auth\\_name | Authority name.                   |
| name        | Object name. For example "Earth"  |
"""
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

"""
    geod_geodesic

The struct containing information about the ellipsoid. This must be initialized by [`geod_init`](@ref)() before use.********************************************************************

| Field | Note                   |
| :---- | :--------------------- |
| a     | the equatorial radius  |
| f     | the flattening  SKIP   |
"""
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

"""
    geod_geodesicline

The struct containing information about a single geodesic. This must be initialized by [`geod_lineinit`](@ref)(), [`geod_directline`](@ref)(), [`geod_gendirectline`](@ref)(), or [`geod_inverseline`](@ref)() before use.********************************************************************

| Field | Note                               |
| :---- | :--------------------------------- |
| lat1  | the starting latitude              |
| lon1  | the starting longitude             |
| azi1  | the starting azimuth               |
| a     | the equatorial radius              |
| f     | the flattening                     |
| salp1 | sine of *azi1*                     |
| calp1 | cosine of *azi1*                   |
| a13   | arc length to reference point      |
| s13   | distance to reference point  SKIP  |
| caps  | the capabilities                   |
"""
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

"""
    geod_polygon

The struct for accumulating information about a geodesic polygon. This is used for computing the perimeter and area of a polygon. This must be initialized by [`geod_polygon_init`](@ref)() before use.********************************************************************

| Field | Note                         |
| :---- | :--------------------------- |
| lat   | the current latitude         |
| lon   | the current longitude  SKIP  |
| num   | the number of points so far  |
"""
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

"""
    geod_init(g, a, f)

Initialize a [`geod_geodesic`](@ref) object.

### Parameters
* `g`:\\[out\\] a pointer to the object to be initialized.
* `a`:\\[in\\] the equatorial radius (meters).
* `f`:\\[in\\] the flattening.********************************************************************
"""
function geod_init(g, a, f)
    @ccall libproj.geod_init(g::Ptr{geod_geodesic}, a::Cdouble, f::Cdouble)::Cvoid
end

"""
    geod_direct(g, lat1, lon1, azi1, s12, plat2, plon2, pazi2)

Solve the direct geodesic problem.

*g* must have been initialized with a call to [`geod_init`](@ref)(). *lat1* should be in the range [−90°, 90°]. The values of *lon2* and *azi2* returned are in the range [−180°, 180°]. Any of the "return" arguments *plat2*, etc., may be replaced by 0, if you do not need some quantities computed.

If either point is at a pole, the azimuth is defined by keeping the longitude fixed, writing *lat* = ±(90° − ε), and taking the limit ε → 0+. An arc length greater that 180° signifies a geodesic which is not a shortest path. (For a prolate ellipsoid, an additional condition is necessary for a shortest path: the longitudinal extent must not exceed of 180°.)

Example, determine the point 10000 km NE of JFK:

```c++
{.c}
   struct geod_geodesic g;
   double lat, lon;
   geod_init(&g, 6378137, 1/298.257223563);
   geod_direct(&g, 40.64, -73.78, 45.0, 10e6, &lat, &lon, 0);
   printf("%.5f %.5f\\n", lat, lon);
```

********************************************************************

### Parameters
* `g`:\\[in\\] a pointer to the [`geod_geodesic`](@ref) object specifying the ellipsoid.
* `lat1`:\\[in\\] latitude of point 1 (degrees).
* `lon1`:\\[in\\] longitude of point 1 (degrees).
* `azi1`:\\[in\\] azimuth at point 1 (degrees).
* `s12`:\\[in\\] distance from point 1 to point 2 (meters); it can be negative.
* `plat2`:\\[out\\] pointer to the latitude of point 2 (degrees).
* `plon2`:\\[out\\] pointer to the longitude of point 2 (degrees).
* `pazi2`:\\[out\\] pointer to the (forward) azimuth at point 2 (degrees).
"""
function geod_direct(g, lat1, lon1, azi1, s12, plat2, plon2, pazi2)
    @ccall libproj.geod_direct(g::Ptr{geod_geodesic}, lat1::Cdouble, lon1::Cdouble, azi1::Cdouble, s12::Cdouble, plat2::Ptr{Cdouble}, plon2::Ptr{Cdouble}, pazi2::Ptr{Cdouble})::Cvoid
end

"""
    geod_gendirect(g, lat1, lon1, azi1, flags, s12_a12, plat2, plon2, pazi2, ps12, pm12, pM12, pM21, pS12)

The general direct geodesic problem.

*g* must have been initialized with a call to [`geod_init`](@ref)(). *lat1* should be in the range [−90°, 90°]. The function value *a12* equals *s12_a12* if *flags* & GEOD\\_ARCMODE. Any of the "return" arguments, *plat2*, etc., may be replaced by 0, if you do not need some quantities computed.

With *flags* & GEOD\\_LONG\\_UNROLL bit set, the longitude is "unrolled" so that the quantity *lon2* − *lon1* indicates how many times and in what sense the geodesic encircles the ellipsoid.********************************************************************

### Parameters
* `g`:\\[in\\] a pointer to the [`geod_geodesic`](@ref) object specifying the ellipsoid.
* `lat1`:\\[in\\] latitude of point 1 (degrees).
* `lon1`:\\[in\\] longitude of point 1 (degrees).
* `azi1`:\\[in\\] azimuth at point 1 (degrees).
* `flags`:\\[in\\] bitor'ed combination of [`geod_flags`](@ref)(); *flags* & GEOD\\_ARCMODE determines the meaning of *s12_a12* and *flags* & GEOD\\_LONG\\_UNROLL "unrolls" *lon2*.
* `s12_a12`:\\[in\\] if *flags* & GEOD\\_ARCMODE is 0, this is the distance from point 1 to point 2 (meters); otherwise it is the arc length from point 1 to point 2 (degrees); it can be negative.
* `plat2`:\\[out\\] pointer to the latitude of point 2 (degrees).
* `plon2`:\\[out\\] pointer to the longitude of point 2 (degrees).
* `pazi2`:\\[out\\] pointer to the (forward) azimuth at point 2 (degrees).
* `ps12`:\\[out\\] pointer to the distance from point 1 to point 2 (meters).
* `pm12`:\\[out\\] pointer to the reduced length of geodesic (meters).
* `pM12`:\\[out\\] pointer to the geodesic scale of point 2 relative to point 1 (dimensionless).
* `pM21`:\\[out\\] pointer to the geodesic scale of point 1 relative to point 2 (dimensionless).
* `pS12`:\\[out\\] pointer to the area under the geodesic (meters<sup>2</sup>).
### Returns
*a12* arc length from point 1 to point 2 (degrees).
"""
function geod_gendirect(g, lat1, lon1, azi1, flags, s12_a12, plat2, plon2, pazi2, ps12, pm12, pM12, pM21, pS12)
    @ccall libproj.geod_gendirect(g::Ptr{geod_geodesic}, lat1::Cdouble, lon1::Cdouble, azi1::Cdouble, flags::Cuint, s12_a12::Cdouble, plat2::Ptr{Cdouble}, plon2::Ptr{Cdouble}, pazi2::Ptr{Cdouble}, ps12::Ptr{Cdouble}, pm12::Ptr{Cdouble}, pM12::Ptr{Cdouble}, pM21::Ptr{Cdouble}, pS12::Ptr{Cdouble})::Cdouble
end

"""
    geod_inverse(g, lat1, lon1, lat2, lon2, ps12, pazi1, pazi2)

Solve the inverse geodesic problem.

*g* must have been initialized with a call to [`geod_init`](@ref)(). *lat1* and *lat2* should be in the range [−90°, 90°]. The values of *azi1* and *azi2* returned are in the range [−180°, 180°]. Any of the "return" arguments, *ps12*, etc., may be replaced by 0, if you do not need some quantities computed.

If either point is at a pole, the azimuth is defined by keeping the longitude fixed, writing *lat* = ±(90° − ε), and taking the limit ε → 0+.

The solution to the inverse problem is found using Newton's method. If this fails to converge (this is very unlikely in geodetic applications but does occur for very eccentric ellipsoids), then the bisection method is used to refine the solution.

Example, determine the distance between JFK and Singapore Changi Airport:

```c++
{.c}
   struct geod_geodesic g;
   double s12;
   geod_init(&g, 6378137, 1/298.257223563);
   geod_inverse(&g, 40.64, -73.78, 1.36, 103.99, &s12, 0, 0);
   printf("%.3f\\n", s12);
```

********************************************************************

### Parameters
* `g`:\\[in\\] a pointer to the [`geod_geodesic`](@ref) object specifying the ellipsoid.
* `lat1`:\\[in\\] latitude of point 1 (degrees).
* `lon1`:\\[in\\] longitude of point 1 (degrees).
* `lat2`:\\[in\\] latitude of point 2 (degrees).
* `lon2`:\\[in\\] longitude of point 2 (degrees).
* `ps12`:\\[out\\] pointer to the distance from point 1 to point 2 (meters).
* `pazi1`:\\[out\\] pointer to the azimuth at point 1 (degrees).
* `pazi2`:\\[out\\] pointer to the (forward) azimuth at point 2 (degrees).
"""
function geod_inverse(g, lat1, lon1, lat2, lon2, ps12, pazi1, pazi2)
    @ccall libproj.geod_inverse(g::Ptr{geod_geodesic}, lat1::Cdouble, lon1::Cdouble, lat2::Cdouble, lon2::Cdouble, ps12::Ptr{Cdouble}, pazi1::Ptr{Cdouble}, pazi2::Ptr{Cdouble})::Cvoid
end

"""
    geod_geninverse(g, lat1, lon1, lat2, lon2, ps12, pazi1, pazi2, pm12, pM12, pM21, pS12)

The general inverse geodesic calculation.

*g* must have been initialized with a call to [`geod_init`](@ref)(). *lat1* and *lat2* should be in the range [−90°, 90°]. Any of the "return" arguments *ps12*, etc., may be replaced by 0, if you do not need some quantities computed.********************************************************************

### Parameters
* `g`:\\[in\\] a pointer to the [`geod_geodesic`](@ref) object specifying the ellipsoid.
* `lat1`:\\[in\\] latitude of point 1 (degrees).
* `lon1`:\\[in\\] longitude of point 1 (degrees).
* `lat2`:\\[in\\] latitude of point 2 (degrees).
* `lon2`:\\[in\\] longitude of point 2 (degrees).
* `ps12`:\\[out\\] pointer to the distance from point 1 to point 2 (meters).
* `pazi1`:\\[out\\] pointer to the azimuth at point 1 (degrees).
* `pazi2`:\\[out\\] pointer to the (forward) azimuth at point 2 (degrees).
* `pm12`:\\[out\\] pointer to the reduced length of geodesic (meters).
* `pM12`:\\[out\\] pointer to the geodesic scale of point 2 relative to point 1 (dimensionless).
* `pM21`:\\[out\\] pointer to the geodesic scale of point 1 relative to point 2 (dimensionless).
* `pS12`:\\[out\\] pointer to the area under the geodesic (meters<sup>2</sup>).
### Returns
*a12* arc length from point 1 to point 2 (degrees).
"""
function geod_geninverse(g, lat1, lon1, lat2, lon2, ps12, pazi1, pazi2, pm12, pM12, pM21, pS12)
    @ccall libproj.geod_geninverse(g::Ptr{geod_geodesic}, lat1::Cdouble, lon1::Cdouble, lat2::Cdouble, lon2::Cdouble, ps12::Ptr{Cdouble}, pazi1::Ptr{Cdouble}, pazi2::Ptr{Cdouble}, pm12::Ptr{Cdouble}, pM12::Ptr{Cdouble}, pM21::Ptr{Cdouble}, pS12::Ptr{Cdouble})::Cdouble
end

"""
    geod_lineinit(l, g, lat1, lon1, azi1, caps)

Initialize a [`geod_geodesicline`](@ref) object.

*g* must have been initialized with a call to [`geod_init`](@ref)(). *lat1* should be in the range [−90°, 90°].

The [`geod_mask`](@ref) values are [see [`geod_mask`](@ref)()]: - *caps* |= GEOD\\_LATITUDE for the latitude *lat2*; this is added automatically, - *caps* |= GEOD\\_LONGITUDE for the latitude *lon2*, - *caps* |= GEOD\\_AZIMUTH for the latitude *azi2*; this is added automatically, - *caps* |= GEOD\\_DISTANCE for the distance *s12*, - *caps* |= GEOD\\_REDUCEDLENGTH for the reduced length *m12*, - *caps* |= GEOD\\_GEODESICSCALE for the geodesic scales *M12* and *M21*, - *caps* |= GEOD\\_AREA for the area *S12*, - *caps* |= GEOD\\_DISTANCE\\_IN permits the length of the geodesic to be given in terms of *s12*; without this capability the length can only be specified in terms of arc length. . A value of *caps* = 0 is treated as GEOD\\_LATITUDE | GEOD\\_LONGITUDE | GEOD\\_AZIMUTH | GEOD\\_DISTANCE\\_IN (to support the solution of the "standard" direct problem).

When initialized by this function, point 3 is undefined (l->s13 = l->a13 = NaN).********************************************************************

### Parameters
* `l`:\\[out\\] a pointer to the object to be initialized.
* `g`:\\[in\\] a pointer to the [`geod_geodesic`](@ref) object specifying the ellipsoid.
* `lat1`:\\[in\\] latitude of point 1 (degrees).
* `lon1`:\\[in\\] longitude of point 1 (degrees).
* `azi1`:\\[in\\] azimuth at point 1 (degrees).
* `caps`:\\[in\\] bitor'ed combination of [`geod_mask`](@ref)() values specifying the capabilities the [`geod_geodesicline`](@ref) object should possess, i.e., which quantities can be returned in calls to [`geod_position`](@ref)() and [`geod_genposition`](@ref)().
"""
function geod_lineinit(l, g, lat1, lon1, azi1, caps)
    @ccall libproj.geod_lineinit(l::Ptr{geod_geodesicline}, g::Ptr{geod_geodesic}, lat1::Cdouble, lon1::Cdouble, azi1::Cdouble, caps::Cuint)::Cvoid
end

"""
    geod_directline(l, g, lat1, lon1, azi1, s12, caps)

Initialize a [`geod_geodesicline`](@ref) object in terms of the direct geodesic problem.

This function sets point 3 of the [`geod_geodesicline`](@ref) to correspond to point 2 of the direct geodesic problem. See [`geod_lineinit`](@ref)() for more information.********************************************************************

### Parameters
* `l`:\\[out\\] a pointer to the object to be initialized.
* `g`:\\[in\\] a pointer to the [`geod_geodesic`](@ref) object specifying the ellipsoid.
* `lat1`:\\[in\\] latitude of point 1 (degrees).
* `lon1`:\\[in\\] longitude of point 1 (degrees).
* `azi1`:\\[in\\] azimuth at point 1 (degrees).
* `s12`:\\[in\\] distance from point 1 to point 2 (meters); it can be negative.
* `caps`:\\[in\\] bitor'ed combination of [`geod_mask`](@ref)() values specifying the capabilities the [`geod_geodesicline`](@ref) object should possess, i.e., which quantities can be returned in calls to [`geod_position`](@ref)() and [`geod_genposition`](@ref)().
"""
function geod_directline(l, g, lat1, lon1, azi1, s12, caps)
    @ccall libproj.geod_directline(l::Ptr{geod_geodesicline}, g::Ptr{geod_geodesic}, lat1::Cdouble, lon1::Cdouble, azi1::Cdouble, s12::Cdouble, caps::Cuint)::Cvoid
end

"""
    geod_gendirectline(l, g, lat1, lon1, azi1, flags, s12_a12, caps)

Initialize a [`geod_geodesicline`](@ref) object in terms of the direct geodesic problem specified in terms of either distance or arc length.

This function sets point 3 of the [`geod_geodesicline`](@ref) to correspond to point 2 of the direct geodesic problem. See [`geod_lineinit`](@ref)() for more information.********************************************************************

### Parameters
* `l`:\\[out\\] a pointer to the object to be initialized.
* `g`:\\[in\\] a pointer to the [`geod_geodesic`](@ref) object specifying the ellipsoid.
* `lat1`:\\[in\\] latitude of point 1 (degrees).
* `lon1`:\\[in\\] longitude of point 1 (degrees).
* `azi1`:\\[in\\] azimuth at point 1 (degrees).
* `flags`:\\[in\\] either GEOD\\_NOFLAGS or GEOD\\_ARCMODE to determining the meaning of the *s12_a12*.
* `s12_a12`:\\[in\\] if *flags* = GEOD\\_NOFLAGS, this is the distance from point 1 to point 2 (meters); if *flags* = GEOD\\_ARCMODE, it is the arc length from point 1 to point 2 (degrees); it can be negative.
* `caps`:\\[in\\] bitor'ed combination of [`geod_mask`](@ref)() values specifying the capabilities the [`geod_geodesicline`](@ref) object should possess, i.e., which quantities can be returned in calls to [`geod_position`](@ref)() and [`geod_genposition`](@ref)().
"""
function geod_gendirectline(l, g, lat1, lon1, azi1, flags, s12_a12, caps)
    @ccall libproj.geod_gendirectline(l::Ptr{geod_geodesicline}, g::Ptr{geod_geodesic}, lat1::Cdouble, lon1::Cdouble, azi1::Cdouble, flags::Cuint, s12_a12::Cdouble, caps::Cuint)::Cvoid
end

"""
    geod_inverseline(l, g, lat1, lon1, lat2, lon2, caps)

Initialize a [`geod_geodesicline`](@ref) object in terms of the inverse geodesic problem.

This function sets point 3 of the [`geod_geodesicline`](@ref) to correspond to point 2 of the inverse geodesic problem. See [`geod_lineinit`](@ref)() for more information.********************************************************************

### Parameters
* `l`:\\[out\\] a pointer to the object to be initialized.
* `g`:\\[in\\] a pointer to the [`geod_geodesic`](@ref) object specifying the ellipsoid.
* `lat1`:\\[in\\] latitude of point 1 (degrees).
* `lon1`:\\[in\\] longitude of point 1 (degrees).
* `lat2`:\\[in\\] latitude of point 2 (degrees).
* `lon2`:\\[in\\] longitude of point 2 (degrees).
* `caps`:\\[in\\] bitor'ed combination of [`geod_mask`](@ref)() values specifying the capabilities the [`geod_geodesicline`](@ref) object should possess, i.e., which quantities can be returned in calls to [`geod_position`](@ref)() and [`geod_genposition`](@ref)().
"""
function geod_inverseline(l, g, lat1, lon1, lat2, lon2, caps)
    @ccall libproj.geod_inverseline(l::Ptr{geod_geodesicline}, g::Ptr{geod_geodesic}, lat1::Cdouble, lon1::Cdouble, lat2::Cdouble, lon2::Cdouble, caps::Cuint)::Cvoid
end

"""
    geod_position(l, s12, plat2, plon2, pazi2)

Compute the position along a [`geod_geodesicline`](@ref).

*l* must have been initialized with a call, e.g., to [`geod_lineinit`](@ref)(), with *caps* |= GEOD\\_DISTANCE\\_IN (or *caps* = 0). The values of *lon2* and *azi2* returned are in the range [−180°, 180°]. Any of the "return" arguments *plat2*, etc., may be replaced by 0, if you do not need some quantities computed.

Example, compute way points between JFK and Singapore Changi Airport the "obvious" way using [`geod_direct`](@ref)():

```c++
{.c}
   struct geod_geodesic g;
   double s12, azi1, lat[101],lon[101];
   int i;
   geod_init(&g, 6378137, 1/298.257223563);
   geod_inverse(&g, 40.64, -73.78, 1.36, 103.99, &s12, &azi1, 0);
   for (i = 0; i < 101; ++i) {
     geod_direct(&g, 40.64, -73.78, azi1, i * s12 * 0.01, lat + i, lon + i, 0);
     printf("%.5f %.5f\\n", lat[i], lon[i]);
   }
```

A faster way using [`geod_position`](@ref)():

```c++
{.c}
   struct geod_geodesic g;
   struct geod_geodesicline l;
   double lat[101],lon[101];
   int i;
   geod_init(&g, 6378137, 1/298.257223563);
   geod_inverseline(&l, &g, 40.64, -73.78, 1.36, 103.99, 0);
   for (i = 0; i <= 100; ++i) {
     geod_position(&l, i * l.s13 * 0.01, lat + i, lon + i, 0);
     printf("%.5f %.5f\\n", lat[i], lon[i]);
   }
```

********************************************************************

### Parameters
* `l`:\\[in\\] a pointer to the [`geod_geodesicline`](@ref) object specifying the geodesic line.
* `s12`:\\[in\\] distance from point 1 to point 2 (meters); it can be negative.
* `plat2`:\\[out\\] pointer to the latitude of point 2 (degrees).
* `plon2`:\\[out\\] pointer to the longitude of point 2 (degrees); requires that *l* was initialized with *caps* |= GEOD\\_LONGITUDE.
* `pazi2`:\\[out\\] pointer to the (forward) azimuth at point 2 (degrees).
"""
function geod_position(l, s12, plat2, plon2, pazi2)
    @ccall libproj.geod_position(l::Ptr{geod_geodesicline}, s12::Cdouble, plat2::Ptr{Cdouble}, plon2::Ptr{Cdouble}, pazi2::Ptr{Cdouble})::Cvoid
end

"""
    geod_genposition(l, flags, s12_a12, plat2, plon2, pazi2, ps12, pm12, pM12, pM21, pS12)

The general position function.

*l* must have been initialized with a call to [`geod_lineinit`](@ref)() with *caps* |= GEOD\\_DISTANCE\\_IN. The value *azi2* returned is in the range [−180°, 180°]. Any of the "return" arguments *plat2*, etc., may be replaced by 0, if you do not need some quantities computed. Requesting a value which *l* is not capable of computing is not an error; the corresponding argument will not be altered.

With *flags* & GEOD\\_LONG\\_UNROLL bit set, the longitude is "unrolled" so that the quantity *lon2* − *lon1* indicates how many times and in what sense the geodesic encircles the ellipsoid.

Example, compute way points between JFK and Singapore Changi Airport using [`geod_genposition`](@ref)(). In this example, the points are evenly space in arc length (and so only approximately equally spaced in distance). This is faster than using [`geod_position`](@ref)() and would be appropriate if drawing the path on a map.

```c++
{.c}
   struct geod_geodesic g;
   struct geod_geodesicline l;
   double lat[101], lon[101];
   int i;
   geod_init(&g, 6378137, 1/298.257223563);
   geod_inverseline(&l, &g, 40.64, -73.78, 1.36, 103.99,
                    GEOD_LATITUDE | GEOD_LONGITUDE);
   for (i = 0; i <= 100; ++i) {
     geod_genposition(&l, GEOD_ARCMODE, i * l.a13 * 0.01,
                      lat + i, lon + i, 0, 0, 0, 0, 0, 0);
     printf("%.5f %.5f\\n", lat[i], lon[i]);
   }
```

********************************************************************

### Parameters
* `l`:\\[in\\] a pointer to the [`geod_geodesicline`](@ref) object specifying the geodesic line.
* `flags`:\\[in\\] bitor'ed combination of [`geod_flags`](@ref)(); *flags* & GEOD\\_ARCMODE determines the meaning of *s12_a12* and *flags* & GEOD\\_LONG\\_UNROLL "unrolls" *lon2*; if *flags* & GEOD\\_ARCMODE is 0, then *l* must have been initialized with *caps* |= GEOD\\_DISTANCE\\_IN.
* `s12_a12`:\\[in\\] if *flags* & GEOD\\_ARCMODE is 0, this is the distance from point 1 to point 2 (meters); otherwise it is the arc length from point 1 to point 2 (degrees); it can be negative.
* `plat2`:\\[out\\] pointer to the latitude of point 2 (degrees).
* `plon2`:\\[out\\] pointer to the longitude of point 2 (degrees); requires that *l* was initialized with *caps* |= GEOD\\_LONGITUDE.
* `pazi2`:\\[out\\] pointer to the (forward) azimuth at point 2 (degrees).
* `ps12`:\\[out\\] pointer to the distance from point 1 to point 2 (meters); requires that *l* was initialized with *caps* |= GEOD\\_DISTANCE.
* `pm12`:\\[out\\] pointer to the reduced length of geodesic (meters); requires that *l* was initialized with *caps* |= GEOD\\_REDUCEDLENGTH.
* `pM12`:\\[out\\] pointer to the geodesic scale of point 2 relative to point 1 (dimensionless); requires that *l* was initialized with *caps* |= GEOD\\_GEODESICSCALE.
* `pM21`:\\[out\\] pointer to the geodesic scale of point 1 relative to point 2 (dimensionless); requires that *l* was initialized with *caps* |= GEOD\\_GEODESICSCALE.
* `pS12`:\\[out\\] pointer to the area under the geodesic (meters<sup>2</sup>); requires that *l* was initialized with *caps* |= GEOD\\_AREA.
### Returns
*a12* arc length from point 1 to point 2 (degrees).
"""
function geod_genposition(l, flags, s12_a12, plat2, plon2, pazi2, ps12, pm12, pM12, pM21, pS12)
    @ccall libproj.geod_genposition(l::Ptr{geod_geodesicline}, flags::Cuint, s12_a12::Cdouble, plat2::Ptr{Cdouble}, plon2::Ptr{Cdouble}, pazi2::Ptr{Cdouble}, ps12::Ptr{Cdouble}, pm12::Ptr{Cdouble}, pM12::Ptr{Cdouble}, pM21::Ptr{Cdouble}, pS12::Ptr{Cdouble})::Cdouble
end

"""
    geod_setdistance(l, s13)

Specify position of point 3 in terms of distance.

This is only useful if the [`geod_geodesicline`](@ref) object has been constructed with *caps* |= GEOD\\_DISTANCE\\_IN.********************************************************************

### Parameters
* `l`:\\[in,out\\] a pointer to the [`geod_geodesicline`](@ref) object.
* `s13`:\\[in\\] the distance from point 1 to point 3 (meters); it can be negative.
"""
function geod_setdistance(l, s13)
    @ccall libproj.geod_setdistance(l::Ptr{geod_geodesicline}, s13::Cdouble)::Cvoid
end

"""
    geod_gensetdistance(l, flags, s13_a13)

Specify position of point 3 in terms of either distance or arc length.

If flags = GEOD\\_NOFLAGS, this calls [`geod_setdistance`](@ref)(). If flags = GEOD\\_ARCMODE, the *s13* is only set if the [`geod_geodesicline`](@ref) object has been constructed with *caps* |= GEOD\\_DISTANCE.********************************************************************

### Parameters
* `l`:\\[in,out\\] a pointer to the [`geod_geodesicline`](@ref) object.
* `flags`:\\[in\\] either GEOD\\_NOFLAGS or GEOD\\_ARCMODE to determining the meaning of the *s13_a13*.
* `s13_a13`:\\[in\\] if *flags* = GEOD\\_NOFLAGS, this is the distance from point 1 to point 3 (meters); if *flags* = GEOD\\_ARCMODE, it is the arc length from point 1 to point 3 (degrees); it can be negative.
"""
function geod_gensetdistance(l, flags, s13_a13)
    @ccall libproj.geod_gensetdistance(l::Ptr{geod_geodesicline}, flags::Cuint, s13_a13::Cdouble)::Cvoid
end

"""
    geod_polygon_init(p, polylinep)

Initialize a [`geod_polygon`](@ref) object.

If *polylinep* is zero, then the sequence of vertices and edges added by [`geod_polygon_addpoint`](@ref)() and [`geod_polygon_addedge`](@ref)() define a polygon and the perimeter and area are returned by [`geod_polygon_compute`](@ref)(). If *polylinep* is non-zero, then the vertices and edges define a polyline and only the perimeter is returned by [`geod_polygon_compute`](@ref)().

The area and perimeter are accumulated at two times the standard floating point precision to guard against the loss of accuracy with many-sided polygons. At any point you can ask for the perimeter and area so far.

An example of the use of this function is given in the documentation for [`geod_polygon_compute`](@ref)().********************************************************************

### Parameters
* `p`:\\[out\\] a pointer to the object to be initialized.
* `polylinep`:\\[in\\] non-zero if a polyline instead of a polygon.
"""
function geod_polygon_init(p, polylinep)
    @ccall libproj.geod_polygon_init(p::Ptr{geod_polygon}, polylinep::Cint)::Cvoid
end

"""
    geod_polygon_clear(p)

Clear the polygon, allowing a new polygon to be started.

### Parameters
* `p`:\\[in,out\\] a pointer to the object to be cleared.********************************************************************
"""
function geod_polygon_clear(p)
    @ccall libproj.geod_polygon_clear(p::Ptr{geod_polygon})::Cvoid
end

"""
    geod_polygon_addpoint(g, p, lat, lon)

Add a point to the polygon or polyline.

*g* and *p* must have been initialized with calls to [`geod_init`](@ref)() and [`geod_polygon_init`](@ref)(), respectively. The same *g* must be used for all the points and edges in a polygon. *lat* should be in the range [−90°, 90°].

An example of the use of this function is given in the documentation for [`geod_polygon_compute`](@ref)().********************************************************************

### Parameters
* `g`:\\[in\\] a pointer to the [`geod_geodesic`](@ref) object specifying the ellipsoid.
* `p`:\\[in,out\\] a pointer to the [`geod_polygon`](@ref) object specifying the polygon.
* `lat`:\\[in\\] the latitude of the point (degrees).
* `lon`:\\[in\\] the longitude of the point (degrees).
"""
function geod_polygon_addpoint(g, p, lat, lon)
    @ccall libproj.geod_polygon_addpoint(g::Ptr{geod_geodesic}, p::Ptr{geod_polygon}, lat::Cdouble, lon::Cdouble)::Cvoid
end

"""
    geod_polygon_addedge(g, p, azi, s)

Add an edge to the polygon or polyline.

*g* and *p* must have been initialized with calls to [`geod_init`](@ref)() and [`geod_polygon_init`](@ref)(), respectively. The same *g* must be used for all the points and edges in a polygon. This does nothing if no points have been added yet. The *lat* and *lon* fields of *p* give the location of the new vertex.********************************************************************

### Parameters
* `g`:\\[in\\] a pointer to the [`geod_geodesic`](@ref) object specifying the ellipsoid.
* `p`:\\[in,out\\] a pointer to the [`geod_polygon`](@ref) object specifying the polygon.
* `azi`:\\[in\\] azimuth at current point (degrees).
* `s`:\\[in\\] distance from current point to next point (meters).
"""
function geod_polygon_addedge(g, p, azi, s)
    @ccall libproj.geod_polygon_addedge(g::Ptr{geod_geodesic}, p::Ptr{geod_polygon}, azi::Cdouble, s::Cdouble)::Cvoid
end

"""
    geod_polygon_compute(g, p, reverse, sign, pA, pP)

Return the results for a polygon.

The area and perimeter are accumulated at two times the standard floating point precision to guard against the loss of accuracy with many-sided polygons. Arbitrarily complex polygons are allowed. In the case of self-intersecting polygons the area is accumulated "algebraically", e.g., the areas of the 2 loops in a figure-8 polygon will partially cancel. There's no need to "close" the polygon by repeating the first vertex. Set *pA* or *pP* to zero, if you do not want the corresponding quantity returned.

More points can be added to the polygon after this call.

Example, compute the perimeter and area of the geodesic triangle with vertices (0°N,0°E), (0°N,90°E), (90°N,0°E).

```c++
{.c}
   double A, P;
   int n;
   struct geod_geodesic g;
   struct geod_polygon p;
   geod_init(&g, 6378137, 1/298.257223563);
   geod_polygon_init(&p, 0);
   geod_polygon_addpoint(&g, &p,  0,  0);
   geod_polygon_addpoint(&g, &p,  0, 90);
   geod_polygon_addpoint(&g, &p, 90,  0);
   n = geod_polygon_compute(&g, &p, 0, 1, &A, &P);
   printf("%d %.8f %.3f\\n", n, P, A);
```

********************************************************************

### Parameters
* `g`:\\[in\\] a pointer to the [`geod_geodesic`](@ref) object specifying the ellipsoid.
* `p`:\\[in\\] a pointer to the [`geod_polygon`](@ref) object specifying the polygon.
* `reverse`:\\[in\\] if non-zero then clockwise (instead of counter-clockwise) traversal counts as a positive area.
* `sign`:\\[in\\] if non-zero then return a signed result for the area if the polygon is traversed in the "wrong" direction instead of returning the area for the rest of the earth.
* `pA`:\\[out\\] pointer to the area of the polygon (meters<sup>2</sup>); only set if *polyline* is non-zero in the call to [`geod_polygon_init`](@ref)().
* `pP`:\\[out\\] pointer to the perimeter of the polygon or length of the polyline (meters).
### Returns
the number of points.
"""
function geod_polygon_compute(g, p, reverse, sign, pA, pP)
    @ccall libproj.geod_polygon_compute(g::Ptr{geod_geodesic}, p::Ptr{geod_polygon}, reverse::Cint, sign::Cint, pA::Ptr{Cdouble}, pP::Ptr{Cdouble})::Cuint
end

"""
    geod_polygon_testpoint(g, p, lat, lon, reverse, sign, pA, pP)

Return the results assuming a tentative final test point is added; however, the data for the test point is not saved. This lets you report a running result for the perimeter and area as the user moves the mouse cursor. Ordinary floating point arithmetic is used to accumulate the data for the test point; thus the area and perimeter returned are less accurate than if [`geod_polygon_addpoint`](@ref)() and [`geod_polygon_compute`](@ref)() are used.

*lat* should be in the range [−90°, 90°].********************************************************************

### Parameters
* `g`:\\[in\\] a pointer to the [`geod_geodesic`](@ref) object specifying the ellipsoid.
* `p`:\\[in\\] a pointer to the [`geod_polygon`](@ref) object specifying the polygon.
* `lat`:\\[in\\] the latitude of the test point (degrees).
* `lon`:\\[in\\] the longitude of the test point (degrees).
* `reverse`:\\[in\\] if non-zero then clockwise (instead of counter-clockwise) traversal counts as a positive area.
* `sign`:\\[in\\] if non-zero then return a signed result for the area if the polygon is traversed in the "wrong" direction instead of returning the area for the rest of the earth.
* `pA`:\\[out\\] pointer to the area of the polygon (meters<sup>2</sup>); only set if *polyline* is non-zero in the call to [`geod_polygon_init`](@ref)().
* `pP`:\\[out\\] pointer to the perimeter of the polygon or length of the polyline (meters).
### Returns
the number of points.
"""
function geod_polygon_testpoint(g, p, lat, lon, reverse, sign, pA, pP)
    @ccall libproj.geod_polygon_testpoint(g::Ptr{geod_geodesic}, p::Ptr{geod_polygon}, lat::Cdouble, lon::Cdouble, reverse::Cint, sign::Cint, pA::Ptr{Cdouble}, pP::Ptr{Cdouble})::Cuint
end

"""
    geod_polygon_testedge(g, p, azi, s, reverse, sign, pA, pP)

Return the results assuming a tentative final test point is added via an azimuth and distance; however, the data for the test point is not saved. This lets you report a running result for the perimeter and area as the user moves the mouse cursor. Ordinary floating point arithmetic is used to accumulate the data for the test point; thus the area and perimeter returned are less accurate than if [`geod_polygon_addedge`](@ref)() and [`geod_polygon_compute`](@ref)() are used.

### Parameters
* `g`:\\[in\\] a pointer to the [`geod_geodesic`](@ref) object specifying the ellipsoid.
* `p`:\\[in\\] a pointer to the [`geod_polygon`](@ref) object specifying the polygon.
* `azi`:\\[in\\] azimuth at current point (degrees).
* `s`:\\[in\\] distance from current point to final test point (meters).
* `reverse`:\\[in\\] if non-zero then clockwise (instead of counter-clockwise) traversal counts as a positive area.
* `sign`:\\[in\\] if non-zero then return a signed result for the area if the polygon is traversed in the "wrong" direction instead of returning the area for the rest of the earth.
* `pA`:\\[out\\] pointer to the area of the polygon (meters<sup>2</sup>); only set if *polyline* is non-zero in the call to [`geod_polygon_init`](@ref)().
* `pP`:\\[out\\] pointer to the perimeter of the polygon or length of the polyline (meters).
### Returns
the number of points.********************************************************************
"""
function geod_polygon_testedge(g, p, azi, s, reverse, sign, pA, pP)
    @ccall libproj.geod_polygon_testedge(g::Ptr{geod_geodesic}, p::Ptr{geod_polygon}, azi::Cdouble, s::Cdouble, reverse::Cint, sign::Cint, pA::Ptr{Cdouble}, pP::Ptr{Cdouble})::Cuint
end

"""
    geod_polygonarea(g, lats, lons, n, pA, pP)

A simple interface for computing the area of a geodesic polygon.

*lats* should be in the range [−90°, 90°].

Arbitrarily complex polygons are allowed. In the case self-intersecting of polygons the area is accumulated "algebraically", e.g., the areas of the 2 loops in a figure-8 polygon will partially cancel. There's no need to "close" the polygon by repeating the first vertex. The area returned is signed with counter-clockwise traversal being treated as positive.

Example, compute the area of Antarctica:

```c++
{.c}
   double
     lats[] = {-72.9, -71.9, -74.9, -74.3, -77.5, -77.4, -71.7, -65.9, -65.7,
               -66.6, -66.9, -69.8, -70.0, -71.0, -77.3, -77.9, -74.7},
     lons[] = {-74, -102, -102, -131, -163, 163, 172, 140, 113,
                88, 59, 25, -4, -14, -33, -46, -61};
   struct geod_geodesic g;
   double A, P;
   geod_init(&g, 6378137, 1/298.257223563);
   geod_polygonarea(&g, lats, lons, (sizeof lats) / (sizeof lats[0]), &A, &P);
   printf("%.0f %.2f\\n", A, P);
```

********************************************************************

### Parameters
* `g`:\\[in\\] a pointer to the [`geod_geodesic`](@ref) object specifying the ellipsoid.
* `lats`:\\[in\\] an array of latitudes of the polygon vertices (degrees).
* `lons`:\\[in\\] an array of longitudes of the polygon vertices (degrees).
* `n`:\\[in\\] the number of vertices.
* `pA`:\\[out\\] pointer to the area of the polygon (meters<sup>2</sup>).
* `pP`:\\[out\\] pointer to the perimeter of the polygon (meters).
"""
function geod_polygonarea(g, lats, lons, n, pA, pP)
    @ccall libproj.geod_polygonarea(g::Ptr{geod_geodesic}, lats::Ptr{Cdouble}, lons::Ptr{Cdouble}, n::Cint, pA::Ptr{Cdouble}, pP::Ptr{Cdouble})::Cvoid
end

"""
    geod_mask

mask values for the *caps* argument to [`geod_lineinit`](@ref)().********************************************************************

| Enumerator           | Note                      |
| :------------------- | :------------------------ |
| GEOD\\_NONE          | Calculate nothing         |
| GEOD\\_LATITUDE      | Calculate latitude        |
| GEOD\\_LONGITUDE     | Calculate longitude       |
| GEOD\\_AZIMUTH       | Calculate azimuth         |
| GEOD\\_DISTANCE      | Calculate distance        |
| GEOD\\_DISTANCE\\_IN | Allow distance as input   |
| GEOD\\_REDUCEDLENGTH | Calculate reduced length  |
| GEOD\\_GEODESICSCALE | Calculate geodesic scale  |
| GEOD\\_AREA          | Calculate reduced length  |
| GEOD\\_ALL           | Calculate everything      |
"""
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

"""
    geod_flags

flag values for the *flags* argument to [`geod_gendirect`](@ref)() and [`geod_genposition`](@ref)()********************************************************************

| Enumerator           | Note                                     |
| :------------------- | :--------------------------------------- |
| GEOD\\_NOFLAGS       | No flags                                 |
| GEOD\\_ARCMODE       | Position given in terms of arc distance  |
| GEOD\\_LONG\\_UNROLL | Unroll the longitude                     |
"""
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

