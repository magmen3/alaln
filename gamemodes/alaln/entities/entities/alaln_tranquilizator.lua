AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Tranquilizator"
ENT.Spawnable = true
ENT.Category = "! Forsakened"
ENT.UseCD = 0
ENT.IconOverride = "editor/obsolete"
local math, table, Color, Vector, Angle, IsValid = math, table, Color, Vector, Angle, IsValid
-- format: multiline
local TranquilizatorModels = {
	"models/vj_cofr/aom/pill_bottle.mdl",
	"models/vj_cofr/aom/w_medkit.mdl"
}

function ENT:Initialize()
	if not SERVER then return end
	self:SetModel(table.Random(TranquilizatorModels))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetAngles(AngleRand(-90, 90))
	if self:GetModel() == "models/vj_cofr/aom/w_medkit.mdl" then
		self:SetModelScale(0.75, 0)
	end
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
		self:EmitSound("vj_cofr/aom/pills/pills_drop.wav", math.Clamp(data.Speed / 3, 20, 65), math.random(95, 105))
		self:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity() * .6)
	end
end

local color_green = Color(110, 210, 110)
local color_yellow = Color(210, 210, 110)
function ENT:Use(ply)
	ply:PickupObject(self)
	self:EmitSound("vj_cofr/aom/pills/pills_drop.wav", 70, math.random(95, 105))
	if self.UseCD > CurTime() or self:IsConstrained() then return end
	if SERVER then
		self.UseCD = CurTime() + 1
		if ply:GetAlalnState("class") == "Cannibal" then
			BetterChatPrint(ply, "You don't wan't this.", color_yellow)
			return
		end

		if ply:GetAlalnState("crazyness") >= 10 then
			ply:AddAlalnState("crazyness", -math.random(8, 20))
			BetterChatPrint(ply, "You eated tranquilizator, now you feel better.", color_green)
			ply:EmitSound("vj_cofr/aom/pills/pills_use.wav", 55, math.random(90, 110))
			ply:BetterViewPunch(AngleRand(-8, 8))
			self:Remove()
			ply:AddAlalnState("score", 0.35)
			ply:SetNWInt("DrugUses", ply:GetNWInt("DrugUses", 0) + 1)
		else
			BetterChatPrint(ply, "You already mentally fine.", color_yellow)
		end
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