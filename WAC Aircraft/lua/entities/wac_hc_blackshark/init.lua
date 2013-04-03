
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

function ENT:SpawnFunction(p, tr)
	if (!tr.Hit) then return end
	local e = ents.Create(ClassName)
	e:SetPos(tr.HitPos)
	--e:SetAngles(p:GetAngles() + Angle(0,90,0))
	e.Owner = p
	e:Spawn()
	e:Activate()
	return e
end
