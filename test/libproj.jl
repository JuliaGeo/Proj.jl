using Test
using StaticArrays
using Proj
import PROJ_jll

@testset "Error handling" begin
    @test Proj.proj_errno_string(0) === nothing
    @test Proj.proj_errno_string(1) == "Unknown error (code 1)"
    @test Proj.proj_errno_string(Proj.PROJ_ERR_INVALID_OP_WRONG_SYNTAX) ==
          "Invalid PROJ string syntax"

    pj = Proj.proj_create("EPSG:4326")
    Proj.proj_errno_set(pj, 14)
    @test Proj.proj_errno(pj) == 14
    Proj.proj_errno_reset(pj)
    @test Proj.proj_errno(pj) == 0
    pj = Proj.proj_destroy(pj)

    # this throws an internal error that is handled by our log_func
    @test_throws Proj.PROJError Proj.proj_create("+proj=bobbyjoe")
    # ensure we have reset the error state
    @test Proj.proj_context_errno() == 0

end

@testset "Database" begin
    crs = Proj.proj_create_from_database("EPSG", "4326", Proj.PJ_CATEGORY_CRS, false)
    Proj.proj_errno(crs)
    Proj.proj_get_id_code(crs, 0)
end

@testset "Create" begin
    pj_latlon = Proj.proj_create("EPSG:4326")

    esriwkt = """GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137.0,298.257223563]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]]"""
    pj2 = Proj.proj_create(esriwkt)

    @test startswith(Proj.proj_as_wkt(pj2, Proj.PJ_WKT1_ESRI, C_NULL), "GEOGCS")
    @test startswith(Proj.proj_as_wkt(pj2, Proj.PJ_WKT2_2018, C_NULL), "GEOGCRS")
end

@testset "Transformation between CRS" begin
    # taken from http://osgeo-org.1560.x6.nabble.com/PROJ-PROJ-6-0-0-proj-create-operation-factory-context-behavior-td5403470.html
    src = Proj.proj_create("IGNF:REUN47GAUSSL")   # area : 55.17,-21.42,55.92,-20.76
    tgt = Proj.proj_create("IGNF:RGAF09UTM20")    # area : -63.2,14.25,-60.73,18.2
    factory = Proj.proj_create_operation_factory_context(C_NULL)
    @test factory != C_NULL
    @test Proj.proj_context_errno() == 0
    results = Proj.proj_create_operations(src, tgt, factory)
    @test results != C_NULL
    n = Proj.proj_list_get_count(results)
    @test n == 1

    operation = Proj.proj_list_get(results, 0)
    @test Bool(Proj.proj_coordoperation_has_ballpark_transformation(operation))
    @test Bool(Proj.proj_coordoperation_has_ballpark_transformation(operation))
    @test startswith(Proj.proj_get_name(operation), "Inverse of GAUSS LABORDE REUNION")

    info = Proj.proj_pj_info(operation)
    @test unsafe_string(info.id) == "pipeline"
    @test startswith(unsafe_string(info.description), "Inverse of GAUSS LABORDE REUNION")
    @test startswith(unsafe_string(info.definition), "proj=pipeline step inv proj=gstmerc")
    @test Bool(info.has_inverse)
    @test info.accuracy === -1.0
    Proj.proj_destroy(operation)

    Proj.proj_list_destroy(results)

    Proj.proj_operation_factory_context_destroy(factory)
    Proj.proj_destroy(src)
    Proj.proj_destroy(tgt)
end

