# [Solar Positioning](@id solar-positioning-algorithms)

Solar position algorithms available in SolarPosition.jl.

| Algorithm | Reference       | Accuracy | Status |
| --------- | --------------- | -------- | ------ |
| PSA       | [BALL01](@cite) | ±0.0083° | ✅     |
| NOAA      | [NOAA](@cite)   | ±0.0167° | ✅     |
| Walraven  | [Wal78](@cite)  | ±0.01°   | ✅     |

## [PSA](@id psa-algorithm)

The PSA (Plataforma Solar de Almería) algorithm is the default high-accuracy solar
position algorithm.

The algorithm was originally published by [BALL01](@cite) and was later updated by
[BMB20](@cite) with new coefficients for improved accuracy.

```@docs
SolarPosition.PSA
```

## [NOAA](@id noaa-algorithm)

The NOAA (National Oceanic and Atmospheric Administration) algorithm provides an
alternative implementation based on [NOAA](@cite).

```@docs
SolarPosition.NOAA
```

## [Walraven](@id walraven-algorithm)

The Walraven algorithm is a solar position algorithm published in 1978 with stated
accuracy of ±0.01°.

The algorithm was originally published by [Wal78](@cite) with corrections from the
1979 Erratum [Wal79](@cite) and azimuth quadrant correction from [Spe89](@cite).

```@docs
SolarPosition.Positioning.Walraven
```
