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
    lat_deg::T      # geodetic latitude (+N)
    lon_deg::T      # longitude (+E)
    elev_m::T       # elevation above MSL
end

Observer(lat, lon; elev = 0.0) = Observer{Float64}(lat, lon, elev)

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
function solar_position(obs::Observer{T}, t::ZonedDateTime; alg::SolarAlgorithm) where {T}
    Positioning.solar_position(obs, alg, t)
end

"""
    solar_position(obs, alg, t, opts, algopts) -> SolarPos

Internal dispatch function for solar position calculation.
"""
function solar_position(obs, alg::SolarAlgorithm, t)
    _solar_position(obs, alg, t)
end

export NOAA, PSA, Observer, solar_position

end
