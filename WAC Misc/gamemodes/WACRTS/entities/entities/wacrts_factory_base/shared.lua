 ENT.Type 		= "anim"
 ENT.Base 		= "base_gmodentity" 
 ENT.PrintName 	= ""
 ENT.Author 		= "WeltEnSTurm"
 ENT.Category 	= WAC.Names.Sents.Weapons
 ENT.Spawnable 	= false
 ENT.AdminSpawnable = false

ENT.IsRTSUnit=true
ENT.IsRTSFactory=true

ENT.CreateableEnts={
	["wacrts_tank_base"]={
		model="models/WeltEnSTurm/RTS/tanks/tank02_body.mdl",
		name="Basic Tank",
		postfix="base",
		res=100,
	},
	["wacrts_tank_artillery01"]={
		model="models/WeltEnSTurm/RTS/tanks/tank03_body.mdl",
		name="Artillery",
		postfix="artillery01",
		res=500,
	}
}
