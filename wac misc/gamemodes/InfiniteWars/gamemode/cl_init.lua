DeriveGamemode("sandbox")

include("Shared.lua")
include("cl_scoreboard.lua")
include("cl_deathnotice.lua")
include("cl_notice.lua")
include("language.lua")
include('cl_panel.lua')

local sprintvar = 100
local cansprint = true
local gm_derma = {}

local function OpenTeamPanel()
	local SW = ScrW()
	local SH = ScrH()
	if gm_derma.TeamPanel then gm_derma.TeamPanel:Remove() end
	gm_derma.TeamPanel = vgui.Create("DFrame")
	gm_derma.TeamPanel:SetPos(SW/2-55, SH/2-55)
	gm_derma.TeamPanel:SetSize(110, 130)
	gm_derma.TeamPanel:SetTitle("Team")
	gm_derma.TeamPanel:SetVisible(true)
	gm_derma.TeamPanel:SetDraggable(false)
	gm_derma.TeamPanel:ShowCloseButton(false)
	gm_derma.TeamPanel:MakePopup()
	
	gm_derma.TeamPanel.team_1 = vgui.Create("DButton", gm_derma.TeamPanel)
	gm_derma.TeamPanel.team_1:SetPos(5, 30)
	gm_derma.TeamPanel.team_1:SetSize(100, 20)
	gm_derma.TeamPanel.team_1:SetText("Blue")
	gm_derma.TeamPanel.team_1.DoClick = function()	RunConsoleCommand("setteam", "1") end

	gm_derma.TeamPanel.team_2 = vgui.Create("DButton", gm_derma.TeamPanel)
	gm_derma.TeamPanel.team_2:SetPos(5, 55)
	gm_derma.TeamPanel.team_2:SetSize(100, 20)
	gm_derma.TeamPanel.team_2:SetText("Red")
	gm_derma.TeamPanel.team_2.DoClick = function()	RunConsoleCommand("setteam", "2") end

	gm_derma.TeamPanel.team_3 = vgui.Create("DButton", gm_derma.TeamPanel)
	gm_derma.TeamPanel.team_3:SetPos(5, 80)
	gm_derma.TeamPanel.team_3:SetSize(100, 20)
	gm_derma.TeamPanel.team_3:SetText("Spectator")
	gm_derma.TeamPanel.team_3.DoClick = function() RunConsoleCommand("setteam", "3") end

	local closebutton = vgui.Create("DButton", gm_derma.TeamPanel)
	closebutton:SetPos(5, 105)
	closebutton:SetSize(100, 20)
	closebutton:SetText("Close")
	closebutton.DoClick = function() RunConsoleCommand("team_menu_close") end
end
concommand.Add("team_menu", OpenTeamPanel)

function CloseTeamPanel()
	if gm_derma.TeamPanel then
		gm_derma.TeamPanel:Remove()
	end
end
concommand.Add("team_menu_close", CloseTeamPanel)

