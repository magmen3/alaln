if SERVER then AddCSLuaFile() end
SWEP.Base = "mann_melee_base"
SWEP.PrintName = "Metal Baseball Bat"
SWEP.Instructions = "This is your trusty metallic baseball bat. Use it as you see fit.\n\nLMB to slash.\nRMB to stab.\nBackstabs do more damage."
SWEP.Category = "Forsakened"
SWEP.Spawnable = true
SWEP.ViewModel = Model("models/weapons/tfa_nmrih/v_me_bat_metal.mdl")
SWEP.WorldModel = Model("models/weapons/tfa_nmrih/w_me_bat_metal.mdl")
SWEP.ViewModelFOV = 65
SWEP.UseHands = true
SWEP.HoldType = "melee2"
SWEP.MeleeHolsterSlot = 1
SWEP.Primary.Sound = "weapons/slam/throw.wav"
SWEP.Primary.Damage = 85
SWEP.Primary.Delay = 0.9
SWEP.Primary.Force = 400
SWEP.PrimaryAnim = "attack_quick"
SWEP.PrimaryAnimDelay = .5
SWEP.PrimaryAnimRate = 1
SWEP.PrimaryPunch = Angle(0, 20, 0)
SWEP.AttPrimaryPunch = Angle(0, -25, 0)
SWEP.PrimaryTimer = 0.2
SWEP.Secondary.Sound = ""
SWEP.Secondary2Sound = "weapons/slam/throw.wav"
SWEP.Secondary.Damage = 130
SWEP.Secondary.Delay = 1.2
SWEP.Secondary.Force = 400
SWEP.AllowSecondAttack = true
SWEP.SecondaryAnim = "attack_charge_begin"
SWEP.SecondaryAnim2 = "attack_charge_end"
SWEP.SecAnimTwoDelay = 0.6
SWEP.SecondaryAnimDelay = .6
SWEP.SecondaryAnimRate = 1.3
SWEP.SecondaryPunch = angle_zero
SWEP.AttSecondaryPunch = Angle(-20, 5, 0)
SWEP.SecondaryTimer = 0.8
SWEP.DmgType = DMG_CLUB
SWEP.AllowBackStab = true
SWEP.BackStabMul = 2
SWEP.SlashSound = "physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav"
SWEP.StabSound = "physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav"
SWEP.HitWorldSound = "physics/metal/metal_solid_impact_hard" .. math.random(4, 5) .. ".wav"
SWEP.ReachDistance = 87
SWEP.VModelForSelector = false
SWEP.IdleAnim = "idle"
SWEP.DeployAnim = "draw"
SWEP.DeploySound = "player/weapon_draw_0" .. math.random(1, 5) .. ".wav"
-- SWEP.WMPos 				= Vector(3.5, -1.5, -2.5)
-- SWEP.WMAng 				= Angle(-80, 180, 180)
SWEP.ENT = "mann_ent_metalbat"
SWEP.DeathDroppable = true
SWEP.CommandDroppable = true
SWEP.NoHolster = true
SWEP.IconOverride = "editor/ai_goal_police"
if CLIENT then
	-- tried to make viewmodel like in The Forest
	function SWEP:CalcViewModelView(ViewModel, OldEyePos, OldEyeAng, EyePos, EyeAng)
		local ply = LocalPlayer()
		if not (IsValid(ply) or ply:Alive()) or ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetNoDraw() then return end
		local eye = ply:GetAttachment(ply:LookupAttachment("forward"))
		local sitvec = Vector(1, -1, ply:KeyDown(IN_DUCK) and 1 or 0.5)
		local vm_origin, vm_angles = EyePos + sitvec, eye.Ang + Angle(0, -5, -10)
		return vm_origin, vm_angles
	end

	function SWEP:DrawWorldModel()
		if self:GetOwner():IsValid() then
			local Pos, Ang = self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))
			if self.DatWorldModel then
				if Pos and Ang then
					self.DatWorldModel:SetRenderOrigin(Pos + Ang:Forward() * 3.9 + Ang:Right() - Ang:Up() * 2.5)
					Ang:RotateAroundAxis(Ang:Up(), -5)
					Ang:RotateAroundAxis(Ang:Right(), 190)
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
		end
	end
end