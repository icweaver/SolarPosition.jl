"""
Collection of solar positioning algorithms.
"""
module Positioning

using Dates
using TimeZones
using StaticArrays

abstract type SolarAlgorithm end

"""
    Observer{T}

Observer location (degrees, meters). Use `Float64` for speed unless you need higher precision.
"""
struct Observer{T<:AbstractFloat}
    latitude::T         # geodetic latitude (+N)
    longitude::T        # longitude (+E)
    altitude::T         # altitude above MSL
    latitude_rad::T     # latitude in radians
    longitude_rad::T    # longitude in radians
    function Observer{T}(lat::T, lon::T, alt::T = zero(T)) where {T<:AbstractFloat}
        new{T}(lat, lon, alt, deg2rad(lat), deg2rad(lon))
    end
end

Observer(lat::T, lon::T; altitude = 0.0) where {T} = Observer{T}(lat, lon, altitude)
Observer(lat::T, lon::T, alt::T) where {T} = Observer{T}(lat, lon, alt)

# include utility functions shared by algorithms
include("utils.jl")

# solar positioning algorithms
include("noaa.jl")
include("psa.jl")


"""
    SolarPos{T}

Describes a single solar position.
"""
struct SolarPos{T<:AbstractFloat}
    azimuth::T           # azimuth (radians, 0=N, +clockwise, range [-π, π])
    elevation::T         # elevation (radians, range [-π, π])
    zenith::T            # zenith (radians, range [0, π])
end


"""
    solar_position(obs, t; alg) -> SolarPos

Angles are in radians.
"""
function solar_position(
    obs::Observer{T},
    dt::ZonedDateTime;
    alg::SolarAlgorithm = PSA(),
    kwargs...,
) where {T}
    Positioning.solar_position(obs, dt, alg; kwargs...)
end

"""
    solar_position(obs, alg, t, opts, algopts) -> SolarPos

Internal dispatch function for solar position calculation.
"""
function solar_position(obs, dt::ZonedDateTime, alg::SolarAlgorithm; kwargs...)
    _solar_position(obs, dt, alg; kwargs...)
end

export NOAA, PSA, Observer, solar_position

end
