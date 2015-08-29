using Proj4
using FactCheck

# Some very basic sanity checking
wgs84 = Projection("+proj=longlat +datum=WGS84 +no_defs")
utm56 = Projection("+proj=utm +zone=56 +south +datum=WGS84 +units=m +no_defs")

# Reference data computed using GeographicLib's GeoConvert tool
@fact transform(wgs84, utm56, [150 -27 0]) -->
    roughly([202273.912995055 7010024.033113679 0], 1e-6)

dup_wgs84 = Projection("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
@fact transform(wgs84, dup_wgs84, [150 -27 0]) -->
    roughly([150 -27 0], 1e-6)
@fact transform(dup_wgs84, wgs84, [150 -27 0]) -->
    roughly([150 -27 0], 1e-6)

# Taken from https://github.com/proj4js/proj4js/blob/master/test/test.js
sweref99tm = Projection("+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs")
rt90 = Projection("+lon_0=15.808277777799999 +lat_0=0.0 +k=1.0 +x_0=1500000.0 +y_0=0.0 +proj=tmerc +ellps=bessel +units=m +towgs84=414.1,41.3,603.1,-0.855,2.141,-7.023,0 +no_defs")
@fact transform(sweref99tm, rt90, [319180, 6399862]) -->
    roughly([1271137.927154 6404230.291456], 1e-6)
@fact transform(sweref99tm, rt90, [319480 6397862;
                                   329200 6599800]) -->
    roughly([1271414.272854 6402225.564811;
             1283568.895883 6604160.216834], 1e-6)
@fact transform(sweref99tm, rt90, [319480 6397862;
                                   329200 6599800;
                                   319480 6397862;
                                   329200 6599800]) -->
    roughly([1271414.272854 6402225.564811;
             1283568.895883 6604160.216834;
             1271414.272854 6402225.564811;
             1283568.895883 6604160.216834], 1e-6)
@fact transform(rt90, sweref99tm, [1271414.272854 6402225.564811;
                                   1283568.895883 6604160.216834;
                                   1271414.272854 6402225.564811;
                                   1283568.895883 6604160.216834]) -->
    roughly([319480 6397862;
             329200 6599800;
             319480 6397862;
             329200 6599800], 1e-6)

epsg_error = Int[]
for epsg_code in keys(Proj4.epsg)
    try
        proj = Projection(Proj4.epsg[epsg_code])
        proj_string1 = string(proj)
        proj1 = Projection(proj_string1)
        proj_string2 = string(proj1)
        proj2 = Projection(proj_string2)
        proj_string3 = string(proj2)
        @fact proj_string1 --> proj_string2
        @fact proj_string2 --> proj_string3
        @fact proj_string3 --> proj_string1
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
        @fact proj_string1 --> proj_string2
        @fact proj_string2 --> proj_string3
        @fact proj_string3 --> proj_string1
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
    @fact errorFraction --> less_than(0.1)

    println(
    """
    The following projection strings could not be parsed by your version of
    libproj Note that this isn't necessarily a problem, but you won't be able
    to use the projections in question.

    total errors: $(round(100*errorFraction,2))%
    libproj version: $(Proj4.libproj_version())
    """)
    for epsg_code in sort(epsg_error)
        println("[EPSG:$epsg_code] \"$(Proj4.epsg[epsg_code])\"")
    end
    for esri_code in sort(esri_error)
        println("[ESRI:$esri_code] \"$(Proj4.esri[esri_code])\"")
    end
end