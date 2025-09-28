"""Unit tests for solar_position interface variants"""

# using SolarPosition.Positioning: solar_position, solar_position!, Observer, PSA
using SolarPosition.Positioning: Observer, PSA, SolPos
using Dates, TimeZones, Tables, DataFrames
using StructArrays: StructVector

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
    dts = [base_dt + Hour(i) for i = 0:n_dts-1]
    dts_zoned = [ZonedDateTime(dt, tz"UTC") for dt in dts]

    single_dt = base_dt
    single_result = solar_position(obs, single_dt)

    @testset "In place" begin
        pos = StructVector{SolPos}((
            azimuth = zeros(n_dts),
            elevation = zeros(n_dts),
            zenith = zeros(n_dts),
        ))

        solar_position!(pos, obs, dts)

    end
end