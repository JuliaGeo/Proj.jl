using Test
using StaticArrays
using Proj
import PROJ_jll

@testset "Error handling" begin
    @test Proj.proj_errno_string(0) === nothing
    @test Proj.proj_errno_string(1) == "Unknown error (code 1)"
    @test Proj.proj_errno_string(Proj.PROJ_ERR_INVALID_OP_WRONG_SYNTAX) == "Invalid PROJ string syntax"

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
    @test a isa AbstractVector
    @test a isa SVector{4,Float64}
    @test a isa Proj.Coord
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
    @test b[1] ≈ 691875.632
    @test b[2] ≈ 6098907.825
    @test b[3] === 0.0
    @test b[4] === Inf

    # inverse transform, back to geographical
    b = Proj.proj_trans(pj, Proj.PJ_INV, b)
    @test b[1] ≈ 12.0
    @test b[2] ≈ 55.0
    @test b[3] === 0.0
    @test b[4] === Inf

    # Clean up
    pj = Proj.proj_destroy(pj)
    pj = Proj.proj_destroy(pj)
    # Julia crashes if proj_destroy is called twice on the same non nullptr,
    # since the contents at that address are already wiped. To prevent this,
    # change the input binding directly after, e.g. pj = proj_destroy(pj)  # -> C_NULL
end

@testset "inverse transformation" begin
    trans = Proj.Transformation("EPSG:4326", "+proj=utm +zone=32 +datum=WGS84")

    # for custom / proj strings, no description can be looked up in the database
    @test repr(trans) == """
    Transformation
        source: WGS 84
        target: unknown"""

    trans⁻¹ = inv(trans)
    trans¹ = inv(trans⁻¹)

    # inverse twice should get the same transform back
    wkt_type = Proj.PJ_WKT2_2019
    @test Proj.proj_as_wkt(trans⁻¹.pj, wkt_type) != Proj.proj_as_wkt(trans.pj, wkt_type)
    @test Proj.proj_as_wkt(trans¹.pj, wkt_type) == Proj.proj_as_wkt(trans.pj, wkt_type)
end

@testset "single transformation" begin
    source_crs = Proj.proj_create("EPSG:4326")
    target_crs = Proj.proj_create("EPSG:28992")
    @test source_crs isa Ptr{Nothing}
    @test target_crs isa Ptr{Nothing}
    trans = Proj.Transformation(source_crs, target_crs)

    # Check that altitude and time inputs are correctly forwarded from the transformation
    @test trans(SA_F64[52.16, 5.39, 5, 2020]) ≈ SA[155191.3538124342, 463537.1362732911, 5.0, 2020.0]

    a = Proj.proj_coord(52.16, 5.39)
    b = Proj.proj_trans(trans.pj, Proj.PJ_FWD, a)
    @test a != b
    @test b ≈ Proj.proj_coord(155191.3538124342, 463537.1362732911)

    # with always_xy=True, we need to use lon/lat, and still get x/y out
    trans = Proj.Transformation(source_crs, target_crs, always_xy = true)
    a = Proj.proj_coord(5.39, 52.16)
    b = Proj.proj_trans(trans.pj, Proj.PJ_FWD, a)
    @test a != b
    @test b ≈ Proj.proj_coord(155191.3538124342, 463537.1362732911)
end

@testset "dense 4D coord vector transformation" begin
    source_crs = Proj.proj_create("EPSG:4326")
    target_crs = Proj.proj_create("EPSG:28992")
    trans = Proj.Transformation(source_crs, target_crs, always_xy = true)
    # This array is mutated in place. Note that this array needs to have 4D elements,
    # with 2D elements it will only do every other one
    A = [Proj.proj_coord(5.39, 52.16) for _ = 1:5]
    err = Proj.proj_trans_array(trans.pj, Proj.PJ_FWD, length(A), A)
    @test err == 0
    B = [Proj.proj_coord(155191.3538124342, 463537.1362732911) for _ = 1:5]
    @test A ≈ B

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
    trans = Proj.Transformation(source_crs, target_crs, always_xy = true)

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
    trans1 = Proj.Transformation("EPSG:4326", "EPSG:28992", always_xy = true)
    trans2 = Proj.Transformation("EPSG:32632", "EPSG:2027", always_xy = true)
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
    Transformation
        source: WGS 84 (with axis order normalized for visualization)
        target: NAD27(76) / UTM zone 15N"""
end

@testset "in and output types" begin
    trans = Proj.Transformation("EPSG:4326", "EPSG:28992", always_xy = true)
    trans(Proj.proj_coord(5.39, 52.16))
    b = trans(SA[5.39, 52.16, 0.0, 0.0])


    # StaticVector, Vector or Tuple
    x, y = 5.39, 52.16
    for inpoint in [SA[x, y], [x, y], (x, y)]
        p = if inpoint isa Vector
            Test.@inferred SArray{S, Float64, 1, L} where {S<:Tuple, L} trans(inpoint)
        else
            Test.@inferred trans(inpoint)
        end
        @test p ≈ [155191.3538124342, 463537.1362732911]
        @test p isa SVector{2, Float64}
    end

    # StaticVectors like GeometryBasics.Point are returned, also with Float32
    p = Test.@inferred trans(Point(5.39f0, 52.16f0))
    @test p ≈ [155191.3538124342, 463537.1362732911]
    @test p isa Point{2, Float32}

    # Integer input will go to the ::Any method and become Float64
    @test trans(SA[1,2]) isa SVector{2, Float64}
    @test trans([5,52]) ≈ [128410.08537081012, 445806.50883314764]

    # SVector{3, Float64}
    p = Test.@inferred trans(SA[5.39, 52.16, 2.0])
    @test p ≈ [155191.35381147722, 463537.13624246384, 2.0]
    @test p isa SVector{3, Float64}

    # SVector{4, Float64}
    p = Test.@inferred trans(SA[5.39, 52.16, 0.0, Inf])
    @test p ≈ [155191.3538124342, 463537.1362732911, 0.0, Inf]
    @test p isa SVector{4, Float64}
end

@testset "network" begin
    as_before = Proj.network_enabled()

    # turn off network, no z transformation
    @test !Proj.enable_network!(false)
    @test !Proj.network_enabled()
    trans_z = Proj.Transformation("EPSG:4326+5773", "EPSG:7856+5711", always_xy = true)
    @test trans_z((151, -33, 5))[3] == 5
    # turn on network, z transformation
    @test Proj.enable_network!(true)
    @test Proj.network_enabled()
    trans_z = Proj.Transformation("EPSG:4326+5773", "EPSG:7856+5711", always_xy = true)
    z = trans_z((151, -33, 5))[3]
    if isinf(z)
        # TODO on CI this hits julia 1.3 all OS, julia 1.6 and nightly Ubuntu only
        @warn "networking not configured correctly"
    else
        @test trans_z((151, -33, 5))[3] ≈ 5.280603319143665
    end

    # 0 args turns it on as well
    Proj.enable_network!(false)
    Proj.enable_network!()
    @test Proj.network_enabled()

    # restore setting as outside the testset
    Proj.enable_network!(as_before)
end
