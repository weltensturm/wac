
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("entities/base_wire_entity.lua")

function ENT:Initialize()
	math.randomseed(CurTime())	
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys = self.Entity:GetPhysicsObject()
end

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal*20
	local ent = ents.Create("wac_pod_camera")
		ent:SetPos(SpawnPos)
		ent:Spawn()
		ent:Activate()
		ent.Owner = ply	
	return ent	
end

function ENT:AddVehicle(e)
	self.Vehicle=e
end

function ENT:Think()
	if self.Vehicle and self.Vehicle:IsValid() then
		local pl = self.Vehicle:GetPassenger()
		if (!pl or !pl:IsValid()) and self.Player then
			self.Player:SetViewEntity(nil)
			self:SetNWEntity("player",NULL)
			self.Player:SetNWEntity("wac_cam", self.Player)
			self.Player = nil
			return
		end
		if !pl or !pl:IsValid() then return end
		if pl:GetNWEntity("wac_cam") != self.Entity then
			self:SetNWEntity("player", pl)
			pl:SetNWEntity("wac_cam", self.Entity)
			self.Player = pl
		end
	else
		if self.Player and self.Player:IsValid() then
			self.Player:SetNWEntity("wac_cam", self.Player)
			self.Player = nil
		end
		self:SetNWEntity("player",NULL)
	end
	self:NextThink(CurTime())
	return true
end

function ENT:Remove()
end

function ENT:BuildDupeInfo()
	local info = WireLib.BuildDupeInfo(self.Entity) or {}
	if (self.Vehicle) and (self.Vehicle:IsValid()) then
		info.v = self.Vehicle:EntIndex()
	end
	return info
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	WireLib.ApplyDupeInfo(self, ply, ent, info, GetEntByID)
	if (info.v) then
		self.Vehicle = GetEntByID(info.v)
		if (!self.Vehicle) or self.Vehicle != GetEntByID(info.v) then
			self.Vehicle = ents.GetByIndex(info.v)
		end
	end
end
