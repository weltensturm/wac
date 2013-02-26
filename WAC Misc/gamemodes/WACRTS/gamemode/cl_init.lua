
include("shared.lua")
include("cl_scoreboard.lua")

local mouse_enabled=false

local Viewmode=0
local Viewpos=Vector(0,0,50)
local Viewpossm=Vector(0,0,0)
local Viewlength=0
local Viewlengthsm=1000

local units_Selected={}
local units_All={}
local function units_Check()
	for k,e in pairs(units_Selected) do
		if !ValidEntity(e) then
			table.remove(units_Selected,k)
		end
	end
	table.Empty(units_All)
	for _,e in pairs(ents.FindByClass("wacrts_*")) do
		if e:GetOwner()==LocalPlayer() then
			table.insert(units_All,e)
		end
	end
end

local selectfield={
	offset=Vector(0,0),
	enable=false,
}

local orders={
	["Attack"]=false,
	["Move"]=false,
}

local function SelectOrder(s)
	orders_Selected=s
end

local function DeselectOrder()
	orders_Selected=false
end


local tDerma={}

--[[local resframe=vgui.Create("DFrame")
resframe:SetPos(10,10)
resframe:SetSize(60,30)
resframe:SetTitle("")
resframe:SetVisible(true)
resframe:SetDraggable(false)
resframe:SetKeyboardInputEnabled(true)
resframe:SetMouseInputEnabled(true)
resframe:ShowCloseButton(false)
resframe:SetParent(scrollpanel)
tDerma.ResourceFrame=resframe]]

function GM:EnableFactoryPanel(e)
	local ww=vgui.Create("DFrame")
	ww:SetPos(640,ScrH()-138)
	ww:SetSize(ScrW()-650,128)
	ww:SetTitle("")
	ww:SetVisible(true)
	ww:SetDraggable(false)
	ww:SetKeyboardInputEnabled(true)
	ww:SetMouseInputEnabled(true)
	ww:ShowCloseButton(false)
	ww:SetParent(scrollpanel)

	local ml = vgui.Create("DPanelList", ww)
	ml:SetPos(3,3)
	ml:SetSize(ScrW()-656, 64)
	ml:SetSpacing(0)
	ml:EnableHorizontal(true)
	ml:EnableVerticalScrollbar(true)
	
	for n,t in pairs(e.CreateableEnts) do
		local tb=vgui.Create("SpawnIcon")
		tb:SetIconSize(64)
		tb:SetModel(t.model)
		tb:SetToolTip(t.name.." ("..t.res..")")
		tb.OnMousePressed=function()
			mouse_Ignore=true
			if ValidEntity(e) then
				RunConsoleCommand("wacrts_factorybuild", e:EntIndex(), t.postfix)
			end
		end
		tb.OnMouseReleased=function()
			mouse_Ignore=false
		end	
		ml:AddItem(tb)
	end
	return ww
end


local pressing_mouseright=false
local rightmouse_startpos=Vector(0,0,0)
local rightmouse_endpos=Vector(0,0,0)
local rightmouse_ghosts={}
local rightmouse_yaw=0

local function CanUseMouseInput()
	if tDerma.BuildPanel and gui.MouseY()>(ScrH()-110) then return false end
	return true
end

local view={angles=Angle(0,0,0)}

local scrollpanel=vgui.Create("DFrame")
scrollpanel:SetPos(0,0)
scrollpanel:SetSize(ScrW(), ScrH())
scrollpanel:SetTitle("")
scrollpanel:SetVisible(true)
scrollpanel:SetDraggable(false)
scrollpanel:SetKeyboardInputEnabled(true)
scrollpanel:SetMouseInputEnabled(true)
scrollpanel:ShowCloseButton(false)
scrollpanel.Paint=function() end
scrollpanel.OnMouseWheeled=function(d,a)
	if mouse_enabled and CanUseMouseInput() then
		local vec=(a==1 and gui.ScreenToVector(gui.MouseX(), gui.MouseY()) or LocalPlayer():GetAimVector())
		local add=vec*a*math.Clamp(util.QuickTrace(Viewpossm,vec*10000).HitPos:Distance(Viewpossm)/(a==1 and 4 or 2),10,1000)
		if !util.QuickTrace(Viewpos,add).Hit then
			Viewpos=Viewpos+add
		end
	end
