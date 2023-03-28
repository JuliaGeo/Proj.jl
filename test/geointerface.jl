using Proj
using GeoInterface
using GeoFormatTypes
const GI = GeoInterface

linearring1 = GI.LinearRing([(1, 2), (3, 4), (5, 6), (1, 2)])
linearring2 = GI.LinearRing([(11, 2), (13, 4), (15, 6), (11, 2)])

polygon1 = GI.Polygon([linearring1])
polygon2 = GI.Polygon([linearring2])
multipolygon = GI.MultiPolygon([polygon1, polygon2])

Proj.reproject(multipolygon, EPSG(4326), EPSG(3857))

