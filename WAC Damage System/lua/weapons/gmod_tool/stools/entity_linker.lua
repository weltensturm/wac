
TOOL.Category			= WAC.Names.ToolCategory
TOOL.Name			= "#tool_entity_linker_name"
TOOL.Command		= nil
TOOL.ConfigName		= ""

local ents={
	["wac_v_camera"]	={"vehicle"},
	["wac_v_turret_00"]	={"vehicle"},
	["wac_v_turret_10"]	={"vehicle"},
	["wac_v_connector"]	={"vehicle"},
	["wac_w_base"]		={"vehicle"},
}

if (CLIENT) then
	language.Add("Tool_entity_linker_name", "Entity Linker")
	language.Add("Tool_entity_linker_desc", "Link entities to pods")
	language.Add("Tool_entity_linker_0", "Click on the entity you want to link")
	language.Add("Tool_entity_linker_1", "Now click on the pod you want to link it to, or press R to clear.")
end

function TOOL:LeftClick(tr)
	if tr.Hit and ValidEntity(tr.Entity) then
		local e=tr.Entity
		local eclass=e:GetClass()
		if e:IsVehicle() then eclass="vehicle" end
		if !self.tEntity and ents[eclass] and type(ents[eclass][1])=="string" then
			self.tEntity=tr.Entity
			self.tEClass=eclass
			self:SetStage(1)
			return true
		elseif self.tEntity and self.tEntity:IsValid() then
			if ents[self.tEClass] and table.HasValue(ents[self.tEClass],eclass) then
				if eclass=="vehicle" then
					if SERVER then self.tEntity:AddVehicle(e) end
					self.tEntity=nil
					self.tEClass=nil
					self:SetStage(0)
					return true
				elseif eclass=="wac_w_base" then
					if SERVER then self.tEntity:AddWeapon(e) end
					self.tEntity=nil
					self.tEClass=nil
					self:SetStage(0)
					return true
				end
			end
		end
	end
end

function TOOL:Reload(tr)
	self.tEntity=nil
	self.tEClass=nil
	self:SetStage(0)
	return true
end
