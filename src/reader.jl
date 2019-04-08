function parse(io::IO)
    d = Decoder()
    decode(d, JSON.parse(io))
end

function parse(s::AbstractString)
    d = Decoder()
    decode(d, JSON.parse(s))
end
