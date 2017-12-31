include('shared.lua')     
local SelectTexture="WeltEnSTurm/RTS/circle"

function ENT:Initialize()
	--[[self.flashlight = ents.Create("env_projectedtexture")
	self.flashlight:SetParent(self.Entity)
	self.flashlight:SetLocalPos(Vector(0, 0, 50))
	self.flashlight:SetLocalAngles(Angle(90,0,0))
	self.flashlight:SetKeyValue("enableshadows", 0)
	self.flashlight:SetKeyValue("farz", 2048)
	self.flashlight:SetKeyValue("nearz", 8)
	self.flashlight:SetKeyValue("lightfov", 50)
	self.flashlight:SetKeyValue("lightcolor", "255 255 255")
	self.flashlight:Spawn()
	self.flashlight:Input("SpotlightTexture", NULL, NULL, SelectTexture)]]
end

function ENT:Draw()
	self.Entity:DrawModel()
end

function ENT:Think()

end