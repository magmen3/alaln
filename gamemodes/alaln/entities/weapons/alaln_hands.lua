-- Original by WebKnight, modified code by Mannytko
AddCSLuaFile()
SWEP.Base = "alaln_base"
SWEP.Spawnable = true
SWEP.UseHands = true
SWEP.PrintName = "Hands"
SWEP.Category = "! Forsakened"
SWEP.Purpose = "These are your hands, you can grab and drag objects with them, but you can't fight or defend yourself with them."
SWEP.Instructions = "LMB to grab,\nRMB to grab with second hand when grabbing with LMB."
SWEP.ViewModel = Model("models/weapons/c_arms_wbk_unarmed.mdl")
SWEP.WorldModel = ""
SWEP.DrawWorldModel = false
SWEP.ViewModelPositionOffset = Vector(-3, 0, -1)
SWEP.ViewModelAngleOffset = Angle(0, 2, -1)
SWEP.ViewModelFOV = 120
SWEP.BobScale = -2
SWEP.SwayScale = -2
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
if CLIENT then SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/alaln_fists") end
SWEP.IconOverride = "editor/obsolete"
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.Droppable = false
SWEP.Range = 90
SWEP.Drag = false
--!! TODO: Переделать систему подбирания потому что это кал с нексторена
function SWEP:Initialize()
	self.Time = 0
	self:SetHoldType("normal")
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 1, "NextIdle")
end

function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
	local owner = self:GetOwner()
	if not IsValid(owner) then return pos, ang end
	local forward, right, up = self.ViewModelPositionOffset.x, self.ViewModelPositionOffset.y, self.ViewModelPositionOffset.z
	local angs = owner:EyeAngles()
	--ang.pitch = -ang.pitch
	ang:RotateAroundAxis(ang:Forward(), self.ViewModelAngleOffset.pitch)
	ang:RotateAroundAxis(ang:Right(), self.ViewModelAngleOffset.roll)
	ang:RotateAroundAxis(ang:Up(), self.ViewModelAngleOffset.yaw)
	return pos + angs:Forward() * forward + angs:Right() * right + angs:Up() * up, ang
end

function SWEP:UpdateNextIdle()
	local vm = self:GetOwner():GetViewModel()
	self:SetNextIdle(CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate())
end

function SWEP:Sprinting()
	self:SetHoldType("normal")
end

function SWEP:Reload()
	return false
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:Deploy()
	self.canWbkUseJumpAnim = true
	self:SetHoldType("normal")
	local vm = self:GetOwner():GetViewModel()
	vm:SetWeaponModel("models/weapons/c_arms.mdl", self)
	self:SetNextPrimaryFire(CurTime() + 0.3)
	self:SetNextSecondaryFire(CurTime() + 0.3)
	self:UpdateNextIdle()
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	local Pos = owner:GetShootPos()
	local Aim = owner:GetAimVector()
	local Tr = util.TraceLine{
		start = Pos,
		endpos = Pos + Aim * self.Range,
		filter = player.GetAll(),
	}

	local HitEnt = Tr.Entity
	if self.Drag then
		HitEnt = self.Drag.Entity
	else
		if not IsValid(HitEnt) or HitEnt:GetMoveType() ~= MOVETYPE_VPHYSICS or HitEnt:IsVehicle() or HitEnt.BlockDrag or IsValid(HitEnt:GetParent() or blacklist[HitEnt:GetClass()]) then return end
		if not self.Drag then
			self.Drag = {
				OffPos = HitEnt:WorldToLocal(Tr.HitPos),
				Entity = HitEnt,
				Fraction = Tr.Fraction,
				OrigAng = HitEnt:GetAngles()
			}

			if HitEnt:GetClass() == "prop_ragdoll" then
				local closest = 1000000000000000
				local physobj = HitEnt:GetPhysicsObjectNum(0)
				for i = 0, HitEnt:GetPhysicsObjectCount() - 1 do -- "ragdoll" being a ragdoll entity
					local phys = HitEnt:GetPhysicsObjectNum(i)
					local dist = phys:GetPos():DistToSqr(Tr.HitPos)
					if dist < closest then
						closest = dist
						physobj = phys
					end
				end

				if IsValid(physobj) then
					self.Drag.physobj = physobj
					self.Drag.OrigAng = physobj:GetAngles()
					self.Drag.OffPos = physobj:WorldToLocal(Tr.HitPos)
				end
			end

			if not IsValid(HitEnt:GetNWEntity("PlayerCarrying")) then
				HitEnt:SetNWEntity("PlayerCarrying", owner)
				timer.Remove("RemoveOwner_" .. HitEnt:EntIndex())
			end

			if HitEnt:GetNWEntity("PlayerCarrying") == owner then timer.Remove("RemoveOwner_" .. HitEnt:EntIndex()) end
			--if SERVER then owner:EmitSound("Flesh.ImpactSoft") end
		end
	end

	if CLIENT or not IsValid(HitEnt) then return end
	local Phys = HitEnt:GetPhysicsObject()
	if self.Drag.physobj then Phys = self.Drag.physobj end
	if IsValid(Phys) then
		local Pos2 = Pos + Aim * self.Range * self.Drag.Fraction
		local OffPos = Phys:LocalToWorld(self.Drag.OffPos)
		local Dif = Pos2 - OffPos
		local Nom
		local addanglevelocity
		if HitEnt:GetClass() == "prop_ragdoll" then
			Nom = (Dif:GetNormal() * math.min(1, Dif:Length() / 100) * 500) * Phys:GetMass()
			addanglevelocity = -Phys:GetAngleVelocity()
		else
			Nom = (Dif:GetNormal() * math.min(1, Dif:Length() / 100) * 500 - Phys:GetVelocity()) * Phys:GetMass()
			addanglevelocity = -Phys:GetAngleVelocity() / 4
		end

		Phys:ApplyForceOffset(Nom, OffPos)
		Phys:AddAngleVelocity(addanglevelocity)
	end
