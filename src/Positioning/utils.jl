"""Utility functions to be used across solar positioning algorithms."""

# wrap angle to [-π, π]
@inline wrapπ(x::T) where {T} = ifelse(x > π, x - 2π, ifelse(x < -π, x + 2π, x))

# degree helpers
deg2rad(x::Real) = float(x) * (π / 180)
rad2deg(x::Real) = float(x) * (180 / π)