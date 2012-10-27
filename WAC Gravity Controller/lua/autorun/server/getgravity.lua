
local ph=FindMetaTable("PhysObj")

if not ph["OriginalEnableGravity"] then
	ph["OriginalEnableGravity"]=ph["EnableGravity"]
end

function ph:EnableGravity(b)
	local nograv=!b
	local e=self:GetEntity()
	e.nograv=nograv
	self:OriginalEnableGravity(b)
end

function ph:GetGravity()
	local e=self:GetEntity()
	return !e.nograv
end

local em=FindMetaTable("Entity")

function em:GetGravity()
	return !self.nograv
end
