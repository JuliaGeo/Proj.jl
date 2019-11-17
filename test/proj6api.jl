using Test
import Proj4

@testset "Error handling" begin
    @test Proj4.proj_errno_string(0) == nothing
    @test Proj4.proj_errno_string(1) == "Operation not permitted"
    @test Proj4.proj_errno_string(2) == "No such file or directory"

    # this throws an internal error that is handled by our log_func
    @test_throws Proj4.PROJError Proj4.proj_create("+proj=bobbyjoe")
    # ensure we have reset the error state
    @test Proj4.proj_context_errno() == 0

end

@testset "Database" begin
    crs = Proj4.proj_create_from_database("EPSG", "4326", Proj4.PJ_CATEGORY_CRS, false, C_NULL)
    Proj4.proj_errno(crs)
    Proj4.proj_get_id_code(crs, 0)
    # The following is wrong, but unfortunately segfaults. How to fix other than adding
    # a null check before the ccall in this and other functions?
    # Proj4.proj_get_id_code(C_NULL, 0)
end

@testset "New tests" begin

pj_latlon = Proj4.proj_create("EPSG:4326")

esriwkt = """GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137.0,298.257223563]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]]"""
pj2 = Proj4.proj_create(esriwkt)

@test startswith(Proj4.proj_as_wkt(pj2, Proj4.PJ_WKT1_ESRI, C_NULL), "GEOGCS")
@test startswith(Proj4.proj_as_wkt(pj2, Proj4.PJ_WKT2_2018, C_NULL), "GEOGCRS")

end

@testset "Transformation between CRS" begin
    # taken from http://osgeo-org.1560.x6.nabble.com/PROJ-PROJ-6-0-0-proj-create-operation-factory-context-behavior-td5403470.html
    src = Proj4.proj_create("IGNF:REUN47GAUSSL")   # area : 55.17,-21.42,55.92,-20.76
    tgt = Proj4.proj_create("IGNF:RGAF09UTM20")    # area : -63.2,14.25,-60.73,18.2
    factory = Proj4.proj_create_operation_factory_context(C_NULL)
    @test factory != C_NULL
    @test Proj4.proj_context_errno() == 0
    results = Proj4.proj_create_operations(src, tgt, factory)
    @test results != C_NULL
    n = Proj4.proj_list_get_count(results)
    for i in 1:n
        operation = Proj4.proj_list_get(results, i-1)
        hasballpark = Bool(Proj4.proj_coordoperation_has_ballpark_transformation(operation))
        print("""Operation $i
            Name: $(Proj4.proj_get_name(operation))
            Has Ballpark: $hasballpark
        """)
        info = Proj4.proj_pj_info(operation)
        print("""Info $i:
            ID:$(unsafe_string(info.id))
            Desc:$(unsafe_string(info.description))
            Def:$(unsafe_string(info.definition))
            Inv:$(Bool(info.has_inverse))
            Acc:$(info.accuracy)
        """)
        Proj4.proj_destroy(operation)
    end
    Proj4.proj_list_destroy(results)

    Proj4.proj_operation_factory_context_destroy(factory)
    Proj4.proj_destroy(src)
    Proj4.proj_destroy(tgt)
    # proj_context_destroy(c)
end
