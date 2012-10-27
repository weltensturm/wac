
WAC.PhysBullets={}
local function main()
	for k,b in pairs(WAC.PhysBullets) do
		if !b then return end
		if b.time < CurTime() then
			table.remove(WAC.PhysBullets, i)
		else
			local tr
			if StarGate then
				tr=StarGate.Trace:New(b.pos,b.dir*b.speed*FrameTime()*70, b.owner)
			else
				tr=util.QuickTrace(b.pos,b.dir*b.speed*FrameTime()*70, b.owner)
			end
			if tr.Hit then
				table.remove(WAC.PhysBullets, k)
			else
				b.pos = tr.HitPos
			end
		end
	end
end
WAC.Hook("Think", "wac_physbullet_cl", main)

local function addbullet(um)
	local b={}
	b.pos=um:ReadVector()
	b.dir=um:ReadVector()
	b.speed=um:ReadFloat()
	b.time=um:ReadFloat()
	b.owner=um:ReadEntity()
	table.insert(WAC.PhysBullets,b)
end
usermessage.Hook("wac_physbullet_add", addbullet)