end

function GM:PlayerBindPress(p,bind,pressed)
	if !mouse_enabled then
		if bind=="invprev" then
			vec=view.angles:Forward()
			local add=vec*1*math.Clamp(util.QuickTrace(Viewpossm,vec*10000).HitPos:Distance(Viewpossm)/4,10,1000)
			if !util.QuickTrace(Viewpos,add).Hit then
				Viewpos=Viewpos+add
			end
			return true
		elseif bind=="invnext" then
			vec=view.angles:Forward()
			local add=vec*-1*math.Clamp(util.QuickTrace(Viewpossm,vec*10000).HitPos:Distance(Viewpossm)/2,10,1000)
			if !util.QuickTrace(Viewpos,add).Hit then
				Viewpos=Viewpos+add
			end
			return true
		end
	end
end

function GM:CalcView(pl,pos,ang,fov)
	--Viewpos.z=util.QuickTrace(Vector(Viewpos.x,Viewpos.y,1000),Vector(0,0,-18000)).HitPos.z
	view.origin=Viewpossm
	view.angles=ang
	WAC.SmoothApproachVector(Viewpossm,Viewpos,20)
	return view
end

local function SelectUnitsInSquare(tx,ty,bx,by)
	if orders_Selected then return end
	local p=LocalPlayer()
	if tx<bx then
		local ax=bx
		bx=tx
		tx=ax
	end
	if ty<by then
		local ay=by
		by=ty
		ty=ay
	end
	if !LocalPlayer():KeyDown(IN_SPEED) then
		for _,e in pairs(units_Selected) do
			e.wac_selected=false
		end
		table.Empty(units_Selected)
	end
	if tx<bx+5 and ty<by+5 then
		local tr=util.QuickTrace(Viewpossm, gui.ScreenToVector(gui.MouseX(), gui.MouseY())*9999,LocalPlayer())
		if tr.Hit then
			if ValidEntity(tr.Entity:GetNWEntity("tank")) then
				tr.Entity=tr.Entity:GetNWEntity("tank")
			end
			if tr.Entity:GetOwner()==p and !table.HasValue(units_Selected, tr.Entity) then
				if tr.Entity.IsRTSTank or tr.Entity.IsRTSFactory then
					table.insert(units_Selected, tr.Entity)
				end
			end
		end
	else
		local tPrimary={}
		local tSecondary={}
		for k,e in pairs(ents.FindByClass("wacrts_*")) do
			if e:GetOwner()==p then
				local spos=e:GetPos():ToScreen()
				if spos.x<tx and spos.x>bx and spos.y<ty and spos.y>by and !table.HasValue(units_Selected, e) then	
					if e.IsRTSTank then
						table.insert(tPrimary, e)
					elseif e.IsRTSFactory then
						table.insert(tSecondary, e)					
					end
				end
			end
		end
		if #tPrimary>0 then
			for _,e in pairs(tPrimary) do
				table.insert(units_Selected, e)
			end			
		else
			for _,e in pairs(tSecondary) do
				table.insert(units_Selected, e)
			end
		end
	end
end


local bulletcolor=Color(255,182,74,200)

