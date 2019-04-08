module Transit
  import JSON
  import Base.getindex
  import Base

  using DataStructures
  using URIParser
  using Decimals

  export Encoder, encode, parse, decode

  include("tagged_value.jl")
  include("tsymbol.jl")
  include("tset.jl")
  include("turi.jl")
  include("link.jl")
  include("constants.jl")
  include("cache.jl")
  include("decoder.jl")
  include("utilities.jl")
  include("emitter.jl")
  include("encoder.jl")
  include("writer.jl")
  include("reader.jl")
end
