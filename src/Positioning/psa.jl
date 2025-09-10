"""
    PSA

Solar position algorithm based on PSA's implementation.
"""

struct PSA <: SolarAlgorithm end

const PSA_PARAMS = Dict{Int,SVector{15,Float64}}(
    2020 => SVector{15,Float64}(
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
    ),
    2001 => SVector{15,Float64}(
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
    ),
)

"""
    _solar_position(
        obs::Observer{T},
        dt::ZonedDateTime,
        ::PSA,
    ) -> SolarPos{T}
PSA algorithm implementation stub.
"""
function _solar_position(
    obs::Observer{T},
    dt::ZonedDateTime,
    ::PSA;
    coeffs::Int = 2020,
) where {T}

    p = PSA_PARAMS[coeffs]

    phi = obs.latitude_rad
    lambda_t = obs.longitude_rad

    # extract date components
    h = fractional_hour(dt)

    # julian day calculation
    jd = Dates.datetime2julian(dt)
    n = jd - 2451545.0

    # ecliptic longitude and obliquity
    omega = p[1] + p[2] * n
    L = p[3] + p[4] * n
    g = p[5] + p[6] * n
    lambda_e = L + p[7] * sin(g) + p[8] * sin(2 * g) + p[9] + p[10] * sin(omega)
    epsilon = p[11] + p[12] * n + p[13] * cos(omega)

    # right ascension and declination
    ra = atan(cos(epsilon) * sin(lambda_e), cos(lambda_e)) % (2 * pi)
    δ = asin(sin(epsilon) * sin(lambda_e))

    # local coordinates
    gmst = p[14] + p[15] * n + h
    lmst = gmst + lambda_t  # check units if gmst in hours
    w = lmst - ra

    theta_z = acos(cos(phi) * cos(w) * cos(δ) + sin(δ) * sin(phi))
    gamma = atan(-sin(w), (tan(δ) * cos(phi) - sin(phi) * cos(w)))

    # Earth mean radius correction
    EMR = 6371.01
    AU = 149597890
    theta_z += (EMR / AU) * sin(theta_z)

    return SolarPos{T}(pi / 2 - theta_z, theta_z, gamma)  # elevation, zenith, azimuth in radians
end
