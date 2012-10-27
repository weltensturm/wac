TOOL.Category = "Constraints"
TOOL.Name = "#Weld - Detail"
TOOL.Command = nil
TOOL.ConfigName = ""

if(CLIENT)then
	language.Add( 'Tool_weld_detail_name', 'Weld - Detail' )
	language.Add( 'Tool_weld_detail_desc', 'Efficiently welds props together' )
	language.Add( 'Tool_weld_detail_0', 'Left-Click: Select detail prop  Right-Click: Detach details from prop  Reload: Force detail position' )
	language.Add( 'Tool_weld_detail_1', 'Now select the prop you want to attach it to' )
	language.Add( 'Undone_Detail', 'Undone Detail Weld' )
end

function TOOL:LeftClick(trace)
	if (trace.Entity:IsValid() && trace.Entity:IsPlayer()) then return false end
	if !trace.Hit || trace.HitWorld then return false end
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	if trace.Entity && trace.Entity:IsValid() && trace.Entity:GetOwner() == self:GetOwner() then
		self:GetOwner():SendLua("GAMEMODE:AddNotify(\"Don't touch that\", NOTIFY_GENERIC, 2); surface.PlaySound(\"buttons/combine_button7.wav\")")
	return false end
	local iNum = self:NumObjects()
	self:SetObject( iNum + 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )
	if (CLIENT) then if (iNum > 0) then self:ClearObjects() end return true end
	if (iNum > 0) then
		local Ent1,  Ent2  = self:GetEnt(1),  self:GetEnt(2)
		local Bone1, Bone2 = self:GetBone(1), self:GetBone(2)
		local CreateDetail = Ent1:SetDetailStatus(true, Ent2, Ent2:WorldToLocal(Ent1:GetPos()))
		if CreateDetail == false then
			self:GetOwner():SendLua("GAMEMODE:AddNotify(\"I can't let you do that, Dave\", NOTIFY_GENERIC, 2.5); surface.PlaySound(\"buttons/combine_button7.wav\")")
			self:ClearObjects()
		return false end
		local Weld = constraint.Weld(Ent1, Ent2, Bone1, Bone2, 0, true)
		undo.Create("Detail")
		if Weld then undo.AddEntity(Weld) end
		undo.AddFunction(function() Ent1:SetDetailStatus(false) end)
		undo.SetPlayer(self:GetOwner())
		undo.Finish()
		Ent1:GetPhysicsObject():Wake()
		self:ClearObjects()
	else
		self:SetStage(iNum+1)	
	end
	return true
end

function TOOL:RightClick(trace)
	local Success = false
	if trace.Hit && !trace.HitWorld && trace.Entity && trace.Entity:IsValid() && trace.Entity:GetOwner() == self:GetOwner() then
		self:GetOwner():SendLua("GAMEMODE:AddNotify(\"Can't touch this\", NOTIFY_GENERIC, 2); surface.PlaySound(\"buttons/combine_button7.wav\")")
	return false end
	if (SERVER) then
		if trace.Entity && trace.Entity:IsValid() && trace.Entity:IsParent() then
			for _, detail in pairs(trace.Entity.Details) do
				if detail && detail:IsValid() then
					constraint.RemoveConstraints(detail, "Weld" )
					detail:SetDetailStatus(false)
				end
			end
			Success = true
		end
	end
	if Success then self:GetOwner():SendLua("GAMEMODE:AddNotify(\"Detached all detail props\", NOTIFY_GENERIC, 2)") return true end
end

function TOOL:Reload()
	if (CLIENT) then return false end
	local Success = false
	local allprops = ents.GetAll()
	for _, stuff in pairs(allprops) do
		if stuff && stuff:IsValid() && stuff:IsDetail() then
			stuff:GetPhysicsObject():SetPos(stuff.Parent:LocalToWorld(stuff.Offset))
			Success = true
		end
	end
	if Success then self:GetOwner():SendLua("GAMEMODE:AddNotify(\"Forced detail prop positions\", NOTIFY_GENERIC, 1.5); surface.PlaySound(\"buttons/combine_button2.wav\")") end
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "#Tool_weld_detail_name", Description = "Welds stuff to other stuff" })
end