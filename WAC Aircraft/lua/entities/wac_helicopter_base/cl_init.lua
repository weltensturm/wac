
include("shared.lua")

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.thirdPerson = {
	distance = 600,
	angle = 10,
	position = Vector(-50,0,100)
}

function ENT:Initialize()
	self:setSounds()
	self.SmoothUp = 0
	self.engineRpm = 0
	self.rotorRpm = 0
	self.Emitter = ParticleEmitter(self:GetPos())
	self.IsOn = false
	self.LastThink = CurTime()
	self.AngVel = Angle(0,0,0)
	self.RotorTime = 0
end



function ENT:Think()
	if !self:GetNWBool("locked") then
		local mouseFlight = self:GetNWBool("active")
		if self.sounds.start then
			if mouseFlight!=self.IsOn then
				if mouseFlight then
					self.sounds.start:Play()
				else
					self.sounds.start:Stop()
				end
				self.IsOn = mouseFlight
			end
		end
		if !self.sounds.engine:IsPlaying() then
			self.sounds.engine:ChangePitch(0,0.1)
			self.sounds.engine:Play()
		end
		if !self.sounds.blades:IsPlaying() then
			self.sounds.blades:ChangePitch(0,0.1)
			self.sounds.blades:Play()
		end
		local frt=CurTime()-self.LastThink
		local e=LocalPlayer():GetViewEntity()
		if !IsValid(e) then e=LocalPlayer() end
		local pos=e:GetPos()
		local spos=self:GetPos()
		local doppler=(pos:Distance(spos+e:GetVelocity())-pos:Distance(spos+self:GetVelocity()))/200*self.rotorRpm

		self.SmoothUp = self.SmoothUp - (self.SmoothUp-self:GetNWFloat("up"))*frt*10
		self.rotorRpm = self.rotorRpm - (self.rotorRpm-self:GetNWFloat("rotorRpm"))*frt*10
		self.engineRpm = self.engineRpm - (self.engineRpm-self:GetNWFloat("engineRpm"))*frt*10

		local engineVal = math.Clamp(self.engineRpm*100+self.engineRpm*self.SmoothUp*3+doppler, 0, 200)
		local val = math.Clamp(self.rotorRpm*100 + doppler, 0, 200)

		local vehicle = LocalPlayer():GetVehicle()
		local inVehicle = false
		if 
			IsValid(vehicle)
			and !vehicle:GetThirdPersonMode()
			and vehicle:GetNetworkedEntity("wac_aircraft") == self
		then
			inVehicle = true
		end
		self.sounds.engine:ChangePitch(engineVal/1.1 + val/10, 0.1)
		self.sounds.engine:ChangeVolume(math.Clamp(engineVal*engineVal/4000, 0, inVehicle and 1 or 5), 0.1)
		self.sounds.blades:ChangePitch(math.Clamp(val, 10, 150), 0.1)
		self.sounds.blades:ChangeVolume(math.Clamp(val*val/5000, 0, inVehicle and 0.4 or 5), 0.1)
		if self.sounds.start then
			self.sounds.start:ChangeVolume(math.Clamp(100 - self.engineRpm*110, 0, 100)/100, 0.1)
			self.sounds.start:ChangePitch(100 - self.engineRpm*20, 0.1)
		end
		self.LastThink=CurTime()
	else
		self.sounds.engine:Stop()
		self.sounds.blades:Stop()
		if self.sounds.start then
			self.sounds.start:Stop()
		end
	end
end

function ENT:OnRemove()
	for _,s in pairs(self.sounds) do
		s:Stop()
	end
end

