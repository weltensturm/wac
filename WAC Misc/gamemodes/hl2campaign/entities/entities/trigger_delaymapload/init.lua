
ENT.Base = "base_anim"
ENT.Type = "anim"

function ENT:Initialize()
	local w = self.max.x - self.min.x
	local l = self.max.y - self.min.y
	local h = self.max.z - self.min.z	
	local min = Vector(0 - (w / 2), 0 - (l / 2), 0 - (h / 2))
	local max = Vector(w / 2, l / 2, h / 2)
	self:DrawShadow(false)
	self:SetCollisionBounds(min, max)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetMoveType(0)
	self:SetTrigger(true)
end

function ENT:StartTouch(ent)
	if ent && ent:IsValid() && ent:IsPlayer() && ent:Team() == TEAM_ALIVE then
		ent:SetTeam(TEAM_COMPLETED_MAP)
		ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		if ent:GetVehicle() && ent:GetVehicle():IsValid() then
			ent:GetVehicle():Remove()
			ent:ExitVehicle()
		end
		local p = ent:EyePos()
		ent:SetNoTarget(true)
		ent:StripWeapons()
		ent:Flashlight(false)
		ent:Spectate(OBS_MODE_ROAMING)
		ent:SetPos(p)
		PrintMessage(HUD_PRINTTALK, Format("%s completed the map (%s) [%i of %i].", ent:Nick(), string.ToMinutesSeconds(CurTime() - ent.startTime), team.NumPlayers(TEAM_COMPLETED_MAP), self.playersAlive))
	end
end

function ENT:Think()
	self.playersAlive = team.NumPlayers(TEAM_ALIVE) + team.NumPlayers(TEAM_COMPLETED_MAP)	
	if self.playersAlive > 0 && team.NumPlayers(TEAM_COMPLETED_MAP) >= (self.playersAlive * (NEXT_MAP_PERCENT / 100)) then
		GAMEMODE:NextMap()
	end
end