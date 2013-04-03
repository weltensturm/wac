<<<<<<< HEAD

include "wac/tool.lua"

TOOL.Category = 'Construction'
TOOL.Name = 'Gravity Controller'
TOOL.Command = nil
TOOL.ConfigName = ''

if CLIENT then
	language.Add("tool.wac_gravitycontroller.name", "Gravity Controller")
	language.Add("tool.wac_gravitycontroller.desc", "Create hovering wizard machines.")
	language.Add("tool.wac_gravitycontroller.0", "Click on where you want to create one")
	language.Add('undone_wac_gravitycontroller', 'Gravity Controller Undone')
	language.Add('cleanup_wac_gravitycontroller', 'Gravity Controller')
	language.Add('cleaned_wac_gravitycontroller', 'Cleaned up all Gravity Controllers')
	language.Add('SBoxLimit_wac_gravitycontroller', 'Maximum amount of Gravity Controllers reached')
end

TOOL.models = {
	{ 'Teapot', 'models/props_interiors/pot01a.mdl' },
	{ 'Spacegate Powernode', 'models/Col Sheppard/spacegate.mdl' },
	{ 'Pot', 'models/props_interiors/pot02a.mdl' },
	{ 'Skull', 'models/Gibs/HGIBS.mdl' },
	{ 'Clock', 'models/props_c17/clock01.mdl' },
	{ 'Hula Doll', 'models/props_lab/huladoll.mdl' },
	{ 'Hover Drive', 'models//props_c17/utilityconducter001.mdl' },
	{ 'Big Hover Drive', 'models/props_wasteland/laundry_washer003.mdl' },
	{ 'SpacegatePowernode', 'models/Cebt/sga_pwnode.mdl' },
}

TOOL.List = "GravControllerModels"
list.Set(TOOL.List,"models/props_docks/dock01_cleat01a.mdl",{})
list.Set(TOOL.List,"models/props_junk/plasticbucket001a.mdl",{})
list.Set(TOOL.List,"models/props_junk/propanecanister001a.mdl",{})
list.Set(TOOL.List,"models/props_wasteland/laundry_washer003.mdl",{})
list.Set(TOOL.List,"models/props_wasteland/laundry_washer001a.mdl",{})
list.Set(TOOL.List,"models/props_lab/huladoll.mdl",{})
list.Set(TOOL.List,"models/props_trainstation/trashcan_indoor001a.mdl",{})
list.Set(TOOL.List,"models/props_c17/clock01.mdl",{})
list.Set(TOOL.List,"models/props_phx/construct/metal_plate1.mdl",{})
list.Set(TOOL.List,"models/props_combine/breenclock.mdl",{})
list.Set(TOOL.List,"models/props_combine/breenglobe.mdl",{})
list.Set(TOOL.List,"models/props_interiors/pot01a.mdl",{})
list.Set(TOOL.List,"models/props_junk/metal_paintcan001a.mdl",{})
list.Set(TOOL.List,"models/props_junk/popcan01a.mdl",{})
list.Set(TOOL.List,"models/Col Sheppard/spacegate.mdl",{})
list.Set(TOOL.List,"models/Cebt/sga_pwnode.mdl",{})


local loopsounds = {
	{'no sound', ''},
	{'scanner', 'npc/scanner/combat_scan_loop2.wav'},
	{'heli rotor', 'NPC_CombineGunship.RotorSound'},
	{'energy shield', 'ambient/machines/combine_shield_loop3.wav'},
	{'dog idlemode', 'npc/dog/dog_idlemode_loop1.wav'},
	{'dropship', 'npc/combine_gunship/dropship_engine_distant_loop1.wav'},
	{'subway hall 1', 'ambient/atmosphere/undercity_loop1.wav'},
	{'subway hall 2', 'ambient/atmosphere/underground_hall_loop1.wav'},
	{'forcefield', 'ambient/energy/force_field_loop1.wav'},
	{'engine rotor', 'npc/combine_gunship/engine_rotor_loop1.wav'}	
}

