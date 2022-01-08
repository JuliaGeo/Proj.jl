module Proj

using PROJ_jll
using CEnum
using StaticArrays
using CoordinateTransformations

export PROJ_jll

# re-export CoordinateTransformations methods we implement
export compose, ∘

# type aliases
const Coord = SVector{4, Float64}
const Coord234 = Union{SVector{2, Float64}, SVector{3, Float64}, SVector{4, Float64}}
const PROJ_COMPUTE_VERSION = VersionNumber
const GEODESIC_VERSION_NUM = VersionNumber

include("libproj.jl")
include("coord.jl")
include("error.jl")

"""
Load a null-terminated list of strings

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

const PROJ_LIB = Ref{String}()

"Module initialization function"
function __init__()
    # register custom error handler
    funcptr = @cfunction(log_func, Ptr{Cvoid}, (Ptr{Cvoid}, Cint, Cstring))
    proj_log_func(C_NULL, funcptr)

    # point to the location of the provided shared resources
    PROJ_LIB[] = joinpath(PROJ_jll.artifact_dir, "share", "proj")
    proj_context_set_search_paths(1, [PROJ_LIB[]])
end

end # module
