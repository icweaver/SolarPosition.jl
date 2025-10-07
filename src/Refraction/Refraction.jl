"""
    Refraction

Atmospheric refraction models.

# Exported Types
- `HUGHES`: Hughes atmospheric refraction model

# Exported Functions
- `refraction`: Apply refraction correction to elevation angle(s)
"""
module Refraction

using DocStringExtensions: TYPEDFIELDS, TYPEDEF


"""
    RefractionAlgorithm

Abstract base type for atmospheric refraction correction algorithms.

Refraction algorithms compute the apparent position of the sun by correcting
for atmospheric refraction effects.

# Examples
```julia
struct MyRefraction <: RefractionAlgorithm end
```
"""
abstract type RefractionAlgorithm end

"""
    NoRefraction <: RefractionAlgorithm

Indicates that no atmospheric refraction correction should be applied.

This is the default refraction setting for solar position calculations.
When used, only basic solar position (azimuth, elevation, zenith) is computed.
"""
struct NoRefraction <: RefractionAlgorithm end

"""
    refraction(model::RefractionAlgorithm, elevation::T) where {T<:AbstractFloat}

Apply atmospheric refraction correction to the given elevation angle(s).

# Arguments
- `model::RefractionAlgorithm`: Refraction model to use (e.g., `HUGHES()`)
- `elevation::T`: True (unrefracted) solar elevation angle in degrees

# Returns
- Refraction correction in degrees to be added to the elevation angle

# Examples
```julia
using SolarPosition
hughes = HUGHES(101325.0, 15.0)  # 15°C temperature
elevation = 30.0  # 30 degrees
correction = refraction(hughes, elevation)
apparent_elevation = elevation + correction
```
"""
function refraction(model::RefractionAlgorithm, elevation::T) where {T<:AbstractFloat}
    return _refraction(model, elevation)
end

include("hughes.jl")

export RefractionAlgorithm, NoRefraction, HUGHES, refraction

end
