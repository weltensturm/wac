
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("entities/base_wire_entity/init.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/consolebox01a.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.seats = {}
end

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos+tr.HitNormal*10)
	ent:Spawn()
	ent:Activate()
	ent.Owner = ply	
	return ent
end

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end


function ENT:updateVehicles()
	MsgN("updated seat connector")
	for i = 1, 9 do
		self:SetNWEntity(i, self.seats[i])
	end
end


function ENT:addVehicle(e)
	if table.HasValue(self.seats, e) then return end
	table.insert(self.seats, e)
	e.wac_seatswitcher = self.Entity
	self:updateVehicles()
end


function ENT:removeVehicle(i)
	self.seats[i].wac_seatswitcher = nil
	table.remove(self.seats, i)
	self:updateVehicles()
end


function ENT:Use(p)
	if IsValid(p) and p:IsPlayer() then
		for _,v in pairs(self.seats) do
			if !IsValid(v:GetPassenger(0)) and !p:InVehicle() then
				p:EnterVehicle(v)
				break
			end
		end
	end
end

function ENT:switchSeat(p, int)
	if !self.seats[int] or self.seats[int]:GetPassenger(0):IsValid() then return end
	local oldang = p:GetAimVector():Angle()
	oldang.y = oldang.y+90
	p:ExitVehicle()
	p:EnterVehicle(self.seats[int])
	--p:SnapEyeAngles(self.seats[int]:GetAngles())
end

concommand.Add("wac_setseat", function(p,c,a)
	if !p:InVehicle() then return end
	local veh = p:GetVehicle()
	if veh.wac_seatswitcher then
		veh.wac_seatswitcher:switchSeat(p, tonumber(a[1]))
	end
end)

function ENT:Think()
	for k,v in pairs(self.seats) do
		if !IsValid(v) or !v.wac_seatswitcher then
			self:removeVehicle(k)
		end
	end
end


function ENT:BuildDupeInfo()
	local info=WireLib.BuildDupeInfo(self.Entity) or {}
	info.v={}
	for k,v in pairs(self.seats) do
		info.v[k]=v:EntIndex()
	end
	return info
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	WireLib.ApplyDupeInfo(self, ply, ent, info, GetEntByID)
	if (info.v) then
		self.seats={}
		for k,v in pairs(info.v) do
			local e=GetEntByID(v)
			if (!e) or e != GetEntByID(v) then
				e=ents.GetByIndex(v)
			end
			if !table.HasValue(self.seats,e) then
				self:addVehicle(e)
			end
		end
	end
end
