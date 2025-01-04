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
using DynamicQuantities
using Interfaces

using SolarPosition.PositionInterface: SolarPositionAlgorithm, SolarPositionInterface,
                                       declination, equation_of_time, offset_hours,
                                       standard_time, fractional_hour
import ..PositionInterface

"""
$(TYPEDFIELDS)
"""
struct BasicAlgorithm <: SolarPositionAlgorithm
    location::Location
end

""" Calculate the solar position vector (zenith, azimuth) using the basic algorithm.

The basic algorithm is based on the reference implementation by Sandia PVPMC [1]. Some 
of the equations are obtained from NREL's SPA algorithm [2] and the Wikipedia page on 
computing solar zenith angles [3] and solar azimuth angles [4].

# References

- **[1]** Sandia PVPMC. Basic Solar Position Models. URL: https://pvpmc.sandia.gov/modeling-guide/1-weather-design-inputs/sun-position/basic-solar-position-models/
- **[2]** NREL. Solar Position Algorithm for Solar Radiation Applications. URL: https://www.nrel.gov/docs/fy08osti/34302.pdf
- **[3]** Wikipedia. Solar zenith angle. URL: https://en.wikipedia.org/wiki/Solar_zenith_angle
- **[4]** Wikipedia. Solar azimuth angle. URL: https://en.wikipedia.org/wiki/Solar_azimuth_angle
"""
function PositionInterface.sunpos(algorithm::BasicAlgorithm, timestamp::ZonedDateTime)

    # collect location-agnostic quantities
    β = declination(timestamp) # declination [deg]

    # Local longitude  / latitude [deg]
    ϕ_local = algorithm.location.latitude

    # hour angle [deg]
    HRA = hour_angle(timestamp, algorithm.location)

    # solar zenith angle [deg]
    θ_z = acosd(sind(ϕ_local.value) * sind(β.value) +
                cosd(ϕ_local.value) * cosd(β.value) * cosd(HRA.value))

    # solar azimuth angle [deg]
    # θ_a is measured westward from south
    θ_a = atand(sind(HRA.value),
        cosd(HRA.value) * sind(ϕ_local.value) - tand(β.value) * cosd(ϕ_local.value))

    # apply correction θ_a to the range [0 to 360]
    # atand(x,y) outputs values in the range [-180, 180], so we have to apply a correction
    if θ_a < 0
        θ_a *= -1
    else
        θ_a = 360 - θ_a
    end

    return (
        Quantity(θ_z, SymbolicDimensions, deg = 1),
        Quantity(θ_a, SymbolicDimensions, deg = 1))
end

function hour_angle(timestamp::ZonedDateTime, location::Location)
    # equation of time from [deg] to [h], 360 deg = 24 h
    E_qt = equation_of_time(timestamp) * 24us"h" / 360us"deg"

    # Longitude of the standard Time Merdidian [deg]
    λ_LSTM = 15 * offset_hours(timestamp).value * us"deg"

    # local standard time [h]
    T_local = fractional_hour(standard_time(timestamp)) * us"h"
    λ_local = location.longitude

    # solar time [h]
    T_solar = T_local + E_qt + (λ_LSTM - λ_local) / 15us"deg/h"

    # hour angle [deg]
    HRA = 15us"deg/h" * (T_solar - 12us"h")
    # return HRA < 0us"deg" ? HRA + 360us"deg" : mod(HRA, 360us"deg")
end

algorithm = BasicAlgorithm(Location(latitude = 0.0, longitude = 0.0))
ts = now(TimeZones.TimeZone("UTC"))

@implements SolarPositionInterface BasicAlgorithm [Arguments(
    algorithm = algorithm, timestamp = ts)]

end # module BasicAlgorithm