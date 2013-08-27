
local CLASS = {}

CLASS.DisplayName			= "Samus Aran"
CLASS.WalkSpeed 			= 300
CLASS.RunSpeed			= 300
CLASS.CrouchedWalkSpeed 	= 0.5
CLASS.DuckSpeed			= 0.2
CLASS.JumpPower			= 300
CLASS.DrawTeamRing		= true

function CLASS:Loadout(pl)
	pl:Give("weapon_metroid_base")
end

function CLASS:OnSpawn(pl)
	pl:SetHullDuck(Vector(-16,-16,0), Vector(16,16,43))
	pl:SetViewOffsetDucked(Vector(0,0,38))
end

player_class.Register("Default", CLASS)