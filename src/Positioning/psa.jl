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

@enum PSACoeffTypes::Int begin
    Y2020 = 2020
    Y2001 = 2001
end

"""
    _solar_position(obs::Observer{T}, alg::PSA, t::ZonedDateTime, opts::CommonOptions{T}, algopts::PSAOptions{T}) -> SolarPos{T}

PSA algorithm implementation stub.
"""
function _solar_position(
    obs::Observer{T},
    ::PSA,
    t::ZonedDateTime,
    coeffs::PSACoeffTypes,
) where {T}
    azimuth = T(π / 3)     # 60 degrees
    elevation = T(π / 4)   # 45 degrees
    zenith = T(π / 2) - elevation
    result = SolarPos(azimuth, elevation, zenith)
    return result
end
