
TOOL.Category = wac.menu.category
TOOL.Name = "Weapon Creator"
TOOL.Command=nil
TOOL.ConfigName = ""

local adminmode=CreateConVar("wac_weaponcr_adminmode", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE})

local WeaponModels={
	"models/WeltEnSTurm/NDS/tank/25mm_gun.mdl",
	"models/WeltEnSTurm/NDS/tank/m1a1_gun.mdl",
	"models/WeltEnSTurm/NDS/tank/future_gun.mdl",
	"models/WeltEnSTurm/NDS/tank/apcgun_future.mdl",
	"models/WeltEnSTurm/NDS/tank/future_gun_long.mdl",
}
for k,v in pairs(WeaponModels) do
	list.Set("wac_wep_models", v, {})
end
if (CLIENT) then
	language.Add("tool.wac_weaponcreator.name", "WAC Weapon Creator")
	language.Add("tool.wac_weaponcreator.desc", "Spawn Weapons")
	language.Add("tool.wac_weaponcreator.0", "Left: Spawn")
end

local impactsounds={
	{"no sound", ''},
	{"25mm", "25mm_impact/25mm_01.wav"},
	{"Tankshell", "WAC/tank/tank_shell_01.wav"},
	{"Tankshell Metal", "WAC/tank/tank_shell_metal_01.wav"},
	{"Mortar 1", "weapons/mortar/mortar_explode1.wav"},
	{"Mortar 2", "weapons/mortar/mortar_explode2.wav"},
	{"Mortar 3", "weapons/mortar/mortar_explode3.wav"},
	{"Grenade", "weapons/explode3.wav"},
}

local shootsounds={
	{"no sound", ''},
	{"APC LAV25", "bf2_apc_gun/lav25_cannon_1p.wav"},
	{"T98", "WAC/tank/T98_cannon_3p.wav"},
	{"SRAW", "USATP_predator/Fire_1p.wav"},
	{"Grenade Launcher", "weapons/grenade_launcher1.wav"},
	{"Stinger", "weapons/stinger_fire1.wav"},
	{"Mortar", "weapons/mortar/mortar_fire1.wav"},
	{"Stridergun", "npc/strider/fire.wav"},
	{"XXXXXX", "npc/vort/attack_shoot.wav"},
	{"Strider Minigun", "npc/strider/strider_minigun.wav"},
}

local reloadsounds={
	{"no sound", ""},
	{"T98", "WAC/tank/T98_reload.wav"},
	{"tank_readyfire", "vehicles/tank_readyfire1.wav"}
}

local effects={
	{"Tankshell", "wac_tankshell_impact"},
	{"25mm", "wac_25mm_impact"},
}

local decals={
	{"Scorch", "Scorch"},
	{"None", 0},
}

local data = {
		adminmode = 0,
		model = WeaponModels[1],
		weight = 50,
		bulletSpeed = 150,
		radius = 50,
		keyFire = 5,
		soundShoot = "WAC/tank/T98_cannon_3p.wav",
		soundReload = "WAC/tank/T98_reload.wav",
		soundExplode = "WAC/tank/Tank_Shell_01.wav",
		decal = "Scorch",
		effect = "wac_tankshell_impact",
		reloadtime = 3,
		trailx = 4,
		traily = 2,
		trailz = 0.006,
		damage = 50,
		size = 10,
		mode = 0,
		col_r = 255,
		col_g = 182,
		col_b = 74,
		dport = 0,
		msize = 1,
		shootdelay = 1,
		width = 1
}

local Data = {

	triggers = {
		adminmode = true
	},

	think = function(self, tool)
		local crt = CurTime()
		local updated = false
		if !self.lastupdate or self.lastupdate < crt + 0.5 then
			self.lastupdate = crt
			for k, v in pairs(data) do
				local value = tool:GetClientInfo(k)
				if tonumber(value) then
					value = tonumber(value)
				end
				if value != v then
					data[k] = value
					if self.triggers[k] then updated = true end
				end
			end
		end
		return updated
	end,

}

for k, v in pairs(data) do
	TOOL.ClientConVar[k] = v
end

--[[
local data={
	["adminmode"]		={2,0},
	["model"]			={1,WeaponModels[1]},
	["weight"]			={0,50},
	["bulletspeed"]		={0,150},
	["radius"]			={0,50},
	["keyFire"]			={0,5},
	["soundShoot"]		={1,"WAC/tank/T98_cannon_3p.wav"},
	["soundReload"]		={1,"WAC/tank/T98_reload.wav"},
	["soundExplode"]	={1,"WAC/tank/Tank_Shell_01.wav"},
	["Decal"]			={1,"Scorch"},
	["effect"]			={1,"wac_tankshell_impact"},
	["reloadtime"]		={0,3},
	["trailx"]				={0,4},
	["traily"]			={0,2},
	["trailz"]				={0,0.006},
	["damage"]			={0,50},
	["size"]				={0,10},
	["mode"]			={0,0},
	["col_r"]				={0,255},
	["col_g"]			={0,182},
	["col_b"]			={0,74},
	["dport"]			={0,0},
	["msize"]			={0,1},
	["shootdelay"]		={0,1},
	["width"]			={0,1},
}
]]

