# SolarPosition.jl

[![Development documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaSolarPV.github.io/SolarPosition.jl/dev)
[![Test workflow status](https://github.com/JuliaSolarPV/SolarPosition.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/JuliaSolarPV/SolarPosition.jl/actions/workflows/Test.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JuliaSolarPV/SolarPosition.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaSolarPV/SolarPosition.jl)
[![Lint workflow Status](https://github.com/JuliaSolarPV/SolarPosition.jl/actions/workflows/Lint.yml/badge.svg?branch=main)](https://github.com/JuliaSolarPV/SolarPosition.jl/actions/workflows/Lint.yml?query=branch%3Amain)
[![Docs workflow Status](https://github.com/JuliaSolarPV/SolarPosition.jl/actions/workflows/Docs.yml/badge.svg?branch=main)](https://github.com/JuliaSolarPV/SolarPosition.jl/actions/workflows/Docs.yml?query=branch%3Amain)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

SolarPosition.jl provides a simple, unified interface to a collection of solar position
algorithms written in pure, performant julia. The position of the sun in the sky is
based on date, time, and a given observer location.

![solarposition logo](sunpathpolarplot.png)

A solar position algorithm is commonly used to calculate the solar zenith and
azimuth angles, which are essential for various applications such as solar energy systems,
building design, and climate studies.

## Solar positioning algorithms

Here we provide an overview of the solar positioning algorithms currently implemented
in SolarPosition.jl. Each algorithm is described with its reference paper, claimed
accuracy and implementation status.

| Algorithm | Reference                                                                          | Accuracy | Status |
| --------- | ---------------------------------------------------------------------------------- | -------- | ------ |
| PSA       | [Blanco-Muriel et al.](<https://doi.org/10.1016/S0038-092X(00)00156-0>)            | ±0.0083° | ✅     |
| NOAA      | [Global Monitoring Laboratory](https://gml.noaa.gov/grad/solcalc/calcdetails.html) | ±0.0167° | ❌     |

## How to Cite

If you use SolarPosition.jl in your work, please cite using the reference given in [CITATION.cff](https://github.com/JuliaSolarPV/SolarPosition.jl/blob/main/CITATION.cff).

## Contributing

If you want to make contributions of any kind, please first that a look into our [contributing guide directly on GitHub](docs/src/contributing.md) or the [contributing page on the website](https://JuliaSolarPV.github.io/SolarPosition.jl/dev/contributing/)
