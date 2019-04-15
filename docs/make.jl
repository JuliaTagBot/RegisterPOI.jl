using Documenter, RegisterPOI

makedocs(
    modules = [RegisterPOI],
    format = :html,
    sitename = "RegisterPOI.jl",
    pages = Any["index.md"]
)

deploydocs(
    repo = "github.com/yakir12/RegisterPOI.jl.git",
    target = "build",
    julia = "1.0",
    deps = nothing,
    make = nothing,
)
