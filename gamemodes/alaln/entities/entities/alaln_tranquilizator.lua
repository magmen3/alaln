AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Tranquilizator"
ENT.Spawnable = true
ENT.Category = "Forsakened"
ENT.UseCD = 0
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

function ENT:Use(ply)
	if CLIENT or self.UseCD > CurTime() then return end
	self.UseCD = CurTime() + 1
	if ply:GetCrazyness() >= 10 then
		ply:AddCrazyness(-math.random(8, 20))
		BetterChatPrint(ply, "You eated tranquilizator, now you feel better.", Color(25, 225, 25))
		ply:EmitSound("vj_cofr/aom/pills/pills_use.wav", 55, math.random(90, 110))
		self:Remove()
		ply:AddScore(0.6)
	else
		BetterChatPrint(ply, "You already mentally fine.", Color(255, 235, 0))
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end