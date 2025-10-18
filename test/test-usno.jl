"""Unit tests for USNO algorithm"""

function expected_usno()
    columns = [:elevation, :zenith, :azimuth]

    values = [
        [32.21913058, 57.78086942, 204.91396212],
        [32.20666654, 57.79333346, 204.9602485],
        [34.92271632, 55.07728368, 169.37217155],
        [18.63848631, 71.36151369, 234.18640074],
        [35.75823472, 54.24176528, 197.67107057],
        [-9.52936557, 99.52936557, 201.18474698],
        [66.86088833, 23.13911167, 245.08379957],
        [9.52936557, 80.47063443, 338.81525302],
        [50.11081313, 39.88918687, 326.23927513],
        [35.36198031, 54.63801969, 175.38462327],
        [-53.24179879, 143.24179879, 18.6423076],
        [-53.24179879, 143.24179879, 18.6423076],
        [32.46463884, 57.53536116, 204.9389006],
        [32.44304455, 57.55695545, 204.98724112],
        [-23.40963192, 113.40963192, 79.54658304],
        [1.10645791, 88.89354209, 104.53792899],
        [32.21913058, 57.78086942, 204.91396212],
        [32.21913058, 57.78086942, 204.91396212],
        [32.21913058, 57.78086942, 204.91396212],
    ]

    return DataFrame(reduce(hcat, values)', columns)
end

function expected_usno_option_2()
    columns = [:elevation, :zenith, :azimuth]

    values = [
        [32.21913452, 57.78086548, 204.91394742],
        [32.20667049, 57.79332951, 204.96023379],
        [34.92271497, 55.07728503, 169.37215926],
        [18.63849557, 71.36150443, 234.18638706],
        [35.7582376, 54.2417624, 197.67105461],
        [-9.52936557, 99.52936557, 201.18473375],
        [66.86090033, 23.13909967, 245.08378652],
        [9.52936557, 80.47063443, 338.81526625],
        [50.11081833, 39.88918167, 326.2392938],
        [35.36197956, 54.63802044, 175.38460729],
        [-53.24180178, 143.24180178, 18.64228637],
        [-53.24180178, 143.24180178, 18.64228637],
        [32.46465875, 57.53534125, 204.93882613],
        [32.44303542, 57.55696458, 204.98727521],
        [-23.40963198, 113.40963198, 79.54658298],
        [1.10645552, 88.89354448, 104.53792651],
        [32.21913452, 57.78086548, 204.91394742],
        [32.21913452, 57.78086548, 204.91394742],
        [32.21913452, 57.78086548, 204.91394742],
    ]

    return DataFrame(reduce(hcat, values)', columns)
end

@testset "USNO" begin
    @testset "With default delta_t (gmst_option=1)" begin
        df_expected = expected_usno()
        conds = test_conditions()
        @test size(df_expected, 1) == 19
        @test size(df_expected, 2) == 3
        @test size(conds, 1) == 19
        @test size(conds, 2) == 4

        for ((dt, lat, lon, alt), (exp_elev, exp_zen, exp_az)) in
            zip(eachrow(conds), eachrow(df_expected))
            if ismissing(alt)
                obs = Observer(lat, lon)
            else
                obs = Observer(lat, lon, altitude = alt)
            end

            res = solar_position(obs, dt, USNO())

            @test isapprox(res.elevation, exp_elev, atol = 1e-6)
            @test isapprox(res.zenith, exp_zen, atol = 1e-6)
            @test isapprox(res.azimuth, exp_az, atol = 1e-6)
        end
    end

    @testset "With gmst_option=2" begin
        df_expected = expected_usno_option_2()
        conds = test_conditions()

        for ((dt, lat, lon, alt), (exp_elev, exp_zen, exp_az)) in
            zip(eachrow(conds), eachrow(df_expected))
            if ismissing(alt)
                obs = Observer(lat, lon)
            else
                obs = Observer(lat, lon, altitude = alt)
            end

            res = solar_position(obs, dt, USNO(67.0, 2))

            @test isapprox(res.elevation, exp_elev, atol = 1e-6)
            @test isapprox(res.zenith, exp_zen, atol = 1e-6)
            @test isapprox(res.azimuth, exp_az, atol = 1e-6)
        end
    end

    @testset "With delta_t=nothing" begin
        df_expected = expected_usno()
        conds = test_conditions()

        for ((dt, lat, lon, alt), (exp_elev, exp_zen, exp_az)) in
            zip(eachrow(conds), eachrow(df_expected))
            if ismissing(alt)
                obs = Observer(lat, lon)
            else
                obs = Observer(lat, lon, altitude = alt)
            end

            res = solar_position(obs, dt, USNO(nothing, 1))

            # results can differ when delta_t is nothing
            @test isapprox(res.elevation, exp_elev, atol = 1e0)
            @test isapprox(res.zenith, exp_zen, atol = 1e0)
            @test isapprox(res.azimuth, exp_az, atol = 1e0)
        end
    end

    @testset "Invalid gmst_option" begin
        @test_throws ErrorException USNO(67.0, 3)
        @test_throws ErrorException USNO(67.0, 0)
    end

    @testset "Solar noon test" begin
        lat, lon = 0.0, 0.0

        # spring equinox at noon UTC when sun is roughly overhead at prime meridian
        dt = ZonedDateTime(2024, 3, 20, 12, 0, 0, tz"UTC")
        obs = Observer(lat, lon)

        res = solar_position(obs, dt, USNO())

        # at equinox and solar noon at equator/prime meridian,
        # elevation should be close to 90 degrees
        @test res.elevation > 85.0
        @test res.zenith < 5.0
    end
end
