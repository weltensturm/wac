
include "wac/base.lua"

local FCVAR={FCVAR_REPLICATED,FCVAR_ARCHIVE}

local cvar = {
	walkSpeed = CreateConVar("wac_player_walkspeed", 195, FCVAR),
	runSpeed = CreateConVar("wac_player_runspeed", 310, FCVAR),
	jumpForce = CreateConVar("wac_player_jumpspeed", 200, FCVAR),
	enable = CreateConVar("wac_player_enable", 1, FCVAR),
}

if SERVER then

	local function update(p)
		if cvar.enable:GetInt()==1 then
			timer.Simple(0.1, function()
				for _, ply in pairs(player.GetAll()) do
					--ply:SetCrouchedWalkSpeed(0.6)
					ply:SetWalkSpeed(cvar.walkSpeed:GetFloat())
					ply:SetRunSpeed(cvar.runSpeed:GetFloat())
					ply:SetJumpPower(cvar.jumpForce:GetFloat())
				end
			end)
		end
	end
	wac.hook("PlayerSpawn", "wac_player_spawn", update)
	concommand.Add("wac_player_update", update)

else

	local blur = {
		enable = CreateClientConVar("wac_cl_speed_blur", 0, true, false),
		inNoclip = CreateClientConVar("wac_cl_speed_blur_noclip", 1, true, false),
		sound,
		smooth = 0
	}

	wac.hook("RenderScreenspaceEffects", "wac_cl_speedblur", function()
		local p = LocalPlayer()
		local doll = p:GetRagdollEntity()
		if
			p:GetViewEntity() == p and blur.enable:GetBool()
			and (p:GetMoveType() != MOVETYPE_NOCLIP or blur.inNoclip:GetBool())
			and !p:InVehicle() and (!p:Alive() or IsValid(p:GetRagdollEntity()))
		then
			if p:Alive() then
				vel = p:GetVelocity():Length()-200
			elseif IsValid(p:GetRagdollEntity()) then
				vel = p:GetRagdollEntity():GetVelocity():Length()-200
			end
		else
			vel = 0
		end
		blur.smooth = blur.smooth-(blur.smooth-vel)*FrameTime()*4
		if blur.smooth > 0 then
			if !blur.sound then
				blur.sound = CreateSound(p, "vehicles/fast_windloop1.wav")
				blur.sound:Play()
				blur.sound:ChangeVolume(0, 0)
			end
			DrawMotionBlur(1-math.Clamp(blur.smooth/500,0,0.9), math.Clamp(blur.smooth/500,0,1), 0.01)
		end
		if blur.sound then
			blur.sound:ChangeVolume(math.Clamp(blur.smooth/1000, 0, 1), 0)
			blur.sound:ChangePitch(math.Clamp(blur.smooth/10, 0, 200), 0)
		end
	end)

	wac.addMenuPanel(wac.menu.tab, wac.menu.category, "Player Speed", function(panel)
		panel:AddControl("Label", {Text = "Client Settings"})
		panel:CheckBox("Enable Speed Blur", "wac_cl_speed_blur")
		panel:CheckBox("Enable Blur in Noclip", "wac_cl_speed_blur_noclip")
		panel:AddControl("Label", {Text = ""})
		panel:AddControl("Label", {Text = "Admin Settings"})
		panel:CheckBox("Enable","wac_walkm_enable")
		panel:AddControl("ComboBox", {
			Label = "Presets",
			MenuButton = 0,
			Options = {
				Default = {
					wac_player_runspeed=500,
					wac_player_walkspeed=250,
					wac_player_jumpspeed=200,
					wac_player_update=1,
				},
				Realistic = {
					wac_player_runspeed=215,
					wac_player_walkspeed=90,
					wac_player_update=1,
				},
				Balanced = {
					wac_player_runspeed=310,
					wac_player_walkspeed=195,
					wac_player_update=1,
				},
			}
		})
		panel:AddControl("Slider", {
			Label = "Walkspeed",
			Type = "number",
			Min = 1,
			Max = 1000,
			Command = "wac_player_walkspeed",
		})
		panel:AddControl("Slider", {
			Label = "Runspeed",
			Type = "number",
			Min = 1,
			Max = 1000,
			Command = "wac_player_runspeed",
		})
		panel:AddControl("Slider", {
			Label = "Jumppower",
			Type = "number",
			Min = 1,
			Max = 1000,
			Command = "wac_player_jumpspeed",
		})
		panel:AddControl("Button", {
			Label = "Update",
			Description = "Update Walkspeed",
			Text = "Update Walkspeed",
			Command = "wac_player_update",
		})
	end)

end
