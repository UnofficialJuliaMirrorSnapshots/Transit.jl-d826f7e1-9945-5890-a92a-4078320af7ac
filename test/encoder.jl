module TestEncoder

using Base.Test
using Transit
using JSON

import DataStructures.OrderedDict

# Convert the value given to transit and then read
# back in the resulting JSON. Not a round trip, since
# we are just reading back in the raw JSON.
function square_trip(x, verbose=false)
    buf = IOBuffer()
    e = Encoder(buf, verbose)
    encode(e, x, false)
    s = takebuf_string(buf)
    #println(s)
    JSON.parse(s)
end

@test square_trip(1) == 1
@test square_trip(1.0) == 1.0
@test square_trip("hello") == "hello"
@test square_trip("~hello") == "~~hello"
@test square_trip(true) == true
@test square_trip(false) == false
@test square_trip(2//3) == Any["~#ratio", Any[2, 3]]
@test square_trip([1,2,3]) == [1,2,3]
@test square_trip((1,2,"hello")) == Any["~#list", Any[1,2,"hello"]]

@test square_trip([:hello, :hello, :hello]) == ["~:hello", "^0", "^0"]
@test square_trip([:aaaa, :bbbb, :aaaa, :bbbb]) == ["~:aaaa", "~:bbbb", "^0", "^1"]

symbols = [Transit.TSymbol("hello"), Transit.TSymbol("hello"), Transit.TSymbol("hello")]

@test square_trip(symbols) == ["~\$hello", "^0", "^0"]
@test square_trip([:aaaa, :bbbb, :aaaa, :bbbb]) == ["~:aaaa", "~:bbbb", "^0", "^1"]

@test square_trip([:aaaa, :bbbb, :aaaa, :bbbb], true) == ["~:aaaa", "~:bbbb", "~:aaaa", "~:bbbb"]

@test square_trip(Dict([("aaa", 11), ("bbb", 22)]), true) == Dict([("aaa", 11), ("bbb", 22)])
end