@testset "Quickstart" begin
    # https://proj.org/development/quickstart.html

    pj = Proj.proj_create_crs_to_crs(
        "EPSG:4326",  # source
        "+proj=utm +zone=32 +datum=WGS84",  # target, also EPSG:32632
    )

    # This will ensure that the order of coordinates for the input CRS
    # will be longitude, latitude, whereas EPSG:4326 mandates latitude,
    # longitude
    pj_for_gis = Proj.proj_normalize_for_visualization(pj)
    Proj.proj_destroy(pj)
    pj = pj_for_gis

    # a coordinate union representing Copenhagen: 55d N, 12d E
    # Given that we have used proj_normalize_for_visualization(), the order of
    # coordinates is longitude, latitude, and values are expressed in degrees.
    a = Proj.proj_coord(12, 55)
    @test a isa Proj.Coord
    @test a isa AbstractVector
    @test eltype(a) == Float64
    @test length(a) == 4
    @test sum(a) == Inf
    @test isbits(a)
    @test a[1] === 12.0
    @test a[2] === 55.0
    @test a[3] === 0.0
    @test a[4] === Inf

    # transform to UTM zone 32
    b = Proj.proj_trans(pj, Proj.PJ_FWD, a)
    @test is_approx(b, (691875.632, 6098907.825, 0.0, Inf))

    # inverse transform, back to geographical
    b = Proj.proj_trans(pj, Proj.PJ_INV, b)
    @test is_approx(b, (12.0, 55.0, 0.0, Inf))

    # Clean up
    pj = Proj.proj_destroy(pj)
    pj = Proj.proj_destroy(pj)
    # Julia crashes if proj_destroy is called twice on the same non nullptr,
    # since the contents at that address are already wiped. To prevent this,
    # change the input binding directly after, e.g. pj = proj_destroy(pj)  # -> C_NULL
end

@testset "inverse transformation" begin
    trans = Proj.Transformation(
        "EPSG:4326",
        "+proj=utm +zone=32 +datum=WGS84",
        always_xy=true,
    )

    # for custom / proj strings, or modified axis order, no description can be looked up in
    # the database
    @test repr(trans) == """
    Transformation pipeline
        description: UTM zone 32N
        definition: proj=pipeline step proj=unitconvert xy_in=deg xy_out=rad step proj=utm zone=32 ellps=WGS84
        direction: forward
    """

    trans⁻¹ = inv(trans, always_xy=true)
    trans¹ = inv(trans⁻¹, always_xy=true)

    # inv does not flip source and target, so the WKT stays the same
    wkt_type = Proj.PJ_WKT2_2019
    @test Proj.proj_as_wkt(trans⁻¹.pj, wkt_type) == Proj.proj_as_wkt(trans.pj, wkt_type)
    @test Proj.proj_as_wkt(trans¹.pj, wkt_type) == Proj.proj_as_wkt(trans.pj, wkt_type)

    a = (12.0, 55.0)
    b = (691875.632, 6098907.825)
    @test is_approx(trans⁻¹(b), a)
    @test is_approx(trans¹(a), b)
    @test trans⁻¹.direction == PJ_INV
    @test trans¹.direction == PJ_FWD

    # we don't check if source and target are equal when constructing a identity transform
    # since Transformation is mutable, it can always be changed after construction
    trans = Proj.Transformation(
        "EPSG:4326",
        "+proj=utm +zone=32 +datum=WGS84",
        direction=PJ_IDENT,
    )
    @test trans(a) === a
    trans⁻¹ = inv(trans, always_xy=true)
    @test trans⁻¹(a) === a
    @test trans⁻¹.direction == PJ_IDENT
    trans⁻¹.direction = PJ_FWD
    @test is_approx(trans⁻¹(a), b)

    @test inv(PJ_FWD) == PJ_INV
    @test inv(PJ_IDENT) == PJ_IDENT
    @test inv(PJ_INV) == PJ_FWD

    @test_throws AssertionError Proj.Transformation("EPSG:28992")
    trans = Proj.Transformation("+proj=pipeline +ellps=GRS80 +step +proj=merc +step +proj=axisswap +order=2,1")

end

@testset "single transformation" begin
    source_crs = Proj.proj_create("EPSG:4326")
    target_crs = Proj.proj_create("EPSG:28992")
    @test source_crs isa Ptr{Nothing}
    @test target_crs isa Ptr{Nothing}
    trans = Proj.Transformation(source_crs, target_crs)

    # Check that altitude and time inputs are correctly forwarded from the transformation
    p = trans(SA_F64[52.16, 5.39, 5, 2020])
    @test is_approx(p, (155191.3538124342, 463537.1362732911, 5.0, 2020.0))

    a = (52.16, 5.39)
    b = Proj.proj_trans(trans.pj, Proj.PJ_FWD, a)
    @test is_approx(b, (155191.3538124342, 463537.1362732911))

    # with always_xy = true, we need to use lon/lat, and still get x/y out
    trans = Proj.Transformation(source_crs, target_crs, always_xy=true)
    a = (5.39, 52.16)
    b = Proj.proj_trans(trans.pj, Proj.PJ_FWD, a)
    @test is_approx(b, (155191.3538124342, 463537.1362732911))
