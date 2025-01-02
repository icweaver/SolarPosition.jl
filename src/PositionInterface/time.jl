export equation_of_time, offset_hours

"""
    equation_of_time(t::Union{Number, DateTime})

Compute the difference between the Sun apparent local time and the Sun mean local time
[deg], which is called Equation of Time, at the time `t`, which can be represented by a
Julian Day or `DateTime`. The algorithm was adapted from **[1, p. 178, 277-279]**.

The output is a `Quantity` with the unit of degrees.

Implementation attribution goes to: https://github.com/JuliaSpace/SatelliteToolbox.jl

# References

- **[1]** Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. 4th ed.
    Microcosm Press, Hawthorne, CA.
"""
function equation_of_time(jd::Number)
    # Number of Julian centuries from J2000 epoch.
    t_ut1 = (jd - JD_J2000) / 36525.0

    # Mean longitude of the Sun.
    λ_m = mod(280.460 + 36000.771t_ut1, 360)

    # Mean anomaly of the Sun.
    #
    # Here, we should use T_TBD (Barycentric Dynamical Time). However, it is sufficient to
    # use t_ut1 because this is a low precision computation [1].
    Ms = mod(357.5291092 + 35999.05034t_ut1, 360) |> deg2rad

    # Auxiliary variables.
    sin_Ms = sin(Ms)
    sin_2Ms = sin(2Ms)

    # Ecliptic latitude of the Sun.
    λ_ecliptic = mod(λ_m + 1.914666471sin_Ms + 0.019994643sin_2Ms, 360) |> deg2rad

    # Compute the equation of time [rad].
    eot = -1.914666471sin_Ms - 0.019994643sin_2Ms + 2.466sin(2λ_ecliptic) -
          0.0053sin(4λ_ecliptic)

    return Quantity(eot, deg = 1)
end

"""
    equation_of_time(t::DateTime)

Convert `t` to the Julian Day and compute the Equation of Time.
"""
equation_of_time(t::DateTime) = equation_of_time(datetime2julian(t))
equation_of_time(t::ZonedDateTime) = equation_of_time(DateTime(t))

"""
    offset_hours(tz::TimeZone)

Return the offset in hours of the timezone `tz` with respect to UTC-0.
"""
offset_hours(tz::FixedTimeZone) = Hour(tz.offset.std).value
offset_hours(t::ZonedDateTime) = offset_hours(FixedTimeZone(t))