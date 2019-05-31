# Julia wrapper for header: proj.h
# Automatically generated using Clang.jl


function proj_context_create()
    ccall((:proj_context_create, libproj), Ptr{PJ_CONTEXT}, ())
end

function proj_context_destroy(ctx)
    ccall((:proj_context_destroy, libproj), Ptr{PJ_CONTEXT}, (Ptr{PJ_CONTEXT},), ctx)
end

function proj_context_set_file_finder(ctx, finder, user_data)
    ccall((:proj_context_set_file_finder, libproj), Cvoid, (Ptr{PJ_CONTEXT}, proj_file_finder, Ptr{Cvoid}), ctx, finder, user_data)
end

function proj_context_set_search_paths(ctx, count_paths, paths)
    ccall((:proj_context_set_search_paths, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Cint, Ptr{Cstring}), ctx, count_paths, paths)
end

function proj_context_use_proj4_init_rules(ctx, enable)
    ccall((:proj_context_use_proj4_init_rules, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Cint), ctx, enable)
end

function proj_context_get_use_proj4_init_rules(ctx, from_legacy_code_path)
    ccall((:proj_context_get_use_proj4_init_rules, libproj), Cint, (Ptr{PJ_CONTEXT}, Cint), ctx, from_legacy_code_path)
end

function proj_create(ctx, definition)
    ccall((:proj_create, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Cstring), ctx, definition)
end

function proj_create_argv(ctx, argc, argv)
    ccall((:proj_create_argv, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Cint, Ptr{Cstring}), ctx, argc, argv)
end

function proj_create_crs_to_crs(ctx, source_crs, target_crs, area)
    ccall((:proj_create_crs_to_crs, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Cstring, Cstring, Ptr{PJ_AREA}), ctx, source_crs, target_crs, area)
end

function proj_normalize_for_visualization(ctx, obj)
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

function proj_context_errno(ctx)
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
    ccall((:proj_errno_string, libproj), Cstring, (Cint,), err)
end

function proj_log_level(ctx, log_level)
    ccall((:proj_log_level, libproj), PJ_LOG_LEVEL, (Ptr{PJ_CONTEXT}, PJ_LOG_LEVEL), ctx, log_level)
end

function proj_log_func(ctx, app_data, logf)
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
    ccall((:proj_rtodms, libproj), Cstring, (Cstring, Cdouble, Cint, Cint), s, r, pos, neg)
end

function proj_string_list_destroy(list)
    ccall((:proj_string_list_destroy, libproj), Cvoid, (PROJ_STRING_LIST,), list)
end

function proj_context_set_database_path(ctx, dbPath, auxDbPaths, options)
    ccall((:proj_context_set_database_path, libproj), Cint, (Ptr{PJ_CONTEXT}, Cstring, Ptr{Cstring}, Ptr{Cstring}), ctx, dbPath, auxDbPaths, options)
end

function proj_context_get_database_path(ctx)
    ccall((:proj_context_get_database_path, libproj), Cstring, (Ptr{PJ_CONTEXT},), ctx)
end

function proj_context_get_database_metadata(ctx, key)
    ccall((:proj_context_get_database_metadata, libproj), Cstring, (Ptr{PJ_CONTEXT}, Cstring), ctx, key)
end

function proj_context_guess_wkt_dialect(ctx, wkt)
    ccall((:proj_context_guess_wkt_dialect, libproj), PJ_GUESSED_WKT_DIALECT, (Ptr{PJ_CONTEXT}, Cstring), ctx, wkt)
end

function proj_create_from_wkt(ctx, wkt, options, out_warnings, out_grammar_errors)
    ccall((:proj_create_from_wkt, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Cstring, Ptr{Cstring}, Ptr{PROJ_STRING_LIST}, Ptr{PROJ_STRING_LIST}), ctx, wkt, options, out_warnings, out_grammar_errors)
end

function proj_create_from_database(ctx, auth_name, code, category, usePROJAlternativeGridNames, options)
    ccall((:proj_create_from_database, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Cstring, Cstring, PJ_CATEGORY, Cint, Ptr{Cstring}), ctx, auth_name, code, category, usePROJAlternativeGridNames, options)
end

function proj_uom_get_info_from_database(ctx, auth_name, code, out_name, out_conv_factor, out_category)
    ccall((:proj_uom_get_info_from_database, libproj), Cint, (Ptr{PJ_CONTEXT}, Cstring, Cstring, Ptr{Cstring}, Ptr{Cdouble}, Ptr{Cstring}), ctx, auth_name, code, out_name, out_conv_factor, out_category)
end

