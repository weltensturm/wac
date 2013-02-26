GM.Name 		= "Infinite Wars"
GM.Author 		= "WeltEnSTurm"
GM.Email 		= "N/A"
GM.Website 	= "N/A"
GM.IsSandboxDerived = true

TEAM_BLUE = 1
TEAM_RED = 2
TEAM_SPECTRATOR = 3
team.SetUp(1, "Blue", Color(80, 80, 200, 255))  
team.SetUp(2, "Red", Color(200, 80, 80 , 225))
team.SetUp(3, "Spectator", Color(100, 100, 100, 255))

CLASSES ={
	["Anti-tank"]={		
		weapons = {
			["w_wac_sraw"]={Vector(0,-50,2),Vector(0,80,7)}  --{lookat,campos}
		},
		defammo = {
			["pistol"] = 30,
			["sniperpenetratedround"] = 5,
		}
	},
	["Engineer"]={		
		weapons = {
			["w_wac_css_m3"]={Vector(0,0,2),Vector(0,50,7)},
			["w_wac_wrench"]={Vector(0,0,2),Vector(20,0,7)},
		},
		defammo = {
			["pistol"] = 30,
			["buckshot"] = 70,
		}
	},
	["Special Ops"]={		
		weapons = {
			["w_wac_tw_g36"]={Vector(0,0,2),Vector(0,50,7)},
			["w_wac_c4"]={Vector(0,1,2),Vector(20,0,7)},
		},
		defammo = {
			["pistol"] = 30,
			["smg1"] = 75,
			["StriderMinigun"] = 4,
		}
	},
	["Sniper"]={		
		weapons = {
			["w_wac_tw_m24"]={Vector(0,0,2),Vector(0,50,7)}
		},
		defammo = {
			["pistol"] = 30,
			["sniperround"] = 24,
		}
	},
}
