"""
    NOAA

Solar position algorithm based on NOAA's implementation.
"""

struct NOAA <: BasicAlg end

"""
    _solar_position(
        obs::Observer{T},
        dt::DateTime,
        ::NOAA,
    ) -> SolPos{T}

NOAA algorithm implementation stub.
"""
function _solar_position(obs::Observer{T}, dt::DateTime, ::NOAA) where {T}
    azimuth = T(π / 4)     # 45 degrees
    elevation = T(π / 6)   # 30 degrees
    zenith = T(π / 2) - elevation
    result = SolPos(azimuth, elevation, zenith)
    return result
end