TOOL.ClientConVar = {
	keyActivate = 0,
	brakeX = 15,
	brakeY = 15,
	brakeZ = 15,
	brakeMul = 10,
	model = "models/props_c17/utilityconducter001.mdl",
	sound = "ambient/atmosphere/underground_hall_loop1.wav",
	pitchMul = 1,
	brakeAng = 0,
	brakeGlobal = 1,
	drawSprite = 1,
	brakeAlways = 0,
	brakeOnly = 0,
	keyUp = 7,
	keyDown = 4,
	keyHover = 1,
	hoverSpeed = 1,
	descHover = 1,
	descLocal = 1,
	brakeAngMul = 20,
	weight = 0,
	relativeToGround = 0,
	heightAboveGround = 30,
	stargateNode = 0,
	liveGravity = 0
}

local vars = TOOL.ClientConVar


local sgapowernd = {
	[1]={-135, 0, 180},
	[2]={68, 118, -60},
	[3]={68, -118, 60}
}

function TOOL:LeftClick(trace)
	if !IsValid(self.GhostEntity) or (trace.Entity && trace.Entity:IsPlayer()) then return false end
	if(CLIENT) then
		return true
	end
	if(!SERVER) then return false end
	local ply = self:GetOwner()
	local pos = self.GhostEntity:GetPos()
	local ang = self.GhostEntity:GetAngles()
	undo.Create('wac_gravitycontroller')
	if trace.Entity and trace.Entity:IsValid() and self.ClientConVar.stargateNode == 1 and trace.Entity.IsStargate then
		trace.Entity.GCTable=trace.Entity.GCTable or {}
		for i=1,3 do
			if !trace.Entity.GCTable[i] or !trace.Entity.GCTable[i]:IsValid() then
				local ent=MakeGravitycontroller(ply, ang, pos, convtable)
				ent:SetPos(trace.Entity:GetPos()+trace.Entity:GetUp()*(sgapowernd[i][1]) - trace.Entity:GetRight()*(sgapowernd[i][2]))
				local ang=trace.Entity:GetAngles()
				ang:RotateAroundAxis(trace.Entity:GetUp(), 90)
				ang:RotateAroundAxis(trace.Entity:GetForward(), sgapowernd[i][3])
				ent:SetAngles(ang)
				trace.Entity.GCTable[i]=ent
				undo.AddEntity(ent)
				local const=constraint.Weld(ent, trace.Entity,0, trace.PhysicsBone, 0, systemmanager)
				local nocollide=constraint.NoCollide( ent, trace.Entity, 0, trace.PhysicsBone)
				undo.AddEntity(const)
				undo.AddEntity(nocollide)
			end
		end
	else
		if (trace.Entity:IsValid() && trace.Entity:GetClass()=="wac_gravitycontroller") then
			trace.Entity.ConTable=table.Copy(self.ClientConVar)
			if !trace.Entity.phys then
				trace.Entity.phys = trace.Entity:GetPhysicsObject()
			end
			if trace.Entity.phys:IsValid() and self.ClientConVar.weight != 0 then
				trace.Entity.phys:SetMass(math.Clamp(self.ClientConVar.weight, 1, 500))
			end
			if trace.Entity.Sound then
				trace.Entity.Sound:Stop()
				trace.Entity.Sound=CreateSound(trace.Entity, self.ClientConVar.sound)
				if trace.Entity.Active then
					trace.Entity.Sound:Play()
				end
			end
			return true
		end
		local ent = MakeGravitycontroller(ply, ang, pos, self.ClientConVar)
		ent:SetPos(trace.HitPos - trace.HitNormal * ent:OBBMins().z)
		if (trace.Entity:IsValid()) then
			local const = constraint.Weld(ent, trace.Entity,0, trace.PhysicsBone, 0, systemmanager)
			local nocollide = constraint.NoCollide( ent, trace.Entity, 0, trace.PhysicsBone)
			undo.AddEntity(const)
			undo.AddEntity(nocollide)
		end
		undo.AddEntity(ent)
	end
	undo.SetPlayer(ply)
	undo.Finish()
	return true
end


