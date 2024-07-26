AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Phantom Loot"
ENT.Spawnable = true
ENT.Category = "Forsakened"
local math, table, Color = math, table, Color
-- format: multiline
local FoodModels = {
	"models/w_models/weapons/w_smg_a.mdl",
	"models/weapons/tfa_nmrih/w_fa_glock17.mdl",
	"models/weapons/tfa_nmrih/w_tool_barricade.mdl",
	"models/weapons/tfa_doi/w_m1911.mdl",
	"models/vj_cofr/aom/w_medkit.mdl",
	"models/weapons/tfa_nmrih/w_fa_sw686.mdl",
	"models/weapons/tfa_nmrih/w_me_hatchet.mdl",
	"models/weapons/w_km2000_knife.mdl",
	"models/props_junk/garbage_metalcan001a.mdl",
	"models/props_junk/garbage_metalcan002a.mdl",
	"models/props_junk/PopCan01a.mdl",
	"models/props_junk/garbage128_composite001a.mdl",
	"models/props_junk/garbage128_composite001b.mdl",
	"models/props_junk/garbage128_composite001c.mdl",
	"models/props_junk/garbage128_composite001d.mdl"
}

local clr_distort = Color(30, 0, 0)
function ENT:Initialize()
	if not SERVER then return end
	self:SetModel(table.Random(FoodModels))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetAngles(AngleRand(-90, 90))
	self:SetRenderFX(15)
	self:SetRenderMode(RENDERMODE_GLOW)
	self:SetColor(clr_distort)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetContents(CONTENTS_SOLID)
		phys:SetMass(1)
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:PhysicsCollide(data, ent)
	if data.DeltaTime > .1 then self:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity() * 0) end
end

local color_red = Color(165, 0, 0)
local randomphrase = {"Wait.. What was that?", "It's... Not real?", "Am i tripping?", "Huh...", "What the..."}
function ENT:Use(ply)
	if CLIENT then return end
	ply:EmitSound("ambient/levels/citadel/strange_talk" .. math.random(1, 11) .. ".wav")
	if ply:GetAlalnState("crazyness") <= 20 then
		ply:AddAlalnState("crazyness", math.random(4, 16))
		BetterChatPrint(ply, table.Random(randomphrase), color_red)
		ply:AddAlalnState("score", 0.2)
		self:Remove()
	else
		ply:TakeDamage(math.random(2, 5), ply, ply)
		BetterChatPrint(ply, "It's not real.", color_red)
		ply:AddAlalnState("crazyness", -math.random(3, 6))
		self:Remove()
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end