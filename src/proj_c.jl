# Julia wrapper for header: proj.h
# Automatically generated using Clang.jl


function proj_context_create()
    ccall((:proj_context_create, libproj), Ptr{PJ_CONTEXT}, ())
end

function proj_context_destroy(ctx = C_NULL)
    ccall((:proj_context_destroy, libproj), Ptr{PJ_CONTEXT}, (Ptr{PJ_CONTEXT},), ctx)
end

function proj_context_set_file_finder(finder, user_data, ctx = C_NULL)
    ccall((:proj_context_set_file_finder, libproj), Cvoid, (Ptr{PJ_CONTEXT}, proj_file_finder, Ptr{Cvoid}), ctx, finder, user_data)
end

function proj_context_set_search_paths(count_paths, paths, ctx = C_NULL)
    ccall((:proj_context_set_search_paths, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Cint, Ptr{Cstring}), ctx, count_paths, paths)
end

function proj_context_use_proj4_init_rules(enable, ctx = C_NULL)
    ccall((:proj_context_use_proj4_init_rules, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Cint), ctx, enable)
end

function proj_context_get_use_proj4_init_rules(from_legacy_code_path, ctx = C_NULL)
    ccall((:proj_context_get_use_proj4_init_rules, libproj), Cint, (Ptr{PJ_CONTEXT}, Cint), ctx, from_legacy_code_path)
end

"""
    proj_create(const char * text,
                PJ_CONTEXT * ctx) -> PJ *

Instantiate an object from a WKT string, PROJ string or object code (like "EPSG:4326", "urn:ogc:def:crs:EPSG::4326", "urn:ogc:def:coordinateOperation:EPSG::1671").

### Parameters
* **text**: String (must not be NULL)
* **ctx**: PROJ context, or NULL for default context

### Returns
Object that must be unreferenced with proj_destroy(), or NULL in case of error.
"""
function proj_create(definition, ctx = C_NULL)
    ccall((:proj_create, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Cstring), ctx, definition)
end

function proj_create_argv(argc, argv, ctx = C_NULL)
    ccall((:proj_create_argv, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Cint, Ptr{Cstring}), ctx, argc, argv)
end

function proj_create_crs_to_crs(source_crs, target_crs, area = C_NULL, ctx = C_NULL)
    ccall((:proj_create_crs_to_crs, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Cstring, Cstring, Ptr{PJ_AREA}), ctx, source_crs, target_crs, area)
end

