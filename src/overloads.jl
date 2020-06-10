# Convenience functions for PJ_COORD

function PJ_COORD(x::Real = 0, y::Real = 0, z::Real = 0, t::Real = 0)
    return PJ_COORD(PJ_XYZT(Cdouble(x), Cdouble(y), Cdouble(z), Cdouble(t)))
end

Base.length(::PJ_COORD) = 4

Base.@propagate_inbounds function Base.getindex(coord::PJ_COORD, i::Int)
    @boundscheck 1 <= i <= 4 || throw(BoundsError(coord,i))
    return getfield(coord.xyzt, i) # getfield also works on Ints
end