if SERVER then 
    CreateConVar('sbox_maxgravitycontroller', 6)
	function MakeGravitycontroller(ply, ang, pos, data)
		local ent = ents.Create('wac_gravitycontroller')
		if !ent:IsValid() then return false end
		ent:SetAngles(ang)
		ent:SetPos(pos)
		ent.vars = table.Copy(data)
		ent:Spawn()
		ent:SetVar('Owner',ply)
		numpad.OnDown(ply, data.keyActivate, 'FireGravitycontroller', ent)
		if data.stargateNode != 1 then
			if data.weight > 1 then
				ent:GetPhysicsObject():SetMass(data.weight)
			end
			numpad.OnDown(ply, data.keyHover, 'ToggleHoverMode', ent)
			numpad.OnDown(ply, data.keyUp, 'GoUp', ent)
			numpad.OnDown(ply, data.keyDown, 'GoDown', ent)
			numpad.OnUp(ply, data.keyUp, 'GoStop', ent)
			numpad.OnUp(ply, data.keyDown, 'GoStop', ent)
			ent.StartVector = ent:WorldToLocal(pos-Vector(0,0,1))
			ent:SetNWVector("startvector", ent.StartVector)
		else
			ent:GetPhysicsObject():SetMass(200)
		end
		table.Merge(ent:GetTable(), {
			ang = ang,
			pos = pos,
			ply = ply,
			data = data,
		})
		ply:AddCount('gravcontroller', ent)	
		ent:Activate()	
		return ent
	end
	duplicator.RegisterEntityClass("wac_gravitycontroller", MakeGravitycontroller, "ang", "pos", "data")
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
	if !IsValid(self.GhostEntity) or self.GhostEntity:GetModel() != vars.model then
		self:MakeGhostEntity(vars.model, Vector(0,0,0), Angle(0,0,0))
	end
	local Ang = tr.HitNormal:Angle()
	Ang.pitch = Ang.pitch+90
	if tr.Entity:GetClass()=="wac_gravitycontroller" then self.GhostEntity:Remove() return end
	local min = self.GhostEntity:OBBMins()
	self.GhostEntity:SetAngles(Ang)
	self.GhostEntity:SetPos(tr.HitPos+tr.HitNormal*-min.z)
	self.GhostEntity:SetNoDraw(false)
end


