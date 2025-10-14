# [Refraction Algorithms](@id refraction-algorithms)

Atmospheric refraction correction algorithms available in SolarPosition.jl.

Atmospheric refraction causes the apparent position of the sun to differ from its true geometric position. This effect is most pronounced near the horizon and can be corrected using various atmospheric models.

| Algorithm    | Reference                                                                                         | Typical Accuracy | Atmospheric Parameters | Status |
| ------------ | ------------------------------------------------------------------------------------------------- | ---------------- | ---------------------- | ------ |
| NoRefraction | N/A                                                                                               | N/A              | None                   | ✅     |
| Hughes       | [Hughes (1985)](https://pvpmc.sandia.gov/app/uploads/sites/243/2022/10/Engineering-Astronomy.pdf) | ~0.1' (arcmin)   | Pressure, Temperature  | ✅     |

To calculate refraction, we can use the `refraction` function:

```@docs
SolarPosition.Refraction.refraction
```

This function is typically used internally by the `solar_position` function when a
refraction algorithm is specified.

## [NoRefraction](@id no-refraction)

The default behavior - no atmospheric refraction correction is applied.

When using `NoRefraction()` (the default), the `solar_position` function returns a `SolPos` struct containing only the true geometric angles (azimuth, elevation, zenith).

```@docs
SolarPosition.NoRefraction
```

## [Hughes](@id hughes-refraction)

The Hughes refraction model accounts for atmospheric pressure and temperature effects.

This model was developed by G. W. Hughes and is used in the SUNAEP software. It's also the basis for the refraction correction in NOAA's solar position calculator (using fixed pressure of 101325 Pa and temperature of 10°C).

When using a refraction algorithm like `Hughes()`, the `solar_position` function returns an `ApparentSolPos` struct containing both true and apparent angles.

```@docs
SolarPosition.HUGHES
```
