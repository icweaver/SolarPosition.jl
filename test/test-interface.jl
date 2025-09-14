"""Unit tests for solar_position interface variants"""

using SolarPosition.Positioning: solar_position, solar_position!, Observer, PSA
using Dates, TimeZones, Tables, DataFrames

@testset "Scalar Interface" begin
    lat, lon, alt = 45.0, 10.0, 4000.0
    dt_plain = DateTime(2020, 10, 17, 12, 30)
    dt_zoned = ZonedDateTime(2020, 10, 17, 12, 30, tz"UTC")

    # reference result using Observer directly
    obs_ref = Observer(lat, lon, alt)
    result_ref = solar_position(obs_ref, dt_plain)

    @testset "Keyword Arguments" begin
        # altitude specified
        result1 = solar_position(dt_plain; latitude = lat, longitude = lon, altitude = alt)
        @test result1 == result_ref

        # ZonedDateTime
        result2 = solar_position(dt_zoned; latitude = lat, longitude = lon, altitude = alt)
        @test result2 == result_ref

        # without altitude (should default to 0)
        obs_no_alt = Observer(lat, lon, 0.0)
        result_no_alt_ref = solar_position(obs_no_alt, dt_plain)

        result3 = solar_position(dt_plain; latitude = lat, longitude = lon)
        @test result3 == result_no_alt_ref

        # ZonedDateTime, no altitude
        result4 = solar_position(dt_zoned; latitude = lat, longitude = lon)
        @test result4 == result_no_alt_ref
    end

    @testset "Algorithm Parameter" begin
        # that algorithm parameter is passed through correctly
        result1 = solar_position(
            dt_plain;
            latitude = lat,
            longitude = lon,
            altitude = alt,
            alg = PSA(),
            coeffs = 2020,
        )
        result2 = solar_position(
            dt_plain;
            latitude = lat,
            longitude = lon,
            altitude = alt,
            alg = PSA(),
            coeffs = 2020,
        )

        @test result1 == result2

        # different coefficient sets work
        result_2001 = solar_position(
            dt_plain;
            latitude = lat,
            longitude = lon,
            altitude = alt,
            coeffs = 2001,
        )
        result_2020 = solar_position(
            dt_plain;
            latitude = lat,
            longitude = lon,
            altitude = alt,
            coeffs = 2020,
        )

        @test result_2001.azimuth != result_2020.azimuth
        @test result_2001.elevation != result_2020.elevation
    end

    @testset "Type Handling" begin
        # float32, float64 inputs give approx. same results
        result_float32 = solar_position(
            dt_plain;
            latitude = 45.0f0,
            longitude = 10.0f0,
            altitude = 0.0f0,
        )
        result_float64 =
            solar_position(dt_plain; latitude = 45.0, longitude = 10.0, altitude = 0.0)

        @test result_float32.azimuth ≈ result_float64.azimuth atol = 1e-6
        @test result_float32.elevation ≈ result_float64.elevation atol = 1e-6
        @test result_float32.zenith ≈ result_float64.zenith atol = 1e-6
    end

    @testset "Cross-Interface Consistency" begin
        obs = Observer(lat, lon, alt)
        result_obs = solar_position(obs, dt_plain)
        result_kw =
            solar_position(dt_plain; latitude = lat, longitude = lon, altitude = alt)

        @test result_obs == result_kw
    end
end

