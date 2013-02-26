
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Range=2000
ENT.Damage=200
ENT.BulletSpeed=1000
ENT.BulletWeight=100
ENT.BulletRadius=30
ENT.FireRate=5
ENT.Speed=7
ENT.Height=10
ENT.Turnspeed=10
ENT.Maxturnspeed=50

ENT.FireSound="WAC/tank/T98_cannon_3p.wav"
ENT.FireSoundLevel=100

ENT.Model="models/WeltEnSTurm/RTS/tanks/tank03_body.mdl"
ENT.Mass=100

ENT.TopParts={
	turret={
		model="models/WeltEnSTurm/RTS/tanks/tank03_turret.mdl",
		pos=Vector(0,0,5.5),
	},
	gun={
		model="models/WeltEnSTurm/RTS/tanks/tank03_gun.mdl",
		pos=Vector(0,4.5,7),
	}
}

local x=CreateConVar("wacrts_x",1,{FCVAR_REPLICATED})
local y=CreateConVar("wacrts_y",50,{FCVAR_REPLICATED})

function ENT:CalculateTravel(vTarget,vVelocity)
	if vVelocity then
		vTarget=vTarget+vVelocity*3
	end
	local dist=vTarget:Distance(self.Gun:GetPos())
	local fwd=(vTarget-self:GetPos()):Normalize()
	local ang=fwd:Angle()
	ang.p=-90+math.asin(dist*0.01905*10/self.BulletSpeed*0.01905^2+dist^3/210000000000000)*360*700
	return self:GetPos()+ang:Forward()*self.Range
end

function ENT:CalculateRange()
	return self.BulletSpeed*0.01905^2/10*math.sin(2*45)*45000
end

function ENT:CalculateIdleTarget()
	return self:GetPos()+self:GetForward()*999999
end