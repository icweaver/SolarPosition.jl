"""A basic implementation of a solar positioning algorithm.

This algorith is based on the reference implementation by Sandia PVPMC [1].

# References

- **[1]** Sandia PVPMC. Basic Solar Position Models. URL: https://pvpmc.sandia.gov/modeling-guide/1-weather-design-inputs/sun-position/basic-solar-position-models/
"""
module Basic

export BasicAlgorithm

using PVSimBase.GeoLocation: Location
using DocStringExtensions
using TimeZones
using DynamicQuantities: Quantity
using Interfaces

using SolarPosition.PositionInterface: SolarPositionAlgorithm, SolarPositionInterface,
                                       declination, equation_of_time, offset_hours
import ..PositionInterface

"""
$(TYPEDFIELDS)
"""
struct BasicAlgorithm <: SolarPositionAlgorithm
    location::Location
end

function PositionInterface.sunpos(algorithm::BasicAlgorithm, timestamp::ZonedDateTime)
    longitude = algorithm.location.longitude
    latitude = algorithm.location.latitude

    # declination [deg]
    β = declination(timestamp)

    # Local standard Time Merdidian [deg]
    LSTM = 15 * offset_hours(timestamp)

    # equation of time 
    E_qt = equation_of_time(timestamp)
    return (Quantity(0.0, deg = 1), Quantity(0.0, deg = 1))
end

algorithm = BasicAlgorithm(Location(latitude = 0.0, longitude = 0.0))
ts = now(TimeZones.TimeZone("UTC"))

@implements SolarPositionInterface BasicAlgorithm [Arguments(
    algorithm = algorithm, timestamp = ts)]

end # module BasicAlgorithm