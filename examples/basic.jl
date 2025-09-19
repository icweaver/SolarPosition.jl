"""Basic example showing how to use SolarPosition.jl."""

using Dates
using SolarPosition

# define observer location (latitude, longitude, altitude in meters)
obs = Observer(52.358134610343214, 4.881269505489815, 0.0)  # Van Gogh Museum

# a whole year of hourly timestamps
times = DateTime(2023):Hour(1):DateTime(2024)

# compute solar positions
positions = solar_position(obs, times)

# or directly using latitude, longitude, altitude
positions = solar_position(
    times;
    latitude = 52.358134610343214,
    longitude = 4.881269505489815,
    altitude = 0.0,
)
