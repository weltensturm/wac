TOOL.Category		= "Constraints"
TOOL.Name			= "#Weld - Detail Multi"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.EntityTable	= {}

if ( CLIENT ) then
    language.Add( "Tool_detailweldmulti_name", "Weld - Detail Multi" )
    language.Add( "Tool_detailweldmulti_desc", "asdf" )
    language.Add( "Tool_detailweldmulti_0", "Primary: Add/Remove entity to parenting table, Secondary: Parent them to the Entity you are looking at" )
end

TOOL.ClientConVar[ "name" ] = ""

function TOOL:LeftClick(trace)
	if (not trace.Entity:IsValid()) or trace.Entity:IsPlayer() then return end
	if (CLIENT) then return end
	if  trace.Entity.MultiDetail and trace.Entity.MultiDetail.IsInTable then
		for i=1,table.getn(self.EntityTable) do
			if self.EntityTable[i] == trace.Entity then
				table.remove(self.EntityTable, i)
			end
		end
		trace.Entity.MultiDetail.IsInTable = false
		if !trace.Entity.MultiDetail.Color then
			trace.Entity.MultiDetail.Color = trace.Entity:GetColor()
		end
		local tbl = trace.Entity.MultiDetail.Color
		trace.Entity:SetColor(tbl.r, tbl.g, tbl.b, tbl.a)
	elseif !trace.Entity.MultiDetail or !trace.Entity.MultiDetail.IsDetail then
		trace.Entity.MultiDetail = {}
		trace.Entity.MultiDetail.IsInTable = true
		trace.Entity.MultiDetail.Color = Color(trace.Entity:GetColor())
		local pl = self:GetOwner()
		local col = Color(trace.Entity:GetColor())
		trace.Entity:SetColor( 50, 50,200,255)
		table.insert(self.EntityTable, trace.Entity)
	end
	return true
end


function TOOL:RightClick(trace)
	if (not trace.Entity:IsValid()) or trace.Entity:IsPlayer() then return end
	if (CLIENT) then return end
	local tUndo={Welds={}, Ents={}}
	for _,e in pairs(self.EntityTable) do
		if e.MultiDetail and e.MultiDetail.IsInTable and !e.MultiDetail.IsDetail then
			if trace.Entity.MultiDetail and trace.Entity.MultiDetail.IsInTable then
				self:GetOwner():ChatPrint("This entity is in your parent table! Remove it before you do that.")
				return
			end
			e.MultiDetail.IsInTable = false
			e.MultiDetail.IsDetail = true
			local tbl = e.MultiDetail.Color
			e:SetColor(tbl.r, tbl.g, tbl.b, tbl.a)
			local CreateDetail = e:SetDetailStatus(true, trace.Entity, trace.Entity:WorldToLocal(e:GetPos()))
			local Weld = constraint.Weld(e, trace.Entity, 0, 0, 0, true)
			if Weld then table.insert(tUndo.Welds, Weld) end
			table.insert(tUndo.Ents, e)
		end
	end
	undo.Create("Detail")
	for _, w in pairs(tUndo.Welds) do
		undo.AddEntity(w)
	end
	undo.AddFunction(function()
		for _, e in pairs(tUndo.Ents) do
			if e and e:IsValid() then
				e:SetDetailStatus(false)
				if e.MultiDetail then
					e.MultiDetail.IsDetail = false 
				end
			end
		end
	end)
	undo.SetPlayer(self:GetOwner())
	undo.Finish()
	table.Empty(self.EntityTable)
	return true
end


function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "#Tool_wire_namer_name", Description = "#Tool_wire_namer_desc" })
end
