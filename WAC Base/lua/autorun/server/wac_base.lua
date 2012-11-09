
local VEHICLE = FindMetaTable("Entity")

local origSet = VEHICLE.SetThirdPersonMode

function VEHICLE:SetThirdPersonMode(b)
	self:SetNWBool("wac_thirdperson", b)
	return origSet(self, b)
end
