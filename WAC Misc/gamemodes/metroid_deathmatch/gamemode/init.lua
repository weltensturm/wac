
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")


function GAMEMODE:Think()
	for _,p in pairs(player.GetAll()) do
		if p:OnGround() then
			p.FirstJump=nil
			p.SecondJump=nil
		elseif p:KeyDown(IN_JUMP) then
			if !p.FirstJump then
				p.FirstJump=CurTime()
			elseif !p.SecondJump and p.FirstJump+0.2<CurTime() then
				p:SetVelocity(Vector(0,0,200-p:GetVelocity().z))
				p.SecondJump=CurTime()
			end
		end
	end
end

local Sounds={
	Beam={
		Hit="npc/strider/strider_minigun.wav"
	}
}

local bTable={}

local function dmg(b, tr)
	util.BlastDamage(b.weapon, b.owner, tr.HitPos+tr.HitNormal, 2+b.power, 2+b.power)
	tr.Entity:TakeDamage(6+b.power, b.owner, b.weapon)
	util.Decal("RedGlowFade", tr.HitPos+tr.HitNormal, tr.HitPos-tr.HitNormal)
	util.Decal("FadingScorch", tr.HitPos+tr.HitNormal, tr.HitPos-tr.HitNormal)
	WorldSound("mp2/pb_hit1.wav", tr.HitPos, 360, 130)
	local fx=EffectData()
	fx:SetStart(tr.HitPos+tr.HitNormal)
	fx:SetNormal(tr.HitNormal)
	fx:SetEntity(tr.Entity)
	fx:SetScale(b.power)
	util.Effect("metroid_beam_hit", fx)
end

function CreateMetroidBullet(pos, vec, pow, wep, own)
	local b={
		power=pow,
		vec=vec,
		pos=pos,
		speed=4500,
		owner=own,
		weapon=wep,
		time=CurTime(),
	}
	umsg.Start("clientsidebeam", own)
	umsg.Float(CurTime())
	umsg.Vector(b.pos)
	umsg.Vector(b.vec)
	umsg.Short(b.pow)
	umsg.Long(b.speed)
	umsg.End()
	table.insert(bTable, b)
end

local tr={}
local function think()
	for k, b in pairs(bTable) do
		if b.time<CurTime()-10 then
			bTable[k]=nil
		else
			if b and b.pos then
				tr=util.QuickTrace(b.pos, b.vec*b.speed*FrameTime(), b.owner)
				if tr.Hit then
					dmg(b, tr)
					bTable[k]=nil
					umsg.Start("erasebeam", b.owner)
					umsg.Float(b.time)
					umsg.End()
				else
					b.pos=b.pos+b.vec*b.speed*FrameTime()
				end
			else
				bTable[k]=nil
			end
		end
	end
end
hook.Add("Think", "bulletthink", think)