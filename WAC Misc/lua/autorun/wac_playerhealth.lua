
include "wac/base.lua"

local FCVAR={FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}

wac.playerHealth={
	b = CreateConVar("wac_playerHealth", 1, FCVAR),
	sd = CreateConVar("wac_healthstart", 2, FCVAR),
	hr = CreateConVar("wac_healthtime", 0, FCVAR),
	ar = CreateConVar("wac_armortime", 0, FCVAR),
	ma = CreateConVar("wac_maxarmor", 0, FCVAR),
	mh = CreateConVar("wac_maxhealth", 100, FCVAR),
	nd = CreateConVar("wac_damage_npc", 1, FCVAR),
	pd = CreateConVar("wac_damage_player", 1, FCVAR),
	falldmg	= CreateConVar("wac_falldamage", 1, FCVAR),
	sound	= CreateConVar("wac_damage_customsnd", 1, FCVAR),
}

if SERVER then
	local function getVar(s)
		if !GetGlobalBool("wac_playerHealth_override") then return GetConVar(s):GetFloat() end
		return GetGlobalFloat(s)
	end

	local dsounds={}
	dsounds["police"]={
		"npc/metropolice/die1.wav",
		"npc/metropolice/die2.wav",
		"npc/metropolice/die3.wav",
		"npc/metropolice/die4.wav",
	}
	dsounds["soldier"]={
		"npc/combine_soldier/die1.wav",
		"npc/combine_soldier/die2.wav",
		"npc/combine_soldier/die3.wav",
	}
	dsounds["zombie_poison"]={
		"npc/zombie_poison/pz_die1.wav",
		"npc/zombie_poison/pz_die2.wav",
	}
	dsounds["zombie"]={
		"npc/zombie/zombie_die1.wav",
		"npc/zombie/zombie_die2.wav",
		"npc/zombie/zombie_die3.wav",
	}
	dsounds["classic"]=dsounds["zombie"]
	dsounds["female"]={
		"vo/npc/female01/pain01.wav",
		"vo/npc/female01/pain02.wav",
		"vo/npc/female01/pain03.wav",
		"vo/npc/female01/pain04.wav",
		"vo/npc/female01/pain05.wav",
		"vo/npc/female01/pain06.wav",
		"vo/npc/female01/pain07.wav",
		"vo/npc/female01/pain08.wav",
		"vo/npc/female01/pain09.wav",
	}
	dsounds["alyx"]={
		"vo/npc/alyx/hurt04.wav",
		"vo/npc/alyx/hurt05.wav",
		"vo/npc/alyx/hurt06.wav",
		"vo/npc/alyx/hurt08.wav",
	}
	dsounds["male"]={
		"vo/npc/male01/pain01.wav",
		"vo/npc/male01/pain02.wav",
		"vo/npc/male01/pain03.wav",
		"vo/npc/male01/pain04.wav",
		"vo/npc/male01/pain05.wav",
		"vo/npc/male01/pain06.wav",
		"vo/npc/male01/pain07.wav",
		"vo/npc/male01/pain08.wav",
		"vo/npc/male01/pain09.wav",		
	}
	
	wac.hook("PlayerDeathSound", "wac_damage_cdsnd_check", function()
		if wac.playerHealth.sound:GetInt()==1 then
			return true
		end
	end)
	wac.hook("PlayerDeath", "wac_damage_cdsnd_death", function(v,w,k)
		if wac.playerHealth.sound:GetInt()==1 then
			local m=v:GetModel()
			if m then
				for n,t in pairs(dsounds) do
					if string.find(m,n) then
						v:EmitSound(t[math.random(#t)])
						return
					end
				end
			end
			v:EmitSound(dsounds["male"][math.random(#dsounds["male"])])
		end
	end)
	
	wac.hook("EntityTakeDamage", "wac_playerHealth_takedamage", function(ent, info)
		if ent:IsPlayer() then
			wac.player(ent)
			ent.wac.lastDamaged=CurTime()
		end
		if getVar("wac_playerHealth")==1 then
			if info:IsFallDamage() then
				local multi = ent:GetVelocity().z/550
				info:SetDamage(10)
				info:ScaleDamage(math.abs(multi*multi*getVar("wac_falldamage")*5))
				return
			end
			if  ent:IsNPC() then
				info:ScaleDamage(getVar("wac_damage_npc"))
			elseif ent:IsPlayer() then
				info:ScaleDamage(getVar("wac_damage_player"))
			end
		end
	end)

	wac.hook("PlayerSpawn", "wac_resethealthtimers", function(p)
		wac.player(p)
		if getVar("wac_playerHealth")==1 then
			p.wac.nextHeal=0
			p.wac.nextArmorize=0
			p.wac.lastDamaged=0
			p:SetHealth(getVar("wac_maxhealth"))
			p:SetArmor(getVar("wac_maxarmor"))
		end
	end)

	wac.hook("Think", "wac_healthrecharge_think", function()
		if getVar("wac_playerHealth")==1 then
			for _, p in pairs(player.GetAll()) do
				wac.player(p)
				local tick = CurTime()
				p.wac.lastDamaged = p.wac.lastDamaged or 0
				if p.wac.lastDamaged+getVar("wac_healthstart")<tick then
				
					p.wac.nextHeal=p.wac.nextHeal or 0
					if p:Health()<getVar("wac_maxhealth") and p.wac.nextHeal<tick and getVar("wac_healthtime") != 0 then
						p:SetHealth(p:Health()+1)
						p.wac.nextHeal = tick+getVar("wac_healthtime")
					end
					
					p.wac.nextArmorize=p.wac.nextArmorize or 0
					if p:Armor()<getVar("wac_maxarmor") and p.wac.nextArmorize<tick and getVar("wac_armortime") != 0 then
						p:SetArmor(p:Armor()+1)
						p.wac.nextArmorize=tick+getVar("wac_armortime")
					end
					
				end
			end
		end
	end)

else

	wac.addMenuPanel(wac.menu.tab, wac.menu.category, "Player Health", function(panel)
		panel:CheckBox("Enable","wac_healthmod")
		panel:AddControl("Slider", {
			Label = "Regen Start Delay",
			Type = "float",
			Min = 0,
			Max = 3,
			Command = "wac_healthstart",
		})
		panel:AddControl("Slider", {
			Label = "Max Health",
			Type = "int",
			Min = 1,
			Max = 1000,
			Command = "wac_maxhealth",
		})
		panel:AddControl("Slider", {
			Label = "Health Regen Rate",
			Type = "float",
			Min = 0,
			Max = 3,
			Command = "wac_healthtime",
		})
		panel:AddControl("Slider", {
			Label = "Max Armor",
			Type = "int",
			Min = 1,
			Max = 1000,
			Command = "wac_maxarmor",
		})
		panel:AddControl("Slider", {
			Label = "Armor Regen Rate",
			Type = "float",
			Min = 0,
			Max = 3,
			Command = "wac_armortime",
		})
		panel:AddControl("Slider", {
			Label = "Damage to NPCs",
			Type = "float",
			Min = 0,
			Max = 3,
			Command = "wac_damage_npc",
		})
		panel:AddControl("Slider", {
			Label = "Damage to Players",
			Type = "float",
			Min = 0,
			Max = 3,
			Command = "wac_damage_player",
		})
		panel:AddControl("Slider", {
			Label = "Falldamage Multiplicator",
			Type = "float",
			Min = 0,
			Max = 5,
			Command = "wac_falldamage",
		})
		panel:CheckBox("Custom Death Sounds","wac_damage_customsnd")
	end)

end
