"""Unit tests for SPA algorithm"""

function expected_spa()
    columns = [
        :elevation,
        :apparent_elevation,
        :zenith,
        :apparent_zenith,
        :azimuth,
        :equation_of_time,
    ]

    values = [
        [32.21708674, 32.24367654, 57.78291326, 57.75632346, 204.9188164, 14.75816027],
        [32.20462016, 32.23122263, 57.79537984, 57.76877737, 204.96510208, 14.75818295],
        [34.92249857, 34.94652348, 55.07750143, 55.05347652, 169.3767211, 14.74179647],
        [18.63493009, 18.68392203, 71.36506991, 71.31607797, 234.19049983, 14.77445424],
        [35.75662074, 35.77992239, 54.24337926, 54.22007761, 197.67009996, -12.4319873],
        [-9.53051391, -9.53051391, 99.53051391, 99.53051391, 201.18870641, 14.75816027],
        [66.85682918, 66.86401769, 23.14317082, 23.13598231, 245.09065324, 14.75816027],
        [9.52569499, 9.61953906, 80.47430501, 80.38046094, 338.81129359, 14.75816027],
        [50.10653615, 50.12059933, 39.89346385, 39.87940067, 326.23446721, 14.75816027],
        [35.36147343, 35.38511409, 54.63852657, 54.61488591, 175.38931352, 14.75816027],
        [-53.24113451, -53.24113451, 143.24113451, 143.24113451, 18.64817122, 14.75816027],
        [-53.24113451, -53.24113451, 143.24113451, 143.24113451, 18.64817122, 14.75816027],
        [32.4622024, 32.48854464, 57.5377976, 57.51145536, 204.94926574, 14.55795391],
        [32.4407131, 32.46707691, 57.5592869, 57.53292309, 204.96985758, 14.64779166],
        [-23.40808954, -23.40808954, 113.40808954, 113.40808954, 79.54868063, 14.68397497],
        [1.10773228, 1.45847482, 88.89226772, 88.54152518, 104.53989829, 14.70334338],
        [32.21708674, 32.24367654, 57.78291326, 57.75632346, 204.9188164, 14.75816027],
        [32.21708677, 32.24367657, 57.78291323, 57.75632343, 204.9188164, 14.75816027],
        [32.21708544, 32.24367524, 57.78291456, 57.75632476, 204.9188164, 14.75816027],
    ]

    return DataFrame(reduce(hcat, values)', columns)
end

@testset "SPA" begin
    df_expected = expected_spa()
    conds = test_conditions()
    @test size(df_expected, 1) == 19
    @test size(df_expected, 2) == 6
    @test size(conds, 1) == 19
    @test size(conds, 2) == 4

    @testset "With default parameters" begin
        for ((dt, lat, lon, alt), row) in zip(eachrow(conds), eachrow(df_expected))
            if ismissing(alt)
                obs = Observer(lat, lon)
            else
                obs = Observer(lat, lon, altitude = alt)
            end

            # SPA includes refraction correction and equation of time
            res = solar_position(obs, dt, SPA())

            @test isapprox(res.elevation, row.elevation, atol = 1e-6)
            @test isapprox(res.zenith, row.zenith, atol = 1e-6)
            @test isapprox(res.azimuth, row.azimuth, atol = 1e-6)
            @test isapprox(res.apparent_elevation, row.apparent_elevation, atol = 1e-6)
            @test isapprox(res.apparent_zenith, row.apparent_zenith, atol = 1e-6)
            @test isapprox(res.equation_of_time, row.equation_of_time, atol = 1e-6)
        end
    end

    @testset "With delta_t=nothing" begin
        for ((dt, lat, lon, alt), row) in zip(eachrow(conds), eachrow(df_expected))
            if ismissing(alt)
                obs = Observer(lat, lon)
            else
                obs = Observer(lat, lon, altitude = alt)
            end

            res = solar_position(obs, dt, SPA(nothing, 101325.0, 12.0, 0.5667))

            # results can differ when delta_t is nothing
            @test isapprox(res.elevation, row.elevation, atol = 1e0)
            @test isapprox(res.zenith, row.zenith, atol = 1e0)
            @test isapprox(res.azimuth, row.azimuth, atol = 1e0)
        end
    end

    @testset "SPA refraction at high elevation" begin
        times = [ZonedDateTime(2020, 3, 23, 12, 0, 0, tz"UTC")]
        obs = Observer(0.0, 0.0)  # Equator at prime meridian
        res = solar_position(obs, times[1], SPA())

        # refraction correction should be minimal
        @test isapprox(res.elevation, res.apparent_elevation, atol = 1e-3)
    end

    @testset "Custom atmospheric parameters" begin
        lat, lon = 45.0, 10.0
        dt = ZonedDateTime(2020, 10, 17, 12, 30, 0, tz"UTC")
        obs = Observer(lat, lon)

        # test with different pressure/temperature
        res_default = solar_position(obs, dt, SPA(67.0, 101325.0, 12.0, 0.5667))
        res_custom = solar_position(obs, dt, SPA(67.0, 95000.0, 25.0, 0.5667))

        # different atmospheric conditions should give slightly different refraction
        @test !isapprox(
            res_default.apparent_elevation,
            res_custom.apparent_elevation,
            atol = 1e-6,
        )

        @test isapprox(res_default.elevation, res_custom.elevation, atol = 1e-10)
    end

    @testset "Multiple times at same location" begin
        lat, lon, alt = 40.0, -105.0, 1655.0
        obs = Observer(lat, lon, altitude = alt)

        # generate multiple timestamps
        base_dt = DateTime(2023, 6, 21, 0, 0, 0)
        times = [base_dt + Hour(h) for h = 0:23]
        results = [solar_position(obs, dt, SPA()) for dt in times]

        # verify we got 24 results and they're reasonable
        @test length(results) == 24
        @test all(r -> -180.0 <= r.azimuth <= 360.0, results)
        @test all(r -> -90.0 <= r.elevation <= 90.0, results)
    end
end
