
include "wac/weapons.lua"

local cvars = {
	allow = CreateClientConVar("wac_weapon_freeview", 1, true, true),
	offset = CreateClientConVar("wac_weapon_offset", 0, true, false),
	fov = CreateClientConVar("wac_weapon_fovmod", 0, true, false),
	bounce = CreateClientConVar("wac_weapon_bounce", 0.6, true, false),
}

local authors = {
	[wac.author] = {
		zoomed = function(w)
			local p = LocalPlayer()
			if IsValid(p) and IsValid(w) and !w.wacNoZoom and !wac.sprinting(p) and w:GetSequence()!=w:LookupSequence("reload") then
				if p:KeyDown(IN_ATTACK2) then
					if !w.wacZoomKeyDown and w.wacLastZoomed < CurTime()+0.2 then
						w.wacZoomKeyDown = true
						w.wacLastZoomed = CurTime()
					end
				else
					w.wacZoomKeyDown = false
				end
			end
		end
	},
	
	Worshipper = {
		zoomed = function(w)
			return w:GetDTBool(1)
		end
	},
	
}

local function checkZoom(w)
	if !authors[w.Author] then
		authors[w.Author] = authors[wac.author]
		MsgN("[WAC] Warning, probably not compatible with weapons from " .. w.Author)
	end
	w.wacZoomed = authors[w.Author].zoomed(w)
end

local function checkWeapon(w)
	local model = {
		max = Vector(3, 5, 0),
		mul = Vector(8, 5, 5)*0.0035,
		mulZoom = Vector(8, 5, 5)*0.002,
		offset = Vector(0, 0, 0),
		
	}
end

local function checkOn(p)
	if cvars.allow:GetInt() == 1 then return true end
	return false
end

local function approachViewAng(w,a,d)
	return a - (
		d*math.Clamp(math.abs(d), self.AngM, self.AngMax)*0.01*(1-f_smZ)
		+ d*math.Clamp(math.abs(d), self.AngMz, self.AngMaxz)*0.1*f_smZ
	)
end

local function approachViewPos(w,p,t,d)
	return math.Clamp(
		p - (1-math.abs(p)/self.VMPosMax.x)*d*(self.VMPosM.x*(1-f_smZ)+self.VMPosMz.x*f_smZ)
		*math.Clamp(70-math.abs(ang.p),-30,30)/30-p*(self.VMPosD.x*(1-f_smZ)+self.VMPosDz.x*f_smZ),
		-(self.VMPosMax.x*(1-f_smZ)+self.VMPosMaxz.x*f_smZ),
		self.VMPosMax.x*(1-f_smZ)+self.VMPosMaxz.x*f_smZ
	)
end

