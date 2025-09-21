using SolarPosition
using Documenter

DocMeta.setdocmeta!(SolarPosition, :DocTestSetup, :(using SolarPosition); recursive = true)

const page_rename = Dict("developer.md" => "Developer docs") # Without the numbers
const numbered_pages = [
    file for file in readdir(joinpath(@__DIR__, "src")) if
    file != "index.md" && splitext(file)[2] == ".md"
]

makedocs(;
    modules = [SolarPosition],
    authors = "Stefan de Lange",
    repo = "https://github.com/JuliaSolarPV/SolarPosition.jl/blob/{commit}{path}#{line}",
    sitename = "SolarPosition.jl",
    format = Documenter.HTML(;
        canonical = "https://JuliaSolarPV.github.io/SolarPosition.jl",
    ),
    pages = [
        "index.md",
        "Examples" => ["examples/basic.md", "examples/plotting.md"],
        "reference.md",
        "contributing.md",
    ],
)

deploydocs(; repo = "github.com/JuliaSolarPV/SolarPosition.jl")
