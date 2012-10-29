
TOOL.Category = wac.menu.category
TOOL.Name = "Pod Camera"
TOOL.Command=nil
TOOL.ConfigName = ""

list.Set("cammodels", "models/Tools/Camera/camera.mdl", {})
list.Set("cammodels", "models/dav0r/camera.mdl", {})

if (CLIENT) then
	language.Add("Tool_wac_podcamera_name", "Pod Camera")
	language.Add("Tool_wac_podcamera_desc", "Advanced Cameras")
	language.Add("Tool_wac_podcamera_0", "Left Click: Spawn")
end

local convars={
	["model"]		={1,"models/Tools/Camera/camera.mdl"},
	["freelook"]		={0,1},
	["drawcrosshair"] ={0,0}
}

for k,s in pairs(convars) do
	TOOL.ClientConVar[k]=s[2]
end

local function CreateCam(ply, Ang, Pos, t)
	local e=ents.Create("wac_v_camera")
	e:SetPos(Pos)
	e:SetAngles(Ang)
	e.Owner=ply
	e:SetNWBool("freelook",util.tobool(t["freelook"][2]))
	e:SetNWBool("drawcrosshair",util.tobool(t["drawcrosshair"][2]))
	e:SetModel(t["model"][2])
	local ttable={
		t=t,
	}
	table.Merge(e:GetTable(), ttable)
	e:Spawn()
	e:Activate()
	return e
end
duplicator.RegisterEntityClass("wac_v_camera", CreateCam, "Ang", "Pos", "t")

function TOOL:LeftClick(tr)
	if CLIENT then return true end
	local e=CreateCam(self.Owner, Angle(0,0,0), tr.HitPos+Vector(0,0,20), convars)
	undo.Create("wac_v_camera")
	undo.AddEntity(e)
	undo.SetPlayer(self:GetOwner())
	undo.SetCustomUndoText("Undone Pod Camera")
	undo.Finish()
end

function TOOL:RightClick(tr)
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("PropSelect", {
		Label = "Camera Model",
		ConVar = "wac_podcamera_model",
		Category = "",
		Models = list.Get("cammodels")
	})
	CPanel:CheckBox("Free Look", "wac_podcamera_freelook")
	CPanel:CheckBox("Crosshair", "wac_podcamera_drawcrosshair")
end

local lastupdate=0
function TOOL:Think()
	local crt=CurTime()
	if lastupdate<crt+0.3 then
		lastupdate=crt
		for k, v in pairs(convars) do
			if v[1]==1 then
				v[2]=self:GetClientInfo(k)
			else
				v[2]=self:GetClientNumber(k)
			end
		end
	end
end
