include("../src/Transit.jl")

function run_test(path)
    println("Running $path")
    include(path)
end

run_test("tset.jl")
run_test("decoder.jl")
run_test("encoder.jl")
run_test("roundtrip.jl")
run_test("exemplar.jl")
