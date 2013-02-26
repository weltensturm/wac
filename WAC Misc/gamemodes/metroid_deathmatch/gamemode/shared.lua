
GM.Name 		= "Metroid Prime Deathmatch"
GM.Author 	= "WeltEnSTurm"
GM.Email 		= ""
GM.Website 	= ""

DeriveGamemode("fretta")
IncludePlayerClasses()	

GM.Help					= "Run. Shoot."
GM.TeamBased 				= false
GM.AllowAutoTeam 			= true
GM.AllowSpectating 			= true
GM.SelectClass 				= false
GM.GameLength 			= 10
GM.NoPlayerDamage 			= false
GM.NoPlayerSelfDamage 		= false
GM.NoPlayerTeamDamage 		= false
GM.NoPlayerPlayerDamage 	= false
GM.NoNonPlayerPlayerDamage 	= false
GM.TakeFragOnSuicide 		= false
GM.AddFragsToTeamScore		= true

TEAM_ORANGE = 1


function GM:CreateTeams()
	if (!GAMEMODE.TeamBased) then return end
	team.SetUp(TEAM_ORANGE, "Players", Color(255, 200, 50), true)
	team.SetSpawnPoint(TEAM_ORANGE, {"info_player_start", "info_player_terrorist", "info_player_counterterrorist"})
end
