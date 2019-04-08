  import JSON

  type Emitter
    io::IO
    cache::Cache
  end

  function make_emitter(io, verbose::Bool)
    let cache = verbose ? NoopCache() : RollingCache()
      Emitter(io, cache)
    end
  end

  function emit_raw(e::Emitter, s::AbstractString)
    print(e.io, s)
  end

  function emit_tag(e::Emitter, x::AbstractString)
    emit(e, "~$x", true)
  end

  function emit(e::Emitter, x::AbstractString, cacheable::Bool)
    let value = iscacheable(x, cacheable) ? write!(e.cache, x) : x
        print(e.io, JSON.json(value))
    end
  end

  function emit(e::Emitter, x::Integer)
    print(e.io, JSON.json(x))
  end

  function emit(e::Emitter, x::Bool)
    print(e.io, JSON.json(x))
  end

  function emit_null(e::Emitter, askey::Bool)
    askey ? emit_tag(e, "_") : emit_raw(e, "null")
  end

  function emit_array_start(e::Emitter)
    print(e.io, "[")
  end

  function emit_array_end(e::Emitter)
    print(e.io, "]")
  end

  function emit_map_start(e::Emitter)
    print(e.io, "{")
  end

  function emit_map_sep(e::Emitter, i=2)
    emit_array_sep(e, i)
  end

  function emit_key_sep(e::Emitter)
    print(e.io, ":")
  end

  function emit_map_end(e::Emitter)
    print(e.io, "} ")
  end

  function emit_array_sep(e::Emitter, i=2)
    if i != 1
      print(e.io, ",")
    end
  end