end

@testset "bounds" begin
    trans = Proj.Transformation("EPSG:4326", "+proj=utm +zone=32 +datum=WGS84")
    x, y = 52, 11
    tx, ty = trans(x, y)

    (xmin, xmax), (ymin, ymax) = (50, 55), (10, 15)
    (txmin, txmax), (tymin, tymax) = Proj.bounds(trans, (xmin, xmax), (ymin, ymax))

    @test txmin < tx < txmax
    @test tymin < ty < tymax

    (ttxmin, ttxmax), (ttymin, ttymax) = Proj.bounds(inv(trans), (txmin, txmax), (tymin, tymax))
    @test ttxmin < xmin < xmax < ttxmax
    @test ttymin < ymin < ymax < ttymax

end

@testset "dense 4D coord vector transformation" begin
    source_crs = Proj.proj_create("EPSG:4326")
    target_crs = Proj.proj_create("EPSG:28992")
    trans = Proj.Transformation(source_crs, target_crs, always_xy=true)
    # This array is mutated in place. Note that this array needs to have 4D elements,
    # with 2D elements it will only do every other one
    A = [Proj.Coord(5.39, 52.16) for _ = 1:5]
    err = Proj.proj_trans_array(trans.pj, Proj.PJ_FWD, length(A), A)
    @test err == 0
    B = [Proj.Coord(155191.3538124342, 463537.1362732911) for _ = 1:5]
    @test all(is_approx(a, b) for (a, b) in zip(A, B))

    # since A is not in target_crs, we will get an error on a second call
    err = Proj.PROJError("push: Invalid latitude")
    @test_throws err Proj.proj_trans_array(trans.pj, Proj.PJ_FWD, length(A), A)
    # error number is reset during PROJError construction
    @test Proj.proj_errno(trans.pj) == 0
    # test triggering finalizer manually
    finalize(trans)
    @test trans.pj === C_NULL
end

@testset "generic array transformation" begin
    source_crs = Proj.proj_create("EPSG:4326")
    target_crs = Proj.proj_create("EPSG:28992")
    trans = Proj.Transformation(source_crs, target_crs, always_xy=true)

    # inplace transformation of vector of 2D coordinates
    # using https://proj.org/development/reference/functions.html#c.proj_trans_generic
    A = [SA[5.39, 52.16] for _ = 1:5]
    st = sizeof(first(A))
    ptr = pointer(A)
    n = length(A)
    # 8 is sizeof(Float64), so ptr + 8 points to first latitude element
    n_done = Proj.proj_trans_generic(
        trans.pj,
        Proj.PJ_FWD,
        ptr,
        st,
        n,
        ptr + 8,
        st,
        n,
        C_NULL,
        C_NULL,
        C_NULL,
        C_NULL,
        C_NULL,
        C_NULL,
    )
    @test n_done == n
    B = [SA[155191.3538124342, 463537.1362732911] for _ = 1:5]
    @test A ≈ B
end

@testset "compose" begin
    trans1 = Proj.Transformation("EPSG:4326", "EPSG:28992", always_xy=true)
    trans2 = Proj.Transformation("EPSG:32632", "EPSG:2027", always_xy=true)
    trans = trans1 ∘ trans2  # same as compose(trans1, trans2)
    source_crs = Proj.proj_get_source_crs(trans.pj)
    target_crs = Proj.proj_get_target_crs(trans.pj)

    # trans1 source is the new source
    source_crs1 = Proj.proj_get_source_crs(trans1.pj)
    source_wkt = Proj.proj_as_wkt(source_crs, Proj.PJ_WKT2_2019, C_NULL)
    source_wkt1 = Proj.proj_as_wkt(source_crs1, Proj.PJ_WKT2_2019, C_NULL)
    @test source_wkt == source_wkt1

    # trans2 source is the new target
    target_crs1 = Proj.proj_get_target_crs(trans2.pj)
    target_wkt = Proj.proj_as_wkt(target_crs, Proj.PJ_WKT2_2019, C_NULL)
    target_wkt1 = Proj.proj_as_wkt(target_crs1, Proj.PJ_WKT2_2019, C_NULL)
    @test target_wkt == target_wkt1

    # which we can also see from show
    @test repr(trans) == """
    Transformation pipeline
        description: Ballpark geographic offset from WGS 84 (with axis order normalized for visualization) to NAD27(76) + UTM zone 15N
        definition: proj=pipeline step proj=unitconvert xy_in=deg xy_out=rad step proj=utm zone=15 ellps=clrk66
        direction: forward
    """
