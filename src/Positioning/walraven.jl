"""
    $(TYPEDEF)

Walraven solar position algorithm.

Walraven's algorithm has a stated accuracy of 0.01 degrees. The implementation
accounts for the 1979 Erratum and correct azimuth quadrant selection.

# Accuracy
Claimed accuracy: ±0.0100°

# Literature
This algorithm is based on [Wal78](@cite) with corrections from the 1979 Erratum [Wal79](@cite)
and azimuth quadrant correction from [Spe89](@cite).

# References
- R. Walraven, "Calculating the position of the sun," Solar Energy,
  vol. 20, no. 5, pp. 393–397, 1978, doi:10.1016/0038-092x(78)90155-x
- R. Walraven, "Erratum," Solar Energy,
  vol. 22, pp. 195, 1979, doi:10.1016/0038-092X(79)90106-3
- J. W. Spencer, "Comments on The Astronomical Almanac's Algorithm for
  Approximate Solar Position (1950–2050)," Solar Energy, vol. 42, no. 4,
  pp. 353, 1989, doi:10.1016/0038-092x(89)90039-x

# Example
```jldoctest
julia> using Dates, TimeZones

julia> obs = Observer(52.52, 13.41);  # Berlin

julia> dt = ZonedDateTime(2024, 6, 21, 12, 0, 0, tz"UTC");

julia> pos = solar_position(obs, dt, Walraven());

julia> typeof(pos)
SolPos{Float64}
```
"""
struct Walraven <: SolarAlgorithm end


function _solar_position(obs::Observer{T}, dt::DateTime, ::Walraven) where {T}
    # Use negative longitude (outdated convention used by Walraven)
    longitude = -obs.longitude

    # Extract time components
    year_val = year(dt)
    day_of_year = dayofyear(dt)

    # Calculate fractional hour
    frac_hour = T(hour(dt) + minute(dt) / 60.0 + second(dt) / 3600.0)

    # Year difference from 1980
    delta = year_val - 1980

    # Leap year calculation (round towards zero)
    leap = div(delta, 4)

    # Time calculation
    time = delta * 365 + leap + day_of_year - 1 + frac_hour / 24

    # Leap year adjustments
    if delta == (leap * 4)
        time -= 1
    end

    if (delta < 0) && (delta != (leap * 4))
        time -= 1
    end

    # Angular position in orbit [rad]
    theta = 2 * T(π) * time / 365.25

    # Mean anomaly [rad]
    g = -0.031271 - 4.53963e-7 * time + theta

    # Longitude of the sun [rad]
    L = (
        4.900968 +
        3.67474e-7 * time +
        (0.033434 - 2.3e-9 * time) * sin(g) +
        0.000349 * sin(2 * g) +
        theta
    )

    # Obliquity of ecliptic [rad]
    epsilon = deg2rad(T(23.4420)) - deg2rad(T(3.56e-7)) * time

    SEL = sin(L)
    A1 = SEL * cos(epsilon)
    A2 = cos(L)

    # Right ascension [rad]
    RA = atan(A1, A2)
    if RA < 0
        RA += 2 * T(π)
    end

    # Declination [rad]
    DECL = asin(SEL * sin(epsilon))

    # Sidereal time [rad]
    ST = 1.759335 + 2 * T(π) * (time / 365.25 - delta) + 3.694e-7 * time
    if ST >= 2 * T(π)
        ST -= 2 * T(π)
    end

    # Local sidereal time [rad]
    S = ST - deg2rad(T(longitude)) + deg2rad(T(frac_hour * 15))
    if S >= 2 * T(π)
        S -= 2 * T(π)
    end

    # Hour angle [rad]
    H = RA - S

    # Latitude in radians
    PHI = obs.latitude_rad

    # Elevation [rad]
    E = asin(sin(PHI) * sin(DECL) + cos(PHI) * cos(DECL) * cos(H))

    # Azimuth [deg] - initial calculation
    A = rad2deg(asin(cos(DECL) * sin(H) / cos(E)))

    # Azimuth quadrant assignment - Spencer (1989) correction for all longitudes
    cos_az = sin(DECL) - sin(E) * sin(PHI)

    if (cos_az >= 0) && (sin(deg2rad(A)) < 0)
        A = 360 + A
    end

    if cos_az < 0
        A = 180 - A
    end

    elevation_deg = rad2deg(E)
    zenith_deg = 90 - elevation_deg

    return SolPos{T}(A, elevation_deg, zenith_deg)
end
