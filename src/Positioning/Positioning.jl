"""
Collection of solar positioning algorithms.
"""
module Positioning

using Dates: datetime2julian, DateTime, hour, minute, second
using TimeZones: ZonedDateTime, UTC
using StructArrays: StructVector
using Tables: Tables
using DocStringExtensions: TYPEDFIELDS, TYPEDEF

abstract type SolarAlgorithm end
abstract type BasicAlg <: SolarAlgorithm end
abstract type ApparentAlg <: SolarAlgorithm end

"""
    Observer{T} where {T<:AbstractFloat}

Observer location (deg  rees, meters). Accepts a type parameter `T` for the
floating point type to use (e.g. `Float32`, `Float64`).

# Fields
$(TYPEDFIELDS)
"""
struct Observer{T<:AbstractFloat}
    "Geodetic latitude (+N)"
    latitude::T
    "Longitude (+E)"
    longitude::T        # longitude (+E)
    "Altitude above mean sea level (meters)"
    altitude::T         # altitude above MSL
    "Latitude in radians (automatically computed)"
    latitude_rad::T
    "Longitude in radians (automatically computed)"
    longitude_rad::T
    function Observer{T}(lat::T, lon::T, alt::T = zero(T)) where {T<:AbstractFloat}
        new{T}(lat, lon, alt, deg2rad(lat), deg2rad(lon))
    end
end

Observer(lat::T, lon::T; altitude = 0.0) where {T} = Observer{T}(lat, lon, altitude)
Observer(lat::T, lon::T, alt::T) where {T} = Observer{T}(lat, lon, alt)

abstract type AbstractSolPos end

"""
    $(TYPEDEF)

Represents a single solar position calculated for a given observer and time.

---

$(TYPEDFIELDS)
"""
struct SolPos{T} <: AbstractSolPos
    "Azimuth (degrees, 0=N, +clockwise, range [-180, 180])"
    azimuth::T
    "Elevation (degrees, range [-90, 90])"
    elevation::T
    "Zenith = 90 - elevation (degrees, range [0, 180])"
    zenith::T
end

"""
    $(TYPEDEF)

Represents a single solar position calculated for a given observer and time.
Also includes apparent elevation and zenith angles.

---

$(TYPEDFIELDS)
"""
struct ApparentSolPos{T} <: AbstractSolPos
    "Azimuth (degrees, 0=N, +clockwise, range [-180, 180])"
    azimuth::T
    "Elevation (degrees, range [-90, 90])"
    elevation::T
    "Zenith = 90 - elevation (degrees, range [0, 180])"
    zenith::T
    "Apparent elevation (degrees, range [-90, 90])"
    apparent_elevation::T
    "Apparent zenith (degrees, range [0, 180])"
    apparent_zenith::T
end

# trait: map algorithm types to their return types, parameterized by T
result_type(::Type{<:BasicAlg}, ::Type{T}) where {T<:AbstractFloat} = SolPos{T}
result_type(::Type{<:ApparentAlg}, ::Type{T}) where {T<:AbstractFloat} = ApparentSolPos{T}


function solar_position end

function solar_position(
    obs::Observer{T},
    dt::DateTime,
    alg::SolarAlgorithm = PSA(),
) where {T<:AbstractFloat}
    _solar_position(obs, dt, alg)
end

function solar_position(
    obs::Observer{T},
    dt::ZonedDateTime,
    alg::SolarAlgorithm = PSA(),
) where {T<:AbstractFloat}
    solar_position(obs, DateTime(dt, UTC), alg)
end

function solar_position!(
    pos::StructVector{T},
    obs::Observer,
    dts::AbstractVector{Union{DateTime,ZonedDateTime}},
    alg::SolarAlgorithm = PSA(),
) where {T<:AbstractSolPos}
    pos .= solar_position.(Ref(obs), dts, Ref(alg))
end

function solar_position!(
    pos::StructVector{T},
    obs::Observer,
    dts::AbstractVector{DateTime},
    alg::SolarAlgorithm = PSA(),
) where {T<:AbstractSolPos}
    pos .= solar_position.(Ref(obs), dts, Ref(alg))
end

function solar_position!(
    pos::StructVector{T},
    obs::Observer,
    dts::AbstractVector{ZonedDateTime},
    alg::SolarAlgorithm = PSA(),
) where {T<:AbstractSolPos}
    pos .= solar_position.(Ref(obs), dts, Ref(alg))
end

function solar_position(
    obs::Observer{T},
    dts::AbstractVector{Union{DateTime,ZonedDateTime}},
    alg::SolarAlgorithm = PSA(),
) where {T<:AbstractFloat}
    RetType = result_type(typeof(alg), T)
    pos = StructVector{RetType}(undef, length(dts))
    solar_position!(pos, obs, dts, alg)
    pos
end

function solar_position(
    obs::Observer{T},
    dts::AbstractVector{DateTime},
    alg::SolarAlgorithm = PSA(),
) where {T<:AbstractFloat}
    RetType = result_type(typeof(alg), T)
    pos = StructVector{RetType}(undef, length(dts))
    solar_position!(pos, obs, dts, alg)
    pos
end

function solar_position(
    obs::Observer{T},
    dts::AbstractVector{ZonedDateTime},
    alg::SolarAlgorithm = PSA(),
) where {T<:AbstractFloat}
    RetType = result_type(typeof(alg), T)
    pos = StructVector{RetType}(undef, length(dts))
    solar_position!(pos, obs, dts, alg)
    pos
end


"""
    solar_position!(table, obs::Observer; dt_col::Symbol=:datetime, alg::SolarAlgorithm=PSA(), kwargs...)
    solar_position!(table; latitude::AbstractFloat, longitude::AbstractFloat,
                    altitude::AbstractFloat=0.0, alg::SolarAlgorithm=PSA(), kwargs...)

Compute solar positions for all times in a table and add the results as new columns.

Arguments
---------
- `table` : Table-like object with datetime column (must support Tables.jl interface).
- `obs::Observer` : Observer location (latitude, longitude, altitude).
- `latitude, longitude, altitude` : Specify observer location directly.
- `dt_col::Symbol` : Name of the datetime column (default: `:datetime`).
- `alg::SolarAlgorithm` : Algorithm to use (default: `PSA()`).
- `kwargs...` : Additional keyword arguments forwarded to the algorithm.

Returns
-------
- Modified table with added columns: `azimuth`, `elevation`, `zenith`.

Notes
-----
All angles are in **radians**. The input table is modified in-place by adding new columns.
"""
function solar_position!(
    table,
    obs::Observer{T},
    alg::SolarAlgorithm = PSA();
    dt_col::Symbol = :datetime,
) where {T<:AbstractFloat}
    tbl = Tables.columntable(table)
    if !haskey(tbl, dt_col)
        throw(ArgumentError("Input table must have a $(dt_col) column"))
    end

    dts = tbl[dt_col]
    result = StructArrays.components(solar_position(obs, dts, alg))

    # add columns to the original table
    table.azimuth = result.azimuth
    table.elevation = result.elevation
    table.zenith = result.zenith

    return table
end

include("utils.jl")
include("psa.jl")
include("noaa.jl")

export Observer, PSA, NOAA, solar_position, solar_position!, SolPos, ApparentSolPos

end
