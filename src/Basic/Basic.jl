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

function PositionInterface.sunpos(algorithm::BasicAlgorithm, timestamp::ZonedDateTime)

    # declination [deg]
    β = declination(timestamp)

    # Longitude of the standard Time Merdidian [deg]
    λ_LSTM = 15 * offset_hours(timestamp)us"deg"

    # Local longitude  / latitude [deg]
    λ_local = algorithm.location.longitude
    ϕ_local = algorithm.location.latitude

    # Local time, without daylights saving time [h]
    T_local = fractional_hour(standard_time(timestamp)) * us"h"

    # equation of time from [deg] to [h], 360 deg = 24 h
    E_qt = equation_of_time(timestamp) * 24us"h" / 360us"deg"
    println("Timestamp: ", timestamp)
    println("E_qt: ", E_qt * 60us"min/h")
    println("T_local: ", T_local)
    println("λ_LSTM: ", λ_LSTM)
    println("λ_local: ", λ_local)
    println("ϕ_local: ", ϕ_local)
    println("β: ", β)

    # solar time [h]
    T_solar = T_local + E_qt + (λ_LSTM - λ_local) / 15us"deg/h"
    println("T_solar: ", T_solar)

    # hour angle [deg]
    H = 15us"deg/h" * (12us"h" - T_solar)
    println("H: ", H)

    return (
        Quantity(0.0, SymbolicDimensions, deg = 1),
        Quantity(0.0, SymbolicDimensions, deg = 1))

    # # solar zenith angle [deg]
    # θ_z = acosd(sind(ϕ_local.value) * sind(β.value) +
    #             cosd(ϕ_local.value) * cosd(β.value) * cosd(H.value))
    # println("θ_z: ", θ_z)

    # # solar azimuth angle [deg]
    # θ_a = atan2d(sind(H.value),
    #              cosd(H.value) * sind(ϕ_local.value) - tand(β.value) * cosd(ϕ_local.value))
    # return (
    #     Quantity(θ_z, SymbolicDimensions, deg = 1),
    #     Quantity(A, SymbolicDimensions, deg = 1))
end

algorithm = BasicAlgorithm(Location(latitude = 0.0, longitude = 0.0))
ts = now(TimeZones.TimeZone("UTC"))

@implements SolarPositionInterface BasicAlgorithm [Arguments(
    algorithm = algorithm, timestamp = ts)]

end # module BasicAlgorithm