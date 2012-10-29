TOOL.Category = 'Construction'
TOOL.Name = '#Gravity Controller'
TOOL.Command = nil
TOOL.ConfigName = ''

models = {
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


loopsounds = {
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

local convtable={
	["keyActivate"]		= {0, 0},
	["brakeX"]		= {0, 15},
	["brakeY"]		= {0, 15},
	["brakeZ"]		= {0, 15},
	["brakeMul"]		= {0, 10},
	["model"]			= {1, "models/props_c17/utilityconducter001.mdl"},
	["sound"]			= {1, "ambient/atmosphere/underground_hall_loop1.wav"},
	["pitchMul"] = {0, 1},
	["brakeAng"]		= {2, 0},
	["brakeGlobal"]		= {2, 1},
	["drawSprite"]		= {0, 1},
	["brakeAlways"]		= {0, 0},
	["brakeOnly"]		= {0, 0},
	["keyUp"]			= {0, 7},
	["keyDown"]			= {0, 4},
	["keyHover"]		= {0, 1},
	["hoverSpeed"]		= {0, 1},
	["descHover"]	= {2, 1},
	["descLocal"]		= {2, 1},
	["brakeAngMul"]		= {0, 20},
	["weight"]			= {0, 0},
	["relativeToGround"]	= {2, 0},
	["heightAboveGround"]	= {0, 30},
	["stargateNode"]	= {2, 0},
	["bLiveGravity"]		={0,0},
}

for s, v in pairs(convtable) do
	TOOL.ClientConVar[s]=v[2]
end

if (CLIENT) then
	language.Add('gravitycontroller', 'Gravity Controller')
	language.Add('tool.gravitycontroller.name', "Gravity Controller Creator")
	language.Add('tool.gravitycontroller.desc', 'Build Starships without hoverballs, or simply use it for stabilizing your stuff')
	language.Add('tool.gravitycontroller.0', 'Click where you would like to create a Gravity Controller, click on one to update it.')
	language.Add('undone.gravitycontroller', 'Gravity Controller Undone')
	language.Add('cleanup.gravitycontroller', 'Gravity Controller')
	language.Add('cleaned.gravitycontroller', 'Cleaned up all Gravity Controllers')
	language.Add('SBoxLimit.gravitycontroller', 'Maximum amount of Gravity Controllers reached')
end

local sgapowernd={
	[1]={-135, 0, 180},
	[2]={68, 118, -60},
	[3]={68, -118, 60}
}

function TOOL:LeftClick(trace)
	if trace.Entity && (trace.Entity:IsPlayer()) then return false end
	if(CLIENT) then
		return true
	end
	if(!SERVER) then return false end
	local ply = self:GetOwner()
	local Pos = trace.HitPos
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch+90
	undo.Create('gravitycontroller')
	if trace.Entity and trace.Entity:IsValid() and convtable["stargateNode"][2]==1 and trace.Entity.IsStargate then
		trace.Entity.GCTable=trace.Entity.GCTable or {}
		for i=1,3 do
			if !trace.Entity.GCTable[i] or !trace.Entity.GCTable[i]:IsValid() then
				local ent=MakeGravitycontroller(ply, Ang, Pos, convtable)
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
		if (trace.Entity:IsValid() && trace.Entity:GetClass()=="gravitycontroller") then
			trace.Entity.ConTable=table.Copy(convtable)
			if !trace.Entity.phys then
				trace.Entity.phys = trace.Entity:GetPhysicsObject()
			end
			if trace.Entity.phys:IsValid() and convtable["weight"][2] != 0 then
				trace.Entity.phys:SetMass(math.Clamp(convtable["weight"][2], 1, 500))
			end
			if trace.Entity.Sound then
				trace.Entity.Sound:Stop()
				trace.Entity.Sound=CreateSound(trace.Entity, convtable["sound"][2])
				if trace.Entity.Active then
					trace.Entity.Sound:Play()
				end
			end
			return true
		end
		local ent=MakeGravitycontroller(ply, Ang, Pos, convtable)
		ent:SetPos(trace.HitPos - trace.HitNormal * ent:OBBMins().z)
		if (trace.Entity:IsValid()) then
			local const=constraint.Weld(ent, trace.Entity,0, trace.PhysicsBone, 0, systemmanager)
			local nocollide=constraint.NoCollide( ent, trace.Entity, 0, trace.PhysicsBone)
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
	function MakeGravitycontroller(ply, Ang, Pos, tbl)
		local ent=ents.Create('gravitycontroller')
		if !ent:IsValid() then return false end
		ent:SetAngles(Ang)
		ent:SetPos(Pos)
		ent.vars = table.Copy(tbl)
		ent:Spawn()
		ent:SetVar('Owner',ply)
		numpad.OnDown(ply, tbl["keyActivate"][2], 'FireGravitycontroller', ent)
		if tbl["stargateNode"][2]!=1 then
			if tbl["weight"][2] > 1 then
				ent:GetPhysicsObject():SetMass(tbl["weight"][2])
			end
			numpad.OnDown(ply, tbl["keyHover"][2], 'ToggleHoverMode', ent)
			numpad.OnDown(ply, tbl["keyUp"][2], 'GoUp', ent)
			numpad.OnDown(ply, tbl["keyDown"][2], 'GoDown', ent)
			numpad.OnUp(ply, tbl["keyUp"][2], 'GoStop', ent)
			numpad.OnUp(ply, tbl["keyDown"][2], 'GoStop', ent)
			ent.StartVector=ent:WorldToLocal(Pos-Vector(0,0,1))
			ent:SetNWVector("startvector", ent.StartVector)
		else
			ent:GetPhysicsObject():SetMass(200)
		end
		local ttable={
			Ang=Ang,
			Pos=Pos,
			ply=ply,
			tbl=tbl,
		}
		table.Merge(ent:GetTable(), ttable)
		ply:AddCount('gravcontroller', ent)		
		return ent
	end
	duplicator.RegisterEntityClass("gravitycontroller", MakeGravitycontroller, "Ang", "Pos", "tbl")
end

if CLIENT then
	local panel = nil
	function TOOL.BuildCPanel(p)
		panel = p
		panel:AddControl("Label", {Text = "Please wait...."})
	end
	local updatetime = 0
	local function UpdatePanel()
		panel:Clear()
		panel:AddControl("PropSelect", {
			Label = "Model",
			ConVar = "gravitycontroller_model",
			Category = "",
			Models = list.Get("GravControllerModels")
		})
		panel:AddControl("TextBox", {
			Label = "Modelpath",
			MaxLength = 300,
			Text = "path_of_model.mdl",
			Command = "gravitycontroller_model",
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
		panel:AddControl("Label", {Text = ""})
		panel:AddControl("Label", {Text = "Sound"})
		panel:AddControl('ComboBox', combo)
		panel:AddControl('Slider', {
			Label = 'Sound Pitch',
			Type = "Float", 
			Min = 0,
			Max = 1, 
			Command = 'gravitycontroller_pitchMul'
		})

		panel:AddControl("TextBox", {
			Label = "Soundpath",
			MaxLength = 300,
			Text = "path_of_sound",
			Command = "gravitycontroller_sound",
		})
		panel:AddControl("Label", {Text = ""})
		panel:CheckBox("Glow","gravitycontroller_drawSprite")
		if convtable["stargateNode"][2] != 1 then
			panel:AddControl('Slider', {
				Label = 'Weight (0: Model Default)',
				Type = "Float", 
				Min = 0,
				Max = 500, 
				Command = 'gravitycontroller_weight'
			})
			panel:AddControl("Label", {Text = ""})
			panel:CheckBox("Brake Only (Don't change gravity)","gravitycontroller_brakeOnly")
			panel:CheckBox("Always Brake","gravitycontroller_brakeAlways")
			panel:CheckBox("Global Airbrake","gravitycontroller_brakeGlobal")
			if convtable["brakeGlobal"][2] == 0 then
				panel:AddControl('Slider', { 
					Label = 'Brake X', 
					Type = "Float", 
					Min = 0, 
					Max = 100, 
					Command = 'gravitycontroller_brakeX' 
				})
				panel:AddControl('Slider', { 
					Label = 'Brake Y', 
					Type = "Float", 
					Min = 0, 
					Max = 100, 
					Command = 'gravitycontroller_brakeY' 
				})
				panel:AddControl('Slider', { 
					Label = 'Brake Z', 
					Type = "Float", 
					Min = 0, 
					Max = 100, 
					Command = 'gravitycontroller_brakeZ' 
				})
			else
				panel:AddControl('Slider', { 
					Label = 'Global Brake', 
					Type = "Float", 
					Min = 0, 
					Max = 100, 
					Command = "gravitycontroller_brakeMul" 
				})
			end	
			panel:CheckBox("Angle Brake (buggy sometimes)","gravitycontroller_brakeAng")
			if convtable["brakeAng"][2] == 1 then
				panel:AddControl('Slider', { 
					Label = 'Angle Brake', 
					Type = "Float", 
					Min = 0, 
					Max = 100, 
					Command = "gravitycontroller_brakeAngMul" 
				})		
			end
			panel:AddControl("Label", {Text = ""})
			panel:AddControl("Numpad", { 
				ButtonSize = "22", 
				Label = "Activate", 
				Command = "gravitycontroller_keyActivate",
				Label2 = 'Hovermode',
				Command2 = "gravitycontroller_keyHover",
			})
			if convtable["relativeToGround"][2]==0 then
				panel:AddControl('Numpad', { 
					ButtonSize = '22', 
					Label = 'Hover Up', 
					Command = "gravitycontroller_keyUp",
					Label2 = 'Hover Down',
					Command2 = "gravitycontroller_keyDown",
				})
			end
			panel:AddControl("Slider", { 
				Label = "Hover Speed",
				Type = "Float", 
				Min = 0.01, 
				Max = 10,
				Command = "gravitycontroller_hoverSpeed"
			})
			panel:CheckBox("Hover relative to ground","gravitycontroller_relativeToGround")
			if convtable["relativeToGround"][2] == 1 then		
				panel:AddControl("Slider", { 
					Label = "Height above ground",
					Type = "Float", 
					Min = 1, 
					Max = 100,
					Command = "gravitycontroller_heightAboveGround"
				})
			end
			panel:AddControl("Label", {Text = ""})
			panel:CheckBox("Hovermode Description","gravitycontroller_descHover")
			if convtable["descHover"][2] == 1 then
				panel:AddControl("Label", {Text = "The GC will act like a hoverball. It will automatically balance all GC's from a contrapion. That means, once activated, everyone of them will have the same target height. So be sure they are all on the same height when you add them to your ship!"})
			end
			panel:CheckBox("Local Brake Description","gravitycontroller_descLocal")
			if convtable["descLocal"][2] == 1 then
				panel:AddControl("Label", {Text = "If you enable that, the GC will brake seperate on every axis. If you set every but one axis to 100, it will 'slide' along that axis. So if you want your ship not to brake as hard forward as it should sideways or upwards, this is for you!"})
			end
		else
			panel:AddControl("Label", {Text = ""})
			panel:AddControl("Numpad", {
				ButtonSize = "22",
				Label = "Activate",
				Command = "gravitycontroller_keyActivate",
			})			
		end
		panel:CheckBox("SGA Powernode Mode","gravitycontroller_stargateNode")
	end
	--usermessage.Hook("UpdateGravControllerPanel", updatepanel)
	local lastupdate=0
	local firstupdate=true
	local oldvtable=table.Copy(convtable)
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
		if firstupdate then
			UpdatePanel()
			firstupdate=false
		end
		for k, v in pairs(oldvtable) do
			if v[1]==2 and v[2] != convtable[k][2] then
				UpdatePanel()
				oldvtable=table.Copy(convtable)
				break
			end
		end
		if (!self:GetClientInfo("model")) then return end
		local model = self:GetClientInfo("model")	
		if (!self.GhostEntity || !self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != model) then
			self:MakeGhostEntity(model, Vector(0,0,0), Angle(0,0,0))
		end	
		self:UpdateSpawnGhost(self.GhostEntity, self:GetOwner())
	end
end

function TOOL:UpdateSpawnGhost(ent, player)
	if (!ent) then return end
	if (!ent:IsValid()) then return end
	local trace = util.TraceLine({
		start = player:EyePos(),
		endpos = player:EyePos() + player:GetAimVector()*1000,
		filter = {player}
	})
	if (!trace.Hit) then return end	
	if (trace.Entity && trace.Entity:GetClass() == "gravitycontroller" || trace.Entity:IsPlayer()) then	
		ent:SetNoDraw(true)
		return		
	end	
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	ent:SetAngles( Ang )	
	local min = ent:OBBMins()
	ent:SetPos(trace.HitPos-trace.HitNormal*min.z)
	ent:SetNoDraw(false)
end

if SERVER then
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
		if (!self:GetClientInfo("model")) then return end
		local model = self:GetClientInfo("model")	
		if (!self.GhostEntity || !self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != model) then
			self:MakeGhostEntity(model, Vector(0,0,0), Angle(0,0,0))
		end	
		self:UpdateSpawnGhost(self.GhostEntity, self:GetOwner())
	end
end