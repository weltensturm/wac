

local qt={
	texture=surface.GetTextureID("sprites/light_glow02_add"),
	color=Color(255, 182, 74, 255),
	x=-10,
	y=-10,
	w=20,
	h=20,
}

local u=100000

function EFFECT:Init(data)
	self.Entity:SetRenderBounds(Vector(-u,-u,-u), Vector(u,u,u))
	self.Pos=data:GetStart()
	self.Size=data:GetScale()
	self.Normal=data:GetNormal()
	self.Angle=self.Normal:Angle()
	self.Angle:RotateAroundAxis(self.Angle:Right(), -90)
	self.State=1
end

function EFFECT:Think()
	self.State=self.State+110*FrameTime()
	return self.State<11
end 

function EFFECT:Render()
	cam.Start3D2D(self.Pos+self.Normal, self.Angle, 1)
	qt.x=-self.State*self.Size
	qt.y=-self.State*self.Size
	qt.w=self.State*2*self.Size
	qt.h=self.State*2*self.Size
	qt.color.a=255-self.State*13
	draw.TexturedQuad(qt)
	cam.End3D2D()
end