local function OpenClassPanel()
	local SW = ScrW()
	local SH = ScrH()
	if ClassPanel then ClassPanel:Remove() end
	ClassPanel = vgui.Create("DFrame")
	ClassPanel:SetPos(SW/2-145, SH/2-120)
	ClassPanel:SetSize(290, 240)
	ClassPanel:SetTitle("Class")
	ClassPanel:SetVisible(true)
	ClassPanel:SetDraggable(false)
	ClassPanel:ShowCloseButton(false)
	ClassPanel:MakePopup()

	local icon = vgui.Create("DModelPanel", ClassPanel)
	icon.model = ""
	icon:SetPos(0, -80)
	icon:SetSize(290, 290)
	icon:SetCamPos(Vector(70,0,50))
	icon:SetLookAt(Vector(0, 0, 40))

	local ClassList = vgui.Create("DComboBox", ClassPanel)
	ClassList:SetPos(20, 120)
	ClassList:SetSize(70, 100)
	ClassList:SetMultiple(false)

	for i,c in pairs(CLASSES) do
		ClassList:AddItem(i)
	end
	ClassList:SelectByName(LocalPlayer():GetNWString("class"))
	
	for _,w in pairs(weapons.GetList()) do
		for _,c in pairs(CLASSES) do
			for key, value in pairs(c.weapons) do
				if key == w.ClassName then
					value.WorldModel = w.WorldModel
					value.PrintName = w.PrintName
				end
			end
		end
	end

	local WMC = vgui.Create("DComboBox", ClassPanel)
	WMC:SetPos(110, 120)
	WMC:SetSize(70, 100)
	local function WeaponListChanged()
		ClassList.SelectedClass.weapon = WMC:GetSelectedItems()[1]:GetValue()
		for k,v in pairs(ClassList.SelectedClass.weapons) do
			if v.PrintName == ClassList.SelectedClass.weapon then
				icon:SetModel(v.WorldModel)
				icon:SetCamPos(v[2])
				icon:SetLookAt(v[1])
				break
			end
		end
	end
	
	local function ClassListChanged()
		ClassList.SelectedClass = CLASSES[ClassList:GetSelectedItems()[1]:GetValue()]	
		WMC:Clear()
		for k,v in pairs(ClassList.SelectedClass.weapons)do
			WMC:AddItem(v.PrintName)
		end
		for k,we in pairs(ClassList.SelectedClass.weapons) do
			WMC:SelectByName(we.PrintName)
			icon:SetModel(we.WorldModel)
			icon:SetCamPos(we[2])
			icon:SetLookAt(we[1])
			break
		end
	end

	local closebutton = vgui.Create("DButton", ClassPanel)
	closebutton:SetPos(200, 200)
	closebutton:SetSize(70, 20)
	closebutton:SetText("Done")
	closebutton.DoClick = function()
		if !ClassList:GetSelectedItems()[1] then ClassPanel:Remove() return end
		RunConsoleCommand("setclass", ClassList:GetSelectedItems()[1]:GetValue())
		RunConsoleCommand("team_menu_close")
	end
	
	local teambutton = vgui.Create("DButton", ClassPanel)
	teambutton:SetPos(200, 160)
	teambutton:SetSize(70, 20)
	teambutton:SetText("Back")
	teambutton.DoClick = function()
		RunConsoleCommand("class_menu_close")
		RunConsoleCommand("team_menu")
	end
	
	local oldsel = ""
	local woldsel = ""
	local paint = vgui.Create("DFrame", ClassPanel)
	paint:SetTitle("")
	paint:SetVisible(true)
	paint:SetDraggable(false)
	paint:ShowCloseButton(false)
	paint.Paint = function()
		if ClassList:GetSelectedItems()[1] then
			if oldsel != ClassList:GetSelectedItems()[1]:GetValue() then
				ClassListChanged()
				oldsel = ClassList:GetSelectedItems()[1]:GetValue()
			end
		end
		if WMC:GetSelectedItems()[1] then
			if woldsel != WMC:GetSelectedItems()[1]:GetValue() then
				WeaponListChanged()
				woldsel = WMC:GetSelectedItems()[1]:GetValue()
			end
		end
	end

end
concommand.Add("class_menu", OpenClassPanel)

function CloseClassPanel()
	if ClassPanel then
		ClassPanel:Remove()
	end
end
concommand.Add("class_menu_close", CloseClassPanel)

local cppos = -10
local watchcp = nil
local TEXTCOL = Color(220, 220, 220, 200)
local BGCOL = Color(20, 20, 20, 100)
local TEAM1COL = Color(50, 50, 195, 200)
local TEAM2COL = Color(195, 50, 50, 200)
local nocol = Color(0,0,0,0)
local pl3dtext = Color(50, 50, 195, 200)
local pl3dbg = Color(20, 20, 20,200)
local purewhite = Color(255,255,255,255)
local purebg = Color(10,10,10,100)
local StaminaCol = Color(220, 220, 220, 200)
local SpottedPlayers = {}
local CompassTable = {
	{
		Pos = Vector(0,1,0),
		Char = "N",
	},
	{
		Pos = Vector(0,-1,0),
		Char = "S",
	},
	{
		Pos = Vector(1,0,0),
		Char = "E",
	},
	{
		Pos = Vector(-1,0,0),
		Char = "W",
	},
		{
		Pos = Vector(1,1,0),
		Char = "NE",
	},
	{
		Pos = Vector(1,-1,0),
		Char = "SE",
	},
	{
		Pos = Vector(-1,-1,0),
		Char = "SW",
	},
	{
		Pos = Vector(-1,1,0),
		Char = "NW",
	},
}

