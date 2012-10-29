
local UsePhysBullets = CreateConVar("wac_physbullets", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE})
local b2=CreateConVar("wac_physbullets_penetrate", 0, {FCVAR_REPLICATED,FCVAR_ARCHIVE})

WAC.PhysBullets = {}

local PENETR_MATS={
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


local deftable={
	Num=1,
	Spread=Vector(0,0,0),
	Tracer=0,
	TracerName="Tracer",
}

function WAC.CreatePhysBullet(start, dir, dmg, speed, spread, owner, num, btable)
	for i=1, num do
		local bullet = {}
		bullet.pos = start
		bullet.dir = dir:Normalize() + VectorRand()*spread*0.8
		bullet.dmg = dmg
		bullet.speed = speed
		bullet.time = CurTime() + 5
		bullet.owner = owner
		bullet.t=table.Copy(btable or deftable)
		umsg.Start("wac_physbullet_add")
		umsg.Vector(bullet.pos)
		umsg.Vector(bullet.dir)
		umsg.Float(bullet.speed)
		umsg.Float(bullet.time)
		umsg.End()
		table.insert(WAC.PhysBullets, bullet)
	end
	WAC.ThinkBullets()
end

local trd={}
local lastth=0
function WAC.ThinkBullets()
	local crt=CurTime()
	for k,b in pairs(WAC.PhysBullets) do
		if !b then return end
		if b.time < CurTime() then
			table.remove(WAC.PhysBullets, i)
		else
			local tr
			local mul=(UsePhysBullets:GetFloat()==0 and 999999 or 1)
			if StarGate and StarGate.Trace then
				tr=StarGate.Trace:New(b.pos,b.dir*b.speed*(crt-lastth)*70*mul, b.owner)
			else
				local trd={}
				trd.start=b.pos
				trd.endpos=b.pos+b.dir*b.speed*(crt-lastth)*70*mul
				trd.filter=b.owner
				trd.mask=MASK_SOLID+MASK_WATER--util.QuickTrace(b.pos,b.dir*b.speed*(crt-lastth)*70*mul, b.owner)
				tr=util.TraceLine(trd)
			end
			if tr.Hit then
				b.t.Src 		= b.pos
				b.t.Dir 		= tr.Normal
				b.t.Force	=b.dmg/2
				b.t.Damage	=b.dmg
				b.owner:FireBullets(b.t)
				if b2:GetInt()==1 and tr.MatType!=83 then
					local mul=0
					local matm=5
					if PENETR_MATS[tr.MatType] then
						matm=PENETR_MATS[tr.MatType]
					end
					trd.start=tr.HitPos+b.dir*matm
					trd.endpos=trd.start-b.dir*matm
					local tr2=util.TraceLine(trd)
					mul=trd.start:Distance(tr2.HitPos)
					if mul!=0 and tr2.Hit then
						b.t.Src		=trd.start
						b.t.Dir		=tr.Normal*-1
						b.t.Damage	=0
						b.t.Force	=0
						b.owner:FireBullets(b.t)
					end
					b.pos=tr2.HitPos+tr.Normal
					b.dmg=b.dmg*mul/matm
					if mul==0 or mul>matm or !util.IsInWorld(trd.start) then
						table.remove(WAC.PhysBullets, k)
					end
				else
					table.remove(WAC.PhysBullets, k)
				end
			else
				b.pos=tr.HitPos
			end
		end
	end
	lastth=crt
end
wac.hook("Think", "wac_physbullets_think", WAC.ThinkBullets)
