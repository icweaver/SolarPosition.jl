# SolarPosition.jl

[![Development documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaSolarPV.github.io/SolarPosition.jl/dev)
[![Test workflow status](https://github.com/JuliaSolarPV/SolarPosition.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/JuliaSolarPV/SolarPosition.jl/actions/workflows/Test.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JuliaSolarPV/SolarPosition.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaSolarPV/SolarPosition.jl)
[![Lint workflow Status](https://github.com/JuliaSolarPV/SolarPosition.jl/actions/workflows/Lint.yml/badge.svg?branch=main)](https://github.com/JuliaSolarPV/SolarPosition.jl/actions/workflows/Lint.yml?query=branch%3Amain)
[![Docs workflow Status](https://github.com/JuliaSolarPV/SolarPosition.jl/actions/workflows/Docs.yml/badge.svg?branch=main)](https://github.com/JuliaSolarPV/SolarPosition.jl/actions/workflows/Docs.yml?query=branch%3Amain)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

SolarPosition.jl provides a simple, unified interface to a collection of validated solar position
algorithms written in pure, performant julia.

Solar positioning algorithms are commonly used to calculate the solar zenith and
azimuth angles, which are essential for various applications where the sun is important, such as:

- Solar energy systems
- Building design
- Climate studies
- Astronomy

## Acknowledgement

This package is based on the work done by reachers in the field of solar photovoltaics
in the packages [solposx](https://github.com/assessingsolar/solposx) and
[pvlib-python](https://github.com/pvlib/pvlib-python). In particular the positioning and
refraction methods have been adapted from [solposx](https://github.com/assessingsolar/solposx), while
the SPA algorithm and the deltat calculation are ported from [pvlib-python](https://github.com/pvlib/pvlib-python). These packages also provide validation data necessary to ensure
correctness of the algorithm implementations.

## Example Usage

```julia
julia> using SolarPosition, Dates

julia> # define observer location (latitude, longitude, altitude in meters)
       obs = Observer(52.358134610343214, 4.881269505489815, 0.0)  # Van Gogh Museum
Observer{Float64}(52.358134610343214, 4.881269505489815, 0.0, 0.9138218391528874, 0.08519422454799269, 0.7918436055968163, 0.6107239182113582)

julia> # a whole year of hourly timestamps
       times = collect(DateTime(2023):Hour(1):DateTime(2024));

julia> # compute solar positions for all timestamps
       positions = solar_position(obs, times)
8761-element StructArray(::Vector{Float64}, ::Vector{Float64}, ::Vector{Float64}) with eltype SolPos{Float64}:
 SolPos{Float64}(7.645796258008522, -60.516077401435986, 150.51607740143598)
 SolPos{Float64}(33.774266870245846, -57.24907673755472, 147.2490767375547)
 ⋮
 SolPos{Float64}(339.955567224588, -59.54193321925232, 149.54193321925231)
 SolPos{Float64}(7.703667844963789, -60.532796780625304, 150.5327967806253)
```

## Solar positioning algorithms

Here we provide an overview of the solar positioning algorithms currently implemented
in SolarPosition.jl. Each algorithm is described with its reference paper, claimed
accuracy and implementation status.

| Algorithm | Reference                                                                                       | Accuracy | Status |
| --------- | ----------------------------------------------------------------------------------------------- | -------- | ------ |
| PSA       | [Blanco-Muriel et al.](https://www.sciencedirect.com/science/article/abs/pii/S0038092X00001560) | ±0.0083° | ✅     |
| NOAA      | [Global Monitoring Laboratory](https://gml.noaa.gov/grad/solcalc/calcdetails.html)              | ±0.0167° | ✅     |
| Walraven  | [Walraven, 1978](<https://doi.org/10.1016/0038-092X(78)90155-X>)                                | ±0.0100° | ✅     |
| USNO      | [U.S. Naval Observatory](https://aa.usno.navy.mil/faq/sun_approx)                                | ±0.0500° | ✅     |
| SPA       | [Reda & Andreas, 2008](https://doi.org/10.1016/j.solener.2007.08.003)                            | ±0.0003° | ✅     |

## Refraction correction algorithms

Atmospheric refraction correction algorithms available in SolarPosition.jl.

| Algorithm | Reference                                                                                        | Atmospheric Parameters | Status |
| --------- | ------------------------------------------------------------------------------------------------ | ---------------------- | ------ |
| HUGHES    | [Hughes, 1985](https://pvpmc.sandia.gov/app/uploads/sites/243/2022/10/Engineering-Astronomy.pdf) | Pressure, Temperature  | ✅     |
| ARCHER    | Archer et al., 1980                                                                              | None                   | ✅     |
| BENNETT   | [Bennett, 1982](https://doi.org/10.1017/S0373463300022037)                                       | Pressure, Temperature  | ✅     |
| MICHALSKY | [Michalsky, 1988](<https://doi.org/10.1016/0038-092X(88)90045-X>)                                | None                   | ✅     |
| SG2       | [Blanc & Wald, 2012](https://doi.org/10.1016/j.solener.2012.07.018)                              | Pressure, Temperature  | ✅     |
| SPA       | [Reda & Andreas, 2004](https://doi.org/10.1016/j.solener.2003.12.003)                            | Pressure, Temperature  | ✅     |

## How to Cite

If you use SolarPosition.jl in your work, please cite using the reference given in [CITATION.cff](https://github.com/JuliaSolarPV/SolarPosition.jl/blob/main/CITATION.cff).

## Contributing

If you want to make contributions of any kind, please first that a look into our [contributing guide directly on GitHub](docs/src/contributing.md) or the [contributing page on the website](https://JuliaSolarPV.github.io/SolarPosition.jl/dev/contributing/)
