using Dates
using Printf

# Load in `deps.jl`, complaining if it does not exist
const depsjl_path = joinpath(@__DIR__, "..", "deps", "deps.jl")
if !isfile(depsjl_path)
    error("Proj4 not installed properly, run Pkg.build(\"Proj4\"), restart Julia and try again")
end
include(depsjl_path)
check_deps()

const FILENAMES = (epsg_path,
                   esri_path)

parse_projection(line::String) = match(r"<(\d+)>\s+(.*?)\s+<>", line)

println("# Contents of this file is generated on $(now()). Do not edit by hand!")
println("# \$ julia generate_projection_codes.jl > projection_codes.jl\n")

for filename in FILENAMES
    lines = open(filename) do proj_file
        readlines(proj_file)
    end

    println("$(basename(filename)) = Dict(")
    for i=1:length(lines)
        m = parse_projection(lines[i])
        if m === nothing
            continue
        else
            proj_code, proj_string = m.captures
            @printf("  %s => \"%s\", %s\n", proj_code, proj_string, lines[i-1])
        end
    end
    println(")\n")
end
