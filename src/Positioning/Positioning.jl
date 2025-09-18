"""
Collection of solar positioning algorithms.
"""
module Positioning

using Dates: datetime2julian, DateTime, hour, minute, second
using TimeZones: ZonedDateTime, UTC
using StaticArrays: SVector
using Tables: Tables

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
    solar_position(obs::Observer, dt::DateTime; alg::SolarAlgorithm=PSA(), kwargs...) -> SolarPos
    solar_position(obs::Observer, dt::ZonedDateTime; alg::SolarAlgorithm=PSA(), kwargs...) -> SolarPos
    solar_position(latitude::T, longitude::T, altitude::T, dt::DateTime;
                   alg::SolarAlgorithm=PSA(), kwargs...) -> SolarPos where {T<:AbstractFloat}
    solar_position(latitude::T, longitude::T, altitude::T, dt::ZonedDateTime;
                   alg::SolarAlgorithm=PSA(), kwargs...) -> SolarPos where {T<:AbstractFloat}
    solar_position(latitude::AbstractFloat, longitude::AbstractFloat, dt::DateTime;
                   alg::SolarAlgorithm=PSA(), kwargs...) -> SolarPos
    solar_position(latitude::AbstractFloat, longitude::AbstractFloat, dt::ZonedDateTime;
                   alg::SolarAlgorithm=PSA(), kwargs...) -> SolarPos
    solar_position(dt::DateTime; latitude::AbstractFloat, longitude::AbstractFloat,
                   altitude::AbstractFloat=0.0, alg::SolarAlgorithm=PSA(), kwargs...) -> SolarPos
    solar_position(dt::ZonedDateTime; latitude::AbstractFloat, longitude::AbstractFloat,
                   altitude::AbstractFloat=0.0, alg::SolarAlgorithm=PSA(), kwargs...) -> SolarPos
    solar_position(obs::Observer, dts::AbstractVector{DateTime};
                   alg::SolarAlgorithm=PSA(), kwargs...) -> NamedTuple
    solar_position(dts::AbstractVector{DateTime}; latitude::AbstractFloat, longitude::AbstractFloat,
                   altitude::AbstractFloat=0.0, alg::SolarAlgorithm=PSA(), kwargs...) -> NamedTuple
    solar_position(dts::AbstractVector{ZonedDateTime}; latitude::AbstractFloat, longitude::AbstractFloat,
                   altitude::AbstractFloat=0.0, alg::SolarAlgorithm=PSA(), kwargs...) -> NamedTuple

Compute the apparent solar position for a given observer at time `dt` or vector of times `dts`.

Arguments
---------
- `obs::Observer` : Observer location (latitude, longitude, altitude).
- `latitude, longitude, altitude` : Specify observer location directly.
- `dt::DateTime` or `ZonedDateTime` : Time at which to compute solar position.
- `dts::AbstractVector{DateTime}` or `AbstractVector{ZonedDateTime}` : Vector of times for batch computation.
- `alg::SolarAlgorithm` : Algorithm to use (default: `PSA()`).
- `kwargs...` : Additional keyword arguments forwarded to the algorithm.

Returns
-------
- `SolarPos` : Struct containing solar zenith, azimuth, elevation (for single time).
- `NamedTuple` : Named tuple with `datetime`, `azimuth`, `elevation`, `zenith` vectors (for multiple times).

