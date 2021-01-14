"""
    Coord <: FieldVector{4, Float64}

General purpose coordinate type, applicable in two, three and four dimensions. This is the
default coordinate datatype used in PROJ.

Elements can be retrieved either by index 1-4, or by field x, y, z, t. If a Coord does not
represent a cartesian coordinate, using the index may be more clear, as the other coordinate
types listed in the [PJ_COORD docs](https://proj.org/development/reference/datatypes.html#c.PJ_COORD)
are not addressable by name.
"""
struct Coord <: FieldVector{4, Float64}
    x::Float64
    y::Float64
    z::Float64
    t::Float64
end
