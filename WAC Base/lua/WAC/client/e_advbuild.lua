
local iSnap=CreateClientConVar("wac_advbuild_snapdistance", 1, true, false)

local enable=false
local mouse_enabled=false

local Viewmode=0
local Viewpos=Vector(0,0,50)
local Viewpossm=Vector(0,0,0)
local Viewlength=0
local Viewlengthsm=1000
local playerstartpos=Vector(0,0,0)
local SelectedEntities={}

local dragging=false

local RotatePos
local RotateLength

local vSnap
local aSnap

local function DeSelect(e)
	for k,v in pairs(SelectedEntities) do
		if v==e then
			SelectedEntities[k]=nil
		end
	end
	if e.Ghost then
		e.Ghost:Remove()
		e.Ghost=nil	
	end
end

local function DeselectAll()
	for k,e in pairs(SelectedEntities) do
		DeSelect(e)
	end
end

local ghosts={}

local function SelectEntity(e)
	if IsValid(e) and e:GetModel() and string.find(e:GetModel(),".mdl") and !e.Ghost and !e.IsGhost and !e:IsPlayer() and !e:IsWeapon() and e!=LocalPlayer():GetViewModel() then
		if !table.HasValue(SelectedEntities) then
			table.insert(SelectedEntities, e)
			local ghost=ClientsideModel(e:GetModel())
			ghost:SetPos(e:GetPos())
			ghost:SetAngles(e:GetAngles())
			ghost:SetColor(0,0,255,100)
			ghost.IsGhost=true
			ghost.Ent=e
			table.insert(ghosts,ghost)
			e.Ghost=ghost
		else
			DeSelect(e)
		end
	elseif IsValid(e) and e.IsGhost then
		DeSelect(e.Ent)
	end
end

local selectfield={
	offset=Vector(0,0),
	enable=false,
}

local view={angles=Angle(0,0,0)}

local scrollpanel;

local jump=false

local function BuildTrace(pos,add)
	local tr={}
	tr.start=pos
	tr.endpos=pos+add
	tr.filter=LocalPlayer()
	tr.mask=MASK_NPCWORLDSTATIC
	return util.TraceLine(tr)
end

local function PlayerBindPress(p,bind,pressed)
	if !p:GetNWBool("wac_advbuild_enable") then return end
	if !mouse_enabled then
		if bind=="invprev" and !p:KeyDown(IN_USE) then
			vec=view.angles:Forward()
			if RotatePos then
				RotateLength=RotateLength-RotateLength/4
			else
				local add=vec*1*math.Clamp(BuildTrace(Viewpos,vec*10000).HitPos:Distance(Viewpos)/4,10,1000)
				Viewpos=BuildTrace(Viewpos,add).HitPos
			end
			return true
		elseif bind=="invnext" and !p:KeyDown(IN_USE) then
			vec=view.angles:Forward()
			if RotatePos then
				RotateLength=RotateLength+RotateLength/8
			else
				local add=vec*-1*math.Clamp(BuildTrace(Viewpos,vec*10000).HitPos:Distance(Viewpos)/8,10,1000)
				Viewpos=BuildTrace(Viewpos,add).HitPos				
			end
			return true
		elseif bind=="+jump" then
			return true
		end
	end
end
WAC.Hook("PlayerBindPress", "wac_cl_advbuild_pbp", PlayerBindPress)

local function CalcView(p,pos,ang,fov)
	if !p:GetNWBool("wac_advbuild_enable") or p:GetViewEntity()!=p then return end
	if input.IsMouseDown(MOUSE_MIDDLE) then
		if !RotatePos then
			local tr=p:GetEyeTrace()
			RotatePos=tr.HitPos+tr.HitNormal*10
			RotateLength=RotatePos:Distance(Viewpossm)
		end
		Viewpos=BuildTrace(RotatePos, p:GetAimVector()*RotateLength*-1).HitPos
	elseif RotatePos then
		RotatePos=nil
		RotateLength=nil
	end
	view.origin=Viewpossm
	view.angles=ang
	view.vm_angles=(ang:Forward()*-1):Angle()
	WAC.SmoothApproachVector(Viewpossm,Viewpos,20)
	return view
