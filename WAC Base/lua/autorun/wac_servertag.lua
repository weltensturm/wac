
include("wac/servertag.lua")

concommand.Add("wac_tag_add", function(player, command, args)
	if player:IsAdmin() then
		wac.tag.add(args[1])
	end
end)

concommand.Add("wac_tag_remove", function(player, command, args)
	if player:IsAdmin() then
		wac.tag.remove(args[1])
	end
end)

local nextThink=0
wac.hook("Think", "wac_svtag_think", function()
	if nextThink < CurTime() then
		local changed = false
		local t = string.Explode(",", GetConVarString("sv_tags") or "")
		for _, tag in pairs(wac.tag.tags) do
			if !table.HasValue(t, tag) then
				table.insert(t, tag)
				changed = true
			end
		end
		if changed then
			RunConsoleCommand("sv_tags", table.concat(t,","))
		end
		nextThink=CurTime()+10
	end
end)

wac.tag.add("wac")
wac.tag.add("wac" .. wac.version)
