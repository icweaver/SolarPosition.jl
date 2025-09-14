"""Unit tests for solar_position interface variants"""

using SolarPosition.Positioning: solar_position, Observer, PSA
using Dates, TimeZones, Tables, DataFrames

@testset "Scalar Interface" begin
    lat, lon, alt = 45.0, 10.0, 4000.0
    dt_plain = DateTime(2020, 10, 17, 12, 30)
    dt_zoned = ZonedDateTime(2020, 10, 17, 12, 30, tz"UTC")

    # Reference result using Observer directly
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
