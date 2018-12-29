local sound = {}

sound.enabled = true
sound.aliases={}

function sound:init(util, path)
    if not winapi then require "winapi" end
    sound.util = util
    
    self.scriptPath = path
    self.toolsPath = sound.util.fixPathSlashes(self.scriptPath.."Spidey/tools/")
end

function sound:play(f)
    if not self.enabled then return end
    for k,v in pairs(self.aliases) do
        if k==f then
            f = v
        end
    end
    winapi.shell_exec(nil,  sound.util.fixPathSlashes(self.toolsPath.."NirCmd/nircmd.exe"), "mediaplay 1000 "..'"'..sound.util.fixPathSlashes(self.scriptPath..f)..'"')
end

function sound:makeAlias(a, f)
    self.aliases[a] = f
end


return sound