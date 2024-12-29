using SolarPosition
using Documenter

DocMeta.setdocmeta!(SolarPosition, :DocTestSetup, :(using SolarPosition); recursive = true)

const page_rename = Dict("developer.md" => "Developer docs") # Without the numbers
const numbered_pages = [file
                        for file in readdir(joinpath(@__DIR__, "src"))
                        if
                        file != "index.md" && splitext(file)[2] == ".md"]

makedocs(;
    modules = [SolarPosition],
    authors = "Stefan de Lange <langestefan@msn.com>",
    repo = "https://github.com/PVSMC/SolarPosition.jl/blob/{commit}{path}#{line}",
    sitename = "SolarPosition.jl",
    format = Documenter.HTML(; canonical = "https://PVSMC.github.io/SolarPosition.jl"),
    pages = ["index.md"; numbered_pages]
)

deploydocs(; repo = "github.com/PVSMC/SolarPosition.jl")