local function hud_update()
	TEAM1COL = Color(
		GetConVar("hud_blue_r"):GetFloat(),
		GetConVar("hud_blue_g"):GetFloat(),
		GetConVar("hud_blue_b"):GetFloat(),
		GetConVar("hud_blue_a"):GetFloat()
	)
	TEAM2COL = Color(
		GetConVar("hud_red_r"):GetFloat(),
		GetConVar("hud_red_g"):GetFloat(),
		GetConVar("hud_red_b"):GetFloat(),
		GetConVar("hud_red_a"):GetFloat()
	)
	TEXTCOL = Color(
		GetConVar("hud_txt_r"):GetFloat(),
		GetConVar("hud_txt_g"):GetFloat(),
		GetConVar("hud_txt_b"):GetFloat(),
		GetConVar("hud_txt_a"):GetFloat()
	)
	BGCOL = Color(
		GetConVar("hud_bg_r"):GetFloat(),
		GetConVar("hud_bg_g"):GetFloat(),
		GetConVar("hud_bg_b"):GetFloat(),
		GetConVar("hud_bg_a"):GetFloat()
	)
	print(GetConVar("hud_bg_r"):GetFloat())
end
concommand.Add("hud_update", hud_update)

local SW=ScrW()
local SH=ScrH()
local smHlth=0
local smArm=0
local smPtsBl=0
local smPtsRd=0
local smRes=0
local smResIn=0
local smResOut=0
local smStorHlth=0
local colWhite=Color(220,220,220,140)
local verts={
	{--long bar left side
		{["x"]=0,["y"]=0,},
		{["x"]=10,["y"]=0,},
		{["x"]=10,["y"]=SH,},
		{["x"]=0,["y"]=SH,},
	},
	{--long bar right side
		{["x"]=SW-10,["y"]=0,},
		{["x"]=SW,["y"]=0,},
		{["x"]=SW,["y"]=SH,},
		{["x"]=SW-10,["y"]=SH,},
	},
	{--draw area top left
		{["x"]=10,["y"]=0,},
		{["x"]=200,["y"]=0,},
		{["x"]=200,["y"]=220,},
		{["x"]=150,["y"]=270,},
		{["x"]=10,["y"]=270,},
	},
	{--draw area bottom left
		{["x"]=10,["y"]=SH,},
		{["x"]=200,["y"]=SH,},
		{["x"]=200,["y"]=SH-10,},
		{["x"]=150,["y"]=SH-60,},
		{["x"]=10,["y"]=SH-60,},
	},
	{--draw area top right
		{["x"]=SW-10,["y"]=0,},
		{["x"]=SW-200,["y"]=0,},
		{["x"]=SW-200,["y"]=50,},
		{["x"]=SW-150,["y"]=100,},
		{["x"]=SW-10,["y"]=100,},
	},
}

local quads={
	border={
		{--left bar
			Vector(0,0),
			Vector(10,0),
			Vector(10,SH),
			Vector(0,SH),
		},
		{--right bar
			Vector(SW-10,0),
			Vector(SW,0),
			Vector(SW,SH),
			Vector(SW-10,SH),
		},
	},
	hudbase={
		{--armor bar bg
			Vector(10,SH-50),
			Vector(147,SH-50),
			Vector(162,SH-35),
			Vector(10,SH-35),
		},
		{--health bar bg
			Vector(10,SH-30),
			Vector(166,SH-30),
			Vector(181,SH-15),
			Vector(10,SH-15),
		},
		{--resource bar bg
			Vector(10,195),
			Vector(190,195),
			Vector(190,210),
			Vector(10,210),
		},
		{--minimap bg
			Vector(10,10),
			Vector(190,10),
			Vector(190,190),
			Vector(10,190),
		},
	},
}

