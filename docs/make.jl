using SolarPosition
using Documenter
using DocStringExtensions
using DocumenterCitations

DocMeta.setdocmeta!(
    SolarPosition,
    :DocTestSetup,
    :(using SolarPosition;
    using Dates;
    obs = Observer(37.7749, -122.4194, 100.0);
    dt = DateTime(2023, 6, 21, 12, 0, 0));
    recursive = true,
)

# Setup bibliography
bib = CitationBibliography(joinpath(@__DIR__, "src", "refs.bib"), style = :alpha)

page_rename = Dict("developer.md" => "Developer docs") # Without the numbers
numbered_pages = [
    file for file in readdir(joinpath(@__DIR__, "src")) if
    file != "index.md" && splitext(file)[2] == ".md"
]

makedocs(;
    modules = [SolarPosition],
    authors = "Stefan de Lange",
    repo = Documenter.Remotes.GitHub("JuliaSolarPV", "SolarPosition.jl"),
    sitename = "SolarPosition.jl",
    format = Documenter.HTML(;
        canonical = "https://JuliaSolarPV.github.io/SolarPosition.jl",
        size_threshold = 2^20, # 1 MB
    ),
    plugins = [bib],
    pages = [
        "index.md",
        "Examples" => ["examples/basic.md", "examples/plotting.md"],
        "reference.md",
        "positioning.md",
        "refraction.md",
        "deltat.md",
        "literature.md",
        "contributing.md",
    ],
)

deploydocs(; repo = "github.com/JuliaSolarPV/SolarPosition.jl")
