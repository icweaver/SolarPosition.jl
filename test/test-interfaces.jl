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

@testset "Algorithms" begin
    dfs = load_test_data()
    for (file, meta) in dfs
        df = meta["df"]
        loc = Location(latitude = meta["latitude"], longitude = meta["longitude"])
        @testset "$(meta["name"])" begin
            for (name, alg) in algorithms
                @testset "$(name)" begin
                    algorithm = alg(loc)
                    for row in eachrow(df)
                        pos = sunpos(algorithm,
                            ZonedDateTime(row.timestamp, TimeZone(meta["timezone"])))
                        # @test pos[1]≈row.θ_z * us"deg" atol=1.0us"deg"
                        # @test pos[2]≈row.θ_a * us"deg" atol=1.5us"deg"
                    end
                end
            end
        end
    end
end

@testset "PositionInterfaces" begin
    @test Interfaces.test()
end