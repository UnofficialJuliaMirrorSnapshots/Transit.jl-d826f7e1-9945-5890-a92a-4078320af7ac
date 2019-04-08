type Encoder
    verbose::Bool
    encoder_functions
    encodes_to_string
    emitter::Emitter

    Encoder(io, verbose=false) =
		new(verbose,
		    Dict{DataType,Function}(),
		    Dict{DataType,Bool}(),
		    make_emitter(io, verbose))
end

function add_encoder(e::Encoder, t::DataType, f::Function, encodes_to_string::Bool)
    e.encoder_functions[t] = f
    e.encodes_to_string[t] = encodes_to_string
end

function encode(e::Encoder, x::Any, askey=false)
    if haskey(e.encoder_functions, typeof(x))
        e.encoder_functions[typeof(x)](e, x, askey)
    else
        encode_value(e, x, askey)
    end
end

function encodes_to_string(e::Encoder, x::Any)
    let t = typeof(x)
        if haskey(e.encoder_functions, t)
            e.encodes_to_string[t](e, x)
        else
            encodes_to_string(e, x)
        end
    end
end

Composite = Union{AbstractArray, Dict}

Simple = Union{AbstractString, Integer, BigInt, AbstractFloat, TSymbol, Symbol, Bool}

function encode_top_level(e::Encoder, x::Simple)
    encode_quoted(e, x)
end

function encode_top_level(e::Encoder, x::Composite)
    encode(e, x)
end

function encode_top_level(e::Encoder, x::Any)
    if encodes_to_string(e, x)
        encode_quoted(e, x)
    else
        encode(e, x, false) 
    end
end


function encode_quoted(e::Encoder, x::Any)
    emit_array_start(e.emitter)
    emit(e.emitter, "~#'", true)
    emit_array_sep(e.emitter)
    encode(e, x, false)
    emit_array_end(e.emitter)
end

function encode_value(e::Encoder, s::AbstractString, askey::Bool)
    if startswith(s, "~") || startswith(s, "^")
        emit(e.emitter, "~$s", askey)
    else
        emit(e.emitter, s, askey)
    end
end

function encode_value(e::Encoder, s::Symbol, askey::Bool)
    emit(e.emitter, "~:$s", true)
end

function encode_value(e::Encoder, ts::TSymbol, askey::Bool)
    emit(e.emitter, "~\$$(ts.s)", true)
end

function encode_value(e::Encoder, b::Bool, askey::Bool)
    if askey
        emit(e.emitter, b ? "~?t" : "~?f", askey)
    else
        emit(e.emitter, b)
    end
end

function encode_value(e::Encoder, x::Char, askey::Bool)
    emit(e.emitter, "~c$x", askey)
end

function encode_value(e::Encoder, u::URI, askey::Bool)
    s = string(u)
    emit(e.emitter, "~r$s", askey)
end

function encode_value(e::Encoder, u::TURI, askey::Bool)
    s = u.value
    emit(e.emitter, "~r$s", askey)
end

function encode_value(e::Encoder, u::Base.Random.UUID, askey::Bool)
    s = string(u)
    emit(e.emitter, "~u$s", askey)
end

function encode_value(e::Encoder, x::Void, askey::Bool)
    emit_null(e.emitter, askey)
end

function encode_value(e::Encoder, i::Integer, askey::Bool)
    if askey
        emit(e.emitter, "~i$i", askey)
    elseif (i <= JSON_MAX_INT && i >= JSON_MIN_INT)
        emit(e.emitter, i)
    elseif i > MAX_INT64 || i < MIN_INT64
        emit(e.emitter, "~n$i", askey)
    else
        emit(e.emitter, "~i$i", askey)
    end
end

function encode_value(e::Encoder, x::BigInt, askey::Bool)
    let s = string(x)
      emit(e.emitter, "~n$s", askey)
    end
end

function encode_special_float(emitter::Emitter, x::AbstractFloat, askey::Bool)
    if isnan(x)
        emit(emitter, "~zNaN", askey)
    elseif x == Inf
        emit(emitter, "~zINF", askey)
    elseif x == -Inf
        emit(emitter, "~z-INF", askey)
    else
        return false
    end
    return true
end

function encode_value(e::Encoder, x::Decimal, askey::Bool)
    let s = string(x)
        emit(e.emitter, "~f$s", askey)
    end
end

function encode_value(e::Encoder, x::BigFloat, askey::Bool)
    if !encode_special_float(e.emitter, x, askey)
        let s = string(x)
            emit(e.emitter, "~f$s", askey)
        end
    end
end

function encode_value(e::Encoder, x::AbstractFloat, askey::Bool)
    if !encode_special_float(e.emitter, x, askey)
        if askey
             emit(e.emitter, "~d$x", askey)
         else
             emit_raw(e.emitter, string(x))
         end
    end
end

function encode_iterator(e::Encoder, iter)
    for (i, x) in iter
        emit_array_sep(e.emitter, i)
        encode(e, x, false)
    end
end

function encode_tagged_enumerable(e::Encoder, tag::AbstractString, iter)
    emit_array_start(e.emitter)
    emit_tag(e.emitter, tag)
    emit_array_sep(e.emitter)

    emit_array_start(e.emitter)
    encode_iterator(e, iter) 
    emit_array_end(e.emitter)
    emit_array_end(e.emitter)
