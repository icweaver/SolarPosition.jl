```@meta
CurrentModule = SolarPosition
```

# SolarPosition.jl

SolarPosition.jl provides a simple, unified interface to a collection of solar position
algorithms written in pure, performant julia. The position of the sun in the sky is
based on date, time, and a given observer location.

A solar position algorithm is commonly used to calculate the solar zenith and
azimuth angles, which are essential for various applications such as solar energy systems,
building design, and climate studies.

## Solar positioning algorithms

Here we provide an overview of the solar positioning algorithms currently implemented
in SolarPosition.jl. Each algorithm is described with its reference paper, claimed
accuracy and implementation status.

| Algorithm | Reference                                                                          | Accuracy | Status |
| --------- | ---------------------------------------------------------------------------------- | -------- | ------ |
| PSA       | [Blanco-Muriel et al.](https://doi.org/10.1016/S0038-092X(00)00156-0)             | ±0.0083° | ✅     |
| NOAA      | [Global Monitoring Laboratory](https://gml.noaa.gov/grad/solcalc/calcdetails.html) | ±0.0167° | ❌     |
