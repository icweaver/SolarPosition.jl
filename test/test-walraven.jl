"""Unit tests for Walraven algorithm"""

function expected_walraven()
    columns = [:elevation, :zenith, :azimuth]

    values = [
        [32.21577184, 57.78422816, 204.9145408],
        [32.20330752, 57.79669248, 204.96082497],
        [34.91988403, 55.08011597, 169.37445826],
        [18.63514306, 71.36485694, 234.18579686],
        [35.75942569, 54.24057431, 197.67543014],
        [-9.53241956, 99.53241956, 201.18624892],
        [66.85832643, 23.14167357, 245.07813388],
        [9.53241956, 80.46758044, 338.81375108],
        [50.11302395, 39.88697605, 326.23525905],
        [35.35901685, 54.64098315, 175.38665251],
        [-53.24443195, 143.24443195, 18.64588668],
        [-53.24443195, 143.24443195, 18.64588668],
        [33.19945919, 56.80054081, 205.08690939],
        [32.078221, 57.921779, 204.90430273],
        [-23.41074972, 113.41074972, 79.55008786],
        [1.10528968, 88.89471032, 104.541125],
        [32.21577184, 57.78422816, 204.9145408],
        [32.21577184, 57.78422816, 204.9145408],
        [32.21577184, 57.78422816, 204.9145408],
    ]

    return DataFrame(reduce(hcat, values)', columns)
end

@testset "Walraven" begin
    df_expected = expected_walraven()
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

        res = solar_position(obs, dt, Walraven())
        @test isapprox(res.elevation, exp_elev, atol = 1e-6)
        @test isapprox(res.zenith, exp_zen, atol = 1e-6)
        @test isapprox(res.azimuth, exp_az, atol = 1e-6)
    end
end
