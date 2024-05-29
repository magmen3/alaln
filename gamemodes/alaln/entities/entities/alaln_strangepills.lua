AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Strange Pills"
ENT.Spawnable = true
ENT.Category = "Forsakened"
ENT.UseCD = 0
local color_pills = Color(175, 165, 65)
function ENT:Initialize()
	if not SERVER then return end
	self:SetModel(Model("models/vj_cofr/aom/w_medkit.mdl"))
	self:SetColor(color_pills)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetAngles(AngleRand(-90, 90))
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetContents(CONTENTS_SOLID)
		phys:SetMass(30)
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:PhysicsCollide(data, ent)
	if data.DeltaTime > .1 then
		self:EmitSound("vj_cofr/aom/pills/pills_drop.wav", math.Clamp(data.Speed / 3, 20, 65), math.random(95, 105))
		self:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity() * .6)
	end
end

local color_green = Color(25, 225, 25)
local color_red = Color(165, 0, 0)
function ENT:Use(ply)
	if CLIENT or self.UseCD > CurTime() then return end
	self.UseCD = CurTime() + 1
	if math.random(1, 2) == 1 then
		for i = 1, 4 do
			ply:TakeDamage(math.random(2, 5), ply, ply)
		end

		BetterChatPrint(ply, "You feel yourself bad.", color_red)
	else
		for i = 1, 5 do
			ply:SetHealth(ply:Health() + math.random(2, 5))
		end

		BetterChatPrint(ply, "You feel good.", color_green)
	end

	ply:EmitSound("vj_cofr/aom/pills/pills_use.wav", 55, math.random(90, 110))
	self:Remove()
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end