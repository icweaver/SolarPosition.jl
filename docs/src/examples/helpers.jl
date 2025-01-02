# # Example: Using solar angle and time helper functions

# In this example we show how to use some of the funcionality provided by this package.

# First, we load the required modules.
using SolarPosition.PositionInterface: declination, equation_of_time
using Dates
using CairoMakie

# ## Declination angle

# The declination angle is the angle between the rays of the sun and the plane of the 
# Earth's equator [1]. It is a function of the day of the year and varies between -23.45° 
# and +23.45°.
#
# [1] pveducation. Declination angle. URL: https://www.pveducation.org/pvcdrom/properties-of-sunlight/declination-angle.

# Lets compute the declination angle in steps of 1 day.
sz = (600, 400)
days = 1:365
δ = declination.(days)
fig = Figure(resolution = sz)
ax = Axis(
    fig[1, 1], xlabel = "Day of the year [-]", ylabel = "Declination [°]", xticks = 0:30:365)
xlims!(ax, 0, 365)
ylims!(ax, -30, 30)
lines!(ax, days, [d.value for d in δ], color = :blue)
save("declination.png", fig)

# ## Equation of time

# The equation of time is the difference between the true solar time and the mean solar
# time. It is a function of the day of the year and varies rougly between -16 and +16 
# minutes, or -4 and +4 degrees.

# Lets compute the equation of time in steps of 1 day.
eot = equation_of_time.(days) * (24 * 60) / 360
fig = Figure(resolution = sz)
ax = Axis(
    fig[1, 1], xlabel = "Day of the year [-]", ylabel = "Equation of Time [min]", xticks = 0:30:365,
    yticks = -16:4:16)
xlims!(ax, 0, 365)
ylims!(ax, -17, 17)
lines!(ax, days, [e.value for e in eot], color = :red)
save("equation_of_time.png", fig)