TOOL.settings = wac.toolSettings({
	buildPanel = function(self)
		self.panel:Clear()
		self.panel:AddControl("PropSelect", {
			Label = "Model",
			ConVar = "wac_gravitycontroller_model",
			Category = "",
			Models = list.Get("GravControllerModels")
		})
		self.panel:AddControl("TextBox", {
			Label = "Modelpath",
			MaxLength = 300,
			Text = "path_of_model.mdl",
			Command = "wac_gravitycontroller_model",
		})
		combo = {
			Label = 'Sound',
			MenuButton = 0,
			Folder = "settings/gravitycontroller/",
			Options = {}
		}
		for k, v in pairs(loopsounds) do
			combo.Options[v[1]] = {gravitycontroller_sound = v[2]}
		end	
		self.panel:AddControl("Label", {Text = ""})
		self.panel:AddControl("Label", {Text = "Sound"})
		self.panel:AddControl('ComboBox', combo)
		self.panel:AddControl('Slider', {
			Label = 'Sound Pitch',
			Type = "Float", 
			Min = 0,
			Max = 1, 
			Command = 'wac_gravitycontroller_pitchMul'
		})

		self.panel:AddControl("TextBox", {
			Label = "Soundpath",
			MaxLength = 300,
			Text = "path_of_sound",
			Command = "wac_gravitycontroller_sound",
		})
		self.panel:AddControl("Label", {Text = ""})
		self.panel:CheckBox("Glow","wac_gravitycontroller_drawSprite")
		if vars.stargateNode != 1 then
			self.panel:AddControl('Slider', {
				Label = 'Weight (0: Model Default)',
				Type = "Float", 
				Min = 0,
				Max = 500, 
				Command = 'wac_gravitycontroller_weight'
			})
			self.panel:AddControl("Label", {Text = ""})
			self.panel:CheckBox("Brake Only (Don't change gravity)","wac_gravitycontroller_brakeOnly")
			self.panel:CheckBox("Always Brake","wac_gravitycontroller_brakeAlways")
			self.panel:CheckBox("Global Airbrake","wac_gravitycontroller_brakeGlobal")
			if vars.brakeGlobal == 0 then
				self.panel:AddControl('Slider', { 
					Label = 'Brake X', 
					Type = "Float", 
					Min = 0, 
					Max = 100, 
					Command = 'wac_gravitycontroller_brakeX' 
				})
				self.panel:AddControl('Slider', { 
					Label = 'Brake Y', 
					Type = "Float", 
					Min = 0, 
					Max = 100, 
					Command = 'wac_gravitycontroller_brakeY' 
				})
				self.panel:AddControl('Slider', { 
					Label = 'Brake Z', 
					Type = "Float", 
					Min = 0, 
					Max = 100, 
					Command = 'wac_gravitycontroller_brakeZ' 
				})
			else
				self.panel:AddControl('Slider', { 
					Label = 'Global Brake', 
					Type = "Float", 
					Min = 0, 
					Max = 100, 
					Command = "wac_gravitycontroller_brakeMul" 
				})
			end	
			self.panel:CheckBox("Angle Brake (buggy sometimes)","wac_gravitycontroller_brakeAng")
			if vars.brakeAng == 1 then
				self.panel:AddControl('Slider', { 
					Label = 'Angle Brake', 
					Type = "Float", 
					Min = 0, 
					Max = 100, 
					Command = "wac_gravitycontroller_brakeAngMul" 
				})		
			end
			self.panel:AddControl("Label", {Text = ""})
			self.panel:AddControl("Numpad", { 
				ButtonSize = "22", 
				Label = "Activate", 
				Command = "wac_gravitycontroller_keyActivate",
				Label2 = 'Hovermode',
				Command2 = "wac_gravitycontroller_keyHover",
			})
			if vars.relativeToGround == 0 then
				self.panel:AddControl('Numpad', { 
					ButtonSize = '22', 
					Label = 'Hover Up', 
					Command = "wac_gravitycontroller_keyUp",
					Label2 = 'Hover Down',
					Command2 = "wac_gravitycontroller_keyDown",
				})
			end
			self.panel:AddControl("Slider", { 
				Label = "Hover Speed",
				Type = "Float", 
				Min = 0.01, 
				Max = 10,
				Command = "wac_gravitycontroller_hoverSpeed"
			})
			self.panel:CheckBox("Hover relative to ground","wac_gravitycontroller_relativeToGround")
			if vars.relativeToGround == 1 then		
				self.panel:AddControl("Slider", { 
					Label = "Height above ground",
					Type = "Float", 
					Min = 1, 
					Max = 100,
					Command = "wac_gravitycontroller_heightAboveGround"
				})
			end
			self.panel:AddControl("Label", {Text = ""})
			self.panel:CheckBox("Hovermode Description","wac_gravitycontroller_descHover")
			if vars.descHover == 1 then
				self.panel:AddControl("Label", {Text = "The GC will act like a hoverball. It will automatically balance all GC's from a contrapion. That means, once activated, everyone of them will have the same target height. So be sure they are all on the same height when you add them to your ship!"})
			end
			self.panel:CheckBox("Local Brake Description","wac_gravitycontroller_descLocal")
			if vars.descLocal == 1 then
				self.panel:AddControl("Label", {Text = "If you enable that, the GC will brake seperate on every axis. If you set every but one axis to 100, it will 'slide' along that axis. So if you want your ship not to brake as hard forward as it should sideways or upwards, this is for you!"})
			end
		else
			self.panel:AddControl("Label", {Text = ""})
			self.panel:AddControl("Numpad", {
				ButtonSize = "22",
				Label = "Activate",
				Command = "wac_gravitycontroller_keyActivate",
			})			
		end
		self.panel:CheckBox("SGA Powernode Mode","wac_gravitycontroller_stargateNode")
	end,

	trigger = {
		"stargateNode", "brakeGlobal", "brakeAng", "relativeToGround", "descLocal", "descHover"
	},

}, vars)

TOOL.BuildCPanel = TOOL.settings.BuildCPanel

function TOOL:Think()
	self.settings:think(self);
	self:updateGhost(self:GetOwner())