"""
    proj_normalize_for_visualization(const PJ * obj,
                                     PJ_CONTEXT * ctx) -> PJ *

Returns a PJ* object whose axis order is the one expected for visualization purposes.

### Parameters
* **obj**: Object of type CoordinateOperation, created with proj_create_crs_to_crs() (must not be NULL)
* **ctx**: PROJ context, or NULL for default context

### Returns
a new PJ* object to free with proj_destroy() in case of success, or nullptr in case of error
"""
function proj_normalize_for_visualization(obj, ctx = C_NULL)
    ccall((:proj_normalize_for_visualization, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, obj)
end

function proj_destroy(P)
    ccall((:proj_destroy, libproj), Ptr{PJ}, (Ptr{PJ},), P)
end

function proj_area_create()
    ccall((:proj_area_create, libproj), Ptr{PJ_AREA}, ())
end

function proj_area_set_bbox(area, west_lon_degree, south_lat_degree, east_lon_degree, north_lat_degree)
    ccall((:proj_area_set_bbox, libproj), Cvoid, (Ptr{PJ_AREA}, Cdouble, Cdouble, Cdouble, Cdouble), area, west_lon_degree, south_lat_degree, east_lon_degree, north_lat_degree)
end

function proj_area_destroy(area)
    ccall((:proj_area_destroy, libproj), Cvoid, (Ptr{PJ_AREA},), area)
end

function proj_angular_input(P, dir)
    ccall((:proj_angular_input, libproj), Cint, (Ptr{PJ}, PJ_DIRECTION), P, dir)
end

function proj_angular_output(P, dir)
    ccall((:proj_angular_output, libproj), Cint, (Ptr{PJ}, PJ_DIRECTION), P, dir)
end

function proj_trans(P, direction, coord)
    ccall((:proj_trans, libproj), PJ_COORD, (Ptr{PJ}, PJ_DIRECTION, PJ_COORD), P, direction, coord)
end

function proj_trans_array(P, direction, n, coord)
    ccall((:proj_trans_array, libproj), Cint, (Ptr{PJ}, PJ_DIRECTION, Csize_t, Ptr{PJ_COORD}), P, direction, n, coord)
end

function proj_trans_generic(P, direction, x, sx, nx, y, sy, ny, z, sz, nz, t, st, nt)
    ccall((:proj_trans_generic, libproj), Csize_t, (Ptr{PJ}, PJ_DIRECTION, Ptr{Cdouble}, Csize_t, Csize_t, Ptr{Cdouble}, Csize_t, Csize_t, Ptr{Cdouble}, Csize_t, Csize_t, Ptr{Cdouble}, Csize_t, Csize_t), P, direction, x, sx, nx, y, sy, ny, z, sz, nz, t, st, nt)
end

function proj_coord(x, y, z, t)
    ccall((:proj_coord, libproj), PJ_COORD, (Cdouble, Cdouble, Cdouble, Cdouble), x, y, z, t)
end

function proj_roundtrip(P, direction, n, coord)
    ccall((:proj_roundtrip, libproj), Cdouble, (Ptr{PJ}, PJ_DIRECTION, Cint, Ptr{PJ_COORD}), P, direction, n, coord)
end

function proj_lp_dist(P, a, b)
    ccall((:proj_lp_dist, libproj), Cdouble, (Ptr{PJ}, PJ_COORD, PJ_COORD), P, a, b)
end

function proj_lpz_dist(P, a, b)
    ccall((:proj_lpz_dist, libproj), Cdouble, (Ptr{PJ}, PJ_COORD, PJ_COORD), P, a, b)
end

function proj_xy_dist(a, b)
    ccall((:proj_xy_dist, libproj), Cdouble, (PJ_COORD, PJ_COORD), a, b)
end

function proj_xyz_dist(a, b)
    ccall((:proj_xyz_dist, libproj), Cdouble, (PJ_COORD, PJ_COORD), a, b)
end

function proj_geod(P, a, b)
    ccall((:proj_geod, libproj), PJ_COORD, (Ptr{PJ}, PJ_COORD, PJ_COORD), P, a, b)
end

function proj_context_errno(ctx = C_NULL)
    ccall((:proj_context_errno, libproj), Cint, (Ptr{PJ_CONTEXT},), ctx)
end

function proj_errno(P)
    ccall((:proj_errno, libproj), Cint, (Ptr{PJ},), P)
end

function proj_errno_set(P, err)
    ccall((:proj_errno_set, libproj), Cint, (Ptr{PJ}, Cint), P, err)
end

function proj_errno_reset(P)
    ccall((:proj_errno_reset, libproj), Cint, (Ptr{PJ},), P)
end

function proj_errno_restore(P, err)
    ccall((:proj_errno_restore, libproj), Cint, (Ptr{PJ}, Cint), P, err)
end

function proj_errno_string(err)
    aftercare(ccall((:proj_errno_string, libproj), Cstring, (Cint,), err))
end

function proj_log_level(log_level, ctx = C_NULL)
    ccall((:proj_log_level, libproj), PJ_LOG_LEVEL, (Ptr{PJ_CONTEXT}, PJ_LOG_LEVEL), ctx, log_level)
end

function proj_log_func(app_data, logf, ctx = C_NULL)
    ccall((:proj_log_func, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Ptr{Cvoid}, PJ_LOG_FUNCTION), ctx, app_data, logf)
end

function proj_factors(P, lp)
    ccall((:proj_factors, libproj), PJ_FACTORS, (Ptr{PJ}, PJ_COORD), P, lp)
end

function proj_info()
    ccall((:proj_info, libproj), PJ_INFO, ())
end

function proj_pj_info(P)
    ccall((:proj_pj_info, libproj), PJ_PROJ_INFO, (Ptr{PJ},), P)
end

function proj_grid_info(gridname)
    ccall((:proj_grid_info, libproj), PJ_GRID_INFO, (Cstring,), gridname)
end

function proj_init_info(initname)
    ccall((:proj_init_info, libproj), PJ_INIT_INFO, (Cstring,), initname)
end

function proj_list_operations()
    ccall((:proj_list_operations, libproj), Ptr{PJ_OPERATIONS}, ())
end

function proj_list_ellps()
    ccall((:proj_list_ellps, libproj), Ptr{PJ_ELLPS}, ())
end

function proj_list_units()
    ccall((:proj_list_units, libproj), Ptr{PJ_UNITS}, ())
end

function proj_list_angular_units()
    ccall((:proj_list_angular_units, libproj), Ptr{PJ_UNITS}, ())
end

function proj_list_prime_meridians()
    ccall((:proj_list_prime_meridians, libproj), Ptr{PJ_PRIME_MERIDIANS}, ())
end

function proj_torad(angle_in_degrees)
    ccall((:proj_torad, libproj), Cdouble, (Cdouble,), angle_in_degrees)
end

function proj_todeg(angle_in_radians)
    ccall((:proj_todeg, libproj), Cdouble, (Cdouble,), angle_in_radians)
end

function proj_dmstor(is, rs)
    ccall((:proj_dmstor, libproj), Cdouble, (Cstring, Ptr{Cstring}), is, rs)
end

function proj_rtodms(s, r, pos, neg)
    aftercare(ccall((:proj_rtodms, libproj), Cstring, (Cstring, Cdouble, Cint, Cint), s, r, pos, neg))
end

"""
    proj_string_list_destroy(PROJ_STRING_LIST list) -> void
"""
function proj_string_list_destroy(list)
    ccall((:proj_string_list_destroy, libproj), Cvoid, (PROJ_STRING_LIST,), list)
end

"""
    proj_context_set_database_path(const char * dbPath,
                                   const char *const * auxDbPaths,
                                   PJ_CONTEXT * ctx,
                                   const char *const * options) -> int

Explicitly point to the main PROJ CRS and coordinate operation definition database ("proj.db"), and potentially auxiliary databases with same structure.

### Parameters
* **dbPath**: Path to main database, or NULL for default.
* **auxDbPaths**: NULL-terminated list of auxiliary database filenames, or NULL.
* **ctx**: PROJ context, or NULL for default context
* **options**: should be set to NULL for now

### Returns
TRUE in case of success
"""
function proj_context_set_database_path(dbPath, auxDbPaths, ctx = C_NULL, options = C_NULL)
    ccall((:proj_context_set_database_path, libproj), Cint, (Ptr{PJ_CONTEXT}, Cstring, Ptr{Cstring}, Ptr{Cstring}), ctx, dbPath, auxDbPaths, options)
end

"""
    proj_context_get_database_path(PJ_CONTEXT * ctx) -> const char *

Returns the path to the database.

### Parameters
* **ctx**: PROJ context, or NULL for default context

### Returns
path, or nullptr
"""
function proj_context_get_database_path(ctx = C_NULL)
    aftercare(ccall((:proj_context_get_database_path, libproj), Cstring, (Ptr{PJ_CONTEXT},), ctx))
end

"""
    proj_context_get_database_metadata(const char * key,
                                       PJ_CONTEXT * ctx) -> const char *

Return a metadata from the database.

### Parameters
* **key**: Metadata key. Must not be NULL
* **ctx**: PROJ context, or NULL for default context

### Returns
value, or nullptr
"""
function proj_context_get_database_metadata(key, ctx = C_NULL)
    aftercare(ccall((:proj_context_get_database_metadata, libproj), Cstring, (Ptr{PJ_CONTEXT}, Cstring), ctx, key))
end

"""
    proj_context_guess_wkt_dialect(const char * wkt,
                                   PJ_CONTEXT * ctx) -> PJ_GUESSED_WKT_DIALECT

Guess the "dialect" of the WKT string.

### Parameters
* **wkt**: String (must not be NULL)
* **ctx**: PROJ context, or NULL for default context
"""
function proj_context_guess_wkt_dialect(wkt, ctx = C_NULL)
    ccall((:proj_context_guess_wkt_dialect, libproj), PJ_GUESSED_WKT_DIALECT, (Ptr{PJ_CONTEXT}, Cstring), ctx, wkt)
end

"""
    proj_create_from_wkt(const char * wkt,
                         PJ_CONTEXT * ctx,
                         const char *const * options,
                         PROJ_STRING_LIST * out_warnings,
                         PROJ_STRING_LIST * out_grammar_errors) -> PJ *

Instantiate an object from a WKT string.

### Parameters
* **wkt**: WKT string (must not be NULL)
* **ctx**: PROJ context, or NULL for default context
* **options**: null-terminated list of options, or NULL. Currently supported options are: 

STRICT=YES/NO. Defaults to NO. When set to YES, strict validation will be enabled.
* **out_warnings**: Pointer to a PROJ_STRING_LIST object, or NULL. If provided, *out_warnings will contain a list of warnings, typically for non recognized projection method or parameters. It must be freed with proj_string_list_destroy().
* **out_grammar_errors**: Pointer to a PROJ_STRING_LIST object, or NULL. If provided, *out_grammar_errors will contain a list of errors regarding the WKT grammaer. It must be freed with proj_string_list_destroy().

### Returns
Object that must be unreferenced with proj_destroy(), or NULL in case of error.
"""
function proj_create_from_wkt(wkt, ctx = C_NULL, options = C_NULL, out_warnings = C_NULL, out_grammar_errors = C_NULL)
    ccall((:proj_create_from_wkt, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Cstring, Ptr{Cstring}, Ptr{PROJ_STRING_LIST}, Ptr{PROJ_STRING_LIST}), ctx, wkt, options, out_warnings, out_grammar_errors)
end

"""
    proj_create_from_database(const char * auth_name,
                              const char * code,
                              PJ_CATEGORY category,
                              int usePROJAlternativeGridNames,
                              PJ_CONTEXT * ctx,
                              const char *const * options) -> PJ *

Instantiate an object from a database lookup.

### Parameters
* **auth_name**: Authority name (must not be NULL)
* **code**: Object code (must not be NULL)
* **category**: Object category
* **usePROJAlternativeGridNames**: Whether PROJ alternative grid names should be substituted to the official grid names. Only used on transformations
* **ctx**: Context, or NULL for default context.
* **options**: should be set to NULL for now

### Returns
Object that must be unreferenced with proj_destroy(), or NULL in case of error.
"""
function proj_create_from_database(auth_name, code, category, usePROJAlternativeGridNames, ctx = C_NULL, options = C_NULL)
    ccall((:proj_create_from_database, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Cstring, Cstring, PJ_CATEGORY, Cint, Ptr{Cstring}), ctx, auth_name, code, category, usePROJAlternativeGridNames, options)
end

"""
    proj_uom_get_info_from_database(const char * auth_name,
                                    const char * code,
                                    const char ** out_name,
                                    double * out_conv_factor,
                                    const char ** out_category,
                                    PJ_CONTEXT * ctx) -> int

Get information for a unit of measure from a database lookup.

### Parameters
* **auth_name**: Authority name (must not be NULL)
* **code**: Unit of measure code (must not be NULL)
* **out_name**: Pointer to a string value to store the parameter name. or NULL. This value remains valid until the next call to proj_uom_get_info_from_database() or the context destruction.
* **out_conv_factor**: Pointer to a value to store the conversion factor of the prime meridian longitude unit to radian. or NULL
* **out_category**: Pointer to a string value to store the parameter name. or NULL. This value might be "unknown", "none", "linear", "angular", "scale", "time" or "parametric";
* **ctx**: Context, or NULL for default context.

### Returns
TRUE in case of success
"""
function proj_uom_get_info_from_database(auth_name, code, out_name, out_conv_factor, out_category, ctx = C_NULL)
    ccall((:proj_uom_get_info_from_database, libproj), Cint, (Ptr{PJ_CONTEXT}, Cstring, Cstring, Ptr{Cstring}, Ptr{Cdouble}, Ptr{Cstring}), ctx, auth_name, code, out_name, out_conv_factor, out_category)
end

"""
    proj_clone(const PJ * obj,
               PJ_CONTEXT * ctx) -> PJ *

"Clone" an object.

### Parameters
* **obj**: Object to clone. Must not be NULL.
* **ctx**: PROJ context, or NULL for default context

### Returns
Object that must be unreferenced with proj_destroy(), or NULL in case of error.
"""
function proj_clone(obj, ctx = C_NULL)
    ccall((:proj_clone, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, obj)
end

"""
    proj_create_from_name(const char * auth_name,
                          const char * searchedName,
                          const PJ_TYPE * types,
                          size_t typesCount,
                          int approximateMatch,
                          size_t limitResultCount,
                          PJ_CONTEXT * ctx,
                          const char *const * options) -> PJ_OBJ_LIST *

Return a list of objects by their name.

### Parameters
* **auth_name**: Authority name, used to restrict the search. Or NULL for all authorities.
* **searchedName**: Searched name. Must be at least 2 character long.
* **types**: List of object types into which to search. If NULL, all object types will be searched.
* **typesCount**: Number of elements in types, or 0 if types is NULL
* **approximateMatch**: Whether approximate name identification is allowed.
* **limitResultCount**: Maximum number of results to return. Or 0 for unlimited.
* **ctx**: Context, or NULL for default context.
* **options**: should be set to NULL for now

### Returns
a result set that must be unreferenced with proj_list_destroy(), or NULL in case of error.
"""
function proj_create_from_name(auth_name, searchedName, types, typesCount, approximateMatch, limitResultCount, ctx = C_NULL, options = C_NULL)
    ccall((:proj_create_from_name, libproj), Ptr{PJ_OBJ_LIST}, (Ptr{PJ_CONTEXT}, Cstring, Cstring, Ptr{PJ_TYPE}, Csize_t, Cint, Csize_t, Ptr{Cstring}), ctx, auth_name, searchedName, types, typesCount, approximateMatch, limitResultCount, options)
end

"""
    proj_get_type(const PJ * obj) -> PJ_TYPE

Return the type of an object.

### Parameters
* **obj**: Object (must not be NULL)

### Returns
its type.
"""
function proj_get_type(obj)
    ccall((:proj_get_type, libproj), PJ_TYPE, (Ptr{PJ},), obj)
end

"""
    proj_is_deprecated(const PJ * obj) -> int

Return whether an object is deprecated.

### Parameters
* **obj**: Object (must not be NULL)

### Returns
TRUE if it is deprecated, FALSE otherwise
"""
function proj_is_deprecated(obj)
    ccall((:proj_is_deprecated, libproj), Cint, (Ptr{PJ},), obj)
end

"""
    proj_get_non_deprecated(const PJ * obj,
                            PJ_CONTEXT * ctx) -> PJ_OBJ_LIST *

Return a list of non-deprecated objects related to the passed one.

### Parameters
* **obj**: Object (of type CRS for now) for which non-deprecated objects must be searched. Must not be NULL
* **ctx**: Context, or NULL for default context.

### Returns
a result set that must be unreferenced with proj_list_destroy(), or NULL in case of error.
"""
function proj_get_non_deprecated(obj, ctx = C_NULL)
    ccall((:proj_get_non_deprecated, libproj), Ptr{PJ_OBJ_LIST}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, obj)
end

"""
    proj_is_equivalent_to(const PJ * obj,
                          const PJ * other,
                          PJ_COMPARISON_CRITERION criterion) -> int

Return whether two objects are equivalent.

### Parameters
* **obj**: Object (must not be NULL)
* **other**: Other object (must not be NULL)
* **criterion**: Comparison criterion

### Returns
TRUE if they are equivalent
"""
function proj_is_equivalent_to(obj, other, criterion)
    ccall((:proj_is_equivalent_to, libproj), Cint, (Ptr{PJ}, Ptr{PJ}, PJ_COMPARISON_CRITERION), obj, other, criterion)
end

"""
    proj_is_crs(const PJ * obj) -> int

Return whether an object is a CRS.

### Parameters
* **obj**: Object (must not be NULL)
"""
function proj_is_crs(obj)
    ccall((:proj_is_crs, libproj), Cint, (Ptr{PJ},), obj)
end

"""
    proj_get_name(const PJ * obj) -> const char *

Get the name of an object.

### Parameters
* **obj**: Object (must not be NULL)

### Returns
a string, or NULL in case of error or missing name.
"""
function proj_get_name(obj)
    aftercare(ccall((:proj_get_name, libproj), Cstring, (Ptr{PJ},), obj))
end

"""
    proj_get_id_auth_name(const PJ * obj,
                          int index) -> const char *

Get the authority name / codespace of an identifier of an object.

### Parameters
* **obj**: Object (must not be NULL)
* **index**: Index of the identifier. 0 = first identifier

### Returns
a string, or NULL in case of error or missing name.
"""
function proj_get_id_auth_name(obj, index)
    aftercare(ccall((:proj_get_id_auth_name, libproj), Cstring, (Ptr{PJ}, Cint), obj, index))
end

"""
    proj_get_id_code(const PJ * obj,
                     int index) -> const char *

Get the code of an identifier of an object.

### Parameters
* **obj**: Object (must not be NULL)
* **index**: Index of the identifier. 0 = first identifier

### Returns
a string, or NULL in case of error or missing name.
"""
function proj_get_id_code(obj, index)
    aftercare(ccall((:proj_get_id_code, libproj), Cstring, (Ptr{PJ}, Cint), obj, index))
end

"""
    proj_get_area_of_use(const PJ * obj,
                         double * out_west_lon_degree,
                         double * out_south_lat_degree,
                         double * out_east_lon_degree,
                         double * out_north_lat_degree,
                         const char ** out_area_name,
                         PJ_CONTEXT * ctx) -> int

Return the area of use of an object.

### Parameters
* **obj**: Object (must not be NULL)
* **out_west_lon_degree**: Pointer to a double to receive the west longitude (in degrees). Or NULL. If the returned value is -1000, the bounding box is unknown.
* **out_south_lat_degree**: Pointer to a double to receive the south latitude (in degrees). Or NULL. If the returned value is -1000, the bounding box is unknown.
* **out_east_lon_degree**: Pointer to a double to receive the east longitude (in degrees). Or NULL. If the returned value is -1000, the bounding box is unknown.
* **out_north_lat_degree**: Pointer to a double to receive the north latitude (in degrees). Or NULL. If the returned value is -1000, the bounding box is unknown.
* **out_area_name**: Pointer to a string to receive the name of the area of use. Or NULL. *p_area_name is valid while obj is valid itself.
* **ctx**: PROJ context, or NULL for default context

### Returns
TRUE in case of success, FALSE in case of error or if the area of use is unknown.
"""
function proj_get_area_of_use(obj, out_west_lon_degree, out_south_lat_degree, out_east_lon_degree, out_north_lat_degree, out_area_name, ctx = C_NULL)
    ccall((:proj_get_area_of_use, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cstring}), ctx, obj, out_west_lon_degree, out_south_lat_degree, out_east_lon_degree, out_north_lat_degree, out_area_name)
end

"""
    proj_as_wkt(const PJ * obj,
                PJ_WKT_TYPE type,
                PJ_CONTEXT * ctx,
                const char *const * options) -> const char *

Get a WKT representation of an object.

### Parameters
* **obj**: Object (must not be NULL)
* **type**: WKT version.
* **ctx**: PROJ context, or NULL for default context
* **options**: null-terminated list of options, or NULL. Currently supported options are: 

MULTILINE=YES/NO. Defaults to YES, except for WKT1_ESRI 


INDENTATION_WIDTH=number. Defauls to 4 (when multiline output is on). 


OUTPUT_AXIS=AUTO/YES/NO. In AUTO mode, axis will be output for WKT2 variants, for WKT1_GDAL for ProjectedCRS with easting/northing ordering (otherwise stripped), but not for WKT1_ESRI. Setting to YES will output them unconditionally, and to NO will omit them unconditionally.

### Returns
a string, or NULL in case of error.
"""
function proj_as_wkt(obj, type, ctx = C_NULL, options = C_NULL)
    aftercare(ccall((:proj_as_wkt, libproj), Cstring, (Ptr{PJ_CONTEXT}, Ptr{PJ}, PJ_WKT_TYPE, Ptr{Cstring}), ctx, obj, type, options))
end

"""
    proj_as_proj_string(const PJ * obj,
                        PJ_PROJ_STRING_TYPE type,
                        PJ_CONTEXT * ctx,
                        const char *const * options) -> const char *

Get a PROJ string representation of an object.

### Parameters
* **obj**: Object (must not be NULL)
* **type**: PROJ String version.
* **ctx**: PROJ context, or NULL for default context
* **options**: NULL-terminated list of strings with "KEY=VALUE" format. or NULL. The currently recognized option is USE_APPROX_TMERC=YES to add the +approx flag to +proj=tmerc or +proj=utm

### Returns
a string, or NULL in case of error.
"""
function proj_as_proj_string(obj, type, ctx = C_NULL, options = C_NULL)
    aftercare(ccall((:proj_as_proj_string, libproj), Cstring, (Ptr{PJ_CONTEXT}, Ptr{PJ}, PJ_PROJ_STRING_TYPE, Ptr{Cstring}), ctx, obj, type, options))
end

"""
    proj_get_source_crs(const PJ * obj,
                        PJ_CONTEXT * ctx) -> PJ *

Return the base CRS of a BoundCRS or a DerivedCRS/ProjectedCRS, or the source CRS of a CoordinateOperation.

### Parameters
* **obj**: Object of type BoundCRS or CoordinateOperation (must not be NULL)
* **ctx**: PROJ context, or NULL for default context

### Returns
Object that must be unreferenced with proj_destroy(), or NULL in case of error, or missing source CRS.
"""
function proj_get_source_crs(obj, ctx = C_NULL)
    ccall((:proj_get_source_crs, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, obj)
end

"""
    proj_get_target_crs(const PJ * obj,
                        PJ_CONTEXT * ctx) -> PJ *

Return the hub CRS of a BoundCRS or the target CRS of a CoordinateOperation.

### Parameters
* **obj**: Object of type BoundCRS or CoordinateOperation (must not be NULL)
* **ctx**: PROJ context, or NULL for default context

### Returns
Object that must be unreferenced with proj_destroy(), or NULL in case of error, or missing target CRS.
"""
function proj_get_target_crs(obj, ctx = C_NULL)
    ccall((:proj_get_target_crs, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, obj)
end

"""
    proj_identify(const PJ * obj,
                  const char * auth_name,
                  int ** out_confidence,
                  PJ_CONTEXT * ctx,
                  const char *const * options) -> PJ_OBJ_LIST *

Identify the CRS with reference CRSs.

### Parameters
* **obj**: Object of type CRS. Must not be NULL
* **auth_name**: Authority name, or NULL for all authorities
* **out_confidence**: Output parameter. Pointer to an array of integers that will be allocated by the function and filled with the confidence values (0-100). There are as many elements in this array as proj_list_get_count() returns on the return value of this function. *confidence should be released with proj_int_list_destroy().
* **ctx**: PROJ context, or NULL for default context
* **options**: Placeholder for future options. Should be set to NULL.

### Returns
a list of matching reference CRS, or nullptr in case of error.
"""
function proj_identify(obj, auth_name, out_confidence, ctx = C_NULL, options = C_NULL)
    ccall((:proj_identify, libproj), Ptr{PJ_OBJ_LIST}, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Cstring, Ptr{Cstring}, Ptr{Ptr{Cint}}), ctx, obj, auth_name, options, out_confidence)
end

"""
    proj_int_list_destroy(int * list) -> void

Free an array of integer.
"""
function proj_int_list_destroy(list)
    ccall((:proj_int_list_destroy, libproj), Cvoid, (Ptr{Cint},), list)
end

"""
    proj_get_authorities_from_database(PJ_CONTEXT * ctx) -> PROJ_STRING_LIST

Return the list of authorities used in the database.

### Parameters
* **ctx**: PROJ context, or NULL for default context

### Returns
a NULL terminated list of NUL-terminated strings that must be freed with proj_string_list_destroy(), or NULL in case of error.
"""
function proj_get_authorities_from_database(ctx = C_NULL)
    ccall((:proj_get_authorities_from_database, libproj), PROJ_STRING_LIST, (Ptr{PJ_CONTEXT},), ctx)
end

"""
    proj_get_codes_from_database(const char * auth_name,
                                 PJ_TYPE type,
                                 int allow_deprecated,
                                 PJ_CONTEXT * ctx) -> PROJ_STRING_LIST

Returns the set of authority codes of the given object type.

### Parameters
* **auth_name**: Authority name (must not be NULL)
* **type**: Object type.
* **allow_deprecated**: whether we should return deprecated objects as well.
* **ctx**: PROJ context, or NULL for default context.

### Returns
a NULL terminated list of NUL-terminated strings that must be freed with proj_string_list_destroy(), or NULL in case of error.
"""
function proj_get_codes_from_database(auth_name, type, allow_deprecated, ctx = C_NULL)
    ccall((:proj_get_codes_from_database, libproj), PROJ_STRING_LIST, (Ptr{PJ_CONTEXT}, Cstring, PJ_TYPE, Cint), ctx, auth_name, type, allow_deprecated)
end

"""
    proj_get_crs_list_parameters_create() -> PROJ_CRS_LIST_PARAMETERS *

Instantiate a default set of parameters to be used by proj_get_crs_list().

### Returns
a new object to free with proj_get_crs_list_parameters_destroy()
"""
function proj_get_crs_list_parameters_create()
    ccall((:proj_get_crs_list_parameters_create, libproj), Ptr{PROJ_CRS_LIST_PARAMETERS}, ())
end

"""
    proj_get_crs_list_parameters_destroy(PROJ_CRS_LIST_PARAMETERS * params) -> void

Destroy an object returned by proj_get_crs_list_parameters_create()
"""
function proj_get_crs_list_parameters_destroy(params)
    ccall((:proj_get_crs_list_parameters_destroy, libproj), Cvoid, (Ptr{PROJ_CRS_LIST_PARAMETERS},), params)
end

"""
    proj_get_crs_info_list_from_database(const char * auth_name,
                                         const PROJ_CRS_LIST_PARAMETERS * params,
                                         int * out_result_count,
                                         PJ_CONTEXT * ctx) -> PROJ_CRS_INFO **

Enumerate CRS objects from the database, taking into account various criteria.

### Parameters
* **auth_name**: Authority name, used to restrict the search. Or NULL for all authorities.
* **params**: Additional criteria, or NULL. If not-NULL, params SHOULD have been allocated by proj_get_crs_list_parameters_create(), as the PROJ_CRS_LIST_PARAMETERS structure might grow over time.
* **out_result_count**: Output parameter pointing to an integer to receive the size of the result list. Might be NULL
* **ctx**: PROJ context, or NULL for default context

### Returns
an array of PROJ_CRS_INFO* pointers to be freed with proj_crs_info_list_destroy(), or NULL in case of error.
"""
function proj_get_crs_info_list_from_database(auth_name, params, out_result_count, ctx = C_NULL)
    ccall((:proj_get_crs_info_list_from_database, libproj), Ptr{Ptr{PROJ_CRS_INFO}}, (Ptr{PJ_CONTEXT}, Cstring, Ptr{PROJ_CRS_LIST_PARAMETERS}, Ptr{Cint}), ctx, auth_name, params, out_result_count)
end

"""
    proj_crs_info_list_destroy(PROJ_CRS_INFO ** list) -> void

Destroy the result returned by proj_get_crs_info_list_from_database().
"""
function proj_crs_info_list_destroy(list)
    ccall((:proj_crs_info_list_destroy, libproj), Cvoid, (Ptr{Ptr{PROJ_CRS_INFO}},), list)
end

"""
    proj_create_operation_factory_context(const char * authority,
                                          PJ_CONTEXT * ctx) -> PJ_OPERATION_FACTORY_CONTEXT *

Instantiate a context for building coordinate operations between two CRS.

### Parameters
* **authority**: Name of authority to which to restrict the search of candidate operations.
* **ctx**: Context, or NULL for default context.

### Returns
Object that must be unreferenced with proj_operation_factory_context_destroy(), or NULL in case of error.
"""
function proj_create_operation_factory_context(authority, ctx = C_NULL)
    ccall((:proj_create_operation_factory_context, libproj), Ptr{PJ_OPERATION_FACTORY_CONTEXT}, (Ptr{PJ_CONTEXT}, Cstring), ctx, authority)
end

"""
    proj_operation_factory_context_destroy(PJ_OPERATION_FACTORY_CONTEXT * ctx) -> void

Drops a reference on an object.

### Parameters
* **ctx**: Object, or NULL.
"""
function proj_operation_factory_context_destroy(ctx = C_NULL)
    ccall((:proj_operation_factory_context_destroy, libproj), Cvoid, (Ptr{PJ_OPERATION_FACTORY_CONTEXT},), ctx)
end

"""
    proj_operation_factory_context_set_desired_accuracy(PJ_OPERATION_FACTORY_CONTEXT * factory_ctx,
                                                        double accuracy,
                                                        PJ_CONTEXT * ctx) -> void

Set the desired accuracy of the resulting coordinate transformations.

### Parameters
* **factory_ctx**: Operation factory context. must not be NULL
* **accuracy**: Accuracy in meter (or 0 to disable the filter).
* **ctx**: PROJ context, or NULL for default context
"""
function proj_operation_factory_context_set_desired_accuracy(factory_ctx, accuracy, ctx = C_NULL)
    ccall((:proj_operation_factory_context_set_desired_accuracy, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}, Cdouble), ctx, factory_ctx, accuracy)
end

"""
    proj_operation_factory_context_set_area_of_interest(PJ_OPERATION_FACTORY_CONTEXT * factory_ctx,
                                                        double west_lon_degree,
                                                        double south_lat_degree,
                                                        double east_lon_degree,
                                                        double north_lat_degree,
                                                        PJ_CONTEXT * ctx) -> void

Set the desired area of interest for the resulting coordinate transformations.

### Parameters
* **factory_ctx**: Operation factory context. must not be NULL
* **west_lon_degree**: West longitude (in degrees).
* **south_lat_degree**: South latitude (in degrees).
* **east_lon_degree**: East longitude (in degrees).
* **north_lat_degree**: North latitude (in degrees).
* **ctx**: PROJ context, or NULL for default context
"""
function proj_operation_factory_context_set_area_of_interest(factory_ctx, west_lon_degree, south_lat_degree, east_lon_degree, north_lat_degree, ctx = C_NULL)
    ccall((:proj_operation_factory_context_set_area_of_interest, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}, Cdouble, Cdouble, Cdouble, Cdouble), ctx, factory_ctx, west_lon_degree, south_lat_degree, east_lon_degree, north_lat_degree)
