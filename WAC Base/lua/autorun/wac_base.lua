
include("wac/base.lua")

if SERVER then

	AddCSLuaFile("autorun/wac_base.lua")

	local folderList = {}
	folderList = file.Find("wac/".."*.lua", "LUA")
	table.sort(folderList)
	for _, f in pairs(folderList) do
		AddCSLuaFile("wac/" .. f)
		MsgN("adding cs lua " .. "wac/" .. f)
	end

else

	-- menu/settings stuff
	wac.hook("PopulateToolMenu", "wac_menu_populate", function()
		for tab, t1 in pairs(wac.menuPanels) do
			for category, t2 in pairs(t1) do
				for name, hook in pairs(t2) do
					spawnmenu.AddToolMenuOption(tab, category, name, name, "", "", function(panel)
						wac.menuPanels[tab][category][name].panel = panel
						panel:Clear()
						hook.func(panel, {})
					end, {})
				end
			end
		end
	end)
	
	local lastThink=0
	wac.hook("Think", "wac_menupanel_update", function()
		local crt=CurTime()
		if lastThink+0.1 < crt then
			for nameTab, tab in pairs(wac.menuPanels) do
				for nameCategory, category in pairs(tab) do
					for namePanel, panel in pairs(category) do
					
						if panel.panel then
							for name, old in pairs(panel.triggers) do
								if GetConVar(name) then
									local new = GetConVar(name):GetString()
									if old != new then
										panel.triggers[name] = new
										panel.panel:Clear()
										panel.func(panel.panel, panel.triggers)
									end
								end
							end
						end
						
					end
				end
			end
			lastThink = crt
		end
	end)
		
	
	-- calcview hooks
	local view = {}
	local lastCalcView = 0
	wac.calcView = function(player, pos, ang, fov)
		if lastCalcView == CurTime() then return view end
		player.wac = player.wac or {}
		lastCalcView = CurTime()
		view.origin = pos
		view.angles = ang
		view.fov = fov
		view.vm_angles = nil
		view.vm_origin = nil
		local send = false
		for name, hook in pairs(wac.hooksCalcView) do
			local t = hook.f(player, view.origin, view.angles, view.fov)
			if t then
				view.origin = t.origin or view.origin
				view.angles = t.angles or view.angles
				view.fov = t.fov or view.fov
				view.vm_angles = t.vm_angles or view.vm_angles
				view.vm_origin=t.vm_origin or view.vm_origin
				send = true
			end
		end
		player.wac.lastView = table.Copy(view)
		if send then return view end
	end
	hook.Add("CalcView", "wac_cl_calcview", wac.calcView)
	wac.hooks["wac_cl_calcview"] = {f = wac.calcView, g = "CalcView"}

end

concommand.Add("wac_reloadhooks" .. (CLIENT and "_cl" or ""), function(player, command, args)
	for name, t in pairs(wac.hooks) do
		if !t.g or !name or !t.f then error("failed to reload hook " .. tostring(t.g) .. ' ' .. tostring(name) .. ' ' .. tostring(t.f)) end
		hook.Add(t.g, name, t.f)
	end
end)