end

=======

include "wac/tool.lua"

TOOL.Category = 'Construction'
TOOL.Name = 'Gravity Controller'
TOOL.Command = nil
TOOL.ConfigName = ''

if CLIENT then
	language.Add("tool.wac_gravitycontroller.name", "Gravity Controller")
	language.Add("tool.wac_gravitycontroller.desc", "Create hovering wizard machines.")
	language.Add("tool.wac_gravitycontroller.0", "Click on where you want to create one")
	language.Add('undone_wac_gravitycontroller', 'Gravity Controller Undone')
	language.Add('cleanup_wac_gravitycontroller', 'Gravity Controller')
	language.Add('cleaned_wac_gravitycontroller', 'Cleaned up all Gravity Controllers')
	language.Add('SBoxLimit_wac_gravitycontroller', 'Maximum amount of Gravity Controllers reached')
end

TOOL.models = {
	{ 'Teapot', 'models/props_interiors/pot01a.mdl' },
	{ 'Spacegate Powernode', 'models/Col Sheppard/spacegate.mdl' },
	{ 'Pot', 'models/props_interiors/pot02a.mdl' },
	{ 'Skull', 'models/Gibs/HGIBS.mdl' },
	{ 'Clock', 'models/props_c17/clock01.mdl' },
	{ 'Hula Doll', 'models/props_lab/huladoll.mdl' },
	{ 'Hover Drive', 'models//props_c17/utilityconducter001.mdl' },
	{ 'Big Hover Drive', 'models/props_wasteland/laundry_washer003.mdl' },
	{ 'SpacegatePowernode', 'models/Cebt/sga_pwnode.mdl' },
}

TOOL.List = "GravControllerModels"
list.Set(TOOL.List,"models/props_docks/dock01_cleat01a.mdl",{})
list.Set(TOOL.List,"models/props_junk/plasticbucket001a.mdl",{})
list.Set(TOOL.List,"models/props_junk/propanecanister001a.mdl",{})
list.Set(TOOL.List,"models/props_wasteland/laundry_washer003.mdl",{})
list.Set(TOOL.List,"models/props_wasteland/laundry_washer001a.mdl",{})
list.Set(TOOL.List,"models/props_lab/huladoll.mdl",{})
list.Set(TOOL.List,"models/props_trainstation/trashcan_indoor001a.mdl",{})
list.Set(TOOL.List,"models/props_c17/clock01.mdl",{})
list.Set(TOOL.List,"models/props_phx/construct/metal_plate1.mdl",{})
list.Set(TOOL.List,"models/props_combine/breenclock.mdl",{})
list.Set(TOOL.List,"models/props_combine/breenglobe.mdl",{})
list.Set(TOOL.List,"models/props_interiors/pot01a.mdl",{})
list.Set(TOOL.List,"models/props_junk/metal_paintcan001a.mdl",{})
list.Set(TOOL.List,"models/props_junk/popcan01a.mdl",{})
list.Set(TOOL.List,"models/Col Sheppard/spacegate.mdl",{})
list.Set(TOOL.List,"models/Cebt/sga_pwnode.mdl",{})


local loopsounds = {
	{'no sound', ''},
	{'scanner', 'npc/scanner/combat_scan_loop2.wav'},
	{'heli rotor', 'NPC_CombineGunship.RotorSound'},
	{'energy shield', 'ambient/machines/combine_shield_loop3.wav'},
	{'dog idlemode', 'npc/dog/dog_idlemode_loop1.wav'},
	{'dropship', 'npc/combine_gunship/dropship_engine_distant_loop1.wav'},
	{'subway hall 1', 'ambient/atmosphere/undercity_loop1.wav'},
	{'subway hall 2', 'ambient/atmosphere/underground_hall_loop1.wav'},
	{'forcefield', 'ambient/energy/force_field_loop1.wav'},
	{'engine rotor', 'npc/combine_gunship/engine_rotor_loop1.wav'}	
}

