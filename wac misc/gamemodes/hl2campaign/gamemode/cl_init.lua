DeriveGamemode("sandbox")

include("sh_init.lua")
include("cl_debug.lua")
include("gui/scoreboard.lua")
include("countdowns.lua")

DROWNING_SOUNDS = {
	"player/pl_drown1.wav",
	"player/pl_drown2.wav",
	"player/pl_drown3.wav"
}

function GM:CreateScoreboard()
	if scoreboard then
		scoreboard:Remove()
		scoreboard = nil
	end
	scoreboard = vgui.Create("scoreboard")
end

function DrowningEffect(um)
	surface.PlaySound(DROWNING_SOUNDS[math.random(1, #DROWNING_SOUNDS)])
	deAlpha = 100
	deAlphaUpdate = 0
end
usermessage.Hook("DrowningEffect", DrowningEffect)

function GM:HUDDrawScoreBoard()
end

local function DrawDarken()
	local tab={}		
	tab["$pp_colour_addr"] 		=0
	tab["$pp_colour_addg"] 		=0
	tab["$pp_colour_addb"] 		=0
	tab["$pp_colour_brightness"] 	=-0.05
	tab["$pp_colour_contrast"] 	=1.1
	tab["$pp_colour_colour"] 		=1.1
	tab["$pp_colour_mulr"] 		=0
	tab["$pp_colour_mulg"] 		=0
	tab["$pp_colour_mulb"] 		=0
	DrawColorModify(tab)
end
hook.Add("RenderScreenspaceEffects", "hl2c_drawdarken", DrawDarken)

function GM:HUDPaint()
	self:HUDDrawTargetID()
	self:HUDDrawPickupHistory()
	surface.SetDrawColor(0, 0, 0, 0)
	w = ScrW()
	h = ScrH()
	centerX = w / 2
	centerY = h / 2
	
	if LocalPlayer():Team() == TEAM_DEAD then
		return
	else
		if deAlpha && deAlpha > 0 then
			if CurTime() >= deAlphaUpdate + 0.01 then
				deAlpha = deAlpha - 1
				deAlphaUpdate = CurTime()
			end
			
			surface.SetDrawColor(0, 0, 255, deAlpha)
			surface.DrawRect(0, 0, w, h)
		end
		if energy < 100 then
			local width = h*0.026*8.2*(energy/100)-8
			draw.RoundedBox(4, (ScrH()-h*0.132)/27.75, ScrH()-h*0.132, h*0.026*8.2, h*0.026, Color(0, 0, 0, 75))
			if width > 4 then
				draw.RoundedBox(2, (ScrH()-h*0.132)/27.75+4, ScrH()-h*0.132+4, width, h*0.026-8, Color(200, 160, 15, 200))
			end
		end
	end
	--self:DrawDeathNotice(0.85, 0.04)
end

function GM:HUDShouldDraw(name)
	if LocalPlayer() && LocalPlayer():IsValid() then
		local wep = LocalPlayer():GetActiveWeapon()
 		if wep && wep:IsValid() && wep.HUDShouldDraw != nil then
			return wep.HUDShouldDraw(wep, name)
		end
 	end
 	return true
end

function GM:Initialize()
	energy = 100
	self.ShowScoreboard = false
	showNav = true
	scoreboard = nil
	
	surface.CreateFont("arial16", {font="Arial", size=16, weight=400, antialias=true})
	surface.CreateFont("arial16Bold", {font="Arial", size=16, weight=700, antialias=true})
	surface.CreateFont("coolvetica72", {font="coolvetica", size=72, weight=500, antialias=true})
	surface.CreateFont("crosshair44", {font="HL2Cross", size=44, weight=430, antialias=true})
	surface.CreateFont("impact32", {font="Impact", size=32, weight=400, antialias=true})
	
	language.Add("worldspawn", "World")
	language.Add("func_door_rotating", "Door")
	language.Add("func_door", "Door")
	language.Add("phys_magnet", "Magnet")
	language.Add("trigger_hurt", "Trigger Hurt")
	language.Add("entityflame", "Fire")
	language.Add("env_explosion", "Explosion")
	language.Add("env_fire", "Fire")
	language.Add("func_tracktrain", "Train")
	language.Add("npc_launcher", "Headcrab Pod")
	language.Add("func_tank", "Mounted Turret")
	language.Add("npc_helicopter", "Helicopter")
	language.Add("npc_bullseye", "Turret")
	language.Add("prop_vehicle_apc", "APC")
	language.Add("item_healthvial", "Health Vial")
	language.Add("combine_mine", "Mine")
	language.Add("npc_grenade_frag", "Grenade")
end

hook.Add("NextMap", function(map)
	if #SUCCESS_SOUNDS > 1 then
		surface.PlaySound(SUCCESS_SOUNDS[math.random(1, #SUCCESS_SOUNDS)])
	elseif #SUCCESS_SOUNDS > 0 then
		surface.PlaySound(SUCCESS_SOUNDS[1])
	end
	if LocalPlayer():Team() != TEAM_ALIVE then
		RunConsoleCommand("+score")
	end
end)

net.Receive("NextMap", function(len, pl)
	hook.Call("NextMap", nil, net.ReadString())
end)

net.Receive("RestartMap", function(len, pl)
	hook.Call("RestartMap", nil, net.ReadString())
end)

net.Receive("StartCampaign", function(len, pl)
	hook.Call("StartCampaign", nil, net.ReadString())
end)


hook.Add("RestartMap", "hl2c_game_restartmap", function()
	local file = FAILURE_SOUNDS[math.random(1, #FAILURE_SOUNDS)]
	sound.PlayFile(file, "", function(station)
		if(IsValid(station)) then station:Play() end
	end)
	RunConsoleCommand("+score")
end)

function PlayerInitialSpawn(um)
	if !file.Exists("hl2campaign_shown_help.txt", "DATA") then
		ShowHelp()
		file.Write("hl2campaign_shown_help.txt", "You've viewed the help menu in Half-Life 2 Campaign.")
	end
	checkpointPosition = um:ReadVector()
end
usermessage.Hook("PlayerInitialSpawn", PlayerInitialSpawn)

function ShowHelp()
	local helpText = [[-= KEYBOARD SHORTCUTS =-
	[F1] Opens this menu.
	[F3] Spawns a vehicle if allowed.
	[F4] Removes a vehicle if you have one.
	
	-= OTHER NOTES =-
	Once you've died three times you cannot respawn until the next map.
	You are not able to carry more than a certain amount of ammo.]]
	local helpMenu = vgui.Create("DFrame")
	local helpPanel = vgui.Create("DPanel", helpMenu)
	local helpLabel = vgui.Create("DLabel", helpPanel)
	helpLabel:SetText(helpText)
	--helpLabel:SetTextColor(color_black)
	helpLabel:SizeToContents()
	helpLabel:SetPos(5, 5)
	local w, h = helpLabel:GetSize()
	helpMenu:SetSize(w + 20, h + 43)
	helpPanel:StretchToParent(5, 28, 5, 5)
	helpMenu:SetTitle("Half-Life 2 Campaign Help")
	helpMenu:Center()
	helpMenu:MakePopup()
end
usermessage.Hook("ShowHelp", ShowHelp)

function GM:ScoreboardHide()
	self.ShowScoreboard = false
	
	if scoreboard then
		scoreboard:SetVisible(false)
	end
end

function GM:ScoreboardShow()
	self.ShowScoreboard = true
	
	if !scoreboard then
		self:CreateScoreboard()
	end
	
	scoreboard:SetVisible(true)
	scoreboard:UpdateScoreboard(true)
end

function ShowTeam()
	if showNav then
		showNav = false
	else
		showNav = true
	end
end
usermessage.Hook("ShowTeam", ShowTeam)

function SetCheckpointPosition(um)
	checkpointPosition = um:ReadVector()
end
usermessage.Hook("SetCheckpointPosition", SetCheckpointPosition)

function UpdateEnergy(um)
	energy = um:ReadFloat()
end
usermessage.Hook("UpdateEnergy", UpdateEnergy)