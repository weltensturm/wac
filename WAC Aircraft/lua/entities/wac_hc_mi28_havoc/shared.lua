
ENT.Base = "wac_hc_base"
ENT.Type = "anim"
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.PrintName = "Havoc Mi-28"

ENT.Model = "models/BF2/helicopters/Mil Mi-28/mi28_b.mdl"
ENT.RotorPhModel = "models/props_junk/sawblade001a.mdl"
ENT.RotorModel = "models/BF2/helicopters/Mil Mi-28/mi28_r.mdl"
ENT.BackRotorModel = "models/BF2/helicopters/Mil Mi-28/mi28_tr.mdl"

ENT.TopRotorPos = Vector(0,0,119)
ENT.TopRotorDir = 1
ENT.BackRotorPos = Vector(-435.09,18.46,164.91)
ENT.BackRotorDir = 1
ENT.SmokePos = Vector(-80,0,50)
ENT.FirePos = Vector(-50,0,100)
ENT.MaxEnterDistance = 100
ENT.EngineForce	= 30
ENT.Weight = 9000

function ENT:AddSeatTable()
	return{
		[1]={
			Pos=Vector(54.74,0,85.22),
			ExitPos=Vector(54.74,80,5),
			wep={
				WAC.Helicopter.GetWeapon("Hydra 70",{
					Name="S-8",
					Ammo=40,
					MaxAmmo=40,
					Damage=70,
					ShootDelay=0.2,
					ShootPos={
						Vector(3.22,72.94,49),
						Vector(3.22,-72.94,49),
					}
				})
			},
		},
		[2]={
			Pos=Vector(115.3,0,61),
			ExitPos=Vector(115.3,60,5),
			wep={
				WAC.Helicopter.GetWeapon("No Weapon"),
				WAC.Helicopter.GetWeapon("2A42"),
				WAC.Helicopter.GetWeapon("Hellfire",{
					Name="9M120",
					ShootPos={
						Vector(3.22,102.38,59.59),
						Vector(3.22,-102.38,59.59),
					},
					CalcView=function(self,t,p,pos,ang,view)
						if p:GetViewEntity()!=p then return view end
						local e=self:GetNWEntity("wac_air_radar")
						if IsValid(e) then
							view.angles=e:GetAngles()
							view.origin=e:GetPos()+e:GetForward()*15
						end
						return view
					end,
				}),
			},
		},
	}
end

function ENT:AddSounds()
	self.Sound={
		Start=CreateSound(self.Entity,"WAC/Heli/ah1_start.wav"),
		Blades=CreateSound(self.Entity,"npc/attack_helicopter/aheli_rotor_loop1.wav"),
		Engine=CreateSound(self.Entity,"WAC/heli/bellinternal.wav"),
		MissileAlert=CreateSound(self.Entity,"HelicopterVehicle/MissileNearby.mp3"),
		MissileShoot=CreateSound(self.Entity,"HelicopterVehicle/MissileShoot.mp3"),
		MinorAlarm=CreateSound(self.Entity,"HelicopterVehicle/MinorAlarm.mp3"),
		LowHealth=CreateSound(self.Entity,"HelicopterVehicle/LowHealth.mp3"),
		CrashAlarm=CreateSound(self.Entity,"HelicopterVehicle/CrashAlarm.mp3"),
	}
end
