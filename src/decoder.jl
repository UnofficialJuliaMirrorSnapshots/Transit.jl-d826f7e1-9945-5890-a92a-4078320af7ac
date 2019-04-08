type Decoder
    decoderFunctions

    Decoder() = new(Dict{ASCIIString,Function}(
                        "_"  => (x -> nothing),
                        ":"  => symbol,
                        "\$" => (x -> TSymbol(x)),
                        "?"  => (x -> x == "t"),
                        "b"  => base64decode,
                        "c"  => (x -> x[1]),
                        "i"  => (x -> Base.parse(Int64, x)),
                        "d"  => (x -> Base.parse(Float64, x)),
                        "f"  => (x -> decimal(lowercase(x))),
                        "r"  => (x -> TURI(x)),
                        "n"  => (x -> Base.parse(BigInt, x)),
                        "u"  => (x -> Base.Random.UUID(x)), # only string case so far
                        "t"  => parsedatetime,
                        "m"  => (x -> Dates.unix2datetime(Base.parse(Float64, x) / 1000.)), # maybe not sufficient
                        "z"  => (x -> if (x == "NaN")
                                          NaN
                                      elseif (x == "INF")
                                          Inf
                                      elseif (x == "-INF")
                                          -Inf
                                      else
                                          throw(string("Don't know how to encode: ", x))
                                      end),

                        # tag decoders
                        "'"  => (x -> x),
                        "set" => (x -> TSet(x)),
                        "link" => (x -> Link(x...)),
                        "list" => tolist,
                        "ratio" => (x -> x[1]//x[2]),
                        "cmap" => (x -> [a[1] => a[2]
                                         for a in zip(x[1:2:end], x[2:2:end])])
                    ))
end

function getindex(d::Decoder, k::AbstractString)
    d.decoderFunctions[k]
end

function add_decoder(e::Decoder, tag::AbstractString, f::Function)
    e.decoderFunctions[tag] = f
end

function decode(e::Decoder, node::Any, cache::Cache=RollingCache(), as_map_key::Bool=false)
    decode_value(e, node, cache, as_map_key)
end

function decode_value(e::Decoder, node::Any, cache::Cache, as_map_key::Bool=false)
    node
end

function decode_value(e::Decoder, node::Bool)
    node ? true : false # where we may have to add TTrue, TFalse for set issue
end

function decode_value(e::Decoder, node::Array{Any,1}, cache::Cache, as_map_key::Bool=false)
    if !isempty(node)
        if node[1] == MAP_AS_ARRAY
            returned_dict = Dict()
            for i in 2:2:length(node)
                key = decode_value(e, node[i], cache, true)
                value = decode_value(e, node[i+1], cache, as_map_key)
                returned_dict[key] = value
            end
            return returned_dict
        else
            decoded = decode_value(e, node[1], cache, as_map_key)
            if isa(decoded, Tag)
                return decode_value(e, decoded, node[2], cache, as_map_key)
            end
        end
    end

    [decode_value(e, x, cache, as_map_key) for x in node]
end


function decode_value(e::Decoder, hash::Dict, cache::Cache, as_map_key::Bool=false)

    if length(hash) != 1
        h = Dict{Any,Any}()
        for kv in hash
            key = decode_value(e, kv[1], cache, true)
            val = decode_value(e, kv[2], cache, false)
            h[key] = val
        end
        return h
    else
        for (k,v) in hash
            key = decode_value(e, k, cache, true)
            if isa(key, Tag)
                return decode_value(e, key, v, cache, as_map_key)
            end
            return Dict{Any,Any}(key => decode_value(e, v, cache, false))
        end
    end
end

function decode_value(e::Decoder, s::AbstractString, cache::Cache, as_map_key::Bool=false)
    if iscachekey(s)
        return decode_value(e, read(cache, s), cache, as_map_key)
    end

    if iscacheable(s, as_map_key)
        write!(cache, s)
    end

    if !startswith(s, ESC)
        s
    elseif startswith(s, TAG)
        Tag(s[3:end])
    elseif startswith(s, ESC_ESC) ||  startswith(s, ESC_SUB) || startswith(s, ESC_RES)
        s[2:end]
    elseif startswith(s, ESC)
        #2:2 is necessary to get str instead of char
        tag = s[2:2]
        if haskey(e.decoderFunctions, tag)
            e[tag](s[3:end])
        else
	    TaggedValue(tag, s[3:end])
        end
    end
end

function decode_value(e::Decoder, tag::Tag, value, cache::Cache, as_map_key::Bool=false)
    if haskey(e.decoderFunctions, tag.rep)
        e[tag.rep](decode_value(e, value, cache, false))
    else
        TaggedValue(tag.rep, decode_value(e, value, cache, false))
    end
end
