
ENT.Base = "wac_helicopter_base"
ENT.Type = "anim"
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.PrintName = "Black Shark Ka-50"

ENT.Model = "models/sentry/ka-50.mdl"

ENT.Weight = 9000

ENT.SmokePos = Vector(-80,0,50)
ENT.FirePos = Vector(-50,0,100)

ENT.Wheels = {
	{
		model = "models/sentry/ka-50_fwheel.mdl",
		pos = Vector(163,0,7),
		friction = 100,
		mass = 250,
	},
	{
		model = "models/sentry/ka-50_bwheel.mdl",
		pos = Vector(-25.5,-56,15),
		friction = 100,
		mass = 550
	},
	{
		model = "models/sentry/ka-50_bwheel.mdl",
		pos = Vector(-25.5,56,15),
		friction = 100,
		mass = 550,
	},

}

ENT.Rotors = {
	{
		model = "models/sentry/ka-50_br.mdl",
		pos = Vector(30,0,106),
		angle = Angle(0,0,0),
		dir = 1,
		targetVel = 360
	},
	{
		model = "models/sentry/ka-50_tr.mdl",
		pos = Vector(30,0,158.5),
		angle = Angle(0,0,0),
		dir = -1,
		targetVel = 360
	}
}

ENT.self.Seats = {
	[1]={
        Pos=Vector(116, 0, 52),
        ExitPos=Vector(160,70,40),
        NoHud=false,
		wep={
			[1]=wac.aircraft.getWeapon("M134",{
				Name="Shipunov 2A42",
				Ammo=460,
				MaxAmmo=460,
				NextShoot=1,
				LastShot=0,
				Gun=1,
				ShootDelay=0.04,
				ShootPos1=Vector(140,-35,43),
				ShootPos2=Vector(140,-35,43),
				func=function(self, t, p)
					if t.NextShoot <= CurTime() then
						if t.Ammo>0 then
							if !t.Shooting then
								t.Shooting=true
								t.SStop:Stop()
								t.SShoot:Play()
							end
							local bullet={}
							bullet.Num 		= 1
							bullet.Src 		= self:LocalToWorld(t.Gun==1 and t.ShootPos1 or t.ShootPos2)
							bullet.Dir 		= self:GetForward()
							bullet.Spread 	= Vector(0.023,0.023,0)
							bullet.Tracer		= 0
							bullet.Force		= 10
							bullet.Damage	= 80
							bullet.Attacker 	= p
							local effectdata=EffectData()
							effectdata:SetOrigin(bullet.Src)
							effectdata:SetAngles(self:GetAngles())
							effectdata:SetScale(1.5)
							util.Effect("MuzzleEffect", effectdata)
							self.Entity:FireBullets(bullet)
							t.Gun=(t.Gun==1 and 2 or 1)
							t.Ammo=t.Ammo-1
							t.LastShot=CurTime()
							t.NextShoot=t.LastShot+t.ShootDelay
							local ph=self:GetPhysicsObject()
							if ph:IsValid() then
								ph:AddAngleVelocity(Vector(0,0,t.Gun==1 and 3 or -3))
							end
						end
						if t.Ammo<=0 then
							t.StopSounds(self,t,p)
							t.Ammo=t.MaxAmmo
							t.NextShoot=CurTime()+60
						end
					end
				end,
				Init=function(self,t)
					t.SShoot=CreateSound(self,"WAC/KA-50/2A42.wav")
					t.SStop=CreateSound(self,"WAC/KA-50/2A42_stop.wav")
				end
			}),
			[2]=wac.aircraft.getWeapon("Hydra 70",{
				Name="S-8",
				Ammo=80,
				MaxAmmo=80,
				ShootPos={
					[1]=Vector(14,-80,46),
					[2]=Vector(14,80,46),
				}
			}),	
		},
	},
}

ENT.Sounds = {
	start = "WAC/KA-50/start.wav",
	blades = "KA50.External",
	engine = "KA50.Internal",
	missileAlert = "WAC/Heli/heatseeker_track_warning.wav",
	missileShoot = "HelicopterVehicle/MissileShoot.mp3",
	minorAlarm = "WAC/Heli/fire_alarm_tank.wav",
	lowHealth = "WAC/Heli/fire_alarm.wav",
	crashAlarm = "WAC/Heli/laser_warning.wav",
}

