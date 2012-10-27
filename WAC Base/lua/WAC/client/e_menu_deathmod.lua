
local c="WAC"
local n="Death View"

WAC.AddMenuPanel(c,n,function(CPanel,t)
	CPanel:CheckBox("First Person Death","wac_cl_fpdeath")
	CPanel:CheckBox("Color Fade","wac_cl_colordeath")
end)
