using TimeZones: now, TimeZone
using Interfaces

using PVSimBase.GeoLocation: Location
using SolarPosition.Basic
using SolarPosition.PositionInterface

@testset "Basic algorithm" begin
    test_location = Location(latitude = 0.0, longitude = 0.0)
    alg = BasicAlgorithm(test_location)
    @test alg isa BasicAlgorithm
    @test alg.location == test_location
    pos = sunpos(alg, now(TimeZone("UTC")))
end

@testset "PositionInterfaces" begin
    @test Interfaces.test()
end