local presets={
	["Tank"]={
		wac_weaponcreator_model="models/WeltEnSTurm/NDS/tank/m1a1_gun.mdl",
		wac_weaponcreator_bulletspeed=70,
		wac_weaponcreator_radius=100,
		wac_weaponcreator_soundShoot="WAC/tank/T98_cannon_3p.wav",
		wac_weaponcreator_soundReload="WAC/tank/T98_reload.wav",
		wac_weaponcreator_Decal="Scorch",
		wac_weaponcreator_effect="wac_tankshell_impact",
		wac_weaponcreator_reloadtime=3,
		wac_weaponcreator_damage=100,
		wac_weaponcreator_size=10,
		wac_weaponcreator_mode=0,
		wac_weaponcreator_col_r=255,
		wac_weaponcreator_col_g=182,
		wac_weaponcreator_col_b=74,
		wac_weaponcreator_dport=0,
		wac_weaponcreator_msize=1,
		wac_weaponcreator_shootdelay=0,
		wac_weaponcreator_width=1,
	},
	["APC"]={
		wac_weaponcreator_model="models/WeltEnSTurm/NDS/tank/25mm_gun.mdl",
		wac_weaponcreator_bulletspeed=150,
		wac_weaponcreator_radius=50,
		wac_weaponcreator_soundShoot="bf2_apc_gun/lav25_cannon_1p.wav",
		wac_weaponcreator_soundReload="vehicles/tank_readyfire1.wav",
		wac_weaponcreator_Decal="0",
		wac_weaponcreator_effect="wac_25mm_impact",
		wac_weaponcreator_reloadtime=3,
		wac_weaponcreator_damage=30,
		wac_weaponcreator_size=3,
		wac_weaponcreator_mode=0,
		wac_weaponcreator_col_r=255,
		wac_weaponcreator_col_g=182,
		wac_weaponcreator_col_b=74,
		wac_weaponcreator_dport=0,
		wac_weaponcreator_shootdelay=0.3,
		wac_weaponcreator_msize=200,
		wac_weaponcreator_width=1,
	},
	["Rocketlauncher"]={
		wac_weaponcreator_model="models/WeltEnSTurm/NDS/tank/future_gun.mdl",
		wac_weaponcreator_bulletspeed=150,
		wac_weaponcreator_radius=50,
		wac_weaponcreator_soundShoot="USATP_predator/Fire_1p.wav",
		wac_weaponcreator_soundReload="",
		wac_weaponcreator_Decal="0",
		wac_weaponcreator_effect="wac_tankshell_impact",
		wac_weaponcreator_reloadtime=6,
		wac_weaponcreator_damage=100,
		wac_weaponcreator_size=3,
		wac_weaponcreator_mode=1,
		wac_weaponcreator_col_r=255,
		wac_weaponcreator_col_g=182,
		wac_weaponcreator_col_b=74,
		wac_weaponcreator_dport=0,
		wac_weaponcreator_shootdelay=0,
		wac_weaponcreator_msize=1,
		wac_weaponcreator_width=1,
	},
	["Plasma Cannon Burst"]={
		wac_weaponcreator_model="models/WeltEnSTurm/NDS/tank/future_gun_long.mdl",
		wac_weaponcreator_bulletspeed=150,
		wac_weaponcreator_radius=50,
		wac_weaponcreator_soundShoot="npc/vort/attack_shoot.wav",
		wac_weaponcreator_soundReload="",
		wac_weaponcreator_Decal="0",
		wac_weaponcreator_effect="wac_25mm_impact",
		wac_weaponcreator_reloadtime=2,
		wac_weaponcreator_damage=30,
		wac_weaponcreator_size=10,
		wac_weaponcreator_mode=2,
		wac_weaponcreator_col_r=50,
		wac_weaponcreator_col_g=0,
		wac_weaponcreator_col_b=255,
		wac_weaponcreator_dport=1,
		wac_weaponcreator_shootdelay=0.1,
		wac_weaponcreator_msize=5,
		wac_weaponcreator_width=4,
	},
	["Plasma Cannon Dual"]={
		wac_weaponcreator_model="models/WeltEnSTurm/NDS/tank/future_gun_long.mdl",
		wac_weaponcreator_bulletspeed=150,
		wac_weaponcreator_radius=50,
		wac_weaponcreator_soundShoot="npc/vort/attack_shoot.wav",
		wac_weaponcreator_soundReload="",
		wac_weaponcreator_Decal="0",
		wac_weaponcreator_effect="wac_25mm_impact",
		wac_weaponcreator_reloadtime=0.8,
		wac_weaponcreator_damage=30,
		wac_weaponcreator_size=10,
		wac_weaponcreator_mode=2,
		wac_weaponcreator_col_r=50,
		wac_weaponcreator_col_g=0,
		wac_weaponcreator_col_b=255,
		wac_weaponcreator_dport=1,
		wac_weaponcreator_shootdelay=0.1,
		wac_weaponcreator_msize=2,
		wac_weaponcreator_width=4,
	}
}

