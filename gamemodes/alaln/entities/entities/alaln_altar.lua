AddCSLuaFile()
ENT.Base = "long_use_base"
ENT.PrintName = "Altar"
ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true
ENT.Category = "! Forsakened"
ENT.TimeToUse = 10
ENT.UseCD = 0
ENT.Uses = 0
ENT.BlockDrag = true
ENT.IconOverride = "editor/info_landmark"
ENT.PartialUses = {
	{
		prog = 5,
		func = function(ent)
			ent:EmitSound("inbs/cult/pleased1.wav")
			ent:GetUser():BetterViewPunch(AngleRand(-14, 14))
		end
	},
	{
		prog = 45,
		func = function(ent)
			ent:EmitSound("inbs/cult/pleased2.wav")
			ent:GetUser():BetterViewPunch(AngleRand(-14, 14))
		end
	},
	{
		prog = 70,
		func = function(ent)
			ent:EmitSound("inbs/cult/pleased3.wav")
			ent:GetUser():BetterViewPunch(AngleRand(-14, 14))
		end
	},
	{
		prog = 99,
		func = function(ent)
			ent:EmitSound("inbs/cult/convert2.wav")
			ent:GetUser():BetterViewPunch(AngleRand(-18, 18))
		end
	}
}

local math, table, Color, Vector, Angle, IsValid = math, table, Color, Vector, Angle, IsValid

-- local vecdown = Vector(0, 0, 15) --28
function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * -15
	local ent = ents.Create(self.ClassName)
	ent:SetAngles(Angle(0, math.random(-360, 360), 0))
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	if not SERVER then return end
	self:SetModel(Model("models/forsakened/altar/altarofcovenants.mdl"))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetSkin(1)
	self:SetBodygroup(2, 1)
	--self:SetPos(self:GetPos() - vecdown)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetContents(CONTENTS_SOLID)
		phys:SetMass(200)
		phys:EnableMotion(false)
	end
end

function ENT:PhysicsCollide(data, ent)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
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

	local upvec = Vector(0, 0, 72)
	local color_green = Color(110, 210, 110)
	local color_yellow = Color(210, 210, 110)
	function ENT:OnUseFinish(ply)
		if self.UseCD > CurTime() then return end
		if ply:GetAlalnState("score") < 100 then
			self:EmitSound(Sound("inbs/cult/failure.wav"))
			BetterChatPrint(ply, "Need more score.", color_yellow)
			return false
		end

		self.Uses = self.Uses + 1
		local ent = ents.Create(table.Random(GarbageLoot))
		ent:SetPos(self:GetPos() + upvec)
		ent:SetAngles(AngleRand(-64, 64))
		ent:Spawn()
		BetterChatPrint(ply, "An unknown force has given you " .. (ent.PrintName or "something") .. ".", color_green)
		self.UseCD = CurTime() + self.UseCD + 10
		self:SetBodygroup(1, 1)
		if self.Uses > 1 then self:SetBodygroup(3, 1) end
		if self.Uses >= math.random(3, 6) then self:SetBodygroup(4, 1) end
	end

	function ENT:OnUseStart(ply)
		return self.UseCD <= CurTime()
	end

	function ENT:OnUseCancel(ply)
		if self.UseCD > CurTime() then return end
		self:EmitSound(Sound("inbs/cult/failure.wav"))
		self.UseCD = CurTime() + self.UseCD + 2
	end
end