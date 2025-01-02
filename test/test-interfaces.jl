using TimeZones
using Dates
using Interfaces

using PVSimBase.GeoLocation: Location
using SolarPosition.Basic
using SolarPosition.PositionInterface

# @testset "Basic algorithm" begin
#     test_location = Location(latitude = 0.0, longitude = 0.0)
#     alg = BasicAlgorithm(test_location)
#     @test alg isa BasicAlgorithm
#     @test alg.location == test_location
#     pos = sunpos(alg, now(TimeZone("UTC")))
# end

@testset "Algorithms" begin
    # latitude, longitude, timestamp, elevation, azimuth
    cases = [
        (39.743, -105.178,
        ZonedDateTime(2020, 2, 10, 0, 0, TimeZone("UTC-7")), -39.44us"deg", 75.84us"deg")
    ]

    for (lat, lon, ts, el, az) in cases
        loc = Location(latitude = lat, longitude = lon)
        alg = BasicAlgorithm(loc)
        pos = sunpos(alg, ts)
        @test pos[1]≈el atol=1.0us"deg"
        @test pos[2]≈az atol=1.0us"deg"
    end
end

@testset "PositionInterfaces" begin
    @test Interfaces.test()
end