// Entity information
ENT.Base = "base_anim"
ENT.Type = "anim"


// Called when the entity first spawns
function ENT:Initialize()
	self.ipsLocation = Vector(self.pos.x, self.pos.y, self.min.z + 8)
	
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


// Called when an entity touches it
function ENT:StartTouch(ent)
	if ent && ent:IsValid() && ent:IsPlayer() && ent:Team() == TEAM_ALIVE && !self.triggered then
		self.triggered = true
		
		if self.OnTouchRun then
			self:OnTouchRun()
		end
		
		local ang = ent:GetAngles()
		
		if !self.skipSpawnpoint then
			GAMEMODE:CreateSpawnPoint(self.ipsLocation, ang.y)
		end
		
		for _, pl in pairs(player.GetAll()) do
			if pl && pl:IsValid() && pl != ent && pl:Team() == TEAM_ALIVE then
				if pl:GetVehicle() && pl:GetVehicle():IsValid() then
					pl:GetVehicle():SetPos(self.ipsLocation)
					pl:GetVehicle():SetAngles(ang)
				else
					pl:SetPos(self.ipsLocation)
					pl:SetAngles(ang)
				end
			end
		end
		
		table.remove(GAMEMODE.checkpointPositions, 1)
		umsg.Start("SetCheckpointPosition", RecipientFilter():AddAllPlayers())
		umsg.Vector(GAMEMODE.checkpointPositions[1])
		umsg.End()
		
		self:Remove()
	end
end