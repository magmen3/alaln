AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Food"
ENT.Spawnable = true
ENT.Category = "! Forsakened"
ENT.UseCD = 0
ENT.IconOverride = "editor/obsolete"
ENT.CannibalOnly = false
local math, table, Color, Vector, Angle, IsValid = math, table, Color, Vector, Angle, IsValid
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

-- "models/gibs/humans/mgib_02.mdl"
-- format: multiline
local GibModels = {
	"models/mosi/fnv/props/gore/gorehead05.mdl",
	"models/mosi/fnv/props/gore/gorehead06.mdl",
	"models/mosi/fnv/props/gore/goreleg02.mdl",
	"models/mosi/fnv/props/gore/goreleg03.mdl",
	"models/mosi/fnv/props/gore/gorelegb02.mdl",
	"models/mosi/fnv/props/gore/goretorso02.mdl",
	"models/mosi/fnv/props/gore/goretorsob02.mdl"
}

function ENT:Initialize()
	if not SERVER then return end
	if self.CannibalOnly then
		self:SetModel(table.Random(GibModels))
	else
		self:SetModel(table.Random(FoodModels))
	end

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
		if self.CannibalOnly then
			self:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav", math.Clamp(data.Speed / 3, 20, 65), math.random(95, 105))
		else
			self:EmitSound("physics/plaster/ceiling_tile_impact_soft" .. math.random(1, 3) .. ".wav", math.Clamp(data.Speed / 3, 20, 65), math.random(95, 105))
		end

		self:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity() * .6)
	end
end

local color_green = Color(110, 210, 110)
local color_yellow = Color(210, 210, 110)
function ENT:Use(ply)
	ply:PickupObject(self)
	self:EmitSound("physics/plaster/ceiling_tile_impact_soft" .. math.random(1, 3) .. ".wav", 70, math.random(95, 105))
	if CLIENT or self.UseCD > CurTime() then return end
	self.UseCD = CurTime() + 1
	if (ply:GetAlalnState("class") == "Cannibal" and not self.CannibalOnly) or (self.CannibalOnly and ply:GetAlalnState("class") ~= "Cannibal") then
		BetterChatPrint(ply, "You don't wan't to eat this.", color_yellow)
		return
	end

	if not SBOXMode:GetBool() then
		if ply:GetAlalnState("hunger") <= 90 then
			ply:AddAlalnState("hunger", math.random(15, 25))
			BetterChatPrint(ply, "You ate food, now your hunger is " .. math.Round(ply:GetAlalnState("hunger"), 0) .. ".", color_green)
			ply:EmitSound("npc/barnacle/barnacle_gulp" .. math.random(1, 2) .. ".wav", 55, math.random(90, 110))
			ply:AddAlalnState("score", 0.3)
			if ply:Health() <= ply:GetMaxHealth() * 0.75 then ply:SetHealth(ply:Health() + math.random(5, 15)) end
			ply:BetterViewPunch(AngleRand(-8, 8))
			self:Remove()
		else
			BetterChatPrint(ply, "You are fed.", color_yellow)
		end
	else
		if ply:Health() <= ply:GetMaxHealth() * 0.85 then
			ply:SetHealth(ply:Health() + math.random(5, 15))
			ply:EmitSound("npc/barnacle/barnacle_gulp" .. math.random(1, 2) .. ".wav", 55, math.random(90, 110))
			ply:BetterViewPunch(AngleRand(-8, 8))
			self:Remove()
		else
			BetterChatPrint(ply, "You are fed.", color_yellow)
		end
	end
end

if CLIENT then
	function ENT:Draw()
		local Closeness = LocalPlayer():GetFOV() * EyePos():Distance(self:GetPos())
		local DetailDraw = Closeness < 300000
		if not DetailDraw then return end
		self:DrawModel()
	end
end