function ENT:DrawHUD(k,p)
	if !self.Seats or !self.Seats[k] then return end
	local activeWeapon=self:GetNWInt("seat_"..k.."_actwep")
	local twep=self.Seats[k].wep[activeWeapon]
	if twep.CamPos and p:GetViewEntity()==p then
		local sw=ScrW()
		local sh=ScrH()
		
		local w=sh/6
		local s=sh/3
		
		surface.SetDrawColor(255,255,255,150)
		
		surface.DrawLine(sw/2-s, sh/2-s, sw/2-s+w, sh/2-s)
		surface.DrawLine(sw/2-s, sh/2-s, sw/2-s, sh/2-s+w)
		
		surface.DrawLine(sw/2+s, sh/2-s, sw/2+s-w, sh/2-s)
		surface.DrawLine(sw/2+s, sh/2-s, sw/2+s, sh/2-s+w)
		
		surface.DrawLine(sw/2-s, sh/2+s, sw/2-s+w, sh/2+s)
		surface.DrawLine(sw/2-s, sh/2+s, sw/2-s, sh/2+s-w)
		
		surface.DrawLine(sw/2+s, sh/2+s, sw/2+s-w, sh/2+s)
		surface.DrawLine(sw/2+s, sh/2+s, sw/2+s, sh/2+s-w)
		
		local lasts=self:GetNWFloat("seat_"..k.."_"..activeWeapon.."_lastshot")
		local nexts=self:GetNWFloat("seat_"..k.."_"..activeWeapon.."_nextshot")
		local ammo=self:GetNWInt("seat_"..k.."_"..activeWeapon.."_ammo")
	
		local width=twep.CrosshairWidth or 30
		local height=twep.CrosshairHeight or 20
		local lw=twep.CrosshairLinew or 30
		local lh=twep.CrosshairLineh or 20
		
		if twep.DrawCrosshair then
			twep.DrawCrosshair(self,twep,LocalPlayer())
		else
			if ammo==self.Seats[k].wep[self:GetNWInt("seat_"..k.."_actwep")].MaxAmmo and nexts>CurTime() then
				surface.SetDrawColor(255,255,255,math.sin(CurTime()*10)*75+75)
			else
				surface.SetDrawColor(255,255,255,150)
			end
			
			surface.DrawOutlinedRect(sw/2-width,sh/2-height,width*2,height*2)
			surface.DrawOutlinedRect(sw/2-width-1,sh/2-height-1,width*2+2,height*2+2)
			
			surface.DrawLine(sw/2,sh/2-height,sw/2,sh/2-height-lh)
			surface.DrawLine(sw/2-1,sh/2-height-1,sw/2-1,sh/2-height-lh)

			surface.DrawLine(sw/2,sh/2+height,sw/2,sh/2+height+lh)
			surface.DrawLine(sw/2-1,sh/2+height+1,sw/2-1,sh/2+height+lh)
			
			surface.DrawLine(sw/2-width-1,sh/2,sw/2-width-lw-1,sh/2)
			surface.DrawLine(sw/2-width-1,sh/2-1,sw/2-width-lw-1,sh/2-1)
			
			surface.DrawLine(sw/2+width+1,sh/2,sw/2+width+lw+1,sh/2)
			surface.DrawLine(sw/2+width+1,sh/2-1,sw/2+width+lw+1,sh/2-1)
		end
		
		local count=0
		for i,wep in pairs(self.Seats[k].wep) do
			if type(wep)=="table" and wep.Name!="No Weapon" then
				count=count+1
				if i==self:GetNWInt("seat_"..k.."_actwep") then			--background active weapon
					surface.SetDrawColor(10,10,10,150)
					surface.DrawRect(sw/2+w*2,sh/7+count*50,w*2+10,50)
				end
			end
		end
		surface.SetDrawColor(10,10,10,100)								--background
		surface.DrawRect(sw/2+w*2,sh/7+50,w*2+10,count*50)
		surface.SetDrawColor(255,255,255,200)
		surface.DrawOutlinedRect(sw/2+w*2,sh/7+50,w*2+10,count*50)	--background outline
		surface.SetFont("wac_heli_small")
		surface.SetTextColor(230,230,230,255)
		local h=1
		for i,wep in pairs(self.Seats[k].wep) do
			if type(wep)=="table" and wep.Name!="No Weapon" then		--weapon name and ammo
				local freeView=self:GetNWInt("seat_"..k.."_"..i.."_ammo")
				surface.SetTextPos(sw/2+w*2+5,sh/7+5+h*50)
				surface.DrawText(wep.Name)
				surface.SetTextPos(sw/2+w*4+5-string.len(freeView)*14,sh/7+5+h*50)
				surface.DrawText(freeView)
				surface.SetDrawColor(255,255,255,200)
				local lastshot=self:GetNWFloat("seat_"..k.."_"..i.."_lastshot")
				local nextshot=self:GetNWFloat("seat_"..k.."_"..i.."_nextshot")
				surface.DrawRect(sw/2+w*2,sh/7+h*50+40,(w*2+10)*math.Clamp((nextshot-CurTime())/(nextshot-lastshot),0,1),10)
				h=h+1
			end
		end
		--[[surface.SetDrawColor(255,255,255,200)
		surface.DrawRect(sw/2+w*2+5,sh/7+10+h*50,math.Clamp((nexts-CurTime())/(nexts-lasts),0,1)*70,10)
		surface.SetTextPos(sw/2+w*2+5,sh/7+20+h*50)
		--surface.SetFont("MenuLarge")
		if ammo==self.Seats[k].wep[self:GetNWInt("seat_"..k.."_actwep")].MaxAmmo and nexts>CurTime() then
			surface.SetTextColor(255,255,255,math.sin(CurTime()*10)*100+100)
			surface.DrawText("RELOADING")
		else
			surface.SetTextColor(255,255,255,200)
			surface.DrawText(ammo)
		end]]
	end
