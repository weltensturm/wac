TOOL.Category = WAC and WAC.Names.ToolCategory or "Construction"
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
	language.Add("Tool_wac_weaponcreator_name", "WAC Weapon Creator")
	language.Add("Tool_wac_weaponcreator_desc", "Spawn Weapons")
	language.Add("Tool_wac_weaponcreator_0", "Left: Spawn")
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

local convtable={
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
for k,s in pairs(convtable) do
	TOOL.ClientConVar[k]=s[2]
end

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
	function MakeNDSWeapon(ply, Ang, Pos, tbl)
		local ent=ents.Create("wac_w_base")
		if !ent:IsValid() then return end
		ent:SetAngles(Ang)
		ent:SetPos(Pos)
		ent.ConTable=table.Copy(tbl)
		ent:SetModel(ent.ConTable["model"][2])
		ent:Spawn()
		local min = ent:OBBMins()
		ent:SetPos(Pos-Ang:Up()*min.z)
		ent:SetVar("Owner",ply)
		numpad.OnDown(ply, ent.ConTable["keyFire"][2], "fireGun", ent)
		numpad.OnUp(ply, ent.ConTable["keyFire"][2], "stopFire", ent)
		ent.Phys=ent:GetPhysicsObject()
		if ent.Phys:IsValid() then
			ent.Phys:SetMass(ent.ConTable["weight"][2])
		end
		local ttable={
			Ang=Ang,
			Pos=Pos,
			ply=ply,
			tbl=ent.ConTable,
		}
		table.Merge(ent:GetTable(), ttable)
		return ent
	end
	duplicator.RegisterEntityClass("wac_w_base", MakeNDSWeapon, "Ang", "Pos", "tbl")
end

function TOOL:LeftClick(tr)
	if CLIENT then return true end
	if !tr.Hit then return end
	if ValidEntity(tr.Entity) and tr.Entity:GetClass()=="wac_w_base" then
		tr.Entity.ConTable=table.Copy(convtable)
		if tr.Entity.Sound then
			tr.Entity.Sound:Stop()
		end
		tr.Entity.Sound=CreateSound(tr.Entity, convtable["soundShoot"][2])
		return true
	end
	local ang=tr.HitNormal:Angle()
	ang.pitch=ang.pitch+90
	local e=MakeNDSWeapon(self:GetOwner(), ang, tr.HitPos, convtable)
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

function TOOL:RightClick(tr)
	if tr.Hit and ValidEntity(tr.Entity) then
		if tr.Entity:GetClass()=="wac_w_base" then
			for k,v in pairs(convtable) do
				if tr.Entity.ConTable[k] then
					convtable[k]=tr.Entity.ConTable[k]
				end
			end
		end
	end
end

if CLIENT then
	function TOOL.BuildCPanel(CPanel)
		CPanel:AddControl("Label", {Text = "Please wait...."})
	end
	local function updatepanel()
		local CPanel=GetControlPanel("wac_weaponcreator")
		CPanel:Clear()
		CPanel:AddHeader()
		CPanel:AddDefaultControls()
		CPanel:AddControl("Label", {Text = "Presets"})
		combobox={}
		combobox.Label="Presets"
		combobox.MenuButton=0
		combobox.Options = {}
		for k,v in pairs(presets) do
			combobox.Options[k]=v
		end
		CPanel:AddControl("ComboBox", combobox)
		CPanel:AddControl("Label", {Text = ""})
		CPanel:AddControl("PropSelect", {
			Label = "Weapon Model",
			ConVar = "wac_weaponcreator_model",
			Category = "",
			Models = list.Get("wac_wep_models")
		})
		CPanel:AddControl("Slider", { 
			Label = "Weight",
			Type = "Float", 
			Min = 10, 
			Max = 500,
			Command = "wac_weaponcreator_weight"
		})
		CPanel:AddControl("Numpad", { 
			ButtonSize = "22", 
			Label = "Fire Key",
			Command = "wac_weaponcreator_keyFire",
		})
		CPanel:AddControl("Label", {Text = ""})
		CPanel:CheckBox("Admin Mode", "wac_weaponcreator_adminmode")
		if convtable["adminmode"][2]==1 then
			if adminmode:GetInt()==1 then
				local combo={}
				combo.Label="Shootsound"
				combo.MenuButton = 0
				combo.Folder = "settings/wac_weaponcreator/"
				combo.Options = {}
				for k, v in pairs(shootsounds) do
					combo.Options[v[1]] = {wac_weaponcreator_soundShoot = v[2]}
				end	
				CPanel:AddControl("Label", {Text = ""})
				CPanel:AddControl("Label", {Text = "Shootsound"})
				CPanel:AddControl('ComboBox', combo)
				CPanel:AddControl("TextBox", {
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
				CPanel:AddControl("Label", {Text = ""})
				CPanel:AddControl("Label", {Text = "Reloadsound"})
				CPanel:AddControl('ComboBox', combo)
				CPanel:AddControl("TextBox", {
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
				CPanel:AddControl("Label", {Text = ""})
				CPanel:AddControl("Label", {Text = "Impact Effect"})
				CPanel:AddControl('ComboBox', combo)
				CPanel:AddControl("TextBox", {
					Label = "path",
					MaxLength = 300,
					Text = "effectpath",
					Command = "wac_weaponcreator_effect",
				})
				CPanel:AddControl("Label", {Text = ""})
				CPanel:AddControl("Label", {Text = "Decal"})
				combo={}
				combo.Label="Decal"
				combo.MenuButton = 0
				combo.Folder = "settings/wac_weaponcreator/"
				combo.Options = {}
				for k, v in pairs(decals) do
					combo.Options[v[1]] = {wac_weaponcreator_decal = v[2]}
				end
				CPanel:AddControl('ComboBox', combo)
				CPanel:AddControl("TextBox", {
					Label = "Decal",
					MaxLength = 300,
					Text = "name",
					Command = "wac_weaponcreator_decal",
				})
				CPanel:AddControl("Slider", { 
					Label = "Explosion Radius",
					Type = "Float", 
					Min = 10, 
					Max = 200,
					Command = "wac_weaponcreator_radius"
				})
				CPanel:AddControl("Slider", { 
					Label = "Bullet Speed",
					Type = "Float", 
					Min = 10, 
					Max = 200,
					Command = "wac_weaponcreator_bulletspeed"
				})
				CPanel:AddControl("Slider", { 
					Label = "Damage",
					Type = "Float", 
					Min = 10, 
					Max = 500,
					Command = "wac_weaponcreator_damage"
				})
				CPanel:AddControl("Slider", { 
					Label = "Size",
					Type = "Float", 
					Min = 1, 
					Max = 50,
					Command = "wac_weaponcreator_size"
				})
				CPanel:AddControl("Slider", { 
					Label = "Reloadtime",
					Type = "Float", 
					Min = 1, 
					Max = 10,
					Command = "wac_weaponcreator_reloadtime"
				})
				
				CPanel:AddControl("Slider", { 
					Label = "Magazine Size",
					Type = "number", 
					Min = 1,
					Max = 200,
					Command = "wac_weaponcreator_msize"
				})
			else
				CPanel:AddControl("Label", {Text = "Adminmode must be serverside first."})				
			end
		end
	end
	usermessage.Hook("UpdateNDSWeaponPanel", updatepanel)
end

function TOOL:UpdateSpawnGhost(ent, player)
	if (!ent) then return end
	if (!ent:IsValid()) then return end
	local tr = utilx.GetPlayerTrace(player, player:GetCursorAimVector())
	local trace = util.TraceLine(tr)
	if (!trace.Hit) then return end
	if trace.Hit and trace.Entity:GetClass()=="wac_w_base" then ent:Remove() return end
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	ent:SetAngles( Ang )	
	local min = ent:OBBMins()
	ent:SetPos(trace.HitPos-trace.HitNormal*min.z)
	ent:SetNoDraw(false)
end

local firstupdate=true
local oldvtable=table.Copy(convtable)
local lastupdate=0
function TOOL:Think()
	local crt=CurTime()
	if lastupdate<crt+0.3 then
		lastupdate=crt
		for k, v in pairs(convtable) do
			if v[1]==1 then
				v[2]=self:GetClientInfo(k)
			else
				v[2]=self:GetClientNumber(k)
			end
		end
	end
	if SERVER then
		if firstupdate then
			umsg.Start("UpdateNDSWeaponPanel")
			umsg.End()
			firstupdate=false
		end
		for k, v in pairs(oldvtable) do
			if v[1]==2 and v[2] != convtable[k][2] then
				umsg.Start("UpdateNDSWeaponPanel", p)
				umsg.End()
				oldvtable=table.Copy(convtable)
				break
			end
		end
	end
	local var=(convtable["damage"][2]+convtable["radius"][2])/(convtable["shootdelay"][2]+convtable["reloadtime"][2])
	if CLIENT then RunConsoleCommand("wac_weaponcreator_weight",var) end
	if (!self:GetClientInfo("model")) then return end
	local model = self:GetClientInfo("model")	
	if (!self.GhostEntity || !self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != model) then
		self:MakeGhostEntity(model, Vector(0,0,0), Angle(0,0,0))
	end	
	self:UpdateSpawnGhost(self.GhostEntity, self:GetOwner())
end

