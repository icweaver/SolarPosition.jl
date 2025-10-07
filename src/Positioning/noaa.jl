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

struct AutoDeltaT end

struct NOAA <: SolarAlgorithm
    "Difference between terrestial time and UT1 [seconds]"
    delta_t::Union{Float64,AutoDeltaT}
end

NOAA() = NOAA(69.0)  # default delta_t value

function _solar_position(obs::Observer{T}, dt::DateTime, alg::NOAA) where {T}
    jd = datetime2julian(dt)
    jc = (jd - 2451545) / 36525.0

    azimuth = T(π / 4)     # 45 degrees
    elevation = T(π / 6)   # 30 degrees
    zenith = T(π / 2) - elevation
    result = SolPos(azimuth, elevation, zenith)
    return result
end
