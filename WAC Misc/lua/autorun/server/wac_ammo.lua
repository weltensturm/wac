
include "wac/base.lua"

local cv={
	b=CreateConVar("wac_ammo_enable", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE}),
	t=CreateConVar("wac_ammo_updatetime", 0.1, {FCVAR_REPLICATED, FCVAR_ARCHIVE}),
}

local AMMO={
	["AR2"]=60,
	["AlyxGun"]=90,
	["Pistol"]=90,
	["SMG1"]=120,
	["357"]=12,
	["XBowBolt"]=12,
	["Buckshot"]=30,
	["RPG_Round"]=3,
	["SMG1_Grenade"]=3,
	["SniperRound"]=12,
	["SniperPenetratedRound"]=12,
	["Grenade"]=5,
	["Gravity"]=45,
	["Battery"]=90,
	["CombineCannon"]=30,
	["AirboatGun"]=100,
	["StriderMinigun"]=45,
	["AR2AltFire"]=3,
	["slam"]=5,
}

for k,v in pairs(AMMO) do
	cv[k]=CreateConVar("wac_ammo_max"..k, v)
end

wac.hook("PlayerSpawn", "wac_ammo_spawn", function(p)
	if cv.b:GetInt()==1 then
		timer.Simple(0,function()
			p:RemoveAllAmmo()
		end)
	end
end)

local CrT=0
local ut=0
wac.hook("Think", "wac_ammo_think", function()
	CrT=CurTime()
	if ut<CrT then
		for _,p in pairs(player.GetAll()) do
			for k,a in pairs(AMMO) do
				local ammo=p:GetAmmoCount(k)
				local maxammo=cv[k]:GetInt()
				if ammo>maxammo then
					p:RemoveAmmo(ammo-maxammo,0)
					p.NDS_AmmoCredits=p.NDS_AmmoCredits or 0
					p.NDS_AmmoCredits=p.NDS_AmmoCredits+ammo-maxammo
				end
			end
		end
		ut=CrT+cv.t:GetFloat()
	end
end)
