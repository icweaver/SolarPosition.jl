"""Unit tests for atmospheric refraction algorithms"""

using SolarPosition.Refraction: HUGHES, refraction

# test elevation angles in degrees
test_elevation_angles() = [-1.0, -0.6, 0.0, 1.0, 4.0, 6.0, 10.0, 90.0]

# expected results for each algorithm (unit: degrees)
expected = Dict(
    "Hughes" => [
        0.32827494,
        0.54716046,
        0.47856238,
        0.360817,
        0.1875788,
        0.13769375,
        0.08750312,
        0.00000000,
    ],
)

# test configurations: (algorithm_name, constructor, expected_results)
test_algorithms = [("Hughes", () -> HUGHES(101325.0, 12.0), expected["Hughes"])]

elevations = test_elevation_angles()

@testset "Refraction: $name" for (name, constructor, expected) in test_algorithms
    algorithm = constructor()

    @testset "Scalar computation" begin
        for (i, elev) in enumerate(elevations)
            result = refraction(algorithm, elev)
            @test result ≈ expected[i] atol = 1e-7
        end
    end

    @testset "Vectorized computation" begin
        results = refraction.(Ref(algorithm), elevations)
        for (i, res) in enumerate(results)
            @test res ≈ expected[i] atol = 1e-7
        end
    end
end
