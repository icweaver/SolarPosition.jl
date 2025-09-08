"""
Collection of solar positioning algorithms.
"""
module Positioning

using Dates
using TimeZones

# Import types from parent module
using ..SolarPosition: Observer, SolarPos, CommonOptions

abstract type SolarAlgorithm end

include("utils.jl")

# solar positioning algorithms
include("noaa.jl")
include("psa.jl")

"""
    solar_position(obs, alg, t, opts, algopts) -> SolarPos

Internal dispatch function for solar position calculation.
"""
function solar_position(obs, alg::SolarAlgorithm, t, opts, algopts)
    if algopts === nothing
        algopts = default_options(alg)
    end
    _solar_position(obs, alg, t, opts, algopts)
end

export NOAA, PSA

end