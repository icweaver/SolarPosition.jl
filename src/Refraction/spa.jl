"""
    $(TYPEDEF)

SPA (Solar Position Algorithm) refraction model.

Atmospheric refraction correction from the SPA algorithm.

This function calculates the atmospheric refraction correction of the solar
elevation angle using the method described in Reda and Andreas's [1]
Solar Position Algorithm (SPA).

# Fields
$(TYPEDFIELDS)

# Constructor
- `SPA()`: Uses default parameters: pressure = 101325 Pa, temperature = 12 °C, refraction_limit = -0.5667°
- `SPA(pressure, temperature)`: Specify custom pressure [Pa] and temperature [°C], uses default refraction_limit
- `SPA(pressure, temperature, refraction_limit)`: Also specify refraction limit [degrees]

# Notes
The equation to calculate the refraction correction is given by:

```math
\\text{ref} = \\frac{P}{1010} \\cdot \\frac{283}{273 + T} \\cdot \\frac{1.02}{60 \\cdot \\tan(el + 10.3/(el + 5.11))}
```

where ``el`` is the true solar elevation angle, ``P`` is the annual average local
air pressure in hPa/mbar, and ``T`` is the annual average local air temperature in °C.

The refraction limit parameter determines the solar elevation angle below which
refraction is not applied, as the sun is assumed to be below horizon. Note that
the sun diameter (0.26667°) is added to this limit.

# Literature
This method was described by [RA08](@cite).

# Example
```julia
using SolarPosition

# Create SPA refraction model with default parameters
spa = SPA()

# Or specify custom atmospheric conditions
spa_custom = SPA(101325.0, 25.0)  # 25°C temperature

# With custom refraction limit
spa_limit = SPA(101325.0, 12.0, -1.0)  # Don't correct below -1°

# Apply refraction correction to elevation angle
elevation = 30.0  # degrees
refraction_correction = refraction(spa, elevation)
apparent_elevation = elevation + refraction_correction
```
"""
struct SPA{T} <: RefractionAlgorithm where {T<:AbstractFloat}
    "Annual average atmospheric pressure [Pascal]"
    pressure::T
    "Annual average temperature [°C]"
    temperature::T
    "Minimum elevation angle for refraction correction [degrees]"
    refraction_limit::T
end

SPA() = SPA{Float64}(101325.0, 12.0, -0.5667)
SPA(pressure::T, temperature::T) where {T<:AbstractFloat} =
    SPA{T}(pressure, temperature, T(-0.5667))

function _refraction(model::SPA{T}, elevation_deg::T) where {T<:AbstractFloat}
    # Convert pressure from Pascal to hPa/mbar
    pressure_hPa = model.pressure / T(100.0)

    # Check if sun is above horizon (elevation >= -0.26667 + refraction_limit)
    # The sun diameter of 0.26667 degrees is added to the refraction limit
    above_horizon = elevation_deg >= (T(-0.26667) + model.refraction_limit)

    if !above_horizon
        return T(0.0)
    end

    # Calculate refraction correction using SPA formula
    # ref = (P/1010) * (283/(273+T)) * 1.02 / (60 * tan(radians(el + 10.3/(el+5.11))))
    refraction_correction = (
        (pressure_hPa / T(1010.0)) * (T(283.0) / (T(273.0) + model.temperature)) * T(1.02) /
        (T(60.0) * tan(deg2rad(elevation_deg + T(10.3) / (elevation_deg + T(5.11)))))
    )

    return refraction_correction
end
