AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Upvalue = 1000
SWEP.IsInUse = 0

local showval = {}

local ShootSound = Sound("repair_loop.mp3")

function SWEP:SVRepair()
	if self.Upvalue < 50 then return end
	local tr=util.QuickTrace(self.Owner:EyePos(), self.Owner:GetAimVector()*100, self.Owner)
	if tr.Entity.Team and tr.Entity.Team==self:GetOwner():Team() then
		tr.Entity.iw_wrenchadd=5
	end
	if tr.Entity and tr.Entity.cbt and (tr.Entity.cbt.health != tr.Entity.cbt.maxhealth) then
		self.IsInUse = CurTime()
		self.Owner:EmitSound(ShootSound)
		local diff = math.Clamp(tr.Entity.cbt.maxhealth-tr.Entity.cbt.health,0,50)
		tr.Entity.cbt.health = tr.Entity.cbt.health + diff
		tr.Entity:SetNWInt("wac_health", tr.Entity.cbt.health)
		self.Upvalue = math.max(self.Upvalue - diff,0)
	elseif tr.Entity and tr.Entity.NDSctr and tr.Entity.NDSctr.cbt and (tr.Entity.NDSctr.cbt.health != tr.Entity.NDSctr.cbt.maxhealth) then
		self.IsInUse = CurTime()
		self.Owner:EmitSound(ShootSound)
		tr.Entity:SetNWInt("wac_health_ctr", tr.Entity.NDSctr.cbt.health)
		local diff = math.Clamp(tr.Entity.NDSctr.cbt.maxhealth-tr.Entity.NDSctr.cbt.health,0,100)
		tr.Entity.NDSctr.cbt.health = tr.Entity.NDSctr.cbt.health + diff
		self.Upvalue = math.max(self.Upvalue - diff,0)
	end
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:SVAddCombat()
	if self.TracedEntity and !self.TracedEntity.NDSctr then
		WAC.SimpleHit(self.TracedEntity, 1, 0)
	end
end

function SWEP:CustomThink()
	if self.IsInUse + 1.5 < CurTime() then
		self.Upvalue = math.min(self.Upvalue + 0.5, 1000)
	end
	umsg.Start("wac_wrench_upval")
	umsg.Float(self.Upvalue)
	umsg.End()
end
