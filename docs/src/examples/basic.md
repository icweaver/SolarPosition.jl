# [Basic Example](@id basic-example)

This section demonstrates basic usage of SolarPosition.jl for calculating solar positions.

First, we need to import the package along with some supporting packages. Although not
strictly necessary, it is common to work with time zone-aware datetimes using the
`TimeZones.jl` package.

```@example basic
using SolarPosition

# supporting packages
using Dates
using DataFrames
using TimeZones
```

We can define an observer location using the `Observer` struct, which takes latitude,
longitude, and altitude (in meters) as arguments.

```@example basic
obs = Observer(37.7749, -122.4194, 100.0)  # San Francisco
```

Finally, we can calculate the solar position for a specific date and time using the
`solar_position` function. The time should be provided as a `ZonedDateTime` to ensure
correct handling of time zones.

```@example basic
tz = tz"America/Los_Angeles"
zdt = ZonedDateTime(2023, 6, 21, 12, 0, 0, tz)  # Summer solstice noon
position = solar_position(obs, zdt)

println("Solar position at summer solstice noon in San Francisco:")
println("Azimuth: $(round(position.azimuth, digits=2))°")
println("Elevation: $(round(position.elevation, digits=2))°")
```

## Using DateTime in UTC

Alternatively, we can directly pass a DateTime (assumed to be in UTC)

```@example basic
zdt_utc = DateTime(zdt, UTC)
position_utc = solar_position(obs, zdt_utc)
println("Azimuth (UTC): $(round(position_utc.azimuth, digits=2))°")
println("Elevation (UTC): $(round(position_utc.elevation, digits=2))°")
```

It is also possible to calculate solar positions for multiple timestamps at once by
passing a vector or range of `ZonedDateTime` or `DateTime` objects.

```@example basic
# Generate hourly timestamps for a whole year
times = ZonedDateTime(DateTime(2019), tz):Hour(1):ZonedDateTime(DateTime(2020), tz)

# This returns a NamedTuple of Vectors
positions = solar_position(obs, times)

# We can inspect the first few entries by converting to a DataFrame
first(DataFrame(positions), 5)
```

## Passing Latitude and Longitude as keyword arguments

Lastly, we show that we can pass latitude and longitude directly without creating an
`Observer` object. In this case the library will create an `Observer` object for us.

```@example basic
times = DateTime(2019):Hour(1):DateTime(2020)
position_direct = solar_position(times; latitude=37.7749, longitude=-122.4194, altitude=100.0)
first(DataFrame(position_direct), 5)
```
