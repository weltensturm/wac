
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("entities/base_wire_entity/init.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys=self.Entity:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:Wake()
		self.phys:SetMass(self.Weight or 50)
	end
end

 function ENT:AddVehicle(v)
	self.Vehicle=v
 end
 
function ENT:BuildDupeInfo()
	local info = WireLib.BuildDupeInfo(self.Entity) or {}
	if (self.Vehicle) and (self.Vehicle:IsValid()) then
		info.v = self.Vehicle:EntIndex()
	end
	return info
end

function ENT:OnRemove()
	if self.Top then
		self.Top:Remove()
	end
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	WireLib.ApplyDupeInfo(ply, ent, info, GetEntByID)
	if (info.v) then
		self.Vehicle = GetEntByID(info.v)
		if (!self.Vehicle) or self.Vehicle != GetEntByID(info.v) then
			self.Vehicle = ents.GetByIndex(info.v)
		end
	end
	self.Owner=ply
end