@testset "Vectorized Interface" begin
    lat, lon, alt = 45.0, 10.0, 4000.0
    obs = Observer(lat, lon, alt)

    # Create test datetime vectors
    base_dt = DateTime(2020, 10, 17, 12, 30)
    dt_vector = [base_dt + Hour(i) for i = 0:4]  # 5 time points
    dt_zoned_vector = [ZonedDateTime(dt, tz"UTC") for dt in dt_vector]

    # Single datetime for comparison
    single_dt = base_dt
    single_result = solar_position(obs, single_dt)

    @testset "Observer with DateTime Vector" begin
        result = solar_position(obs, dt_vector)

        # return structure
        @test haskey(result, :datetime)
        @test haskey(result, :azimuth)
        @test haskey(result, :elevation)
        @test haskey(result, :zenith)

        # lengths match input
        @test length(result.datetime) == length(dt_vector)
        @test length(result.azimuth) == length(dt_vector)
        @test length(result.elevation) == length(dt_vector)
        @test length(result.zenith) == length(dt_vector)

        # first result matches single call
        @test result.datetime == dt_vector
        @test result.azimuth[1] ≈ single_result.azimuth
        @test result.elevation[1] ≈ single_result.elevation
        @test result.zenith[1] ≈ single_result.zenith

        # results are different across times
        @test !all(result.azimuth .≈ result.azimuth[1])
        @test !all(result.elevation .≈ result.elevation[1])
    end

    @testset "Keywords with DateTime Vector" begin
        result = solar_position(dt_vector; latitude = lat, longitude = lon, altitude = alt)

        @test haskey(result, :datetime)
        @test haskey(result, :azimuth)
        @test haskey(result, :elevation)
        @test haskey(result, :zenith)

        @test length(result.datetime) == length(dt_vector)
        @test length(result.azimuth) == length(dt_vector)
        @test length(result.elevation) == length(dt_vector)
        @test length(result.zenith) == length(dt_vector)

        # datetime preservation
        @test result.datetime == dt_vector

        # consistency with Observer interface
        obs_result = solar_position(obs, dt_vector)
        @test result.azimuth ≈ obs_result.azimuth
        @test result.elevation ≈ obs_result.elevation
        @test result.zenith ≈ obs_result.zenith
    end

    @testset "Keywords with ZonedDateTime Vector" begin
        result =
            solar_position(dt_zoned_vector; latitude = lat, longitude = lon, altitude = alt)

        # return structure
        @test haskey(result, :datetime)
        @test haskey(result, :azimuth)
        @test haskey(result, :elevation)
        @test haskey(result, :zenith)

        # lengths
        @test length(result.datetime) == length(dt_zoned_vector)
        @test length(result.azimuth) == length(dt_zoned_vector)
        @test length(result.elevation) == length(dt_zoned_vector)
        @test length(result.zenith) == length(dt_zoned_vector)

        # datetime preservation (ZonedDateTime gets converted to DateTime)
        @test result.datetime == DateTime.(dt_zoned_vector, UTC)

        # consistency with DateTime version (should give same results)
        dt_result =
            solar_position(dt_vector; latitude = lat, longitude = lon, altitude = alt)
        @test result.azimuth ≈ dt_result.azimuth
        @test result.elevation ≈ dt_result.elevation
        @test result.zenith ≈ dt_result.zenith
    end

    @testset "Default Altitude" begin
        result_no_alt = solar_position(dt_vector; latitude = lat, longitude = lon)
        result_zero_alt =
            solar_position(dt_vector; latitude = lat, longitude = lon, altitude = 0.0)

        @test result_no_alt.azimuth ≈ result_zero_alt.azimuth
        @test result_no_alt.elevation ≈ result_zero_alt.elevation
        @test result_no_alt.zenith ≈ result_zero_alt.zenith
    end

    @testset "Empty Vector" begin
        empty_dt_vector = DateTime[]
        result = solar_position(empty_dt_vector; latitude = lat, longitude = lon)

        @test length(result.datetime) == 0
        @test length(result.azimuth) == 0
        @test length(result.elevation) == 0
        @test length(result.zenith) == 0
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
        @test df.azimuth ≈ direct_result.azimuth
        @test df.elevation ≈ direct_result.elevation
        @test df.zenith ≈ direct_result.zenith
    end

    @testset "Keyword Interface" begin
        df = DataFrame(datetime = dt_vector, humidity = [60.0, 65.0, 70.0])
        result = solar_position!(df; latitude = lat, longitude = lon, altitude = alt)

        @test result === df
        @test "azimuth" in names(df)
        @test "elevation" in names(df)
        @test "zenith" in names(df)

        df2 = DataFrame(datetime = dt_vector, humidity = [60.0, 65.0, 70.0])
        solar_position!(df2, obs)
        @test df.azimuth ≈ df2.azimuth
        @test df.elevation ≈ df2.elevation
        @test df.zenith ≈ df2.zenith
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

    @testset "Algorithm Parameters" begin
        df = DataFrame(datetime = dt_vector)
        solar_position!(df, obs; alg = PSA(), coeffs = 2020)

        @test "azimuth" in names(df)
        @test "elevation" in names(df)
        @test "zenith" in names(df)
        @test all(isfinite, df.azimuth)
        @test all(isfinite, df.elevation)
        @test all(isfinite, df.zenith)
    end

end