TOOL.ClientConVar = {
	keyActivate = 0,
	brakeX = 15,
	brakeY = 15,
	brakeZ = 15,
	brakeMul = 10,
	model = "models/props_c17/utilityconducter001.mdl",
	sound = "ambient/atmosphere/underground_hall_loop1.wav",
	pitchMul = 1,
	brakeAng = 0,
	brakeGlobal = 1,
	drawSprite = 1,
	brakeAlways = 0,
	brakeOnly = 0,
	keyUp = 7,
	keyDown = 4,
	keyHover = 1,
	hoverSpeed = 1,
	descHover = 1,
	descLocal = 1,
	brakeAngMul = 20,
	weight = 0,
	relativeToGround = 0,
	heightAboveGround = 30,
	stargateNode = 0,
	liveGravity = 0
}

local vars = TOOL.ClientConVar


local sgapowernd = {
	[1]={-135, 0, 180},
	[2]={68, 118, -60},
	[3]={68, -118, 60}
}

function TOOL:LeftClick(trace)
	if !IsValid(self.GhostEntity) or (trace.Entity && trace.Entity:IsPlayer()) then return false end
	if(CLIENT) then
		return true
	end
	if(!SERVER) then return false end
	local ply = self:GetOwner()
	local pos = self.GhostEntity:GetPos()
	local ang = self.GhostEntity:GetAngles()
	undo.Create('wac_gravitycontroller')
	if trace.Entity and trace.Entity:IsValid() and self.ClientConVar.stargateNode == 1 and trace.Entity.IsStargate then
		trace.Entity.GCTable=trace.Entity.GCTable or {}
		for i=1,3 do
			if !trace.Entity.GCTable[i] or !trace.Entity.GCTable[i]:IsValid() then
				local ent=MakeGravitycontroller(ply, ang, pos, convtable)
				ent:SetPos(trace.Entity:GetPos()+trace.Entity:GetUp()*(sgapowernd[i][1]) - trace.Entity:GetRight()*(sgapowernd[i][2]))
				local ang=trace.Entity:GetAngles()
				ang:RotateAroundAxis(trace.Entity:GetUp(), 90)
				ang:RotateAroundAxis(trace.Entity:GetForward(), sgapowernd[i][3])
				ent:SetAngles(ang)
				trace.Entity.GCTable[i]=ent
				undo.AddEntity(ent)
				local const=constraint.Weld(ent, trace.Entity,0, trace.PhysicsBone, 0, systemmanager)
				local nocollide=constraint.NoCollide( ent, trace.Entity, 0, trace.PhysicsBone)
				undo.AddEntity(const)
				undo.AddEntity(nocollide)
			end
		end
	else
		if (trace.Entity:IsValid() && trace.Entity:GetClass()=="wac_gravitycontroller") then
			trace.Entity.ConTable=table.Copy(self.ClientConVar)
			if !trace.Entity.phys then
				trace.Entity.phys = trace.Entity:GetPhysicsObject()
			end
			if trace.Entity.phys:IsValid() and self.ClientConVar.weight != 0 then
				trace.Entity.phys:SetMass(math.Clamp(self.ClientConVar.weight, 1, 500))
			end
			if trace.Entity.Sound then
				trace.Entity.Sound:Stop()
				trace.Entity.Sound=CreateSound(trace.Entity, self.ClientConVar.sound)
				if trace.Entity.Active then
					trace.Entity.Sound:Play()
				end
			end
			return true
		end
		local ent = MakeGravitycontroller(ply, ang, pos, self.ClientConVar)
		ent:SetPos(trace.HitPos - trace.HitNormal * ent:OBBMins().z)
		if (trace.Entity:IsValid()) then
			local const = constraint.Weld(ent, trace.Entity,0, trace.PhysicsBone, 0, systemmanager)
			local nocollide = constraint.NoCollide( ent, trace.Entity, 0, trace.PhysicsBone)
			undo.AddEntity(const)
			undo.AddEntity(nocollide)
		end
		undo.AddEntity(ent)
	end
	undo.SetPlayer(ply)
	undo.Finish()
	return true
end