wac.hook("CalcView", "wac_weapons_calcview", function(p, pos, ang, fov)
	if !IsValid(p) or p:InVehicle() or p:GetViewEntity() != p or !p:Alive() then return end
	if !checkOn(p) then return end
	local w = p:GetActiveWeapon()
	if !w.wacChecked then checkWeapon(w) end
	if !w.wacCalcView then return end
	
	p.wacViewAng = p.wacViewAng or ang
	p.wacOldAng = p.wacOldAng or ang
	
	local difference = Angle(
		math.AngleDifference(p.wacViewAng.p, ang.p),
		math.AngleDifference(p.wacViewAng.y, ang.y), 0
	)
	
	local oldDifference = Angle(
		math.AngleDifference(p.wacOldAng.p, ang.p),
		math.AngleDifference(p.wacOldAng.y, ang.y), 0
	)
	
	p.wacViewAng.p = approachViewAng(w, p.wacViewAng.p, difference.p) 
	p.wacViewAng.y = approachViewAng(w, p.wacViewAng.y, difference.y)
	
	local vel=pl:GetVelocity()
	local lvel=vel:Length()
	local FrT=FrameTime()
	local crt = CurTime()
	viewang=viewang or ang
	oldang=oldang or ang
	viewang.r=0
	VMPosAdd.x = math.Clamp(VMPosAdd.x - (1-math.abs(VMPosAdd.x)/self.VMPosMax.x)*aYDiff*(self.VMPosM.x*(1-f_smZ)+self.VMPosMz.x*f_smZ)*math.Clamp(70-math.abs(ang.p),-30,30)/30 - VMPosAdd.x*(self.VMPosD.x*(1-f_smZ)+self.VMPosDz.x*f_smZ), -(self.VMPosMax.x*(1-f_smZ)+self.VMPosMaxz.x*f_smZ), self.VMPosMax.x*(1-f_smZ)+self.VMPosMaxz.x*f_smZ)
	VMPosAdd.z = math.Clamp(VMPosAdd.z - (1-math.abs(VMPosAdd.z)/self.VMPosMax.z)*aPDiff*(self.VMPosM.z*(1-f_smZ)+self.VMPosMz.z*f_smZ)*math.Clamp(70-math.abs(ang.p),-30,30)/30 - VMPosAdd.z*(self.VMPosD.z*(1-f_smZ)+self.VMPosDz.z*f_smZ), -(self.VMPosMax.z*(1-f_smZ)+self.VMPosMaxz.z*f_smZ), self.VMPosMax.z*(1-f_smZ)+self.VMPosMaxz.z*f_smZ)
	if (f_smZ >= 0.9 and zoomed(self) and self.ZoomOverlay and !self.zmFull) then
		self.zmFull = true
		self.zoomBlack=255
		pl:GetViewModel():SetNoDraw(true)
	elseif self.zmFull and f_smZ < 0.9 then
		self.zmFull = false
		pl:GetViewModel():SetNoDraw(false)
	end
	local ri = viewang:Right()
	local up = viewang:Up()
	local fwd = viewang:Forward()
	local VMFlip = (self.ViewModelFlip)and(-1)or(1)
	local VMFlop = 0-VMFlip
	local pvel=pl:WorldToLocal(pl:GetPos()+(pos-lastpos)*100)
	lastpos=pos
	local runsinx=math.sin(viewtime*14)*f_smGr
	local runsiny=math.sin(viewtime*7)*f_smGr
	local tr=util.QuickTrace(pos,ang:Forward()*23,self.Owner)
	SmoothVars(lvel, self, FrT, crt, tr, pvel, viewang, ang, VMFlip, lastdelta)
	fwd.z=math.Clamp(fwd.z,-1,(1-f_smSpr))
	local m=(0.1*math.Clamp(1-f_smZ,0.01,1)*(p:KeyDown(IN_DUCK) and 0.1 or 1))
	pos=pos+runsinx*up*3*math.Clamp(lvel*lvel*0.00001,m,10)*CVars.bounce:GetFloat()+ri*runsiny*3*math.Clamp(lvel*lvel*0.00001, m, 10)*CVars.bounce:GetFloat()
	--[[local eyes=p:GetAttachment(p:LookupAttachment("eyes"))
	pos=eyes.Pos]]
	view.origin=pos
	view.fov = math.Clamp(fov - (self.zoomStart+((f_smZol+20+(fov-90))*((f_smZ>=0.9 and self.zoomEnd) and 1 or 0)))*f_smZ+CVars.fov:GetFloat(), 1.5, 100)
	if self.ScopeModel then
		self.ScopeModel:SetPos(pos+v_smSpd.x*fwd*-0.01+v_smSpd.y*ri*0.002+v_smSpd.z*up*-0.002)
		self.ScopeModel:SetAngles(viewang-Angle(a_smAngAdd.p,a_smAngAdd.y*VMFlip,a_smAngAdd.r))
		self.ScopeModel:SetModelScale(Vector(0.5, view.fov/100, view.fov/100))
	end
	--local vmang=viewang-a_smAngAdd*0.7+Angle(self.RunAng.p*f_smSpr-ang.p*f_smSpr, self.RunAng.y*f_smSpr*VMFlop+ang.p*f_smSpr*0.4*VMFlip, ang.p*f_smSpr*0.5*VMFlip)*(1-f_smHs)
	local vmang=viewang-a_smAngAdd*0.7+Angle(self.RunAng.p*f_smSpr, self.RunAng.y*f_smSpr*VMFlop, self.RunAng.r*f_smSpr)*(1-f_smHs)
	vmang=vmang+Angle((a_smAng.p+self.AimAng.p*f_smZ)*(1-f_smSpr), (a_smAng.y+self.AimAng.y*f_smZ)*VMFlip*(1-f_smSpr), self.AimAng.r*f_smZ*(1-f_smSpr))*(1-f_smHs)+Angle(f_smHs*90,(f_smHs*-90+runsiny*2*f_smSpr)*VMFlip+runsiny*5*f_smSpr*VMFlop,0)
	pos=pos+ri*(runsiny*-m*VMFlip+runsiny*lvel*0.001+self.VMPosOffset.x*(1-f_smSpr)*(1-f_smZ) +math.Clamp(ang.p*0.05*f_smSpr,0,30)*VMFlip +v_smSpd.y*VMFlip*(1.5-f_smZ)*0.004 +VMPosAdd.x*VMFlip + VMFlip*(self.VMAngAdd.y)*(1-f_smZ)*0.1 +self.RunPos.x*f_smSpr*VMFlop +runsiny*f_smSpr +self.AimPos.x*f_smZ-runsiny*f_smSpr)
	pos=pos+fwd*(CVars.OffsetY:GetFloat()*(1-f_smZ)*(1-f_smSpr)+self.VMPosOffset.y*(1-f_smSpr)*(1-f_smZ) -v_smSpd.x*(1.5-f_smZ)*0.004 -f_smHs*10+VMPosAdd.y +self.RunPos.y*f_smSpr +self.AimPos.y*f_smZ-runsiny*f_smSpr)
	pos=pos+up*(runsinx*-m+runsinx*lvel*0.001+self.VMPosOffset.z*(1-f_smSpr)*(1-f_smZ) -math.Clamp(ang.p*0.05*f_smSpr,0,30) -v_smSpd.z*(2-f_smZ)*0.004 +VMPosAdd.z -v_smSpd:Length()*0.002*(1-f_smZ) +(self.VMAngAdd.p)*(1-f_smZ)*0.1 +self.RunPos.z*f_smSpr +runsinx*0.5*f_smSpr +self.AimPos.z*f_smZ)
	view.angles=ang+Angle(runsinx*math.Clamp(lvel/300*f_smGr, 0.1, 1), runsiny*math.Clamp(lvel/300*f_smGr, 0.1, 1), 0)
	view.angles=viewang+Angle(0+runsinx*0,0,v_smSpd.y*-0.0125)*(lvel/250)*f_smGr*CVars.bounce:GetFloat()
	view.vm_angles=vmang
	view.vm_origin=pos-v_smWall*(1-f_smZ)
	view.znear=1
	return view
end)


