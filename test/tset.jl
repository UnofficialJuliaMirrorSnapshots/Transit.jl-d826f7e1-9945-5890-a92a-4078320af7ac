module TestTSet

using Base.Test
using Transit


a = Transit.TSet([1,2])
a1 = Transit.TSet([1,2])

b = Transit.TSet([3,4])
b1 = Transit.TSet([4,3])

c = Transit.TSet(Any[a, b])
c1 = Transit.TSet(Any[a,b])

s0 = Transit.TSet([Transit.TSymbol("aaa"), Transit.TSymbol("bbb"),  Transit.TSymbol("ccc")])
s1 = Transit.TSet([Transit.TSymbol("aaa"), Transit.TSymbol("bbb"),  Transit.TSymbol("ccc")])

s2 = Transit.TSet([Transit.TSymbol("aaa"), Transit.TSymbol("ccc"),  Transit.TSymbol("bbb")])
s3 = Transit.TSet([Transit.TSymbol("ccc"), Transit.TSymbol("aaa"),  Transit.TSymbol("bbb")])

@test s0 == s0
@test s0 == s1
@test s1 == s2
@test s2 == s1
@test s3 == s2
@test s3 == s3

@test a == a
@test a == a1
@test b == b
@test b == b1
@test a != b
@test b != a

@test c == c
@test c == c1

end