end

"""
    proj_operation_factory_context_set_crs_extent_use(PJ_OPERATION_FACTORY_CONTEXT * factory_ctx,
                                                      PROJ_CRS_EXTENT_USE use,
                                                      PJ_CONTEXT * ctx) -> void

Set how source and target CRS extent should be used when considering if a transformation can be used (only takes effect if no area of interest is explicitly defined).

### Parameters
* **factory_ctx**: Operation factory context. must not be NULL
* **use**: How source and target CRS extent should be used.
* **ctx**: PROJ context, or NULL for default context
"""
function proj_operation_factory_context_set_crs_extent_use(factory_ctx, use, ctx = C_NULL)
    ccall((:proj_operation_factory_context_set_crs_extent_use, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}, PROJ_CRS_EXTENT_USE), ctx, factory_ctx, use)
end

"""
    proj_operation_factory_context_set_spatial_criterion(PJ_OPERATION_FACTORY_CONTEXT * factory_ctx,
                                                         PROJ_SPATIAL_CRITERION criterion,
                                                         PJ_CONTEXT * ctx) -> void

Set the spatial criterion to use when comparing the area of validity of coordinate operations with the area of interest / area of validity of source and target CRS.

### Parameters
* **factory_ctx**: Operation factory context. must not be NULL
* **criterion**: patial criterion to use
* **ctx**: PROJ context, or NULL for default context
"""
function proj_operation_factory_context_set_spatial_criterion(factory_ctx, criterion, ctx = C_NULL)
    ccall((:proj_operation_factory_context_set_spatial_criterion, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}, PROJ_SPATIAL_CRITERION), ctx, factory_ctx, criterion)
