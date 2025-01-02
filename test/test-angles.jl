"""Tests related to the computation of solar angles.

    |     Day       | Declination ± 0.3|
    |---------------|------------------|
    | March 22      | 0                |  
    | June 21       | +23.45           |
    | September 23  | 0                |
    | December 22   | -23.45           |
"""

using Dates: DateTime
using DynamicQuantities: Quantity
using SolarPosition.PositionInterface

@testset "Function declination" begin
    atol = 0.6

    cases = [ # (date, declination [degrees])
        (DateTime(2023, 3, 22, 0, 0, 0), 0),           # March 22
        (DateTime(2023, 6, 21, 0, 0, 0), +23.45),      # June 21
        (DateTime(2023, 9, 23, 0, 0, 0), 0),           # September 23
        (DateTime(2023, 12, 22, 0, 0, 0), -23.45)      # December 22
    ]

    for (date, ϵ) in cases
        δ = PositionInterface.declination(date)
        @test δ isa Quantity
        @test isapprox(δ.value, ϵ, atol = atol)
    end

    @test isapprox(PositionInterface.declination(80).value, 0, atol = atol)

    @test_throws ArgumentError PositionInterface.declination(-1)
    @test_throws ArgumentError PositionInterface.declination(366)
end