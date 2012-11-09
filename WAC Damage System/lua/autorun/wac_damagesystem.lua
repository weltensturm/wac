
include "wac/base.lua"

wac.damageSystem = wac.damageSystem or {
	
	settings = {
		enable = CreateConVar("wac_damagesystem_enable", 1, FCVAR),
		damageExplosion = CreateConVar("wac_damagesystem_explosiondamage", 5, FCVAR),
		damageContraption = CreateConVar("wac_damagesystem_contraptiondamage", 0.5, FCVAR),
		damageEntity = CreateConVar("wac_damagesystem_entitydamage", 0.1, FCVAR),
		destroyMode = CreateConVar("wac_damagesystem_destroymode", 1, FCVAR),
	},
	
	explosion = function(pos, radius, amount, weapon, attacker)
		attacker = attacker or weapon
		util.BlastDamage(
			weapon,
			attacker,
			pos,
			radius*2,
			amount
		)
		local targets = ents.FindInSphere(pos, radius)
		for _,e in pairs(targets) do
			if !wac.damageSystem.validate(e) and e:IsPlayer() and e:GetViewEntity() == e then 
				local dist = e:GetPos():Distance(pos)
				umsg.Start("HitHook", e)
				umsg.Float((radius-dist)/100)
				umsg.End()
			end
		end
		local shake = ents.Create("env_shake")
		shake:SetPos(pos)
		shake:SetKeyValue("amplitude", "1000")
		shake:SetKeyValue("radius", radius)
		shake:SetKeyValue("duration", radius/100)
		shake:SetKeyValue("frequency", "255")
		shake:SetKeyValue("spawnflags", "4")
		shake:Spawn()
		shake:Activate()
		shake:Fire("StartShake", "", 0)
		timer.Simple(10, function() shake:Remove() end)
	end,
	
	destroy = function(e, attacker, inflictor)
		-- there seems to be a bug when an effect is created in this hook the game crashes
		timer.Simple(math.random(10)/100, function()
			if !wac.damageSystem.validate(e) then return end
			e.wacDamageDead = true
			local wreck = ents.Create("wac_wreck")
			wreck:SetModel(e:GetModel())
			wreck:SetAngles(e:GetAngles())
			wreck:SetPos(e:GetPos())
			local phys = e:GetPhysicsObject()
			wreck.angvel = phys:GetAngleVelocity()
			wreck.velocity = e:GetVelocity()
			wreck.mass = phys:GetMass()
			wreck:Spawn()
			wreck:Activate()
			wreck:SetMaterial(e:GetMaterial())
			wreck:Explode()
			if e:IsVehicle() and e:GetPassenger():IsValid() then
				ewa:GetPassenger():TakeDamage(9999, inflictor, attacker)
			end
			e:Remove()
		end)
	end,
	
	validate = function(e)
		if
			IsValid(e) and e:GetPhysicsObject():IsValid()
			and !(e:Health()>0) and !e:IsNPC() and e:GetModel() and !e.HasDied
			and !e.Exploded and !e:IsPlayer() and (!e.AutoSpawned or e.wac_vulnerable)
			and !e:IsWeapon() and !e.IsBullet and !e.wac_ignore
		then
			local ec = e:GetClass()
			if
				ec != "wreckedstuff" and ec != "prop_ragdoll" and ec != "wac_wreck"
				and string.find(ec,"func_")!=1 and string.find(ec, "point_")!=1
			then
				return true
			end
		end
		return false
	end,

}

local cvars = wac.damageSystem.settings

wac.hook("EntityTakeDamage", "wac_dmgsys_takedmg", function(ent, dmg)
	if cvars.enable:GetInt() != 1 or !wac.damageSystem.validate(ent) then return end
	if ent.hasdamagecase then
		ent:gcbt_breakactions()
		return
	end
	if !ent.wacDamageContraption then
		ent.wacDamageContraption = {}
		local t = ent.wacDamageContraption
		t.ents = constraint.GetAllConstrainedEntities(ent)
		t.weight = 0
		for k, e in pairs(t.ents) do
			if !e.wacDamageContraption and wac.damageSystem.validate(e) then
				e.wacDamageContraption = t
				if e:GetPhysicsObject():IsValid() then
					t.weight = t.weight + e:GetPhysicsObject():GetMass()
				end
			end
		end
		t.maxHealth = t.weight
		t.health = t.maxHealth
		ent:SetNWInt("wac_contraption_maxhealth", t.maxHealth)
		ent:SetNWInt("wac_contraption_health", t.health)
	end
	
	local damage = dmg:GetDamage() * (dmg:IsExplosionDamage() and cvars.damageExplosion:GetFloat() or 1) 
	ent.wacDamageContraption.health = ent.wacDamageContraption.health - damage*cvars.damageContraption:GetFloat()

	if ent.wacDamageContraption.health < 0 then
		if !ent.wacDamage then
			if !ent:GetPhysicsObject():IsValid() then return end
			local h = math.Clamp(ent:GetPhysicsObject():GetMass()*4, 1, 4000)
			ent.wacDamage = {
				health = h,
				maxHealth = h
			}
			ent:SetNWInt("wac_health", ent.wacDamage.health)
			ent:SetNWInt("wac_maxhealth", ent.wacDamage.maxHealth)
		end
		ent.wacDamage.health = ent.wacDamage.health
			- (damage - ent.wacDamageContraption.health)*cvars.damageEntity:GetFloat()
		if ent.wacDamage.health <= 0 then
			wac.damageSystem.destroy(ent, dmg:GetAttacker(), dmg:GetInflictor())
		end 
	else
		for k, e in pairs(ent.wacDamageContraption.ents) do
			e:SetNWInt("wac_contraption_health", ent.wacDamageContraption.health)
		end
	end
end)

