"""
    $(TYPEDEF)

NOAA (National Oceanic and Atmospheric Administration) solar position algorithm.

This algorithm is based on NOAA's Solar Position Calculator implementation.
Currently provides a stub implementation for testing purposes.

# Accuracy
Claimed accuracy: ±0.0167° (when fully implemented)

# References
[1] NOAA Global Monitoring Laboratory Solar Position Calculator
    https://gml.noaa.gov/grad/solcalc/calcdetails.html

# Status
⚠️  **Note**: This is currently a stub implementation that returns fixed values.
Full implementation is planned for future releases.

# Example
```julia
# Note: Currently returns stub values
pos = solar_position(obs, dt, NOAA())
```
"""
struct NOAA <: SolarAlgorithm end

function _solar_position(obs::Observer{T}, dt::DateTime, ::NOAA, ::NoRefraction) where {T}
    azimuth = T(π / 4)     # 45 degrees
    elevation = T(π / 6)   # 30 degrees
    zenith = T(π / 2) - elevation
    result = SolPos(azimuth, elevation, zenith)
    return result
end

function _solar_position(
    obs::Observer{T},
    dt::DateTime,
    alg::NOAA,
    refraction::RefractionAlgorithm,
) where {T}
    # First compute basic position
    basic_pos = _solar_position(obs, dt, alg, NoRefraction())

    # Apply refraction correction (to be implemented by specific refraction algorithms)
    apparent_elevation = basic_pos.elevation  # placeholder
    apparent_zenith = basic_pos.zenith  # placeholder

    return ApparentSolPos(
        basic_pos.azimuth,
        basic_pos.elevation,
        basic_pos.zenith,
        apparent_elevation,
        apparent_zenith,
    )
end
