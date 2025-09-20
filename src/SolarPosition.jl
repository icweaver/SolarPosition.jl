module SolarPosition

include("Positioning/Positioning.jl")

using .Positioning: solar_position, solar_position!, Observer, PSA

export solar_position, solar_position!, Observer, PSA

# to make the makie extension work
export sunpathplot
export sunpathplot!
export sunpathpolarplot
export sunpathpolarplot!

function sunpathplot end
function sunpathplot! end
function sunpathpolarplot end
function sunpathpolarplot! end

end # module
