AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Mann's Entity Base"
ENT.Category = "! Forsakened"
ENT.SWEP = "mann_wep_base"
ENT.Model = Model("models/weapons/w_pist_usp.mdl")
ENT.ImpactSound = "Drywall.ImpactHard"
ENT.SecondSound = ""
ENT.Material = ""
ENT.Scale = 1
local math, Color, AngleRand = math, Color, AngleRand
ENT.Color = Color(200, 200, 200, 255)
-- ENT.Skin		= ""
-- ENT.Sequence	= ""
-- ENT.PhysBox 	= {Vector(0, 0, 0), Vector(0, 0, 0)}
-- ENT.CBounds 	= {Vector(0, 0, 0), Vector(0, 0, 0)}
ENT.Spawnable = false
ENT.EntMass = 35
ENT.AmmoAmt = 13
ENT.AmmoType = "Pistol"
ENT.RSound = "items/ammo_pickup.wav"
ENT.RSoundPitch = math.random(95, 105)
ENT.IconOverride = "editor/ai_goal_standoff"
if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		if self.Bodygroups then
			for i, val in ipairs(self.Bodygroups) do
				self:SetBodygroup(i, val)
			end
		end

		if self.Material then self:SetMaterial(self.Material) end
		if self.Scale then self:SetModelScale(self.Scale, 0) end
		if self.Color then self:SetColor(self.Color) end
		if self.Skin then self:SetSkin(self.Skin) end
		if self.Sequence then self:SetSequence(self.Sequence) end
		if self.PhysBox then self:PhysicsInitBox(self.PhysBox[1], self.PhysBox[2]) end
		if self.CBounds then self:SetCollisionBounds(self.CBounds[1], self.CBounds[2]) end
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(self.CollisionGroup or COLLISION_GROUP_WEAPON)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(false)
		self:SetAngles(AngleRand(-90, 90))
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetContents(CONTENTS_SOLID)
			phys:SetMass(self.Mass or 35)
			phys:Wake()
			phys:EnableMotion(true)
		end
	end

	function ENT:Use(ply)
		self:PickUp(ply)
	end

	function ENT:PhysicsCollide(data, ent)
		if data.DeltaTime > .1 then
			self:EmitSound(self.ImpactSound, math.Clamp(data.Speed / 3, 20, 85), math.random(95, 105))
			if self.SecondSound then sound.Play(self.SecondSound, self:GetPos(), math.Clamp(data.Speed / 3, 20, 85), math.random(95, 105)) end
			self:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity() * .6)
		end
	end

	function ENT:PickUp(ply)
		local SWEP = self.SWEP
		if not SWEP then ply:PickupObject(self) end
		if not self.RoundsInMag then self.RoundsInMag = self.AmmoAmt end
		if ply:HasWeapon(self.SWEP) then
			if self.RoundsInMag > 0 then
				if not self.Melee then
					ply:GiveAmmo(self.RoundsInMag, self.AmmoType, true)
					self:EmitSound(self.RSound, 75, self.RSoundPitch)
					self.RoundsInMag = 0
				end

				ply:PickupObject(self)
				ply:SelectWeapon(SWEP)
			else
				ply:PickupObject(self)
			end
		else
			ply:Give(self.SWEP)
			ply:GetWeapon(self.SWEP):SetClip1(self.RoundsInMag)
			self:Remove()
			ply:SelectWeapon(SWEP)
		end
	end
else
	function ENT:Draw()
		local Closeness = LocalPlayer():GetFOV() * EyePos():Distance(self:GetPos())
		local DetailDraw = Closeness < 250000
		if not DetailDraw then return end
		self:DrawModel()
	end
end