end

function SWEP:SecondaryAttack()
	local owner = self:GetOwner()
	if owner:KeyDown(IN_ATTACK) then self:PrimaryAttack() end
end

if CLIENT then
	local color_red = Color(185, 15, 15)
	function SWEP:DrawHUD()
		local owner = self:GetOwner()
		local tr = {}
		tr.start = owner:GetShootPos()
		local dir = Vector(1, 0, 0)
		dir:Rotate(owner:EyeAngles())
		tr.endpos = tr.start + dir * 500
		tr.filter = owner
		local traceResult = util.TraceLine(tr)
		local hitEnt = IsValid(traceResult.Entity) and traceResult.Entity:IsNPC() and color_red or color_white
		local frac = traceResult.Fraction
		local alpha = -(frac * 255 - 255) / 2
		surface.SetDrawColor(hitEnt.r, hitEnt.g, hitEnt.b, alpha)
		draw.NoTexture()
		Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, math.min(10, 6 / frac), 3)
	end
end

function SWEP:Think()
	local owner = self:GetOwner()
	local vm = owner:GetViewModel()
	local idletime = self:GetNextIdle()
	local selftable = self:GetTable()
	if selftable.Drag and (not owner:KeyDown(IN_ATTACK) or not IsValid(selftable.Drag.Entity)) then
		local ent = self.Drag.Entity
		if IsValid(ent) then
			timer.Create("RemoveOwner_" .. ent:EntIndex(), 30, 1, function()
				if not IsValid(ent) then return end
				ent:SetNWEntity("PlayerCarrying", nil)
			end)
		end

		selftable.Drag = nil
	end

	if selftable.Drag and owner:GetPos():DistToSqr(selftable.Drag.Entity:GetPos()) > 9500 then selftable.Drag = nil end
	if self.Drag and owner:KeyDown(IN_ATTACK2) then
		self:SetHoldType("duel")
	elseif self.Drag and not owner:KeyDown(IN_ATTACK2) then
		self:SetHoldType("magic")
	else
		self:SetHoldType("normal")
	end

	if owner:KeyPressed(IN_JUMP) and owner:WaterLevel() < 2 and self.canWbkUseJumpAnim == true then
		self.canWbkUseJumpAnim = false
		if owner:IsSprinting() and owner:KeyDown(IN_FORWARD) then
			vm:SendViewModelMatchingSequence(vm:LookupSequence("WbkIdle_JumpRun"))
		else
			vm:SendViewModelMatchingSequence(vm:LookupSequence("WbkIdle_JumpStand"))
		end

		self:UpdateNextIdle()
	end

	if owner:OnGround() and self.canWbkUseJumpAnim == false then self.canWbkUseJumpAnim = true end
	if not owner:OnGround() and owner:GetMoveType() ~= MOVETYPE_LADDER and owner:WaterLevel() == 0 and idletime > 0 and CurTime() > idletime then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("WbKInAir"))
		self:UpdateNextIdle()
	end

	if idletime > 0 and CurTime() > idletime then
		if owner:WaterLevel() >= 2 then
			if owner:KeyDown(IN_FORWARD) or owner:IsSprinting() then
				vm:SendViewModelMatchingSequence(vm:LookupSequence("WbKInSwim"))
				self:UpdateNextIdle()
			else
				vm:SendViewModelMatchingSequence(vm:LookupSequence("WbkIdle_Lowered"))
				self:UpdateNextIdle()
			end
		else
			if owner:OnGround() then
				if owner:IsSprinting() and owner:KeyDown(IN_FORWARD) then
					vm:SendViewModelMatchingSequence(vm:LookupSequence("WbKSprint"))
					self:UpdateNextIdle()
				else
					vm:SendViewModelMatchingSequence(vm:LookupSequence("WbkIdle_Lowered"))
					self:UpdateNextIdle()
				end
			end
		end
	end
end