end
WAC.Hook("CalcView", "wac_cl_advbuild_cv", CalcView)

local function SelectUnitsInSquare(tx,ty,bx,by)
	if tx<bx then
		tx,bx=bx,tx
	end
	if ty<by then
		ty,by=by,ty
	end
	if !LocalPlayer():KeyDown(IN_SPEED) then
		DeselectAll()
	end
	if ty<by+5 and tx<bx+5 then
		local tr=util.QuickTrace(Viewpossm, gui.ScreenToVector(gui.MouseX(), gui.MouseY())*99999, LocalPlayer())
		if tr.Hit then
			SelectEntity(tr.Entity)
		end
	else
		for k,e in pairs(ents.GetAll()) do
			if IsValid(e) then
				local spos=e:GetPos():ToScreen()
				if !e:IsWeapon() and !e:IsPlayer() and spos.x<tx and spos.x>bx and spos.y<ty and spos.y>by then
					SelectEntity(e)
				end
			end
		end
	end
end

local vFwd=Vector(0,1,0)
local vLeft=Vector(1,0,0)
local vUp=Vector(0,0,1)
local cText=Color(255,255,255,255)
local cTextOutline=Color(20,20,20,200)
local dragstartx=0
local dragstarty=0
local dragaxis="X"
local DragTable={
	[1]={
		[1]="X",
		[2]="Y",
		[3]="Z",
	},
	[2]={
		[2]="XZ",
		[1]="YX",
		[3]="YZ",
	},
	[3]={
		["X"]=vFwd,
		["Y"]=vLeft,
		["Z"]=vUp,
	},
}
local t_History={}

local function SnapVector(vec)
	vec.x=math.Round(vec.x/vSnap:GetValue())*vSnap:GetValue()
	vec.y=math.Round(vec.y/vSnap:GetValue())*vSnap:GetValue()
	vec.z=math.Round(vec.z/vSnap:GetValue())*vSnap:GetValue()
	return vec
end

