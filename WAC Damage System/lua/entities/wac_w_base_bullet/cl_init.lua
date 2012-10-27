include('shared.lua')     

function ENT:Initialize()
	self.Glow=Material("sprites/light_glow02_add")
end

function ENT:Draw()
	self.scale1=self:GetNWFloat("size")
	self.scale2=self.scale1*1.25
	self.scale3=self.scale1*1.5
	local startpos = self.Entity:GetPos()
	render.SetMaterial(self.Glow)
	local col=Color(self:GetColor())
	render.DrawSprite(startpos, self.scale1, self.scale1, col)
	render.DrawSprite(startpos, self.scale2, self.scale2, col)
	render.DrawSprite(startpos, self.scale3*self:GetNWFloat("width"), self.scale3, col)
end
