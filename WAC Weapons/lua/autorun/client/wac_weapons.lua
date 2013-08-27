--[[

local function preparePlayer(player)
	player.wac = player.wac or {
		view = {}
	}
end

local function prepareWeapon(weapon)
	weapon.wac = weapon.wac or {
		viewAngle = Angle(0,0,0),
		viewPos = Vector(0,0,0)
	}
end

local function checkWeapon(weapon)
	if !IsValid(weapon) then return false end
end

local function checkAllow(weapon, player)
	if !weapon.wac or !weapon.wac.allowViewChange then return false end
	preparePlayer(player)
	prepareWeapon(weapon)
end

wac.hook("CalcView", "wac_weapon_calcview", function(player, pos, ang, fov)
	
	if player:InVehicle() or !player:Alive() then return end
	
	local weapon = player:GetActiveWeapon()
	if !checkWeapon(weapon) then return end
	if !checkAllow(weapon, player) then return end

	local velocity = pl:GetVelocity()
	local speed = velocity:Length()
	local timeFrame = FrameTime()
	local timeCurrent = CurTime()

	return player.wac.view

end)

]]
