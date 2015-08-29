# Spatial Reference Objects

A Spatial Reference System Identifier (SRID) is a unique value used to unambiguously identify projected, unprojected, and local spatial coordinate system definitions. Each projected and geographic coordinate system is defined by either a well-known ID (WKID) or a definition string (WKT).

Virtually all major spatial vendors have created their own SRID implementation or refer to those of an authority, such as the European Petroleum Survey Group (EPSG), or Environmental Systems Research Institute (ESRI).

We provide projection codes through their WKIDs in the `epsg` and `esri` dictionaries in `src/projection_codes.jl`. The dictionaries are automatically generated from the proj.4 projection definition strings, defined (in files of the same name) in the nad directory of the proj.4 source distribution. For the uninitiated, their distinction is stated in [the following response](http://gis.stackexchange.com/a/18675) from Michael D. Kennedy:

> If an Esri well-known ID is below 32767, it corresponds to the EPSG ID. WKIDs that are 32767 or above are Esri-defined. Either the object isn't in the [EPSG Geodetic Parameter Dataset](http://www.epsg-registry.org/) yet, or it probably won't be added. If an object is later added to the EPSG Dataset, Esri will update the WKID to match the EPSG one, but the previous value will still work.
> 
> There are some limitations. Esri doesn't follow the axes directions that EPSG does, in ArcGIS Desktop at least, it's always longitude-latitude or easting-northing (xy), although we're picking up the axes order in Server now.