function GM:HUDPaint()
	units_Check()
	if mouse_enabled==true then
		local pl=LocalPlayer()
		local left=input.IsMouseDown(MOUSE_LEFT)
		if left and CanUseMouseInput() then
			if !orders_Selected then
				local x=gui.MouseX()
				local y=gui.MouseY()
				if !selectfield.enable then
					selectfield.offset=Vector(x,y)
					selectfield.enable=true
				end
				local fx=selectfield.offset.x
				local fy=selectfield.offset.y
				if fx<x then
					local ax=x
					x=fx
					fx=ax
				end
				if fy<y then
					local ay=y
					y=fy
					fy=ay
				end
				surface.SetDrawColor(10,10,10,55)
				surface.DrawRect(x,y,fx-x,fy-y)
				surface.SetDrawColor(200,115,10,255)
				surface.DrawLine(fx,fy,fx,y)
				surface.DrawLine(fx,fy,x,fy)
				surface.DrawLine(x,fy,x,y)
				surface.DrawLine(fx,y,x,y)
			else
				selectfield.enable=false
				local tr=util.QuickTrace(Viewpossm, gui.ScreenToVector(gui.MouseX(), gui.MouseY())*9999,LocalPlayer())
				for _,e in pairs(units_Selected) do
					if ValidEntity(e) then
						RunConsoleCommand("wacrts_orders_"..orders_Selected, e:EntIndex(), tr.HitPos.x,tr.HitPos.y,tr.HitPos.z)
					end
				end
				DeselectOrder()
			end
		else
			if !orders_Selected and selectfield.enable then
				SelectUnitsInSquare(gui.MouseX(), gui.MouseY(), selectfield.offset.x, selectfield.offset.y)
				selectfield.enable=false
			end
		end
		if pressing_mouseright then
			for k,e in pairs(units_Selected) do
				if !e.wac_ghost or !ValidEntity(e.wac_ghost) then
					e.wac_ghost=ClientsideModel(e:GetModel())
					e.wac_ghost:SetColor(100,100,255,150)
					e.wac_ghost.ent=e
					e.wac_ghost.time=CurTime()
					e.wac_ghost:SetModelScale(Vector(0,0,0))
					table.insert(rightmouse_ghosts, e.wac_ghost)
				end
				if ValidEntity(e.wac_ghost) then
					local scale=math.Clamp(CurTime()*10-e.wac_ghost.time*10,0,1)
					e.wac_ghost:SetModelScale(Vector(scale,scale,scale))
					if rightmouse_startpos==rightmouse_endpos then
						rightmouse_yaw=0
					else
						rightmouse_yaw=(rightmouse_endpos-rightmouse_startpos):Angle().y
					end
					e.wac_ghost:SetAngles(Angle(0,rightmouse_yaw,0))
					local pos=rightmouse_startpos+Vector(0,0,10)+e.wac_ghost:GetRight()*(k-#units_Selected/2)*30
					if rightmouse_yaw==0 then
						local dist=e:BoundingRadius()*1.2
						pos=rightmouse_startpos+Angle(0,dist*k*5,0):Forward()*dist*k/2
					end
					local tr=util.QuickTrace(pos+Vector(0,0,100),Vector(0,0,-200))
					e.wac_ghost:SetPos(tr.HitPos)
				end			
			end
		else
			for k,e in pairs(rightmouse_ghosts) do
				if e:IsValid() then
					e:Remove()
					table.remove(rightmouse_ghosts,k)
				end
			end
		end
		if orders_Selected then
			local x=gui.MouseX()
			local y=gui.MouseY()
			surface.SetDrawColor(255,187,74,255)
			surface.DrawLine(x-10,y,x+10,y)
			surface.DrawLine(x,y-10,x,y+10)
		end
	end
	units_Check()
	for k,e in pairs(units_All) do
		local pos=e:GetPos():ToScreen()
		local size=100000/e:GetPos():Distance(Viewpossm)
		surface.SetDrawColor(Color(0,0,0,150))
		surface.DrawRect(pos.x-size/4-1, pos.y-size/4-1, size/2+2, math.Clamp(size/30+2,3,9999))
		local maxh=e:GetNWInt("wac_maxhealth")
		local h=(maxh==0 and 1 or e:GetNWInt("wac_health")/maxh)
		surface.SetDrawColor(table.HasValue(units_Selected,e) and Color(150,200,255,200) or Color(50,255,100,100))
		surface.DrawRect(pos.x-size/4, pos.y-size/4, size/2*h, math.Clamp(size/30,1,9999))
		if e.IsRTSFactory then
			surface.SetDrawColor(255,100,100,200)
			local done=e:GetNWFloat("done")
			surface.DrawRect(pos.x-size/4, pos.y-math.Clamp(size/100,1,9999)-size/4, size/2*done, math.Clamp(size/100,1,9999))
		end
	end
	for _,e in pairs(ents.FindByClass("wacrts_shell*")) do
		local p=e:GetPos()
		if p:Distance(Viewpossm)>200 then
			local pos=e:GetPos():ToScreen()
			draw.RoundedBox(2,pos.x-1,pos.y-1,2,2,bulletcolor)
		end
	end
	local res=LocalPlayer():GetNWFloat("wacrts_resources")
	draw.SimpleText(math.floor(res),"Trebuchet22",80,20,bulletcolor,2,1)
end

local pos_addtime=0
local pos_addspeedside=0
local pos_addspeedfwd=0
local lastposset=0
function GM:Think()
	local pl=LocalPlayer()
	if input.IsMouseDown(MOUSE_RIGHT) and !pressing_mouseright then
		rightmouse_startpos=util.QuickTrace(LocalPlayer():EyePos(), gui.ScreenToVector(gui.MouseX(), gui.MouseY())*9999, LocalPlayer()).HitPos
		pressing_mouseright=true
	elseif input.IsMouseDown(MOUSE_RIGHT) and pressing_mouseright then
		rightmouse_endpos=util.QuickTrace(LocalPlayer():EyePos(), gui.ScreenToVector(gui.MouseX(), gui.MouseY())*9999, LocalPlayer()).HitPos
	elseif !input.IsMouseDown(MOUSE_RIGHT) and pressing_mouseright then
		local override=!LocalPlayer():KeyDown(IN_SPEED)
		units_Check()
		for k,e in pairs(units_Selected) do
			if override then
				RunConsoleCommand("wacrts_resettargetpos",e:EntIndex())
			end
			local eid=e:EntIndex()
			local pos=rightmouse_startpos+Angle(0,rightmouse_yaw,0):Right()*(k-#units_Selected/2)*30
			if rightmouse_yaw==0 then
				local dist=e:BoundingRadius()*1.2
				pos=rightmouse_startpos+Angle(0,dist*k*5,0):Forward()*dist*k/2
			end
			RunConsoleCommand("wacrts_orders_Move", eid, pos.x, pos.y, pos.z, rightmouse_yaw)
		end
		pressing_mouseright=false
	end
	local CrT=CurTime()
	if CrT>pos_addtime then
		if mouse_enabled and (pl:KeyDown(IN_JUMP) or input.IsMouseDown(MOUSE_MIDDLE)) then
			gui.EnableScreenClicker(false)
			mouse_enabled=false
		elseif !mouse_enabled and (!pl:KeyDown(IN_JUMP) and !input.IsMouseDown(MOUSE_MIDDLE)) then
			gui.EnableScreenClicker(true)
			mouse_enabled=true
		end
		local fwd=pl:KeyDown(IN_FORWARD)
		local back=pl:KeyDown(IN_BACK)
		local left=pl:KeyDown(IN_MOVELEFT)
		local right=pl:KeyDown(IN_MOVERIGHT)
		local aright=view.angles:Right()
		local afwd=aright:Angle():Right()*-1
		local add=Vector(0,0,0)
		if mouse_enabled then
			left=left or gui.MouseX()<3
			right=right or gui.MouseX()>ScrW()-3
			fwd=fwd or gui.MouseY()<3
			back=back or gui.MouseY()>ScrH()-3
		end
		if fwd then
			pos_addspeedfwd=math.Clamp(pos_addspeedfwd+1,0,100)
		elseif back then
			pos_addspeedfwd=math.Clamp(pos_addspeedfwd-1,-100,0)
		else
			pos_addspeedfwd=0
		end
		add=add+afwd*0.5*pos_addspeedfwd
		if right then
			pos_addspeedside=math.Clamp(pos_addspeedside+1,0,100)
		elseif left then
			pos_addspeedside=math.Clamp(pos_addspeedside-1,-100,0)
		else
			pos_addspeedside=0
		end
		add=add+aright*0.5*pos_addspeedside
		if !util.QuickTrace(Viewpos,add).Hit then
			Viewpos=Viewpos+add
		end
		pos_addtime=CrT+0.01
	end
	if lastposset+0.3<CurTime() and spawned then
		RunConsoleCommand("wacrts_setplayerpos", Viewpos.x, Viewpos.y, Viewpos.z)
		lastposset=CurTime()
	end
	if ValidEntity(units_Selected[1]) and units_Selected[1].IsRTSFactory then
		if !tDerma.BuildPanel then
			tDerma.BuildPanel=self:EnableFactoryPanel(units_Selected[1])
		end
	elseif tDerma.BuildPanel then
		tDerma.BuildPanel:Remove()
		tDerma.BuildPanel=nil
	end
end

usermessage.Hook("wacrts_spawnplayer", function(um)
	Viewpos=um:ReadVector()
	spawned=true
end)
