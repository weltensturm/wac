
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("entities/base_wire_entity/init.lua")

function ENT:Initialize()
	math.randomseed(CurTime())
	self.Entity:SetModel("models/props_c17/consolebox01a.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Seats={}
end

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local ent=ents.Create(ClassName)
	ent:SetPos(tr.HitPos+tr.HitNormal*10)
	ent:Spawn()
	ent:Activate()
	ent.Owner=ply	
	return ent
end

function ENT:AddVehicle(e)
	if table.HasValue(self.Seats,e) then return end
	table.insert(self.Seats,e)
	e.wac_seatswitcher=self.Entity
end

function ENT:RemoveSeat(int)
	self.Seats[int].wac_seatswitcher=nil
	table.remove(self.Seats,int)
end

function ENT:Use(p)
	if IsValid(p) and p:IsPlayer() then
		for _,v in pairs(self.Seats) do
			if !IsValid(v:GetPassenger(0)) and !p:InVehicle() then
				p:EnterVehicle(v)
				break
			end
		end
	end
end

function ENT:Think()
	for i=1,9 do
		if self:GetNWEntity("seat"..i) != self.Seats[i] then
			self:SetNWEntity("seat"..i, self.Seats[i])
		end
	end
	for k,v in pairs(self.Seats) do
		if !v or !IsValid(v) or !v.wac_seatswitcher then
			self:RemoveSeat(k)
		end
	end
end

function ENT:BuildDupeInfo()
	local info=WireLib.BuildDupeInfo(self.Entity) or {}
	info.v={}
	for k,v in pairs(self.Seats) do
		info.v[k]=v:EntIndex()
	end
	return info
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	WireLib.ApplyDupeInfo(self, ply, ent, info, GetEntByID)
	if (info.v) then
		self.Seats={}
		for k,v in pairs(info.v) do
			local e=GetEntByID(v)
			if (!e) or e != GetEntByID(v) then
				e=ents.GetByIndex(v)
			end
			if !table.HasValue(self.Seats,e) then
				self:AddVehicle(e)
			end
		end
	end
end

function ENT:SeatSwitch(p, int)
	if !self.Seats[int] or self.Seats[int]:GetPassenger(0):IsValid() then return end
	local oldang=p:GetAimVector():Angle()
	oldang.y=oldang.y+90
	p:ExitVehicle()
	p:EnterVehicle(self.Seats[int])
	--p:SnapEyeAngles(self.Seats[int]:GetAngles())
end

concommand.Add("wac_setseat", function(p,c,a)
	if !p:InVehicle() then return end
	local veh=p:GetVehicle()
	if veh.wac_seatswitcher then
		veh.wac_seatswitcher:SeatSwitch(p, tonumber(a[1]))
	end
end)

