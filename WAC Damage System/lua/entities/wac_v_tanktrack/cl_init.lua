include('shared.lua')

local mdl="models/WeltEnSTurm/NDS/tank/tracks01.mdl"
function ENT:Initialize()
	math.randomseed(CurTime())
	self.chain={};self.chainr={};self.chaind={}
	self.curve=8
	self.segs=15
	
	self.height=22.5
	self.segang=22.5
	
	self.chain={
		m={},
		cb={},
		cf={},
		t={},
		md={}
	}
	self.offset=0
end

function ENT:Draw()
	self.DrawTime=CurTime()+0.1
end

function ENT:CheckChain()
	for i=1,self.segs do
		if !ValidEntity(self.chain.m[i]) then
			self.chain.m[i]=ClientsideModel(mdl, RENDERGROUP_OPAQUE)
		end
		if !ValidEntity(self.chain.t[i]) then
			self.chain.t[i]=ClientsideModel(mdl, RENDERGROUP_OPAQUE)
		end
	end
	for i=1,self.curve do
		if !ValidEntity(self.chain.cb[i]) then
			self.chain.cb[i]=ClientsideModel(mdl, RENDERGROUP_OPAQUE)
		end
		if !ValidEntity(self.chain.cf[i]) then
			self.chain.cf[i]=ClientsideModel(mdl, RENDERGROUP_OPAQUE)
		end
	end
end

local ang;local pos;local nang;local ri;local fwd;local lastchainh;local firstchainh;local xpos;local up;local trw;local angl
local aang=Angle(0,0,0)
local NULLVEC=Vector(0,0,0)
function ENT:Think()
	local crt=CurTime()
	self:CheckVisible(crt)
	self:CheckChain()
	ang=self:GetAngles()
	pos=self:GetPos()
	ri=self:GetRight()
	up=self:GetUp()
	fwd=self:GetForward()
	nang=self:GetAngles()
	nang:RotateAroundAxis(fwd, 180)
	trw=util.QuickTrace(pos, up*-10, self.Entity)
	if trw.Hit then
		local lvel=self:WorldToLocal(pos+self:GetVelocity())
		self.offset=self.offset+lvel.y/50
		self.offset=self:TrimOffset(self.offset)
	end
	
	--###########] main chain (the piece on the ground)
	for i=1,#self.chain.m do
		posx=pos-ri*#self.chain.m*4.5+ri*(i*9+self.offset)
		local tr=util.QuickTrace(posx, up*-10, self.Entity)
		self.chain.m[i]:SetAngles(ang)
		self.chain.m[i]:SetPos(tr.HitPos)
		self.chain.md[i]=tr.HitPos:Distance(posx)
		self.chain.t[i]:SetAngles(nang)
		self.chain.t[i]:SetPos(pos-ri*#self.chain.m*4.5+ri*(i*9-self.offset+9)+up*(self.height*2-self.chain.md[i]))
	end
	
	--###########] rotate it a bit, depending what "offset" we have, and set xpos to the front end of the chain
	ang:RotateAroundAxis(fwd, self.offset*-2.5+self.segang)
	xpos=pos+ri*(9*#self.chain.m/2+9)+up*(self.height-self.chain.md[#self.chain.m])
	local apos
	--###########] curve front
	for i=1,#self.chain.cf do
		ang:RotateAroundAxis(fwd, -self.segang)
		self.chain.cf[i]:SetAngles(ang)
		apos=xpos+ang:Up()*-self.height
		self.chain.cf[i]:SetPos(apos)
	end
	xpos=pos+ri*-(9*#self.chain.m/2-9)+up*(self.height-self.chain.md[1])
	--###########]curve back
	for i=1,#self.chain.cb do
		ang:RotateAroundAxis(fwd, -self.segang)
		self.chain.cb[i]:SetAngles(ang)
		apos=xpos+ang:Up()*-self.height
		self.chain.cb[i]:SetPos(apos)
	end
	self:NextThink(crt)
	return true
end

--###########] Trim offset.. if we add vel.y/50, it may be it's greater than 9 or smaller than 0. To avoid that
function ENT:TrimOffset(o)
	o=o-(o>9 and 9 or (o<0 and -9 or 0))
	if o<0 or o>9 then
		o=self:TrimOffset(o)
	end
	return o
end

local ncol=Color(0,0,0,0)
function ENT:CheckVisible(crt)
	if (!self.DrawTime or crt>self.DrawTime) then
		if !self.Invisible then
			for i=1, #self.chain do
				self.chain[i]:SetColor(ncol)
			end
			self.Invisible=true
		end
		return
	end
	if self.Invisible then
		for i=1, #self.chain do
			self.chain[i]:SetColor(255,255,255,255)
		end
		self.Invisible=false
	end
end

function ENT:OnRemove()
	for k,v in pairs(self.chain) do
		for a,s in pairs(v) do
			if type(s)!="number" then
				s:Remove()
			end
		end
	end
end