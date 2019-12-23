local music = {}

function music.load(file)
    local util = music.util
    
    local m = music.yaml.eval(music.util.getFileContents("smb/"..file..".yaml"))
    
    local h = {}
    h.squareDataOffset = #music.util.stripSpaces(m.data.square2)/2
    h.triangleDataOffset = h.squareDataOffset + #music.util.stripSpaces(m.data.square1)/2
    h.noiseDataOffset = h.triangleDataOffset + #music.util.stripSpaces(m.data.triangle)/2
    h.noteLength = tonumber(m.data.noteLength,16)
    m.data.header = h

    music[file] = m
end


music.init = function(t)
    for k,v in pairs(t) do
        music[k] = t[k]
    end
end


return music