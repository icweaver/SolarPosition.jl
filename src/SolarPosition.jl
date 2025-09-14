module SolarPosition

include("Positioning/Positioning.jl")

using .Positioning: solar_position, PSA

export solar_position, PSA

end # module
