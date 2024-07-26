AddCSLuaFile()
SWEP.Base = "mann_melee_base"
SWEP.PrintName = "Kampfmesser KM-2000"
SWEP.Purpose = "This is your trusty combat knife, used by German Bundeswehr and German Army. Use it as you see fit. Made in Germany!"
SWEP.Instructions = "LMB to slash,\nRMB to stab,\nBackstabs do more damage."
SWEP.Category = "! Forsakened"
SWEP.Spawnable = true
SWEP.ViewModel = Model("models/weapons/v_km2000_knife.mdl")
SWEP.WorldModel = Model("models/weapons/w_km2000_knife.mdl")
SWEP.ViewModelFOV = 120
SWEP.ViewModelPositionOffset = Vector(-10, 0, 0)
SWEP.ViewModelAngleOffset = Angle(3, 0, 2)
SWEP.UseHands = true
SWEP.HoldType = "knife"
SWEP.MeleeHolsterSlot = 1
SWEP.Primary.Sound = Sound("weapons/tfa_tannenberg_type30/hatchet_melee_05.wav")
SWEP.Primary.Damage = 65
SWEP.Primary.Delay = 0.7
SWEP.Primary.Force = 400
SWEP.PrimaryAnim = "hitcenter2"
SWEP.PrimaryAnimDelay = .5
SWEP.PrimaryAnimRate = 1
SWEP.PrimaryPunch = Angle(0, 10, 0)
SWEP.AttPrimaryPunch = Angle(0, -15, 0)
SWEP.PrimaryTimer = 0.1
SWEP.Secondary.Sound = Sound("weapons/tfa_tannenberg_type30/hatchet_melee_05.wav")
SWEP.Secondary.Damage = 85
SWEP.Secondary.Delay = 0.9
SWEP.Secondary.Force = 400
SWEP.AllowSecondAttack = true
SWEP.SecondaryAnim = "hitcenter1"
SWEP.SecondaryAnimDelay = .5
SWEP.SecondaryAnimRate = 1
SWEP.SecondaryPunch = Angle(-10, 0, 0)
SWEP.AttSecondaryPunch = Angle(15, 0, 0)
SWEP.SecondaryTimer = 0.15
SWEP.DmgType = DMG_SLASH
SWEP.AllowBackStab = true
SWEP.BackStabMul = 2
SWEP.SlashSound = Sound("weapons/tfa_tannenberg_type30/bayonet_hitflesh_03.wav")
SWEP.StabSound = Sound("weapons/tfa_tannenberg_type30/bayonet_hitflesh_04.wav")
SWEP.HitWorldSound = Sound("weapons/tfa_tannenberg_type30/bayonet_hitworld_0" .. math.random(1, 4) .. ".wav")
SWEP.ReachDistance = 74
SWEP.VModelForSelector = false
SWEP.IdleAnim = "idle"
SWEP.DeployAnim = "draw"
SWEP.DeploySound = Sound("player/weapon_draw_0" .. math.random(1, 5) .. ".wav")
SWEP.PitchMul = 0.96
-- SWEP.WMPos 				= Vector(3.5, -1.5, -2.5)
-- SWEP.WMAng 				= Angle(0, -60, 180)
SWEP.ENT = "mann_ent_knife"
SWEP.Droppable = true
SWEP.IconOverride = "editor/ai_goal_police"
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
					self.DatWorldModel:SetRenderOrigin(Pos + Ang:Forward() * 2.5 + Ang:Right() - Ang:Up() * -3)
					Ang:RotateAroundAxis(Ang:Up(), -20)
					Ang:RotateAroundAxis(Ang:Forward(), 190)
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
		end
	end
end