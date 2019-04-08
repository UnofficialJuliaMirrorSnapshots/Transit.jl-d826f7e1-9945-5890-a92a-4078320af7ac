function startswith(str::AbstractString, pats...)
    for pat in pats
        if start(search(str, pat)) == 1
            return true
        end
    end
    false
end

function constantly(value)
    function(_...)
        value
    end
end

function tolist(a::AbstractArray)
  l = list()
  for item in a
    l = cons(item, l)
  end
  reverse(l)
end


date_formats = ["yyyy-mm-ddTHH:MM:SS.sss", "yyyy-mm-ddTHH:MM:SS"]

function parsedatetime(s::AbstractString)
    s = replace(s, r"Z$", "")
    s = replace(s, r"-\d\d:\d\d$", "")
    for fmt in date_formats
        try
            return DateTime(s, fmt)
	catch ex
            println(ex)
	end
    end
    throw(ArgumentError("Dont know how to parse date/time: $s"))
end
