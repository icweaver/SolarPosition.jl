"""Plot solar positions using SolarPosition.jl."""

using Dates
using DataFrames
using GLMakie
using SolarPosition

# define observer location (latitude, longitude, altitude in meters)
obs = Observer(28.6, 77.2, 0.0)

# a whole year of hourly timestamps
times = DateTime(2023):Hour(1):DateTime(2024)

# compute solar positions
positions = solar_position(obs, times)

# plot positions from NamedTuple
sunpathplot(positions, coords = :polar)

# plot DataFrame
df = DataFrame(positions)
sunpathplot(df, coords = :cartesian)

# plot DataFrame in polar coordinates
fig = Figure()
ax = PolarAxis(fig[1, 1], title = "Solar Path - Polar Coordinates")
sunpathplot!(ax, df; coords = :polar)
fig