if SERVER then 
    CreateConVar('sbox_maxgravitycontroller', 6)
	function MakeGravitycontroller(ply, ang, pos, data)
		local ent = ents.Create('wac_gravitycontroller')
		if !ent:IsValid() then return false end
		ent:SetAngles(ang)
		ent:SetPos(pos)
		ent.vars = table.Copy(data)
		ent:Spawn()
		ent:SetVar('Owner',ply)
		numpad.OnDown(ply, data.keyActivate, 'FireGravitycontroller', ent)
		if data.stargateNode != 1 then
			if data.weight > 1 then
				ent:GetPhysicsObject():SetMass(data.weight)
			end
			numpad.OnDown(ply, data.keyHover, 'ToggleHoverMode', ent)
			numpad.OnDown(ply, data.keyUp, 'GoUp', ent)
			numpad.OnDown(ply, data.keyDown, 'GoDown', ent)
			numpad.OnUp(ply, data.keyUp, 'GoStop', ent)
			numpad.OnUp(ply, data.keyDown, 'GoStop', ent)
			ent.StartVector = ent:WorldToLocal(pos-Vector(0,0,1))
			ent:SetNWVector("startvector", ent.StartVector)
		else
			ent:GetPhysicsObject():SetMass(200)
		end
		table.Merge(ent:GetTable(), {
			ang = ang,
			pos = pos,
			ply = ply,
			data = data,
		})
		ply:AddCount('gravcontroller', ent)	
		ent:Activate()	
		return ent
	end
	duplicator.RegisterEntityClass("wac_gravitycontroller", MakeGravitycontroller, "ang", "pos", "data")
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
	if !IsValid(self.GhostEntity) or self.GhostEntity:GetModel() != vars.model then
		self:MakeGhostEntity(vars.model, Vector(0,0,0), Angle(0,0,0))
	end
	local Ang = tr.HitNormal:Angle()
	Ang.pitch = Ang.pitch+90
	if tr.Entity:GetClass()=="wac_gravitycontroller" then self.GhostEntity:Remove() return end
	local min = self.GhostEntity:OBBMins()
	self.GhostEntity:SetAngles(Ang)
	self.GhostEntity:SetPos(tr.HitPos+tr.HitNormal*-min.z)
	self.GhostEntity:SetNoDraw(false)
end


