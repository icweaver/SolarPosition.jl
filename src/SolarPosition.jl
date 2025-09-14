module SolarPosition

include("Positioning/Positioning.jl")

using .Positioning: solar_position, solar_position!, Observer, PSA

export solar_position, solar_position!, Observer, PSA

end # module
