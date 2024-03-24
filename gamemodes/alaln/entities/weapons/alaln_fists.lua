-- Original by WebKnight, modified code by Mannytko
if SERVER then AddCSLuaFile() end
SWEP.Base = "alaln_base"
SWEP.Spawnable = true
SWEP.UseHands = true
SWEP.PrintName = "Berserker Fists"
SWEP.Category = "Forsakened"
SWEP.Purpose = "These are your hands. They're no energy sword, but they still pack a wallop, and can kick someone ass."
SWEP.Instructions = "R to upper/lower fists,\nLMB with uppered fists to swing,\nRMB with uppered fists to block,\nRMB with lowered fists to grab"
SWEP.ViewModel = Model("models/weapons/v_fist.mdl")
SWEP.WorldModel = ""
SWEP.ViewModelPositionOffset = Vector(0, -1, -1)
SWEP.ViewModelAngleOffset = Angle(0, 0, -1)
SWEP.ViewModelFOV = 75
SWEP.BobScale = 2.5
SWEP.SwayScale = 2.5
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.ViewModelFlip = false
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
if CLIENT then SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/alaln_fists") end
SWEP.IconOverride = "halflife/lab1_cmpm3000"
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.BounceWeaponIcon = false
SWEP.AllowViewAttachment = true
SWEP.HitDistance = 70
SWEP.Range = 80
local HitSound = Sound("Flesh.ImpactHard")
function SWEP:Initialize()
	self:SetHoldType("fist")
	self.isInBlockDam = false
	self.Time = 0
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextMeleeAttack")
	self:NetworkVar("Float", 1, "NextIdle")
	self:NetworkVar("Int", 2, "Combo")
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

function SWEP:PrimaryAttack(right)
	if self:GetOwner():IsSprinting() then return end
	local currentAnimFSF = self:GetSequenceName(self:GetOwner():GetViewModel():GetSequence())
	if currentAnimFSF == "inspect" or self.fistsOut == false then
		self.fistsOut = true
		self:SetHoldType("fist")
		local vm = self:GetOwner():GetViewModel()
		vm:SetWeaponModel("models/weapons/v_fist.mdl", self)
		vm:SendViewModelMatchingSequence(vm:LookupSequence("draw"))
		self:EmitSound("weapons/wbk/PF_Osm_3.wav")
		self:GetOwner():ViewPunch(Angle(-4.4, 0, 1.5))
		self:SetNextPrimaryFire(CurTime() + 0.3)
		self:SetNextSecondaryFire(CurTime() + 0.3)
		self:UpdateNextIdle()
	else
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
		local currentPunchAnim = self:GetSequenceName(self:GetOwner():GetViewModel():GetSequence())
		local anim = "punch_miss"
		if currentPunchAnim == "punch_miss" then anim = "punch_hit" end
		if currentPunchAnim == "punch_hit" or currentPunchAnim == "draw" or not self:GetOwner():OnGround() then anim = "punch_hard" end
		local vm = self:GetOwner():GetViewModel()
		vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
		if anim == "punch_hard" then
			self:EmitSound("weapons/wbk/PF_Swing_dif_" .. math.random(1, 3) .. ".wav")
			self:GetOwner():ViewPunch(Angle(-9, -11, 1))
		else
			self:EmitSound("weapons/wbk/PF_Attack_" .. math.random(1, 3) .. ".wav")
		end

		self:UpdateNextIdle()
		self:SetNextMeleeAttack(CurTime() + 0.14)
		self:GetOwner():ViewPunch(Angle(0, -8.5, -2.5))
		self:SetNextPrimaryFire(CurTime() + 0.6)
		self:SetNextSecondaryFire(CurTime() + 0.6)
	end
end

