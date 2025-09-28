"""Plot solar positions using SolarPosition.jl with hourly labels."""

using Dates
using TimeZones
using DataFrames
using GLMakie
using SolarPosition

# define observer location (latitude, longitude, altitude in meters)
tz = tz"Asia/Kolkata"
obs = Observer(28.6, 77.2, 0.0)

# a whole year of hourly timestamps
times = collect(ZonedDateTime(DateTime(2019), tz):Hour(1):ZonedDateTime(DateTime(2020), tz))
positions = solar_position(obs, times)

# plot positions from NamedTuple with hourly labels in polar coordinates
sunpathplot(positions)

# plot DataFrame with hourly labels in cartesian coordinates
df = DataFrame(positions)
sunpathpolarplot(df, hour_labels = true, colorbar = true)

# plot DataFrame in polar coordinates with hourly labels
fig = Figure()
ax = PolarAxis(fig[1, 1], title = "Polar Coordinates with Hour Labels")
sunpathpolarplot!(ax, df, hour_labels = true, colorbar = false)
fig

# example without hourly labels for comparison
fig2 = Figure()
ax2 = Axis(fig2[1, 1], title = "Cartesian Coordinates (No Labels)")
sunpathplot!(ax2, df; hour_labels = false, colorbar = true)
fig2
