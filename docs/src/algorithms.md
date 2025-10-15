# [Positioning Algorithms](@id algorithms)

Solar position algorithms available in SolarPosition.jl.

| Algorithm | Reference       | Accuracy | Status |
| --------- | --------------- | -------- | ------ |
| PSA       | [BALL01](@cite) | ±0.0083° | ✅     |
| NOAA      | [NOAA](@cite)   | ±0.0167° | ❌     |

## [PSA](@id psa-algorithm)

The PSA (Plataforma Solar de Almería) algorithm is the default high-accuracy solar position algorithm.

The algorithm was originally published by [BALL01](@cite) and was later updated by [BMB20](@cite)
with new coefficients for improved accuracy.

```@docs
SolarPosition.PSA
```

## [NOAA](@id noaa-algorithm)

The NOAA (National Oceanic and Atmospheric Administration) algorithm provides an
alternative implementation based on [NOAA](@cite).

```@docs
SolarPosition.NOAA
```
