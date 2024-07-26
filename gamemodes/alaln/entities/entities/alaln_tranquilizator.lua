AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Tranquilizator"
ENT.Spawnable = true
ENT.Category = "Forsakened"
ENT.UseCD = 0
local math, table, Color = math, table, Color
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

local color_green = Color(25, 225, 25)
local color_yellow = Color(255, 235, 0)
function ENT:Use(ply)
	if CLIENT or self.UseCD > CurTime() then return end
	self.UseCD = CurTime() + 1
	if ply:GetAlalnState("class") == "Cannibal" then
		BetterChatPrint(ply, "You don't wan't this.", color_yellow)
		return
	end

	if ply:GetAlalnState("crazyness") >= 10 then
		ply:AddAlalnState("crazyness", -math.random(8, 20))
		BetterChatPrint(ply, "You eated tranquilizator, now you feel better.", color_green)
		ply:EmitSound("vj_cofr/aom/pills/pills_use.wav", 55, math.random(90, 110))
		self:Remove()
		ply:AddAlalnState("score", 0.35)
	else
		BetterChatPrint(ply, "You already mentally fine.", color_yellow)
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end