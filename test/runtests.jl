using Proj4
using Test

@testset "Proj4" begin


println("""
C library version: $(Proj4.version)  [\"$(Proj4._get_release())\"]
geodesic support: $(Proj4.has_geodesic_support)
""")

# Some very basic sanity checking
wgs84 = Projection("+proj=longlat +datum=WGS84 +no_defs")
utm56 = Projection("+proj=utm +zone=56 +south +datum=WGS84 +units=m +no_defs")
nad83 = Projection(Proj4.epsg[4269])

# Reference data computed using GeographicLib's GeoConvert tool
@test transform(wgs84, utm56, [150.0, -27.0, 0.0]) ≈
    [202273.912995055, 7010024.033113679, 0] atol=1e-6

dup_wgs84 = Projection("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
@test transform(wgs84, dup_wgs84, [150 -27 0]) ≈
    [150 -27 0] atol=1e-6
@test transform(dup_wgs84, wgs84, [150 -27 0]) ≈
    [150 -27 0] atol=1e-6

# Taken from https://github.com/proj4js/proj4js/blob/master/test/test.js
sweref99tm = Projection("+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs")
rt90 = Projection("+lon_0=15.808277777799999 +lat_0=0.0 +k=1.0 +x_0=1500000.0 +y_0=0.0 +proj=tmerc +ellps=bessel +units=m +towgs84=414.1,41.3,603.1,-0.855,2.141,-7.023,0 +no_defs")
@test transform(sweref99tm, rt90, [319180 6399862]) ≈
    [1271137.927154 6404230.291456] atol=1e-2
@test transform(sweref99tm, rt90, [319480 6397862;
                                   329200 6599800]) ≈
    [1271414.272854 6402225.564811;
     1283568.895883 6604160.216834] atol=1e-2
@test transform(sweref99tm, rt90, [319480 6397862;
                                   329200 6599800;
                                   319480 6397862;
                                   329200 6599800]) ≈
    [1271414.272854 6402225.564811;
     1283568.895883 6604160.216834;
     1271414.272854 6402225.564811;
     1283568.895883 6604160.216834] atol=1e-2
@test transform(rt90, sweref99tm, [1271414.272854 6402225.564811;
                                   1283568.895883 6604160.216834;
                                   1271414.272854 6402225.564811;
                                   1283568.895883 6604160.216834]) ≈
    [319480 6397862;
     329200 6599800;
     319480 6397862;
     329200 6599800] atol=1e-2

# Just to verify that we get different Projections from different (projection) definitions
wgs84 = Projection(Proj4.epsg[4326]) # World
svy21 = Projection(Proj4.epsg[3414]) # Singapore
proj = Projection(Proj4.epsg[3906]) # based on the Australian National Spheroid (bessel ellipse)

wgs84_a, wgs84_es = spheroid_params(wgs84)
svy21_a, svy21_es = spheroid_params(svy21)
proj_a, proj_es = spheroid_params(proj)
@test wgs84_es  ≈ svy21_es atol=1e-6 # same ellipsoid
@test svy21_es  ≈ 0.0066943799901413165 atol=1e-6
@test proj_es   ≈ 0.006674372231802145 atol=1e-6
@test abs(proj_es - wgs84_es) > 1e-6
@test abs(proj_a - wgs84_a) > 500.0

@test !compare_datums(svy21, wgs84)
@test compare_datums(svy21, svy21)
@test is_latlong(wgs84)
@test !is_latlong(utm56)
@test !is_latlong(sweref99tm)
@test !is_latlong(svy21)
@test is_geocent(Projection(Proj4.epsg[4328])) # WGS 84 (geocentric)
@test !is_geocent(wgs84) # WGS 84 (geocentric)

#=
# TODO(cjf): It's unclear exatly what the below was meant to achieve.
# Commented out for now since the tests are broken.
function test_point(point)
    rev = reverse(vec(point))
    rad = deg2rad(point)
    rev_rad = deg2rad(point)

    @test lonlat2xy!(rev, wgs84) ≈ lonlat2xy(reverse(vec(point)), wgs84) atol=1e-6 # inplace
    @test rev ≈ rev_rad atol=1e-6
    @test point ≈ rad2deg(rad) atol=1e-6
end

for point in ([-73.78, 40.64], # JFK
              [-73.78  40.64],
              [103.99,  1.36], # SIN
              [103.99   1.36])
    test_point(point)
end
=#

p1, p2 = [-73.78, 40.64],[103.99, 30.36] # p1, p2 in degrees
proj1, proj2 = wgs84, proj # chosen to have different ellipses
q1, q2 = lonlat2xy(p1, proj1), lonlat2xy(p2, proj2)

if Proj4.has_geodesic_support
    r2 = transform(proj2, proj1, q2)
    dist_q1r2, azi1, azi2 = geod_inverse(q1, r2, proj1)
    dest, azi = geod_direct(q1, azi1, dist_q1r2, proj1)
    @test dest ≈ r2 atol=1e-6
    @test azi ≈ azi2 atol=1e-6
    @test geod_destination(q1, azi1, dist_q1r2, proj1) ≈ r2 atol=1e-6

    # # It is not necessarily symmetric:
    # # You can go q1(azi1) -[dist1]-> r2,
    # # but not    r2(azi2) -[dist1]-> q1
    # # So the following statements are false in general:
    # dest, azi = geod_direct(r2, azi2, dist1, proj1)
    # @test dest ≈ q1 atol=1e-6
    # @test azi ≈ azi1 atol=1e-6
    # @test geod_destination(r2, azi2, dist1, proj1) ≈ q1 atol=1e-6

    # # To get the reverse azimuth to move from r2 back to q1,
    # # make another call to geod_inverse:
    dist_r2q1, azi1, azi2 = geod_inverse(r2, q1, proj1)
    dest, azi = geod_direct(r2, azi1, dist_r2q1, proj1)
    @test dest ≈ q1 atol=1e-6
    @test azi ≈ azi2 atol=1e-6
    @test geod_destination(r2, azi1, dist_r2q1, proj1) ≈ q1 atol=1e-6

    # The distances from both calls to geod_inverse should be the same, i.e.
    @test dist_r2q1 ≈ dist_q1r2 atol=1e-6

    # Doublecheck when we perform the operations in the other projection:
    r1 = transform(proj1, proj2, q1)
    dist_r1q2, azi1, azi2 = geod_inverse(r1, q2, proj2)
    dest, azi = geod_direct(r1, azi1, dist_r1q2, proj2)
    @test dest ≈ q2 atol=1e-6
    @test azi ≈ azi2 atol=1e-6
    @test geod_destination(r1, azi1, dist_r1q2, proj2) ≈ q2 atol=1e-6
    dist_q2r1, azi1, azi2 = geod_inverse(q2, r1, proj1)
    dest, azi = geod_direct(q2, azi1, dist_q2r1, proj1)
    @test dest ≈ r1 atol=1e-6
    @test azi ≈ azi2 atol=1e-6
    @test geod_destination(q2, azi1, dist_q2r1, proj1) ≈ r1 atol=1e-6

    @test geod_distance(r1, q2, proj2) ≈ dist_r1q2 atol=1e-6
    @test geod_distance(q2, r1, proj1) ≈ dist_q2r1 atol=1e-6
    @test geod_distance(q1, r2, proj1) ≈ dist_q1r2 atol=1e-6
    @test geod_distance(r2, q1, proj1) ≈ dist_r2q1 atol=1e-6

    # The distances computed in both projections can be significantly different if the ellipsoids are different
    @test (dist_r1q2 - dist_q1r2) > 5e4
    @test (dist_q2r1 - dist_r2q1) > 5e4

    # So be consistent with your choice of projections when computing distances,
    # and deviate from WGS84 only if you know what you're doing
    @test geod_distance(r1, q2, proj2) ≈ geod_distance(q2, r1, proj2) atol=1e-6
    @test geod_distance(q1, r2, proj1) ≈ geod_distance(r2, q1, proj1) atol=1e-6
    @test geod_distance(r1, q2, proj2) ≈ geod_distance(q2, r1, proj2) atol=1e-6
    @test geod_distance(q1, r2, proj1) ≈ geod_distance(r2, q1, proj1) atol=1e-6
end

epsg_error = Int[]
for epsg_code in keys(Proj4.epsg)
    try
        proj = Projection(Proj4.epsg[epsg_code])
        proj_string1 = string(proj)
        proj1 = Projection(proj_string1)
        proj_string2 = string(proj1)
        proj2 = Projection(proj_string2)
        proj_string3 = string(proj2)
        @test proj_string1 == proj_string2
        @test proj_string2 == proj_string3
        @test proj_string3 == proj_string1
    catch
        push!(epsg_error, epsg_code)
    end
end

esri_error = Int[]
for esri_code in keys(Proj4.esri)
    try
        proj_string = Proj4.esri[esri_code]
        proj = Projection(proj_string)
        proj_string1 = string(proj)
        proj1 = Projection(proj_string1)
        proj_string2 = string(proj1)
        proj2 = Projection(proj_string2)
        proj_string3 = string(proj2)
        @test proj_string1 == proj_string2
        @test proj_string2 == proj_string3
        @test proj_string3 == proj_string1
    catch
        push!(esri_error, esri_code)
    end
end

if length(epsg_error) > 0 || length(esri_error) > 0
    errorFraction = (length(epsg_error) + length(esri_error)) /
                    (length(Proj4.epsg) + length(Proj4.esri))
    # Some errors are ok (due to old libproj versions), but a good fraction of
    # the strings should parse - if not something *really* wrong has probably
    # occurred.
    @test errorFraction < 0.1

    println(
    """
    The following projection strings could not be parsed by your version of
    libproj Note that this isn't necessarily a problem, but you won't be able
    to use the projections in question.

    total errors: $(round(100*errorFraction; digits=2))%
    """)
    for epsg_code in sort(epsg_error)
        println("[EPSG:$epsg_code] \"$(Proj4.epsg[epsg_code])\"")
    end
    for esri_code in sort(esri_error)
        println("[ESRI:$esri_code] \"$(Proj4.esri[esri_code])\"")
    end
end


end # testset "Proj4"
