
TOOL.Category		= "WAC"
TOOL.Name		= "#tool_toiwstatic_name"
TOOL.Command	= nil
TOOL.ConfigName	= ""

if (CLIENT) then
	language.Add("Tool_toiwstatic_name", "IWStatic")
	language.Add("Tool_toiwstatic_desc", "Makes stuff to a special entity to save for autospawn")
	language.Add("Tool_toiwstatic_0", "clickclackclock")
end

function TOOL:LeftClick(tr)
	if !self:GetOwner():IsAdmin() then return end
	if CLIENT then return true end
	for _,ent in pairs(constraint.GetAllConstrainedEntities(tr.Entity)) do
		if ent:GetClass() == "prop_physics" then
			local e = ents.Create("prop_iw_static")
			e:SetPos(ent:GetPos())
			e:SetAngles(ent:GetAngles())
			e:SetModel(ent:GetModel())
			e:Activate()
			e:Spawn()
			ent:Remove()
		end
	end
end

function TOOL:RightClick(tr)
	if !self:GetOwner():IsAdmin() then return end
	if tr.Entity:GetClass() == "prop_physics" then
		if CLIENT then return true end
		local e = ents.Create("prop_iw_shield")
		e:SetPos(tr.Entity:GetPos())
		e:SetAngles(tr.Entity:GetAngles())
		e:SetModel(tr.Entity:GetModel())
		e:Activate()
		e:Spawn()
		e.Team = tr.Entity.Team
		tr.Entity:Remove()
	end
end
