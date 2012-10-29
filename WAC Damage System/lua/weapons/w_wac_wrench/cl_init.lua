include("shared.lua")

SWEP.PrintName = "Wrench"
SWEP.Slot = 0
SWEP.SlotPos = 9
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.TraceArmor = 0

local seUpval=1000
local trEnt=NULL
local trVal=0
local trMaxVal=0
local trFade=0
local fintime=0
local fin=false

local colors={
	bgcol=Color(90,90,90,210),
	whcol=Color(180,180,180,220),
}

function SWEP:DrawHUD()
	local pl=LocalPlayer()
	local tr=util.QuickTrace(pl:EyePos(), pl:GetAimVector()*100, pl)
	local crt=CurTime()
	if tr.Hit and IsValid(tr.Entity) then
		trVal=tr.Entity:GetNWInt("wac_health")
		trMaxVal=tr.Entity:GetNWInt("wac_maxhealth")
		if trVal==0 or trVal==trMaxVal then
			trVal=tr.Entity:GetNWInt("wac_health_ctr")
			trMaxVal=tr.Entity:GetNWInt("wac_maxhealth_ctr")		
		end
	end
	if tr.Hit and tr.Entity and trVal>0 and trVal<trMaxVal then
		trFade=math.Clamp(trFade+10,0,100)
	elseif trFade>0 then
		trFade=math.Clamp(trFade-10,0,100)
	end
	local SW=ScrW()
	local SH=ScrH()
	if trFade>0 then
		draw.RoundedBox(4, SW-315, SH-50-trFade*0.3, 226, 35, Color(90,90,90,210*trFade/100))
		draw.RoundedBox(2, SW-310, SH-45-trFade*0.3, trVal/trMaxVal*214 + 2, 25, Color(180,180,180,220*trFade/100))
	end
	draw.RoundedBox(4, SW-315, SH-50, 226, 35, colors.bgcol)
	draw.RoundedBox(2, SW-310, SH-45, seUpval*0.214 + 2, 25, colors.whcol)
end

local function changeupval(um)
	seUpval=um:ReadFloat()
end
usermessage.Hook("wac_wrench_upval", changeupval)
