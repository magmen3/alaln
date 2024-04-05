AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Food"
ENT.Spawnable = true
ENT.Category = "Forsakened"
ENT.UseCD = 0
-- format: multiline
local FoodModels = {
	"models/props_junk/garbage_milkcarton002a.mdl",
	"models/props_junk/garbage_glassbottle003a.mdl",
	"models/props_junk/garbage_glassbottle002a.mdl",
	"models/props_junk/garbage_takeoutcarton001a.mdl",
	"models/props_junk/watermelon01.mdl",
	"models/props_junk/PopCan01a.mdl"
}

function ENT:Initialize()
	if not SERVER then return end
	self:SetModel(table.Random(FoodModels))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetAngles(AngleRand(-90, 90))
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetContents(CONTENTS_SOLID)
		phys:SetMass(20)
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:PhysicsCollide(data, ent)
	if data.DeltaTime > .1 then
		self:EmitSound("physics/plaster/ceiling_tile_impact_soft" .. math.random(1, 3) .. ".wav", math.Clamp(data.Speed / 3, 20, 65), math.random(95, 105))
		self:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity() * .6)
	end
end

function ENT:Use(ply)
	if CLIENT or self.UseCD > CurTime() then return end
	self.UseCD = CurTime() + 1
	if ply:GetHunger() <= 90 then
		ply:AddHunger(math.random(15, 25))
		--ply:ChatPrint("You eated food, now your hunger is " .. math.Round(ply:GetHunger(), 0) .. ".")
		BetterChatPrint(ply, "You eated food, now your hunger is " .. math.Round(ply:GetHunger(), 0) .. ".", Color(25, 225, 25))
		ply:EmitSound("npc/barnacle/barnacle_gulp" .. math.random(1, 2) .. ".wav", 55, math.random(90, 110))
		ply:AddScore(0.3)
		self:Remove()
	else
		BetterChatPrint(ply, "You are fed.", Color(255, 235, 0))
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end