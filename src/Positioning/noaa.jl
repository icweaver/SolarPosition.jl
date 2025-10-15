struct AutoDeltaT end

"""
    $(TYPEDEF)

NOAA (National Oceanic and Atmospheric Administration) solar position algorithm.

This algorithm is based on NOAA's Solar Position Calculator implementation.
Currently provides a stub implementation for testing purposes.

# Accuracy
Claimed accuracy: ±0.0167° (when fully implemented)

# Literature
Based on the NOAA solar position calculator [NOAA](@cite).

# Status
⚠️  **Note**: This is currently a stub implementation that returns fixed values.
Full implementation is planned for future releases.

# Example
```jldoctest
julia> pos = solar_position(obs, dt, NOAA());  # Note: Currently returns stub values

julia> typeof(pos)
SolPos{Float64}
```
"""
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