end

"""
    proj_operation_factory_context_set_grid_availability_use(PJ_OPERATION_FACTORY_CONTEXT * factory_ctx,
                                                             PROJ_GRID_AVAILABILITY_USE use,
                                                             PJ_CONTEXT * ctx) -> void

Set how grid availability is used.

### Parameters
* **factory_ctx**: Operation factory context. must not be NULL
* **use**: how grid availability is used.
* **ctx**: PROJ context, or NULL for default context
"""
function proj_operation_factory_context_set_grid_availability_use(factory_ctx, use, ctx = C_NULL)
    ccall((:proj_operation_factory_context_set_grid_availability_use, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}, PROJ_GRID_AVAILABILITY_USE), ctx, factory_ctx, use)
end

"""
    proj_operation_factory_context_set_use_proj_alternative_grid_names(PJ_OPERATION_FACTORY_CONTEXT * factory_ctx,
                                                                       int usePROJNames,
                                                                       PJ_CONTEXT * ctx) -> void

Set whether PROJ alternative grid names should be substituted to the official authority names.

### Parameters
* **factory_ctx**: Operation factory context. must not be NULL
* **usePROJNames**: whether PROJ alternative grid names should be used
* **ctx**: PROJ context, or NULL for default context
"""
function proj_operation_factory_context_set_use_proj_alternative_grid_names(factory_ctx, usePROJNames, ctx = C_NULL)
    ccall((:proj_operation_factory_context_set_use_proj_alternative_grid_names, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}, Cint), ctx, factory_ctx, usePROJNames)