TOOL.settings = wac.toolSettings({
	buildPanel = function(self)
		self.panel:Clear()
		self.panel:AddControl("PropSelect", {
			Label = "Model",
			ConVar = "wac_gravitycontroller_model",
			Category = "",
			Models = list.Get("GravControllerModels")
		})
		self.panel:AddControl("TextBox", {
			Label = "Modelpath",
			MaxLength = 300,
			Text = "path_of_model.mdl",
			Command = "wac_gravitycontroller_model",
		})
		combo = {
			Label = 'Sound',
			MenuButton = 0,
			Folder = "settings/gravitycontroller/",
			Options = {}
		}
		for k, v in pairs(loopsounds) do
			combo.Options[v[1]] = {gravitycontroller_sound = v[2]}
		end	
		self.panel:AddControl("Label", {Text = ""})
		self.panel:AddControl("Label", {Text = "Sound"})
		self.panel:AddControl('ComboBox', combo)
		self.panel:AddControl('Slider', {
			Label = 'Sound Pitch',
			Type = "Float", 
			Min = 0,
			Max = 1, 
			Command = 'wac_gravitycontroller_pitchMul'
		})

		self.panel:AddControl("TextBox", {
			Label = "Soundpath",
			MaxLength = 300,
			Text = "path_of_sound",
			Command = "wac_gravitycontroller_sound",
		})
		self.panel:AddControl("Label", {Text = ""})
		self.panel:CheckBox("Glow","wac_gravitycontroller_drawSprite")
		if vars.stargateNode != 1 then
			self.panel:AddControl('Slider', {
				Label = 'Weight (0: Model Default)',
				Type = "Float", 
				Min = 0,
				Max = 500, 
				Command = 'wac_gravitycontroller_weight'
			})
			self.panel:AddControl("Label", {Text = ""})
			self.panel:CheckBox("Brake Only (Don't change gravity)","wac_gravitycontroller_brakeOnly")
			self.panel:CheckBox("Always Brake","wac_gravitycontroller_brakeAlways")
			self.panel:CheckBox("Global Airbrake","wac_gravitycontroller_brakeGlobal")
			if vars.brakeGlobal == 0 then
				self.panel:AddControl('Slider', { 
					Label = 'Brake X', 
					Type = "Float", 
					Min = 0, 
					Max = 100, 
					Command = 'wac_gravitycontroller_brakeX' 
				})
				self.panel:AddControl('Slider', { 
					Label = 'Brake Y', 
					Type = "Float", 
					Min = 0, 
					Max = 100, 
					Command = 'wac_gravitycontroller_brakeY' 
				})
				self.panel:AddControl('Slider', { 
					Label = 'Brake Z', 
					Type = "Float", 
					Min = 0, 
					Max = 100, 
					Command = 'wac_gravitycontroller_brakeZ' 
				})
			else
				self.panel:AddControl('Slider', { 
					Label = 'Global Brake', 
					Type = "Float", 
					Min = 0, 
					Max = 100, 
					Command = "wac_gravitycontroller_brakeMul" 
				})
			end	
			self.panel:CheckBox("Angle Brake (buggy sometimes)","wac_gravitycontroller_brakeAng")
			if vars.brakeAng == 1 then
				self.panel:AddControl('Slider', { 
					Label = 'Angle Brake', 
					Type = "Float", 
					Min = 0, 
					Max = 100, 
					Command = "wac_gravitycontroller_brakeAngMul" 
				})		
			end
			self.panel:AddControl("Label", {Text = ""})
			self.panel:AddControl("Numpad", { 
				ButtonSize = "22", 
				Label = "Activate", 
				Command = "wac_gravitycontroller_keyActivate",
				Label2 = 'Hovermode',
				Command2 = "wac_gravitycontroller_keyHover",
			})
			if vars.relativeToGround == 0 then
				self.panel:AddControl('Numpad', { 
					ButtonSize = '22', 
					Label = 'Hover Up', 
					Command = "wac_gravitycontroller_keyUp",
					Label2 = 'Hover Down',
					Command2 = "wac_gravitycontroller_keyDown",
				})
			end
			self.panel:AddControl("Slider", { 
				Label = "Hover Speed",
				Type = "Float", 
				Min = 0.01, 
				Max = 10,
				Command = "wac_gravitycontroller_hoverSpeed"
			})
			self.panel:CheckBox("Hover relative to ground","wac_gravitycontroller_relativeToGround")
			if vars.relativeToGround == 1 then		
				self.panel:AddControl("Slider", { 
					Label = "Height above ground",
					Type = "Float", 
					Min = 1, 
					Max = 100,
					Command = "wac_gravitycontroller_heightAboveGround"
				})
			end
			self.panel:AddControl("Label", {Text = ""})
			self.panel:CheckBox("Hovermode Description","wac_gravitycontroller_descHover")
			if vars.descHover == 1 then
				self.panel:AddControl("Label", {Text = "The GC will act like a hoverball. It will automatically balance all GC's from a contrapion. That means, once activated, everyone of them will have the same target height. So be sure they are all on the same height when you add them to your ship!"})
			end
			self.panel:CheckBox("Local Brake Description","wac_gravitycontroller_descLocal")
			if vars.descLocal == 1 then
				self.panel:AddControl("Label", {Text = "If you enable that, the GC will brake seperate on every axis. If you set every but one axis to 100, it will 'slide' along that axis. So if you want your ship not to brake as hard forward as it should sideways or upwards, this is for you!"})
			end
		else
			self.panel:AddControl("Label", {Text = ""})
			self.panel:AddControl("Numpad", {
				ButtonSize = "22",
				Label = "Activate",
				Command = "wac_gravitycontroller_keyActivate",
			})			
		end
		self.panel:CheckBox("SGA Powernode Mode","wac_gravitycontroller_stargateNode")
	end,

	trigger = {
		"stargateNode", "brakeGlobal", "brakeAng", "relativeToGround", "descLocal", "descHover"
	},

}, vars)

TOOL.BuildCPanel = TOOL.settings.BuildCPanel

function TOOL:Think()
	self.settings:think(self);
	self:updateGhost(self:GetOwner())
end

>>>>>>> added new experimental base
