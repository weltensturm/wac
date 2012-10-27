
local FCVAR={FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}

WAC.Damage={}
WAC.Damage.CVars={
	Enable 		=CreateConVar("wac_dmgsys_enable", "1", 	FCVAR),
	DMul		=CreateConVar("wac_dmgsys_mul", "1", 		FCVAR),
	DMulS		=CreateConVar("wac_dmgsys_mul_s", "0.5", 	FCVAR),
	DMGByNW	=CreateConVar("wac_dmgsys_mul_nw", 0.1, 	FCVAR),
	DdMode	=CreateConVar("wac_dmgsys_deathmode", 1,FCVAR),
}

function WAC.ResetHitEffect(p)
	umsg.Start("HitHook", p)
	umsg.Float(0)
	umsg.End()
end
WAC.Hook("PlayerSpawn", "wac_dmgsys_resetblur", WAC.ResetHitEffect)


function WAC.Validate(e)
	if (e and IsEntity(e) and e:IsValid() and e:GetPhysicsObject():IsValid() and !(e:Health()>0) and !e:IsNPC() and e:GetModel() and !e.HasDied and !e.Exploded and !e:IsPlayer() and (!e.AutoSpawned or e.wac_vulnerable) and !e:IsWeapon() and !e.IsBullet and !e.wac_ignore) then
		local ec = e:GetClass()
		if (ec != "wreckedstuff" and ec != "prop_ragdoll" and ec != "wac_wreck" and string.find(ec,"func_")!=1 and string.find(ec, "point_")!=1) then
			return true
		end
	end
	return false
end

function WAC.HitX(ent, dmg, prc, wep, att)
	if WAC.Damage.CVars.Enable:GetInt() != 1 then return end
	if !WAC.Validate(ent) then return end
	if ent.hasdamagecase then
		ent:gcbt_breakactions()
		return
	end
	if !ent.NDSctr then
		ent.NDSctr=constraint.GetAllConstrainedEntities(ent)
	end
	if ent.NDSctr and !ent.NDSctr.cbt then
		local contrapionweight=0
		for _,e in pairs(ent.NDSctr) do
			if WAC.Validate(e) and !e.NDSctr then
				e.NDSctr = ent.NDSctr
				local ph = e:GetPhysicsObject()
				if ph and ph:IsValid() then
					contrapionweight = contrapionweight + ph:GetMass()
				end
			end
		end
		if !ent.NDSctr.cbt then
			ent.NDSctr.cbt={}
			ent.NDSctr.cbt.health=contrapionweight
			ent.NDSctr.cbt.maxhealth=contrapionweight
			ent:SetNWInt("wac_ctr_health", contrapionweight)
			ent:SetNWInt("wac_ctr_Maxhealth", contrapionweight)
		end
	end
	local diff=ent.NDSctr.cbt.health-dmg*WAC.Damage.CVars.DMulS:GetFloat()
	if diff<0 then
		WAC.Damage.NormalHit(ent, dmg*WAC.Damage.CVars.DMul:GetFloat(), prc, wep, att)
	else
		ent.NDSctr.cbt.health = diff
		ent:SetNWInt("wac_ctr_health", contrapionweight)
	end
end

function WAC.Damage.NormalHit(ent, dmg, prc, wep, att)
	if !ent.cbt then	
		local h = ent:GetPhysicsObject():GetMass() * 4
		ent.cbt = {}
		ent.cbt.health = math.Clamp(h, 1, 4000)
		ent.cbt.armor = 8
		ent.cbt.maxhealth = math.Clamp(h, 1, 4000)
		ent:SetNWInt("wac_health", ent.cbt.health)
		ent:SetNWInt("wac_maxhealth", ent.cbt.maxhealth)
	end	
	if ent.cbt then
		if dmg > ent.cbt.health then
			WAC.Damage.WreckIt(ent, wep, att)
		else
			ent.cbt.health = ent.cbt.health - dmg
			ent:SetNWInt("wac_health", ent.cbt.health)
		end
	end
end

function WAC.Damage.SimpleHit(ent, dmg, prc, wep, att)
	if !WAC.Validate(ent) then return end
	local contrapionweight = 0
	if !ent.NDSctr then
		ent.NDSctr = constraint.GetAllConstrainedEntities(ent)
	end
	if ent.NDSctr or (ent.NDSctr and !ent.NDSctr.cbt) then
		for _,e in pairs(ent.NDSctr) do
			if WAC.Validate(e) then
				e.NDSctr = ent.NDSctr
				local ph = e:GetPhysicsObject()
				if ph and ph:IsValid() then
					contrapionweight = contrapionweight + ph:GetMass()
				end
			end
		end
		if !ent.NDSctr.cbt then
			ent.NDSctr.cbt = {}
			ent.NDSctr.cbt.health = contrapionweight
			ent.NDSctr.cbt.maxhealth = contrapionweight
			ent:SetNWInt("wac_health_ctr", ent.cbt.health)
			ent:SetNWInt("wac_maxhealth_ctr", ent.cbt.maxhealth)
		end
	end
	local diff = ent.NDSctr.cbt.health - dmg/2
	if diff < 0 then
		WAC.NormalHit(ent, dmg*10, prc, wep, att)
	else
		ent.NDSctr.cbt.health = diff
		ent:SetNWInt("wac_health_ctr", diff)
	end
end

function WAC.Damage.WreckIt(ent, wep, att)
	timer.Simple(math.random(10)/100, function()
		if WAC.Validate(ent) then
			ent.HasDied = true
			local wreck = ents.Create("wac_wreck")
			wreck:SetModel(ent:GetModel())
			wreck:SetAngles(ent:GetAngles())
			wreck:SetPos(ent:GetPos())
			ent.phys = ent.phys or ent:GetPhysicsObject()
			wreck.angvel = ent.phys:GetAngleVelocity()
			wreck.velocity = ent:GetVelocity()
			wreck.mass = ent.phys:GetMass()
			wreck:Spawn()
			wreck:Activate()
			wreck:SetMaterial(ent:GetMaterial())
			wreck:Explode()
			if ent:IsVehicle() and ent:GetPassenger():IsValid() then ent:GetPassenger():TakeDamage(999,wep,att) end
			ent:Remove()
		end
	end)
end

function WAC.SimpleSplode(pos, rad, dmg, prc, igtr, wep, att)
	if !att then att=wep end
	util.BlastDamage(wep, att, pos, rad*2, dmg)
	local targets = ents.FindInSphere(pos, rad)
	for _,e in pairs(targets) do
		if !WAC.Validate(e) and e:IsPlayer() and e:GetViewEntity() == e then 
			local dist = e:GetPos():Distance(pos)
			umsg.Start("HitHook", e)
			umsg.Float((rad-dist)/100)
			umsg.End()
		end
	end
	local shake = ents.Create("env_shake")
	shake:SetPos(pos)
	shake:SetKeyValue("amplitude", "1000")
	shake:SetKeyValue("radius", rad)
	shake:SetKeyValue("duration", rad/100)
	shake:SetKeyValue("frequency", "255")
	shake:SetKeyValue("spawnflags", "4")
	shake:Spawn()
	shake:Activate()
	shake:Fire("StartShake", "", 0)
	timer.Simple(10, function() shake:Remove() end)
end

function WAC.Hit() end

WAC.Hook("EntityTakeDamage", "wac_dmgsys_takedmg", 
	function(ent, wep, att, amt, dmg)
		if !dmg:IsExplosionDamage() then
			amt = amt*WAC.Damage.CVars.DMGByNW:GetFloat()
		end
		WAC.HitX(ent, amt, 3.5, wep, att)
	end
)

