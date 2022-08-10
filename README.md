do not merge

# Proj.jl

[![CI](https://github.com/JuliaGeo/Proj.jl/workflows/CI/badge.svg)](https://github.com/JuliaGeo/Proj.jl/actions?query=workflow%3ACI)

A simple [Julia](https://julialang.org/) wrapper around the [PROJ](https://proj.org/)
cartographic projections library. This package has been renamed from [Proj4.jl](https://github.com/JuliaGeo/Proj.jl/tree/v0.7.6) to Proj.jl.

Quickstart, based on the [PROJ docs](https://proj.org/development/quickstart.html):

```julia
using Proj

# Proj.jl implements the CoordinateTransformations.jl API.
# A Proj.Transformation needs the source and target coordinate reference systems.
trans = Proj.Transformation("EPSG:4326", "+proj=utm +zone=32 +datum=WGS84")

# Once created, you can call this object to transform points.
# The result will be a tuple of Float64s, of length 2, 3 or 4 depending on the input length.
# The 3rd coordinate is elevation (default 0), and the 4th is time (default Inf).
# Here the (latitude, longitude) of Copenhagen is entered
trans(55, 12)
# -> (691875.632137542, 6.098907825129169e6)
# Passing coordinates as a single tuple or vector also works.

# Note that above the latitude is passed first, because that is the axis order that the
# EPSG mandates. If you want to pass in (longitude, latitude) / (x, y), you can set the
# `always_xy` keyword to true. For more info see https://proj.org/faq.html#why-is-the-axis-ordering-in-proj-not-consistent
trans = Proj.Transformation("EPSG:4326", "+proj=utm +zone=32 +datum=WGS84", always_xy=true)

# now we input (longitude, latitude), and get the same result as above
trans(12, 55)
# -> (691875.632137542, 6.098907825129169e6)

# using `inv` we can reverse the direction, `compose` can combine two transformations in one
inv(trans)(691875.632137542, 6.098907825129169e6) == (12, 55)
```

Note that, as described in https://proj.org/resource_files.html, PROJ has the capability
to use remote grids for transformations that need them. Unless you have manually set
the environment variable `PROJNETWORK=ON` or changed `proj.ini`, networking is
disabled by default. To enable from Julia, run `Proj.enable_network!()`.
`Proj.network_enabled()` can be used to check the setting. Note that it needs to be set
before creating a transformation, otherwise it will have no effect.

API documentation for the underlying C API may be found here:
https://proj.org/development/reference/index.html
