
--[[
	WAC (WeltEnSTurm's Addon Compilation)
	Copyright (C) 2012 Robert Luger

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  http://www.gnu.org/licenses/gpl.html
]]

wac = wac or {
	
	version = "330",
	
	author = "weltensturm",
	
	menu = {
		tab = "Options",
		category = "WAC",
	},
	
	player = function(p)
		p.wac = p.wac or {}
	end,

	smoothApproach = function(x,y,s,c)
		if !x then error("first argument nil", 2) end
		if !y then error("second argument nil", 2) end
		local FrT=math.Clamp(FrameTime(), 0.001, 0.035)*0.3
		c=(c and c*FrT)or(99999)
		return x-math.Clamp((x-y)*s*FrT,-c,c)
	end,

	smoothApproachAngle = function(x,y,s,c)
		local FrT=math.Clamp(FrameTime(), 0.001, 0.035)*0.3
		c=(c and c*FrT)or(99999)
		return x-math.Clamp(math.AngleDifference(x,y)*s*FrT,-c,c)
	end,

	smoothApproachAngles = function(a1,a2,s,c)
		if !a1 or !a2 then error("one argument is nil", 2) end
		a1.p = wac.smoothApproachAngle(a1.p, a2.p, s,c)
		a1.y = wac.smoothApproachAngle(a1.y, a2.y, s,c)
		a1.r = wac.smoothApproachAngle(a1.r, a2.r, s,c)
		return a1
	end,

	smoothApproachVector = function(begin, target, s, c)
		if !begin then error("first argument is nil", 2) end
		if !target then error("second argument is nil", 2) end
		if !s then error("third argument is nil", 2) end
		local dir = (begin-target):GetNormal()
		local dist = begin:Distance(target)
		local var = wac.smoothApproach(0,dist,s,c)
		local v = begin-dir*var
		begin.x = v.x
		begin.y = v.y
		begin.z = v.z
		--[[begin.x=WAC.SmoothApproach(begin.x,end.x,s,c)
		begin.y=WAC.SmoothApproach(begin.y,end.y,s,c)
		begin.z=WAC.SmoothApproach(begin.z,end.z,s,c)]]
		return begin
	end,


	hooks = {},
	hooksCalcView = {},
	hook = function(gmhook, name, func, unload)
		if gmhook == "CalcView" then
			wac.hooksCalcView[name] = {f = func, u = unload, g = gmhook}
		else
			wac.hooks[name] = {f = func, u = unload, g = gmhook}
			hook.Add(gmhook, name, func)
		end
	end,
	
	menuPanels = {},
	addMenuPanel = function(tab, category, name, func, ...)
		wac.menuPanels[tab] = wac.menuPanels[tab] or {}
		wac.menuPanels[tab][category] = wac.menuPanels[tab][category] or {}
		wac.menuPanels[tab][category][name] = wac.menuPanels[tab][category][name] or {}
		
		local t = wac.menuPanels[tab][category][name]
		t.func = func
		
		if t.triggers then
			for k, v in pairs(t.triggers) do
				t.triggers[k] = ""
			end
		end
		
		t.triggers = t.triggers or {}
		if ... then
			for _, var in pairs({...}) do
				t.triggers[var] = ""
			end
		end
		
	end,
	
}
