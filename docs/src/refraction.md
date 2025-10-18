# [Refraction Correction](@id refraction-correction)

Atmospheric refraction correction algorithms available in SolarPosition.jl.

Atmospheric refraction causes the apparent position of the sun to differ from its true geometric position. This effect is most pronounced near the horizon and can be corrected using various atmospheric models.

| Algorithm                                              | Reference      | Atmospheric Parameters | Status |
| ------------------------------------------------------ | -------------- | ---------------------- | ------ |
| [`HUGHES`](@ref SolarPosition.Refraction.HUGHES)       | [Hug85](@cite) | Pressure, Temperature  | ✅     |
| [`ARCHER`](@ref SolarPosition.Refraction.ARCHER)       | [Arc80](@cite) | None                   | ✅     |
| [`BENNETT`](@ref SolarPosition.Refraction.BENNETT)     | [Ben82](@cite) | Pressure, Temperature  | ✅     |
| [`MICHALSKY`](@ref SolarPosition.Refraction.MICHALSKY) | [Mic88](@cite) | None                   | ✅     |
| [`SG2`](@ref SolarPosition.Refraction.SG2)             | [BW12](@cite)  | Pressure, Temperature  | ✅     |
| [`SPA`](@ref SolarPosition.Refraction.SPA)             | [RA08](@cite)  | Pressure, Temperature  | ✅     |

To calculate refraction, we can use the [`refraction`](@ref SolarPosition.Refraction.refraction) function:

```@docs
SolarPosition.Refraction.refraction
```

This function is typically used internally by the [`solar_position`](@ref SolarPosition.solar_position) function when a
refraction algorithm is specified, but is also a publicly available method.

!!! info
When using a refraction algorithm like [`HUGHES`](@ref SolarPosition.Refraction.HUGHES)`()`,
the [`solar_position`](@ref SolarPosition.Positioning.solar_position) function returns an
[`ApparentSolPos`](@ref SolarPosition.Positioning.ApparentSolPos) struct containing
both true and apparent angles.

```@docs
SolarPosition.Refraction.NoRefraction
```

!!! info
When using [`NoRefraction`](@ref SolarPosition.Refraction.NoRefraction)`()` (the default), the
[`solar_position`](@ref SolarPosition.Positioning.solar_position) function returns a
[`SolPos`](@ref SolarPosition.Positioning.SolPos) struct containing only the true
geometric angles (azimuth, elevation, zenith). In this case, no refraction
correction is applied.

## [Hughes](@id hughes-refraction)

The Hughes refraction model accounts for atmospheric pressure and temperature effects.

This model was developed by [Hug85](@cite) and is used in the SUNAEP software [Zim81](@cite).
It's also the basis for the refraction correction in NOAA's solar position calculator (using fixed
pressure of 101325 Pa and temperature of 10°C).

```@docs
SolarPosition.Refraction.HUGHES
```

## [Archer](@id archer-refraction)

The Archer refraction model is a cosine-based correction that does not require atmospheric parameters.

This simplified model from [Arc80](@cite) computes refraction based on the zenith angle using
trigonometric relationships. It's useful when atmospheric data is not available.

```@docs
SolarPosition.Refraction.ARCHER
```

## [Bennett](@id bennett-refraction)

The Bennett refraction model is widely used in marine navigation and accounts for atmospheric conditions.

Developed by [Ben82](@cite), this model provides accurate refraction corrections with adjustments
for atmospheric pressure and temperature. It's particularly effective for low elevation angles.

```@docs
SolarPosition.Refraction.BENNETT
```

## [Michalsky](@id michalsky-refraction)

The Michalsky refraction model uses a rational polynomial approximation.

From [Mic88](@cite), this algorithm is part of the Astronomical Almanac's method for approximate
solar position calculations. It includes special handling for very low elevation angles.

```@docs
SolarPosition.Refraction.MICHALSKY
```

## [SG2](@id sg2-refraction)

The SG2 (Second Generation) refraction algorithm is optimized for fast computation over multi-decadal periods.

Developed by [BW12](@cite), this algorithm uses a two-regime approach with different formulas
for elevations above and below a threshold. It accounts for atmospheric pressure and temperature.

```@docs
SolarPosition.Refraction.SG2
```

## [SPA](@id spa-refraction)

The SPA (Solar Position Algorithm) refraction model is part of NREL's high-accuracy solar position algorithm.

From [RA08](@cite), this is the refraction correction used in NREL's SPA algorithm, which is
accurate to ±0.0003° over the years -2000 to 6000. It includes a configurable refraction limit
for below-horizon calculations.

```@docs
SolarPosition.Refraction.SPA
```
