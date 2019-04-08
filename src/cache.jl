abstract Cache

# Do nothing cache used in verbose mode.
type NoopCache <: Cache
end

function write!(rc::NoopCache, name::AbstractString)
    name
end

# Real caching.
type RollingCache <: Cache
    key_to_value::Dict{ASCIIString,Any}
    value_to_key::Dict{Any,ASCIIString}

    RollingCache() = new(Dict{ASCIIString,Any}(), Dict{Any,ASCIIString}())
end

const FIRST_ORD = 48
const LAST_ORD  = 91
const CACHE_CODE_DIGITS = 44;
const CACHE_SIZE = CACHE_CODE_DIGITS * CACHE_CODE_DIGITS;
const MIN_SIZE_CACHEABLE = 4

function read(rc::RollingCache, key::AbstractString)
    rc.key_to_value[key]
end

function write!(rc::RollingCache, name::AbstractString)
    if haskey(rc.value_to_key, name)
	return rc.value_to_key[name]
    end

    if iscachefull(rc)
        clear!(rc)
    end

    key = encode_key(length(rc.key_to_value))
    rc.key_to_value[key] = name
    rc.value_to_key[name] = key

    name
end

function iscachefull(rc::RollingCache)
    length(rc.key_to_value) >= CACHE_SIZE
end

function clear!(rc::RollingCache)
    empty!(rc.key_to_value)
    empty!(rc.value_to_key)
end

function iscachekey(str::AbstractString)
    startswith(str, SUB) && str != MAP_AS_ARRAY
end

function iscacheable(str::AbstractString, key=false)
    length(str) >= MIN_SIZE_CACHEABLE && (key || startswith(str, "~#","~\$","~\:"))
end

function clear!(rc::RollingCache)
    rc.key_to_value = Dict{AbstractString, Any}()
    rc.value_to_key = Dict{Any, AbstractString}()
end

function encode_key(i::Integer)
    let hi = div(i, CACHE_CODE_DIGITS),
        lo = i % CACHE_CODE_DIGITS,
        ch = Char(lo+FIRST_ORD)
        if hi == 0
            "^$ch"
        else
            ch1 = Char(hi+FIRST_ORD)
            "^$ch1$ch"
        end
    end
end
