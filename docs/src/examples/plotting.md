```@meta
DocTestSetup = quote
    using SolarPosition
    using CairoMakie
    CairoMakie.activate!(type = "svg")
end
```

# [Using the Makie.jl plotting extension](@id plotting-examples)

SolarPosition.jl provides a plotting extension based on [Makie.jl](https://makie.juliaplots.org/stable/).

To use it, simply import both the `SolarPosition` and `Makie` packages:

```@example plotting
using SolarPosition
using CairoMakie
using Dates
using TimeZones
using DataFrames
```

## Basic Sun Path Plotting

Let's start by defining an observer location and calculating solar positions for a whole year:

```@example plotting
# Define observer location (New Delhi, India)
# Parameters: latitude, longitude, altitude in meters
tz = tz"Asia/Kolkata"
obs = Observer(28.6, 77.2, 0.0)

# Generate hourly timestamps for a whole year
times = ZonedDateTime(DateTime(2019), tz):Hour(1):ZonedDateTime(DateTime(2020), tz)
positions = solar_position(obs, times)
```

### Simple Sun Path Plot

The simplest way to visualize solar positions is using the `sunpathplot` function:

```@example plotting
# Plot positions in Cartesian coordinates
sunpathplot(positions)
```

### Polar Coordinates with Hour Labels

For a more detailed visualization, you can use polar coordinates with hourly labels:

```@example plotting
# Convert to DataFrame for more plotting options
df = DataFrame(positions)

# Plot in polar coordinates with hourly labels and colorbar
sunpathpolarplot(df, hour_labels = true, colorbar = true)
```

## Advanced Plotting Examples

### Custom Polar Plot with Manual Axis Setup

You can create more customized plots by manually setting up the axes:

```@example plotting
# Create a custom polar plot with manual axis configuration
fig = Figure(size = (600, 600))
ax = PolarAxis(fig[1, 1], title = "Solar Path - Polar Coordinates with Hour Labels")
sunpathpolarplot!(ax, df, hour_labels = true, colorbar = false)
fig
```

### Cartesian Plot without Hour Labels

For comparison, here's a cleaner plot without hourly labels:

```@example plotting
# Example without hourly labels for a cleaner appearance
fig2 = Figure(size = (800, 600))
ax2 = Axis(fig2[1, 1],
    title = "Solar Path - Cartesian Coordinates",
    xlabel = "Azimuth (degrees)",
    ylabel = "Elevation (degrees)"
)
sunpathplot!(ax2, df; hour_labels = false, colorbar = true)
fig2
```

## Plot Customization Options

The plotting functions support various customization options:

- `hour_labels`: Boolean to show/hide hourly time labels
- `colorbar`: Boolean to show/hide the colorbar indicating time of year
- Custom figure sizes and axis titles as shown in the examples above

These plotting capabilities make it easy to visualize and analyze solar paths for any location and time period.
