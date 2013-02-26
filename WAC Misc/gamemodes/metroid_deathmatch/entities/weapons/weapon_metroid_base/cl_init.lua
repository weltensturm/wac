include("shared.lua")

local weapon = nil
local AddRecoil = nil
local zoomed = nil
local VMAngles = Angle(0,0,0)
local punchView

local function FindAim(user)
	VMAngles = user:GetViewAngles()
	local self=LocalPlayer():GetActiveWeapon()
	if !self or !self.Muzzle or !(type(self.Muzzle)=="table") then return end
	if punchView then
		punchView=nil
		self.Muzzle.Alpha=200
		user:SetViewAngles(Angle(VMAngles.p+math.random(-0.1,0.1), VMAngles.y+math.random(-0.1,0.1), VMAngles.r))
	end
end
hook.Add("CreateMove", "metroid_findaim", FindAim)

local function viewRecoil(um)
	punchView=true
end
usermessage.Hook("m_recoil", viewRecoil)

local DrawTable={
	WHITE=Color(255,255,255,255),
	SPR={
		MAT=Material("sprites/orangecore2"),
		COL=Color(255,182,74,255),
	},
	HUD={
		MAT1=surface.GetTextureID("WeltEnSTurm/weapons/powerbeam/hud1"),
		MAT2=surface.GetTextureID("WeltEnSTurm/weapons/powerbeam/hud2"),
		MAT3=surface.GetTextureID("WeltEnSTurm/weapons/METROID_overlay"),
	}
}

local lPOS=Vector(0,0,0)
local lCOLOR=Color(255, 182, 74, 255)
local lMATERIAL=Material("sprites/light_glow02_add")

local bTable={}
function SWEP:DrawHUD()
	local PL = LocalPlayer()
	if (zoomed and !self.DrawZoomedCrosshair) or !(self.DrawCustomCrosshair) or PL:InVehicle() then return end
	
	local SW=ScrW()
	local SH=ScrH()
	
	local tr = util.QuickTrace(PL:GetShootPos()+self.Owner:GetRight()*5+self.Owner:GetUp()*-2, PL:GetAimVector()*163842, PL)

	local HitW=(tr.Hit
	and tr.HitPos:ToScreen().x
	or SW/2)	
	local HitH=(tr.Hit
	and tr.HitPos:ToScreen().y
	or SH/2)

	self.Muzzle.Shots=self:GetNWInt("shots")

	self.Muzzle.Alpha=(self.Muzzle.Alpha>0
	and self.Muzzle.Alpha-26
	or 0)
	
	local xLerp=(SW/2-HitW)/20
	local yLerp=(SH/2-HitH)/20

	surface.SetTexture(DrawTable.HUD.MAT1)
	surface.SetDrawColor(DrawTable.WHITE)
	surface.DrawTexturedRect(HitW-4, HitH-4, 8, 8)
	
	surface.SetTexture(DrawTable.HUD.MAT2)
	surface.SetDrawColor(DrawTable.WHITE)
	surface.DrawTexturedRectRotated(HitW, HitH-18, 8, 16, 0)
	surface.DrawTexturedRectRotated(HitW-16, HitH+10, 8, 16, 120)
	surface.DrawTexturedRectRotated(HitW+16, HitH+10, 8, 16, 240)
	

	render.SetMaterial(lMATERIAL)
	cam.Start3D(LocalPlayer():EyePos(), viewang)
	for _, b in pairs(bTable) do
		render.DrawSprite(b.pos, 13+b.pow*2, 13+b.pow*2, lCOLOR)
		render.DrawSprite(b.pos, 14+b.pow*2, 14+b.pow*2, lCOLOR)
		render.DrawSprite(b.pos, 15+b.pow*2, 15+b.pow*2, lCOLOR)
		b.pos=b.pos+b.dir*b.speed*FrameTime()
	end
	cam.End3D()
end

local function GetBeamData(um)
	local b={
		time=um:ReadFloat(),
		pos=um:ReadVector(),
		dir=um:ReadVector(),
		pow=um:ReadShort(),
		speed=um:ReadLong(),
	}
	table.insert(bTable, b)
end
usermessage.Hook("clientsidebeam", GetBeamData)

local function EraseBeam(um)
	local t=um:ReadFloat()
	for k, b in pairs(bTable) do
		if b.time==t then
			bTable[k]=nil
		end
	end
end
usermessage.Hook("erasebeam", EraseBeam)


local viewtime=0
local f_smZ=0
local f_smHs=0
local f_smGr=0
local v_smSpd=Vector(0,0,0)
local v_smWall=Vector(0,0,0)
local a_smAng={p=0,y=0,r=0}
local a_smAngAdd=Angle(0,0,0)
local VMPosMax		= Vector(3, 0, 5)
local VMPosM			= Vector(0.08, 0.05, 0.05)*0.5
local VMPosMz			= Vector(0.08, 0.05, 0.05)*0.5
local VMPosOffset		= Vector(0,0,0)
local VMPosD			= Vector(0.15, 0.15, 0.15)
local VMPosDz			= Vector(0.16, 0.16, 0.16)*2
local VMPosMaxz		= Vector(4, 0, 4)
local VMAngM			= Vector(0.4, 0.4, 0)*0
local VMAngMax		= Vector(0, 0, 0)
local VMPosAdd 		= Vector(0,0,0)
local VMAngAdd 		= Angle(0,0,0)
local VMAngAddO	 	= Angle(0,0,0)