end

function ENT:onViewSwitch(p, thirdPerson)
	self.viewPos = nil
end

function ENT:onEnter(p)
	p.wac.lagAngles =  self:GetAngles()
	p.wac.lagPos = self:GetPos()
	p.wac.lagSpeed = Vector(0, 0, 0)
	p.wac.lagAccel = Vector(0, 0, 0)
	p.wac.lagAccelDelta = Vector(0, 0, 0)
	p.wac.air.vehicle = self
end

function ENT:viewCalcThirdPerson(k, p, view)
	local ang;
	if
			k == 1
			and p:GetInfo("wac_cl_air_mouse") == "1"
			and !wac.key.down(tonumber(p:GetInfo("wac_cl_air_key_15")))
			and p:GetInfo("wac_cl_air_usejoystick") == "0"
	then
		ang = self:GetAngles()
	else
		ang = p:GetAimVector():Angle()
		ang.r = view.angles.r
	end
	ang:RotateAroundAxis(ang:Right(), -self.thirdPerson.angle)
	local origin = self:LocalToWorld(self.thirdPerson.position)
	local tr = util.QuickTrace(
			origin,
			ang:Forward()*-self.thirdPerson.distance,
			{self.Entity, self:GetNWEntity("wac_air_rotor_rear"), self:GetNWEntity("wac_air_rotor_main")}
	)
	self.viewTarget = {
		origin = (tr.HitPos - tr.Normal*5) - view.origin,
		angles = ang - self:GetAngles()
	}
	return view
end

function ENT:viewCalcFirstPerson(k, p, view)
	p.wac = p.wac or {}
	if wac.key.down(tonumber(p:GetInfo("wac_cl_air_key_15"))) then
		if !p.wac.viewFree then
			p.wac.viewFree = true
		end
	else
		if p.wac.viewFree then
			p.wac.viewFree = false
			p.wac_air_resetview = true
			MsgN("reset view")
		end
	end
	if
		k == 1
		and p:GetInfo("wac_cl_air_mouse") == "1"
		and !p.wac.viewFree
		and p:GetInfo("wac_cl_air_usejoystick") == "0"
	then
		self.viewTarget = {
			origin = Vector(0,0,0),
			angles = Angle(0,0,0),
			fov = view.fov
		}
	else
		self.viewTarget = {
			origin = Vector(0,0,0),
			angles = view.angles - self:GetAngles(),
			fov = view.fov
		}
		--self.viewTarget.angles.r = self.viewTarget.angles.r + view.angles.r
	end
	return view
end

function ENT:viewCalcExit(p, view)
	p.wac.air.vehicle = nil
end

local lastWeapon=0
function ENT:viewCalc(k, p, pos, ang, fov)
	if !self.Seats[k] then return end
	local view = {origin = pos, angles = ang, fov = fov}

	if p:GetVehicle():GetNWEntity("wac_aircraft") != self then
		--p.wac.air.vehicle = nil
		return self:viewCalcExit(p, view)
	end

	wac.smoothApproachAngles(p.wac.lagAngles, self:GetAngles(), 20)
	local shakeEnabled = p:GetInfo("wac_cl_air_shakeview") == "1"
	if shakeEnabled then
		wac.smoothApproachVector(p.wac.lagPos, self:GetPos(), 20)
		wac.smoothApproachVector(p.wac.lagSpeed, p.wac.lagPos-self:GetPos(), 20)
		wac.smoothApproachVector(p.wac.lagAccel, p.wac.lagSpeed, 20)
		wac.smoothApproachVector(p.wac.lagAccelDelta, p.wac.lagAccel, 20)
	end

	local seat = self.Seats[k]
	local activeWeapon = self:GetNWInt("seat_"..k.."_actwep")
	local weapon = seat.wep[activeWeapon]
	if weapon.CalcView then
		view = weapon.CalcView(self,weapon,p,pos,ang,view)
		if lastWeapon != activeWeapon then
			p.wac_air_resetview = true
			lastWeapon = activeWeapon
		end
	elseif seat.CalcView then
		view = seat.CalcView(self,weapon,p,pos,ang,view)
	else
		if p:GetVehicle():GetThirdPersonMode() then
			view = self:viewCalcThirdPerson(k, p, view)
		else
			view = self:viewCalcFirstPerson(k, p, view)
		end
	end
	if self.viewTarget then
		self.viewPos = self.viewPos or table.Copy(self.viewTarget)
		wac.smoothApproachVector(self.viewPos.origin, self.viewTarget.origin, 30)
		wac.smoothApproachAngles(self.viewPos.angles, self.viewTarget.angles, 30)
		view.origin = view.origin + self.viewPos.origin
		if p:GetInfo("wac_cl_air_smoothview") == "1" then
			view.angles = self:GetAngles()*2 + self.viewPos.angles - p.wac.lagAngles
			if shakeEnabled then
				view.origin = view.origin + (p.wac.lagAccel - p.wac.lagAccelDelta)/4
			end
		else
			view.angles = self:GetAngles() + self.viewPos.angles
		end
		self.viewTarget = nil
	end
	return view
