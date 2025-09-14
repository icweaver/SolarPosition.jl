"""
Collection of solar positioning algorithms.
"""
module Positioning

using Dates: datetime2julian, DateTime, hour, minute, second
using TimeZones: ZonedDateTime, UTC
using StaticArrays: SVector
using Tables

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
    solar_position(obs::Observer{T}, dt::DateTime; alg::SolarAlgorithm=PSA(), kwargs...) -> SolarPos
    solar_position(obs::Observer{T}, dt::ZonedDateTime; alg::SolarAlgorithm=PSA(), kwargs...) -> SolarPos
    solar_position(latitude::T, longitude::T, altitude::T,
                   dt::Union{DateTime,ZonedDateTime};
                   alg::SolarAlgorithm=PSA(), kwargs...) -> SolarPos
                   where {T<:AbstractFloat}

Compute the apparent solar position for a given observer at time `dt`.

Arguments
---------
- `obs::Observer{T}` : Observer location (latitude, longitude, altitude).
- `latitude, longitude, altitude` : Specify observer location directly.
- `dt::DateTime` or `ZonedDateTime` : Time at which to compute solar position.
- `alg::SolarAlgorithm` : Algorithm to use (default: `PSA()`).
- `kwargs...` : Additional keyword arguments forwarded to the algorithm.

Returns
-------
- `SolarPos` : Struct containing solar zenith, azimuth, elevation, etc.

Notes
-----
All angles are in **radians**.
"""
function solar_position end

function solar_position(
    obs::Observer{T},
    dt::DateTime;
    alg::SolarAlgorithm = PSA(),
    kwargs...,
) where {T}
    _solar_position(obs, dt, alg; kwargs...)
end

function solar_position(
    obs::Observer{T},
    dt::ZonedDateTime;
    alg::SolarAlgorithm = PSA(),
    kwargs...,
) where {T}
    solar_position(obs, DateTime(dt, UTC); alg, kwargs...)
end

function solar_position(
    latitude::T,
    longitude::T,
    altitude::T,
    dt::Union{DateTime,ZonedDateTime};
    alg::SolarAlgorithm = PSA(),
    kwargs...,
) where {T<:AbstractFloat}
    obs = Observer{T}(latitude, longitude, altitude)
    solar_position(obs, dt; alg, kwargs...)
end

function solar_position(
    latitude::Real,
    longitude::Real,
    dt::Union{DateTime,ZonedDateTime};
    alg::SolarAlgorithm = PSA(),
    kwargs...,
)
    solar_position(latitude, longitude, 0.0, dt; alg, kwargs...)
end

function solar_position(
    dt::Union{DateTime,ZonedDateTime};
    latitude::Real,
    longitude::Real,
    altitude::Real = 0.0,
    alg::SolarAlgorithm = PSA(),
    kwargs...,
)
    solar_position(latitude, longitude, altitude, dt; alg, kwargs...)
end

include("utils.jl")
include("noaa.jl")
include("psa.jl")

export NOAA, PSA, Observer, solar_position

end
