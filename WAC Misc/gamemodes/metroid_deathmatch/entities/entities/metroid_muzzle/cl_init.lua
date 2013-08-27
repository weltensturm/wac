include('shared.lua')

local lPos=Vector(0,0,0)
local lCol=Color(255, 182, 74, 255)
local lMat=Material("sprites/orangecore2")
local lAl=0

local bTable={}

function ENT:Initialize()
	self.Entity:SetRenderBounds(Vector(-100,-100,-100), Vector(100,100,100))
	timer.Simple(0.1, function() self.Weapon=self:GetNWEntity("weapon")
		self.VM=LocalPlayer():GetViewModel()
		self.aID=self.VM:LookupAttachment("muzzle")
	end)
end

local xAng=Angle(0,0,0)

function ENT:Draw()
	if !self.Weapon or !self.Weapon.Muzzle or !self.Weapon.Muzzle.Shots then return end
	
	lPos=self.VM:GetAttachment(self.aID).Pos
	lAl=math.Approach(lAl, self.Weapon.Muzzle.Shots/10, FrameTime())*100
	
	xAng.p=viewang.p
	xAng.y=viewang.y
	xAng.r=viewang.r
	xAng:RotateAroundAxis(viewang:Forward(), 90)
	xAng:RotateAroundAxis(viewang:Up(), -90)
	
	cam.Start3D2D(lPos, xAng, lAl/5)
	local crt=CurTime()*80
	local dis=0
	for i=0, 999999999999999999, 360 do
		if i>crt then
			dis=i
			break
		end
	end
	surface.SetTexture(surface.GetTextureID("sprites/orangecore2"))
	surface.SetDrawColor(Color(255,255,255,255))
	surface.DrawTexturedRectRotated(-1,1,30,30, dis-crt)
	surface.DrawTexturedRectRotated(-1,1,30,30, 360+crt-dis)
	surface.SetTexture(surface.GetTextureID("sprites/light_glow02_add"))
	surface.DrawTexturedRectRotated(-1,1,30,30, dis-crt)
	surface.DrawTexturedRectRotated(-1,1,30,30, 360+crt-dis)
	cam.End3D2D()
end