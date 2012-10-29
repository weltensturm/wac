
local PHYSICS=FindMetaTable("PhysObj")

if not PHYSICS["OriginalEnableGravity"] then
	PHYSICS["OriginalEnableGravity"]=PHYSICS["EnableGravity"]
end

function PHYSICS:EnableGravity(b)
	local nograv=!b
	local e=self:GetEntity()
	e.nograv=nograv
	self:OriginalEnableGravity(b)
end

function PHYSICS:GetGravity()
	local e=self:GetEntity()
	return !e.nograv
end

local em=FindMetaTable("Entity")

function em:GetGravity()
	return !self.nograv
end
