AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Armor"
ENT.Spawnable = true
ENT.Category = "Forsakened"
ENT.UseCD = 0
function ENT:Initialize()
	if not SERVER then return end
	self:SetModel(Model("models/Items/hevsuit.mdl"))
	self:SetMaterial("phoenix_storms/torpedo")
	local mins, maxs = self:GetModelBounds()
	local x0 = mins.x -- Define the min corner of the box
	local y0 = mins.y
	local z0 = mins.z
	local x1 = maxs.x -- Define the max corner of the box
	local y1 = maxs.y
	local z1 = maxs.z
	self:PhysicsInitConvex({Vector(x0, y0, z0), Vector(x0, y0, z1), Vector(x0, y1, z0), Vector(x0, y1, z1), Vector(x1, y0, z0), Vector(x1, y0, z1), Vector(x1, y1, z0), Vector(x1, y1, z1)})
	self:EnableCustomCollisions(true)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetContents(CONTENTS_SOLID)
		phys:SetMass(100)
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:PhysicsCollide(data, ent)
	if data.DeltaTime > .1 then
		self:EmitSound("physics/metal/metal_canister_impact_soft" .. math.random(1, 3) .. ".wav", math.Clamp(data.Speed / 3, 20, 65), math.random(95, 105))
		self:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity() * .6)
	end
end

function ENT:Use(ply)
	if CLIENT or self.UseCD > CurTime() then return end
	self.UseCD = CurTime() + 1
	if ply:Armor() < 1 then
		ply:SetArmor(100)
		BetterChatPrint(ply, "You wear armor.", Color(25, 225, 25))
		ply:EmitSound("npc/combine_soldier/gear" .. math.random(1, 6) .. ".wav", 55, math.random(90, 110))
		ply:SetModel("models/sgg/hev_corpse.mdl")
		ply:SetSubMaterial(0, "phoenix_storms/dome")
		ply:SetSubMaterial(2, "phoenix_storms/torpedo")
		ply:SetWalkSpeed(ply:GetWalkSpeed() * 0.8)
		ply:SetRunSpeed(ply:GetRunSpeed() * 0.8)
		ply:SetJumpPower(ply:GetJumpPower() * 0.8)
		ply:SetSlowWalkSpeed(ply:GetSlowWalkSpeed() * 0.8)
		ply:SetCrouchedWalkSpeed(ply:GetCrouchedWalkSpeed() * 0.9)
		ply:SetNWBool("HasArmor", true)
		self:Remove()
	elseif ply:Armor() >= 1 and ply:Armor() < 95 then
		ply:SetArmor(100)
		ply:EmitSound("npc/combine_soldier/gear" .. math.random(1, 6) .. ".wav", 55, math.random(90, 110))
		ply:SetModel("models/sgg/hev_corpse.mdl")
		ply:SetSubMaterial(0, "phoenix_storms/dome")
		ply:SetSubMaterial(2, "phoenix_storms/torpedo")
		BetterChatPrint(ply, "You repaired your armor.", Color(25, 225, 25))
		ply:SetNWBool("HasArmor", true)
		self:Remove()
	elseif ply:Armor() >= 95 then
		BetterChatPrint(ply, "You already have armor.", Color(255, 235, 0))
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end