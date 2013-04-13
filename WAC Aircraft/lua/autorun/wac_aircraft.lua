
include "wac/aircraft.lua"

wac.aircraft.getWeapon = function(n,t2)
	if !wac.aircraft.weapons[n] then
		error("Could not find weapon \"" .. n .. "\"!", 2)
	end
	local t = table.Copy(wac.aircraft.weapons[n])
	if t2 then
		table.Merge(t,t2)
	end
	return t
end

local mat
local nextrandom=0
local dorandom=0
if CLIENT then
	mat=Material("pp/blurscreen")
end


wac.aircraft.weapons = {
	["No Weapon"]={
		Name="No Weapon",
		Ammo=0,
		func=function(self, t, p)end,
	},
	["2A42"]={
		Name="2A42",
		Ammo=250,
		MaxAmmo=250,
		NextShoot=1,
		LastShot=0,
		ShootDelay=0.2,
		MouseControl=true,
		ShootPos=Vector(180,0,20),
		CamPos=Vector(180,0,20),
		CrosshairHeight=10,
		CrosshairWidth=10,
		CrosshairLineh=20,
		CrosshairLinew=20,
		func=function(self, t, p)
			if t.NextShoot <= CurTime() then
				if t.Ammo>0 then
					self.Gun:GetPhysicsObject():AddAngleVelocity(Vector(200,0,0))
					local ang=self.Gun:GetAngles()
					local b=ents.Create("wac_hc_hebullet")
					local pos=self.Gun:GetPos()+self.Gun:GetForward()*100
					b:SetPos(pos)
					b:SetAngles(ang)
					b.col=Color(255,200,100)
					b.Speed=200
					b.Size=5
					b.Width=1
					b.Damage=20
					b.Radius=60
					b:Spawn()
					b.Owner=p
					self:EmitSound("WAC/cannon/havoc_cannon_1p.wav")
					self:EmitSound("WAC/cannon/havoc_cannon_3p.wav")
					local effectdata=EffectData()
					effectdata:SetOrigin(pos)
					effectdata:SetAngles(ang)
					effectdata:SetScale(1.5)
					util.Effect("MuzzleEffect", effectdata)
					t.Ammo=t.Ammo-1
					t.LastShot=CurTime()
					t.NextShoot=t.LastShot+t.ShootDelay
				end
				if t.Ammo<=0 then
					t.Ammo=t.MaxAmmo
					t.NextShoot=CurTime()+60
				end
			end
		end,
		Phys=function(self,t,p)
			self.MouseVector=self:WorldToLocal(self:GetPos()+p:GetAimVector()*5)
		end,
		DeSelect=function(self,t,p) self.MouseVector=Vector(0,0,0) end,
		CalcView=function(self,t,p,pos,ang,view)
			if p:GetViewEntity()!=p then return view end
			local e=self:GetNWEntity("wac_air_radar")
			if IsValid(e) then
				view.angles=e:GetAngles()
				view.origin=e:GetPos()+e:GetForward()*15
			end
			return view
		end,
		RenderScreenSpace=function(self,t,p)
			local crt=CurTime()
			if crt>nextrandom then
				dorandom=0
				dorandom=math.random(1,8)==1 and 2 or 0
				nextrandom=crt+0.1
			end
			mat:SetFloat("$blur", 1+dorandom)
			render.UpdateScreenEffectTexture()
			render.SetMaterial(mat)
			render.DrawScreenQuad()
			DrawColorModify({
				["$pp_colour_addr"] 		=0,
				["$pp_colour_addg"] 		=0,
				["$pp_colour_addb"] 		=0,
				["$pp_colour_brightness"] =0,
				["$pp_colour_contrast" ] 	=1,
				["$pp_colour_colour" ] 	=0.01,
				["$pp_colour_mulr" ] 	=0,
				["$pp_colour_mulg" ] 	=0,
				["$pp_colour_mulb" ] 	=0,
			})
		end,
		DrawCrosshair=function(self,t,p)
			local gun=self:GetNWEntity("gun")
			if !IsValid(gun) then return end
			local sw=ScrW()
			local sh=ScrH()
			local w=sh/6
			local s=sh/3
			local k=p:GetNWInt("wac_passenger_id")
			local aw=self:GetNWInt("seat_"..k.."_actwep")
			local lasts=self:GetNWFloat("seat_"..k.."_"..aw.."_lastshot")
			local nexts=self:GetNWFloat("seat_"..k.."_"..aw.."_nextshot")
			local ammo=self:GetNWInt("seat_"..k.."_"..aw.."_ammo")
			local width=t.CrosshairWidth or 30
			local height=t.CrosshairHeight or 20
			local lw=t.CrosshairLinew or 30
			local lh=t.CrosshairLineh or 20
			local tr=util.QuickTrace(gun:GetPos()+gun:GetForward()*50,gun:GetForward()*99999,gun)
			local pos=Vector(sw/2,sh/2)
			if ammo==t.MaxAmmo and nexts>CurTime() then
				surface.SetDrawColor(255,255,255,math.sin(CurTime()*10)*75+75)
			else
				surface.SetDrawColor(255,255,255,150)
			end
			surface.DrawOutlinedRect(pos.x-width,pos.y-height,width*2,height*2)
			surface.DrawOutlinedRect(pos.x-width-1,pos.y-height-1,width*2+2,height*2+2)
			surface.DrawLine(pos.x-1,pos.y-2-height,pos.x-1,pos.y-height-lh)
			surface.DrawLine(pos.x,pos.y-2-height,pos.x,pos.y-height-lh)
			surface.DrawLine(pos.x-1,pos.y+1+height,pos.x-1,pos.y+height+lh)
			surface.DrawLine(pos.x,pos.y+1+height,pos.x,pos.y+height+lh)
			surface.DrawLine(pos.x-1-width-lw,pos.y-1,pos.x-1-width,pos.y-1)
			surface.DrawLine(pos.x-1-width-lw,pos.y,pos.x-1-width,pos.y)
			surface.DrawLine(pos.x-1+width+lw,pos.y-1,pos.x+1+width,pos.y-1)
			surface.DrawLine(pos.x-1+width+lw,pos.y,pos.x+1+width,pos.y)
		end,
	},
	["25MM HE"]={
		Name="25MM HE",
		Ammo=250,
		MaxAmmo=250,
		NextShoot=1,
		LastShot=0,
		ShootDelay=0.2,
		MouseControl=true,
		ShootPos=Vector(180,0,20),
		CamPos=Vector(180,0,20),
		CrosshairHeight=10,
		CrosshairWidth=10,
		CrosshairLineh=20,
		CrosshairLinew=20,
		func=function(self, t, p)
			if t.NextShoot <= CurTime() then
				if t.Ammo>0 then
					self.Gun:GetPhysicsObject():AddAngleVelocity(Vector(200,0,0))
					local ang=self.Gun:GetAngles()--p:GetAimVector():Angle()
					local b=ents.Create("wac_hc_hebullet")
					local pos=self.Gun:GetPos()+self.Gun:GetForward()*60--self:LocalToWorld(t.ShootPos)+ang:Right()*5+ang:Forward()*10
					b:SetPos(pos)
					b:SetAngles(ang)
					b.col=Color(255,200,100)
					b.Speed=200
					b.Size=5
					b.Width=1
					b.Damage=20
					b.Radius=60
					b:Spawn()
					b.Owner=p
					self:EmitSound("WAC/cannon/havoc_cannon_1p.wav")
					self:EmitSound("WAC/cannon/havoc_cannon_3p.wav")
					local effectdata=EffectData()
					effectdata:SetOrigin(pos)
					effectdata:SetAngles(ang)
					effectdata:SetScale(1.5)
					util.Effect("MuzzleEffect", effectdata)
					t.Ammo=t.Ammo-1
					t.LastShot=CurTime()
					t.NextShoot=t.LastShot+t.ShootDelay
				end
				if t.Ammo<=0 then
					t.Ammo=t.MaxAmmo
					t.NextShoot=CurTime()+60
				end
			end
		end,
		Phys=function(self,t,p)
			self.MouseVector=self:WorldToLocal(self:GetPos()+p:GetAimVector()*5)
		end,
		DeSelect=function(self,t,p) self.MouseVector=Vector(0,0,0) end,
		CalcView=function(self,t,p,pos,ang,view)
			if p:GetViewEntity()!=p then return view end
			local e=self:GetNWEntity("gun")
			if IsValid(e) then
				view.angles=e:GetAngles()
				view.origin=e:GetPos()+e:GetRight()*5
			end
			return view
		end,
		RenderScreenSpace=function(self,t,p)
			local crt=CurTime()
			if crt>nextrandom then
				dorandom=0
				dorandom=math.random(1,8)==1 and 2 or 0
				nextrandom=crt+0.1
			end
			mat:SetFloat("$blur", 1+dorandom)
			render.UpdateScreenEffectTexture()
			render.SetMaterial(mat)
			render.DrawScreenQuad()
			DrawColorModify({
				["$pp_colour_addr"] 		=0,
				["$pp_colour_addg"] 		=0,
				["$pp_colour_addb"] 		=0,
				["$pp_colour_brightness"] =0,
				["$pp_colour_contrast" ] 	=1,
				["$pp_colour_colour" ] 	=0.01,
				["$pp_colour_mulr" ] 	=0,
				["$pp_colour_mulg" ] 	=0,
				["$pp_colour_mulb" ] 	=0,
			})
		end,
		DrawCrosshair=function(self,t,p)
			local gun=self:GetNWEntity("gun")
			if !IsValid(gun) then return end
			local sw=ScrW()
			local sh=ScrH()
			local w=sh/6
			local s=sh/3
			local k=p:GetNWInt("wac_passenger_id")
			local aw=self:GetNWInt("seat_"..k.."_actwep")
			local lasts=self:GetNWFloat("seat_"..k.."_"..aw.."_lastshot")
			local nexts=self:GetNWFloat("seat_"..k.."_"..aw.."_nextshot")
			local ammo=self:GetNWInt("seat_"..k.."_"..aw.."_ammo")
			local width=t.CrosshairWidth or 30
			local height=t.CrosshairHeight or 20
			local lw=t.CrosshairLinew or 30
			local lh=t.CrosshairLineh or 20
			local tr=util.QuickTrace(gun:GetPos()+gun:GetForward()*50,gun:GetForward()*99999,gun)
			local pos=tr.HitPos:ToScreen()
			if ammo==t.MaxAmmo and nexts>CurTime() then
				surface.SetDrawColor(255,255,255,math.sin(CurTime()*10)*75+75)
			else
				surface.SetDrawColor(255,255,255,150)
			end
			surface.DrawOutlinedRect(pos.x-width,pos.y-height,width*2,height*2)
			surface.DrawOutlinedRect(pos.x-width-1,pos.y-height-1,width*2+2,height*2+2)
			surface.DrawLine(pos.x-1,pos.y-2-height,pos.x-1,pos.y-height-lh)
			surface.DrawLine(pos.x,pos.y-2-height,pos.x,pos.y-height-lh)
			surface.DrawLine(pos.x-1,pos.y+1+height,pos.x-1,pos.y+height+lh)
			surface.DrawLine(pos.x,pos.y+1+height,pos.x,pos.y+height+lh)
			surface.DrawLine(pos.x-1-width-lw,pos.y-1,pos.x-1-width,pos.y-1)
			surface.DrawLine(pos.x-1-width-lw,pos.y,pos.x-1-width,pos.y)
			surface.DrawLine(pos.x-1+width+lw,pos.y-1,pos.x+1+width,pos.y-1)
			surface.DrawLine(pos.x-1+width+lw,pos.y,pos.x+1+width,pos.y)
		end,
	},
	["M134"]={
		Name="M134",
		Ammo=800,
		MaxAmmo=800,
		NextShoot=1,
		LastShot=0,
		Gun=1,
		ShootDelay=0.01,
		ShootPos1=Vector(40,40,30),
		ShootPos2=Vector(40,-40,30),
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
					bullet.Spread 	= Vector(0.015,0.015,0)
					bullet.Tracer		= 0
					bullet.Force		= 10
					bullet.Damage	= 20
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
		StopSounds=function(self,t,p)
			if t.Shooting then
				t.SShoot:Stop()
				t.SStop:Play()
				t.Shooting=false
			end				
		end,
		Init=function(self,t)
			t.SShoot=CreateSound(self,"Warkanum/minigun_shoot.wav")
			t.SStop=CreateSound(self,"Warkanum/minigun_wind_stop.wav")
		end,
		Think=function(self,t,p)
			if t.NextShoot<=CurTime() then
				t.StopSounds(self,t,p)
			end
		end,
		DeSelect=function(self,t,p)
			t.StopSounds(self,t,p)
		end,
	},
	["M197"]={
		Name="M197",
		Ammo=750,
		MaxAmmo=750,
		NextShoot=1,
		LastShot=0,
		ShootDelay=0.08,
		MouseControl=true,
		ShootPos=Vector(180,0,20),
		CamPos=Vector(180,0,20),
		CrosshairHeight=10,
		CrosshairWidth=10,
		CrosshairLineh=20,
		CrosshairLinew=20,
		func=function(self, t, p)
			if t.NextShoot <= CurTime() then
				local ph=self.Gun:GetPhysicsObject()
				if t.Ammo>0 and ph:GetAngleVelocity().x>1000 then
					local ang=self.Gun:GetAngles()--p:GetAimVector():Angle()
					local b=ents.Create("wac_hc_hebullet")
					local pos=self.Gun:GetPos()+self.Gun:GetForward()*60--self:LocalToWorld(t.ShootPos)+ang:Right()*5+ang:Forward()*10
					b:SetPos(pos)
					ang.p=ang.p+math.Rand(-1,1)*0.1
					ang.y=ang.y+math.Rand(-1,1)*0.1
					ang.r=ang.r+math.Rand(-1,1)*0.1
					b:SetAngles(ang)
					b.col=Color(255,200,100)
					b.Speed=400
					b.Size=0
					b.Width=0
					b:Spawn()
					b.Owner=p
					b.Explode=function(self,tr)
						if self.Exploded then return end
						self.Exploded = true
						if !tr.HitSky then
							self.Owner = self.Owner or self.Entity
							local bt={}
							bt.Src 		=self:GetPos()
							bt.Dir 		=tr.Normal
							bt.Force	=30
							bt.Damage	=60
							bt.Tracer	=0
							b.Owner:FireBullets(bt)
							local explode=ents.Create("env_physexplosion")
							explode:SetPos(tr.HitPos)
							explode:Spawn()
							explode:SetKeyValue("magnitude", 60)
							explode:SetKeyValue("radius", 10)
							explode:SetKeyValue("spawnflags", "19")
							explode:Fire("Explode", 0, 0)
							timer.Simple(5,function() explode:Remove() end)
							util.BlastDamage(self, self.Owner, tr.HitPos, 40, 20)
							local ed=EffectData()
							ed:SetEntity(self.Entity)
							ed:SetAngles(tr.HitNormal:Angle())
							ed:SetOrigin(tr.HitPos)
							ed:SetScale(30)
							util.Effect("wac_impact_m197",ed)
						end
						self.Entity:Remove()
					end
					self.Sound.GunSound1:Stop()
					self.Sound.GunSound1:Play()
					self.Sound.GunSound2:Stop()
					self.Sound.GunSound2:Play()
					local effectdata=EffectData()
					effectdata:SetOrigin(pos)
					effectdata:SetAngles(ang)
					effectdata:SetScale(1.5)
					util.Effect("MuzzleEffect", effectdata)
					t.Ammo=t.Ammo-1
					t.LastShot=CurTime()
					t.NextShoot=t.LastShot+t.ShootDelay
				end
				if t.Ammo<=0 then
					t.Ammo=t.MaxAmmo
					t.NextShoot=CurTime()+60
				end
				self.Gun:GetPhysicsObject():AddAngleVelocity(Vector(100,0,0))
			end
		end,
		Init=function(self,t)
			self.Sound.GunSound1=CreateSound(self,"WAC/cannon/viper_cannon_1p.wav")
			self.Sound.GunSound2=CreateSound(self,"WAC/cannon/viper_cannon_3p.wav")
			self.Sound.GunSoundSpin=CreateSound(self,"WAC/cannon/viper_cannon_rotate.wav")
			self.Sound.GunSoundSpin:Play()
			self.Sound.GunSoundSpin:ChangePitch(0,0.1)
			self.Sound.GunSoundSpin:ChangeVolume(0,0.1)
		end,
		Phys=function(self,t,p)
			self.MouseVector=self:WorldToLocal(self:GetPos()+p:GetAimVector()*5)
			if IsValid(self.Gun) then
				local pitch=self.Gun:GetPhysicsObject():GetAngleVelocity().x/10
				self.Sound.GunSoundSpin:ChangePitch(pitch,0.1)
				self.Sound.GunSoundSpin:ChangeVolume(math.Clamp(pitch/90,0,1)/2,0.1)
			end
		end,
		DeSelect=function(self,t,p)
			self.MouseVector=Vector(0,0,0)
			self.Sound.GunSoundSpin:ChangePitch(0,0.1)
			self.Sound.GunSoundSpin:ChangeVolume(0,0.1)
		end,
		CalcView=function(self,t,p,pos,ang,view)
			if p:GetViewEntity()!=p then return view end
			local e=self:GetNWEntity("wac_air_radar")
			if IsValid(e) then
				view.angles=e:GetAngles()
				view.origin=e:GetPos()-self:GetUp()*5
			end
			return view
		end,
		RenderScreenSpace=function(self,t,p)
			local crt=CurTime()
			if crt>nextrandom then
				dorandom=0
				dorandom=math.random(1,8)==1 and 2 or 0
				nextrandom=crt+0.1
			end
			mat:SetFloat("$blur", 1+dorandom)
			render.UpdateScreenEffectTexture()
			render.SetMaterial(mat)
			render.DrawScreenQuad()
			DrawColorModify({
				["$pp_colour_addr"] 		=0,
				["$pp_colour_addg"] 		=0,
				["$pp_colour_addb"] 		=0,
				["$pp_colour_brightness"] =0,
				["$pp_colour_contrast" ] 	=1,
				["$pp_colour_colour" ] 	=0.01,
				["$pp_colour_mulr" ] 	=0,
				["$pp_colour_mulg" ] 	=0,
				["$pp_colour_mulb" ] 	=0,
			})
		end,
		DrawCrosshair=function(self,t,p)
			local gun=self:GetNWEntity("gun")
			if !IsValid(gun) then return end
			local sw=ScrW()
			local sh=ScrH()
			local w=sh/6
			local s=sh/3
			local k=p:GetNWInt("wac_passenger_id")
			local aw=self:GetNWInt("seat_"..k.."_actwep")
			local lasts=self:GetNWFloat("seat_"..k.."_"..aw.."_lastshot")
			local nexts=self:GetNWFloat("seat_"..k.."_"..aw.."_nextshot")
			local ammo=self:GetNWInt("seat_"..k.."_"..aw.."_ammo")
			local width=t.CrosshairWidth or 30
			local height=t.CrosshairHeight or 20
			local lw=t.CrosshairLinew or 30
			local lh=t.CrosshairLineh or 20
			local tr=util.QuickTrace(gun:GetPos()+gun:GetForward()*50,gun:GetForward()*99999,gun)
			local pos=Vector(sw/2,sh/2)
			if ammo==t.MaxAmmo and nexts>CurTime() then
				surface.SetDrawColor(255,255,255,math.sin(CurTime()*10)*75+75)
			else
				surface.SetDrawColor(255,255,255,150)
			end
			surface.DrawOutlinedRect(pos.x-width,pos.y-height,width*2,height*2)
			surface.DrawOutlinedRect(pos.x-width-1,pos.y-height-1,width*2+2,height*2+2)
			surface.DrawLine(pos.x-1,pos.y-2-height,pos.x-1,pos.y-height-lh)
			surface.DrawLine(pos.x,pos.y-2-height,pos.x,pos.y-height-lh)
			surface.DrawLine(pos.x-1,pos.y+1+height,pos.x-1,pos.y+height+lh)
			surface.DrawLine(pos.x,pos.y+1+height,pos.x,pos.y+height+lh)
			surface.DrawLine(pos.x-1-width-lw,pos.y-1,pos.x-1-width,pos.y-1)
			surface.DrawLine(pos.x-1-width-lw,pos.y,pos.x-1-width,pos.y)
			surface.DrawLine(pos.x-1+width+lw,pos.y-1,pos.x+1+width,pos.y-1)
			surface.DrawLine(pos.x-1+width+lw,pos.y,pos.x+1+width,pos.y)
		end,
	},
	["Hellfire"]={
		Name="Hellfire",
		Ammo=8,
		MaxAmmo=8,
		NextShoot=1,
		LastShot=0,
		ShootDelay=2,
		Gun=1,
		MouseControl=true,
		ShootPos={
			[1]=Vector(50,60,40),
			[2]=Vector(50,-60,40),
		},
		CamPos=Vector(180,0,30),
		func=function(self,t,p)
			if t.NextShoot<=CurTime() then
				if t.Ammo>0 then
					if IsValid(t.rocket) and t.rocket.Owner==p then
						t.rocket.Aimed=false
						t.rocket=nil
					end
					local rocket=ents.Create("wac_hc_rocket")
					rocket:SetPos(self:LocalToWorld(t.ShootPos[t.Gun]))
					rocket:SetAngles(self:GetAngles())
					rocket.Owner=p
					rocket.Damage=450
					rocket.Radius=200
					rocket.Speed=10
					rocket.TrailLength=500
					rocket.Scale=7
					rocket.SmokeDens=1
					rocket.AngAddMul=20
					rocket.Fuel=100
					rocket:Spawn()
					rocket.Aimed=2
					rocket.Launcher=self
					rocket.StartTime=CurTime()+0.2
					t.rocket=rocket
					p:SetNWEntity("wac_air_cam",rocket)
					local ph=rocket:GetPhysicsObject()
					if ph:IsValid() then
						ph:SetVelocity(self:GetVelocity()+self:GetForward()*2000)
					end
					self:EmitSound("USATP_predator/Fire_1p.wav");
					constraint.NoCollide(self,rocket,0,0)
					t.Gun=(t.Gun==1 and 2 or 1)
					t.Ammo=t.Ammo-1
					t.LastShot=CurTime()
					t.NextShoot=t.LastShot+t.ShootDelay
					self:SetNWInt("rocket_podside_2",t.Gun)
				end
				if t.Ammo<=0 then
					t.Ammo=t.MaxAmmo
					t.NextShoot=CurTime()+60
				end
			end
		end,
		Phys=function(self,t,p)
			self.MouseVector=self:WorldToLocal(self:GetPos()+p:GetAimVector()*5)
			if IsValid(t.rocket) then
				t.rocket.TargetPos=util.QuickTrace(self.Gun:GetPos()+self.Gun:GetForward()*20,self.Gun:GetForward()*100000).HitPos
			end
		end,
		DeSelect = function(self,t,p)
			self.MouseVector = Vector(0,0,0)
			if IsValid(t.rocket) and t.rocket.Owner == p then
				t.rocket.Aimed = false
				t.rocket = nil
			end
		end,
		RenderScreenSpace=function(self,t,p)
			local crt=CurTime()
			if crt>nextrandom then
				dorandom=0
				dorandom=math.random(1,8)==1 and 2 or 0
				nextrandom=crt+0.1
			end
			mat:SetFloat("$blur", 1+dorandom)
			render.UpdateScreenEffectTexture()
			render.SetMaterial(mat)
			render.DrawScreenQuad()
			DrawColorModify({
				["$pp_colour_addr"] 		=0,
				["$pp_colour_addg"] 		=0,
				["$pp_colour_addb"] 		=0,
				["$pp_colour_brightness"] =0,
				["$pp_colour_contrast" ] 	=1,
				["$pp_colour_colour" ] 	=0.01,
				["$pp_colour_mulr" ] 	=0,
				["$pp_colour_mulg" ] 	=0,
				["$pp_colour_mulb" ] 	=0,
			})
		end,
		CalcView=function(self,t,p,pos,ang,view)
			if p:GetViewEntity()!=p then return view end
			local e=self:GetNWEntity("wac_air_radar")
			if IsValid(e) then
				view.angles=e:GetAngles()
				view.origin=e:GetPos()-self:GetUp()*5
			end
			return view
		end,
	},
	["Hydra 70"]={
		Name="Hydra 70",
		Ammo=14,
		MaxAmmo=14,
		NextShoot=1,
		LastShot=0,
		ShootDelay=0.3,
		Gun=1,
		ShootPos={
			[1]=Vector(50,40,40),
			[2]=Vector(50,-40,40),
		},
		func=function(self,t,p)
			if t.NextShoot<=CurTime() then
				if t.Ammo>0 then
					local rocket=ents.Create("wac_hc_rocket")
					rocket:SetPos(self:LocalToWorld(t.ShootPos[t.Gun]))
					rocket:SetAngles(self:GetAngles())
					rocket.Owner=p
					rocket.Damage=150
					rocket.Radius=200
					rocket.Speed=500
					rocket.Drag=Vector(0,1,1)
					rocket.TrailLength=200
					rocket.Scale=15
					rocket.SmokeDens=1
					rocket.Launcher=self
					rocket:Spawn()
					rocket:StartRocket()
					local ph=rocket:GetPhysicsObject()
					if ph:IsValid() then
						ph:SetVelocity(self:GetVelocity())
						ph:AddAngleVelocity(self:GetPhysicsObject():GetAngleVelocity() + Vector(30,0,0))
					end
					self.Sound.MissileShoot:Stop()
					self.Sound.MissileShoot:Play()
					constraint.NoCollide(self,rocket,0,0)
					t.Gun=(t.Gun==1 and 2 or 1)
					t.Ammo=t.Ammo-1
					t.LastShot=CurTime()
					t.NextShoot=t.LastShot+t.ShootDelay
				end
				if t.Ammo<=0 then
					t.Ammo=t.MaxAmmo
					t.NextShoot=CurTime()+60
				end
			end
		end,
	},
}
