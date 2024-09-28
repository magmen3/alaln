AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Radio"
ENT.Spawnable = true
ENT.Category = "! Forsakened"
ENT.UseCD = 0
ENT.IconOverride = "editor/env_soundscape"
ENT.Used = false
local math, table, Color, Vector, Angle, IsValid = math, table, Color, Vector, Angle, IsValid
function ENT:Initialize()
	if not SERVER then return end
	self:SetModel(Model("models/vj_props/radio.mdl"))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetAngles(AngleRand(-90, 90))
	self:SetModelScale(0.5, 0)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetContents(CONTENTS_SOLID)
		phys:SetMass(45)
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:PhysicsCollide(data, ent)
	if data.DeltaTime > .1 then
		self:EmitSound("physics/metal/metal_computer_impact_hard" .. math.random(1, 3) .. ".wav", math.Clamp(data.Speed / 3, 20, 65), math.random(95, 105))
		self:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity() * .6)
		if data.Speed >= 1000 then
			self:Remove()
		end
	end
end

local color_green = Color(110, 210, 110)
local color_yellow = Color(210, 210, 110)
function ENT:Use(ply)
	ply:PickupObject(self)
	self:EmitSound("physics/metal/metal_computer_impact_soft" .. math.random(1, 3) .. ".wav", 70, math.random(95, 105))
	if CLIENT or self.UseCD > CurTime() then return end
	if math.random(1, 2) == 2 then
		self:EmitSound("forsakened/radio.mp3", 85, math.random(95, 105))
	else
		self:EmitSound("vj_cofr/aom/player_da/helpyou.wav", 70, math.random(95, 105))
	end
	if not self.Used then
		ply:SetNWString("ChoosenOne", true)
		self.Used = true
	end
	self.UseCD = CurTime() + 85
	SafeRemoveEntityDelayed(self, 85)
end

function ENT:OnTakeDamage(dmg)
	if dmg:GetDamage() >= 40 then
		self:Remove()
	end
end

--local vecup = Vector(0, 0, 15)
function ENT:OnRemove()
	self:StopSound("forsakened/radio.mp3")
	if CLIENT then return end
	self:EmitSound("physics/metal/metal_box_break" .. math.random(1, 2) .. ".wav", 70)
	CreateGibs(self, "metal", 6)
	--[[local gib = ents.Create("env_shooter")
	gib:SetPos(self:GetPos() + vecup)
	gib:SetKeyValue("model", "models/gibs/metal_gib5.mdl")
	gib:SetKeyValue("shootsounds", 2)
	gib:SetKeyValue("m_iGibs", "8")
	gib:SetKeyValue("delay", "0")
	gib:SetKeyValue("m_flVelocity", "200")
	gib:SetKeyValue("m_flVariance", "100")
	gib:SetKeyValue("m_flGibLife", "10")
	gib:SetKeyValue("nogibshadows", "1")
	gib:SetKeyValue("spawnflags", bit.bor(4))
	gib:Spawn()
	gib:Fire("Shoot")]]
end

if CLIENT then
	function ENT:Draw()
		local Closeness = LocalPlayer():GetFOV() * EyePos():Distance(self:GetPos())
		local DetailDraw = Closeness < 250000
		if not DetailDraw then return end
		self:DrawModel()
	end
end