end

function ENT:MovePlayerView(k,p,md)
	if p.wac_air_resetview then md:SetViewAngles(Angle(0,90,0)) p.wac_air_resetview=false end
	local freeView = md:GetViewAngles()
	local id = self:GetNWInt("seat_"..k.."_actwep")
	if !self.Seats or !self.Seats[k] or !self.Seats[k].wep[id] then return end
	if (k==1 and p:GetInfo("wac_cl_air_mouse")=="1" and p:GetInfo("wac_cl_air_usejoystick")=="0" and !wac.key.down(tonumber(p:GetInfo("wac_cl_air_key_15")))) or (self.Seats and self.Seats[k].wep[id].MouseControl) then
		freeView.p = freeView.p-freeView.p*FrameTime()*6
		freeView.y = freeView.y-(freeView.y-90)*FrameTime()*6
	else
		freeView.p = math.Clamp(freeView.p,-90,90)
	end
	freeView.y = (freeView.y<-90 and -180 or (freeView.y<0 and 0 or freeView.y))
	md:SetViewAngles(freeView)
end

function ENT:DrawScreenSpaceEffects(k,p)
	if !self.Seats or !self.Seats[k] or p:GetViewEntity()!=p then return end
	local twep=self.Seats[k].wep[self:GetNWInt("seat_"..k.."_actwep")]
	if twep.RenderScreenSpace then twep.RenderScreenSpace(self,twep,p) end
end

function ENT:DrawRotor()
	if IsValid(self.BlurCModel) and self.rotorRpm>0.6 then
		self.RotorTime=self.RotorTime+self.rotorRpm*FrameTime()
		self.BlurCModel:SetPos(self:LocalToWorld(self.TopRotorPos))
		local ang=self:GetAngles()
		ang:RotateAroundAxis(self:GetUp(),-self.RotorTime*1000)
		self.BlurCModel:SetAngles(ang)
		self.BlurCModel:DrawModel()
	end
end

local HudMat=Material("WeltEnSTurm/helihud/arrow")
local HudCol=Color(70,199,50,150)
local Black=Color(0,0,0,200)
function ENT:DrawPilotHud()
	local pos = self:GetPos()
	local fwd = self:GetForward()
	local ri = self:GetRight()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ri, 90)
	ang:RotateAroundAxis(fwd, 90)
	
	local uptm = self.rotorRpm
	local upm = self.SmoothUp
	local spos=self.Seats[1].Pos
	cam.Start3D2D(self:LocalToWorld(Vector(20,3.75,37.75)+spos), ang,0.015)
	surface.SetDrawColor(HudCol)
	surface.DrawRect(235, 249, 10, 2)
	surface.DrawRect(255, 249, 10, 2)
	surface.DrawRect(249, 235, 2, 10)
	surface.DrawRect(249, 255, 2, 10)
	surface.DrawRect(-3, 0, 3, 500)
	surface.DrawRect(500, 0, 3, 500)
	surface.DrawRect(7, 0, 3, 500)
	surface.DrawRect(490, 0, 3, 500)
	
	surface.DrawRect(-6,-3,19,3)
	surface.DrawRect(-6,500,19,3)
	surface.DrawRect(487,-3,19,3)
	surface.DrawRect(487,500,19,3)
	surface.DrawRect(9,248,5,3)
	surface.DrawRect(485,248,5,3)
	
	surface.DrawRect(1, 500-uptm*500, 5, uptm*500)
	surface.DrawLine(30, 5*ang.r-200+2.77*ang.p, 220, 5*ang.r-200+2.77*(ang.p*0.12))
	surface.DrawLine(30, 5*ang.r-200+2.77*ang.p+1, 220, 5*ang.r-200+2.77*(ang.p*0.12)+1)
	surface.DrawLine(280, 5*ang.r-200-2.77*(ang.p*0.12), 470, 5*ang.r-200-2.77*ang.p)
	surface.DrawLine(280, 5*ang.r-200-2.77*(ang.p*0.12)+1, 470, 5*ang.r-200-2.77*ang.p+1)
	surface.SetMaterial(HudMat)
	surface.DrawTexturedRect(-20,250-upm*250-10,20,20)
	surface.DrawTexturedRectRotated(498,math.Clamp(250-self:GetVelocity().z/5.249*2,0,500),20,20,180)
	surface.SetTextColor(HudCol)
	surface.SetFont("wac_heli_small")
	surface.SetTextPos(-10, 505) 
	surface.DrawText("SPD")
	surface.SetTextPos(-10, 520)
	surface.DrawText(math.floor(self:GetVelocity():Length()*0.1)) --knots (real would be 0.037147, but fuck it)
	
	if self:GetNWBool("hover") then
		surface.SetTextColor(HudCol)
		surface.SetFont("wac_heli_small")
		surface.SetTextPos(483, -18)
		surface.DrawText("HVR")
	end
	
	local tr=util.QuickTrace(pos,Vector(0,0,-999999),self.Entity)
	surface.SetTextPos(485,505)
	surface.DrawText("ALT")
	surface.SetTextPos(485,520)
	surface.DrawText(math.floor((pos.z-tr.HitPos.z)/16))

	cam.End3D2D()
