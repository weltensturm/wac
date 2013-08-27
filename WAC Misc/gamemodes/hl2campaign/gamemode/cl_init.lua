DeriveGamemode("sandbox")

-- Include the required lua files
include("sh_init.lua")
include("cl_scoreboard.lua")


-- Client only constants
DROWNING_SOUNDS = {
	"player/pl_drown1.wav",
	"player/pl_drown2.wav",
	"player/pl_drown3.wav"
}


-- Called by ShowScoreboard
function GM:CreateScoreboard()
	if scoreboard then
		scoreboard:Remove()
		scoreboard = nil
	end

	scoreboard = vgui.Create("scoreboard")
end


-- This creates the drowning effect
function DrowningEffect(um)
	surface.PlaySound(DROWNING_SOUNDS[math.random(1, #DROWNING_SOUNDS)])
	deAlpha = 100
	deAlphaUpdate = 0
end
usermessage.Hook("DrowningEffect", DrowningEffect)


-- Do not want!
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

-- Called every frame to draw the hud
function GM:HUDPaint()
	if self.ShowScoreboard && LocalPlayer() && LocalPlayer():Team() != TEAM_DEAD then
		return
	end
	self:HUDDrawTargetID()
	self:HUDDrawPickupHistory()
	surface.SetDrawColor(0, 0, 0, 0)
	w = ScrW()
	h = ScrH()
	centerX = w / 2
	centerY = h / 2
	--[[Draw nav marker/point
	if showNav && checkpointPosition && LocalPlayer():Team() == TEAM_ALIVE then
		local checkpointDistance = math.Round(LocalPlayer():GetPos():Distance(checkpointPosition) / 39)
		local checkpointPositionScreen = checkpointPosition:ToScreen()
		
		surface.SetDrawColor(255, 255, 255, 255)
		
		if checkpointPositionScreen.x > 32 && checkpointPositionScreen.x < w - 43 && checkpointPositionScreen.y > 32 && checkpointPositionScreen.y < h - 38 then
			surface.SetTexture(surface.GetTextureID("hl2c_nav_marker"))
			surface.DrawTexturedRect(checkpointPositionScreen.x - 14, checkpointPositionScreen.y - 14, 28, 28)
			draw.DrawText(tostring(checkpointDistance).." m", "arial16", checkpointPositionScreen.x, checkpointPositionScreen.y + 15, Color(255, 220, 0, 255), 1)
		else
			local r = math.Round(centerX / 2)
			local checkpointPositionRad = math.atan2(checkpointPositionScreen.y - centerY, checkpointPositionScreen.x - centerX)
			local checkpointPositionDeg = 0 - math.Round(math.deg(checkpointPositionRad))
			surface.SetTexture(surface.GetTextureID("hl2c_nav_pointer"))
			surface.DrawTexturedRectRotated(math.cos(checkpointPositionRad) * r + centerX, math.sin(checkpointPositionRad) * r + centerY, 32, 32, checkpointPositionDeg + 90)
		end
	end]]
	
	if LocalPlayer():Team() == TEAM_DEAD then
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, w, h * 0.10)
		surface.DrawRect(0, h - h * 0.10, w, h * 0.10)
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
	if nextMapCountdownStart then
		local nextMapCountdownLeft = math.Round(nextMapCountdownStart + NEXT_MAP_TIME - CurTime())
		if nextMapCountdownLeft > 0 then
			draw.DrawText("Next Map in "..tostring(nextMapCountdownLeft), "impact32", centerX, h - h * 0.075, Color(255, 255, 255, 200), 1)
		else
			draw.DrawText("Changing Map!", "impact32", centerX, h - h * 0.075, Color(255, 255, 255, 200), 1)
		end
	end
	if restartMapCountdownStart then
		local restartMapCountdownLeft = math.Round(restartMapCountdownStart + RESTART_MAP_TIME - CurTime())
		if restartMapCountdownLeft > 0 then
			draw.DrawText("Restarting Map in "..tostring(restartMapCountdownLeft), "impact32", centerX, h - h * 0.075, Color(255, 255, 255, 200), 1)
		else
			draw.DrawText("Restarting Map!", "impact32", centerX, h - h * 0.075, Color(255, 255, 255, 200), 1)
		end
	end
	--self:DrawDeathNotice(0.85, 0.04)
end

function GM:HUDShouldDraw(name)
	if LocalPlayer() && LocalPlayer():IsValid() then
		if !LocalPlayer():Alive() || (self.ShowScoreboard && LocalPlayer() && LocalPlayer():Team() != TEAM_DEAD) then
			return false
		end
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
	
	surface.CreateFont("Arial", 16, 400, true, false, "arial16")
	surface.CreateFont("Arial", 16, 700, true, false, "arial16Bold")
	surface.CreateFont("coolvetica", 72, 500, true, false, "coolvetica72")
	surface.CreateFont("HL2Cross", 44, 430, true, false, "crosshair44")
	surface.CreateFont("Impact", 32, 400, true, false, "impact32")
	
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

function NextMap(um)
	if #SUCCESS_SOUNDS > 1 then
		surface.PlaySound(SUCCESS_SOUNDS[math.random(1, #SUCCESS_SOUNDS)])
	elseif #SUCCESS_SOUNDS > 0 then
		surface.PlaySound(SUCCESS_SOUNDS[1])
	end
	nextMapCountdownStart = um:ReadLong()
	if LocalPlayer():Team() != TEAM_ALIVE then
		RunConsoleCommand("+score")
	end
end
usermessage.Hook("NextMap", NextMap)

function PlayerInitialSpawn(um)
	if !file.Exists("hl2campaign/shown_help.txt") then
		ShowHelp()
		file.Write("hl2campaign/shown_help.txt", "You've viewed the help menu in Half-Life 2 Campaign.")
	end
	checkpointPosition = um:ReadVector()
end
usermessage.Hook("PlayerInitialSpawn", PlayerInitialSpawn)

function RestartMap(um)
	if #FAILURE_SOUNDS > 1 then
		surface.PlaySound(FAILURE_SOUNDS[math.random(1, #FAILURE_SOUNDS)])
	elseif #FAILURE_SOUNDS > 0 then
		surface.PlaySound(FAILURE_SOUNDS[1])
	end
	restartMapCountdownStart = um:ReadLong()
	RunConsoleCommand("+score")
end
usermessage.Hook("RestartMap", RestartMap)

function ShowHelp()
	local helpText = [[-= KEYBOARD SHORTCUTS =-
	[F1] Opens this menu.
	[F2] Opens buy/sell menu.
	[F3] Spawns a vehicle if allowed.
	[F4] Removes a vehicle if you have one.
	
	-= OTHER NOTES =-
	Once you're dead you cannot respawn until the next map.
	You are not able to carry more than a certain amount of ammo.
	To pick up weapons, hold E.]]
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

-- Called by client pressing -score
function GM:ScoreboardHide()
	self.ShowScoreboard = false
	
	if scoreboard then
		scoreboard:SetVisible(false)
	end
end


-- Called by client pressing +score
function GM:ScoreboardShow()
	self.ShowScoreboard = true
	
	if !scoreboard then
		self:CreateScoreboard()
	end
	
	scoreboard:SetVisible(true)
	scoreboard:UpdateScoreboard(true)
end


-- Called by ShowTeam
function ShowTeam()
	if showNav then
		showNav = false
	else
		showNav = true
	end
end
usermessage.Hook("ShowTeam", ShowTeam)


-- Called by server
function SetCheckpointPosition(um)
	checkpointPosition = um:ReadVector()
end
usermessage.Hook("SetCheckpointPosition", SetCheckpointPosition)


-- Called by server Think()
function UpdateEnergy(um)
	energy = um:ReadFloat()
end
usermessage.Hook("UpdateEnergy", UpdateEnergy)