AddCSLuaFile()
SWEP.Base = "mann_melee_base"
SWEP.PrintName = "Fire Axe"
SWEP.Purpose = "PLACEHOLDER" --!!
SWEP.Instructions = "LMB to slash.\nRMB to stab.\nBackstabs do more damage."
SWEP.Category = "! Forsakened"
SWEP.Spawnable = true
SWEP.ViewModel = Model("models/weapons/tfa_nmrih/v_me_axe_fire.mdl")
SWEP.WorldModel = Model("models/weapons/tfa_nmrih/w_me_axe_fire.mdl")
SWEP.ViewModelFOV = 140
SWEP.ViewModelPositionOffset = Vector(-12, 0, 0)
SWEP.ViewModelAngleOffset = Angle(-15, 0, -5)
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.HoldType = "melee2"
SWEP.MeleeHolsterSlot = 1
SWEP.SoundCL = false
SWEP.Primary.Sound = Sound("weapons/slam/throw.wav")
SWEP.Primary.Damage = 90
SWEP.Primary.Delay = 1
SWEP.Primary.Force = 400
SWEP.PrimaryAnim = "attack_quick"
SWEP.PrimaryAnimDelay = .5
SWEP.PrimaryAnimRate = 1
SWEP.PrimaryPunch = Angle(0, -25, 0)
SWEP.AttPrimaryPunch = Angle(0, 25, 0)
SWEP.PrimaryTimer = 0.2
SWEP.Secondary.Sound = ""
SWEP.Secondary2Sound = Sound("weapons/slam/throw.wav")
SWEP.Secondary.Damage = 130
SWEP.Secondary.Delay = 1.6
SWEP.Secondary.Force = 400
SWEP.AllowSecondAttack = true
SWEP.SecondaryAnim = "attack_charge_begin"
SWEP.SecondaryAnim2 = "attack_charge_end"
SWEP.SecAnimTwoDelay = 0.6
SWEP.SecondaryAnimDelay = .6
SWEP.SecondaryAnimRate = 1.3
SWEP.SecondaryPunch = angle_zero
SWEP.AttSecondaryPunch = Angle(45, 5, 0)
SWEP.SecondaryTimer = 0.8
SWEP.DmgType = DMG_SLASH
SWEP.AllowBackStab = true
SWEP.BackStabMul = 2
SWEP.SlashSound = Sound("nmrihimpact/sharp_heavy1.wav")
SWEP.StabSound = Sound("physics/body/body_medium_break" .. math.random(2, 4) .. ".wav")
SWEP.HitWorldSound = Sound("nmrihimpact/concrete/concrete_impact_bullet2.wav")
SWEP.ReachDistance = 110
SWEP.VModelForSelector = false
SWEP.IdleAnim = "idle"
SWEP.DeployAnim = "draw"
SWEP.DeploySound = Sound("player/weapon_draw_0" .. math.random(1, 5) .. ".wav")
SWEP.PitchMul = 0.96
SWEP.ENT = "mann_ent_fireaxe"
SWEP.Droppable = true
SWEP.NoHolster = true
SWEP.IconOverride = "editor/ai_goal_police"
SWEP.MaxHP = 85
SWEP.HP = 85
if CLIENT then
	--local Crouched = 0
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
		local sitvec = Vector(1, -1, Crouched)
		local vm_origin, vm_angles = EyePos + sitvec, eye.Ang + Angle(0, -5, -10)
		return vm_origin, vm_angles
	end]]
	function SWEP:DrawWorldModel()
		if self:GetOwner():IsValid() then
			local Pos, Ang = self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))
			if self.DatWorldModel then
				if Pos and Ang then
					self.DatWorldModel:SetRenderOrigin(Pos + Ang:Forward() * 3.9 + Ang:Right() - Ang:Up() * 6)
					Ang:RotateAroundAxis(Ang:Up(), 180)
					Ang:RotateAroundAxis(Ang:Right(), 180)
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