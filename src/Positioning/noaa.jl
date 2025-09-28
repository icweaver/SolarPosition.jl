"""
    NOAA

Solar position algorithm based on NOAA's implementation.
"""

struct NOAA <: SolarAlgorithm end

"""
    _solar_position(
        obs::Observer{T},
        dt::DateTime,
        ::NOAA,
    ) -> SolarPosition{T}

NOAA algorithm implementation stub.
"""
function _solar_position(obs::Observer{T}, dt::DateTime, ::NOAA) where {T}
    azimuth = T(π / 4)     # 45 degrees
    elevation = T(π / 6)   # 30 degrees
    zenith = T(π / 2) - elevation
    result = SolarPosition(azimuth, elevation, zenith)
    return result
end
