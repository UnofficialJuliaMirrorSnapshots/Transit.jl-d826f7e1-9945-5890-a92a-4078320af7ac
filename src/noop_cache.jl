type NoopCache
end

function write!(rc::RollingCache, name::AbstractString)
  name
end
