
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	math.randomseed(CurTime())
	self.Entity:SetModel("models/WeltEnSTurm/BF2/bf2_physbullet.mdl")		
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys = self.Entity:GetPhysicsObject()
	if self.phys:IsValid() then
		self.phys:Wake()
		self.phys:EnableDrag(false)
	end
	self:SetNotSolid(true)
	self.cbt={}
	self.cbt.health=5000
	self.cbt.armor=500
	self.cbt.maxhealth=5000
	self:SetNWInt("size", 5)
	self:SetNWFloat("width", 1)
	local col=Color(255,100,10,255)
	self:SetColor(col.r,col.g,col.b,col.a)
	col.a=50
	local trail=util.SpriteTrail(self.Entity, 0, col, false, 5, 0, 0.2, 1, "trails/smoke.vmt")
	self:NextThink(CurTime())
	self.oldpos=self:GetPos()
end


function ENT:PhysicsUpdate(ph)
	if !util.IsInWorld(self:GetPos()) then self:Remove() end
	local pos=self:GetPos()
	local difference = pos-self.oldpos
	self.oldpos = pos
	local tr=util.QuickTrace(pos-difference,difference,self.Entity)
	if tr.Hit then
		if self.Exploded then return end
		self.Exploded=true
		for _,e in pairs(ents.FindInSphere(tr.HitPos,self.Radius)) do
			if !e.IsRTSUnit and e.Tank and ValidEntity(e) then
				e:TakeDamage(self.Damage,self.Entity)
				e=e.Tank
			end
			if ValidEntity(e) then
				e:TakeDamage(self.Damage,self.Entity)
			end
		end
		self:SetPos(tr.HitPos)
		local ed = EffectData()
		ed:SetOrigin(tr.HitPos)
		ed:SetStart(tr.HitPos)
		ed:SetAngle(Angle(0,0,0))
		ed:SetScale(self.Radius)
		util.Effect("PropSplode", ed)
		self:Remove()
	end
end

function ENT:Think()
	self.phys:Wake()
end