local function HUDPaint()
	if !LocalPlayer():GetNWBool("wac_advbuild_enable") then return end
	local x=gui.MouseX()
	local y=gui.MouseY()
	for _,e in pairs(SelectedEntities) do
			if IsValid(e) then
			local ang=e.Ghost:GetAngles()
			local pos=e.Ghost:GetPos()
			local spos=pos:ToScreen()
			local fpos=(pos+vFwd*50):ToScreen()
			local upos=(pos+vUp*50):ToScreen()
			local rpos=(pos+vLeft*50):ToScreen()
			surface.SetDrawColor(200,111,50,255)
			surface.DrawLine(spos.x,spos.y,fpos.x,fpos.y)
			surface.DrawLine(spos.x,spos.y,rpos.x,rpos.y)
			surface.DrawLine(spos.x,spos.y,upos.x,upos.y)
			surface.DrawLine(spos.x+1,spos.y+1,fpos.x+1,fpos.y+1)
			surface.DrawLine(spos.x+1,spos.y+1,rpos.x+1,rpos.y+1)
			surface.DrawLine(spos.x+1,spos.y+1,upos.x+1,upos.y+1)
			draw.SimpleTextOutlined(math.floor(pos.x*10)/10, "Trebuchet22", rpos.x, rpos.y, cText, 1, 1, 1, cTextOutline)
			draw.SimpleTextOutlined(math.floor(pos.y*10)/10, "Trebuchet22", fpos.x, fpos.y, cText, 1, 1, 1, cTextOutline)
			draw.SimpleTextOutlined(math.floor(pos.z*10)/10, "Trebuchet22", upos.x, upos.y, cText, 1, 1, 1, cTextOutline)
		end
	end
	if mouse_enabled==true then
		local height=50
		local width=50
		local gap=10
		local SW=ScrW()
		local SH=ScrH()
		local offsetx=40
		local offsety=40
		for a=1,2 do
			for i=1,3 do
				local xs=SW-(width+gap)*a-offsetx
				local ys=SH-(height+gap)*i-offsety
				if x<xs+width and x>xs and y<ys+height and y>ys and !dragging then
					dragstartx=x
					dragstarty=y
					dragging=true
					dragaxis=DragTable[a][i]
					surface.SetDrawColor(200,115,10,255)
					surface.DrawRect(xs,ys,width,height)
				end
				surface.SetDrawColor(10,10,10,100)
				surface.DrawRect(xs,ys,width,height)
				surface.SetDrawColor(200,115,10,255)
				surface.DrawLine(xs,ys,xs+width,ys)
				surface.DrawLine(xs,ys+height,xs+width,ys+height)
				surface.DrawLine(xs,ys,xs,ys+height)
				surface.DrawLine(xs+width,ys,xs+width,ys+height)
				draw.SimpleTextOutlined(DragTable[a][i], "Trebuchet22", xs+width/2, ys+height/2, cText, 1, 1, 1, cTextOutline)
			end
		end
		local pl=LocalPlayer()
		local left=input.IsMouseDown(MOUSE_LEFT)
		if left and !dragging and selectfield.enable then
			local fx=selectfield.offset.x
			local fy=selectfield.offset.y
			if fx<x then
				fx,x=x,fx
			end
			if fy<y then
				fy,y=y,fy
			end
			surface.SetDrawColor(10,10,10,55)
			surface.DrawRect(x,y,fx-x,fy-y)
			surface.SetDrawColor(200,115,10,255)
			surface.DrawLine(fx,fy,fx,y)
			surface.DrawLine(fx,fy,x,fy)
			surface.DrawLine(x,fy,x,y)
			surface.DrawLine(fx,y,x,y)
		else
			if !left and dragging then
				dragging=false
				selectfield.enable=false
			end
		end
	elseif !input.IsMouseDown(MOUSE_MIDDLE) then
		local pos=LocalPlayer():GetEyeTrace().HitPos:ToScreen()
		surface.SetDrawColor(0,0,0,255)
		surface.DrawLine(pos.x-10,pos.y,pos.x+10,pos.y)
		surface.DrawLine(pos.x,pos.y-10,pos.x,pos.y+10)
	end
	if dragging then
		if dragstartx != gui.MouseX() then
			local diff=dragstartx-gui.MouseX()
			local axis=DragTable[3][string.Left(dragaxis,1)]
			for _,e in pairs(SelectedEntities) do
				e.Ghost:SetPos(SnapVector(e.Ghost:GetPos()+axis*diff*vSnap:GetValue()*0.5))
			end
			gui.SetMousePos(dragstartx,gui.MouseY())
		end
		if dragstarty != gui.MouseY() then
			local diff=dragstarty-gui.MouseY()
			local axis=DragTable[3][string.Right(dragaxis,1)]
			if axis then
				for _,e in pairs(SelectedEntities) do
					e.Ghost:SetPos(SnapVector(e.Ghost:GetPos()+axis*diff*vSnap:GetValue()*0.5))
				end
				gui.SetMousePos(gui.MouseX(),dragstarty)
			end
		end
	else
		local crt=CurTime()
		local moved={}
		for k,e in pairs(SelectedEntities) do
			if IsValid(e) then
				local pos=e.Ghost:GetPos()
				if e:GetPos()!=pos then
					RunConsoleCommand("wac_advbuild_moveent", e:EntIndex(), pos.x, pos.y, pos.z)
					table.insert(moved,{
						type="move",
						e=e,
						from=e:GetPos(),
						to=pos,
					})
				end
				local ang=e.Ghost:GetAngles()
				if e:GetAngles()!=ang then
					RunConsoleCommand("wac_advbuild_rotateent", e:EntIndex(), ang.p, ang.y, ang.r)
				end
			end
		end
		if #moved>0 then
			table.insert(t_History,moved)
		end
	end
