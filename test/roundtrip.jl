module TestEncoder

using Base.Test
using Transit
using JSON

import DataStructures.list

# Convert the value given to transit and then read
# back in the resulting JSON. Not a round trip, since
# we are just reading back in the raw JSON.
function round_trip(x, verbose=false)
    buf = IOBuffer()
    e = Transit.write(buf, x)
    s = takebuf_string(buf)
    Transit.parse(IOBuffer(s))
end

function test_round_trip(value, verbose=false)
    x = round_trip(value, verbose)
    x == value
end

@test test_round_trip(1)
@test test_round_trip(1.0)
@test test_round_trip("hello")
@test test_round_trip("~hello")
@test test_round_trip(true)
@test test_round_trip(false)
@test test_round_trip(2//3)
@test test_round_trip([1,2,3])
@test test_round_trip(list(1,2,"hello"))

@test test_round_trip([:hello, :hello, :hello])
@test test_round_trip([:aaaa, :bbbb, :aaaa, :bbbb])

symbols = [Transit.TSymbol("hello"), Transit.TSymbol("hello"), Transit.TSymbol("hello")]

@test test_round_trip(symbols)
@test test_round_trip([:aaaa, :bbbb, :aaaa, :bbbb])

@test test_round_trip([:aaaa, :bbbb, :aaaa, :bbbb], true)

@test test_round_trip(Dict([("aaa", 11), ("bbb", 22)]), true)

@test test_round_trip(Transit.TSet([1,2,3]))

@test test_round_trip(Transit.TSet(Any[Transit.TSet([1,2]), Transit.TSet([2,3])]))
end
