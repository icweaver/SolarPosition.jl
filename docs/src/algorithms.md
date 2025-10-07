# [Algorithms](@id algorithms)

Solar position algorithms available in SolarPosition.jl.

| Algorithm | Reference                                                                                       | Accuracy | Status |
| --------- | ----------------------------------------------------------------------------------------------- | -------- | ------ |
| PSA       | [Blanco-Muriel et al.](https://www.sciencedirect.com/science/article/abs/pii/S0038092X00001560) | ±0.0083° | ✅     |
| NOAA      | [Global Monitoring Laboratory](https://gml.noaa.gov/grad/solcalc/calcdetails.html)              | ±0.0167° | ❌     |

## [PSA](@id psa-algorithm)

The PSA (Plataforma Solar de Almería) algorithm is the default high-accuracy solar position algorithm.

```@docs
SolarPosition.PSA
```

## [NOAA](@id noaa-algorithm)

The NOAA (National Oceanic and Atmospheric Administration) algorithm provides an alternative implementation.

```@docs
SolarPosition.NOAA
```
