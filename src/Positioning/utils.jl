"""Utility functions to be used across solar positioning algorithms."""

# wrap angle to [-π, π]
@inline wrapπ(x::T) where {T} = ifelse(x > π, x - 2π, ifelse(x < -π, x + 2π, x))

# degree helpers
deg2rad(x::Real) = float(x) * (π / 180)
rad2deg(x::Real) = float(x) * (180 / π)

# fractional hour helper
fractional_hour(dt::DateTime) = hour(dt) + minute(dt) / 60 + second(dt) / 3600

# constants 
EMR = 6371.01  # Earth Mean Radius in km
AU = 149597890  # Astronomical Unit in km