end

"""
    proj_operation_factory_context_set_allow_use_intermediate_crs(PJ_OPERATION_FACTORY_CONTEXT * factory_ctx,
                                                                  PROJ_INTERMEDIATE_CRS_USE use,
                                                                  PJ_CONTEXT * ctx) -> void

Set whether an intermediate pivot CRS can be used for researching coordinate operations between a source and target CRS.

### Parameters
* **factory_ctx**: Operation factory context. must not be NULL
* **use**: whether and how intermediate CRS may be used.
* **ctx**: PROJ context, or NULL for default context
"""
function proj_operation_factory_context_set_allow_use_intermediate_crs(factory_ctx, use, ctx = C_NULL)
    ccall((:proj_operation_factory_context_set_allow_use_intermediate_crs, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}, PROJ_INTERMEDIATE_CRS_USE), ctx, factory_ctx, use)
end

"""
    proj_operation_factory_context_set_allowed_intermediate_crs(PJ_OPERATION_FACTORY_CONTEXT * factory_ctx,
                                                                const char *const * list_of_auth_name_codes,
                                                                PJ_CONTEXT * ctx) -> void

Restrict the potential pivot CRSs that can be used when trying to build a coordinate operation between two CRS that have no direct operation.

### Parameters
* **factory_ctx**: Operation factory context. must not be NULL
* **list_of_auth_name_codes**: an array of strings NLL terminated, with the format { "auth_name1", "code1", "auth_name2", "code2", ... NULL }
* **ctx**: PROJ context, or NULL for default context
"""
function proj_operation_factory_context_set_allowed_intermediate_crs(factory_ctx, list_of_auth_name_codes, ctx = C_NULL)
    ccall((:proj_operation_factory_context_set_allowed_intermediate_crs, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}, Ptr{Cstring}), ctx, factory_ctx, list_of_auth_name_codes)