function SWEP:Reload()
	if self:GetOwner():IsSprinting() then return end
	if self.canPutfistsOut == false then return end
	self.canPutfistsOut = false
	timer.Simple(0.6, function()
		if not self:IsValid() then return end
		self.canPutfistsOut = true
	end)

	if self.fistsOut == false then
		self.fistsOut = true
		self:SetHoldType("fist")
		local vm = self:GetOwner():GetViewModel()
		vm:SetWeaponModel("models/weapons/v_fist.mdl", self)
		vm:SendViewModelMatchingSequence(vm:LookupSequence("draw"))
		self:EmitSound("weapons/wbk/PF_Osm_3.wav")
		self:GetOwner():ViewPunch(Angle(-2, 0, 1))
		self:SetNextPrimaryFire(CurTime() + 0.5)
		self:SetNextSecondaryFire(CurTime() + vm:SequenceDuration())
		self:UpdateNextIdle()
	else
		local vm = self:GetOwner():GetViewModel()
		vm:SetWeaponModel("models/weapons/c_arms.mdl", self)
		vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_holster"))
		self.fistsOut = false
		self:SetHoldType("normal")
		self:GetOwner():ViewPunch(Angle(2, 0, 1))
		self:SetNextPrimaryFire(CurTime() + 0.5)
		self:SetNextSecondaryFire(CurTime() + 0.3)
		self:EmitSound("weapons/wbk/PF_Osm_2.wav")
	end
end

local phys_pushscale = GetConVar("phys_pushscale")
function SWEP:DealDamage()
	local anim = self:GetSequenceName(self:GetOwner():GetViewModel():GetSequence())
	self:GetOwner():LagCompensation(true)
	local tr = util.TraceLine({
		start = self:GetOwner():GetShootPos(),
		endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * self.HitDistance,
		filter = self:GetOwner(),
		mask = MASK_SHOT_HULL
	})

	if not IsValid(tr.Entity) then
		tr = util.TraceHull({
			start = self:GetOwner():GetShootPos(),
			endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * self.HitDistance,
			filter = self:GetOwner(),
			mins = Vector(-10, -10, -8),
			maxs = Vector(10, 10, 8),
			mask = MASK_SHOT_HULL
		})
	end

	-- We need the second part for single player because SWEP:Think is ran shared in SP
	if tr.Hit and not (game.SinglePlayer() and CLIENT) then
		if not IsValid(tr.Entity) then
			self:SetNextPrimaryFire(CurTime() + 1.3)
			self:SetNextSecondaryFire(CurTime() + 1.3)
			timer.Simple(0.08, function()
				local vm = self:GetOwner():GetViewModel()
				vm:SendViewModelMatchingSequence(vm:LookupSequence("draw"))
				self:EmitSound(HitSound)
				self:SetNextPrimaryFire(CurTime() + 0.6)
				self:SetNextSecondaryFire(CurTime() + 0.6)
				self:UpdateNextIdle()
			end)
		else
			if anim == "punch_hard" then
				self:EmitSound("weapons/wbk/PF_Crit_" .. math.random(1, 2) .. ".wav")
			else
				self:EmitSound("weapons/wbk/PF_Hit_Humanoid_" .. math.random(2, 5) .. ".wav")
			end
		end
	end

	local hit = false
	local scale = phys_pushscale:GetFloat()
	if SERVER and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:Health() > 0) then
		local dmginfo = DamageInfo()
		local attacker = self:GetOwner()
		if not IsValid(attacker) then attacker = self end
		dmginfo:SetAttacker(attacker)
		dmginfo:SetInflictor(self)
		dmginfo:SetDamage(math.random(25, 55))
		if anim == "punch_hit" then
			dmginfo:SetDamageForce(self:GetOwner():GetRight() * 4912 * scale + self:GetOwner():GetForward() * 9998 * scale) -- Yes we need those specific numbers
		elseif anim == "punch_miss" then
			dmginfo:SetDamageForce(self:GetOwner():GetRight() * -4912 * scale + self:GetOwner():GetForward() * 9989 * scale)
		elseif anim == "punch_hard" then
			dmginfo:SetDamageForce(self:GetOwner():GetUp() * 5158 * scale + self:GetOwner():GetForward() * 10012 * scale)
			dmginfo:SetDamage(math.random(12, 18))
			timer.Simple(0.1, function() self:GetOwner():ViewPunch(Angle(12.5, 0, 8.5)) end)
		end

		SuppressHostEvents(NULL) -- Let the breakable gibs spawn in multiplayer on client
		tr.Entity:TakeDamageInfo(dmginfo)
		SuppressHostEvents(self:GetOwner())
		hit = true
	end

	if IsValid(tr.Entity) then
		local phys = tr.Entity:GetPhysicsObject()
		if IsValid(phys) then phys:ApplyForceOffset(self:GetOwner():GetAimVector() * 80 * phys:GetMass() * scale, tr.HitPos) end
	end

	if SERVER then
		if hit and anim ~= "punch_hard" then
			self:SetCombo(self:GetCombo() + 1)
		else
			self:SetCombo(0)
		end
	end

	self:GetOwner():LagCompensation(false)
