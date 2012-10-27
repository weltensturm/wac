local MetaEntity = FindMetaTable("Entity")

function MetaEntity:SetDetailStatus(IsDetail, ParentEntity, Offset)
	if IsDetail then
		if self == ParentEntity then Msg("Tried to parent to itself.\n") return false end
		if self.Parent then Msg("Tried to parent when already parented.\n") return false end
		if self.Details then Msg("Tried to parent a parent prop.\n") return false end
		self:SetParent(ParentEntity)
		self.Parent = ParentEntity
		self.Offset = Offset
		ParentEntity.Details = ParentEntity.Details or {}
		table.insert(ParentEntity.Details, self)
	end
	if !IsDetail then
		if !self.Parent then Msg("Tried unparent a non-parented prop.\n") return false end
		self:SetParent()
		for k,d in pairs(self.Parent.Details) do
			if d==self then
				self.Parent.Details[k]=nil
			end
		end
		if #self.Parent.Details==0 then
			self.Parent.Details=nil
		end
		self:SetPos(self.Parent:LocalToWorld(self.Offset))
		self.Parent = nil
		self:GetPhysicsObject():Wake()
	end
end

function MetaEntity:IsParent()
	if self.Details then return true else return false end
end

function MetaEntity:IsDetail()
	if self.Parent then return true else return false end
end