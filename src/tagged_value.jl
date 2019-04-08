immutable Tag
    rep::AbstractString
end

type TaggedValue
    tag::AbstractString
    value::Any
end

import Base.==, Base.hash, Base.string

function ==(tv::TaggedValue, other::TaggedValue)
    tv.value == other.value && tv.tag == other.tag
end

const hashttaggedvalue_seed = UInt === UInt64 ? 0x8ee14727cfcae1ce : 0x1f487ece

function hash(tv::TaggedValue, h::UInt)
    h = hash(hashttaggedvalue_seed, h)
    h $= hash(tv.tag)
    h $= hash(tv.value)
    return h
end

function string(tv::TaggedValue)
    "$(tv.tag): $(tv.value)"
end
