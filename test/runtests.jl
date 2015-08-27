using Proj4
using Base.Test

# Some very basic sanity checking
wgs84 = Projection("+proj=longlat +datum=WGS84 +no_defs")
utm56 = Projection("+proj=utm +zone=56 +south +datum=WGS84 +units=m +no_defs")

# Reference data computed using GeographicLib's GeoConvert tool
@test maximum(transform(wgs84, utm56, [150 -27 0]) .-
              [202273.912995055 7010024.033113679 0]) < 1e-6

