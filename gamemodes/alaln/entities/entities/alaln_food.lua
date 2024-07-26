AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Food"
ENT.Spawnable = true
ENT.Category = "Forsakened"
ENT.UseCD = 0
local math, table, Color = math, table, Color
-- format: multiline
local FoodModels = {
	"models/props_junk/garbage_milkcarton002a.mdl",
	"models/props_junk/garbage_glassbottle003a.mdl",
	"models/props_junk/garbage_glassbottle002a.mdl",
	"models/props_junk/garbage_takeoutcarton001a.mdl",
	"models/props_junk/garbage_metalcan001a.mdl",
	"models/props_junk/garbage_metalcan002a.mdl",
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

local color_green = Color(25, 225, 25)
local color_yellow = Color(255, 235, 0)
function ENT:Use(ply)
	if CLIENT or self.UseCD > CurTime() then return end
	self.UseCD = CurTime() + 1
	if ply:GetAlalnState("class") == "Cannibal" then
		BetterChatPrint(ply, "You don't wan't to eat this.", color_yellow)
		return
	end

	if ply:GetAlalnState("hunger") <= 90 then
		ply:AddAlalnState("hunger", math.random(15, 25))
		--ply:ChatPrint("You ate food, now your hunger is " .. math.Round(ply:GetAlalnState("hunger"), 0) .. ".")
		BetterChatPrint(ply, "You ate food, now your hunger is " .. math.Round(ply:GetAlalnState("hunger"), 0) .. ".", color_green)
		ply:EmitSound("npc/barnacle/barnacle_gulp" .. math.random(1, 2) .. ".wav", 55, math.random(90, 110))
		ply:AddAlalnState("score", 0.3)
		if ply:Health() < ply:GetMaxHealth() * 0.75 then
			ply:SetHealth(ply:Health() + math.random(5, 15))
		end
		self:Remove()
	else
		BetterChatPrint(ply, "You are fed.", color_yellow)
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end