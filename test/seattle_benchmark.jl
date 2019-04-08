include("../src/Transit.jl")
# To run this, Pkg.clone the Benchmarks.jl package at:
#
# https://github.com/johnmyleswhite/Benchmarks.jl/
#
# with:
#
# > Pkg.clone("https://github.com/johnmyleswhite/Benchmarks.jl")

import Benchmarks
import Transit

const SEATTLEDIR = "../transit-format/examples/0.8/"
const JSONFILE = string(SEATTLEDIR, "example.json")
const JSONVERBOSEFILE = string(SEATTLEDIR, "example.verbose.json")

function run_tests(data::AbstractString)
    io = IOBuffer(data)
    Transit.parse(io)
end

function read_json()
    readall(open(JSONFILE))
end

function read_json_verbose()
    readall(open(JSONVERBOSEFILE))
end

println("Transit JSON parse")
println(@Benchmarks.benchmark run_tests(read_json()))
println("\n")
println("Transit JSON verbose parse")
println(@Benchmarks.benchmark run_tests(read_json_verbose()))
