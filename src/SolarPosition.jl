module SolarPosition

using Dates
using TimeZones

include("Positioning/Positioning.jl")
using .Positioning

# main types and functions
export Observer, SolarPos, CommonOptions
export solar_position
export Positioning

Base.@kwdef struct CommonOptions{T<:AbstractFloat}
    radians::Bool = false               # output in radians if true, degrees by default
end
CommonOptions() = CommonOptions{Float64}()


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
    solar_position(obs, t; alg, opts=CommonOptions(), algopts=nothing) -> SolarPos

Angles are in radians.
"""
function solar_position(
    obs::Observer{T},
    t::ZonedDateTime;
    alg::SolarAlgorithm,
    opts::CommonOptions{T} = CommonOptions{T}(),
    algopts = nothing,
) where {T}
    Positioning.solar_position(obs, alg, t, opts, algopts)
end

end # module
