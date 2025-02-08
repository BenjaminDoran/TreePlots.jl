using TreePlots
using Documenter

DocMeta.setdocmeta!(TreePlots, :DocTestSetup, :(using TreePlots); recursive = true)

const page_rename = Dict("developer.md" => "Developer docs") # Without the numbers
const numbered_pages = [
    file for file in readdir(joinpath(@__DIR__, "src")) if
    file != "index.md" && splitext(file)[2] == ".md"
]

makedocs(;
    modules = [TreePlots],
    authors = "Benjamin Doran and collaborators",
    repo = "https://github.com/BenjaminDoran/TreePlots.jl/blob/{commit}{path}#{line}",
    sitename = "TreePlots.jl",
    format = Documenter.HTML(; canonical = "https://BenjaminDoran.github.io/TreePlots.jl"),
    pages = ["index.md"; numbered_pages],
)

deploydocs(; repo = "github.com/BenjaminDoran/TreePlots.jl")
