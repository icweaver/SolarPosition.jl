"""Basic example showing how to use SolarPosition.jl."""

using Dates
using SolarPosition

# define observer location (latitude, longitude, altitude in meters)
obs = Observer(52.358134610343214, 4.881269505489815, 0.0)  # Van Gogh Museum

# a whole year of hourly timestamps
times = collect(DateTime(2023):Hour(1):DateTime(2024))

# compute solar positions (uses PSA algorithm by default)
positions = solar_position(obs, times)

# You can also explicitly choose an algorithm:
# PSA algorithm (high accuracy ±0.0083°)
positions_psa = solar_position(obs, times, PSA())

# NOAA algorithm (±0.0167°)
positions_noaa = solar_position(obs, times, NOAA())
