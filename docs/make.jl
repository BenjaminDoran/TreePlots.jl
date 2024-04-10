using TreePlots
using Documenter

DocMeta.setdocmeta!(TreePlots, :DocTestSetup, :(using TreePlots); recursive=true)

makedocs(;
    modules=[TreePlots],
    authors="Benjamin Doran and collaborators",
    sitename="TreePlots.jl",
    format=Documenter.HTML(;
        canonical="https://BenjaminDoran.github.io/TreePlots.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/BenjaminDoran/TreePlots.jl",
    devbranch="main",
)
