INFO_PLAYER_SPAWN = {Vector(7680, -1053, 2128), 90}

NEXT_MAP = "d3_citadel_04"

SUPER_GRAVITY_GUN = true

TRIGGER_CHECKPOINT = {
	{Vector(3175, 522, 2368), Vector(3580, 562, 2529)}
}

hook.Add("InitPostEntity", "hl2cInitPostEntity", function()
	wep = ents.Create("weapon_physcannon")
	wep:SetPos(Vector(7680, -1053, 2128))
	wep:Spawn()
	wep:Activate()
	
	local func_brushes = ents.FindByClass("func_brush")
	func_brushes[6]:Remove()
	func_brushes[7]:Remove()
	func_brushes[12]:Remove()
	func_brushes[13]:Remove()
end)