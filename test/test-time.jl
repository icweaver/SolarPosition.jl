"""Tests related to the equation of time.

    |     Day     | Equation of Time |
    |-------------|------------------|
    | February 11 | [-15, -14]       |
    | May 11      | [ +3,  +4]       |
    | July 26     | [ -7,  -6]       |
    | November 2  | [+16,  17]       |
"""

using Dates: DateTime
using DynamicQuantities
using SolarPosition.PositionInterface

@testset "Function equation_of_time" begin
    deg_to_min = (24 * 60) / 360

    cases = [ # (date, min [minutes], max [minutes])
        (DateTime(2000, 2, 11, 0, 0, 0), -15, -14),     # February 11
        (DateTime(2000, 5, 11, 0, 0, 0), +3, +4),       # May 11
        (DateTime(2000, 7, 26, 0, 0, 0), -7, -6),       # July 26
        (DateTime(2000, 11, 2, 0, 0, 0), +16, +17)      # November 2
    ]

    for (date, min, max) in cases
        eot = PositionInterface.equation_of_time(date) * deg_to_min
        @test eot isa Quantity
        @test min < eot < max
    end
end