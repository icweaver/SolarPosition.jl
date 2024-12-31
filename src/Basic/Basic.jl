"""A basic implementation of a solar positioning algorithm."""
module Basic

export BasicAlgorithm, sunpos

using PVSimBase.GeoLocation: Location
using DocStringExtensions
using TimeZones
using DynamicQuantities: Quantity
using Interfaces

using SolarPosition.PositionInterface: SolarPositionAlgorithm, SolarPositionInterface

"""
$(TYPEDFIELDS)
"""
struct BasicAlgorithm <: SolarPositionAlgorithm
    location::Location
end

function sunpos(algorithm::BasicAlgorithm, timestamp::ZonedDateTime)
    loc = algorithm.location
    return (Quantity(0.0, deg = 1), Quantity(0.0, deg = 1))
end

algorithm = BasicAlgorithm(Location(latitude = 0.0, longitude = 0.0))
ts = now(TimeZones.TimeZone("UTC"))

@implements SolarPositionInterface BasicAlgorithm [Arguments(
    algorithm = algorithm, timestamp = ts)]

end # module BasicAlgorithm