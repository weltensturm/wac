
include "wac/tool.lua"

TOOL.Category = wac.menu.category
TOOL.Name = "Turret Creator"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.NextModeChange = 0

if CLIENT then
	language.Add("Tool.wac_turretcreator.name", "WAC Turret Creator")
	language.Add("Tool.wac_turretcreator.desc", "Spawn Turret Parts")
	language.Add("Tool.wac_turretcreator.0", "Left: Spawn, Right: Change Mode")
end

local models_00={
	"models/WeltEnSTurm/NDS/turret/turret03_00.mdl",
	"models/WeltEnSTurm/NDS/turret/turret04_00.mdl",
	"models/WeltEnSTurm/NDS/turret/turret05_00.mdl",
	"models/WeltEnSTurm/NDS/turret/turret06_00.mdl",
	"models/WeltEnSTurm/NDS/turret/turret08_00.mdl",
	"models/WeltEnSTurm/NDS/turret/turret09_00.mdl",
}
local models_01={
	"models/WeltEnSTurm/NDS/turret/turret03_01.mdl",
	"models/WeltEnSTurm/NDS/turret/turret04_01.mdl",
	"models/WeltEnSTurm/NDS/turret/turret04_02.mdl",
	"models/WeltEnSTurm/NDS/turret/turret05_01.mdl",
	"models/WeltEnSTurm/NDS/turret/turret05_02.mdl",
	"models/WeltEnSTurm/NDS/turret/turret06_01.mdl",
	"models/WeltEnSTurm/NDS/turret/turret06_02.mdl",
	"models/WeltEnSTurm/NDS/turret/turret09_01.mdl",
}
local models_10={
	"models/WeltEnSTurm/NDS/turret/turret03_10.mdl",
	"models/WeltEnSTurm/NDS/turret/turret03_20.mdl",
	"models/WeltEnSTurm/NDS/turret/turret05_10.mdl",
	"models/WeltEnSTurm/NDS/turret/turret03_21.mdl",
}
local models_11={
	"models/WeltEnSTurm/NDS/turret/turret05_10.mdl",
	"models/WeltEnSTurm/NDS/turret/turret03_11.mdl",
	"models/WeltEnSTurm/NDS/turret/turret03_21.mdl",
}

for k,v in pairs(models_00) do
	list.Set("wac_turret_models00", v, {})
end
for k,v in pairs(models_01) do
	list.Set("wac_turret_models01", v, {})
end
for k,v in pairs(models_10) do
	list.Set("wac_turret_models10", v, {})
end
for k,v in pairs(models_11) do
	list.Set("wac_turret_models11", v, {})
end

local movesounds={
	{"no sound", ""},
	{"tank turret", "vehicles/tank_turret_loop1.wav"}
}

local vars = {
	model00 = models_00[1],
	model01 = models_01[1],
	model10 = models_10[1],
	model11 = models_11[1],
	weight = 50,
	speed = 10,
	maxspeed = 100,
	["local"] = 0,
	spawnmode = 0,
	nosound = 0
}

for k, v in pairs(vars) do
	TOOL.ClientConVar[k] = v
end

function TOOL:LeftClick(tr)
	if !tr.Hit then return false end
	if tr.Hit and tr.Entity:GetClass()=="wac_v_turret_".. vars.spawnmode .."0" then
		if SERVER then
			tr.Entity.nosound = vars.nosound
			tr.Entity.speed = vars.speed
			tr.Entity.maxpseed = vars.maxspeed
		end
		return true
	end
	
	if SERVER then
		local e = ents.Create("wac_v_turret_" .. vars.spawnmode .. "0")
		e:SetModel(vars["model" .. vars.spawnmode .. "0"])
		e:SetAngles(self.GhostEntity:GetAngles())
		e:SetPos(self.GhostEntity:GetPos())
		e:Spawn()
		e:Activate()
		e.speed = vars.speed
		e.maxspeed = vars.maxspeed
		e.nosound = vars.nosound
		e.iLocal = vars["local"]
		e.Owner = self:GetOwner()
		e.Weight = 160-vars.maxspeed
		
		local e2 = ents.Create("wac_v_turret_"..vars.spawnmode.."1")
		e2:SetModel(vars["model"..vars.spawnmode.."1"])
		e2:SetAngles(e:GetAngles())
		e2:SetPos(e:GetPos()+e:GetUp()*e2:OBBMaxs().z*vars.spawnmode)
		e2:Spawn()
		e2:Activate()
		e2.GunBase = e
		e2.speed = vars.speed
		e2.maxspeed = vars.maxspeed
		e2.nosound = vars.nosound
		e2.iLocal = vars["local"]
		e2.Owner = self:GetOwner()

		constraint.Axis(e, e2, 0, 0, Vector(0,0,0), (vars.spawnmode==1) and Vector(0,0,1) or Vector(0,1,0), 0, 0, 0, 1)
		undo.Create("wac_turret")
		undo.AddEntity(e)
		undo.AddEntity(e2)
		if tr.Entity:IsValid() then
			local const=constraint.Weld(e, tr.Entity,0, tr.PhysicsBone, 0, systemmanager)
			local nocollide=constraint.NoCollide(e, tr.Entity, 0, tr.PhysicsBone)
			undo.AddEntity(const)
			undo.AddEntity(nocollide)
		end
		undo.SetPlayer(self:GetOwner())
		undo.SetCustomUndoText("Undone Turret")
		undo.Finish()
	end
	return true
