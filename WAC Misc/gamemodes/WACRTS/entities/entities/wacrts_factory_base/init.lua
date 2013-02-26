
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.BuildRate=10

function ENT:Initialize()
	self.Entity:SetModel("models/WeltEnSTurm/RTS/factories/factory02.mdl")		
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local ph=self:GetPhysicsObject()
	if ph:IsValid() then
		ph:SetMass(300)
		ph:Wake()
	end
	fLastThink=0
	self.ResourcesDone=0
	self.PosAfterSpawn=self:GetPos()+self:GetForward()*100
end

function ENT:BuildUnit(s)
	if self.BuildingEnt then return end
	local e=ents.Create("wacrts_tank_"..s)
	if ValidEntity(e) then
		e:SetColor(self:GetColor())
		e:SetPos(self:GetPos()+self:GetUp()*5)
		e:SetAngles(self:GetAngles())
		e:SetOwner(self:GetOwner())
		self.BuildingEnt=e
		self.ResourcesNeeded=self.CreateableEnts[e:GetClass()].res
		e:SetNWFloat("wac_maxhealth", 1)
	end
end

function ENT:Think()
	local crt=CurTime()
	if self.BuildingEnt then
		local res=GAMEMODE:TakeResources(10*GAMEMODE.Resources.BuildRate:GetFloat()*(crt-fLastThink), self.BuildingEnt:GetOwner())
		self.ResourcesDone=self.ResourcesDone+res
		self.BuildingEnt:SetNWFloat("wac_health",self.ResourcesDone/self.ResourcesNeeded)
		if self.ResourcesDone>=self.ResourcesNeeded then
			self.BuildingEnt:Spawn()
			self.BuildingEnt:SetDesiredPos(self:GetPos()+self:GetForward()*100)
			self.BuildingEnt:SetDesiredPos(self.PosAfterSpawn)
			self.ResourcesDone=0
			self.ResourcesNeeded=0
			self.BuildingEnt:SetNWFloat("wac_maxhealth",0)
			self.BuildingEnt:SetNWFloat("wac_health",0)
			self.BuildingEnt=nil
		end
	end	
	fLastThink=CurTime()
end

function ENT:OnRemove()
	if self.BuildingEnt then
		self.BuildingEnt:Remove()
	end
end

function ENT:SetDesiredPos(pos,ang)
	self.PosAfterSpawn=pos
end

function ENT:SetTargetYaw(y) end
function ENT:ResetTargetPos() end
function ENT:SetAttackPosition(v) end
function ENT:SetTarget(ent) end
