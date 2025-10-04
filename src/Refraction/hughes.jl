"""
    $(TYPEDEF)

Hughes refraction model.

This algorithm uses the Hughes refraction model to correct solar elevation values for
atmospheric refraction effects.

# Fields
$(TYPEDFIELDS)

# Constructor
- `HUGHES()`: Uses default parameters: pressure = 101325 Pa, temperature = 12 °C
- `HUGHES(pressure, temperature)`: Specify custom pressure [Pa] and temperature [°C]

# References


# Example
```julia
```
"""
struct HUGHES{T} <: RefractionModel where {T<:AbstractFloat}
    "Annual average atmospheric pressure [Pascal]"
    pressure::T
    "Annual average temperature [°C]"
    temperature::T
end

HUGHES() = HUGHES{Float64}(101325.0, 12.0)