local verts2={
	{--armor bar background
		{["x"]=10,["y"]=SH-50,},
		{["x"]=147,["y"]=SH-50,},
		{["x"]=162,["y"]=SH-35,},
		{["x"]=10,["y"]=SH-35,},
	},
	{--health bar background
		{["x"]=10,["y"]=SH-30,},
		{["x"]=166,["y"]=SH-30,},
		{["x"]=181,["y"]=SH-15,},
		{["x"]=10,["y"]=SH-15,},
	},
	{--resource bar background
		{["x"]=10,["y"]=195,},
		{["x"]=190,["y"]=195,},
		{["x"]=190,["y"]=210,},
		{["x"]=10,["y"]=210,},
	},
	{--minimap background
		{["x"]=10,["y"]=10,},
		{["x"]=190,["y"]=10,},
		{["x"]=190,["y"]=190,},
		{["x"]=10,["y"]=190,},
	},
	{--storage health bg
		{["x"]=10,["y"]=215,},
		{["x"]=191,["y"]=215,},
		{["x"]=176,["y"]=230,},
		{["x"]=10,["y"]=230,},
	},
}

local cResourcePoint=Color(0,0,0,200)
local cBullet=Color(255,200,0,200)
local cTeams={
	[1]=Color(10,10,200,200),
	[2]=Color(200,10,10,200),
}

local CamData={
	angles=Angle(90,90,0),
	origin=Vector(0,0,5000),
	x=10,
	y=10,
	w=180,
	h=180,
	ortho=true,
	ortholeft=-4500, --14000 def
	orthoright=4500,
	orthotop=-4500,
	orthobottom=4500,
	drawhud=false,
	drawviewmodel=false,
}
local CamAddVector=Vector(0,0,5000)
local DrawOrtho=CreateClientConVar("iw_cl_drawortho", 0, true, false)
local vUp=Vector(0,0,5000)
local vSubs=Vector(0,0,30)
--[[local MinimapID=surface.GetTextureID("WeltEnSTurm/InfiniteWars/minimap")
local MinimapMat=Material("WeltEnSTurm/InfiniteWars/minimap")
local MinimapRT=GetRenderTarget("IW_MM",512,512)]]

function GM:HUDPaint()
	local pl = LocalPlayer()
	local pteam = pl:Team()
	local plpos = pl:GetPos()

	local restarttime = GetGlobalInt("restarttime")
	if !pl:Alive() or pl:Health() <= 0 then
		if restarttime < CurTime() then
			if pl:Team() == 3 then return end
			local left = math.floor(pl:GetNWInt("spawntime")-CurTime())
			local txt = ""
			if left >= 1 and left < 100 then
				txt = "Time until respawn: "..left
			else
				txt = "Prepairing to respawn..."
			end
			if txt != "" then
				draw.RoundedBox(4, SW/2-150, 15, 300, 30, purebg)
				draw.DrawText(txt, "TargetID", SW/2, 20, purewhite,1)
			end
		elseif restarttime > CurTime() then
			draw.RoundedBox(4, SW/2-150, 15, 300, 30, purebg)
			draw.DrawText("Next round start: "..math.Clamp(math.floor(restarttime-CurTime()),0, 99999), "TargetID", SW/2, 20, purewhite,1)
			return
		end
	end
--##################[Desc: Drawed when dead/round end]

	if !pl:Alive() then
		smHlth=0
		smArm=0
		smRes=0
		smStorHlth=0
		return
	end
	
	local storHlthMax=0
	local storHlth=0
	local storAmt=0
	for _,e in pairs(ents.FindByClass("stor_mass")) do
		local tm=e:GetNWInt("Team")
		if tm==pteam then
			storHlth=storHlth+e:GetNWInt("nds_health")
			storHlthMax=storHlthMax+e:GetNWInt("nds_maxhealth")
			storAmt=storAmt+1
		end
	end
	
	local maxpoints=GetGlobalFloat("MaxPoints")
	smHlth=WAC.SmoothApproach(smHlth, pl:Health()/WAC.HealthMod.mh:GetFloat(), 20)
	smArm=WAC.SmoothApproach(smArm, pl:Armor()/WAC.HealthMod.ma:GetFloat(), 20)
	smPtsBl=team.GetScore(pteam)/GetGlobalFloat("maxpoints")
	smRes=math.Clamp(WAC.SmoothApproach(smRes,GetGlobalInt("resources_team"..pteam)/GetGlobalInt("resources_max_team"..pteam),10),0,1)
	smResIn=WAC.SmoothApproach(smResIn,GetGlobalInt("resources_in_team"..pteam)/30,10)
	smResOut=WAC.SmoothApproach(smResOut,GetGlobalInt("resources_out_team"..pteam)/30,10)
	smStorHlth=math.Clamp(WAC.SmoothApproach(smStorHlth,storHlth/storHlthMax,20),0,1)
	