end

"""
    proj_create_operations(const PJ * source_crs,
                           const PJ * target_crs,
                           const PJ_OPERATION_FACTORY_CONTEXT * operationContext,
                           PJ_CONTEXT * ctx) -> PJ_OBJ_LIST *

Find a list of CoordinateOperation from source_crs to target_crs.

### Parameters
* **source_crs**: source CRS. Must not be NULL.
* **target_crs**: source CRS. Must not be NULL.
* **operationContext**: Search context. Must not be NULL.
* **ctx**: PROJ context, or NULL for default context

### Returns
a result set that must be unreferenced with proj_list_destroy(), or NULL in case of error.
"""
function proj_create_operations(source_crs, target_crs, operationContext, ctx = C_NULL)
    ccall((:proj_create_operations, libproj), Ptr{PJ_OBJ_LIST}, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Ptr{PJ}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}), ctx, source_crs, target_crs, operationContext)
end

"""
    proj_list_get_count(const PJ_OBJ_LIST * result) -> int

Return the number of objects in the result set.

### Parameters
* **result**: Object of type PJ_OBJ_LIST (must not be NULL)
"""
function proj_list_get_count(result)
    ccall((:proj_list_get_count, libproj), Cint, (Ptr{PJ_OBJ_LIST},), result)
end

"""
    proj_list_get(const PJ_OBJ_LIST * result,
                  int index,
                  PJ_CONTEXT * ctx) -> PJ *

Return an object from the result set.

### Parameters
* **result**: Object of type PJ_OBJ_LIST (must not be NULL)
* **index**: Index
* **ctx**: PROJ context, or NULL for default context

### Returns
a new object that must be unreferenced with proj_destroy(), or nullptr in case of error.
"""
function proj_list_get(result, index, ctx = C_NULL)
    ccall((:proj_list_get, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ_OBJ_LIST}, Cint), ctx, result, index)
end

"""
    proj_list_destroy(PJ_OBJ_LIST * result) -> void

Drops a reference on the result set.

### Parameters
* **result**: Object, or NULL.
"""
function proj_list_destroy(result)
    ccall((:proj_list_destroy, libproj), Cvoid, (Ptr{PJ_OBJ_LIST},), result)
end

