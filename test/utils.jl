
function format_data(df::DataFrame)
    names = Dict(
        "Observer hour angle" => "HRA",
        "Topocentric zenith angle" => "θ_z",
        "Time (H:MM:SS)" => "time",
        "Date (M/D/YYYY)" => "date",
        "Top. azimuth angle (eastward from N)" => "θ_a",
        "Topocentric sun declination" => "δ",
        "Topocentric sun right ascension" => "RA",
        "Equation of time" => "EoT"
    )
    rename!(df, names)
    select!(df, collect(values(names)))
    df.timestamp = [DateTime("$(row.date) $(row.time)", DateFormat("m/d/y H:M:S"))
                    for row in eachrow(df)]
    select!(df, Not(:date, :time))
    return df
end

function load_test_data()
    meta = JSON.parsefile("../data/meta.json")

    for file in keys(meta)
        df = CSV.read("../data/$(file).csv", DataFrame)
        meta[file]["df"] = format_data(df)
    end

    return meta
end