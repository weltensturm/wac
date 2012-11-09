
include('shared.lua')
include("wac/keyboard.lua")

function ENT:Think()
	if !self:GetNWBool("locked") then
		local mouseFlight = self:GetNWBool("active")
		if self.Sound.Start then
			if mouseFlight!=self.IsOn then
				if mouseFlight then
					self.Sound.Start:Play()
				else
					self.Sound.Start:Stop()
				end
				self.IsOn=mouseFlight
			end
		end
		if !self.Sound.Engine:IsPlaying() then
			self.Sound.Engine:ChangePitch(0,0.1)
			self.Sound.Engine:Play()
		end
		if !self.Sound.Blades:IsPlaying() then
			self.Sound.Blades:ChangePitch(0,0.1)
			self.Sound.Blades:Play()
		end
		local frt=CurTime()-self.LastThink
		local e=LocalPlayer():GetViewEntity()
		if !IsValid(e) then e=LocalPlayer() end
		local pos=e:GetPos()
		local spos=self:GetPos()
		local doppler=(pos:Distance(spos+e:GetVelocity())-pos:Distance(spos+self:GetVelocity()))/200*self.rotorRpm

		self.SmoothUp = self.SmoothUp - (self.SmoothUp-self:GetNWFloat("up"))*frt*10
		self.rotorRpm = self.rotorRpm - (self.rotorRpm-self:GetNWFloat("rotorRpm"))*frt*10
		self.engineRpm = self.engineRpm - (self.engineRpm-self:GetNWFloat("rotorRpm"))*frt*10

		local engineVal = math.Clamp(self.engineRpm*100+self.engineRpm*self.SmoothUp*3+doppler, 0, 200)
		local val = math.Clamp(self.rotorRpm*100 + doppler, 0, 200)

		local vehicle = LocalPlayer():GetVehicle()
		local inVehicle = false
		if --[[GetConVar("gmod_vehicle_viewmode"):GetInt() == 0 and]] vehicle and vehicle:IsValid() and vehicle:GetNetworkedEntity("wac_aircraft") == self then
			inVehicle = true
		end
		self.Sound.Engine:ChangePitch(engineVal,0.1)
		self.Sound.Engine:ChangeVolume(math.Clamp(engineVal*engineVal/4000, 0, inVehicle and 1 or 5),0.1)
		self.Sound.Blades:ChangePitch(math.Clamp(val, 50, 150),0.1)
		self.Sound.Blades:ChangeVolume(math.Clamp(val*val/5000, 0, inVehicle and 0.4 or 5),0.1)
		if self.Sound.Start then
			self.Sound.Start:ChangeVolume(math.Clamp(100 - self.engineRpm*150, 0, 100)/100,0.1)
			self.Sound.Start:ChangePitch(100 - self.engineRpm*30,0.1)
		end
		self.LastThink=CurTime()
	else
		self.Sound.Engine:Stop()
		self.Sound.Blades:Stop()
		if self.Sound.Start then
			self.Sound.Start:Stop()
		end
	end
end
function ENT:CalcThirdPersonView(k,p,pos,ang,view)
	local a = wac.key.down(tonumber(p:GetInfo("wac_cl_air_key_15")))
	local b=p:GetInfo("wac_cl_air_mouse")=="1"
	local c=p:GetInfo("wac_cl_air_usejoystick")=="1"
	if k==1 then
		if a then
			p.wac.heliFreeAim = true
		elseif p.wac.heliFreeAim then
			p.wac.heliFreeAim = false
			p.wac.heliResetView = true
		end
	end
	if (k==1 and (!c and a!=b) or (c and b)) or (k!=1 and a) then
		ang=self:GetAngles()
	end
	
	ang:RotateAroundAxis(self:GetRight(),-10)
	
	p.wac.viewAng = p.wac.viewAng or Angle(0,0,0)

	local m=math.Clamp(CurTime()-p.wac_air_v_time,0,1)
	if p:GetInfo("wac_cl_air_smoothview")=="1" then
		p.wac.viewAng = WAC.SmoothApproachAngles(p.wac.viewAng, ang, 10*m)
		view.angles = p.wac.viewAng
	else
		p.wac.viewAng = WAC.SmoothApproachAngles(p.wac.viewAng, ang-self:GetAngles(), 10*m)
		view.angles = p.wac.viewAng + self:GetAngles()
	end
	
	local tr = util.QuickTrace(self:LocalToWorld(Vector(-50,0,100))+self:GetVelocity()/50,view.angles:Forward()*-self.ThirdPDist,{self.Entity,self:GetNWEntity("rotor_rear")})
	view.origin=tr.HitPos-tr.Normal*10
	return view
end

function ENT:Draw()
	self:DrawModel()
	self:DrawRotor()
	if !self.SeatsT or self:GetNWBool("locked") then return end
	self:DrawPilotHud()
	self:DrawWeaponSelection()
end