end

@testset "Coord constructor" begin
    coord = Proj.Coord(1.0, 2.0, 3.0, Inf)
    @test_throws MethodError Proj.Coord()
    @test_throws ErrorException Proj.Coord(0.0)
    @test Proj.Coord(1.0, 2.0) == Proj.Coord(1.0, 2.0, 0.0, Inf)
    @test Proj.Coord(1.0, 2.0, 3.0) == coord
    @test Proj.Coord(1.0, 2.0, 3.0, 4.0) == Proj.Coord(1.0, 2.0, 3.0, 4.0)

    @test Proj.Coord((1.0, 2.0, 3.0)) == coord
    @test Proj.Coord([1.0, 2.0, 3.0]) == coord
    @test Proj.Coord(1, 2, 3) == coord
    @test Proj.Coord([1, 2, 3]) == coord
    @test Proj.Coord(UInt8[1, 2, 3]) == coord
    @test Proj.Coord(1:3) == coord
    @test Proj.Coord(1.0f0:3) == coord
    @test Proj.Coord((i for i = 1:3)) == coord
    @test Proj.Coord(coord) === coord
    @test convert(Proj.Coord, coord) === coord
    @test convert(Proj.Coord, (1.0, 2.0, 3.0)) == coord

    @inferred Proj.Coord(1, 2)
    @inferred Proj.Coord((1, 2))
    @inferred Proj.Coord([1, 2])
    @inferred Proj.Coord(SA[1, 2])
end

@testset "in and output types" begin
    trans = Proj.Transformation("EPSG:4326", "EPSG:28992", always_xy=true)
    trans(Proj.proj_coord(5.39, 52.16))
    b = trans(SA[5.39, 52.16, 0.0, 0.0])

    # StaticVector, Vector or Tuple
    x, y, z, t = 5.39, 52.16, 0.0, Inf

    @inferred trans(x, y)
    @inferred trans(x, y, z)
    @inferred trans(x, y, z, t)
    @inferred trans(Proj.Coord(x, y))
    @inferred trans((x, y))
    # for Vector it cannot be precisely inferred due to unknown length
    @inferred Proj.NTuple234 trans([x, y])
    @inferred trans(SA[x, y])

    # SVector{2/3/4, Float64}
    p = trans(SA[5, 52])
    @test is_approx(p, (128410.08537081012, 445806.50883314764))
    p = trans(SA[5.39, 52.16, 2.0])
    @test is_approx(p, (155191.35381147722, 463537.13624246384, 2.0))
    p = trans(SA[5.39, 52.16, 0.0, Inf])
    @test is_approx(p, (155191.3538124342, 463537.1362732911, 0.0, Inf))
end

@testset "network" begin
    as_before = Proj.network_enabled()

    # turn off network, no z transformation
    @test !Proj.enable_network!(false)
    @test !Proj.network_enabled()
    trans_z = Proj.Transformation("EPSG:4326+5773", "EPSG:7856+5711", always_xy=true)
    @test trans_z((151, -33, 5))[3] == 5
    # turn on network, z transformation
    @test Proj.enable_network!(true)
    @test Proj.network_enabled()
    trans_z = Proj.Transformation("EPSG:4326+5773", "EPSG:7856+5711", always_xy=true)
    z = trans_z((151, -33, 5))[3]
    @test z ≈ 5.280647277836724f0

    # 0 args turns it on as well
    Proj.enable_network!(false)
    Proj.enable_network!()
    @test Proj.network_enabled()

    # restore setting as outside the testset
    Proj.enable_network!(as_before)
end
