"""Unit tests for Skyfield algorithm (not yet implemented)"""

function expected_skyfield()
    columns = [:elevation, :zenith, :azimuth]

    values = [
        [32.21731177, 57.78268823, 204.91794786],
        [32.20484556, 57.79515444, 204.96423388],
        [34.92239511, 55.07760489, 169.37578931],
        [18.63535617, 71.36464383, 234.18984836],
        [35.75683037, 54.24316963, 197.66893877],
        [-9.5305175, 99.5305175, 201.18798691],
        [66.85755467, 23.14244533, 245.08983994],
        [9.52569869, 80.47430131, 338.81201317],
        [50.10684928, 39.89315072, 326.23556156],
        [35.36142589, 54.63857411, 175.38836795],
        [-53.24128453, 143.24128453, 18.64711844],
        [-53.24128453, 143.24128453, 18.64711844],
        [32.43211642, 57.56788358, 205.06175657],
        [32.62788726, 57.36871411, 204.26008339],
        [-23.40856284, 113.40856284, 79.54814898],
        [1.10723972, 88.89276028, 104.53937506],
        [32.21731177, 57.78268823, 204.91794786],
        [32.21731177, 57.78268823, 204.91794786],
        [32.21731177, 57.78268823, 204.91794786],
    ]

    return DataFrame(reduce(hcat, values)', columns)
end

@testset "Skyfield (not implemented)" begin
    @test_skip begin
        df_expected = expected_skyfield()
        conds = test_conditions()
        @test size(df_expected, 1) == 19
        @test size(df_expected, 2) == 3
        @test size(conds, 1) == 19
        @test size(conds, 2) == 4

        # TODO: Implement Skyfield algorithm
        # This algorithm uses the Skyfield astronomical library approach
        # struct Skyfield <: SolarAlgorithm end

        # for ((dt, lat, lon, alt), (exp_elev, exp_zen, exp_az)) in
        #     zip(eachrow(conds), eachrow(df_expected))
        #     if ismissing(alt)
        #         obs = Observer(lat, lon)
        #     else
        #         obs = Observer(lat, lon, altitude = alt)
        #     end
        #
        #     res = solar_position(obs, dt, Skyfield())
        #     @test isapprox(res.elevation, exp_elev, atol = 1e-6)
        #     @test isapprox(res.zenith, exp_zen, atol = 1e-6)
        #     @test isapprox(res.azimuth, exp_az, atol = 1e-6)
        # end
    end
end
