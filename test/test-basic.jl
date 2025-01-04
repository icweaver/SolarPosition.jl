using TimeZones
using Dates
using Interfaces
using DynamicQuantities

using PVSimBase.GeoLocation: Location
using SolarPosition.Basic
using SolarPosition.PositionInterface

const algorithms = (
    "Basic" => BasicAlgorithm,
)

@testset "Function hour_angle" begin
    dfs = load_test_data()

    for (file, meta) in dfs
        df = meta["df"]
        # keep only 1 out of 10 rows 
        df = df[1:10:end, :]
        loc = Location(latitude = meta["latitude"], longitude = meta["longitude"])
        @testset "$(meta["name"])" begin
            for row in eachrow(df)
                HRA = Basic.hour_angle(
                    ZonedDateTime(row.timestamp, TimeZone(meta["timezone"])), loc)
                # @test pos[1]≈row.θ_z * us"deg" atol=1.0us"deg"
                println("Time: ", row.timestamp, " HRA: ", HRA)
                # @test HRA isa Quantity
                # @test HRA≈row.HRA * us"deg" atol=1.0us"deg"
            end
        end
    end
end