end

function encode_value(e::Encoder, a::AbstractArray, askey::Bool)
    emit_array_start(e.emitter)
    encode_iterator(e, enumerate(a))
    emit_array_end(e.emitter)
end

function encodes_to_string(e::Encoder, x::AbstractArray)
    false
end

function encode_value(e::Encoder, r::Rational, askey::Bool)
    encode_tagged_enumerable(e, "#ratio", enumerate([num(r), den(r)]))
end

function encodes_to_string(e::Encoder, x::Rational)
    false
end

function encode_value(e::Encoder, x::DateTime, askey::Bool)
    let millis = trunc(Int64, Dates.datetime2unix(x) * 1000)
        emit(e.emitter, "~m$millis", askey)
    end
end

function encode_value(e::Encoder, x::Array{Int8}, askey::Bool)
    encoded = base64encode(x)
    emit(e.emitter, "~b$encoded", askey)
end

function encode_value(e::Encoder, x::Date, askey::Bool)
    encode_value(e, DateTime(x), askey)
end

function encode_value(e::Encoder, x::Tuple, askey::Bool)
    encode_tagged_enumerable(e, "#list", enumerate(x))
end

function encode_value(e::Encoder, x::Cons, askey::Bool)
    encode_tagged_enumerable(e, "#list", enumerate(x))
end

function encodes_to_string(e::Encoder, x::Cons)
    false
end

function encode_value(e::Encoder, x::Nil, askey::Bool)
    encode_tagged_enumerable(e, "#list", [])
end

function encodes_to_string(e::Encoder, x::Nil)
    false
end


function encodes_to_string(e::Encoder, x::Tuple)
    false
end

# Maybe can use AbstractSet but instead but need to figure out version boundary
# for when it's available
function encode_value(e::Encoder, x::Set, askey::Bool)
    encode_tagged_enumerable(e, "#set", enumerate(x))
end

function encode_value(e::Encoder, x::TSet, askey::Bool)
    encode_tagged_enumerable(e, "#set", enumerate(x))
end

function encodes_to_string(e::Encoder, x::Set)
    false
end

function encodes_to_string(e::Encoder, x::TSet)
    false
end

function encode_value(e::Encoder, x::Link, askey::Bool)
    let a = [x.href, x.rel, x.name, x.prompt, x.render]
        encode_tagged_enumerable(e, "#link", enumerate(a))
    end
end

function encodes_to_string(e::Encoder, x::Link)
    false
end

function encode_value(e::Encoder, x::TaggedValue, askey::Bool)
    emit_array_start(e.emitter)
    emit_tag(e.emitter, "#$(x.tag)")
    emit_array_sep(e.emitter)
    encode(e, x.value, false)
    emit_array_end(e.emitter)
end

function encodes_to_string(e::Encoder, x::TaggedValue)
    false
end

function has_stringable_keys(e::Encoder, x::Dict)
    for k in keys(x)
	if ! encodes_to_string(e, k)
            return false
        end
    end
    true
end

function encode_map(e::Encoder, x::Dict)
    emit_array_start(e.emitter)
    emit(e.emitter, "^ ", true)

    for (k, v) in x
        emit_array_sep(e.emitter)
        encode_value(e, k, true)
        emit_array_sep(e.emitter)
        encode_value(e, v, false)
    end

    emit_array_end(e.emitter)
end

function encode_cmap(e::Encoder, x::Dict)
    emit_array_start(e.emitter)
    emit(e.emitter, "~#cmap", true)
    emit_array_sep(e.emitter)

    emit_array_start(e.emitter)
    i = 1
    for (k, v) in x
        emit_array_sep(e.emitter, i)
	i = i + 1
        encode_value(e, k, false)
        emit_array_sep(e.emitter)
        encode_value(e, v, false)
    end
    emit_array_end(e.emitter)
    emit_array_end(e.emitter)
end

function encode_verbose_map(e::Encoder, x::Dict)
    emit_map_start(e.emitter)
    i = 1
    for (k, v) in x
        emit_map_sep(e.emitter, i)
        encode_value(e, k, true)
        emit_key_sep(e.emitter)
        encode_value(e, v, false)
	i = i + i
    end
    emit_map_end(e.emitter)
end

function encode_value(e::Encoder, x::Dict, askey::Bool)
    if !has_stringable_keys(e, x)
        encode_cmap(e, x)
    elseif e.verbose
        encode_verbose_map(e, x)
    else
        encode_map(e, x)
    end
end

function encode_value(e::Encoder, x::Dict{AbstractString}, askey::Bool)
    if e.verbose
        encode_verbose_map(e, x)
    else
        encode_map(e, x)
    end
end

function encode_value(e::Encoder, x::Dict{Symbol}, askey::Bool)
    if e.verbose
        encode_verbose_map(e, x)
    else
        encode_map(e, x)
    end
end

function encodes_to_string(e::Encoder, x::Dict)
    false
end

# Default encoder raises exception.
function encode_value(e::Encoder, x::Any, askey::Bool)
    throw(ArgumentError("Don't know how to encode: $x of type $(typeof(x))."))
end

# Default is to claim we do encode to string.
function encodes_to_string(e::Encoder, x::Any)
    true
end
