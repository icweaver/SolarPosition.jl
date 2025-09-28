"""
Collection of solar positioning algorithms.
"""
module Positioning

using Dates: datetime2julian, DateTime, hour, minute, second
using TimeZones: ZonedDateTime, UTC
using StructArrays: StructArray, StructVector
using Tables: Tables

abstract type SolarAlgorithm end
abstract type BasicAlg <: SolarAlgorithm end
abstract type ApparentAlg <: SolarAlgorithm end

"""
    Observer{T}

Observer location (deg  rees, meters). Use `Float64` for speed unless you need higher precision.
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

abstract type AbstractSolPos end

struct SolPos{T} <: AbstractSolPos
    azimuth::T
    elevation::T
    zenith::T
end

struct ApparentSolPos{T} <: AbstractSolPos
    azimuth::T
    elevation::T
    zenith::T
    apparent_elevation::T
    apparent_zenith::T
end


function solar_position end

function solar_position(obs::Observer, dt::DateTime, alg::SolarAlgorithm = PSA())
    _solar_position(obs, dt, alg)
end

function solar_position(obs::Observer, dt::ZonedDateTime, alg::SolarAlgorithm = PSA())
    solar_position(obs, DateTime(dt, UTC), alg)
end

function solar_position!(
    pos::StructVector{T},
    obs::Observer,
    dts::Vector{DateTime},
    alg::SolarAlgorithm = PSA(),
) where {T<:AbstractSolPos}
    pos .= _solar_position.(Ref(obs), dts, Ref(alg))
end

include("utils.jl")
include("psa.jl")
include("noaa.jl")

export Observer, PSA, NOAA, solar_position, solar_position!

end