function proj_clone(ctx, obj)
    ccall((:proj_clone, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, obj)
end

function proj_create_from_name(ctx, auth_name, searchedName, types, typesCount, approximateMatch, limitResultCount, options)
    ccall((:proj_create_from_name, libproj), Ptr{PJ_OBJ_LIST}, (Ptr{PJ_CONTEXT}, Cstring, Cstring, Ptr{PJ_TYPE}, Csize_t, Cint, Csize_t, Ptr{Cstring}), ctx, auth_name, searchedName, types, typesCount, approximateMatch, limitResultCount, options)
end

function proj_get_type(obj)
    ccall((:proj_get_type, libproj), PJ_TYPE, (Ptr{PJ},), obj)
end

function proj_is_deprecated(obj)
    ccall((:proj_is_deprecated, libproj), Cint, (Ptr{PJ},), obj)
end

function proj_get_non_deprecated(ctx, obj)
    ccall((:proj_get_non_deprecated, libproj), Ptr{PJ_OBJ_LIST}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, obj)
end

function proj_is_equivalent_to(obj, other, criterion)
    ccall((:proj_is_equivalent_to, libproj), Cint, (Ptr{PJ}, Ptr{PJ}, PJ_COMPARISON_CRITERION), obj, other, criterion)
end

function proj_is_crs(obj)
    ccall((:proj_is_crs, libproj), Cint, (Ptr{PJ},), obj)
end

function proj_get_name(obj)
    ccall((:proj_get_name, libproj), Cstring, (Ptr{PJ},), obj)
end

function proj_get_id_auth_name(obj, index)
    ccall((:proj_get_id_auth_name, libproj), Cstring, (Ptr{PJ}, Cint), obj, index)
end

function proj_get_id_code(obj, index)
    ccall((:proj_get_id_code, libproj), Cstring, (Ptr{PJ}, Cint), obj, index)
end

function proj_get_area_of_use(ctx, obj, out_west_lon_degree, out_south_lat_degree, out_east_lon_degree, out_north_lat_degree, out_area_name)
    ccall((:proj_get_area_of_use, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cstring}), ctx, obj, out_west_lon_degree, out_south_lat_degree, out_east_lon_degree, out_north_lat_degree, out_area_name)
end

function proj_as_wkt(ctx, obj, type, options)
    ccall((:proj_as_wkt, libproj), Cstring, (Ptr{PJ_CONTEXT}, Ptr{PJ}, PJ_WKT_TYPE, Ptr{Cstring}), ctx, obj, type, options)
end

function proj_as_proj_string(ctx, obj, type, options)
    ccall((:proj_as_proj_string, libproj), Cstring, (Ptr{PJ_CONTEXT}, Ptr{PJ}, PJ_PROJ_STRING_TYPE, Ptr{Cstring}), ctx, obj, type, options)
end

function proj_get_source_crs(ctx, obj)
    ccall((:proj_get_source_crs, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, obj)
end

function proj_get_target_crs(ctx, obj)
    ccall((:proj_get_target_crs, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, obj)
end

function proj_identify(ctx, obj, auth_name, options, out_confidence)
    ccall((:proj_identify, libproj), Ptr{PJ_OBJ_LIST}, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Cstring, Ptr{Cstring}, Ptr{Ptr{Cint}}), ctx, obj, auth_name, options, out_confidence)
end

function proj_int_list_destroy(list)
    ccall((:proj_int_list_destroy, libproj), Cvoid, (Ptr{Cint},), list)
end

function proj_get_authorities_from_database(ctx)
    ccall((:proj_get_authorities_from_database, libproj), PROJ_STRING_LIST, (Ptr{PJ_CONTEXT},), ctx)
end

function proj_get_codes_from_database(ctx, auth_name, type, allow_deprecated)
    ccall((:proj_get_codes_from_database, libproj), PROJ_STRING_LIST, (Ptr{PJ_CONTEXT}, Cstring, PJ_TYPE, Cint), ctx, auth_name, type, allow_deprecated)
end

function proj_get_crs_list_parameters_create()
    ccall((:proj_get_crs_list_parameters_create, libproj), Ptr{PROJ_CRS_LIST_PARAMETERS}, ())
end

function proj_get_crs_list_parameters_destroy(params)
    ccall((:proj_get_crs_list_parameters_destroy, libproj), Cvoid, (Ptr{PROJ_CRS_LIST_PARAMETERS},), params)
end

function proj_get_crs_info_list_from_database(ctx, auth_name, params, out_result_count)
    ccall((:proj_get_crs_info_list_from_database, libproj), Ptr{Ptr{PROJ_CRS_INFO}}, (Ptr{PJ_CONTEXT}, Cstring, Ptr{PROJ_CRS_LIST_PARAMETERS}, Ptr{Cint}), ctx, auth_name, params, out_result_count)
end

function proj_crs_info_list_destroy(list)
    ccall((:proj_crs_info_list_destroy, libproj), Cvoid, (Ptr{Ptr{PROJ_CRS_INFO}},), list)
end

function proj_create_operation_factory_context(ctx, authority)
    ccall((:proj_create_operation_factory_context, libproj), Ptr{PJ_OPERATION_FACTORY_CONTEXT}, (Ptr{PJ_CONTEXT}, Cstring), ctx, authority)
end

function proj_operation_factory_context_destroy(ctx)
    ccall((:proj_operation_factory_context_destroy, libproj), Cvoid, (Ptr{PJ_OPERATION_FACTORY_CONTEXT},), ctx)
end

function proj_operation_factory_context_set_desired_accuracy(ctx, factory_ctx, accuracy)
    ccall((:proj_operation_factory_context_set_desired_accuracy, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}, Cdouble), ctx, factory_ctx, accuracy)
