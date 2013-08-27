include('shared.lua')     

 
local Laser=Material("cable/redlaser")
local Blue=Color(5, 5, 255, 255)

local NULLVEC=Vector(0,0,0)
function ENT:Draw()

	local e=self:GetNWEntity("ent")
	if !ValidEntity(e) or e.FullySpawned then return end
	local max=self:OBBMaxs()
	local min=self:OBBMins()
	local pos=self:GetPos()
	local ri=self:GetForward()
	local up=self:GetUp()
	local fwd=NULLVEC-self:GetRight()
	self.Smooth=WAC.SmoothApproach(self.Smooth,(min.z+(max.z-min.z)*self:GetNWFloat("progress")),50)
	local p=self.Smooth
	if p>max.z then return end
	local normal=up
	local distance = normal:Dot(pos+p*up)
	render.EnableClipping(true)
	render.PushCustomClipPlane(normal, distance)
	self:DrawModel()
	render.PopCustomClipPlane()

	local normal2=up*-1
	local distance2=normal2:Dot(pos+p*up)
	e:SetRenderClipPlaneEnabled(true)
	e:SetRenderClipPlane(normal2, distance2)

	render.SetMaterial(Laser)
	render.DrawBeam(pos+fwd*max.y+ri*max.x+up*p, pos+fwd*max.y+ri*max.x+up*max.z, 5, 0, 0, Blue)
	render.DrawBeam(pos+fwd*min.y+ri*max.x+up*p, pos+fwd*min.y+ri*max.x+up*max.z, 5, 0, 0, Blue)
	render.DrawBeam(pos+fwd*min.y+ri*min.x+up*p, pos+fwd*min.y+ri*min.x+up*max.z, 5, 0, 0, Blue)
	render.DrawBeam(pos+fwd*max.y+ri*min.x+up*p, pos+fwd*max.y+ri*min.x+up*max.z, 5, 0, 0, Blue)
	render.DrawBeam(pos+fwd*max.y+ri*max.x+up*max.z, pos+fwd*min.y+ri*max.x+up*max.z, 5, 0, 0, Blue)
	render.DrawBeam(pos+fwd*max.y+ri*min.x+up*max.z, pos+fwd*min.y+ri*min.x+up*max.z, 5, 0, 0, Blue)
	render.DrawBeam(pos+fwd*max.y+ri*max.x+up*p, pos+fwd*min.y+ri*max.x+up*p, 5, 0, 0, Blue)
	render.DrawBeam(pos+fwd*max.y+ri*min.x+up*p, pos+fwd*min.y+ri*min.x+up*p, 5, 0, 0, Blue)
	render.DrawBeam(pos+fwd*max.y+ri*max.x+up*p, pos+fwd*max.y+ri*min.x+up*p, 5, 0, 0, Blue)
	render.DrawBeam(pos+fwd*min.y+ri*max.x+up*p, pos+fwd*min.y+ri*min.x+up*p, 5, 0, 0, Blue)
	render.DrawBeam(pos+fwd*max.y+ri*max.x+up*max.z, pos+fwd*max.y+ri*min.x+up*max.z, 5, 0, 0, Blue)
	render.DrawBeam(pos+fwd*min.y+ri*max.x+up*max.z, pos+fwd*min.y+ri*min.x+up*max.z, 5, 0, 0, Blue)
end

function ENT:Initialize()
	self.Smooth=0
end

local function clearghost(um)
	local e=um:ReadEntity()
	if e and e:IsValid() then
		e:SetRenderClipPlaneEnabled(false)
		e.FullySpawned=true
	end
end
usermessage.Hook("iw_ghost_remove", clearghost)