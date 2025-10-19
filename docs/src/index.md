```@meta
CurrentModule = SolarPosition
```

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

A solar position algorithm is commonly used to calculate the solar zenith and
azimuth angles, which are essential for various applications such as solar energy systems,
building design, and climate studies.

## Example Usage

```julia
using Dates
using SolarPosition

# define observer location (latitude, longitude, altitude in meters)
obs = Observer(52.358134610343214, 4.881269505489815, 0.0)  # Van Gogh Museum

# a whole year of hourly timestamps
times = collect(DateTime(2023):Hour(1):DateTime(2024))

# compute solar positions for all timestamps
positions = solar_position(obs, times)
```

## Solar positioning algorithms

Here we provide an overview of the solar positioning algorithms currently implemented
in SolarPosition.jl. Each algorithm is described with its reference paper, claimed
accuracy and implementation status.

| Algorithm                                             | Reference                                                                                       | Accuracy | Status |
| ----------------------------------------------------- | ----------------------------------------------------------------------------------------------- | -------- | ------ |
| [`PSA`](@ref SolarPosition.Positioning.PSA)           | [Blanco-Muriel et al.](https://www.sciencedirect.com/science/article/abs/pii/S0038092X00001560) | ±0.0083° | ✅     |
| [`NOAA`](@ref SolarPosition.Positioning.NOAA)         | [Global Monitoring Laboratory](https://gml.noaa.gov/grad/solcalc/calcdetails.html)              | ±0.0167° | ✅     |
| [`Walraven`](@ref SolarPosition.Positioning.Walraven) | [Wal78](@cite)                                                                                  | ±0.0100° | ✅     |
| [`USNO`](@ref SolarPosition.Positioning.USNO)         | [USNO](@cite)                                                                                   | ±0.0500° | ✅     |
| [`SPA`](@ref SolarPosition.Positioning.SPA)           | [RA08](@cite)                                                                                   | ±0.0003° | ✅     |

## Refraction correction algorithms

Atmospheric refraction correction algorithms available in SolarPosition.jl.

| Algorithm                                              | Reference      | Atmospheric Parameters | Status |
| ------------------------------------------------------ | -------------- | ---------------------- | ------ |
| [`HUGHES`](@ref SolarPosition.Refraction.HUGHES)       | [Hug85](@cite) | Pressure, Temperature  | ✅     |
| [`ARCHER`](@ref SolarPosition.Refraction.ARCHER)       | [Arc80](@cite) | None                   | ✅     |
| [`BENNETT`](@ref SolarPosition.Refraction.BENNETT)     | [Ben82](@cite) | Pressure, Temperature  | ✅     |
| [`MICHALSKY`](@ref SolarPosition.Refraction.MICHALSKY) | [Mic88](@cite) | None                   | ✅     |
| [`SG2`](@ref SolarPosition.Refraction.SG2)             | [BW12](@cite)  | Pressure, Temperature  | ✅     |
| [`SPARefraction`](@ref SolarPosition.Refraction.SPARefraction)             | [RA08](@cite)  | Pressure, Temperature  | ✅     |

## How to Cite

If you use SolarPosition.jl in your work, please cite using the reference given in [CITATION.cff](https://github.com/JuliaSolarPV/SolarPosition.jl/blob/main/CITATION.cff).

## Contributing

If you want to make contributions of any kind, please first that a look into our [contributing guide directly on GitHub](https://github.com/JuliaSolarPV/SolarPosition.jl/blob/main/docs/src/contributing.md) or the [contributing page on the website](https://JuliaSolarPV.github.io/SolarPosition.jl/dev/contributing/)
