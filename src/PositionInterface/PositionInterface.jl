module PositionInterface

using Interfaces
using DynamicQuantities: Quantity
using Dates
using PVSimBase
using TimeZones

export SolarPositionInterface, SolarPositionAlgorithm, sunpos

include("time.jl")
include("angles.jl")

abstract type SolarPositionAlgorithm end

function sunpos end

components = (
    mandatory = (
        sunpos_check = (
        "interface implements the sunpos function" => a::Arguments -> sunpos(
        a.algorithm, a.timestamp) isa Tuple{Quantity, Quantity}
    ),
    ),
    optional = ()
)

description = """
Defines an interface to calculate the position of the sun in the sky from a given 
observer position and time defined by a location and timestamp. 

A solar position is uniquely defined by the elevation and azimuth angles. 
"""

@interface SolarPositionInterface SolarPositionAlgorithm components description

end # module PositionInterface