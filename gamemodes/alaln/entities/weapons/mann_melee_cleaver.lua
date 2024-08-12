AddCSLuaFile()
SWEP.Base = "mann_melee_base"
SWEP.PrintName = "Butcher's Knife"
SWEP.Purpose = "PLACEHOLDER" --!!
SWEP.Instructions = "LMB to slash,\nRMB to stab,\nBackstabs do more damage."
SWEP.Category = "! Forsakened"
SWEP.Spawnable = true
SWEP.ViewModel = Model("models/weapons/tfa_nmrih/v_me_cleaver.mdl")
SWEP.WorldModel = Model("models/weapons/tfa_nmrih/w_me_cleaver.mdl")
SWEP.ViewModelFOV = 130
SWEP.ViewModelPositionOffset = Vector(-18, 0, -3)
SWEP.ViewModelAngleOffset = Angle(-5, 0, 2)
SWEP.UseHands = true
SWEP.HoldType = "alaln_melee"
SWEP.MeleeHolsterSlot = 1
SWEP.SoundCL = false
SWEP.Primary.Sound = Sound("weapons/slam/throw.wav")
SWEP.Primary.Damage = 60
SWEP.Primary.Delay = 0.7
SWEP.Primary.Force = 400
SWEP.PrimaryAnim = "attack_quick"
SWEP.PrimaryAnimDelay = .5
SWEP.PrimaryAnimRate = 1
SWEP.PrimaryPunch = Angle(0, 15, 0)
SWEP.AttPrimaryPunch = Angle(0, -20, 0)
SWEP.PrimaryTimer = 0.2
SWEP.Secondary.Sound = Sound("weapons/slam/throw.wav")
SWEP.Secondary.Damage = 85
SWEP.Secondary.Delay = 1
SWEP.Secondary.Force = 400
SWEP.AllowSecondAttack = true
SWEP.SecondaryAnim = "attack_charge_end"
SWEP.SecondaryAnimDelay = .5
SWEP.SecondaryAnimRate = 1
SWEP.SecondaryPunch = Angle(-15, 0, 0)
SWEP.AttSecondaryPunch = Angle(20, 0, 0)
SWEP.SecondaryTimer = 0.2
SWEP.DmgType = DMG_SLASH
SWEP.AllowBackStab = true
SWEP.BackStabMul = 2
SWEP.SlashSound = Sound("nmrihimpact/sharp_light1.wav")
SWEP.StabSound = Sound("nmrihimpact/sharp_heavy2.wav")
SWEP.HitWorldSound = Sound("physics/metal/metal_solid_impact_hard1.wav")
SWEP.ReachDistance = 76
SWEP.VModelForSelector = false
SWEP.IdleAnim = "idle"
SWEP.DeployAnim = "draw"
SWEP.DeploySound = Sound("player/weapon_draw_0" .. math.random(1, 5) .. ".wav")
-- SWEP.WMPos 				= Vector(3.5, -1.5, -2.5)
-- SWEP.WMAng 				= Angle(0, -60, 180)
SWEP.ENT = "mann_ent_hatchet"
SWEP.Droppable = true
SWEP.IconOverride = "editor/ai_goal_police"
SWEP.MaxHP = 65
SWEP.HP = 65
if CLIENT then
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
		local vm_origin, vm_angles = EyePos + sitvec, eye.Ang + Angle(0, -5, 0)
		return vm_origin, vm_angles
	end]]
	function SWEP:DrawWorldModel()
		if self:GetOwner():IsValid() then
			local Pos, Ang = self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))
			if self.DatWorldModel then
				if Pos and Ang then
					self.DatWorldModel:SetRenderOrigin(Pos + Ang:Forward() * 0.6 + Ang:Right() * -0.6 - Ang:Up() * -1)
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