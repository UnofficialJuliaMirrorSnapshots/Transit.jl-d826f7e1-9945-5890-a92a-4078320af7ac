import Base.in
import Base.==
import Base.length
import Base.start
import Base.done
import Base.next
import Base.string
import Base.show
import Base.enumerate
import Base.isequal
import Base.print
import Base.println


immutable TSet
    dict::Dict{Tuple{Any,DataType},Any}

    TSet() = new(Dict{Tuple{Any,DataType},Any}())
    TSet(itr) = new([(x, typeof(x)) => x for x in itr])
end

in(x, s::TSet) = haskey(s.dict, (x, typeof(x)))
==(s::TSet, t::TSet) = ==(s.dict, t.dict)
length(s::TSet) = length(s.dict)
start(s::TSet) = start(s.dict)
function next(s::TSet, x::Any)
    nextdict = next(s.dict, x)
    return (nextdict[1][2], nextdict[2])
end

done(s::TSet, state::Any) = done(s.dict, state)
enumerate(s::TSet) = enumerate(values(s.dict))
string(s::TSet) = "TSet($(join(map(string, [a for a in s]), ",")))"
show(s::TSet) = println(string(s))
print(io::IO, s::TSet) = print(io, string(s))


const hashtset_seed = UInt === UInt64 ? 0x852ada37cfe8e0ce : 0xcfe8e0ce
function hash(s::TSet, h::UInt)
    h = hash(hashtset_seed, h)
    for x in s
        h $= hash(x)
    end
    return h
end