end

function SWEP:OnDrop()
	self:Remove() -- You can't drop fists
end

function SWEP:Deploy()
	self.fistsOut = false
	self.canPutfistsOut = true
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
	self:SetNextMeleeAttack(0)
	return true
end

function SWEP:SecondaryAttack()
	if self.fistsOut == true then
		local owner = self:GetOwner()
		local vm = owner:GetViewModel()
		local isInBlockAnim = self:GetSequenceName(vm:GetSequence())
		if owner:OnGround() and isInBlockAnim ~= "WbkDefendHimself" then
			vm:SetWeaponModel("models/weapons/c_arms_wbk_unarmed.mdl", self)
			vm:SendViewModelMatchingSequence(vm:LookupSequence("WbkDefendHimself"))
			self:SetHoldType("camera")
			self.isInBlockDam = true
			self:GetOwner():ViewPunch(Angle(-1.4, 0, 1.5))
			timer.Simple(0.2, function()
				if not self:IsValid() then return end
				self:GetOwner():ViewPunch(Angle(1.4, 0, 1.5))
			end)

			timer.Simple(0.4, function()
				if not self:IsValid() then return end
				self:GetOwner():ViewPunch(Angle(-1.4, 0, 1.5))
			end)

			timer.Simple(0.5, function()
				if not self:IsValid() then return end
				self:GetOwner():ViewPunch(Angle(1.4, 0, 1.5))
			end)

			timer.Simple(0.8, function()
				if not self:IsValid() then return end
				self:GetOwner():ViewPunch(Angle(-1.4, 0, 1.5))
			end)

			timer.Simple(1, function()
				if not self:IsValid() then return end
				self:GetOwner():ViewPunch(Angle(1.4, 0, 1.5))
			end)

			timer.Simple(1.35, function()
				if not self:IsValid() then return end
				self:SetHoldType("fist")
				if vm:GetModel() == "models/weapons/c_arms_wbk_unarmed.mdl" then -- fix for weird bug when start sprinting with block
					vm:SetWeaponModel("models/weapons/v_fist.mdl", self)
					vm:SendViewModelMatchingSequence(vm:LookupSequence("draw"))
				end

				self.isInBlockDam = false
			end)

			self:UpdateNextIdle()
		end

		self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration() + 0.1)
		self:SetNextSecondaryFire(CurTime() + vm:SequenceDuration() + 0.1)
	else
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
					OrigAng = HitEnt:GetAngles(),
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
end

function SWEP:OnDrop()
	self:Remove()
end

if CLIENT then
	local color_red = Color(180, 0, 0)
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
		surface.SetDrawColor(Color(hitEnt.r, hitEnt.g, hitEnt.b, alpha))
		draw.NoTexture()
		Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, math.min(10, 6 / frac), 3)
	end
end

