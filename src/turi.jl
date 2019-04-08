type TURI
    value::AbstractString
end

function ==(u1::TURI, u2::TURI)
    (u1.value == u2.value)
end

function Base.convert(::Type{URIParser.URI}, turi::TURI)
    URIParser.URI(turi.value)
end

function Base.string(turi::TURI)
    turi.value
end
