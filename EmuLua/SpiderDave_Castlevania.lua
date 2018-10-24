-- script by SpiderDave

spidey=require "Spidey.SpideyStuff"
font = spidey.font
--require "Spidey.default_font"

spidey.imgEdit.transparent = true
--spidey.imgEdit.transparentColor="#000000"
spidey.imgEdit.nobk=true

spidey.selection.snap = 8

--require ".\\SpiderDave\\SpiderDave_functions"
--require ".\\SpiderDave\\default_font"

cv1_heart=getfilecontents(".\\SpiderDave\\cv1_heart.gd")

enableddisabled={[true]="enabled",[false]="disabled"}

current_font=1

--used for sp weapon switching cheat.  the key is the current weapon and the value is the next to switch to
next_sp_weapon={[0x00]=0x08,[0x08]=0x0d,[0x0d]=0x09,[0x09]=0x0b,[0x0b]=0x0f,[0x0f]=0x0a,[0x0a]=0x00}

game = {}
game.paused = false

cheats={
    enabled=true,
    active=false,
    invincible=false,  --false because it's too flashy atm
    whip=false,
    hearts=true,
    triple=true,
    lives=true,
    time=true,
    control_jump=true,
    fast_whip=true,
    sp_weapon_select=true
}
debug=false

classMenu=spidey.classes.Menu
mnu=classMenu:new()
mnu.font=font[current_font]
mnu.background="small"
--mnu.cursor_image=cv1_heart
mnu.background_color="black"
mnu.items={}
mnu.items={
    {text='Reload level',action=function() if action then memory.writebyte(0x0019,0x00) end end}
}
mnu:addStandard()

--converts unsigned 8-bit integer to signed 8-bit integer
function signed8bit(_b)
if _b>255 or _b<0 then return false end
if _b>127 then return (255-_b)*-1 else return _b end
end

inp = input_read()

simon={}

emu.registerexit(function(x) emu.message("") end)
function spidey.update(inp,joy)
	lastinp=inp
	
	game.paused=(memory.readbyte(0x00ef)==0x01)
	action=(memory.readbyte(0x0019)==0x06)
	--level_end=(memory.readbyte(0x00e7)==0x08)
	level_end=(memory.readbyte(0x004f)==0xff)
	
	simon.action=memory.readbyte(0x046c)
	simon.sp_weapon=memory.readbyte(0x015b)
	
	
	gui.text(0,0, ""); -- force clear of previous text
	
	
	if (cheats.active) then
		if cheats.invincible then memory.writebyte(0x005b,0x2f) end
		if cheats.lives then memory.writebyte(0x002a,0x63) end
		if cheats.whip then memory.writebyte(0x0070,0x02) end
		if cheats.hearts and not level_end then memory.writebyte(0x0071,0x63) end
		if cheats.triple then memory.writebyte(0x0064,0x02) end
		if cheats.time and not level_end then
			memory.writebyte(0x0042,0x99)
			memory.writebyte(0x0043,0x99)
		end
		if level_end then
			-- Make the countdown shorter if we have a heap of time/hearts from cheats
			if cheats.time then memory.writebyte(0x0043,0x00) end --trim first two digits of time
			if cheats.hearts then memory.writebyte(0x0071, memory.readbyte(0x0071) % 10 ) end --trim first digit of hearts
		end
		
		if cheats.fast_whip then
			simon.whip_frame=memory.readbyte(0x0568)
			if simon.whip_frame <0x09 or (simon.whip_frame > 0x10 and  joy[1].B_press) then 
				simon.whip_frame=0x09
				memory.writebyte(0x0568,simon.whip_frame)
			end
		end
		
		if joy[1].B_press and simon.whip_frame >0x00 then
			--simon.whip_frame=0x01
			--memory.writebyte(0x0568,simon.whip_frame)
		end
		
		
		if joy[2].left_press then sfx=(sfx or 0) - 1 end
		if joy[2].right_press then sfx=(sfx or 0) + 1 end
		if joy[2].start_press then
			sfx=(sfx or 0)
			emu.message(string.format('sfx:%2X',sfx))
			memory.writebyte(0x00b4,sfx)
		end
		
		--memory.writebyte(0x031d,0x00)
		--memory.writebyte(0x031e,0x00)
		
		
		if simon.sp_weapon==0x08 then
			if joy[1].left then
				memory.writebyte(0x0464,0x01)
			elseif joy[1].right then
				memory.writebyte(0x0464,0x00)
			end
		end
		
		--weapon turns to enemy
		if memory.readbyte(0x0448)==23 then
			--memory.writebyte(0x0448,0x0e)
		end
		
		--if simon.sp_weapon==0x09 then --boomerang
		if true then
			--memory.writebyte(0x0330,0x64) --looks like ghost
			--memory.writebyte(0x0330,0x01)
			--memory.writebyte(0x0410,0x00) --stop moving
			--memory.writebyte(0x0410+0x1c,0x00) --stop moving
			--memory.writebyte(0x03d8,0x01)
			if joy[2].left then
				memory.writebyte(0x0464,0x01) --face/move left
				memory.writebyte(0x0410,0x01) --movement speed
			elseif joy[2].right then
				memory.writebyte(0x0464,0x00) --face/move right
				memory.writebyte(0x0410,0x01) --movement speed
			else
				--memory.writebyte(0x0410,0x00) --stop moving
				--memory.writebyte(0x0410+0x1c,0x00) --stop moving
			end

			if joy[2].up then
				memory.writebyte(0x03d8,0x02)
				memory.writebyte(0x03d8+0x1c,0x00)
			elseif joy[2].down then
				memory.writebyte(0x03d8,0x02)
				memory.writebyte(0x03d8+0x1c,0x00)
			else
				memory.writebyte(0x03d8,0x00)
				memory.writebyte(0x03d8+0x1c,0x00)
			end
		end
		
		
		if joy[1].select_press and action and cheats.sp_weapon_select then
			memory.writebyte(0x0018,0x05)
			memory.writebyte(0x0019,0x00)
			if next_sp_weapon[simon.sp_weapon] then
				simon.sp_weapon=next_sp_weapon[simon.sp_weapon]
				memory.writebyte(0x015b,simon.sp_weapon)
			end
		end
		
		if action and cheats.control_jump and simon.action==0x01 then --jumping
			if joy[1].left then
				memory.writebyte(0x0584,0x82)
			elseif joy[1].right then
				memory.writebyte(0x0584,0x81)
			else
				--memory.writebyte(0x0584,0x80)
			end
		end
		
	end
	
    if game.paused and cheats.enabled then
        mnu:show()
    else
        mnu:hide()
    end
end

spidey.run()