function SWEP:Think()
	local owner = self:GetOwner()
	local vm = owner:GetViewModel()
	local idletime = self:GetNextIdle()
	local selftable = self:GetTable()
	if selftable.Drag and (not owner:KeyDown(IN_ATTACK2) or not IsValid(selftable.Drag.Entity)) then
		local ent = self.Drag.Entity
		if IsValid(ent) then timer.Create("RemoveOwner_" .. ent:EntIndex(), 30, 1, function() ent:SetNWEntity("PlayerCarrying", nil) end) end
		selftable.Drag = nil
	end

	if selftable.Drag and owner:GetPos():DistToSqr(selftable.Drag.Entity:GetPos()) > 9500 then selftable.Drag = nil end
	if self.Drag then
		self:SetHoldType("magic")
	elseif self.fistsOut == true then
		if self.isInBlockDam == false then
			self:SetHoldType("fist")
		else
			self:SetHoldType("camera")
		end
	else
		self:SetHoldType("normal")
	end

	local isCrouchAnim = self:GetSequenceName(vm:GetSequence())
	if owner:Crouching() and owner:OnGround() and isCrouchAnim ~= "WbkCrouch" and isCrouchAnim ~= "WbkDefendHimself" and not self.fistsOut then
		vm:SetWeaponModel("models/weapons/c_arms_wbk_unarmed.mdl", self)
		vm:SendViewModelMatchingSequence(vm:LookupSequence("WbkCrouch"))
	else
		if self.fistsOut and not self.isInBlockDam then
			if vm:GetModel() == "models/weapons/c_arms_wbk_unarmed.mdl" then
				vm:SetWeaponModel("models/weapons/v_fist.mdl", self)
				vm:SendViewModelMatchingSequence(vm:LookupSequence("draw"))
			end
		end
	end

	if owner:KeyPressed(IN_JUMP) and owner:WaterLevel() < 2 and self.canWbkUseJumpAnim == true and self.fistsOut == false then
		self.canWbkUseJumpAnim = false
		if owner:IsSprinting() then
			vm:SendViewModelMatchingSequence(vm:LookupSequence("WbkIdle_JumpRun"))
		else
			vm:SendViewModelMatchingSequence(vm:LookupSequence("WbkIdle_JumpStand"))
		end

		self:UpdateNextIdle()
	end

	if owner:OnGround() and self.canWbkUseJumpAnim == false then self.canWbkUseJumpAnim = true end
	if not owner:OnGround() and owner:WaterLevel() == 0 then
		if self.fistsOut == false and idletime > 0 and CurTime() > idletime then
			vm:SendViewModelMatchingSequence(vm:LookupSequence("WbKInAir"))
			self:UpdateNextIdle()
		end
	end

	if owner:IsSprinting() and self.fistsOut == true then
		self.fistsOut = false
		self:SetHoldType("normal")
		vm:SetWeaponModel("models/weapons/c_arms.mdl", self)
		vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_holster"))
		self:EmitSound("weapons/wbk/PF_Osm_2.wav")
	end

	if self.fistsOut == false and idletime > 0 and CurTime() > idletime then
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
				if owner:IsSprinting() then
					vm:SendViewModelMatchingSequence(vm:LookupSequence("WbKSprint"))
					self:UpdateNextIdle()
				else
					vm:SendViewModelMatchingSequence(vm:LookupSequence("WbkIdle_Lowered"))
					self:UpdateNextIdle()
				end
			end
		end
	end

	if idletime > 0 and CurTime() > idletime and self.fistsOut == true then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("idle" .. math.random(1, 2)))
		self:UpdateNextIdle()
	end

	local meleetime = self:GetNextMeleeAttack()
	if meleetime > 0 and CurTime() > meleetime then
		self:DealDamage()
		self:SetNextMeleeAttack(0)
	end

	if SERVER and CurTime() > self:GetNextPrimaryFire() + 0.1 then self:SetCombo(0) end
end