"""
    proj_crs_get_geodetic_crs(const PJ * crs,
                              PJ_CONTEXT * ctx) -> PJ *

Get the geodeticCRS / geographicCRS from a CRS.

### Parameters
* **crs**: Object of type CRS (must not be NULL)
* **ctx**: PROJ context, or NULL for default context

### Returns
Object that must be unreferenced with proj_destroy(), or NULL in case of error.
"""
function proj_crs_get_geodetic_crs(crs, ctx = C_NULL)
    ccall((:proj_crs_get_geodetic_crs, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, crs)
end

"""
    proj_crs_get_horizontal_datum(const PJ * crs,
                                  PJ_CONTEXT * ctx) -> PJ *

Get the horizontal datum from a CRS.

### Parameters
* **crs**: Object of type CRS (must not be NULL)
* **ctx**: PROJ context, or NULL for default context

### Returns
Object that must be unreferenced with proj_destroy(), or NULL in case of error.
"""
function proj_crs_get_horizontal_datum(crs, ctx = C_NULL)
    ccall((:proj_crs_get_horizontal_datum, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, crs)
end

"""
    proj_crs_get_sub_crs(const PJ * crs,
                         int index,
                         PJ_CONTEXT * ctx) -> PJ *

Get a CRS component from a CompoundCRS.

### Parameters
* **crs**: Object of type CRS (must not be NULL)
* **index**: Index of the CRS component (typically 0 = horizontal, 1 = vertical)
* **ctx**: PROJ context, or NULL for default context

### Returns
Object that must be unreferenced with proj_destroy(), or NULL in case of error.
"""
function proj_crs_get_sub_crs(crs, index, ctx = C_NULL)
    ccall((:proj_crs_get_sub_crs, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Cint), ctx, crs, index)
end

"""
    proj_crs_get_datum(const PJ * crs,
                       PJ_CONTEXT * ctx) -> PJ *

Returns the datum of a SingleCRS.

### Parameters
* **crs**: Object of type SingleCRS (must not be NULL)
* **ctx**: PROJ context, or NULL for default context

### Returns
Object that must be unreferenced with proj_destroy(), or NULL in case of error (or if there is no datum)
"""
function proj_crs_get_datum(crs, ctx = C_NULL)
    ccall((:proj_crs_get_datum, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, crs)
end

"""
    proj_crs_get_coordinate_system(const PJ * crs,
                                   PJ_CONTEXT * ctx) -> PJ *

Returns the coordinate system of a SingleCRS.

### Parameters
* **crs**: Object of type SingleCRS (must not be NULL)
* **ctx**: PROJ context, or NULL for default context

### Returns
Object that must be unreferenced with proj_destroy(), or NULL in case of error.
"""
function proj_crs_get_coordinate_system(crs, ctx = C_NULL)
    ccall((:proj_crs_get_coordinate_system, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, crs)
end

"""
    proj_cs_get_type(const PJ * cs,
                     PJ_CONTEXT * ctx) -> PJ_COORDINATE_SYSTEM_TYPE

Returns the type of the coordinate system.

### Parameters
* **cs**: Object of type CoordinateSystem (must not be NULL)
* **ctx**: PROJ context, or NULL for default context

### Returns
type, or PJ_CS_TYPE_UNKNOWN in case of error.
"""
function proj_cs_get_type(cs, ctx = C_NULL)
    ccall((:proj_cs_get_type, libproj), PJ_COORDINATE_SYSTEM_TYPE, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, cs)
end

"""
    proj_cs_get_axis_count(const PJ * cs,
                           PJ_CONTEXT * ctx) -> int

Returns the number of axis of the coordinate system.

### Parameters
* **cs**: Object of type CoordinateSystem (must not be NULL)
* **ctx**: PROJ context, or NULL for default context

### Returns
number of axis, or -1 in case of error.
"""
function proj_cs_get_axis_count(cs, ctx = C_NULL)
    ccall((:proj_cs_get_axis_count, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, cs)
end

"""
    proj_cs_get_axis_info(const PJ * cs,
                          int index,
                          const char ** out_name,
                          const char ** out_abbrev,
                          const char ** out_direction,
                          double * out_unit_conv_factor,
                          const char ** out_unit_name,
                          const char ** out_unit_auth_name,
                          const char ** out_unit_code,
                          PJ_CONTEXT * ctx) -> int

Returns information on an axis.

### Parameters
* **cs**: Object of type CoordinateSystem (must not be NULL)
* **index**: Index of the coordinate system (between 0 and proj_cs_get_axis_count() - 1)
* **out_name**: Pointer to a string value to store the axis name. or NULL
* **out_abbrev**: Pointer to a string value to store the axis abbreviation. or NULL
* **out_direction**: Pointer to a string value to store the axis direction. or NULL
* **out_unit_conv_factor**: Pointer to a double value to store the axis unit conversion factor. or NULL
* **out_unit_name**: Pointer to a string value to store the axis unit name. or NULL
* **out_unit_auth_name**: Pointer to a string value to store the axis unit authority name. or NULL
* **out_unit_code**: Pointer to a string value to store the axis unit code. or NULL
* **ctx**: PROJ context, or NULL for default context

### Returns
TRUE in case of success
"""
function proj_cs_get_axis_info(cs, index, out_name, out_abbrev, out_direction, out_unit_conv_factor, out_unit_name, out_unit_auth_name, out_unit_code, ctx = C_NULL)
    ccall((:proj_cs_get_axis_info, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Cint, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cdouble}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cstring}), ctx, cs, index, out_name, out_abbrev, out_direction, out_unit_conv_factor, out_unit_name, out_unit_auth_name, out_unit_code)
end

"""
    proj_get_ellipsoid(const PJ * obj,
                       PJ_CONTEXT * ctx) -> PJ *

Get the ellipsoid from a CRS or a GeodeticReferenceFrame.

### Parameters
* **obj**: Object of type CRS or GeodeticReferenceFrame (must not be NULL)
* **ctx**: PROJ context, or NULL for default context

### Returns
Object that must be unreferenced with proj_destroy(), or NULL in case of error.
"""
function proj_get_ellipsoid(obj, ctx = C_NULL)
    ccall((:proj_get_ellipsoid, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, obj)
end

"""
    proj_ellipsoid_get_parameters(const PJ * ellipsoid,
                                  double * out_semi_major_metre,
                                  double * out_semi_minor_metre,
                                  int * out_is_semi_minor_computed,
                                  double * out_inv_flattening,
                                  PJ_CONTEXT * ctx) -> int

Return ellipsoid parameters.

### Parameters
* **ellipsoid**: Object of type Ellipsoid (must not be NULL)
* **out_semi_major_metre**: Pointer to a value to store the semi-major axis in metre. or NULL
* **out_semi_minor_metre**: Pointer to a value to store the semi-minor axis in metre. or NULL
* **out_is_semi_minor_computed**: Pointer to a boolean value to indicate if the semi-minor value was computed. If FALSE, its value comes from the definition. or NULL
* **out_inv_flattening**: Pointer to a value to store the inverse flattening. or NULL
* **ctx**: PROJ context, or NULL for default context

### Returns
TRUE in case of success.
"""
function proj_ellipsoid_get_parameters(ellipsoid, out_semi_major_metre, out_semi_minor_metre, out_is_semi_minor_computed, out_inv_flattening, ctx = C_NULL)
    ccall((:proj_ellipsoid_get_parameters, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cdouble}), ctx, ellipsoid, out_semi_major_metre, out_semi_minor_metre, out_is_semi_minor_computed, out_inv_flattening)
end

"""
    proj_get_prime_meridian(const PJ * obj,
                            PJ_CONTEXT * ctx) -> PJ *

Get the prime meridian of a CRS or a GeodeticReferenceFrame.

### Parameters
* **obj**: Object of type CRS or GeodeticReferenceFrame (must not be NULL)
* **ctx**: PROJ context, or NULL for default context

### Returns
Object that must be unreferenced with proj_destroy(), or NULL in case of error.
"""
function proj_get_prime_meridian(obj, ctx = C_NULL)
    ccall((:proj_get_prime_meridian, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, obj)
end

"""
    proj_prime_meridian_get_parameters(const PJ * prime_meridian,
                                       double * out_longitude,
                                       double * out_unit_conv_factor,
                                       const char ** out_unit_name,
                                       PJ_CONTEXT * ctx) -> int

Return prime meridian parameters.

### Parameters
* **prime_meridian**: Object of type PrimeMeridian (must not be NULL)
* **out_longitude**: Pointer to a value to store the longitude of the prime meridian, in its native unit. or NULL
* **out_unit_conv_factor**: Pointer to a value to store the conversion factor of the prime meridian longitude unit to radian. or NULL
* **out_unit_name**: Pointer to a string value to store the unit name. or NULL
* **ctx**: PROJ context, or NULL for default context

### Returns
TRUE in case of success.
"""
function proj_prime_meridian_get_parameters(prime_meridian, out_longitude, out_unit_conv_factor, out_unit_name, ctx = C_NULL)
    ccall((:proj_prime_meridian_get_parameters, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cstring}), ctx, prime_meridian, out_longitude, out_unit_conv_factor, out_unit_name)
end

"""
    proj_crs_get_coordoperation(const PJ * crs,
                                PJ_CONTEXT * ctx) -> PJ *

Return the Conversion of a DerivedCRS (such as a ProjectedCRS), or the Transformation from the baseCRS to the hubCRS of a BoundCRS.

### Parameters
* **crs**: Object of type DerivedCRS or BoundCRSs (must not be NULL)
* **ctx**: PROJ context, or NULL for default context

### Returns
Object of type SingleOperation that must be unreferenced with proj_destroy(), or NULL in case of error.
"""
function proj_crs_get_coordoperation(crs, ctx = C_NULL)
    ccall((:proj_crs_get_coordoperation, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, crs)
end

"""
    proj_coordoperation_get_method_info(const PJ * coordoperation,
                                        const char ** out_method_name,
                                        const char ** out_method_auth_name,
                                        const char ** out_method_code,
                                        PJ_CONTEXT * ctx) -> int

Return information on the operation method of the SingleOperation.

### Parameters
* **coordoperation**: Object of type SingleOperation (typically a Conversion or Transformation) (must not be NULL)
* **out_method_name**: Pointer to a string value to store the method (projection) name. or NULL
* **out_method_auth_name**: Pointer to a string value to store the method authority name. or NULL
* **out_method_code**: Pointer to a string value to store the method code. or NULL
* **ctx**: PROJ context, or NULL for default context

### Returns
TRUE in case of success.
"""
function proj_coordoperation_get_method_info(coordoperation, out_method_name, out_method_auth_name, out_method_code, ctx = C_NULL)
    ccall((:proj_coordoperation_get_method_info, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cstring}), ctx, coordoperation, out_method_name, out_method_auth_name, out_method_code)
end

"""
    proj_coordoperation_is_instantiable(const PJ * coordoperation,
                                        PJ_CONTEXT * ctx) -> int

Return whether a coordinate operation can be instantiated as a PROJ pipeline, checking in particular that referenced grids are available.

### Parameters
* **coordoperation**: Object of type CoordinateOperation or derived classes (must not be NULL)
* **ctx**: PROJ context, or NULL for default context

### Returns
TRUE or FALSE.
"""
function proj_coordoperation_is_instantiable(coordoperation, ctx = C_NULL)
    ccall((:proj_coordoperation_is_instantiable, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, coordoperation)
end

"""
    proj_coordoperation_has_ballpark_transformation(const PJ * coordoperation,
                                                    PJ_CONTEXT * ctx) -> int

Return whether a coordinate operation has a "ballpark" transformation, that is a very approximate one, due to lack of more accurate transformations.

### Parameters
* **coordoperation**: Object of type CoordinateOperation or derived classes (must not be NULL)
* **ctx**: PROJ context, or NULL for default context

### Returns
TRUE or FALSE.
"""
function proj_coordoperation_has_ballpark_transformation(coordoperation, ctx = C_NULL)
    ccall((:proj_coordoperation_has_ballpark_transformation, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, coordoperation)
end

"""
    proj_coordoperation_get_param_count(const PJ * coordoperation,
                                        PJ_CONTEXT * ctx) -> int

Return the number of parameters of a SingleOperation.

### Parameters
* **coordoperation**: Object of type SingleOperation or derived classes (must not be NULL)
* **ctx**: PROJ context, or NULL for default context
"""
function proj_coordoperation_get_param_count(coordoperation, ctx = C_NULL)
    ccall((:proj_coordoperation_get_param_count, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, coordoperation)
end

"""
    proj_coordoperation_get_param_index(const PJ * coordoperation,
                                        const char * name,
                                        PJ_CONTEXT * ctx) -> int

Return the index of a parameter of a SingleOperation.

### Parameters
* **coordoperation**: Object of type SingleOperation or derived classes (must not be NULL)
* **name**: Parameter name. Must not be NULL
* **ctx**: PROJ context, or NULL for default context

### Returns
index (>=0), or -1 in case of error.
"""
function proj_coordoperation_get_param_index(coordoperation, name, ctx = C_NULL)
    ccall((:proj_coordoperation_get_param_index, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Cstring), ctx, coordoperation, name)
end

"""
    proj_coordoperation_get_param(const PJ * coordoperation,
                                  int index,
                                  const char ** out_name,
                                  const char ** out_auth_name,
                                  const char ** out_code,
                                  double * out_value,
                                  const char ** out_value_string,
                                  double * out_unit_conv_factor,
                                  const char ** out_unit_name,
                                  const char ** out_unit_auth_name,
                                  const char ** out_unit_code,
                                  const char ** out_unit_category,
                                  PJ_CONTEXT * ctx) -> int

Return a parameter of a SingleOperation.

### Parameters
* **coordoperation**: Object of type SingleOperation or derived classes (must not be NULL)
* **index**: Parameter index.
* **out_name**: Pointer to a string value to store the parameter name. or NULL
* **out_auth_name**: Pointer to a string value to store the parameter authority name. or NULL
* **out_code**: Pointer to a string value to store the parameter code. or NULL
* **out_value**: Pointer to a double value to store the parameter value (if numeric). or NULL
* **out_value_string**: Pointer to a string value to store the parameter value (if of type string). or NULL
* **out_unit_conv_factor**: Pointer to a double value to store the parameter unit conversion factor. or NULL
* **out_unit_name**: Pointer to a string value to store the parameter unit name. or NULL
* **out_unit_auth_name**: Pointer to a string value to store the unit authority name. or NULL
* **out_unit_code**: Pointer to a string value to store the unit code. or NULL
* **out_unit_category**: Pointer to a string value to store the parameter name. or NULL. This value might be "unknown", "none", "linear", "angular", "scale", "time" or "parametric";
* **ctx**: PROJ context, or NULL for default context

### Returns
TRUE in case of success.
"""
function proj_coordoperation_get_param(coordoperation, index, out_name, out_auth_name, out_code, out_value, out_value_string, out_unit_conv_factor, out_unit_name, out_unit_auth_name, out_unit_code, out_unit_category, ctx = C_NULL)
    ccall((:proj_coordoperation_get_param, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Cint, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cdouble}, Ptr{Cstring}, Ptr{Cdouble}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cstring}), ctx, coordoperation, index, out_name, out_auth_name, out_code, out_value, out_value_string, out_unit_conv_factor, out_unit_name, out_unit_auth_name, out_unit_code, out_unit_category)
end

"""
    proj_coordoperation_get_grid_used_count(const PJ * coordoperation,
                                            PJ_CONTEXT * ctx) -> int

Return the number of grids used by a CoordinateOperation.

### Parameters
* **coordoperation**: Object of type CoordinateOperation or derived classes (must not be NULL)
* **ctx**: PROJ context, or NULL for default context
"""
function proj_coordoperation_get_grid_used_count(coordoperation, ctx = C_NULL)
    ccall((:proj_coordoperation_get_grid_used_count, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, coordoperation)
end

"""
    proj_coordoperation_get_grid_used(const PJ * coordoperation,
                                      int index,
                                      const char ** out_short_name,
                                      const char ** out_full_name,
                                      const char ** out_package_name,
                                      const char ** out_url,
                                      int * out_direct_download,
                                      int * out_open_license,
                                      int * out_available,
                                      PJ_CONTEXT * ctx) -> int

Return a parameter of a SingleOperation.

### Parameters
* **coordoperation**: Object of type SingleOperation or derived classes (must not be NULL)
* **index**: Parameter index.
* **out_short_name**: Pointer to a string value to store the grid short name. or NULL
* **out_full_name**: Pointer to a string value to store the grid full filename. or NULL
* **out_package_name**: Pointer to a string value to store the package name where the grid might be found. or NULL
* **out_url**: Pointer to a string value to store the grid URL or the package URL where the grid might be found. or NULL
* **out_direct_download**: Pointer to a int (boolean) value to store whether *out_url can be downloaded directly. or NULL
* **out_open_license**: Pointer to a int (boolean) value to store whether the grid is released with an open license. or NULL
* **out_available**: Pointer to a int (boolean) value to store whether the grid is available at runtime. or NULL
* **ctx**: PROJ context, or NULL for default context

### Returns
TRUE in case of success.
"""
function proj_coordoperation_get_grid_used(coordoperation, index, out_short_name, out_full_name, out_package_name, out_url, out_direct_download, out_open_license, out_available, ctx = C_NULL)
    ccall((:proj_coordoperation_get_grid_used, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Cint, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), ctx, coordoperation, index, out_short_name, out_full_name, out_package_name, out_url, out_direct_download, out_open_license, out_available)
end

"""
    proj_coordoperation_get_accuracy(const PJ * coordoperation,
                                     PJ_CONTEXT * ctx) -> double

Return the accuracy (in metre) of a coordinate operation.

### Parameters
* **coordoperation**: Coordinate operation. Must not be NULL.
* **ctx**: PROJ context, or NULL for default context

### Returns
the accuracy, or a negative value if unknown or in case of error.
"""
function proj_coordoperation_get_accuracy(obj, ctx = C_NULL)
    ccall((:proj_coordoperation_get_accuracy, libproj), Cdouble, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, obj)
end

"""
    proj_coordoperation_get_towgs84_values(const PJ * coordoperation,
                                           double * out_values,
                                           int value_count,
                                           int emit_error_if_incompatible,
                                           PJ_CONTEXT * ctx) -> int

Return the parameters of a Helmert transformation as WKT1 TOWGS84 values.

### Parameters
* **coordoperation**: Object of type Transformation, that can be represented as a WKT1 TOWGS84 node (must not be NULL)
* **out_values**: Pointer to an array of value_count double values.
* **value_count**: Size of out_values array. The suggested size is 7 to get translation, rotation and scale difference parameters. Rotation and scale difference terms might be zero if the transformation only includes translation parameters. In that case, value_count could be set to 3.
* **emit_error_if_incompatible**: Boolean to inicate if an error must be logged if coordoperation is not compatible with a WKT1 TOWGS84 representation.
* **ctx**: PROJ context, or NULL for default context

### Returns
TRUE in case of success, or FALSE if coordoperation is not compatible with a WKT1 TOWGS84 representation.
"""
function proj_coordoperation_get_towgs84_values(coordoperation, out_values, value_count, emit_error_if_incompatible, ctx = C_NULL)
    ccall((:proj_coordoperation_get_towgs84_values, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Ptr{Cdouble}, Cint, Cint), ctx, coordoperation, out_values, value_count, emit_error_if_incompatible)
end
