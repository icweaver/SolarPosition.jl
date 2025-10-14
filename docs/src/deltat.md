# [Delta T (ΔT)](@id deltat)

Delta T (ΔT) is the difference between Terrestrial Dynamical Time (TD) and Universal Time (UT):

```math
\Delta T = TD - UT
```

This correction is essential for accurate astronomical calculations because Earth's rotation rate
is not constant. It varies due to tidal braking from the Moon, changes in Earth's moment of inertia,
and other geophysical factors.

## Implementation

SolarPosition.jl implements ΔT calculation using polynomial expressions fitted to historical
observations and modern measurements from atomic clocks:

- **Historical data (-500 to 1950)**: Based on eclipse observations from Morrison and Stephenson (2004)
- **Modern era (1950-2005)**: Direct measurements from atomic clocks and radio observations
- **Future (2005-2050)**: Extrapolation based on recent trends
- **Far past/future**: Parabolic extrapolation formula

## Usage

```@docs
SolarPosition.Positioning.calculate_deltat
```

## Examples

### Basic Usage

Calculate ΔT for a specific year and month:

```julia
using SolarPosition.Positioning: calculate_deltat

# Calculate ΔT for June 2020
dt = calculate_deltat(2020, 6)
println("ΔT ≈ $(round(dt, digits=2)) seconds")
```

### Using Date Objects

For more convenient usage with date objects:

```julia
using SolarPosition.Positioning: calculate_deltat
using Dates

# Using Date
date = Date(2020, 6, 15)
dt1 = calculate_deltat(date)

# Using DateTime
datetime = DateTime(2020, 6, 15, 12, 30, 45)
dt2 = calculate_deltat(datetime)

# Using ZonedDateTime
using TimeZones
zdt = ZonedDateTime(2020, 6, 15, 12, 30, 45, tz"UTC")
dt3 = calculate_deltat(zdt)
```

### Historical Values

Calculate ΔT for historical dates:

```julia
using SolarPosition.Positioning: calculate_deltat

# Ancient Rome (year 0)
dt_ancient = calculate_deltat(0, 6)
println("Year 0: ΔT ≈ $(round(dt_ancient, digits=0)) seconds")

# Early telescope era (1650)
dt_1650 = calculate_deltat(1650, 6)
println("Year 1650: ΔT ≈ $(round(dt_1650, digits=1)) seconds")

# Near zero around 1900
dt_1900 = calculate_deltat(1900, 6)
println("Year 1900: ΔT ≈ $(round(dt_1900, digits=1)) seconds")
```

### Plotting Historical Trend

Visualize how ΔT has changed over time:

```@example deltat
using SolarPosition.Positioning: calculate_deltat
using CairoMakie

# Calculate ΔT for years 1990-2040
years = 1990:1:2040
deltat_values = [calculate_deltat(year, 6) for year in years]

# Create plot with transparent background
fig = Figure(size=(800, 500), backgroundcolor=:transparent, textcolor="#f5ab35")
ax = Axis(fig[1, 1],
    xlabel = "Year",
    ylabel = "ΔT (seconds)",
    title = "Historical and Projected Values of ΔT (1990-2040)",
    backgroundcolor=:transparent
)

lines!(ax, years, deltat_values, linewidth=2)

fig
```

## Accuracy and Limitations

### Supported Range

- **Defined range**: -1999 to 3000 CE
- **Warnings**: Issued for dates outside this range
- **Extrapolation**: Still provides values outside the defined range using parabolic formula

### Accuracy

- **Modern era (1950-2025)**: Very accurate (< 1 second)
- **Historical (1600-1950)**: Accurate to a few seconds
- **Medieval (500-1600)**: Accuracy decreases to ~10-30 seconds
- **Ancient (< 500)**: Accuracy decreases significantly (~50-500 seconds)
- **Future predictions**: Uncertainty increases with time

The uncertainty in ΔT arises because Earth's rotation is affected by unpredictable factors like
atmospheric circulation, ocean currents, and tectonic events.

## References

1. **NASA GSFC**: [Five Millennium Canon of Solar Eclipses: Delta T](http://eclipse.gsfc.nasa.gov/SEcat5/deltatpoly.html)
2. **Morrison, L. and Stephenson, F. R. (2004)**: "Historical Values of the Earth's Clock Error ΔT and the Calculation of Eclipses", Journal for the History of Astronomy, Vol. 35, Part 3, pp 327-336
3. **Astronomical Almanac**: Direct observations from atomic clocks and VLBI measurements
