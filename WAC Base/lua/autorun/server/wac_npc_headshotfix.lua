
include "wac/base.lua"

local eb = CreateConVar("wac_npc_headshotfix", 1, {FCVAR_REPLICATED,FCVAR_ARCHIVE})

if SERVER then

	wac.hook("ScaleNPCDamage", "wac_headshotfix_hook", function(e,hg,dmg)
		if eb:GetInt()==1 then
			if hg==1 then dmg:ScaleDamage(0.2) end
			-- It's 10 times by default, but it should be 2, 10*0.2=2
		end
	end)

else

	wac.addMenuPanel(wac.menu.tab, wac.menu.category, "Misc", function(panel)
		panel:CheckBox("NPC Headshot Damage Fix","wac_npc_headshotfix")
	end)

end