--##################[Health Section]
	surface.SetDrawColor(0, 0, 0, 140)
	surface.DrawRect(0,0,10,SH)
	surface.DrawRect(SW-10, 0, 10, SH)
	surface.DrawRect(10, 0, 190, 240)
	surface.DrawRect(10, SH-60, 170, 55)
	
	surface.SetDrawColor(0,0,0,60)
	surface.DrawRect(10,10,180,180)
	surface.DrawRect(10,195,180,15)
	surface.DrawRect(10,215,180,15)
	
	surface.SetDrawColor(220,220,220,140)
	surface.DrawRect(10,SH-50,160*smArm,15)
	surface.DrawRect(10,SH-30,160*smHlth,15)
	surface.DrawRect(10,195,180*smRes,15)
	draw.SimpleText(math.ceil(GetGlobalInt("resources_team"..pteam)).."/"..math.ceil(GetGlobalInt("resources_max_team"..pteam)).." ("..GetGlobalInt("resources_in_team"..pteam)-GetGlobalInt("resources_out_team"..pteam)..")","Trebuchet22",100,191,colWhite,1)
	surface.DrawRect(10,215,180*smStorHlth,15)
	draw.SimpleText("Storages: "..storAmt, "Trebuchet22", 90, 211, colWhite, 1)
	
	draw.SimpleText(pl:Armor(),"Trebuchet22",11,SH-54,colWhite)
	draw.SimpleText(pl:Health(),"Trebuchet22",11,SH-34,colWhite)
	draw.SimpleText("ARMOR","Trebuchet22",61,SH-54,colWhite)
	draw.SimpleText("HEALTH","Trebuchet22",61,SH-34,colWhite)
--####
	
--##################[Armor Section]
	local wep=pl:GetActiveWeapon()
	if wep and wep:IsValid() and !pl:InVehicle() then
		local wepc=wep:Clip1()
		local ammo=pl:GetAmmoCount(wep:GetPrimaryAmmoType())
		local w=137
		if ammo>0 or wepc>0 then
			w=0
		end
		surface.SetDrawColor(0, 0, 0, 140)
		surface.DrawRect(SW-180, SH-60, 170, 55)
		if wepc>0 then
			draw.SimpleText(wepc,"Trebuchet22",SW-11,SH-54,colWhite,2)
			draw.SimpleText("CLIP","Trebuchet22",SW-61,SH-54,colWhite,2)
		end
		if ammo>0 then
			draw.SimpleText(ammo,"Trebuchet22",SW-11,SH-34,colWhite,2)
			draw.SimpleText("AMMO","Trebuchet22",SW-61,SH-34,colWhite,2)
		end
	end
--####