end

function proj_operation_factory_context_set_area_of_interest(ctx, factory_ctx, west_lon_degree, south_lat_degree, east_lon_degree, north_lat_degree)
    ccall((:proj_operation_factory_context_set_area_of_interest, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}, Cdouble, Cdouble, Cdouble, Cdouble), ctx, factory_ctx, west_lon_degree, south_lat_degree, east_lon_degree, north_lat_degree)
end

function proj_operation_factory_context_set_crs_extent_use(ctx, factory_ctx, use)
    ccall((:proj_operation_factory_context_set_crs_extent_use, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}, PROJ_CRS_EXTENT_USE), ctx, factory_ctx, use)
end

function proj_operation_factory_context_set_spatial_criterion(ctx, factory_ctx, criterion)
    ccall((:proj_operation_factory_context_set_spatial_criterion, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}, PROJ_SPATIAL_CRITERION), ctx, factory_ctx, criterion)
end

function proj_operation_factory_context_set_grid_availability_use(ctx, factory_ctx, use)
    ccall((:proj_operation_factory_context_set_grid_availability_use, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}, PROJ_GRID_AVAILABILITY_USE), ctx, factory_ctx, use)
end

function proj_operation_factory_context_set_use_proj_alternative_grid_names(ctx, factory_ctx, usePROJNames)
    ccall((:proj_operation_factory_context_set_use_proj_alternative_grid_names, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}, Cint), ctx, factory_ctx, usePROJNames)
end

function proj_operation_factory_context_set_allow_use_intermediate_crs(ctx, factory_ctx, use)
    ccall((:proj_operation_factory_context_set_allow_use_intermediate_crs, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}, PROJ_INTERMEDIATE_CRS_USE), ctx, factory_ctx, use)
end

function proj_operation_factory_context_set_allowed_intermediate_crs(ctx, factory_ctx, list_of_auth_name_codes)
    ccall((:proj_operation_factory_context_set_allowed_intermediate_crs, libproj), Cvoid, (Ptr{PJ_CONTEXT}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}, Ptr{Cstring}), ctx, factory_ctx, list_of_auth_name_codes)
end

function proj_create_operations(ctx, source_crs, target_crs, operationContext)
    ccall((:proj_create_operations, libproj), Ptr{PJ_OBJ_LIST}, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Ptr{PJ}, Ptr{PJ_OPERATION_FACTORY_CONTEXT}), ctx, source_crs, target_crs, operationContext)
end

function proj_list_get_count(result)
    ccall((:proj_list_get_count, libproj), Cint, (Ptr{PJ_OBJ_LIST},), result)
end

function proj_list_get(ctx, result, index)
    ccall((:proj_list_get, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ_OBJ_LIST}, Cint), ctx, result, index)
end

function proj_list_destroy(result)
    ccall((:proj_list_destroy, libproj), Cvoid, (Ptr{PJ_OBJ_LIST},), result)
end