end

function ENT:DrawWeaponSelection()
	local fwd = self:GetForward()
	local ri = self:GetRight()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ri, 90)
	ang:RotateAroundAxis(fwd, 90)
	for k,t in pairs(self.Seats) do
		if type(t)=="table" and !t.NoHud then
			cam.Start3D2D(self:LocalToWorld(Vector(20,5,25)+t.Pos), ang, 0.02)
			surface.DrawRect(-10, 0, 500, 30)
			surface.DrawRect(-10, 30, 10, 20)
			if t.wep then
				local actwep=self:GetNWInt("seat_"..k.."_actwep")
				if t.wep[actwep] then
					local lastshot=self:GetNWFloat("seat_"..k.."_"..actwep.."_lastshot")
					local nextshot=self:GetNWFloat("seat_"..k.."_"..actwep.."_nextshot")
					local ammo=self:GetNWInt("seat_"..k.."_"..actwep.."_ammo")
					surface.DrawRect(10, 40, math.Clamp((nextshot-CurTime())/(nextshot-lastshot), 0, 1)*480, 10)
					draw.SimpleText(k.." "..t.wep[actwep].Name, "wac_heli_big", 0, -2.5, Black, 0)
					draw.SimpleText(nextshot>CurTime() and ammo==t.wep[actwep].MaxAmmo and "RELOADING" or ammo, "wac_heli_big", 480, -2.5, Black, 2)
				end
			else
				draw.SimpleText(k, "wac_heli_big", 0, -2.5, Black, 0)
			end
			cam.End3D2D()
		end
	end
end

function ENT:Draw()
	self:DrawModel()
	self:DrawRotor()
	if !self.Seats or self:GetNWBool("locked") then return end
	self:DrawPilotHud()
	self:DrawWeaponSelection()
	if self.engineRpm > 0.2 and self.SmokePos then
		if !self.lastHeatDrawn or self.lastHeatDrawn < CurTime()+1 then
			if type(self.SmokePos) == "table" then
				for _, v in self.SmokePos do
					local particle = self.Emitter:Add("sprites/heatwave",self:LocalToWorld(v))
					particle:SetVelocity(self:GetVelocity()+self:GetForward()*-100)
					particle:SetDieTime(0.1)
					particle:SetStartAlpha(255)
					particle:SetEndAlpha(255)
					particle:SetStartSize(40)
					particle:SetEndSize(20)
					particle:SetColor(255,255,255)
					particle:SetRoll(math.Rand(-50,50))
					self.Emitter:Finish()
				end
			else
				local particle = self.Emitter:Add("sprites/heatwave",self:LocalToWorld(self.SmokePos))
				particle:SetVelocity(self:GetVelocity()+self:GetForward()*-100)
				particle:SetDieTime(0.1)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(255)
				particle:SetStartSize(40)
				particle:SetEndSize(20)
				particle:SetColor(255,255,255)
				particle:SetRoll(math.Rand(-50,50))
				self.Emitter:Finish()
			end
			self.lastHeatDrawn = CurTime()
		end
	end
end
