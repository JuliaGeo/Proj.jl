using Proj
using BenchmarkTools
using StaticArrays

const ctrans = Proj.Transformation("EPSG:4326", "EPSG:28992", always_xy = true)

function timer(p)
    tot = 0.0
    for _ = 1:10_000
        tot += sum(ctrans(p))
    end
    tot
end

function timer(x, y)
    tot = 0.0
    for _ = 1:10_000
        tot += sum(ctrans(x, y))
    end
    tot
end

# test different input types
svector = SA[5.39, 52.16]
vector = [5.39, 52.16]
tupl = (5.39, 52.16)
x, y = 5.39, 52.16

# timed using Julia 1.8.0-beta3
@btime Proj.Coord($svector)  # 2.900 ns (0 allocations: 0 bytes)
@btime Proj.Coord($vector)   # 3.700 ns (0 allocations: 0 bytes)
@btime Proj.Coord($tupl)     # 2.600 ns (0 allocations: 0 bytes)
@btime Proj.Coord($x, $y)    # 2.800 ns (0 allocations: 0 bytes)

@btime timer($svector)       # 9.899 ms (0 allocations: 0 bytes)
@btime timer($vector)        # 9.899 ms (0 allocations: 0 bytes)
@btime timer($tupl)          # 9.908 ms (0 allocations: 0 bytes)
@btime timer($x, $y)         # 9.977 ms (0 allocations: 0 bytes)
