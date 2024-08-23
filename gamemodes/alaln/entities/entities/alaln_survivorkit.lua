AddCSLuaFile()
ENT.Base = "long_use_base"
ENT.PrintName = "Survivor Kit"
ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true
ENT.Category = "! Forsakened"
ENT.TimeToUse = 8
ENT.IconOverride = "editor/obsolete"
ENT.PartialUses = {
	{
		prog = 2,
		func = function(ent) 
			ent:EmitSound("physics/cardboard/cardboard_box_break1.wav")
			ent:GetUser():BetterViewPunch(AngleRand(-10, 10))
		end
	},
	{
		prog = 30,
		func = function(ent) 
			ent:EmitSound("physics/cardboard/cardboard_box_break3.wav")
			ent:GetUser():BetterViewPunch(AngleRand(-10, 10))
		end
	},
	{
		prog = 60,
		func = function(ent) 
			ent:EmitSound("physics/cardboard/cardboard_box_break1.wav")
			ent:GetUser():BetterViewPunch(AngleRand(-10, 10))
		end
	},
	{
		prog = 99,
		func = function(ent) 
			ent:EmitSound("physics/cardboard/cardboard_box_break2.wav")
			ent:GetUser():BetterViewPunch(AngleRand(-16, 16))
		end
	}
}

local math, table, Color, Vector, Angle, IsValid = math, table, Color, Vector, Angle, IsValid
function ENT:Initialize()
	if not SERVER then return end
	self:SetModel(Model("models/weapon_case/briefcase.mdl"))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:SetModelScale(0.9, 0)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetContents(CONTENTS_SOLID)
		phys:SetMass(75)
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:PhysicsCollide(data, ent)
	if data.DeltaTime > .1 then
		self:EmitSound("physics/metal/metal_computer_impact_hard" .. math.random(1, 3) .. ".wav", math.Clamp(data.Speed / 3, 20, 65), math.random(95, 105))
		self:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity() * .6)
	end
end

function ENT:IsProgressUsable()
end

if SERVER then
	-- format: multiline
	local SurvivorLoot = {
		"alaln_food",
		"mann_wep_flaregun",
		"mann_ent_knife"
	}

	local color_green = Color(110, 210, 110)
	function ENT:OnUseFinish(ply)
		for _, item in ipairs(SurvivorLoot) do
			ply:Give(item)
		end
		--self:EmitSound("physics/cardboard/cardboard_box_break1.wav", 75, math.random(95, 105))
		BetterChatPrint(ply, "You've opened a survival kit.", color_green)
		self:Remove()
	end

	function ENT:OnUseStart(ply)
	end

	function ENT:OnUseCancel(ply)
	end
end