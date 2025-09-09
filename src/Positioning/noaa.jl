"""
    NOAA

Solar position algorithm based on NOAA's implementation.
"""

struct NOAA <: SolarAlgorithm end

"""NOAA algorithm implementation"""

"""
    NOAAOptions{T<:AbstractFloat}

Configuration options for NOAA solar position calculations.

See also: [`NOAA`](@ref)
"""
Base.@kwdef struct NOAAOptions{T<:AbstractFloat}
    delta_t::T = 67.0
end

"""
    _solar_position(
        obs::Observer{T},
        alg::NOAA,
        t::ZonedDateTime,
    ) -> SolarPos{T}

NOAA algorithm implementation stub.
"""
function _solar_position(obs::Observer{T}, ::NOAA, t::ZonedDateTime) where {T}
    azimuth = T(π / 4)     # 45 degrees
    elevation = T(π / 6)   # 30 degrees
    zenith = T(π / 2) - elevation
    result = SolarPos(azimuth, elevation, zenith)
    return result
end