function proj_crs_get_geodetic_crs(ctx, crs)
    ccall((:proj_crs_get_geodetic_crs, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, crs)
end

function proj_crs_get_horizontal_datum(ctx, crs)
    ccall((:proj_crs_get_horizontal_datum, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, crs)
end

function proj_crs_get_sub_crs(ctx, crs, index)
    ccall((:proj_crs_get_sub_crs, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Cint), ctx, crs, index)
end

function proj_crs_get_datum(ctx, crs)
    ccall((:proj_crs_get_datum, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, crs)
end

function proj_crs_get_coordinate_system(ctx, crs)
    ccall((:proj_crs_get_coordinate_system, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, crs)
end

function proj_cs_get_type(ctx, cs)
    ccall((:proj_cs_get_type, libproj), PJ_COORDINATE_SYSTEM_TYPE, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, cs)
end

function proj_cs_get_axis_count(ctx, cs)
    ccall((:proj_cs_get_axis_count, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, cs)
end

function proj_cs_get_axis_info(ctx, cs, index, out_name, out_abbrev, out_direction, out_unit_conv_factor, out_unit_name, out_unit_auth_name, out_unit_code)
    ccall((:proj_cs_get_axis_info, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Cint, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cdouble}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cstring}), ctx, cs, index, out_name, out_abbrev, out_direction, out_unit_conv_factor, out_unit_name, out_unit_auth_name, out_unit_code)
end

function proj_get_ellipsoid(ctx, obj)
    ccall((:proj_get_ellipsoid, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, obj)
end

function proj_ellipsoid_get_parameters(ctx, ellipsoid, out_semi_major_metre, out_semi_minor_metre, out_is_semi_minor_computed, out_inv_flattening)
    ccall((:proj_ellipsoid_get_parameters, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cdouble}), ctx, ellipsoid, out_semi_major_metre, out_semi_minor_metre, out_is_semi_minor_computed, out_inv_flattening)
end

function proj_get_prime_meridian(ctx, obj)
    ccall((:proj_get_prime_meridian, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, obj)
end

function proj_prime_meridian_get_parameters(ctx, prime_meridian, out_longitude, out_unit_conv_factor, out_unit_name)
    ccall((:proj_prime_meridian_get_parameters, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cstring}), ctx, prime_meridian, out_longitude, out_unit_conv_factor, out_unit_name)
end

function proj_crs_get_coordoperation(ctx, crs)
    ccall((:proj_crs_get_coordoperation, libproj), Ptr{PJ}, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, crs)
end

function proj_coordoperation_get_method_info(ctx, coordoperation, out_method_name, out_method_auth_name, out_method_code)
    ccall((:proj_coordoperation_get_method_info, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cstring}), ctx, coordoperation, out_method_name, out_method_auth_name, out_method_code)
end

function proj_coordoperation_is_instantiable(ctx, coordoperation)
    ccall((:proj_coordoperation_is_instantiable, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, coordoperation)
end

function proj_coordoperation_has_ballpark_transformation(ctx, coordoperation)
    ccall((:proj_coordoperation_has_ballpark_transformation, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, coordoperation)
end

function proj_coordoperation_get_param_count(ctx, coordoperation)
    ccall((:proj_coordoperation_get_param_count, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, coordoperation)
end

function proj_coordoperation_get_param_index(ctx, coordoperation, name)
    ccall((:proj_coordoperation_get_param_index, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Cstring), ctx, coordoperation, name)
end

function proj_coordoperation_get_param(ctx, coordoperation, index, out_name, out_auth_name, out_code, out_value, out_value_string, out_unit_conv_factor, out_unit_name, out_unit_auth_name, out_unit_code, out_unit_category)
    ccall((:proj_coordoperation_get_param, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Cint, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cdouble}, Ptr{Cstring}, Ptr{Cdouble}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cstring}), ctx, coordoperation, index, out_name, out_auth_name, out_code, out_value, out_value_string, out_unit_conv_factor, out_unit_name, out_unit_auth_name, out_unit_code, out_unit_category)
end

function proj_coordoperation_get_grid_used_count(ctx, coordoperation)
    ccall((:proj_coordoperation_get_grid_used_count, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, coordoperation)
end

function proj_coordoperation_get_grid_used(ctx, coordoperation, index, out_short_name, out_full_name, out_package_name, out_url, out_direct_download, out_open_license, out_available)
    ccall((:proj_coordoperation_get_grid_used, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Cint, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), ctx, coordoperation, index, out_short_name, out_full_name, out_package_name, out_url, out_direct_download, out_open_license, out_available)
end

function proj_coordoperation_get_accuracy(ctx, obj)
    ccall((:proj_coordoperation_get_accuracy, libproj), Cdouble, (Ptr{PJ_CONTEXT}, Ptr{PJ}), ctx, obj)
end

function proj_coordoperation_get_towgs84_values(ctx, coordoperation, out_values, value_count, emit_error_if_incompatible)
    ccall((:proj_coordoperation_get_towgs84_values, libproj), Cint, (Ptr{PJ_CONTEXT}, Ptr{PJ}, Ptr{Cdouble}, Cint, Cint), ctx, coordoperation, out_values, value_count, emit_error_if_incompatible)
end
