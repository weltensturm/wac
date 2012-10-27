TOOL.Category = WAC and WAC.Names.ToolCategory or "Construction"
TOOL.Name = "Turret Creator"
TOOL.Command=nil
TOOL.ConfigName = ""
TOOL.DesiredPos=Vector(0,0,0)
TOOL.DesiredAng=Angle(0,0,0)
TOOL.NextModeChange=0

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

if (CLIENT) then
	language.Add("Tool_wac_turretcreator_name", "WAC Turret Creator")
	language.Add("Tool_wac_turretcreator_desc", "Spawn Turret Parts")
	language.Add("Tool_wac_turretcreator_0", "Left: Spawn Gunmount, Right: Spawn Turret Mount")
end

local movesounds={
	{"no sound", ""},
	{"tank turret", "vehicles/tank_turret_loop1.wav"}
}
local convtable={
	["model00"]			={1,models_00[1]},
	["model01"]			={1,models_01[1]},
	["model10"]			={1,models_10[1]},
	["model11"]			={1,models_11[1]},
	["weight"]			={0,50},
	["speed"]			={0,10},
	["maxspeed"]		={0,100},
	["local"]				={0,0},
	["spawnmode"]		={0,0},
	["nosound"]			={0,0},
}
for k,s in pairs(convtable) do
	TOOL.ClientConVar[k]=s[2]
end

local vecleft=Vector(0,1,0)
local nullvec=Vector(0,0,0)
local upvec=Vector(0,0,1)
function TOOL:LeftClick(tr)
	if CLIENT then return true end
	if !tr.Hit then return end
	if tr.Hit and tr.Entity:GetClass()=="wac_v_turret_"..convtable["spawnmode"][2].."0" then
		tr.Entity.nosound=convtable["nosound"][2]
		tr.Entity.speed=convtable["speed"][2]
		tr.Entity.maxpseed=convtable["maxspeed"][2]
		return true
	end
	local e=ents.Create("wac_v_turret_"..convtable["spawnmode"][2].."0")
	e:SetModel(convtable["model"..convtable["spawnmode"][2].."0"][2])
	e:SetAngles(self.DesiredAng)
	e:Spawn()
	local min=e:OBBMins()
	e:SetPos(tr.HitPos+tr.HitNormal*-min.z)
	e.speed=convtable["speed"][2]
	e.maxspeed=convtable["maxspeed"][2]
	e.nosound=convtable["nosound"][2]
	e.iLocal=convtable["local"][2]
	e.Owner=self:GetOwner()
	e.Weight=160-convtable["maxspeed"][2]
	local e2=ents.Create("wac_v_turret_"..convtable["spawnmode"][2].."1")
	e2:SetModel(convtable["model"..convtable["spawnmode"][2].."1"][2])
	e2:SetAngles(self.DesiredAng)
	e2:SetPos(e:GetPos()+e:GetUp()*e2:OBBMaxs().z*convtable["spawnmode"][2])
	e2:Spawn()
	e2.GunBase=e
	e2.speed=convtable["speed"][2]
	e2.maxspeed=convtable["maxspeed"][2]
	e2.nosound=convtable["nosound"][2]
	e2.iLocal=convtable["local"][2]
	e2.Owner=self:GetOwner()
	constraint.Axis(e, e2, 0, 0, nullvec, (convtable["spawnmode"][2]==1)and(upvec)or(vecleft), 0, 0, 0, 1)
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
	return true
end

function TOOL:RightClick(tr)
	if (CLIENT or SinglePlayer()) and self.NextModeChange<CurTime() then
		RunConsoleCommand("wac_turretcreator_spawnmode", ((convtable["spawnmode"][2]==0)and(1)or(0)))
		self.NextModeChange=CurTime()+0.1
	end
end

if CLIENT then
	function TOOL.BuildCPanel(CPanel)
		CPanel:AddControl("Label", {Text = "Please Wait..\nEither GMod is loading tools, or you don't have your toolgun pulled out."})
	end
	local function updatepanel()
		local CPanel=GetControlPanel("wac_turretcreator")
		CPanel:Clear()
		CPanel:AddHeader()
		CPanel:AddDefaultControls()
		CPanel:AddControl("PropSelect", {
			Label = "Base Model",
			ConVar = "wac_turretcreator_model00",
			Category = "",
			Models = list.Get("wac_turret_models00")
		})
		CPanel:AddControl("PropSelect", {
			Label = "Top Model",
			ConVar = "wac_turretcreator_model01",
			Category = "",
			Models = list.Get("wac_turret_models01")
		})
		CPanel:AddControl("PropSelect", {
			Label = "Mount Base",
			ConVar = "wac_turretcreator_model10",
			Category = "",
			Models = list.Get("wac_turret_models10")
		})
		CPanel:AddControl("PropSelect", {
			Label = "Mount Top",
			ConVar = "wac_turretcreator_model11",
			Category = "",
			Models = list.Get("wac_turret_models11")
		})
		CPanel:AddControl("Slider", { 
			Label = "Weight",
			Type = "Float", 
			Min = 10, 
			Max = 500,
			Command = "wac_turretcreator_weight"
		})
		CPanel:AddControl("Slider", { 
			Label = "Speed",
			Type = "Float", 
			Min = 0.1, 
			Max = 8,
			Command = "wac_turretcreator_speed"
		})
		CPanel:AddControl("Slider", { 
			Label = "Max Speed",
			Type = "Float", 
			Min = 0.1, 
			Max = 150,
			Command = "wac_turretcreator_maxspeed"
		})
		CPanel:CheckBox("Local","wac_turretcreator_local")
		CPanel:CheckBox("No Sound","wac_turretcreator_nosound")
	end
	usermessage.Hook("UpdateNDSTurretPanel", updatepanel)
end

function TOOL:UpdateSpawnGhost(ent, ply)
	local tr = util.TraceLine(utilx.GetPlayerTrace(ply, ply:GetCursorAimVector()))
	if (!tr.Hit) then return end
	local Ang
	if tr.Entity:GetClass()=="wac_v_turret_11" then
		Ang=tr.Entity:GetAngles()
	else
		Ang=tr.HitNormal:Angle()
		Ang.pitch = Ang.pitch+90
	end
	self.DesiredAng=Ang
	if !ValidEntity(ent) then
		return
	end
	if tr.Entity:GetClass()=="wac_v_turret_"..convtable["spawnmode"][2].."0" then ent:Remove() return end
	local min = self.GhostEntity:OBBMins()
	self.DesiredPos=tr.HitPos+tr.HitNormal*-min.z
	ent:SetAngles(self.DesiredAng)
	ent:SetPos(self.DesiredPos)
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
			umsg.Start("UpdateNDSTurretPanel")
			umsg.End()
			firstupdate=false
		end
		for k, v in pairs(oldvtable) do
			if v[1]==2 and v[2] != convtable[k][2] then
				umsg.Start("UpdateNDSTurretPanel", p)
				umsg.End()
				oldvtable=table.Copy(convtable)
				break
			end
		end
	end
	if CLIENT then RunConsoleCommand("wac_turretcreator_weight",160-convtable["maxspeed"][2]) end
	if (!self:GetClientInfo("model"..convtable["spawnmode"][2].."0")) then return end
	local model = self:GetClientInfo("model"..convtable["spawnmode"][2].."0")	
	if (!self.GhostEntity or !self.GhostEntity:IsValid() or self.GhostEntity:GetModel() != model) then
		self:MakeGhostEntity(model, Vector(0,0,0), Angle(0,0,0))
	end	
	self:UpdateSpawnGhost(self.GhostEntity, self:GetOwner())
end

