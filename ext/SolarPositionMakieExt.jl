module SolarPositionMakieExt

using Dates, Tables, Makie
using SolarPosition
import SolarPosition: sunpathpolarplot, sunpathpolarplot!, sunpathplot, sunpathplot!

function _add_colorbar!(fig, plot_obj, position = fig[1, 2])
    month_names =
        ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    month_days = [15, 46, 74, 105, 135, 166, 196, 227, 258, 288, 319, 349]
    inverted_month_days = 365 .- reverse(month_days)
    inverted_month_names = reverse(month_names)
    return Colorbar(position, plot_obj, ticks = (inverted_month_days, inverted_month_names))
end

function _try_add_colorbar_to_recipe!(ax, plot_obj)
    try
        parent = ax.parent
        while !isa(parent, Figure) &&
                  !isnothing(parent) &&
                  hasfield(typeof(parent), :parent)
            parent = parent.parent
        end
        if isa(parent, Figure)
            _add_colorbar!(parent, plot_obj, parent[1, 2])
        end
    catch
        # silently fail if colorbar can't be added
    end
end

function _add_hour_labels!(ax, dts, ze, el, az, coords)
    hours = hour.(dts)
    visible_mask = el .> 0
    if !any(visible_mask)
        return
    end

    ze_visible = ze[visible_mask]
    el_visible = el[visible_mask]
    az_visible = az[visible_mask]
    hours_visible = hours[visible_mask]

    for hour_val in unique(hours_visible)
        hour_mask = hours_visible .== hour_val
        if !any(hour_mask)
            continue
        end

        if coords === :polar
            idx = argmin(ze_visible[hour_mask])
            label_az = az_visible[hour_mask][idx]
            label_ze = ze_visible[hour_mask][idx]
            x, y = deg2rad(label_az), label_ze
        else
            idx = argmax(el_visible[hour_mask])
            label_az = az_visible[hour_mask][idx]
            label_el = el_visible[hour_mask][idx]
            offset = label_az < 180 ? -10 : 10
            x, y = label_az + offset, label_el
        end

        text!(
            ax,
            x,
            y,
            text = lpad(string(hour_val), 2, '0'),
            align = (:center, :bottom),
            fontsize = 13,
        )
    end
end


@recipe(SunpathPlot) do scene
    Theme(colormap = :twilight, markersize = 3, hour_labels = true, colorbar = true)
end

@recipe(SunpathpolarPlot) do scene
    Theme(colormap = :twilight, markersize = 3, hour_labels = true, colorbar = true)
end

function Makie.plot!(sp::SunpathPlot{<:Tuple})
    data = sp[1][]
    dts = data.datetime
    ze = data.zenith
    az = data.azimuth
    el = 90 .- ze
    vals = 365 .- dayofyear.(dts)

    ax = current_axis()
    if ax isa Axis
        xlims!(ax, 0, 360)
        ylims!(ax, 0, 90)
        ax.xlabel = "Azimuth (°)"
        ax.ylabel = "Elevation (°)"
        ax.xticks = 0:30:360
        ax.yticks = 0:10:90
    end

    p = scatter!(
        sp,
        az,
        el;
        color = vals,
        colormap = sp.colormap[],
        markersize = sp.markersize[],
    )

    # add hourly labels if requested
    if sp.hour_labels[]
        _add_hour_labels!(ax, dts, ze, 90 .- ze, az, :polar)
    end

    # add colorbar if requested and possible
    if sp.colorbar[]
        _try_add_colorbar_to_recipe!(ax, p)
    end

    return p
end


function Makie.plot!(sp::SunpathpolarPlot{<:Tuple})
    data = sp[1][]
    dts = data.datetime
    ze = data.zenith
    az = data.azimuth
    vals = 365 .- dayofyear.(dts)

    ax = current_axis()
    if ax isa PolarAxis
        ax.direction = -1
        ax.theta_0 = -π / 2
        ax.rlimits = (0, 90)
    end

    p = scatter!(
        sp,
        deg2rad.(az),
        ze;
        color = vals,
        colormap = sp.colormap[],
        markersize = sp.markersize[],
    )

    # add hourly labels if requested
    if sp.hour_labels[]
        _add_hour_labels!(ax, dts, ze, 90 .- ze, az, :polar)
    end

    # add colorbar if requested and possible
    if sp.colorbar[]
        _try_add_colorbar_to_recipe!(ax, p)
    end

    return p
end



function Makie.convert_arguments(sp::Type{Union{<:SunpathPlot,<:SunpathpolarPlot}}, tbl)
    cols = Tables.columns(tbl)
    dts = Tables.getcolumn(cols, :datetime)
    zenith = Tables.getcolumn(cols, :zenith)
    azimuth = Tables.getcolumn(cols, :azimuth)
    return ((datetime = dts, zenith = zenith, azimuth = azimuth),)
end

function SolarPosition.sunpathpolarplot(
    data;
    hour_labels = true,
    colorbar = true,
    kwargs...,
)
    fig = Figure()
    ax = PolarAxis(fig[1, 1])
    p = sunpathpolarplot!(ax, data; hour_labels = hour_labels, kwargs...)

    if colorbar
        _add_colorbar!(fig, p)
    end

    return fig
end

function SolarPosition.sunpathplot(data; hour_labels = true, colorbar = true, kwargs...)
    fig = Figure()
    ax = Axis(fig[1, 1])
    p = sunpathplot!(ax, data; hour_labels = hour_labels, kwargs...)

    if colorbar
        _add_colorbar!(fig, p)
    end

    return fig
end

end # module
