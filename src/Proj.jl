module Proj

using PROJ_jll
using CEnum
using CoordinateTransformations
using NetworkOptions: ca_roots
import GeoFormatTypes as GFT

export PROJ_jll
export PJ_DIRECTION, PJ_FWD, PJ_IDENT, PJ_INV

"""
    struct Coord <: AbstractVector{Float64}

    Coord(x, y, [z = 0], [t = Inf])
    Coord(v::AbstractVector{<:Real})
    Coord(v)

Represent a coordinate with 4 Float64 values. Struct for interoperability with the PROJ C
API, specifically anything that expects a
[`PJ_COORD`](https://proj.org/development/reference/datatypes.html#c.PJ_COORD).

The constructors accept either 2 to 4 numbers, or 1 collection of 2 to 4 numbers, with the
first two required numbers representing x and y coordinates. Number 3 is the elevation
(defaults to 0), and number 4 is the time in years (defaults to Inf).

The four fields are called x, y, z and t, but note that depending on the [axis
ordering](https://proj.org/faq.html#why-is-the-axis-ordering-in-proj-not-consistent) the
field x may represent y and vice versa. You can use getindex `coord[2]` to avoid confusion.

The user generally does not need to create a `Coord` directly, since the input coordinates
are automatically converted to `Coord` by ccall. Therefore the constuctors need to be as
flexible as the call methods on the `Transformation`.

# Examples
```julia
julia> Proj.Coord(1.0, 2.0)
4-element Proj.Coord:
  1.0
  2.0
  0.0
 Inf

julia> Proj.Coord((1.0, 2.0, 3.0))
4-element Proj.Coord:
  1.0
  2.0
  3.0
 Inf
```
"""
struct Coord <: AbstractVector{Float64}
    x::Float64
    y::Float64
    z::Float64
    t::Float64
    Coord(x, y, z = 0.0, t = Inf) = new(x, y, z, t)
end

# this shields a StackOverflow from the splatting constructor
Coord(::Real) = error("Proj.Coord takes 2 to 4 numbers, one given")
Coord(v) = Coord(v...)

function Coord(v::AbstractVector{<:Real})
    n = length(v)
    return if n == 2
        Coord(v[begin], v[begin+1])
    elseif n == 3
        Coord(v[begin], v[begin+1], v[begin+2])
    elseif n == 4
        Coord(v[begin], v[begin+1], v[begin+2], v[begin+3])
    else
        error("Proj.Coord takes 2 to 4 numbers")
    end
end

Base.convert(::Type{Coord}, x) = Coord(x)
Base.convert(::Type{Coord}, x::Coord) = x

Base.length(::Coord) = 4
Base.size(::Coord) = (4,)
Base.getindex(coord::Coord, i::Int) = getfield(coord, i)
Base.IndexStyle(::Type{Coord}) = IndexLinear()
Base.eltype(::Coord) = Float64

# type aliases
const NTuple234 = Union{NTuple{2,Float64},NTuple{3,Float64},NTuple{4,Float64}}
const PROJ_COMPUTE_VERSION = VersionNumber
const GEODESIC_VERSION_NUM = VersionNumber

include("libproj.jl")
include("crs.jl")
include("coord.jl")
include("error.jl")

"""
    unsafe_loadstringlist(ptr::Ptr{Cstring})

Load a null-terminated list of strings.

It takes a `PROJ_STRING_LIST`, which is a `Ptr{Cstring}`, and returns a `Vector{String}`.
"""
function unsafe_loadstringlist(ptr::Ptr{Cstring})
    strings = String[]
    (ptr == C_NULL) && return strings
    i = 1
    cstring = unsafe_load(ptr, i)
    while cstring != C_NULL
        push!(strings, unsafe_string(cstring))
        i += 1
        cstring = unsafe_load(ptr, i)
    end
    proj_string_list_destroy(ptr)
    return strings
end

"Prevent an error converting a null pointer to a string, returns `nothing` instead"
aftercare(x::Cstring) = x == C_NULL ? nothing : unsafe_string(x)
aftercare(x::Ptr{Cstring}) = unsafe_loadstringlist(x)

const PROJ_DATA = Ref{String}()

"Module initialization function"
function __init__()
    # register custom error handler
    funcptr = @cfunction(log_func, Ptr{Cvoid}, (Ptr{Cvoid}, Cint, Cstring))
    proj_log_func(C_NULL, funcptr)

    # set path to CA certificates
    ca_path = ca_roots()
    if ca_path !== nothing
        proj_context_set_ca_bundle_path(ca_path)
    end

    # point to the location of the provided shared resources
    PROJ_DATA[] = joinpath(PROJ_jll.artifact_dir, "share", "proj")
    proj_context_set_search_paths(1, [PROJ_DATA[]])
end

end # module
