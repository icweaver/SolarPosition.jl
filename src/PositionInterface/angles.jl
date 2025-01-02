export declination

"""
    declination(t::Union{Number, DateTime})

Compute the declination angle [1] of the Sun [deg] at the time `t`, which can be 
represented by the day of the year (`Float`) or `DateTime`. 

The output is a `Quantity` with the unit of degrees.

# References

- **[1]** pveducation. Declination angle. URL: https://www.pveducation.org/pvcdrom/properties-of-sunlight/declination-angle.
"""
function declination(d::Number)
    (0 <= d <= 365) || throw(ArgumentError("day of the year must be in the range [0, 365]"))
    δ = -23.45cosd((360 / 365) * (d + 10))
    return Quantity(δ, deg = 1)
end

"""
    declination(t::DateTime)

Convert `t` to the day of the year and compute the declination angle.
"""
declination(t::DateTime) = declination(datetime2julian(t) -
                                       datetime2julian(DateTime(year(t), 1, 1)))
declination(t::ZonedDateTime) = declination(DateTime(t))