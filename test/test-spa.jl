"""Unit tests for SPA algorithm (not yet implemented)"""

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

@testset "SPA (not implemented)" begin
    @test_skip begin
        df_expected = expected_spa()
        conds = test_conditions()
        @test size(df_expected, 1) == 19
        @test size(df_expected, 2) == 6
        @test size(conds, 1) == 19
        @test size(conds, 2) == 4

        # TODO: Implement SPA (Solar Position Algorithm) by NREL
        # This is a high-accuracy algorithm (±0.0003°)
        # struct SPA <: SolarAlgorithm end

        # for ((dt, lat, lon, alt), row) in zip(eachrow(conds), eachrow(df_expected))
        #     if ismissing(alt)
        #         obs = Observer(lat, lon)
        #     else
        #         obs = Observer(lat, lon, altitude = alt)
        #     end
        #
        #     # SPA includes refraction correction and equation of time
        #     res = solar_position(obs, dt, SPA())
        #
        #     @test isapprox(res.elevation, row.elevation, atol = 1e-7)
        #     @test isapprox(res.zenith, row.zenith, atol = 1e-7)
        #     @test isapprox(res.azimuth, row.azimuth, atol = 1e-7)
        #     @test isapprox(res.apparent_elevation, row.apparent_elevation, atol = 1e-7)
        #     @test isapprox(res.apparent_zenith, row.apparent_zenith, atol = 1e-7)
        #     @test isapprox(res.equation_of_time, row.equation_of_time, atol = 1e-7)
        # end
    end

    @testset "SPA refraction at high elevation" begin
        @test_skip begin
            # Test that SPA sets refraction to zero for solar elevation angles
            # between 85 and 90 degrees (when sun is nearly overhead)
            # The below example has a solar elevation angle of ~87.9°
            times = [ZonedDateTime(2020, 3, 23, 12, 0, 0, tz"UTC")]
            obs = Observer(0.0, 0.0)  # Equator at prime meridian

            res = solar_position(obs, times[1], SPA())

            # At such high elevation, refraction correction should be minimal/zero
            # so elevation ≈ apparent_elevation
            @test isapprox(res.elevation, res.apparent_elevation, atol = 1e-6)
        end
    end
end
