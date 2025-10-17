"""Unit tests for NOAA.jl"""

using SolarPosition.Positioning: Observer, NOAA, solar_position, NoRefraction
using SolarPosition.Refraction: HUGHES
using Dates, TimeZones
using DataFrames

function expected_noaa()
    columns = [:elevation, :apparent_elevation, :zenith, :apparent_zenith, :azimuth]

    values = [
        [32.21715174, 32.24268539, 57.78284826, 57.75731461, 204.92232395],
        [32.20468378, 32.23022967, 57.79531622, 57.76977033, 204.96860803],
        [34.92392895, 34.94698595, 55.07607105, 55.05301405, 169.38094302],
        [18.63438988, 18.68174893, 71.36561012, 71.31825107, 234.19290241],
        [35.75618186, 35.77854313, 54.24381814, 54.22145687, 197.67357003],
        [-9.52911395, -9.49473778, 99.52911395, 99.49473778, 201.19219097],
        [66.85423515, 66.8611327, 23.14576485, 23.1388673, 245.09172279],
        [9.52911581, 9.62132639, 80.47088419, 80.3786736, 338.80780907],
        [50.10765752, 50.12113671, 39.89234248, 39.87886329, 326.22893168],
        [35.36265374, 35.38534047, 54.63734626, 54.61465953, 175.39359304],
        [-53.23987161, -53.23556094, 143.23987161, 143.23556094, 18.65415239],
        [-53.23987161, -53.23556094, 143.23987161, 143.23556094, 18.65415239],
        [32.46248831, 32.48778263, 57.53751169, 57.51221737, 204.95376627],
        [32.44117331, 32.4664883, 57.55882669, 57.5335117, 204.97518601],
        [-23.40444445, -23.39111232, 113.40444445, 113.39111232, 79.55187937],
        [1.11161226, 1.46445929, 88.88838774, 88.53554071, 104.54291476],
        [32.21715174, 32.24268539, 57.78284826, 57.75731461, 204.92232395],
        [32.21715174, 32.24268539, 57.78284826, 57.75731461, 204.92232395],
        [32.21715174, 32.24268539, 57.78284826, 57.75731461, 204.92232395],
    ]

    return DataFrame(reduce(hcat, values)', columns)
end

@testset "NOAA" begin
    df_expected = expected_noaa()
    conds = test_conditions()
    @test size(df_expected, 1) == 19
    @test size(df_expected, 2) == 5
    @test size(conds, 1) == 19
    @test size(conds, 2) == 4

    @testset "With default delta_t" begin
        # conds = time, latitude, longitude, altitude
        for ((dt, lat, lon, alt), (exp_elev, exp_app_elev, exp_zen, exp_app_zen, exp_az)) in
            zip(eachrow(conds), eachrow(df_expected))
            if ismissing(alt)
                obs = Observer(lat, lon)
            else
                obs = Observer(lat, lon, altitude = alt)
            end

            # the original NOAA algorithm is defined with Hughes refraction correction
            # NOAA uses Hughes with temperature=10°C and pressure=101325 Pa
            res = solar_position(obs, dt, NOAA(), HUGHES(101325.0, 10.0))

            # azimuth calculations have small variations
            @test isapprox(res.elevation, exp_elev, atol = 2e-7)
            @test isapprox(res.zenith, exp_zen, atol = 2e-7)
            @test isapprox(res.azimuth, exp_az, atol = 3e-7)
            @test isapprox(res.apparent_elevation, exp_app_elev, atol = 2e-7)
            @test isapprox(res.apparent_zenith, exp_app_zen, atol = 2e-7)
        end
    end

    @testset "With delta_t=nothing" begin
        for ((dt, lat, lon, alt), (exp_elev, exp_app_elev, exp_zen, exp_app_zen, exp_az)) in
            zip(eachrow(conds), eachrow(df_expected))
            if ismissing(alt)
                obs = Observer(lat, lon)
            else
                obs = Observer(lat, lon, altitude = alt)
            end

            res = solar_position(obs, dt, NOAA(nothing), HUGHES(101325.0, 10.0))

            # results can differ when delta_t is nothing
            @test isapprox(res.elevation, exp_elev, atol = 1e0)
            @test isapprox(res.zenith, exp_zen, atol = 1e0)
            @test isapprox(res.azimuth, exp_az, atol = 1e0)
            @test isapprox(res.apparent_elevation, exp_app_elev, atol = 1e0)
            @test isapprox(res.apparent_zenith, exp_app_zen, atol = 1e0)
        end
    end

    @testset "Refraction comparison at solar noon" begin
        lat, lon = 0.0, 0.0

        # spring equinox at noon UTC when sun is roughly overhead at prime meridian
        dt = ZonedDateTime(2024, 3, 20, 12, 0, 0, tz"UTC")
        obs = Observer(lat, lon)

        # with refraction correction
        res_with_refraction = solar_position(obs, dt, NOAA(), HUGHES())

        # without refraction correction
        res_no_refraction = solar_position(obs, dt, NOAA())

        # elevation and apparent_elevation should be nearly identical
        @test isapprox(
            res_with_refraction.apparent_elevation,
            res_no_refraction.elevation,
            atol = deg2rad(0.1),
        )
        @test isapprox(
            res_with_refraction.apparent_zenith,
            res_no_refraction.zenith,
            atol = deg2rad(0.1),
        )

        @test isapprox(res_with_refraction.azimuth, res_no_refraction.azimuth, atol = 1e-10)
        @test isapprox(
            res_with_refraction.elevation,
            res_no_refraction.elevation,
            atol = 1e-10,
        )
        @test isapprox(res_with_refraction.zenith, res_no_refraction.zenith, atol = 1e-10)
    end
end