if SERVER then
	function MakeNDSWeapon(ply, Ang, Pos, t)
		local ent=ents.Create("wac_w_base")
		if !ent:IsValid() then return end
		ent:SetAngles(Ang)
		ent:SetPos(Pos)
		ent.ConTable=table.Copy(t)
		ent:SetModel(t.model)
		ent:Spawn()
		local min = ent:OBBMins()
		ent:SetPos(Pos-Ang:Up()*min.z)
		ent:SetVar("Owner",ply)
		numpad.OnDown(ply, t.keyFire, "fireGun", ent)
		numpad.OnUp(ply, t.keyFire, "stopFire", ent)
		ent.Phys = ent:GetPhysicsObject()
		if ent.Phys:IsValid() then
			ent.Phys:SetMass(t.weight)
		end
		table.Merge(ent:GetTable(), {
			dup_ang = Ang,
			dup_pos = Pos,
			dup_data = t,
		})
		return ent
	end
	duplicator.RegisterEntityClass("wac_w_base", MakeNDSWeapon, "dup_ang", "dup_pos", "dup_data")
end

function TOOL:LeftClick(tr)
	if IsValid(tr.Entity) and tr.Entity:GetClass()=="wac_w_base" then
		if SERVER then
			tr.Entity.ConTable=table.Copy(data)
			if tr.Entity.Sound then
				tr.Entity.Sound:Stop()
			end
			tr.Entity.Sound=CreateSound(tr.Entity, data.soundShoot)
		end
		return true
	elseif IsValid(self.GhostEntity) then
		if SERVER then
			local e = MakeNDSWeapon(self:GetOwner(), self.GhostEntity:GetAngles(), self.GhostEntity:GetPos(), data)
			undo.Create("wac_w_base")
			if tr.Entity:IsValid() then
				local const=constraint.Weld(e, tr.Entity,0, tr.PhysicsBone, 0, systemmanager)
				local nocollide=constraint.NoCollide(e, tr.Entity, 0, tr.PhysicsBone)
				undo.AddEntity(const)
				undo.AddEntity(nocollide)
			end
			undo.AddEntity(e)
			undo.SetPlayer(self:GetOwner())
			undo.SetCustomUndoText("Undone Weapon")
			undo.Finish()
		end
		return true
	end
end

function TOOL:RightClick(tr)
	if tr.Hit and IsValid(tr.Entity) then
		if tr.Entity:GetClass()=="wac_w_base" then
			for k,v in pairs(data) do
				if tr.Entity.ConTable[k] then
					data[k]=tr.Entity.ConTable[k]
				end
			end
			return true
		end
	end
end

function TOOL:UpdateSpawnGhost(player)
	if !IsValid(self.GhostEntity) then return end
	local trace = util.QuickTrace(player:EyePos(), player:GetAimVector()*10000, {player});
	if !trace.Hit or trace.Entity:GetClass() == "wac_w_base" then
		self.GhostEntity:Remove()
		return
	end
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	self.GhostEntity:SetAngles(Ang)
	local min = self.GhostEntity:OBBMins()
	self.GhostEntity:SetPos(trace.HitPos-trace.HitNormal*min.z)
	self.GhostEntity:SetNoDraw(false)
end

function TOOL:Think()
	if Data:think(self) and CLIENT then
		self:updatePanel()
	end
	if CLIENT then
		local power = (data.damage + data.radius)/(data.shootdelay+data.reloadtime)
		RunConsoleCommand("wac_weaponcreator_weight", power)
	end
	if !IsValid(self.GhostEntity) or self.GhostEntity:GetModel() != data.model then
		self:MakeGhostEntity(data.model, Vector(0,0,0), Angle(0,0,0))
	end	
	self:UpdateSpawnGhost(self:GetOwner())
end


