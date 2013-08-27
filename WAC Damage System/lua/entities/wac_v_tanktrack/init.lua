
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("entities/base_wire_entity/init.lua")
include("shared.lua")

function ENT:Initialize()
	math.randomseed(CurTime())
	self.Entity:SetModel("models/WeltEnSTurm/NDS/tank/tracks01.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Inputs=Wire_CreateInputs(self.Entity, {"Speed"})
	self.upVal=0
	self.snd={}
	self.snd["trks"]=CreateSound(self.Entity, "WAC/Tank/M1A2_tracks.wav")
	self.snd["trks"]:Play()
	self.snd["trks"]:ChangeVolume(0)
	self.snd["trks"]:ChangePitch(0)
	self.snd["engn"]=CreateSound(self.Entity, "vehicles/APC/apc_cruise_loop3.wav")
	self.snd["engn"]:Play()
	self.snd["engn"]:ChangeVolume(0)
	self.snd["engn"]:ChangePitch(0)
end

function ENT:OnRemove()
	self.Sounds:Stop()
end

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local ent=ents.Create("wac_v_tanktrack")
	ent:SetPos(tr.HitPos+tr.HitNormal*60)
	ent:Spawn()
	ent:Activate()
	ent.Owner=ply	
	return ent
end

local NULLVEC=Vector(0,0,0)
function ENT:PhysicsUpdate(ph)
	local pos=self:GetPos()
	local fwd=self:GetForward()
	local up=self:GetUp()
	local ri=self:GetRight()
	local trd={}
	trd.start=pos
	trd.endpos=pos-up*10
	trd.filter=self.Entity
	local tr=util.TraceLine(trd)
	trd.start=trd.start+ri*50
	trd.endpos=trd.endpos+ri*50
	local tr2=util.TraceLine(trd)
	trd.start=trd.start-ri*100
	trd.endpos=trd.endpos-ri*100
	local tr3=util.TraceLine(trd)
	local v=math.Clamp(self.Inputs["Speed"].Value,-1,1)
	self.upVal=math.Clamp(v!=0 and self.upVal+v or self.upVal-self.upVal/60, -130, 130)
	local cvel=ph:GetVelocity()
	local rvel=self:WorldToLocal(cvel+pos)
	if tr.Hit or tr2.Hit or tr3.Hit then
		local angv=ph:GetAngleVelocity()
		local ri=self:GetRight()
		local fwd=self:GetForward()
		cvel.z=0
		local angmul=self:GetAngles()
		angmul=math.abs(angmul.p)+math.abs(angmul.r)
		self.snd["trks"]:ChangeVolume(math.Clamp(math.abs(rvel.y)/36, 0, 5))
		self.snd["trks"]:ChangePitch(math.Clamp(math.abs(rvel.y)/3, 40, 100)+math.sin(CurTime()))
		ph:SetVelocity((ri*self.upVal*2+cvel*0.4)*(1-math.Clamp(angv:Length()*0.001*(1-math.Clamp(angmul/90,0,1)),0,1)))
	else
		self.snd["trks"]:ChangeVolume(0)
		self.snd["trks"]:ChangePitch(0)
	end
	self.snd["engn"]:ChangeVolume(math.Clamp((math.abs(self.upVal*3)+math.abs(rvel.y/2))/66, 1, 5))
	self.snd["engn"]:ChangePitch(math.Clamp((math.abs(self.upVal*3)+math.abs(rvel.y/2))/6, 40, 100)+math.sin(CurTime()))
end

function ENT:Think()
	self:NextThink(CurTime())
	return true
end

function ENT:OnRemove()
	for k,v in pairs(self.snd) do
		v:Stop()
	end
end