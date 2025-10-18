"""Unit tests for solar_position interface variants"""

# using SolarPosition.Positioning: solar_position, solar_position!, Observer, PSA
using SolarPosition.Positioning:
    Observer, PSA, NOAA, Walraven, SolPos, solar_position, solar_position!
using Dates, TimeZones, Tables, DataFrames
using StructArrays: StructVector
using Dates: Hour, @dateformat_str

@testset "Scalar Interface - $alg_name" for (alg_name, alg) in [
    ("PSA", PSA()),
    ("NOAA", NOAA()),
    ("Walraven", Walraven()),
]
    lat, lon, alt = 45.0, 10.0, 4000.0
    dt_plain = DateTime(2020, 10, 17, 12, 30)
    dt_zoned = ZonedDateTime(2020, 10, 17, 12, 30, tz"UTC")

    # reference result using Observer directly
    obs_ref = Observer(lat, lon, alt)
    result_ref = solar_position(obs_ref, dt_plain, alg)

    @testset "Observer" begin
        # DateTime
        result1 = solar_position(obs_ref, dt_plain, alg)
        @test result1 == result_ref

        # ZonedDateTime
        result2 = solar_position(obs_ref, dt_zoned, alg)
        @test result2 == result_ref
    end

end

@testset "Vectorized Interface - $alg_name" for (alg_name, alg) in [
    ("PSA", PSA()),
    ("NOAA", NOAA()),
    ("Walraven", Walraven()),
]
    lat, lon, alt = 45.0, 10.0, 4000.0
    obs = Observer(lat, lon, alt)
    n_dts = 10

    base_dt = DateTime(2020, 10, 17, 12, 30)
    dts = [base_dt + Hour(i) for i = 0:(n_dts-1)]
    dts_zoned = [ZonedDateTime(dt, tz"UTC") for dt in dts]

    single_dt = base_dt
    single_result = solar_position(obs, single_dt, alg)

    @testset "In place" begin
        pos = StructVector{SolPos{Float64}}((
            azimuth = zeros(n_dts),
            elevation = zeros(n_dts),
            zenith = zeros(n_dts),
        ))

        solar_position!(pos, obs, dts, alg)
        @test all(pos .!= 0.0)
        @test pos[1] == single_result
        @test pos isa StructVector{SolPos{Float64}}
        @test length(pos) == n_dts

        # test a second time to ensure there are no allocations
        # (we test ≤ 32 because on julia LTS there are some unavoidable allocations)
        @test @allocated(solar_position!(pos, obs, dts, alg)) ≤ 32
        @test all(pos .!= 0.0)
        @test pos[1] == single_result
        @test pos isa StructVector{SolPos{Float64}}
        @test length(pos) == n_dts
    end

    @testset "Return new" begin
        # DateTime
        pos1 = solar_position(obs, dts, alg)
        @test pos1 isa StructVector{SolPos{Float64}}
        @test length(pos1) == n_dts
        @test pos1[1] == single_result

        # ZonedDateTime
        pos2 = solar_position(obs, dts_zoned, alg)
        @test pos2 isa StructVector{SolPos{Float64}}
        @test length(pos2) == n_dts
        @test pos2[1] == single_result

        @test pos1 == pos2
    end
end


@testset "Tables Interface - $alg_name" for (alg_name, alg) in [
    ("PSA", PSA()),
    ("NOAA", NOAA()),
    ("Walraven", Walraven()),
]
    lat, lon, alt = 45.0, 10.0, 4000.0
    obs = Observer(lat, lon, alt)
    base_dt = DateTime(2020, 10, 17, 12, 30)
    dt_vector = [base_dt + Hour(i) for i = 0:2]

    @testset "DataFrame with Observer" begin
        df = DataFrame(datetime = dt_vector, temperature = [20.0, 21.0, 22.0])
        solar_position!(df, obs, alg)

        @test "azimuth" in names(df)
        @test "elevation" in names(df)
        @test "zenith" in names(df)
        @test "temperature" in names(df)
        @test df.datetime == dt_vector
        @test df.temperature == [20.0, 21.0, 22.0]
        @test all(isfinite, df.azimuth)
        @test all(isfinite, df.elevation)
        @test all(isfinite, df.zenith)

        direct_result = solar_position(obs, dt_vector, alg)
        @test df.azimuth == direct_result.azimuth
        @test df.elevation == direct_result.elevation
        @test df.zenith == direct_result.zenith
    end

    @testset "Error Cases" begin
        df_no_datetime = DataFrame(temperature = [20.0, 21.0, 22.0])
        @test_throws ArgumentError solar_position!(df_no_datetime, obs, alg)

        df_empty = DataFrame(datetime = DateTime[])
        solar_position!(df_empty, obs, alg)
        @test "azimuth" in names(df_empty)
        @test "elevation" in names(df_empty)
        @test "zenith" in names(df_empty)
        @test length(df_empty.azimuth) == 0
    end

    @testset "Custom DateTime Column" begin
        df = DataFrame(time_utc = dt_vector)
        solar_position!(df, obs, alg; dt_col = :time_utc)

        @test "azimuth" in names(df)
        @test "elevation" in names(df)
        @test "zenith" in names(df)
        @test df.time_utc == dt_vector

        direct_result = solar_position(obs, dt_vector, alg)
        @test df.azimuth == direct_result.azimuth
        @test df.elevation == direct_result.elevation
        @test df.zenith == direct_result.zenith
    end

    @testset "Return new Table" begin
        df = DataFrame(datetime = dt_vector, temperature = [20.0, 21.0, 22.0])
        result_table = solar_position(df, obs, alg)

        @test result_table isa DataFrame
        @test "azimuth" in names(result_table)
        @test "elevation" in names(result_table)
        @test "zenith" in names(result_table)
        @test "temperature" in names(result_table)
        @test result_table.datetime == df.datetime
        @test result_table.temperature == df.temperature

        direct_result = solar_position(obs, dt_vector, alg)
        @test result_table.azimuth == direct_result.azimuth
        @test result_table.elevation == direct_result.elevation
        @test result_table.zenith == direct_result.zenith
    end

end
