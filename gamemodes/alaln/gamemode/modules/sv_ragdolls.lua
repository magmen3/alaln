util.AddNetworkString("alaln-ragplayercolor")
local meta = FindMetaTable("Player")
local metaent = FindMetaTable("Entity")
if not (meta or metaent) then return end
function metaent:BetterSetPlayerColor(col)
	if not (col or self) then
		DebugPrint("Error! Calling BetterSetPlayerColor() without args")
		return
	end

	timer.Simple(.1, function()
		if not IsValid(self) then return end
		net.Start("alaln-ragplayercolor")
		net.WriteEntity(self)
		net.WriteVector(col)
		net.Broadcast()
	end)
end

local vecgovno = Vector(0, 0, 10)
function meta:CreateRagdoll()
	if not (self or self:IsValid() or self:IsPlayer()) then return end
	self.DeathRagdoll = self.DeathRagdoll or false
	local ply_pos = self:GetPos() - vecgovno
	local ply_ang = self:GetAngles()
	local ply_mdl = self:GetModel()
	local ply_skn = self:GetSkin()
	local ply_col = self:GetColor()
	local ply_mat = self:GetMaterial()
	local ply_submat0 = self:GetSubMaterial(0)
	local ply_submat2 = self:GetSubMaterial(2)
	local playerModelIsRagdoll = self:GetBoneCount() > 1
	local ent
	if playerModelIsRagdoll then
		ent = ents.Create("prop_ragdoll")
	else
		ent = ents.Create("prop_physics")
	end

	ent:SetPos(ply_pos)
	ent:SetAngles(ply_ang - Angle(ply_ang.p, 0, 0))
	ent:SetModel(ply_mdl)
	ent:SetSkin(ply_skn)
	ent:SetColor(ply_col)
	ent:SetMaterial(ply_mat)
	ent:SetSubMaterial(0, ply_submat0)
	ent:SetSubMaterial(2, ply_submat2)
	ent:SetCreator(self)
	ent:BetterSetPlayerColor(self:GetPlayerColor())
	self:Spectate(OBS_MODE_CHASE)
	self:SpectateEntity(ent)
	for _, bg in ipairs(self:GetBodyGroups()) do
		ent:SetBodygroup(bg.id, self:GetBodygroup(bg.id))
	end

	ent:Spawn()
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then phys:SetMass(phys:GetMass()) end
	if not ent:IsValid() then return end
	self.DeathRagdoll = ent
	local plyvel = self:GetVelocity()
	if playerModelIsRagdoll then
		for i = 0, ent:GetPhysicsObjectCount() - 1 do
			local bone = ent:GetPhysicsObjectNum(i)
			if bone and bone:IsValid() then
				local bonepos, boneang = self:GetBonePosition(ent:TranslatePhysBoneToBone(i))
				bone:SetPos(bonepos)
				bone:SetAngles(boneang)
				bone:SetVelocity(plyvel * 0.20)
			end
		end

		ent:SetFlexScale(self:GetFlexScale())
		for i = 1, ent:GetFlexNum() do
			ent:SetFlexWeight(i, self:GetFlexWeight(i))
		end
	else
		phys:SetVelocity(plyvel * 2)
	end

	if self:IsOnFire() then ent:Ignite(math.random(6, 8), 150) end
	ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetNWEntity("plyrag", ent)
end