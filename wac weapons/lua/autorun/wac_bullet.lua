
include "wac/base.lua"

local materials = {
	[MAT_GLASS]=4,
	[MAT_WOOD]=17,
	[MAT_CONCRETE]=14,
	[MAT_PLASTIC]=10,
	[MAT_METAL]=4,
	[MAT_SAND]=14,
	[MAT_FOLIAGE]=20,
	[MAT_COMPUTER]=10,
	[MAT_TILE]=10,
	[MAT_VENT]=10,
	[MAT_ANTLION]=7,
	[MAT_BLOODYFLESH]=7,
	[MAT_DIRT]=10,
	[MAT_FLESH]=7,
	[MAT_GRATE]=20,
	[MAT_ALIENFLESH]=7,
	[MAT_CLIP]=1,
	[MAT_ANTLION]=7,
}

local use = CreateConVar("wac_bullet_physics", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE})
local penetrate = CreateConVar("wac_bullet_penetrate", 0, {FCVAR_REPLICATED,FCVAR_ARCHIVE})

local defaultTable = {
	Num = 1,
	Spread = Vector(0,0,0),
	Tracer = 0,
	TracerName = "Tracer",
}

local bullets = {}

wac.createBullet = function(owner, damage, speed, spread, num, data)
	for i=1, num do
		local bullet = {}
		bullet.pos = owner:GetShootPos();
		bullet.dir = owner:GetAimVector():GetNormalized() + VectorRand()*spread*0.8
		bullet.dmg = damage
		bullet.speed = speed
		bullet.time = CurTime() + 5
		bullet.owner = owner
		bullet.t = table.Copy(data or defaultTable)
		umsg.Start("wac_bullet_add")
		umsg.Vector(bullet.pos)
		umsg.Vector(bullet.dir)
		umsg.Float(bullet.speed)
		umsg.Float(bullet.time)
		umsg.End()
		table.insert(bullets, bullet)
	end
end

local lastThink = 0

wac.hook("Think", "wac_bullet_think", function()
	local crt = CurTime()
	for k, b in pairs(bullets) do
		if !b then return end
		if b.time < CurTime() then
			table.remove(bullets, i)
		else
			local tr
			local mul = (use:GetBool() and 1 or 999999)
			if StarGate and StarGate.Trace then
				tr = StarGate.Trace:New(b.pos,b.dir*b.speed*(crt-lastThink)*70*mul, b.owner)
			else
				tr = util.TraceLine({
					start = b.pos,
					endpos = b.pos+b.dir*b.speed*(crt-lastThink)*70*mul,
					filter = b.owner,
					mask = MASK_SOLID + MASK_WATER
				})
			end
			if tr.Hit then
				b.t.Src = b.pos
				b.t.Dir = tr.Normal
				b.t.Force = b.dmg/6
				b.t.Damage = b.dmg
				b.owner:FireBullets(b.t)
				if use:GetInt() == 1 and tr.MatType != 83 then
					local mul = 0
					local matm = 5
					if materials[tr.MatType] then
						matm = materials[tr.MatType]
					end
					local trd = {}
					trd.start = tr.HitPos+b.dir*matm
					trd.endpos = trd.start-b.dir*matm
					local tr2 = util.TraceLine(trd)
					mul = trd.start:Distance(tr2.HitPos)
					if mul != 0 and tr2.Hit then
						b.t.Src = trd.start
						b.t.Dir = tr.Normal*-1
						b.t.Damage = 0
						b.t.Force = 0
						b.owner:FireBullets(b.t)
					end
					b.pos=tr2.HitPos+tr.Normal
					b.dmg=b.dmg*mul/matm
					if mul==0 or mul>matm or !util.IsInWorld(trd.start) then
						table.remove(bullets, k)
					end
				else
					table.remove(bullets, k)
				end
			else
				b.pos=tr.HitPos
			end
		end
	end
	lastThink = crt
end)

