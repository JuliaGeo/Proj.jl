using Proj
using Test
using GeoInterface
using GeoFormatTypes
const GI = GeoInterface

using GeoInterfaceRecipes
GeoInterfaceRecipes.@enable_geo_plots GeoInterface.Wrappers.WrapperGeometry

ring1 = GI.LinearRing([(1, 2), (7, 4), (5, 6), (1, 2)])
ring2 = GI.LinearRing([(11, 2), (20, 4), (15, 6), (11, 2)])
hole2 = GI.LinearRing([(14, 4), (16, 4), (17, 5), (14, 4)])

# Set up a regular tranformation of the points for reference
source_crs = convert(Proj.CRS, EPSG(4326))
target_crs = convert(Proj.CRS, EPSG(3857))
trans = Proj.Transformation(source_crs, target_crs; always_xy=true)
ref_points3857 = map(GeoInterface.getpoint(multipolygon)) do p
    trans([GeoInterface.x(p), GeoInterface.y(p)])
end

polygon1 = GI.Polygon([ring1])
polygon2 = GI.Polygon([ring2, hole2])
multipolygon = GI.MultiPolygon([polygon1, polygon2])

multipolygon3857 = Proj.reproject(multipolygon, EPSG(4326), EPSG(3857))
multipolygon4326 = Proj.reproject(multipolygon3857; target_crs=EPSG(4326))
points4326_1 = collect(GI.getpoint(multipolygon))
points4326_2 = GI.convert.(Tuple, GI.getpoint(multipolygon4326))
points3857 = GI.convert.(Tuple, GI.getpoint(multipolygon3857))

# Comparison to regular `trans` on points
@test all(map((p1, p2) -> all(map(isapprox, p1, p2)), ref_points3857, points3857))

# Round trip comparison
@test all(map((p1, p2) -> all(map(isapprox, p1, p2)), points4326_1, points4326_2))

# Embedded crs check
@test GI.crs(multipolygon3857) == EPSG(3857)
@test GI.crs(multipolygon4326) == EPSG(4326)