if CLIENT then

	local panel

	function TOOL.BuildCPanel(p)
		panel = p
		panel:AddControl("Label", {Text = "Please wait...."})
	end

	function TOOL:updatePanel()
		panel:Clear()
		panel:AddControl("Label", {Text = "Presets"})
		panel:AddControl("ComboBox", {
			Label = "Presets",
			MenuButton = 0,
			Options = presets
		})
		panel:AddControl("Label", {Text = ""})
		panel:AddControl("PropSelect", {
			Label = "Weapon Model",
			ConVar = "wac_weaponcreator_model",
			Category = "",
			Models = list.Get("wac_wep_models")
		})
		panel:AddControl("Slider", { 
			Label = "Weight",
			Type = "Float", 
			Min = 10, 
			Max = 500,
			Command = "wac_weaponcreator_weight"
		})
		panel:AddControl("Numpad", { 
			ButtonSize = "22", 
			Label = "Fire Key",
			Command = "wac_weaponcreator_keyFire",
		})
		panel:AddControl("Label", {Text = ""})
		panel:CheckBox("Admin Mode", "wac_weaponcreator_adminmode")
		if data.adminmode==1 then
			if adminmode:GetInt()==1 then
				local combo={}
				combo.Label="Shootsound"
				combo.MenuButton = 0
				combo.Folder = "settings/wac_weaponcreator/"
				combo.Options = {}
				for k, v in pairs(shootsounds) do
					combo.Options[v[1]] = {wac_weaponcreator_soundShoot = v[2]}
				end	
				panel:AddControl("Label", {Text = ""})
				panel:AddControl("Label", {Text = "Shootsound"})
				panel:AddControl('ComboBox', combo)
				panel:AddControl("TextBox", {
					Label = "path",
					MaxLength = 300,
					Text = "path_of_sound",
					Command = "wac_weaponcreator_soundShoot",
				})
				combo={}
				combo.Label="Reloadsound"
				combo.MenuButton = 0
				combo.Folder = "settings/wac_weaponcreator/"
				combo.Options = {}
				for k, v in pairs(reloadsounds) do
					combo.Options[v[1]] = {wac_weaponcreator_soundReload = v[2]}
				end
				panel:AddControl("Label", {Text = ""})
				panel:AddControl("Label", {Text = "Reloadsound"})
				panel:AddControl('ComboBox', combo)
				panel:AddControl("TextBox", {
					Label = "path",
					MaxLength = 300,
					Text = "path_of_sound",
					Command = "wac_weaponcreator_soundReload",
				})
				combo={}
				combo.Label="Effect"
				combo.MenuButton = 0
				combo.Folder = "settings/wac_weaponcreator/"
				combo.Options = {}
				for k, v in pairs(effects) do
					combo.Options[v[1]] = {wac_weaponcreator_effect = v[2]}
				end	
				panel:AddControl("Label", {Text = ""})
				panel:AddControl("Label", {Text = "Impact Effect"})
				panel:AddControl('ComboBox', combo)
				panel:AddControl("TextBox", {
					Label = "path",
					MaxLength = 300,
					Text = "effectpath",
					Command = "wac_weaponcreator_effect",
				})
				panel:AddControl("Label", {Text = ""})
				panel:AddControl("Label", {Text = "Decal"})
				combo={}
				combo.Label="Decal"
				combo.MenuButton = 0
				combo.Folder = "settings/wac_weaponcreator/"
				combo.Options = {}
				for k, v in pairs(decals) do
					combo.Options[v[1]] = {wac_weaponcreator_decal = v[2]}
				end
				panel:AddControl('ComboBox', combo)
				panel:AddControl("TextBox", {
					Label = "Decal",
					MaxLength = 300,
					Text = "name",
					Command = "wac_weaponcreator_decal",
				})
				panel:AddControl("Slider", { 
					Label = "Explosion Radius",
					Type = "Float", 
					Min = 10, 
					Max = 200,
					Command = "wac_weaponcreator_radius"
				})
				panel:AddControl("Slider", { 
					Label = "Bullet Speed",
					Type = "Float", 
					Min = 10, 
					Max = 200,
					Command = "wac_weaponcreator_bulletspeed"
				})
				panel:AddControl("Slider", { 
					Label = "Damage",
					Type = "Float", 
					Min = 10, 
					Max = 500,
					Command = "wac_weaponcreator_damage"
				})
				panel:AddControl("Slider", { 
					Label = "Size",
					Type = "Float", 
					Min = 1, 
					Max = 50,
					Command = "wac_weaponcreator_size"
				})
				panel:AddControl("Slider", { 
					Label = "Reloadtime",
					Type = "Float", 
					Min = 1, 
					Max = 10,
					Command = "wac_weaponcreator_reloadtime"
				})
				
				panel:AddControl("Slider", { 
					Label = "Magazine Size",
					Type = "number", 
					Min = 1,
					Max = 200,
					Command = "wac_weaponcreator_msize"
				})
			else
				panel:AddControl("Label", {Text = "Adminmode must be serverside first."})				
			end
		end
	end
end
