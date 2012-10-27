
include("shared.lua")

local nphm={
	"models/tools/camera/camera.mdl",
}

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetNWInt("channel", self.Channel)
	SetGlobalEntity("wac_cam_rt"..self.Channel, self.Entity)
	if table.HasValue(nphm, self:GetModel()) then
		self.Physm=ents.Create("prop_physics")
		self.Physm:SetModel("models/dav0r/camera.mdl")
		self.Physm:SetPos(self:GetPos())
		self.Physm:SetAngles(self:GetAngles())
		self.Physm:Spawn()
		self.Physm:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self.Physm:SetColor(Color(0,0,0,0))
		self.Entity:SetParent(self.Physm)
		undo.Create("prop")
		undo.AddEntity(self.Physm)
		undo.SetPlayer(self.Owner)
		undo.SetCustomUndoText("Undone RT7 Camera")
		undo.Finish()
	else
		undo.Create("prop")
		undo.AddEntity(self.Entity)
		undo.SetPlayer(self.Owner)
		undo.SetCustomUndoText("Undone RT7 Camera")
		undo.Finish()
	end
end