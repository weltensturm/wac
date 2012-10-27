
if CLIENT then

	local cvars = {
		enable = CreateClientConVar("wac_cl_tbf", 0, true, false),
		framerate = CreateClientConVar("wac_cl_tbf_framerate", 0, true, false),
		width = CreateClientConVar("wac_cl_tbf_width", 217, true, false),
		interval = CreateClientConVar("wac_cl_tbf_interval", 0, true, false),
		hide = CreateClientConVar("wac_cl_tbf_hide", 0, true, false),
		y = CreateClientConVar("wac_cl_tbf_x", 50, true, false),
		x = CreateClientConVar("wac_cl_tbf_y", 108, true, false),
	}
	
	local color = {
		line = Color(255, 165, 15, 155),
		background = Color(15, 15, 15, 155)
	}
	
	local lastTaken = 0
	
	local frames = {}
	local frameCurrent = 0
	
	local averageFrames = {}
	local averageCurrent = 0

	wac.hook("HUDPaint", "wac_frametime_hud", function()
		if cvars.enable:GetInt() != 1 then return end
		
		local screen = {w = ScrW(), h = ScrH()}
		local pos = {x = cvars.x:GetInt(), y = cvars.y:GetInt()}
		local width = cvars.width:GetInt()
		
		local frameTime = os.clock() - lastTaken
		lastTaken = frameTime + lastTaken
		
		if #frames != width then
			if #frames < width then
				for i=1, width - #frames do table.insert(frames, 1, 0) end
			else
				for i=1, #frames - width do table.remove(frames, 1) end
			end
		end
		
		local average = 0
		averageCurrent = averageCurrent + 1
		averageFrames[averageCurrent] = frameTime
		if averageCurrent>=7 then
			for k,v in pairs(averageFrames) do average = average + v end
			average = math.floor(average/#averageFrames*10000)/10000
			averageCurrent = 0
			table.Empty(averageFrames)
		end
		
		frameCurrent = frameCurrent + 1
		frames[frameCurrent] = frameTime
		
		--[[
	sys.presetlines={
		{10, 25, 0, 25},
		{10, 50, 0, 50},
		{10, 75, 0, 75},
		{10, 100, 0, 100},
				surface.DrawLine(SW-W-t[1]-X, SH-t[2]-Y, SW-t[3]-X, SH-t[4]-Y)
	}]]
		if cvars.hide:GetInt() == 0 then
			surface.SetDrawColor(0, 0, 0, 155)
			
			local x = screen.w - width - pos.x
			local y = screen.h - pos.y
			local w = screen.w - pos.x
			local h = screen.h - pos.y
			surface.DrawLine(x - 10, y - 25, w, h - 25)
			surface.DrawLine(x - 10, y - 50, w, h - 50)
			surface.DrawLine(x - 10, y - 75, w, h - 75)
			surface.DrawLine(x - 10, y - 100, w, h - 100)
		end

	end)
	
	
	wac.addMenuPanel(wac.menu.tab, wac.menu.category, "Frametime HUD", function(panel)
		panel:AddControl("Slider", {
			Label = "Width", Type = "int", Min = 50,
			Max = 1680, Command = "wac_cl_tbf_width",
		})
		panel:AddControl("Slider", {
			Label = "Interval", Type = "int", Min = 0,
			Max = 50, Command = "wac_cl_tbf_interval",
		})
		panel:AddControl("Slider", {
			Label = "X", Type = "int", Min = 0, Max = 1800,
			Command = "wac_cl_tbf_X",
		})
		panel:AddControl("Slider", {
			Label = "Y", Type = "int", Min = 0, Max = 1800,
			Command = "wac_cl_tbf_Y",
		})
		panel:CheckBox("Enable","wac_cl_tbf")
		panel:CheckBox("Framerate","wac_cl_tbf_framerate")
		panel:CheckBox("Hide","wac_cl_tbf_hide")
	end)

	
	
	--[[
	local c="WAC"
	local n="Frame Meter"

	local n1="Number"
	local n2="BarDelay"

	local sys={
		lastfrm=0,
		tInfo={},
		colors={
			[1]=Color(255,165,15,155),
			[2]=Color(15,15,15,155),
		},
		[n1]={
			val=0,
			interval=0,
			tData={},
		},
		[n2]={
			val=0,
			interval=0,
			tData={},
			iTemp=0,
		},
		text={
			[1]={
				"25",
				"50",
				"75",
				"100",
				".039",
				".019",
				".013",
				".009",
			},
			[2]={
				"60",
				"30",
				"20",
				"15",
				".016",
				".033",
				".049",
				".066",
			}
		}
	}

	sys.presetlines={
		{10, 25, 0, 25},
		{10, 50, 0, 50},
		{10, 75, 0, 75},
		{10, 100, 0, 100},
	}

	local last = 0
	wac.hook("HUDPaint", "wac_tbf", function()
		if sys.enable:GetInt() != 1 then return end
		local W=sys.width:GetInt()
		local SW, SH = ScrW(), ScrH()
		local FrT=CurTime()-sys.lastfrm
		sys.lastfrm=CurTime()
		local X=sys.X:GetInt()
		local Y=sys.Y:GetInt()
		sys.lasttime=crt
		if #sys.tInfo != W then
			if #sys.tInfo<W then
				for i=1, W-#sys.tInfo do
					table.insert(sys.tInfo, 1, 0)
				end
			else
				for i=1, #sys.tInfo-W do
					table.remove(sys.tInfo, 1)
				end
			end
		end
		sys[n1].interval=sys[n1].interval+1
		sys[n1].tData[sys[n1].interval]=FrT
		if sys[n1].interval>=7 then
			sys[n1].interval=0
			sys[n1].val=0
			for _, k in pairs(sys[n1].tData) do
				sys[n1].val=sys[n1].val+k
			end
			sys[n1].val=math.floor(sys[n1].val/#sys[n1].tData*10000)/10000
			table.Empty(sys[n1].tData)
		end
		sys[n2].interval=sys[n2].interval+1
		sys[n2].tData[sys[n2].interval]=FrT
		if sys[n2].interval>=sys.interval:GetInt() then
			sys[n2].iTemp=0
			for _, k in pairs(sys[n2].tData) do
				sys[n2].iTemp=sys[n2].iTemp+k
			end
			table.insert(sys.tInfo, sys[n2].iTemp/#sys[n2].tData)
			table.Empty(sys[n2].tData)
			sys[n2].interval=0
		end
		if sys.hide:GetInt() == 0 then
			surface.SetDrawColor(0, 0, 0, 155)
			for k, t in pairs(sys.presetlines) do
				surface.DrawLine(SW-W-t[1]-X, SH-t[2]-Y, SW-t[3]-X, SH-t[4]-Y)
			end
			surface.DrawLine(SW-X, SH-Y, SW-X, SH-100-Y)
			surface.DrawLine(SW-X, SH-Y, SW-W-X, SH-Y)
			surface.DrawLine(SW-W-1-X, SH-Y, SW-W-1-X, SH-100-Y)
			draw.SimpleTextOutlined("FPS/TBF", "DefaultSmall", SW-W+8-X, SH-110-Y, sys.colors[1], TEXT_ALIGN_RIGHT, 0, 1,sys.colors[2])
			draw.SimpleTextOutlined(" "..math.floor(1/sys[n1].val).."/"..sys[n1].val, "DefaultSmall", SW-W+8-X, SH-110-Y, sys.colors[1], TEXT_ALIGN_LEFT, 0, 1,sys.colors[2])
			surface.SetDrawColor(16,16,16,50)
			surface.DrawRect(SW-X-W, SH-Y-100, W, 100)
			if sys.mode:GetInt() == 0 then
				for i=1,4 do
					draw.SimpleTextOutlined(sys.text[2][i].."/"..sys.text[2][i+4], "DefaultSmall", SW-W-1-X, SH-1-Y-i*25, sys.colors[1], TEXT_ALIGN_RIGHT, 0, 1, sys.colors[2])
				end
				for i=1, W do
					if sys.tInfo[i] != 0 then
						surface.SetDrawColor(255, 165-(sys.tInfo[i]*1800), 15, 155)
						surface.DrawLine(SW-i-X, SH-Y, SW-i-X, SH-Y-sys.tInfo[i]*1500)
					end
				end
			else
				for i=1,4 do
					draw.SimpleTextOutlined(sys.text[1][i].."/"..sys.text[1][i+4], "DefaultSmall", SW-W-1-X, SH-1-Y-i*25, sys.colors[1], TEXT_ALIGN_RIGHT, 0, 1, sys.colors[2])
				end
				for i=1, W do
					if sys.tInfo[i] != 0 then
						surface.SetDrawColor(255, 165-(sys.tInfo[i]*1800), 15, 155)
						surface.DrawLine(SW-i-X, SH-Y, SW-i-X, SH-Y-1/sys.tInfo[i])
					end
				end
			end
		end
	end)

	WAC.AddMenuPanel(c,n,function(CPanel,t)
		CPanel:AddControl("Slider", {
			Label = "Width",
			Type = "int",
			Min = 50,
			Max = 1680,
			Command = "wac_cl_tbf_width",
		})
		CPanel:AddControl("Slider", {
			Label = "Interval",
			Type = "int",
			Min = 0,
			Max = 50,
			Command = "wac_cl_tbf_interval",
		})
		CPanel:AddControl("Slider", {
			Label = "X",
			Type = "int",
			Min = 0,
			Max = 1800,
			Command = "wac_cl_tbf_X",
		})
		CPanel:AddControl("Slider", {
			Label = "Y",
			Type = "int",
			Min = 0,
			Max = 1800,
			Command = "wac_cl_tbf_Y",
		})
		CPanel:CheckBox("Enable","wac_cl_tbf")
		CPanel:CheckBox("FPS View","wac_cl_tbf_mode")
		CPanel:CheckBox("Hide","wac_cl_tbf_hide")
	end)
	]]

end