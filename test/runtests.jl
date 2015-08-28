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

for proj_string in values(Proj4.epsg)
   proj = Projection(proj_string)
   proj_string1 = Proj4._get_def(proj)
   proj1 = Projection(proj_string1)
   proj_string2 = Proj4._get_def(proj1)
   proj2 = Projection(proj_string2)
   proj_string3 = Proj4._get_def(proj2)
   @fact proj_string1 --> proj_string2
   @fact proj_string2 --> proj_string3
   @fact proj_string3 --> proj_string1
end

error_strings = ASCIIString[]
for proj_string in values(Proj4.esri)
    try
        proj = Projection(proj_string)
        proj_string1 = Proj4._get_def(proj)
        proj1 = Projection(proj_string1)
        proj_string2 = Proj4._get_def(proj1)
        proj2 = Projection(proj_string2)
        proj_string3 = Proj4._get_def(proj2)
        @fact proj_string1 --> proj_string2
        @fact proj_string2 --> proj_string3
        @fact proj_string3 --> proj_string1
    catch
        push!(error_strings, proj_string)
    end
end

@fact sort(error_strings) -->
    ["+a=6371000 +b=6371000 +units=m",      # ESRI:53001
     "+a=6371000 +b=6371000 +units=m",      # ESRI:53002
     "+a=6371000 +b=6371000 +units=m",      # ESRI:53011
     "+a=6371000 +b=6371000 +units=m",      # ESRI:53013
     "+a=6371000 +b=6371000 +units=m",      # ESRI:53014
     "+a=6371000 +b=6371000 +units=m",      # ESRI:53015
     "+a=6371000 +b=6371000 +units=m",      # ESRI:53017
     "+a=6371000 +b=6371000 +units=m",      # ESRI:53018
     "+a=6371000 +b=6371000 +units=m",      # ESRI:53019
     "+a=6371000 +b=6371000 +units=m",      # ESRI:53022
     "+a=6371000 +b=6371000 +units=m",      # ESRI:53023
     "+a=6371000 +b=6371000 +units=m",      # ESRI:53024
     "+a=6371000 +b=6371000 +units=m",      # ESRI:53025
     "+a=6371000 +b=6371000 +units=m",      # ESRI:53031
     "+ellps=WGS84 +datum=WGS84 +units=m",  # ESRI:54001
     "+ellps=WGS84 +datum=WGS84 +units=m",  # ESRI:54002
     "+ellps=WGS84 +datum=WGS84 +units=m",  # ESRI:54011
     "+ellps=WGS84 +datum=WGS84 +units=m",  # ESRI:54013
     "+ellps=WGS84 +datum=WGS84 +units=m",  # ESRI:54014
     "+ellps=WGS84 +datum=WGS84 +units=m",  # ESRI:54015
     "+ellps=WGS84 +datum=WGS84 +units=m",  # ESRI:54017
     "+ellps=WGS84 +datum=WGS84 +units=m",  # ESRI:54018
     "+ellps=WGS84 +datum=WGS84 +units=m",  # ESRI:54019
     "+ellps=WGS84 +datum=WGS84 +units=m",  # ESRI:54022
     "+ellps=WGS84 +datum=WGS84 +units=m",  # ESRI:54023
     "+ellps=WGS84 +datum=WGS84 +units=m",  # ESRI:54024
     "+ellps=WGS84 +datum=WGS84 +units=m",  # ESRI:54025
     "+ellps=WGS84 +datum=WGS84 +units=m",  # ESRI:54031
     "+ellps=bessel +units=m"]              # ESRI:102163
