"""
Utility to calculate deltat.
"""
start_year = 2020
end_year = 2025
num_years = end_year - start_year + 1

# Create a matrix where rows are years, columns are months
function_lookup = Matrix{Union{Function,Nothing}}(nothing, num_years, 12)

# Helper function to convert year/month to indices
function to_indices(year, month)
    year_idx = year - start_year + 1
    month_idx = month
    return year_idx, month_idx
end

# Add functions
year_idx, month_idx = to_indices(2023, 1)
function_lookup[year_idx, month_idx] = x -> x^2

# Usage
function get_function(year, month)
    if year < start_year || year > end_year || month < 1 || month > 12
        return nothing
    end
    year_idx, month_idx = to_indices(year, month)
    return function_lookup[year_idx, month_idx]
end