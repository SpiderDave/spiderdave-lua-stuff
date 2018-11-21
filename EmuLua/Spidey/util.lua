local util={}

-- Remove all spaces from a string
util.stripSpaces = function(s)
    return string.gsub(s, "%s", "")
end

util.printf = function(s,...)
    --return io.write(s:format(...))
    --return print(s:format(...))
    return print(s:format(...))
end

function util.fileExists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function util.startsWith(haystack, needle)
    return string.sub(haystack, 1, string.len(needle)) == needle
end

function util.endsWith(haystack, needle)
   return needle=='' or string.sub(haystack,-string.len(needle))==needle
end

function util.trim(s)
    --if type(s)~="string" then return tostring(s) end
    if not s then return end
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function util.ltrim(s)
  return (s:gsub("^%s*", ""))
end

function util.rtrim(s)
  local n = #s
  while n > 0 and s:find("^%s", n) do n = n - 1 end
  return s:sub(1, n)
end


function util.limitString(s, limit)
    if type(s)~="string" then return s end
    limit = limit or 0x80
    if #s>limit then
        s=s:sub(1,limit).."..."
    end
    return s
end

function util.split(s, delim, max)
  assert (type (delim) == "string" and string.len (delim) > 0,
          "bad delimiter")
  assert(max == nil or max >= 1)
  local start = 1
  local t = {}
  local nSplits = 0
  while true do
    if max then
        if nSplits>= max then break end
    end
    local pos = string.find (s, delim, start, true) -- plain find
    if not pos then
      break
    end
    nSplits=nSplits+1
    table.insert (t, string.sub (s, start, pos - 1))
    start = pos + string.len (delim)
  end
  table.insert (t, string.sub (s, start))
  return t
end

function util.join(a,str)
    local out=""
    for i=1,#a do
        out=out..a[i]
        if i<#a then
            out=out..str
        end
    end
    return out
end

function util.copyTable(t)
  if type(t) ~= 'table' then return t end
  local res = {}
  for k, v in pairs(t) do res[util.copyTable(k)] = util.copyTable(v) end
  return res
end

return util