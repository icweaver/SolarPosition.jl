"""
    $(TYPEDEF)

PSA (Plataforma Solar de Almería) solar position algorithm.

This algorithm computes solar position with high accuracy using empirical coefficients.
Two coefficient sets are available: 2001 (range 1999-2015) and 2020 (range 2020-2050).

# Fields
$(TYPEDFIELDS)

# Constructor
- `PSA()`: Uses 2020 coefficients (default)
- `PSA(2020)`: Uses 2020 coefficients (range 2020-2050, accuracy ±0.0083°)
- `PSA(2001)`: Uses 2001 coefficients (range 1999-2015, accuracy ±0.0083°)

# References
[1] M. Blanco, D. Alarcón, T. López, and M. Lara, "Computing the Solar Vector,"
    Solar Energy, vol. 70, no. 5, 2001, doi:10.1016/S0038-092X(00)00156-0

[2] M. Blanco, K. Milidonis, and A. Bonanos, "Updating the PSA sun position algorithm,"
    Solar Energy, vol. 212, 2020, doi:10.1016/j.solener.2020.10.084

# Example
```julia
# Use default 2020 coefficients
pos = solar_position(obs, dt, PSA())

# Use 2001 coefficients for historical data
pos_historical = solar_position(obs, dt, PSA(2001))
```
"""
struct PSA <: BasicAlg
    "Coefficient set year (2001 or 2020)"
    coeffs::Int
end

PSA() = PSA(2020)  # default to latest coefficients

const PSA_PARAMS = Dict{Int,Vector}(
    2020 => Vector([
        2.267127827,
        -9.300339267e-4,
        4.895036035,
        1.720279602e-2,
        6.239468336,
        1.720200135e-2,
        3.338320972e-2,
        3.497596876e-4,
        -1.544353226e-4,
        -8.689729360e-6,
        4.090904909e-1,
        -6.213605399e-9,
        4.418094944e-5,
        6.697096103,
        6.570984737e-2,
    ]),
    2001 => Vector([
        2.1429,
        -0.0010394594,
        4.8950630,
        0.017202791698,
        6.2400600,
        0.0172019699,
        0.03341607,
        0.00034894,
        -0.0001134,
        -0.0000203,
        0.4090928,
        -6.2140e-09,
        0.0000396,
        6.6974243242,
        0.0657098283,
    ]),
)

function _solar_position(obs::Observer{T}, dt::DateTime, alg::PSA) where {T}
    p = PSA_PARAMS[alg.coeffs]

    # elapsed julian days (n) since J2000.0
    jd = datetime2julian(dt)
    n = jd - 2451545.0                                                  # Eq. 2

    # ecliptic coordinates of the sun
    # ecliptic longitude (λₑ), and obliquity of the ecliptic (ϵ)
    Ω = p[1] + p[2] * n                                                 # Eq. 3
    L = p[3] + p[4] * n                                                 # Eq. 4
    g = p[5] + p[6] * n                                                 # Eq. 5
    λₑ = L + p[7] * sin(g) + p[8] * sin(2 * g) + p[9] + p[10] * sin(Ω)  # Eq. 6
    ϵ = p[11] + p[12] * n + p[13] * cos(Ω)                              # Eq. 7

    # celestial right ascension (ra) and declination (d)
    ra = atan(cos(ϵ) * sin(λₑ), cos(λₑ))                                # Eq. 8
    ra = mod(ra, 2π)
    δ = asin(sin(ϵ) * sin(λₑ))                                          # Eq. 9

    # computes the local coordinates: azimuth (γ) and zenith angle (θz)
    ϕ = obs.latitude_rad
    hour = fractional_hour(dt)
    gmst = p[14] + p[15] * n + hour                                     # Eq. 10
    λt = rad2deg(obs.longitude_rad)
    lmst = (gmst * 15 + λt) * π / 180                                   # Eq. 11
    ω = lmst - ra                                                       # Eq. 12
    θz = acos(cos(ϕ) * cos(ω) * cos(δ) + sin(δ) * sin(ϕ))               # Eq. 13
    γ = atan(-sin(ω), (tan(δ) * cos(ϕ) - sin(ϕ) * cos(ω)))              # Eq. 14

    # parallax correction
    θz = θz + (EMR / AU) * sin(θz)                                      # Eq. 15,16

    return SolPos(mod(rad2deg(γ), 360), rad2deg(π / 2 - θz), rad2deg(θz))
end