end

function TOOL:RightClick(tr)
	if (CLIENT or game.SinglePlayer()) and self.NextModeChange<CurTime() then
		RunConsoleCommand("wac_turretcreator_spawnmode", ((vars.spawnmode == 0)and(1)or(0)))
		self.NextModeChange=CurTime()+0.1
	end
	self:updateGhost(self:GetOwner())
end

function TOOL:updateGhost(player)
	if CLIENT then return end
	local tr = util.QuickTrace(player:EyePos(), player:GetAimVector()*1000, player)
	if !tr.Hit then
		if IsValid(self.GhostEntity) then
			self.GhostEntity:Remove()
		end
		return
	end
	if !IsValid(self.GhostEntity) or self.GhostEntity:GetModel() != vars["model"..vars.spawnmode.."0"] then
		self:MakeGhostEntity(vars["model"..vars.spawnmode.."0"], Vector(0,0,0), Angle(0,0,0))
	end	
	local Ang
	if tr.Entity:GetClass()=="wac_v_turret_11" then
		Ang = tr.Entity:GetAngles()
	else
		Ang = tr.HitNormal:Angle()
		Ang.pitch = Ang.pitch+90
	end
	if tr.Entity:GetClass()=="wac_v_turret_"..vars.spawnmode.."0" then self.GhostEntity:Remove() return end
	local min = self.GhostEntity:OBBMins()
	self.GhostEntity:SetAngles(Ang)
	self.GhostEntity:SetPos(tr.HitPos+tr.HitNormal*-min.z)
	self.GhostEntity:SetNoDraw(false)
end


TOOL.settings = wac.toolSettings({
	buildPanel = function(self)
		self.panel:Clear()
		self.panel:AddControl("PropSelect", {
			Label = "Base Model",
			ConVar = "wac_turretcreator_model00",
			Category = "",
			Models = list.Get("wac_turret_models00")
		})
		self.panel:AddControl("PropSelect", {
			Label = "Top Model",
			ConVar = "wac_turretcreator_model01",
			Category = "",
			Models = list.Get("wac_turret_models01")
		})
		self.panel:AddControl("PropSelect", {
			Label = "Mount Base",
			ConVar = "wac_turretcreator_model10",
			Category = "",
			Models = list.Get("wac_turret_models10")
		})
		self.panel:AddControl("PropSelect", {
			Label = "Mount Top",
			ConVar = "wac_turretcreator_model11",
			Category = "",
			Models = list.Get("wac_turret_models11")
		})
		self.panel:AddControl("Slider", { 
			Label = "Weight",
			Type = "Float", 
			Min = 10, 
			Max = 500,
			Command = "wac_turretcreator_weight"
		})
		self.panel:AddControl("Slider", { 
			Label = "Speed",
			Type = "Float", 
			Min = 0.1, 
			Max = 8,
			Command = "wac_turretcreator_speed"
		})
		self.panel:AddControl("Slider", { 
			Label = "Max Speed",
			Type = "Float", 
			Min = 0.1, 
			Max = 150,
			Command = "wac_turretcreator_maxspeed"
		})
		self.panel:CheckBox("Local","wac_turretcreator_local")
		self.panel:CheckBox("No Sound","wac_turretcreator_nosound")
	end
}, vars)

TOOL.BuildCPanel = TOOL.settings.BuildCPanel

function TOOL:Think()
	self.settings:think(self)
	self:updateGhost(self:GetOwner())
end