Notes
-----
All angles are in **radians**.
"""
function solar_position end

function solar_position(obs::Observer, dt::DateTime; alg::SolarAlgorithm = PSA(), kwargs...)
    _solar_position(obs, dt, alg; kwargs...)
end

function solar_position(
    obs::Observer,
    dt::ZonedDateTime;
    alg::SolarAlgorithm = PSA(),
    kwargs...,
)
    solar_position(obs, DateTime(dt, UTC); alg, kwargs...)
end

function solar_position(
    latitude::T,
    longitude::T,
    altitude::T,
    dt::DateTime;
    alg::SolarAlgorithm = PSA(),
    kwargs...,
) where {T<:AbstractFloat}
    obs = Observer{T}(latitude, longitude, altitude)
    solar_position(obs, dt; alg, kwargs...)
end

function solar_position(
    latitude::T,
    longitude::T,
    altitude::T,
    dt::ZonedDateTime;
    alg::SolarAlgorithm = PSA(),
    kwargs...,
) where {T<:AbstractFloat}
    obs = Observer{T}(latitude, longitude, altitude)
    solar_position(obs, dt; alg, kwargs...)
end

function solar_position(
    latitude::AbstractFloat,
    longitude::AbstractFloat,
    dt::DateTime;
    alg::SolarAlgorithm = PSA(),
    kwargs...,
)
    solar_position(latitude, longitude, 0.0, dt; alg, kwargs...)
end

function solar_position(
    latitude::AbstractFloat,
    longitude::AbstractFloat,
    dt::ZonedDateTime;
    alg::SolarAlgorithm = PSA(),
    kwargs...,
)
    solar_position(latitude, longitude, 0.0, dt; alg, kwargs...)
end

function solar_position(
    dt::DateTime;
    latitude::AbstractFloat,
    longitude::AbstractFloat,
    altitude::AbstractFloat = 0.0,
    alg::SolarAlgorithm = PSA(),
    kwargs...,
)
    solar_position(latitude, longitude, altitude, dt; alg, kwargs...)
end

function solar_position(
    dt::ZonedDateTime;
    latitude::AbstractFloat,
    longitude::AbstractFloat,
    altitude::AbstractFloat = 0.0,
    alg::SolarAlgorithm = PSA(),
    kwargs...,
)
    solar_position(latitude, longitude, altitude, dt; alg, kwargs...)
end

function solar_position(
    obs::Observer,
    dts::AbstractVector{DateTime};
    alg::SolarAlgorithm = PSA(),
    kwargs...,
)
    n = length(dts)
    az = zeros(Float64, n)
    el = zeros(Float64, n)
    zn = zeros(Float64, n)

    for (i, dt) in enumerate(dts)
        pos = solar_position(obs, dt; alg, kwargs...)
        az[i] = pos.azimuth
        el[i] = pos.elevation
        zn[i] = pos.zenith
    end

    return (; datetime = dts, azimuth = az, elevation = el, zenith = zn)
end

function solar_position(
    dts::AbstractVector{DateTime};
    latitude::AbstractFloat,
    longitude::AbstractFloat,
    altitude::AbstractFloat = 0.0,
    alg::SolarAlgorithm = PSA(),
    kwargs...,
)
    obs = Observer(latitude, longitude, altitude)
    solar_position(obs, dts; alg, kwargs...)
end

function solar_position(
    dts::AbstractVector{ZonedDateTime};
    latitude::AbstractFloat,
    longitude::AbstractFloat,
    altitude::AbstractFloat = 0.0,
    alg::SolarAlgorithm = PSA(),
    kwargs...,
)
    obs = Observer(latitude, longitude, altitude)
    dts = DateTime.(dts, UTC)
    solar_position(obs, dts; alg, kwargs...)
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
    obs::Observer;
    dt_col::Symbol = :datetime,
    alg::SolarAlgorithm = PSA(),
    kwargs...,
)
    tbl = Tables.columntable(table)
    if !haskey(tbl, dt_col)
        throw(ArgumentError("Input table must have a $(dt_col) column"))
    end

    dts = tbl[dt_col]
    result = solar_position(obs, dts; alg, kwargs...)

    # add columns to the original table
    table.azimuth = result.azimuth
    table.elevation = result.elevation
    table.zenith = result.zenith

    return table
end

function solar_position!(
    table;
    latitude::AbstractFloat,
    longitude::AbstractFloat,
    altitude::AbstractFloat = 0.0,
    alg::SolarAlgorithm = PSA(),
    kwargs...,
)
    obs = Observer(latitude, longitude, altitude)
    solar_position!(table, obs; alg, kwargs...)
end


include("utils.jl")
include("noaa.jl")
include("psa.jl")

export NOAA, PSA, Observer, solar_position, solar_position!

end
