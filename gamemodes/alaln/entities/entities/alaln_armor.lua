AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Armor"
ENT.Spawnable = true
ENT.Category = "Forsakened"
ENT.UseCD = 0
local math, table, Color = math, table, Color
function ENT:Initialize()
	if not SERVER then return end
	self:SetModel(Model("models/Items/hevsuit.mdl"))
	self:SetMaterial("forsakened/hevsuit_sheet")
	local mins, maxs = self:GetModelBounds()
	local x0 = mins.x -- Define the min corner of the box
	local y0 = mins.y
	local z0 = mins.z
	local x1 = maxs.x -- Define the max corner of the box
	local y1 = maxs.y
	local z1 = maxs.z
	local vecs = {Vector(x0, y0, z0), Vector(x0, y0, z1), Vector(x0, y1, z0), Vector(x0, y1, z1), Vector(x1, y0, z0), Vector(x1, y0, z1), Vector(x1, y1, z0), Vector(x1, y1, z1)}
	self:PhysicsInitConvex(vecs)
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
		self:EmitSound("physics/metal/metal_canister_impact_soft" .. math.random(1, 3) .. ".wav", math.Clamp(data.Speed / 3, 20, 85), math.random(95, 105))
		self:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity() * .6)
	end
end

local color_green = Color(25, 225, 25)
local color_yellow = Color(255, 235, 0)
function ENT:Use(ply)
	if CLIENT or self.UseCD > CurTime() then return end
	self.UseCD = CurTime() + 1
	if ply:Armor() < 1 then
		if ply:GetAlalnState("class") == "Cannibal" then
			ply:SetSubMaterial()
			ply:SetSubMaterial(3, "models/screamer/corpse9")
		elseif ply:GetAlalnState("class") == "Berserker" then
			ply:SetSubMaterial()
			ply:SetSubMaterial(3, "models/in/other/corpse1_player_charple")
		end

		ply:SetArmor(100)
		BetterChatPrint(ply, "You wear armor.", color_green)
		self:EmitSound("npc/combine_soldier/gear" .. math.random(1, 6) .. ".wav", 55, math.random(90, 110))
		ply:EmitSound("hl1/fvox/bell.wav", 75, math.random(90, 110))
		timer.Simple(1, function()
			if not (IsValid(ply)) then return end
			ply:EmitSound("hl1/fvox/voice_on.wav", 100, math.random(90, 110))
		end)
		ply:SetModel(Model("models/sgg/hev_corpse.mdl"))
		ply:SetNWBool("HasArmor", true)
		ply:AddAlalnState("score", 0.5)
		self:Remove()
	elseif ply:Armor() >= 1 and ply:Armor() < 95 then
		ply:SetArmor(100)
		self:EmitSound("npc/combine_soldier/gear" .. math.random(1, 6) .. ".wav", 55, math.random(90, 110))
		ply:SetModel(Model("models/sgg/hev_corpse.mdl"))
		BetterChatPrint(ply, "You repaired your armor.", color_green)
		ply:SetNWBool("HasArmor", true)
		ply:EmitSound("hl1/fvox/power_restored.wav", 100, math.random(90, 110))
		timer.Simple(1.8, function()
			if not (IsValid(ply)) then return end
			if ply:Health() < ply:GetMaxHealth() * 0.75 then
				ply:EmitSound("hl1/fvox/morphine_shot.wav", 100, math.random(90, 110))
				ply:SetHealth(ply:Health() + math.random(25, 45))
			end
		end)
		self:Remove()
	elseif ply:Armor() >= 95 then
		BetterChatPrint(ply, "You already have armor.", color_yellow)
	end

	ply:SetupHands()
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end