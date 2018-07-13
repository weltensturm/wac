
MAX_AMMO = {
	["pistol"] = 150,
	["357"] = 12,
	["smg1"] = 225,
	["smg1_grenade"] = 3,
	["ar2"] = 60,
	["ar2altfire"] = 3,
	["buckshot"] = 30,
	["xbowbolt"] = 10,
	["rpg_round"] = 3,
	["slam"] = 5,
}

AMMO_ITEMS = {
    ["pistol"] = {"item_ammo_pistol", "item_ammo_pistol_large"},
    ["357"] = {"item_ammo_357", "item_ammo_357_large"},
    ["smg1"] = {"item_ammo_smg1", "item_ammo_smg1_large"},
    ["smg1_grenade"] = {"item_ammo_smg1_grenade"},
    ["ar2"] = {"item_ammo_ar2", "item_ammo_ar2_large"},
    ["ar2altfire"] = {"item_ammo_ar2_altfire"},
    ["buckshot"] = {"item_box_buckshot"},
    ["xbowbolt"] = {"item_ammo_crossbow"},
    ["rpg_round"] = {"item_rpg_round"},
}

WEAPON_MAP = {}

SPAWN_CLEAN = {
	"weapon_357",
	"weapon_ar2",
	"weapon_crossbow",
	"weapon_crowbar",
	"weapon_pistol",
	"weapon_physcannon",
	"weapon_rpg",
	"weapon_shotgun",
	"weapon_smg1",
	"item_suit",
}

if SERVER then

    WEAPONS_REPLACE = {
        weapon_357 = "weapon_uh_pist_python",
        weapon_ar2 = "weapon_uh_snip_g36",
        weapon_crossbow = "weapon_uh_snip_scout",
        weapon_pistol = "weapon_uh_pist_glock17",
        --weapon_rpg = ,
        weapon_shotgun = "weapon_uh_shotgun_m5",
        weapon_smg1 = "weapon_uh_smg_mp5",
    }

	local loadout_active = {}
	local suit = false

	function GM:PlayerCanPickupItem(pl, item)

		for type, items in pairs(AMMO_ITEMS) do
			for _, class in pairs(items) do
				if class == item:GetClass() then
					if pl:GetAmmoCount(type) >= MAX_AMMO[type] then
						return false
					end 
				end
			end
		end
	
		return true
	
	end
	
	function GM:PlayerCanPickupWeapon(pl, weapon) 
		if pl:Team() != TEAM_ALIVE || weapon:GetClass() == "weapon_stunstick" || (weapon:GetClass() == "weapon_physgun" && !pl:IsAdmin()) then
			weapon:Remove()
			return false
		end
		for type, max in pairs(MAX_AMMO) do
			if weapon:GetPrimaryAmmoType() == type and pl:GetAmmo(type) > max then
				return false
			end
		end
		--if pl:KeyDown(IN_USE) then return true end
		--return false
		return true
	end

	hook.Add("Think", "hl2c_loadout_think", function()
		for _, player in pairs(player.GetAll()) do
			if player:Alive() and player:Team() == TEAM_ALIVE then
				for _, weapon in pairs(player:GetWeapons()) do
					if IsValid(weapon) and weapon:GetClass() != "weapon_physgun" then
						loadout_active[weapon:GetClass()] = true
					end
				end
				if player:IsSuitEquipped() then
					suit = true
				end
			end
		end
		for from, to in pairs(WEAPON_MAP) do
			if loadout_active[from] then
				for _, class in pairs(to) do
					loadout_active[to] = true
				end
			end
		end
		for _, player in pairs(player.GetAll()) do
			if player:Alive() and player:Team() == TEAM_ALIVE then
				for class, _ in pairs(loadout_active) do
					if not player:HasWeapon(class) then
						weapon = player:Give(class)
						if weapon.SetClip1 then weapon:SetClip1(0) end
						if weapon.SetClip2 then weapon:SetClip2(0) end
					end
				end
				if suit and not player:IsSuitEquipped() then
					player:EquipSuit()
				end
			end
		end
	end)

	hook.Add("PlayerSpawn", "hl2c_loadout_playerspawn", function(pl)
		pl:Give("w_wac_hands")
		if not suit then
			pl:RemoveSuit()
		end
		if loadout_active && #loadout_active > 0 then
			for class, clips in pairs(loadout_active) do
				weapon = pl:Give(class)
				if weapon.SetClip1 then weapon:SetClip1(clips[1]) end
				if weapon.SetClip2 then weapon:SetClip2(clips[2]) end
			end
		elseif pl.info && pl.info.loadout then
			for wep, ammo in pairs(pl.info.loadout) do
				weapon = pl:Give(wep)
				if weapon.SetClip1 then weapon:SetClip1(ammo[1]) end
				if weapon.SetClip2 then weapon:SetClip2(ammo[2]) end
			end
			if pl.info.active then
				pl:SelectWeapon(pl.info.active)
			end
		end
		pl:RemoveAllAmmo()
		if pl.info and pl.info.ammo then
			for ammo, count in pairs(pl.info.ammo) do
				pl:SetAmmo(count, ammo)
			end
		end
		if GetConVarNumber("hl2c_admin_physgun") == 1 && pl:IsAdmin() then
			pl:Give("weapon_physgun")
		end
	end)

	hook.Add("InitPostEntity", "hl2c_loadout_initpostentity", function()
		print("WHAT")
		for _, spawnpoint in pairs(ents.FindByClass("item_suit")) do
			for _, ent in pairs(ents.FindInBox(spawnpoint:GetPos()-Vector(100,100,100), spawnpoint:GetPos()+Vector(100,100,100))) do
				print(ent:GetClass())
				if table.HasValue(SPAWN_CLEAN, ent:GetClass()) then
					if ent:GetClass() == "item_suit" then
						suit = true
					else
						loadout_active[ent:GetClass()] = true
					end
					ent:Remove()
				end
			end
		end
	end)

end