--##################[Minimap]
	
	
	if DrawOrtho:GetInt()==1 then
		CamData.origin=plpos+vUp--util.QuickTrace(pl:EyePos(),vUp,pl).HitPos
		render.RenderView(CamData)
	end

	--[[local rt=render.GetRenderTarget()
	MinimapMat:SetMaterialTexture("$basetexture", MinimapRT)
	render.SetRenderTarget(MinimapRT)
	cam.Start2D()
	render.RenderView(CamData)
	cam.End2D()
	render.SetRenderTarget(rt)
	surface.SetDrawColor(255,255,255,255)
	surface.SetTexture(MinimapID)
	surface.DrawTexturedRect(10,10,400,400)]]
	
	surface.SetDrawColor(cTeams[pteam])
	surface.DrawLine(10,10,190,10)
	surface.DrawLine(190,10,190,190)
	surface.DrawLine(10,190,190,190)
	surface.DrawLine(10,10,10,190)
	surface.DrawLine(10,195,190,195)
	surface.DrawLine(10,210,190,210)
	surface.DrawLine(10,195,10,210)
	surface.DrawLine(190,195,190,210)

	surface.DrawLine(10, 215, 190, 215)
	surface.DrawLine(10, 230, 10, 215)
	surface.DrawLine(10, 230, 190, 230)
	surface.DrawLine(190, 215, 190, 230)

	surface.DrawLine(10,SH-50,170,SH-50)
	surface.DrawLine(170,SH-35,170,SH-50)
	surface.DrawLine(170,SH-35,10,SH-35)
	surface.DrawLine(10,SH-35,10,SH-50)
	surface.DrawLine(10,SH-30,170,SH-30)
	surface.DrawLine(170,SH-15,170,SH-30)
	surface.DrawLine(170,SH-15,10,SH-15)
	surface.DrawLine(10,SH-15,10,SH-30)
	
	local Radar = {mass={}}
	for _,e in pairs(ents.FindByClass("iw_masspoint")) do
		local extractor=e:GetNWEntity("extractor")
		if ValidEntity(extractor) then
			e.Team=extractor:GetNWInt("Team")
		else e.Team=0 end
		table.insert(Radar.mass,e)
	end
	local RPos={
		x=100,
		y=100,
	}
	local scale=0.02
	for k,e in pairs(Radar.mass) do
		local pos=(e:GetPos()-plpos)*scale
		local alpha=200
		if pos.x>85 or pos.x<-85 or pos.y>85 or pos.y<-85 then
			alpha=50
		end
		pos.x=math.Clamp(pos.x,-85,85)
		pos.y=math.Clamp(pos.y,-85,85)
		if e.Team>0 then
			cResourcePoint.r=((e.Team==2)and(200)or(0))
			cResourcePoint.g=10
			cResourcePoint.b=((e.Team==1)and(200)or(0))
		elseif !e.Team or e.Team!=1 or e.Team!=2 then
			cResourcePoint.r=250
			cResourcePoint.g=250
			cResourcePoint.b=250
		end
		cResourcePoint.a=alpha
		draw.RoundedBox(4,RPos.x+pos.x-4,RPos.y-pos.y-4,8,8,cResourcePoint)
	end
	for _,b in pairs(WAC.PhysBullets) do
		local pos=(b.pos-plpos)*scale
		if pos.x>87 or pos.x<-87 or pos.y>87 or pos.y<-87 then
			cBullet.a=50
		else
			cBullet.a=200
		end
		pos.x=math.Clamp(pos.x,-87,87)
		pos.y=math.Clamp(pos.y,-87,87)
		surface.SetDrawColor(cBullet)
		surface.DrawLine(RPos.x+pos.x,RPos.y-pos.y, RPos.x+pos.x+b.dir.x*3, RPos.y-pos.y-b.dir.y*3)
	end
	for _,e in pairs(ents.FindByClass("nds_w_base_bullet")) do
		if ValidEntity(e) then
			local pos=(e:GetPos()-plpos)*scale
			if pos.x>89 or pos.x<-89 or pos.y>89 or pos.y<-89 then
				cBullet.a=20
			else
				cBullet.a=200
			end
			pos.x=math.Clamp(pos.x,-89,89)
			pos.y=math.Clamp(pos.y,-89,89)
			draw.RoundedBox(2,RPos.x+pos.x-1,RPos.y-pos.y-1,2,2,cBullet)
		end
	end
	for _,e in pairs(ents.FindByClass("nds_w_rocket")) do
		if ValidEntity(e) then
			local pos=(e:GetPos()-plpos)*scale
			if pos.x>88 or pos.x<-88 or pos.y>88 or pos.y<-88 then
				cBullet.a=20
			else
				cBullet.a=200
			end
			pos.x=math.Clamp(pos.x,-88,88)
			pos.y=math.Clamp(pos.y,-88,88)
			draw.RoundedBox(2,RPos.x+pos.x-2,RPos.y-pos.y-2,4,4,cBullet)
		end
	end
	for _,p in pairs(player.GetAll()) do
		if p:Team()==pteam then
			local pview=p:GetAimVector()*2
			local ri=pview:Angle():Right()
			local left=pview-ri*1
			local right=pview+ri*1
			local pos=(p:GetPos()-plpos)*scale
			pos.x=math.Clamp(pos.x,-88,88)
			pos.y=math.Clamp(pos.y,-88,88)
			surface.SetDrawColor(TEXTCOL)
			surface.DrawLine(RPos.x+pos.x+left.x*2,RPos.y+pos.y-left.y*2,RPos.x+pos.x+left.x*10,RPos.y+pos.y+left.y*-10)
			surface.DrawLine(RPos.x+pos.y+right.x*2,RPos.y+pos.y-right.y*2,RPos.x+pos.x+right.x*10,RPos.y+pos.y+right.y*-10)
			draw.RoundedBox(4,RPos.x+pos.x-4,RPos.y-pos.y-4,8,8,TEXTCOL)
			draw.RoundedBox(4,RPos.x+pos.x-3,RPos.y-pos.y-3,6,6,cTeams[pteam])
		end
	end
	for i,Spot in pairs(SpottedPlayers) do
		if Spot and Spot.Player and Spot.Player:IsValid() then
			local p=Spot.Player
			local pview=p:GetAimVector()*2
			local ri=pview:Angle():Right()
			local left=pview-ri*1
			local right=pview+ri*1
			local pos=(p:GetPos()-plpos)*scale
			pos.x=math.Clamp(pos.x,-85,85)
			pos.y=math.Clamp(pos.y,-85,85)
			local a=cTeams[p:Team()].a
			if pos.x<-85 or pos.x>85 or pos.y<-85 or pos.y>85 then
				cTeams[p:Team()].a=a*Spot.Alpha*0.2
			else
				cTeams[p:Team()].a=a*Spot.Alpha			
			end
			surface.SetDrawColor(TEXTCOL)
			surface.DrawLine(RPos.x+pos.x+left.x*2,RPos.y+pos.y-left.y*2,RPos.x+pos.x+left.x*10,RPos.y+pos.y+left.y*-10)
			surface.DrawLine(RPos.x+pos.x+right.x*2,RPos.y+pos.y-right.y*2,RPos.x+pos.x+right.x*10,RPos.y+pos.y+right.y*-10)
			draw.RoundedBox(4,RPos.x+pos.x-4,RPos.y-pos.y-4,8,8,TEXTCOL)
			draw.RoundedBox(4,RPos.x+pos.x-3,RPos.y-pos.y-3,6,6,cTeams[p:Team()])
			cTeams[p:Team()].a=a
			Spot.Alpha=WAC.SmoothApproach(Spot.Alpha, (Spot.Time>CurTime() and Spot.Player:Alive())and(1)or(0), 20)
			if (SpottedPlayers[i].Time < CurTime() or !Spot.Player:Alive()) and Spot.Alpha <= 0.01 then
				table.remove(SpottedPlayers, i)
			end
		end
	end
end

function GM:HUDShouldDraw(n)
	if (n == "CHudHealth" or n == "CHudBattery" or n == "CHudSecondaryAmmo" or n == "CHudAmmo") then
		return false
	else
		return true
	end
end

function changesprintvar(um)
	sprintvar = um:ReadFloat()
	cansprint = um:ReadBool()
end
usermessage.Hook("ChangeSprintVar", changesprintvar)

local function SpottedPlayer(um)
	local p = um:ReadEntity()
	local lp = LocalPlayer()
	local CT = CurTime()
	--if p:Team() != lp:Team() then
		for k,t in pairs(SpottedPlayers) do
			if t.Player == p then
				t.Time = CT+10
				return
			end
		end
		local Spotted = {}
		Spotted.Time = CT+10
		Spotted.Alpha = 0
		Spotted.Player = p
		table.insert(SpottedPlayers, Spotted)
	--end
end
usermessage.Hook("SpottedEnemy", SpottedPlayer)

local function SetRedSquare(um)
end
usermessage.Hook("RedScreen", SetRedSquare)
