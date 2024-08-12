AddCSLuaFile()
ENT.Base = "long_use_base"
ENT.PrintName = "Garbage"
ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true
ENT.Category = "! Forsakened"
ENT.TimeToUse = 6
ENT.UseCD = 0
ENT.Uses = 0
ENT.BlockDrag = true
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
-- format: multiline
local GarbageModels = {
	"models/props_junk/garbage128_composite001a.mdl",
	"models/props_junk/garbage128_composite001b.mdl",
	"models/props_junk/garbage128_composite001c.mdl",
	"models/props_junk/garbage128_composite001d.mdl",
	"models/props_junk/TrashDumpster01a.mdl",
	"models/props_junk/trashcluster01a.mdl"
}

function ENT:Initialize()
	if not SERVER then return end
	self:SetModel(table.Random(GarbageModels))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	if self:GetModel() ~= "models/props_junk/TrashDumpster01a.mdl" then
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	else
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
	end

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetContents(CONTENTS_SOLID)
		phys:SetMass(200)
		phys:EnableMotion(false)
	end
end

function ENT:IsProgressUsable()
	return self.UseCD <= CurTime()
end

if SERVER then
	-- format: multiline
	local GarbageLoot = {
		"alaln_food",
		"alaln_tranquilizator",
		"mann_ent_pm",
		"mann_ent_knife",
		"alaln_strangepills",
		"mann_ent_hammer"
	}

	local upvec = Vector(0, 0, 24)
	local color_green = Color(110, 210, 110)
	function ENT:OnUseFinish(ply)
		if self.UseCD > CurTime() then return end
		self.Uses = self.Uses + 1
		local ent = ents.Create(table.Random(GarbageLoot))
		ent:SetPos(self:GetPos() + upvec)
		ent:SetAngles(AngleRand(-64, 64))
		ent:Spawn()
		--self:EmitSound("physics/cardboard/cardboard_box_break1.wav", 75, math.random(95, 105))
		BetterChatPrint(ply, "You found " .. (ent.PrintName or "something") .. ".", color_green)
		self.UseCD = CurTime() + 10
		if self.Uses >= math.random(3, 6) then self:Remove() end
	end

	function ENT:OnUseStart(ply)
		return self.UseCD <= CurTime()
	end

	function ENT:OnUseCancel(ply)
	end
end