local function SmoothVars(lvel, self, FrT, crt, tr, pvel, vang, ang, flp)
	viewtime = viewtime+math.Clamp(lvel/150,0,2)*FrT+0.0001
	f_smGr=WAC.SmoothApproach(f_smGr, (self.Owner:OnGround())and(1)or(0), 50, 15)
	a_smAng.p=WAC.SmoothApproach(a_smAng.p, VMAngAdd.p, 150, 200)
	a_smAng.y=WAC.SmoothApproach(a_smAng.y, VMAngAdd.y, 150, 200)
	a_smAng.r=WAC.SmoothApproach(a_smAng.r, VMAngAdd.r, 150, 200)
	WAC.SmoothApproachVector(v_smWall, tr.StartPos+tr.Normal*23-tr.HitPos, 25)
	WAC.SmoothApproachVector(v_smSpd, pvel, 25)
	v_smSpd.x=math.Clamp(v_smSpd.x,-700,700)
	v_smSpd.y=math.Clamp(v_smSpd.y,-700,700)
	v_smSpd.z=math.Clamp(v_smSpd.z,-700,700)
	a_smAngAdd.p=WAC.SmoothApproach(a_smAngAdd.p, math.AngleDifference(vang.p,ang.p), 50)
	a_smAngAdd.y=WAC.SmoothApproach(a_smAngAdd.y, math.AngleDifference(vang.y,ang.y)*flp, 50)
end

local view={}
local viewang
local oldang
local function SetViewAngles(p, pos, ang, fov)
	local pl=LocalPlayer()
	local self=p:GetActiveWeapon()
	if p:InVehicle() or p:GetViewEntity() != p then return end
	local vel=pl:GetVelocity()
	local lvel=vel:Length()
	local FrT=FrameTime()
	local crt = CurTime()
	viewang=viewang or ang
	oldang=oldang or ang
	local PDiff = math.AngleDifference(viewang.p, ang.p)
	local YDiff = math.AngleDifference(viewang.y, ang.y)
	local aPDiff=math.AngleDifference(oldang.p,ang.p)
	local aYDiff=math.AngleDifference(oldang.y,ang.y)
	viewang.p = viewang.p-((PDiff*math.Clamp(math.abs(PDiff),.001,50)*0.01)*(1-f_smZ)+(PDiff*math.Clamp(math.abs(PDiff),.001,5)*0.1)*f_smZ)
	viewang.y = viewang.y-((YDiff*math.Clamp(math.abs(YDiff),.001,50)*0.01)*(1-f_smZ)+(YDiff*math.Clamp(math.abs(YDiff),.001,5)*0.1)*f_smZ)
	VMPosAdd.x = math.Clamp(VMPosAdd.x - (1-math.abs(VMPosAdd.x)/VMPosMax.x)*aYDiff*(VMPosM.x*(1-f_smZ)+VMPosMz.x*f_smZ)*math.Clamp(70-math.abs(ang.p),-30,30)/30 - VMPosAdd.x*(VMPosD.x*(1-f_smZ)+VMPosDz.x*f_smZ), -(VMPosMax.x*(1-f_smZ)+VMPosMaxz.x*f_smZ), VMPosMax.x*(1-f_smZ)+VMPosMaxz.x*f_smZ)
	VMPosAdd.z = math.Clamp(VMPosAdd.z - (1-math.abs(VMPosAdd.z)/VMPosMax.z)*aPDiff*(VMPosM.z*(1-f_smZ)+VMPosMz.z*f_smZ)*math.Clamp(70-math.abs(ang.p),-30,30)/30 - VMPosAdd.z*(VMPosD.z*(1-f_smZ)+VMPosDz.z*f_smZ), -(VMPosMax.z*(1-f_smZ)+VMPosMaxz.z*f_smZ), VMPosMax.z*(1-f_smZ)+VMPosMaxz.z*f_smZ)
	if (f_smZ >= 0.9 and self:Zoomed() and self.ZoomOverlay and !self.__zmFull) then
		self.__zmFull = true
		self.zoomBlack=255
		pl:GetViewModel():SetNoDraw(true)
	elseif self.__zmFull and f_smZ < 0.9 then
		self.__zmFull = false
		pl:GetViewModel():SetNoDraw(false)
	end
	local ri = viewang:Right()
	local up = viewang:Up()
	local fwd = viewang:Forward()
	local VMFlip = (self.ViewModelFlip)and(-1)or(1)
	local VMFlop = 0-VMFlip
	local pvel=pl:WorldToLocal(pl:GetPos()+vel)
	local tr=util.QuickTrace(pos,ang:Forward()*23,self.Owner)
	SmoothVars(lvel, self, FrT, crt, tr, pvel, viewang, ang, VMFlip)
	view.origin=pos
	local vmang=viewang-a_smAngAdd*0.7
	vmang=vmang+Angle(a_smAng.p, a_smAng.y*VMFlip, 0)
	pos=pos+ri*(VMPosOffset.x+VMPosAdd.x*VMFlip + VMFlip*(VMAngAdd.y)*0.1)
	pos=pos+fwd*(VMPosOffset.y+VMPosAdd.y)
	pos=pos+up*(VMPosOffset.z+VMPosAdd.z-v_smSpd:Length()*0.002 +(VMAngAdd.p)*0.1)
	pos=pos+v_smSpd*0.001
	view.angles=viewang+Angle(0,0,v_smSpd.y*-0.015)*(lvel/300)*f_smGr
	view.vm_angles=vmang
	view.vm_origin=pos-v_smWall*(1-f_smZ)
	return view
end
WAC.Hook("CalcView", "nds_self_alt_view", SetViewAngles)
