
if game.SinglePlayer() then

	include "wac/base.lua"

	local interval = CreateConVar("wac_autosave_time", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE})
	if SERVER then
		local savetime=0
		wac.hook("Think", "wac_autosave_think", function()
			if interval:GetFloat() <= 0 then return end
			local tick = CurTime()
			if savetime+interval:GetFloat() < tick then
				player.GetByID(1):ConCommand("autosave")
				player.GetByID(1):PrintMessage(HUD_PRINTTALK, "Game has been saved.")
				savetime = tick
			end
		end)
	else
		wac.addMenuPanel(wac.menu.tab, wac.menu.category, "Misc", function(panel)
			panel:AddControl("Slider", {
				Label = "Autosave Time (Seconds)",
				Type = "number",
				Min = 0,
				Max = 1000,
				Command = "wac_autosave_time",
			})
		end)
	end

end