end
WAC.Hook("HUDPaint", "wac_cl_advbuild_hp", HUDPaint)

local categories={
	{
		n="Help",
		f=function(pp)
			local p=vgui.Create("DLabel", pp)
			p:SetText(" Space: Rotate View")
			pp:AddItem(p)
			p=vgui.Create("DLabel", pp)
			p:SetText(" Mouse Wheel: Zoom")
			pp:AddItem(p)
			p=vgui.Create("DLabel", pp)
			p:SetText(" Middle Mouse: Orbit")
			pp:AddItem(p)
			p=vgui.Create("DLabel", pp)
			p:SetText(" W, A, S, D: Move")
			pp:AddItem(p)
		end,
	},
	{
		n="Options",
		f=function(pp)
			local p=vgui.Create("DButton", window)
			p:SetText("Done")
			p.DoClick = function()
				RunConsoleCommand("wac_advbuild_toggle")
			end
			pp:AddItem(p)
			p=vgui.Create("DButton", window)
			p:SetPos(80, 170)
			p:SetSize(60, 20)
			p:SetText("Undo")
			p.DoClick=function()
				local t=t_History[#t_History]
				if t then
					PrintTable(t)
					if t.e and t.e:IsValid() then
						if t.e.Ghost and t.e.Ghost:IsValid() then
							t.e.Ghost:SetPos(t.from)
						end
						t.e:SetPos(t.from)
					end
					t_History[#t_History]=nil
				end
			end
			pp:AddItem(p)
			p=vgui.Create("DNumSlider", pp)
			p:SetText("Position Snap")
			p:SetMin(0.01)
			p:SetMax(10)
			p:SetDecimals(1)
			p:SetValue(1)
			vSnap=p
			pp:AddItem(p)
			p=vgui.Create("DNumSlider", pp)
			p:SetText("Angle Snap")
			p:SetMin(0.01)
			p:SetMax(10)
			p:SetDecimals(1)
			p:SetValue(1)
			aSnap=p
			pp:AddItem(p)
		end,
	},
}

local function CreateMultiPanel(sp)
	local w=150
	local h=500
	local head=0
	local e=3
	local p
	p=vgui.Create("DFrame")
	p:SetPos(0,0)
	p:SetSize(w,h)
	p:SetTitle("")	
	p:SetVisible(true)
	p:SetDraggable(true)
	p:SetKeyboardInputEnabled(true)
	p:SetMouseInputEnabled(true)
	p:ShowCloseButton(false)
	p:SetParent(sp)
	--[[p=vgui.Create("DPanelList", p)
	p:SetPos(e,e*3)
	p:SetSize(w-e*2,h-e*4)
	p:SetSpacing(0)
	p:EnableHorizontal(false)
	p:EnableVerticalScrollbar(true)]]
	local Frame=p
	
	local lists={}
	
	for i=1,(#categories-1) do
		p=vgui.Create("DVerticalDivider", Frame)
		p:SetPos(e,e+head+h/#categories*(i-1))
		p:SetSize(w-e*2,(h-e*2-head)/(#categories-1))
		p:SetDividerHeight(1)
		p:SetTopMin(1)
		p:SetBottomMin(e)
		table.insert(lists,p)
	end
	
	local lastp;
	for k,t in pairs(categories) do
		p=vgui.Create("DPanelList", Frame)
		p:SetPos(e,e-head+h/#categories*(k-1))
		p:SetSize(w-e*2,h/#categories-e-head)
		p:SetSpacing(1)
		p:EnableHorizontal(false)
		p:EnableVerticalScrollbar(true)
		t.f(p)
		if lists[k-1] then
			lists[k-1]:SetBottom(p)
		end
		if lists[k] then
			lists[k]:SetTop(p)
		end
	end
	--[[
	vSnap=p
	p=vgui.Create("DPanelList",p)
	p:SetPos(0,0)
	p:SetSize(w-e*2, h-e*3-e)
	p:SetSpacing(0)
	p:EnableHorizontal(true)
	p:EnableVerticalScrollbar(true)
	local HelpList=p
	HelpCategory:SetContents(p)
	p=vgui.Create("DNumSlider", p)
	p:SetPos(3,2)
	p:SetWide(200-61)
	p:SetText("Move Snap")
	p:SetMin(0.01)
	p:SetMax(10)
	p:SetDecimals(1)
	p:SetValue(1)]]
end

local function CreateMenuPanel()
	scrollpanel=vgui.Create("DFrame")
	scrollpanel:SetPos(0,0)
	scrollpanel:SetSize(ScrW(), ScrH())
	scrollpanel:SetTitle("")
	scrollpanel:SetVisible(true)
	scrollpanel:SetDraggable(false)
	scrollpanel:SetKeyboardInputEnabled(true)
	scrollpanel:SetMouseInputEnabled(true)
	scrollpanel:ShowCloseButton(false)
	scrollpanel.Paint=function() end
	scrollpanel.OnMousePressed=function(panel, Key)
		if !selectfield.enable and Key==107 then
			selectfield.offset=Vector(gui.MouseX(),gui.MouseY())
			selectfield.enable=true
		end
	end
	scrollpanel.OnMouseReleased=function(panel, Key)
		if Key==107 and dragging==false then
			SelectUnitsInSquare(gui.MouseX(), gui.MouseY(), selectfield.offset.x, selectfield.offset.y)
			selectfield.enable=false
		end
	end
	scrollpanel.OnMouseWheeled=function(d,a)
		if mouse_enabled then
			local vec=gui.ScreenToVector(gui.MouseX(), gui.MouseY())
			local add=vec*a*math.Clamp(BuildTrace(Viewpos,vec*10000).HitPos:Distance(Viewpos)/(a==1 and 4 or 8),10,1000,p)
			Viewpos=BuildTrace(Viewpos,add).HitPos
		end
	end
	--[[local window=vgui.Create("DFrame")
	window:SetPos(10,10)
	window:SetSize(150,200)
	window:SetTitle("Options")
	window:SetVisible(true)
	window:SetDraggable(true)
	window:SetKeyboardInputEnabled(true)
	window:SetMouseInputEnabled(true)
	window:ShowCloseButton(false)
	window:SetParent(scrollpanel)
	local p=vgui.Create("DButton", window)
	p:SetPos(3, 177)
	p:SetSize(72, 20)
	p:SetText("Done")
	p.DoClick = function()
		RunConsoleCommand("wac_advbuild_toggle")
	end
	p=vgui.Create("DButton", window)
	p:SetPos(75, 177)
	p:SetSize(72, 20)
	p:SetText("Undo")
	p.DoClick=function()
		local t=t_History[#t_History]
		if t then
			for _,t2 in pairs(t) do
				if t2.e and t2.e:IsValid() then
					if t2.e.Ghost and t2.e.Ghost:IsValid() then
						t2.e.Ghost:SetPos(t2.from)
					end
					t2.e:SetPos(t2.from)
				end
			end
			t_History[#t_History]=nil
		end
	end
	local ml=vgui.Create("DPanelList", window)
	ml:SetPos(3,20)
	ml:SetSize(150-6, 200-44)
	ml:SetSpacing(0)
	ml:EnableHorizontal(true)
	ml:EnableVerticalScrollbar(true)
	local vsl=vgui.Create("DNumSlider",ml)
	vsl:SetPos(3,2)
	vsl:SetWide(200-61)
	vsl:SetText("Move Snap")
	vsl:SetMin(0.01)
	vsl:SetMax(10)
	vsl:SetDecimals(1)
	vsl:SetValue(1)
	--vsl:SetConVar("wac_advbuild_possnap")
	vSnap=vsl
	local help=vgui.Create("DFrame")
	help:SetPos(10,210)
	help:SetSize(150,200)
	help:SetTitle("Help")
	help:SetKeyboardInputEnabled(true)
	help:SetMouseInputEnabled(true)
	help:ShowCloseButton(true)
	help:SetParent(scrollpanel)
	local ml=vgui.Create("DPanelList", help)
	ml:SetPos(3,20)
	ml:SetSize(150-6, 200-24)
	ml:SetSpacing(0)
	ml:EnableHorizontal(true)
	ml:EnableVerticalScrollbar(true)]]
	CreateMultiPanel(scrollpanel)
end

local pos_addtime=0
local pos_addspeedside=0
local pos_addspeedfwd=0
local rightmousepressed=false
local lastposset=0


local function Think()
	local p=LocalPlayer()
	if !p:GetNWBool("wac_advbuild_enable") then
		if scrollpanel then
			RunConsoleCommand("wac_advbuild_moveplayer", playerstartpos.x, playerstartpos.y, playerstartpos.z)
			scrollpanel:Remove()
			scrollpanel=nil
			gui.EnableScreenClicker(false)
			for k,e in pairs(SelectedEntities) do
				if IsValid(e) then
					if e.Ghost and e.Ghost:IsValid() then
						e.Ghost:Remove()
						e.Ghost=nil
					end
				end
			end
			table.Empty(SelectedEntities)
		end
		return
	end
	if !scrollpanel then
		CreateMenuPanel()
		Viewpos=p:EyePos()
		Viewpossm=Viewpos
		playerstartpos=p:GetPos()
	end
	if input.IsMouseDown(MOUSE_RIGHT) and !rightmousepressed then
		local gvec=gui.ScreenToVector(gui.MouseX(), gui.MouseY())
		local trdata={
			start=view.origin,
			endpos=view.origin+gvec*99999
		}
		local pos=util.TraceLine(trdata).HitPos
		RunConsoleCommand("wacrts_rightclickaction", pos.x, pos.y, pos.z)
		rightmousepressed=true
	elseif !input.IsMouseDown(MOUSE_RIGHT) then
		rightmousepressed=false
	end
	local CrT=CurTime()
	if CrT>pos_addtime then
		if mouse_enabled and (p:KeyDown(IN_JUMP) or input.IsMouseDown(MOUSE_MIDDLE)) then
			gui.EnableScreenClicker(false)
			mouse_enabled=false
		elseif !mouse_enabled and (!p:KeyDown(IN_JUMP) and !input.IsMouseDown(MOUSE_MIDDLE)) then
			gui.EnableScreenClicker(true)
			mouse_enabled=true
		end
		local fwd=p:KeyDown(IN_FORWARD)
		local back=p:KeyDown(IN_BACK)
		local left=p:KeyDown(IN_MOVELEFT)
		local right=p:KeyDown(IN_MOVERIGHT)
		local aright=view.angles:Right()
		local afwd=aright:Angle():Right()*-1
		local add=Vector(0,0,0)
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
		Viewpos=BuildTrace(Viewpos,add).HitPos
		pos_addtime=CrT+0.01
	end
	if lastposset+0.1<CurTime() then
		RunConsoleCommand("wac_advbuild_moveplayer", Viewpos.x, Viewpos.y, Viewpos.z-65)
		for k,e in pairs(ghosts) do
			if IsValid(e) and !IsValid(e.Ent) then
				e:Remove()
				ghosts[k]=nil
			end
		end
		lastposset=CurTime()
	end
end
WAC.Hook("Think", "wac_cl_advbuild_th", Think)
