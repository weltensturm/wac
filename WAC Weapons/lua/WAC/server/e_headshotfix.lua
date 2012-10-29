
local eb=CreateConVar("wac_headshotfix_enable", 1, {FCVAR_REPLICATED,FCVAR_ARCHIVE})

wac.hook("ScaleNPCDamage", "wac_headshotfix_hook", function(e,hg,dmg)
	if eb:GetInt()==1 then
		if hg==1 then dmg:ScaleDamage(0.2) end
		-- It's 10 times by default, but it should be 2, 10*0.2=2
	end
end)
