TOOL.Category = WAC and WAC.Names.ToolCategory or "Render"
TOOL.Name = "RT7"
TOOL.Command=nil
TOOL.ConfigName = ""

list.Set("screenmodels", "models/weltensturm/rt7/rt7screen.mdl", {})
list.Set("cammodels", "models/Tools/Camera/camera.mdl", {})
list.Set("cammodels", "models/dav0r/camera.mdl", {})

if (CLIENT) then
	language.Add("Tool_wac_rt7_tool_name", "7 additional RT cams/screens")
	language.Add("Tool_wac_rt7_tool_desc", "Spawn them.")
	language.Add("Tool_wac_rt7_tool_0", "Left Click: Cam, Right Click: Screen")
end

local convars={
	["screenmodel"]="models/weltensturm/rt7/rt7screen.mdl",
	["cammodel"]="models/dav0r/camera.mdl",
	["channel"]=1
}

for k,s in pairs(convars) do
	TOOL.ClientConVar[k]=s
end

function TOOL:LeftClick(tr)
	if CLIENT then return true end
	local e=ents.Create("wac_rt7_cam")
	e:SetPos(self:GetOwner():EyePos())
	e:SetAngles(self:GetOwner():GetAngles())
	e:SetModel(self:GetClientInfo("cammodel"))
	e.Channel=self:GetClientNumber("channel")
	e.Owner=self:GetOwner()
	e:Spawn()
	e:Activate()
end

function TOOL:RightClick(tr)
	if CLIENT then return true end
	if !tr.Hit then return end
	local e=ents.Create("wac_rt7_screen")
	e:SetPos(tr.HitPos)
	local eyeang=self:GetOwner():GetAimVector():Angle()
	e:SetAngles(Angle(0, eyeang.y, tr.HitNormal:Angle().r))
	e:SetModel(self:GetClientInfo("screenmodel"))
	e.Channel=self:GetClientNumber("channel")
	e:Spawn()
	e:Activate()
	undo.Create("prop")
	undo.AddEntity(e)
	undo.SetPlayer(self:GetOwner())
	undo.SetCustomUndoText("Undone RT7 Screen")
	undo.Finish()
end

function TOOL:Reload(tr)
	if CLIENT then return true end
	SetGlobalEntity("wac_cam_rt"..self:GetClientNumber("channel"), self:GetOwner())
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("PropSelect", {
		Label = "Camera Model",
		ConVar = "wac_rt7_tool_cammodel",
		Category = "",
		Models = list.Get("cammodels")
	})
	CPanel:AddControl("PropSelect", {
		Label = "Screen Model",
		ConVar = "wac_rt7_tool_screenmodel",
		Category = "",
		Models = list.Get("screenmodels")
	})
	CPanel:AddControl('Slider', {
		Label = "Channel",
		Type = "Integer", 
		Min = 1,
		Max = 7,
		Command = "wac_rt7_tool_channel"
	})
end