# [Solar Positioning](@id solar-positioning-algorithms)

Solar position algorithms available in SolarPosition.jl.

| Algorithm                                             | Reference       | Accuracy      | Status |
| ----------------------------------------------------- | --------------- | ------------- | ------ |
| [`PSA`](@ref SolarPosition.Positioning.PSA)           | [BALL01](@cite) | ±0.0083°      | ✅     |
| [`NOAA`](@ref SolarPosition.Positioning.NOAA)         | [NOAA](@cite)   | ±0.0167°      | ✅     |
| [`Walraven`](@ref SolarPosition.Positioning.Walraven) | [Wal78](@cite)  | ±0.0100°      | ✅     |
| [`USNO`](@ref SolarPosition.Positioning.USNO)         | [USNO](@cite)   | ±0.0500°      | ✅     |
| [`SPA`](@ref SolarPosition.Positioning.SPA)           | [RA08](@cite)   | ±0.0003°      | ✅     |

## [PSA](@id psa-algorithm)

The PSA (Plataforma Solar de Almería) algorithm is the default high-accuracy solar
position algorithm.

The algorithm was originally published by [BALL01](@cite) and was later updated by
[BMB20](@cite) with new coefficients for improved accuracy.

```@docs
SolarPosition.Positioning.PSA
```

## [NOAA](@id noaa-algorithm)

The NOAA (National Oceanic and Atmospheric Administration) algorithm provides an
alternative implementation based on [NOAA](@cite).

```@docs
SolarPosition.Positioning.NOAA
```

## [Walraven](@id walraven-algorithm)

The Walraven algorithm is a solar position algorithm published in 1978 with stated
accuracy of ±0.0100°.

The algorithm was originally published by [Wal78](@cite) with corrections from the
1979 Erratum [Wal79](@cite) and azimuth quadrant correction from [Spe89](@cite).

```@docs
SolarPosition.Positioning.Walraven
```

## [USNO](@id usno-algorithm)

The USNO (U.S. Naval Observatory) algorithm provides solar position calculations based
on formulas from the USNO's Astronomical Applications Department.

The algorithm offers two options for calculating Greenwich mean sidereal time, providing
flexibility for different accuracy requirements.

```@docs
SolarPosition.Positioning.USNO
```

## [SPA](@id spa-algorithm)

The SPA (Solar Position Algorithm) is the highest-accuracy algorithm available in this
package, with uncertainty of ±0.0003° for years between -2000 and 6000.

The algorithm was published by the National Renewable Energy Laboratory (NREL) in
[RA08](@cite) and implements a complete heliocentric, geocentric, and topocentric solar
position calculation with periodic terms for Earth heliocentric longitude and latitude.

```@docs
SolarPosition.Positioning.SPA
```
