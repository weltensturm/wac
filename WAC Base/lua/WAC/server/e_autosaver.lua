
if SinglePlayer() then
	local autosavetime=CreateConVar("wac_autosave_time", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE})
	local savetime=0
	local function savethink()
		local SvT=autosavetime:GetFloat()
		if SvT<=0 then return end
		local CrT=CurTime()
		if savetime+SvT<CrT then
			player.GetByID(1):ConCommand("autosave")
			player.GetByID(1):PrintMessage(HUD_PRINTTALK, "Game has been saved.")
			savetime=CrT
		end
	end
	WAC.Hook("Think", "wac_autosave_think", savethink)
end
