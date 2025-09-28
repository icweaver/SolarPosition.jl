"""
    Positioning

Collection of solar positioning algorithms and related functionality.

This module provides the core solar position calculation algorithms, observer location handling,
and result types for SolarPosition.jl. It includes implementations of various solar position
algorithms such as PSA and NOAA.

# Exported Types
- [`Observer`](@ref): Geographic observer location
- [`SolPos`](@ref): Basic solar position result
- [`ApparentSolPos`](@ref): Solar position with atmospheric corrections
- [`PSA`](@ref): PSA algorithm implementation
- [`NOAA`](@ref): NOAA algorithm implementation

# Exported Functions
- [`solar_position`](@ref): Calculate solar positions
- [`solar_position!`](@ref): In-place solar position calculation
"""
module Positioning

using Dates: datetime2julian, DateTime, hour, minute, second
using TimeZones: ZonedDateTime, UTC
using StructArrays: StructArrays
using Tables: Tables
using DocStringExtensions: TYPEDFIELDS, TYPEDEF, TYPEDSIGNATURES

"""
    SolarAlgorithm

Abstract base type for all solar position algorithms.

All concrete algorithm types must inherit from either [`BasicAlg`](@ref) or [`ApparentAlg`](@ref).
"""
abstract type SolarAlgorithm end

"""
    BasicAlg <: SolarAlgorithm

Abstract type for algorithms that compute basic solar position (azimuth, elevation, zenith).

Algorithms inheriting from this type return [`SolPos`](@ref) results.
"""
abstract type BasicAlg <: SolarAlgorithm end

"""
    ApparentAlg <: SolarAlgorithm

Abstract type for algorithms that compute both basic and apparent solar positions.

Algorithms inheriting from this type return [`ApparentSolPos`](@ref) results with
additional atmospheric refraction corrections.
"""
abstract type ApparentAlg <: SolarAlgorithm end

"""
    Observer{T} where {T<:AbstractFloat}

Observer location (deg  rees, meters). Accepts a type parameter `T` for the
floating point type to use (e.g. `Float32`, `Float64`).

---
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
struct SolPos{T} <: AbstractSolPos where {T<:AbstractFloat}
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
struct ApparentSolPos{T} <: AbstractSolPos where {T<:AbstractFloat}
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

"""
    $(TYPEDSIGNATURES)

Calculate solar position(s) for given observer location(s) and time(s).

This function computes the solar position (azimuth, elevation, and zenith angles) based on
an observer's geographic location and timestamp(s). It supports multiple input formats and
automatically handles time zone conversions.

---

# Arguments
- `obs::Observer`: Observer location with latitude, longitude, and altitude
- `dt::DateTime` or `dt::ZonedDateTime`: Single timestamp
- `dts::AbstractVector{DateTime}` or `dts::AbstractVector{ZonedDateTime}`: Multiple timestamps
- `alg::SolarAlgorithm`: Solar positioning algorithm (default: `PSA()`)

---

# Returns
- For single timestamps: `SolPos` or `ApparentSolPos` struct containing angles
- For multiple timestamps: `StructVector` of solar position data

---

# Angles Convention
All returned angles are in **degrees**:
- **Azimuth**: 0° = North, positive clockwise, range [-180°, 180°]
- **Elevation**: angle above horizon, range [-90°, 90°]
- **Zenith**: angle from zenith (90° - elevation), range [0°, 180°]

---

# Examples
## Single timestamp calculation
```julia
using SolarPosition, Dates, TimeZones

# Define observer location (San Francisco)
obs = Observer(37.7749, -122.4194, 100.0)

# Calculate position at specific time
dt = ZonedDateTime(2023, 6, 21, 12, 0, 0, tz"America/Los_Angeles")
pos = solar_position(obs, dt)

println("Azimuth: \$(pos.azimuth)°")
println("Elevation: \$(pos.elevation)°")
println("Zenith: \$(pos.zenith)°")
```

## Multiple timestamps calculation
```julia
# Generate hourly timestamps for a day
times = collect(DateTime(2023, 6, 21):Hour(1):DateTime(2023, 6, 22))
positions = solar_position(obs, times)

# Access as StructVector (acts like array of structs)
println("First position: ", positions[1])
println("All azimuths: ", positions.azimuth)
```

## Using different algorithms
```julia
# Use NOAA algorithm instead of default PSA
pos_noaa = solar_position(obs, dt, NOAA())
```

# Supported Input Types
- **Observer**: `Observer{T}` struct with lat/lon/altitude
- **Single time**: `DateTime`, `ZonedDateTime`
- **Multiple times**: `Vector{DateTime}`, `Vector{ZonedDateTime}`
- **Algorithm**: Any `SolarAlgorithm` subtype

# Time Zone Handling
- `DateTime` inputs are assumed to be in UTC
- `ZonedDateTime` inputs are automatically converted to UTC
- For local solar time calculations, use appropriate time zones

# Performance Notes
- Vectorized operations are optimized for multiple timestamps
- Type-stable implementations for both `Float32` and `Float64`
- Broadcasting-friendly for large datasets

See also: [`solar_position!`](@ref), [`Observer`](@ref), [`PSA`](@ref), [`NOAA`](@ref)
"""
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
    pos::StructArrays.StructVector{T},
    obs::Observer,
    dts::AbstractVector{Union{DateTime,ZonedDateTime}},
    alg::SolarAlgorithm = PSA(),
) where {T<:AbstractSolPos}
    pos .= solar_position.(Ref(obs), dts, Ref(alg))
end

function solar_position!(
    pos::StructArrays.StructVector{T},
    obs::Observer,
    dts::AbstractVector{DateTime},
    alg::SolarAlgorithm = PSA(),
) where {T<:AbstractSolPos}
    pos .= solar_position.(Ref(obs), dts, Ref(alg))
end

function solar_position!(
    pos::StructArrays.StructVector{T},
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
    pos = StructArrays.StructVector{RetType}(undef, length(dts))
    solar_position!(pos, obs, dts, alg)
    pos
end

function solar_position(
    obs::Observer{T},
    dts::AbstractVector{DateTime},
    alg::SolarAlgorithm = PSA(),
) where {T<:AbstractFloat}
    RetType = result_type(typeof(alg), T)
    pos = StructArrays.StructVector{RetType}(undef, length(dts))
    solar_position!(pos, obs, dts, alg)
    pos
end

function solar_position(
    obs::Observer{T},
    dts::AbstractVector{ZonedDateTime},
    alg::SolarAlgorithm = PSA(),
) where {T<:AbstractFloat}
    RetType = result_type(typeof(alg), T)
    pos = StructArrays.StructVector{RetType}(undef, length(dts))
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
The input table is modified **in-place** by adding new columns.
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

    # add the result columns to the table
    for (key, value) in pairs(result)
        table[!, key] = value
    end
end

"""
    $(TYPEDSIGNATURES)

Non-mutating version of [`solar_position!`](@ref) that returns a modified copy of the input table.

See [`solar_position!`](@ref) for detailed documentation of arguments, examples, and usage patterns.
"""
function solar_position(
    table,
    obs::Observer{T},
    alg::SolarAlgorithm = PSA();
    kwargs...,
) where {T<:AbstractFloat}
    table_copy = copy(table)
    solar_position!(table_copy, obs, alg; kwargs...)
    return table_copy
end

include("utils.jl")
include("psa.jl")
include("noaa.jl")

export Observer, PSA, NOAA, solar_position, solar_position!, SolPos, ApparentSolPos

end
