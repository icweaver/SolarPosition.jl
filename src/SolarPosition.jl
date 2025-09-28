module SolarPosition

include("Positioning/Positioning.jl")

using .Positioning: Observer, PSA, NOAA, solar_position, solar_position!

export solar_position, solar_position!, Observer, PSA, NOAA

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
