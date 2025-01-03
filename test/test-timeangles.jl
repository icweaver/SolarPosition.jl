"""Tests related to the computation of solar time and angle quantities."""

using Dates
using DynamicQuantities
using CSV
using DataFrames
using JSON

using SolarPosition.PositionInterface

const deg_to_min = (24 * 60) / 360 * us"min/deg"

function format_data(df::DataFrame)
    names = Dict(
        "Observer hour angle" => "HRA",
        "Topocentric zenith angle" => "θ_z",
        "Time (H:MM:SS)" => "time",
        "Date (M/D/YYYY)" => "date",
        "Top. azimuth angle (westward from S)" => "θ_a",
        "Topocentric sun declination" => "δ",
        "Topocentric sun right ascension" => "RA",
        "Equation of time" => "EoT"
    )
    rename!(df, names)
    select!(df, collect(values(names)))
    df.timestamp = [DateTime("$(row.date) $(row.time)", DateFormat("m/d/y H:M:S"))
                    for row in eachrow(df)]
    select!(df, Not(:date, :time))
    return df
end

function load_test_data()
    meta = JSON.parsefile("../data/meta.json")

    for file in keys(meta)
        df = CSV.read("../data/$(file).csv", DataFrame)
        meta[file]["df"] = format_data(df)
    end

    return meta
end

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
