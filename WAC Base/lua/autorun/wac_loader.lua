
--[[
WAC_Version=95

MsgN("[WAC] Loading autorun/wac_loader.lua, Version "..WAC_Version)

if SERVER then
	SetGlobalInt("wac_version", WAC_Version)
end

local exceptions={
	"e_blur.lua",
	"e_mdelta.lua",
}

WAC={__hooks={}}
function WAC.Reload(p, c, a)
	local panels=WAC.MenuPanels
	if WAC and WAC.__hooks then
		for k,v in pairs(WAC.__hooks) do
			hook.Remove(v[1], v[2])
		end
	end
	if p and IsValid(p) and (p:IsAdmin() or CLIENT) and a[1]=="full" then
		include("autorun/wac_loader.lua")
		return
	end

	WAC={__hooks={},MenuPanels=panels}

	for _, folder in pairs({"shared/", SERVER and "server/" or "client/"}) do
		local folderList = file.Find("wac/"..folder.."*.lua", "LUA")
		table.sort(folderList)
		for i, f in pairs(folderList) do
			if !table.HasValue(exceptions, f) or GetGlobalBool("wac_debugload") then
				MsgN("[WAC] Loading WAC/"..folder..f)
				include("WAC/"..folder..f)
				if SERVER and (folder == "shared/" or folder == "client/") then
					AddCSLuaFile("WAC/" .. folder .. f)
				end
			end
		end
	end

end
concommand.Add("wac_reload"..(SERVER and "" or "_cl"), WAC.Reload)

function WAC.Unload(p,c,a)
	if WAC and WAC.__hooks then
		for k,v in pairs(WAC.__hooks) do
			hook.Remove(v[1], v[2])
			MsgN("Unloaded "..v[1]..", "..v[2])
		end
	end
end
concommand.Add("wac_unload"..(SERVER and "" or "_cl"), WAC.Unload)

WAC.Reload()
]]
