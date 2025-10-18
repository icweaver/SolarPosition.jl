module SolarPosition

include("Refraction/Refraction.jl")
include("Positioning/Positioning.jl")

using .Positioning: Observer, PSA, NOAA, Walraven, USNO, solar_position, solar_position!
using .Positioning: SolPos, ApparentSolPos, SPASolPos
using .Refraction: RefractionAlgorithm, NoRefraction
using .Refraction: HUGHES, ARCHER, BENNETT, MICHALSKY, SG2, SPA

export solar_position, solar_position!, Observer, PSA, NOAA, Walraven, USNO
export RefractionAlgorithm, NoRefraction
export HUGHES, ARCHER, BENNETT, MICHALSKY, SG2, SPA
export SolPos, ApparentSolPos, SPASolPos

# SPA positioning algorithm is available as SolarPosition.Positioning.SPA
# to avoid name conflict with Refraction.SPA

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
