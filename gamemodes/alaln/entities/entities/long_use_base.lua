AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Progress Usable"
ENT.Author = "SweptThrone"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.AutomaticFrameAdvance = true
ENT.ProgPerTick = 0 -- used internally, this should not be changed
ENT.TimeToUse = ENT.TimeToUse or 1.5 -- the user can edit this
ENT.PartialUse = 1 -- used internally, this should not be changed
--ENT.DrawKeyPrompt = true -- deprecated, use self:SetDrawKeyPrompt( b )
--ENT.DrawProgress = true -- deprecated, use self:SetProgress( b )
ENT.PartialUses = {}
--[[ this is an example of a filled-in PartialUses table
	 make sure they're in chronological order, or they may not be called
	 prog is the percentage used the entity is when func should be called
	 ent is the entity, you can use ent:GetUser() for the player using the entity

ENT.PartialUses = {
	{ prog = 1, func = function( ent ) ent:EmitSound( "buttons/blip1.wav", 75, 38 ) end },
	{ prog = 20, func = function( ent ) ent:EmitSound( "buttons/blip1.wav", 75, 50 ) end },
	{ prog = 40, func = function( ent ) ent:EmitSound( "buttons/blip1.wav", 75, 63 ) end },
	{ prog = 60, func = function( ent ) ent:EmitSound( "buttons/blip1.wav", 75, 75 ) end },
	{ prog = 80, func = function( ent ) ent:EmitSound( "buttons/blip1.wav", 75, 88 ) end },
	{ prog = 99, func = function( ent ) ent:EmitSound( "buttons/blip1.wav", 75, 100 ) end }
}
]]
function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "EndTime")
	self:NetworkVar("Entity", 0, "User")
	self:NetworkVar("Bool", 0, "DrawKeyPrompt")
	self:NetworkVar("Bool", 1, "DrawProgress")
	if SERVER then
		self:SetEndTime(0)
		self:SetDrawKeyPrompt(true)
		self:SetDrawProgress(true)
		self.ProgPerTick = 1 / (self.TimeToUse * (1 / FrameTime()) / 100)
	end
end

function ENT:IsProgressUsable()
	return true
end

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/Items/item_item_crate.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then phys:Wake() end
	end

	function ENT:Use(ply, act, typ)
		if IsValid(self:GetUser()) and self:GetUser() ~= ply then return end
		if ply:KeyDownLast(IN_USE) and not IsValid(self:GetUser()) then return end
		self:SetUser(ply)
		if not ply:KeyDownLast(IN_USE) then
			self:SetEndTime(0)
			self:OnUseStart(ply)
			self:SetEndTime(CurTime() + self.TimeToUse)
		end

		if CurTime() >= self:GetEndTime() and IsValid(self:GetUser()) and self:GetEndTime() ~= 0 then
			self:OnUseFinish(self:GetUser())
			self:SetEndTime(0)
			self.PartialUse = 1
			self:SetUser(nil)
		end
	end

	function ENT:OnUseFinish(ply)
		self:EmitSound("items/gift_pickup.wav")
	end

	function ENT:OnUseStart(ply)
		self:EmitSound("items/ammopickup.wav")
	end

	function ENT:OnUseCancel(ply)
		self:EmitSound("buttons/button10.wav")
	end

	function ENT:CancelUse(func)
		func = func or false
		self:SetEndTime(0)
		self.PartialUse = 1
		if func then self:OnUseCancel(self:GetUser()) end
		self:SetUser(nil)
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end

function ENT:Think()
	if IsValid(self:GetUser()) then
		if (self:GetUser():GetUseEntity() ~= self or not self:GetUser():KeyDown(IN_USE)) and self:GetEndTime() ~= 0 then
			self:SetUser(nil)
			self:SetEndTime(0)
			self.PartialUse = 1
			if SERVER then self:OnUseCancel(self:GetUser()) end
		end

		if self.PartialUses[self.PartialUse] ~= nil and CurTime() >= (self:GetEndTime() - self.TimeToUse) + (self.PartialUses[self.PartialUse].prog / 100) * self.TimeToUse and self:GetEndTime() ~= 0 then
			self.PartialUses[self.PartialUse].func(self)
			self.PartialUse = self.PartialUse + 1
		end
	end

	self:NextThink(CurTime())
	return true
end