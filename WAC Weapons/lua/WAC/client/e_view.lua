local x="ONLY FOR TESTING"

--[[
local view={
	angles=NULLANG,
	vm_origin=NULLVEC,
	vm_angles=NULLANG,
}

local vt={
	scoped=false,
	ang=Angle(0,0,0),
	diff=Angle(0,0,0),
}

vt.defaultweapon=function(p,w)
	w.wac_view_lag=1
	w.wac_view_lag_zoomed=0.5
	w.AimPos=Vector(4.74, -3.97, 1.71)
	w.AimAng=Angle(-1.32,0,0)
	w.RunPos=Vector(-5,-1,2)
	w.RunAng=Angle(15,-50,0)
end

vt.addweapon=function(p,w)
	if !IsValid(w) then return end
	local ini=INIParser:new("WAC SWEPs/"..w:GetClass()..".txt")
	vt.defaultweapon(p,w)
	if ini then
		w.wac_view_enabled=true
		if ini.disable then
			w.wac_view_forbid=true
			return
		end
		if ini.aimpos then
			w.AimPos=Vector(ini.aimpos[1].x,ini.aimpos[1].y,ini.aimpos[1].z)
		end
		if ini.runpos then
			w.RunPos=Vector(ini.runpos[1].x,ini.runpos[1].y,ini.runpos[1].z)
		end
		if ini.aimang then
			w.AimAng=Angle(ini.aimang[1].p,ini.aimang[1].y,ini.aimang[1].r)
		end
		if ini.runang then
			w.RunAng=Angle(ini.runang[1].p,ini.runang[1].y,ini.runang[1].r)
		end
		if ini.data then
			if ini.data[1].zoom then
				w.wac_view_canzoom=true
			end
			if ini.data[1].viewlag then
				w.wac_view_lag=ini.data[1].viewlag
			end
			if ini.data[1].viewlagzoomed then
				w.wac_view_lag_zoomed=ini.data[1].viewlagzoomed
			end
			if ini.data[1].crosshair==1 then
				w.wac_view_crosshair=true
			end
		end
		return true
	end
	w.wac_view_forbid=true
	return false
end

vt.switchw=function(p,w,lw)
	vt.scoped=false
end

vt.canview=function(p,w)
	if w.wac_view_forbid then return false end
	if !w.wac_view_enabled then
		if !vt.addweapon(p,w) then return false end
	end
	if w != vt.lastw then
		vt.switchw(p,w,vt.lastw)
		vt.lastw=w
	end
	return true
end

wac.hook("CalcView", "wac_cl_view_cview",function(p,pos,ang,fov)
	local p=LocalPlayer()
	local w=p:GetActiveWeapon()
	if vt.canview(p,w) then
		vt.ang.p=WAC.SmoothApproachAngle(vt.ang.p,ang.p,50)
		vt.ang.y=WAC.SmoothApproachAngle(vt.ang.y,ang.y,50)
		vt.ang.r=0
		vt.diff.p=WAC.SmoothApproachAngle(vt.diff.p,math.AngleDifference(ang.p,vt.ang.p),70)
		vt.diff.y=WAC.SmoothApproachAngle(vt.diff.y,math.AngleDifference(ang.y,vt.ang.y),70)
		view.angles=vt.ang
		view.vm_angles=vt.ang+Angle(vt.diff.p/1.6,vt.diff.y/1.6,0)
		local flip=w.ViewModelFlip and 1 or -1
		flop=flip*-1
		local ri=vt.ang:Right()
		local up=vt.ang:Up()
		local fwd=vt.ang:Forward()
		view.vm_origin=pos+ri*vt.diff.y*flop*0.1+up*vt.diff.p*0.1
		return view
	end
end)
]]