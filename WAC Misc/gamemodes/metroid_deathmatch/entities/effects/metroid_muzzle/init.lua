
local DrawTable={
	MAT1=CreateMaterial("metroid_muzzle_1","UnlitGeneric",{
		["$basetexture"]	= "sprites/orangecore2",
		["$nocull"]			= "1",
		["$additive"]		= "1",
		["$vertexalpha"]	= "1",
		["$vertexcolor"]		= "1",
	}),
	WHITE=Color(255,255,255,255),
}


function EFFECT:Init(data)
	self.ply=data:GetEntity()
	self.mdl=self.ply:GetViewModel()
	self.ent=self.ply:GetActiveWeapon()
end

function EFFECT:Think()
	return false
end

local xAng=Angle(0,0,0)
function EFFECT:Render()
	local pos=self.mdl:GetAttachment(1).Pos
	local crt=CurTime()*80
	local dis=0
	for i=0, 999999999999999999, 360 do
		if i>crt then
			dis=i
			break
		end
	end
	render.SetMaterial(DrawTable.MAT1)
	render.DrawSprite(pos, self.ent.Muzzle.Shots*10, self.ent.Muzzle.Shots*10,DrawTable.WHITE)
end