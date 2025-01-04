"""Tests related to the computation of solar time and angle quantities."""

using Dates
using DynamicQuantities
using TimeZones

using SolarPosition.PositionInterface

const deg_to_min = (24 * 60) / 360 * us"min/deg"

"""Tests related to the equation of time.

Special test data is loaded from the file `data/spa-test-data-1.csv`.

Other interesting dates are:

|     Day     | Equation of Time |
|-------------|------------------|
| February 11 | [-15, -14]       |
| May 11      | [ +3,  +4]       |
| July 26     | [ -7,  -6]       |
| November 2  | [+16,  17]       |
"""

@testset "Function equation_of_time" begin
    dfs = load_test_data()

    for (file, meta) in dfs
        df = meta["df"]
        for row in eachrow(df)
            eot = PositionInterface.equation_of_time(row.timestamp) * deg_to_min
            @test eot isa Quantity
            @test eot≈row.EoT * us"min" atol=1.0us"min"
        end
    end
end

"""Tests related to solar declination.

    |     Day       | Declination ± 0.3|
    |---------------|------------------|
    | March 22      | 0                |  
    | June 21       | +23.45           |
    | September 23  | 0                |
    | December 22   | -23.45           |
"""

@testset "Function declination" begin
    dfs = load_test_data()

    for (file, meta) in dfs
        df = meta["df"]
        for row in eachrow(df)
            δ = PositionInterface.declination(row.timestamp)
            @test δ isa Quantity
            @test δ≈row.δ * us"deg" atol=1.0us"deg"
        end

        @test PositionInterface.declination(80)≈0 * us"deg" atol=1.0us"deg"
        @test_throws ArgumentError PositionInterface.declination(-1)
        @test_throws ArgumentError PositionInterface.declination(366)
    end
end

"""Offset hours tests.

The offset in hours is the difference between UTC-0 and the UTC-`tz` timezone of the observer.
"""

@testset "Function offset_hours" begin
    cases = [
        (DateTime("2021-01-01T00:00:00"), 0),
        (DateTime("2021-01-01T12:00:00"), 0),
        (ZonedDateTime(2020, 2, 13, 4, 0, TimeZone("UTC-7")), -7),
        (ZonedDateTime(2020, 2, 13, 4, 0, TimeZone("UTC+1")), 1),
        (ZonedDateTime(2020, 2, 13, 4, 0, TimeZone("UTC+2")), 2),
        (ZonedDateTime(2020, 2, 13, 4, 0, TimeZone("UTC+3")), 3),
        (ZonedDateTime(2020, 2, 13, 4, 0, TimeZone("Europe/Madrid")), 1),
        (ZonedDateTime(2020, 2, 13, 4, 0, TimeZone("America/New_York")), -5),
        (ZonedDateTime(2020, 2, 13, 4, 0, TimeZone("America/Los_Angeles")), -8),
        (ZonedDateTime(2020, 2, 13, 4, 0, TimeZone("Australia/Sydney")), 10)
    ]

    for (dt, offset) in cases
        @test PositionInterface.offset_hours(dt) == Hour(offset)
    end
end

"""Fractional hour tests.

The fractional hour is the time of the day as a fraction of 24 hours.
"""

@testset "Function fractional_hour" begin
    cases = [
        (DateTime("2021-01-01T00:00:00"), 0.0),
        (DateTime("2021-01-01T12:00:00"), 12.0),
        (ZonedDateTime(2020, 2, 13, 1, 0, TimeZone("UTC-7")), 1.0),
        (ZonedDateTime(2020, 2, 13, 4, 0, TimeZone("UTC-7")), 4.0),
        (ZonedDateTime(2020, 2, 13, 12, 0, TimeZone("UTC-7")), 12.0),
        (ZonedDateTime(2020, 2, 13, 23, 59, TimeZone("UTC-7")), 23 + 59 / 60),
        (ZonedDateTime(2020, 2, 13, 12, 50, 50, TimeZone("UTC-7")),
            12 + 50 / 60 + 50 / 3600)
    ]

    for (dt, frac) in cases
        @test PositionInterface.fractional_hour(dt)≈frac atol=1e-5
    end
end
