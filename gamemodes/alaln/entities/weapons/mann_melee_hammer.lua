AddCSLuaFile()
SWEP.Base = "mann_melee_base"
SWEP.PrintName = "Claw Hammer"
SWEP.Purpose = "An old steel claw hammer, formerly someone's construction tool, is now your survival tool."
SWEP.Instructions = "LMB to attack,\nRMB to nail an object/bolt a door,\nYou can only nail a item that is closely overlapping another surface."
SWEP.Category = "! Forsakened"
SWEP.Spawnable = true
SWEP.ViewModel = Model("models/weapons/tfa_nmrih/v_tool_barricade.mdl")
SWEP.WorldModel = Model("models/weapons/tfa_nmrih/w_tool_barricade.mdl")
SWEP.ViewModelFOV = 120
SWEP.ViewModelPositionOffset = Vector(-12, -1, 1)
SWEP.ViewModelAngleOffset = Angle(-10, 0, -5)
SWEP.UseHands = true
SWEP.HoldType = "alaln_melee"
SWEP.MeleeHolsterSlot = 1
SWEP.SoundCL = false
SWEP.Primary.Sound = Sound("weapons/slam/throw.wav")
SWEP.Primary.Damage = 80
SWEP.Primary.Delay = 1
SWEP.Primary.Force = 400
SWEP.PrimaryAnim = "attack_quick_2"
SWEP.PrimaryAnimDelay = 0.5
SWEP.PrimaryAnimRate = 1
SWEP.PrimaryPunch = Angle(0, 15, 0)
SWEP.AttPrimaryPunch = Angle(0, -20, 0)
SWEP.PrimaryTimer = 0.1
SWEP.Secondary.Sound = Sound("snd_jack_hmcd_hammerhit.wav")
SWEP.Secondary.Damage = 120
SWEP.Secondary.Delay = 0.9
SWEP.Secondary.Force = 400
SWEP.Secondary.Automatic = true
SWEP.AllowSecondAttack = false
SWEP.SecondaryAnim = "attack_quick_1"
SWEP.SecondaryAnimDelay = 0.5
SWEP.SecondaryAnimRate = 1.3
SWEP.SecondaryPunch = Angle(3, 0, 0)
SWEP.DmgType = DMG_CLUB
SWEP.AllowBackStab = true
SWEP.BackStabMul = 2
SWEP.SlashSound = Sound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav")
SWEP.StabSound = Sound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav")
SWEP.HitWorldSound = Sound("physics/metal/metal_solid_impact_hard" .. math.random(4, 5) .. ".wav")
SWEP.ReachDistance = 70
SWEP.VModelForSelector = false
SWEP.IdleAnim = "idle"
SWEP.DeployAnim = "draw"
SWEP.DeploySound = Sound("player/weapon_draw_0" .. math.random(1, 5) .. ".wav")
SWEP.PitchMul = 1.05
-- SWEP.WMPos 				= Vector(3.5, -1.5, -2.5)
-- SWEP.WMAng 				= Angle(0, -60, 180)
SWEP.ENT = "mann_ent_hammer"
SWEP.Droppable = true
SWEP.IconOverride = "editor/ai_goal_police"
game.AddDecal("alaln-naildecal", "decals/alaln_naildecal")
SWEP.MaxHP = 60
SWEP.HP = 60
do
	local function BindObjects(ent1, pos1, ent2, pos2, power)
		local Strength, CheckEnt, OtherEnt = 1, ent1, ent2
		if CheckEnt:IsWorld() then
			CheckEnt = ent2
			OtherEnt = ent1
		end

		if not power then power = 1 end
		for key, tab in pairs(constraint.FindConstraints(CheckEnt, "Rope")) do
			if (tab.Ent1 == OtherEnt) or (tab.Ent2 == OtherEnt) then Strength = Strength + 1 end
		end

		constraint.Rope(ent1, ent2, 0, 0, ent1:WorldToLocal(pos1), ent2:WorldToLocal(pos2), (pos1 - pos2):Length(), -.1, (500 + Strength * 100) * power, 0, "", false)
		return Strength
	end

	-- bind items/lock doors
	local color_yellow = Color(210, 210, 110)
	function SWEP:SecondaryAttack()
		local owner = self:GetOwner()
		if not IsFirstTimePredicted() then
			self:DoBFSAnimation(self.SecondaryAnim)
			owner:GetViewModel():SetPlaybackRate(self.SecondaryAnimRate or 1)
			return
		end

		if SERVER then
			local ShPos, AimVec = owner:GetShootPos(), owner:GetAimVector()
			local Tr = util.QuickTrace(ShPos, AimVec * 65, {owner})
			if self:CanNail(Tr) then
				local NewTr, NewEnt = util.QuickTrace(Tr.HitPos, AimVec * 10, {owner, Tr.Entity}), nil
				if self:CanNail(NewTr) then
					if not NewTr.HitSky then NewEnt = NewTr.Entity end
					if NewEnt and (IsValid(NewEnt) or NewEnt:IsWorld()) and not (NewEnt:IsPlayer() or NewEnt:IsNPC() or (NewEnt == Tr.Entity)) then
						if Tr.Entity:IsDoor() then
							if not IsFirstTimePredicted() then
								self:DoBFSAnimation(self.SecondaryAnim)
								owner:GetViewModel():SetPlaybackRate(self.SecondaryAnimRate or 1)
								return
							end

							Tr.Entity:Fire("lock", "", 0)
							self:TakePrimaryAmmo(3)
							owner:EmitSound(self.Secondary.Sound, 75, math.random(95, 105))
							self:SprayDecals()
							BetterChatPrint(owner, "Door Sealed", color_yellow)
							owner:BetterViewPunch(self.SecondaryPunch)
							self:DoBFSAnimation(self.SecondaryAnim)
							owner:GetViewModel():SetPlaybackRate(self.SecondaryAnimRate or 1)
							owner:SetAnimation(PLAYER_ATTACK1)
						else
							local Strength = BindObjects(Tr.Entity, Tr.HitPos, NewEnt, NewTr.HitPos, 24)
							owner:EmitSound(self.Secondary.Sound, 75, math.random(95, 105))
							util.Decal("alaln-naildecal", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
							BetterChatPrint(owner, "Bond strength: " .. tostring(Strength), color_yellow)
							self:DoBFSAnimation(self.SecondaryAnim)
							owner:BetterViewPunch(self.SecondaryPunch)
							owner:GetViewModel():SetPlaybackRate(self.SecondaryAnimRate or 1)
						end

						self.HP = self.HP - (self.Primary.Damage / 35)
						self:SetNextSecondaryFire(CurTime() + 1.5)
						self:SetNextPrimaryFire(CurTime() + 1.5)
					end
				end
			end
		end
	end
end

function SWEP:CanNail(Tr)
	return Tr.Hit and Tr.Entity and (IsValid(Tr.Entity) or Tr.Entity:IsWorld()) and not (Tr.Entity:IsPlayer() or Tr.Entity:IsNPC())
end

do
	local decal = "alaln-naildecal"
	function SWEP:SprayDecals()
		local owner = self:GetOwner()
		local shootpos = owner:GetShootPos()
		local aimvec = owner:GetAimVector()
		local Tr = util.QuickTrace(shootpos, aimvec * 70, {owner})
		util.Decal(decal, Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
		local Tr2 = util.QuickTrace(shootpos, (aimvec + Vector(0, 0, .15)) * 70, {owner})
		util.Decal(decal, Tr2.HitPos + Tr2.HitNormal, Tr2.HitPos - Tr2.HitNormal)
		local Tr3 = util.QuickTrace(shootpos, (aimvec + Vector(0, 0, -.15)) * 70, {owner})
		util.Decal(decal, Tr3.HitPos + Tr3.HitNormal, Tr3.HitPos - Tr3.HitNormal)
		local Tr4 = util.QuickTrace(shootpos, (aimvec + Vector(0, .15, 0)) * 70, {owner})
		util.Decal(decal, Tr4.HitPos + Tr4.HitNormal, Tr4.HitPos - Tr4.HitNormal)
		local Tr5 = util.QuickTrace(shootpos, (aimvec + Vector(0, -.15, 0)) * 70, {owner})
		util.Decal(decal, Tr5.HitPos + Tr5.HitNormal, Tr5.HitPos - Tr5.HitNormal)
		local Tr6 = util.QuickTrace(shootpos, (aimvec + Vector(.15, 0, 0)) * 70, {owner})
		util.Decal(decal, Tr6.HitPos + Tr6.HitNormal, Tr6.HitPos - Tr6.HitNormal)
		local Tr7 = util.QuickTrace(shootpos, (aimvec + Vector(-.15, 0, 0)) * 70, {owner})
		util.Decal(decal, Tr7.HitPos + Tr7.HitNormal, Tr7.HitPos - Tr7.HitNormal)
	end
end

if CLIENT then
	local color_red = Color(185, 15, 15)
	local color_green = Color(110, 210, 110)
	function SWEP:DrawHUD()
		local owner = self:GetOwner()
		local tr = {}
		tr.start = owner:GetShootPos()
		local dir = Vector(1, 0, 0)
		dir:Rotate(owner:EyeAngles())
		tr.endpos = tr.start + dir * 500
		tr.filter = owner
		local traceResult = util.TraceLine(tr)
		local hitEnt
		local Tr = util.QuickTrace(self:GetOwner():GetShootPos(), self:GetOwner():GetAimVector() * 65, {self:GetOwner()})
		if IsValid(traceResult.Entity) and traceResult.Entity:IsNPC() then
			hitEnt = color_red
		elseif self:CanNail(Tr) then
			hitEnt = color_green
		else
			hitEnt = color_white
		end

		local frac = traceResult.Fraction
		local alpha = -(frac * 255 - 255) / 2
		surface.SetDrawColor(hitEnt.r, hitEnt.g, hitEnt.b, alpha)
		draw.NoTexture()
		Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, math.min(20, 5 / frac), 3)
	end

	local Crouched = 0
	-- tried to make viewmodel like in The Forest
	--[[function SWEP:CalcViewModelView(ViewModel, OldEyePos, OldEyeAng, EyePos, EyeAng)
		local ply = LocalPlayer()
		if not (IsValid(ply) or ply:Alive()) or ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetNoDraw() then return pos, ang end
		if self:GetOwner():KeyDown(IN_DUCK) then
			Crouched = math.Clamp(Crouched + .1, 1.5, 6)
		else
			Crouched = math.Clamp(Crouched - .1, 1.5, 6)
		end

		local eye = ply:GetAttachment(ply:LookupAttachment("forward"))
		local sitvec = Vector(0, 0, Crouched)
		local vm_origin, vm_angles = EyePos + sitvec, eye.Ang + Angle(0, -2, 0)
		return vm_origin, vm_angles
	end]]
	function SWEP:DrawWorldModel()
		if self:GetOwner():IsValid() then
			local Pos, Ang = self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))
			if self.DatWorldModel then
				if Pos and Ang then
					self.DatWorldModel:SetRenderOrigin(Pos + Ang:Forward() * 3 + Ang:Right() * 1.5 - Ang:Up())
					Ang:RotateAroundAxis(Ang:Up(), -20)
					Ang:RotateAroundAxis(Ang:Forward(), 180)
					Ang:RotateAroundAxis(Ang:Right(), 0)
					self.DatWorldModel:SetRenderAngles(Ang)
					self.DatWorldModel:DrawModel()
				end
			else
				self.DatWorldModel = ClientsideModel(self.WorldModel)
				self.DatWorldModel:SetPos(self:GetPos())
				self.DatWorldModel:SetParent(self)
				self.DatWorldModel:SetNoDraw(true)
				self.DatWorldModel:SetModelScale(1, 0)
			end
		else
			self:DrawModel()
		end
	end
end