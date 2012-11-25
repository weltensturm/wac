--[[
local VEHICLE = FindMetaTable("Vehicle")

local origSet = VEHICLE.SetThirdPersonMode

function VEHICLE:SetThirdPersonMode(b)
	MsgN("autorun/server/wac_base.lua [7]: " .. b)
	self:SetNWBool("wac_thirdperson", b)
	return origSet(self, b)
end
]]