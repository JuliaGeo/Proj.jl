# Proj4.jl

[![CI](https://github.com/JuliaGeo/Proj4.jl/workflows/CI/badge.svg)](https://github.com/JuliaGeo/Proj4.jl/actions?query=workflow%3ACI)

A simple Julia wrapper around the [PROJ](https://proj.org/) cartographic projections library.

Quickstart, based on the [PROJ docs](https://proj.org/development/quickstart.html):

```julia
using Proj4

# Proj4.jl implements the CoordinateTransformations.jl API
# A Proj4.Transformation needs the source and target coordinate reference systems
trans = Proj4.Transformation("EPSG:4326", "+proj=utm +zone=32 +datum=WGS84")

# Once created, you can call this object to transform points
# the result will be a SVector from StaticArrays.jl
# Here the (latitude, longitude) of Copenhagen is entered
trans([55, 12])
# -> SVector{2, Float64}(691875.632, 6098907.825)

# Note that above the latitude is passed first, because that is the axis order that the
# EPSG mandates. If you want to pass in (longitude, latitude) / (x, y), you can set the
# `always_xy` keyword to true. For more info see https://proj.org/faq.html#why-is-the-axis-ordering-in-proj-not-consistent
trans = Proj4.Transformation("EPSG:4326", "+proj=utm +zone=32 +datum=WGS84", always_xy=true)

# now we input (longitude, latitude), and get the same result as above
trans([12, 55])
# -> SVector{2, Float64}(691875.632, 6098907.825)

# using `inv` we can reverse the direction, `compose` can combine two transformations in one
inv(trans)([691875.632, 6098907.825]) ≈ [12, 55]



# This is the old API of this package, which will be removed soon
wgs84 = Projection("+proj=longlat +datum=WGS84 +no_defs")
utm56 = Projection("+proj=utm +zone=56 +south +datum=WGS84 +units=m +no_defs")

transform(wgs84, utm56, [150 -27 0])
# Should result in [202273.913 7010024.033 0.0]
```

Note that, as described in https://proj.org/resource_files.html, PROJ has the capability
to use remote grids for transformations that need them. For users that have not set
the environment variable `PROJNETWORK=ON`, or changed `proj.ini`, the networking is
disabled by default. To enable from Julia, run `Proj4.enable_network()`.
`Proj4.network_enabled()` can be used to check the setting. Note that it needs to be set
before creating a transformation, otherwise it will have no effect.

API documentation for the underlying C API may be found here:
https://proj.org/development/reference/index.html
