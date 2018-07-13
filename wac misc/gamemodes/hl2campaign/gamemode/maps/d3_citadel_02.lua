NEXT_MAP = "d3_citadel_03"

NEXT_MAP_PERCENT = 1

TRIGGER_DELAYMAPLOAD = {Vector(3781, 13186, 3900), Vector(3984, 13590, 4000)}


hook.Add("PlayerSpawn", "hl2c_d3_citadel_02", function(pl)
    local pod = ents.FindByClass("prop_vehicle_prisoner_pod")[1]
    if not pod then
        GAMEMODE:NextMap()
    end
    if not IsValid(pod:GetPassenger(1)) then
        pl:EnterVehicle(pod)
    else
        pl:SetPos(pod:GetPos())
        pl:SetParent(pod)
        pl:SetNoDraw(true)
    end
end)
