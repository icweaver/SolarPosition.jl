"""Unit tests for USNO algorithm (not yet implemented)"""

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

@testset "USNO (not implemented)" begin
    @test_skip begin
        # TODO: Implement USNO algorithm
        # struct USNO <: SolarAlgorithm
        #     delta_t::Union{Nothing, Float64, Vector{Float64}}
        #     gmst_option::Int  # 1 or 2
        # end

        @testset "Default (gmst_option=1)" begin
            df_expected = expected_usno()
            conds = test_conditions()
            @test size(df_expected, 1) == 19
            @test size(df_expected, 2) == 3

            # for ((dt, lat, lon, alt), (exp_elev, exp_zen, exp_az)) in
            #     zip(eachrow(conds), eachrow(df_expected))
            #     if ismissing(alt)
            #         obs = Observer(lat, lon)
            #     else
            #         obs = Observer(lat, lon, altitude = alt)
            #     end
            #
            #     res = solar_position(obs, dt, USNO(gmst_option=1))
            #     @test isapprox(res.elevation, exp_elev, atol = 1e-6)
            #     @test isapprox(res.zenith, exp_zen, atol = 1e-6)
            #     @test isapprox(res.azimuth, exp_az, atol = 1e-6)
            # end
        end

        @testset "gmst_option=2" begin
            df_expected = expected_usno_option_2()
            conds = test_conditions()

            # Test with gmst_option=2
            # Similar structure as above but with USNO(gmst_option=2)
        end

        @testset "delta_t with nothing" begin
            # Test that delta_t=nothing works correctly
            times = [ZonedDateTime(2020, 3, 23, 12, 0, 0, tz"UTC")]
            obs = Observer(50.0, 10.0)

            # res_default = solar_position(obs, times[1], USNO())
            # res_nothing = solar_position(obs, times[1], USNO(delta_t=nothing))
            #
            # Results may differ when delta_t is nothing
            # @test !isapprox(res_default.elevation, res_nothing.elevation, atol = 1e-10)
        end

        @testset "Invalid gmst_option" begin
            # Test that invalid gmst_option throws error
            # @test_throws ArgumentError USNO(gmst_option=3)
            # @test_throws ArgumentError USNO(gmst_option="not_an_option")
        end
    end

    @testset "delta_t array and series input" begin
        @test_skip begin
            # Test that delta_t can be specified as either an array or float
            times = collect(
                ZonedDateTime(2020, 3, 23, 12, 0, 0, tz"UTC"):Hour(1):ZonedDateTime(
                    2020,
                    3,
                    23,
                    22,
                    0,
                    0,
                    tz"UTC",
                ),
            )
            obs = Observer(50.0, 10.0)
            delta_t = fill(67.0, length(times))

            # usno_array = solar_position(obs, times, USNO(delta_t=delta_t))
            # usno_float = solar_position(obs, times, USNO(delta_t=67.0))
            #
            # @test usno_array.elevation ≈ usno_float.elevation
            # @test usno_array.zenith ≈ usno_float.zenith
            # @test usno_array.azimuth ≈ usno_float.azimuth
        end
    end
end
