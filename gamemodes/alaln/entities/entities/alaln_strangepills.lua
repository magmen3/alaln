AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Strange Pills"
ENT.Spawnable = true
ENT.Category = "! Forsakened"
ENT.UseCD = 0
ENT.IconOverride = "editor/obsolete"
local math, table, Color, Vector, Angle, IsValid = math, table, Color, Vector, Angle, IsValid
local color_pills = Color(110, 110, 0)
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
	self:SetModelScale(0.7, 0)
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

local color_green = Color(110, 210, 110)
local color_red = Color(185, 15, 15)
function ENT:Use(ply)
	ply:PickupObject(self)
	self:EmitSound("vj_cofr/aom/pills/pills_drop.wav", 70, math.random(95, 105))
	if self.UseCD > CurTime() or self:IsConstrained() then return end
	if SERVER then
		self.UseCD = CurTime() + 1
		local rnd = math.random(1, 2)
		if rnd == 1 then
			for i = 1, 4 do
				ply:TakeDamage(math.random(2, 5), ply, ply)
			end

			BetterChatPrint(ply, "You feel yourself bad.", color_red)
		elseif rnd == 2 and ply:Health() < ply:GetMaxHealth() then
			for i = 1, 5 do
				ply:SetHealth(ply:Health() + math.random(1, 5))
			end

			BetterChatPrint(ply, "You feel yourself better.", color_green)
		end

		ply:SetNWInt("DrugUses", ply:GetNWInt("DrugUses", 0) + 1)
		ply:EmitSound("vj_cofr/aom/pills/pills_use.wav", 55, math.random(90, 110))
		ply:BetterViewPunch(AngleRand(-8, 8))
		self:Remove()
	end

	if ply:GetNWInt("DrugUses", 0) >= math.random(2, 3) then
		if CLIENT and ply == LocalPlayer() then
			surface.PlaySound("forsakened/addiction.mp3")
		end
		ply:AddAlalnState("crazyness", math.random(4, 16))
		ply:SetNWInt("DrugUses", 0)
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