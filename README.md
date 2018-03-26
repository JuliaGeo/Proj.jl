# Proj4

[![Build status](https://travis-ci.org/JuliaGeo/Proj4.jl.svg?branch=master)](https://travis-ci.org/JuliaGeo/Proj4.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/tscgm13l1pvajqqa/branch/master?svg=true)](https://ci.appveyor.com/project/JuliaGeo/proj4-jl/branch/master)

A simple wrapper around the Proj.4 cartographic projections library.

Basic example:

```julia
using Proj4

wgs84 = Projection("+proj=longlat +datum=WGS84 +no_defs")
utm56 = Projection("+proj=utm +zone=56 +south +datum=WGS84 +units=m +no_defs")

transform(wgs84, utm56, [150 -27 0])
# Should result in [202273.913 7010024.033 0.0]
```

API documentation for the underlying C API may be found here:
https://github.com/OSGeo/proj.4/wiki/ProjAPI
