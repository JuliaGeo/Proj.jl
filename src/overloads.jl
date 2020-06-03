# Convenience functions for PJ_COORD

Base.length(::PJ_COORD) = 4

Base.@propagate_inbounds function Base.getindex(coord::PJ_COORD, i::Int)
    Base.@boundscheck @assert i ∈ (1, 2, 3, 4)

    return if i == 1
        coord.xyzt.x
    elseif i == 2
        coord.xyzt.y
    elseif i == 3
        coord.xyzt.x
    elseif i == 4
        coord.xyzt.t
    end
end

# Make this interface (at least for vectors)
# a little more Julian
function proj_trans_generic(P, direction, x::Vector{Float64}, y::Vector{Float64}, z::Vector{Float64} = zeros(length(x)), t::Vector{Float64} = zeros(length(x)))
    return proj_trans_generic(
        P, direction,
        x, sizeof(Float64), length(x),
        y, sizeof(Float64), length(y),
        z, sizeof(Float64), length(z),
        t, sizeof(Float64), length(t),
    )
end
