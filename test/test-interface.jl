"""Unit tests for solar_position interface variants"""

# using SolarPosition.Positioning: solar_position, solar_position!, Observer, PSA
using SolarPosition.Positioning: Observer, PSA, SolPos, solar_position, solar_position!
using Dates, TimeZones, Tables, DataFrames
using StructArrays: StructVector
using Dates: Hour, @dateformat_str

@testset "Scalar Interface" begin
    lat, lon, alt = 45.0, 10.0, 4000.0
    dt_plain = DateTime(2020, 10, 17, 12, 30)
    dt_zoned = ZonedDateTime(2020, 10, 17, 12, 30, tz"UTC")

    # reference result using Observer directly
    obs_ref = Observer(lat, lon, alt)
    result_ref = solar_position(obs_ref, dt_plain)

    @testset "Observer" begin
        # DateTime
        result1 = solar_position(obs_ref, dt_plain)
        @test result1 == result_ref

        # ZonedDateTime
        result2 = solar_position(obs_ref, dt_zoned)
        @test result2 == result_ref
    end

end

@testset "Vectorized Interface" begin
    lat, lon, alt = 45.0, 10.0, 4000.0
    obs = Observer(lat, lon, alt)
    n_dts = 10

    base_dt = DateTime(2020, 10, 17, 12, 30)
    dts = [base_dt + Hour(i) for i = 0:(n_dts-1)]
    dts_zoned = [ZonedDateTime(dt, tz"UTC") for dt in dts]

    single_dt = base_dt
    single_result = solar_position(obs, single_dt)

    @testset "In place" begin
        pos = StructVector{SolPos{Float64}}((
            azimuth = zeros(n_dts),
            elevation = zeros(n_dts),
            zenith = zeros(n_dts),
        ))

        solar_position!(pos, obs, dts)
        @test all(pos .!= 0.0)
        @test pos[1] == single_result
        @test pos isa StructVector{SolPos{Float64}}
        @test length(pos) == n_dts
    end

    @testset "Return new" begin
        # DateTime
        pos1 = solar_position(obs, dts)
        @test pos1 isa StructVector{SolPos{Float64}}
        @test length(pos1) == n_dts
        @test pos1[1] == single_result

        # ZonedDateTime
        pos2 = solar_position(obs, dts_zoned)
        @test pos2 isa StructVector{SolPos{Float64}}
        @test length(pos2) == n_dts
        @test pos2[1] == single_result

        @test pos1 == pos2
    end
end


@testset "Tables Interface" begin
    lat, lon, alt = 45.0, 10.0, 4000.0
    obs = Observer(lat, lon, alt)
    base_dt = DateTime(2020, 10, 17, 12, 30)
    dt_vector = [base_dt + Hour(i) for i = 0:2]

    @testset "DataFrame with Observer" begin
        df = DataFrame(datetime = dt_vector, temperature = [20.0, 21.0, 22.0])
        result = solar_position!(df, obs)

        @test result === df
        @test "azimuth" in names(df)
        @test "elevation" in names(df)
        @test "zenith" in names(df)
        @test df.datetime == dt_vector
        @test df.temperature == [20.0, 21.0, 22.0]
        @test all(isfinite, df.azimuth)
        @test all(isfinite, df.elevation)
        @test all(isfinite, df.zenith)

        direct_result = solar_position(obs, dt_vector)
        @test df.azimuth == direct_result.azimuth
        @test df.elevation == direct_result.elevation
        @test df.zenith == direct_result.zenith
    end

    @testset "Error Cases" begin
        df_no_datetime = DataFrame(temperature = [20.0, 21.0, 22.0])
        @test_throws ArgumentError solar_position!(df_no_datetime, obs)

        df_empty = DataFrame(datetime = DateTime[])
        result = solar_position!(df_empty, obs)
        @test "azimuth" in names(result)
        @test "elevation" in names(result)
        @test "zenith" in names(result)
        @test length(result.azimuth) == 0
    end

    @testset "Custom DateTime Column" begin
        df = DataFrame(time_utc = dt_vector)
        result = solar_position!(df, obs; dt_col = :time_utc)

        @test result === df
        @test "azimuth" in names(df)
        @test "elevation" in names(df)
        @test "zenith" in names(df)
        @test df.time_utc == dt_vector

        direct_result = solar_position(obs, dt_vector)
        @test df.azimuth == direct_result.azimuth
        @test df.elevation == direct_result.elevation
        @test df.zenith == direct_result.zenith
    end

end
