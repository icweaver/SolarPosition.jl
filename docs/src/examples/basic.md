# [Basic Examples](@id basic-examples)

This section demonstrates basic usage of SolarPosition.jl for calculating solar positions.

```@example basic
using SolarPosition
using Dates
using TimeZones

# Define observer location (latitude, longitude, altitude in meters)
obs = Observer(37.7749, -122.4194, 100.0)  # San Francisco

# Calculate solar position for a specific time
dt = ZonedDateTime(2023, 6, 21, 12, 0, 0, tz"America/Los_Angeles")  # Summer solstice noon
position = solar_position(obs, dt)

println("Solar position at summer solstice noon in San Francisco:")
println("Azimuth: $(round(position.azimuth, digits=2))°")
println("Elevation: $(round(position.elevation, digits=2))°")
```
