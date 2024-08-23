AddCSLuaFile()
SWEP.Base = "mann_wep_base"
SWEP.PrintName = "Flare Gun"
SWEP.Purpose = "PLACEHOLDER" --!!
SWEP.Instructions = "LMB to fire,\nRMB to aim sights."
SWEP.Spawnable = true
SWEP.Category = "! Forsakened"
SWEP.Spawnable = true
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 3
SWEP.ViewModel = Model("models/weapons/tfa_nmrih/v_fa_flaregun.mdl")
SWEP.WorldModel = Model("models/weapons/tfa_nmrih/w_fa_flaregun.mdl")
SWEP.IdlePos = Vector(-0.5, -12, 0.5)
SWEP.ViewModelFOV = 120
SWEP.ViewModelFlip = false
SWEP.InsHands = false
SWEP.UseHands = true
SWEP.FuckedWorldModel = true
SWEP.FuckedWorldModelForward = 5
SWEP.FuckedWorldModelUp = -1
SWEP.FuckedWorldModelAngFW = 175
SWEP.FuckedWorldModelAngR = 0
SWEP.FuckedWorldModelRight = 2
SWEP.Primary.Ammo = "SMG1_Grenade"
SWEP.Primary.Damage = 80
SWEP.Primary.Recoil = 3.5
SWEP.ShellType = ""
SWEP.Primary.Automatic = false
SWEP.TriggerDelay = .1
SWEP.CycleTime = .4
SWEP.ENT = "mann_ent_flaregun"
SWEP.CustomColor = Color(200, 200, 200, 255)
SWEP.HolsterSlot = 2
SWEP.AimPos = Vector(-2.42, -2, 2)
SWEP.AimAng = Angle(0, 1.5, 0)
SWEP.SprintPos = Vector(5, -2, 0)
SWEP.SprintAng = Angle(-20, 30, 0)
SWEP.CloseFireSound = Sound("vj_weapons/flare/fire.wav")
SWEP.ExtraFireSound = Sound("snd_mann_bulletcrack.wav")
SWEP.FarFireSound = Sound("vj_weapons/flare/fire_dist.wav")
SWEP.ReloadSound = Sound("snd_jack_hmcd_rvreload.wav")
SWEP.ShotPitch = math.random(95, 103)
SWEP.DrawAnim = "draw"
SWEP.FireAnim = "fire_1"
SWEP.LastFireAnim = "fire_last_1"
SWEP.DryFireAnim = "fire_dry_1"
SWEP.ReloadAnim = "reload_dry"
SWEP.ReloadTime = 3.7
SWEP.ReloadRate = 0.75
SWEP.HipHoldType = "alaln_revolver_idle"
SWEP.AimHoldType = "alaln_revolver_aim"
SWEP.DownHoldType = "alaln_melee"
SWEP.IconOverride = "editor/ai_goal_standoff"
SWEP.BarrelLength = 5
SWEP.Droppable = true
SWEP.IconOverride = "editor/env_explosion"
function SWEP:ShootFlare()
	local owner = self:GetOwner()
	if owner:IsSprinting() then return end
	if CLIENT then return end
	local proj = ents.Create("obj_vj_flareround")
	local ply_Ang = owner:GetAimVector():Angle()
	local ply_Pos = owner:GetShootPos()
	if owner:IsPlayer() then
		proj:SetPos(ply_Pos)
	else
		proj:SetPos(self:GetNW2Vector("VJ_CurBulletPos"))
	end

	if owner:IsPlayer() then
		proj:SetAngles(ply_Ang)
	else
		proj:SetAngles(owner:GetAngles())
	end

	proj:SetOwner(owner)
	proj:Activate()
	proj:Spawn()
	local phys = proj:GetPhysicsObject()
	if IsValid(phys) and IsValid(owner) then phys:SetVelocity(owner:GetAimVector() * 15000) end
end

function SWEP:PrimaryAttack()
	self.ReloadInterrupted = true
	if not self:GetReady() then return end
	if self:GetSprinting() > 10 then return end
	local owner = self:GetOwner()
	if self:Clip1() <= 0 then
		self:EmitSound("weapons/firearms/hndg_glock17/glock17_dryfire.wav")
		self:SetNextPrimaryFire(CurTime() + (self.Primary.Automatic and .4 or .3))
		if self.DryFireAnim then self:DoBFSAnimation(self.DryFireAnim) end
		if SERVER and math.random(1, 2) == 2 and owner:GetActiveWeapon():GetClass() == self:GetClass() then owner:ConCommand("checkammo") end
		return
	end

	if not IsFirstTimePredicted() then
		if (self:Clip1() == 1) and self.LastFireAnim then
			self:DoBFSAnimation(self.LastFireAnim)
		elseif self:Clip1() > 0 then
			self:DoBFSAnimation(self.FireAnim)
		end
		return
	end

	self.LastFire = CurTime()
	local WaterMul = 1
	if owner:GetAlalnState("class") == "Berserker" then
		WaterMul = .9
	elseif owner:GetAlalnState("class") == "Gunslinger" or owner:GetAlalnState("class") == "Operative" then
		WaterMul = 1.5
	end

	if owner:WaterLevel() >= 3 then WaterMul = .5 end
	local dmgAmt, InAcc = self.Primary.Damage * math.Rand(.9, 1.1) * WaterMul, 1 - self.Accuracy
	if owner:GetAlalnState("class") == "Berserker" then
		InAcc = (1.05 - self.Accuracy) * 1.5
	elseif owner:GetAlalnState("class") == "Gunslinger" or owner:GetAlalnState("class") == "Operative" then
		InAcc = (1 - self.Accuracy) * 0.5
	end

	if self:GetAiming() <= 99 then InAcc = InAcc + self.HipFireInaccuracy end
	self:ShootFlare()
	if (owner:GetAlalnState("class") ~= "Gunslinger" and owner:GetAlalnState("class") ~= "Operative") and CLIENT then self:Stun() end
	if (self:Clip1() == 1) and self.LastFireAnim then
		self:DoBFSAnimation(self.LastFireAnim)
	elseif self:Clip1() > 0 then
		self:DoBFSAnimation(self.FireAnim)
		if self.FireAnimRate then owner:GetViewModel():SetPlaybackRate(self.FireAnimRate) end
	end

	owner:SetAnimation(PLAYER_ATTACK1)
	local Pitch = self.ShotPitch * math.Rand(.95, 1)
	if SERVER then
		local Dist = 75
		owner:EmitSound(self.CloseFireSound, Dist, Pitch)
		owner:EmitSound(self.FarFireSound, Dist * 2, Pitch)
		if self.ExtraFireSound then sound.Play(self.ExtraFireSound, owner:GetShootPos() + VectorRand(), Dist - 5, Pitch) end
		if self.CycleType == "manual" then
			timer.Simple(.2, function()
				if IsValid(self) and IsValid(owner) then
					self:DoBFSAnimation(self.CycleAnim)
					self:EmitSound(self.CycleSound, 55, 100)
				end
			end)
		end
	end

	local Rightness, Upness = 4, 2
	if self:GetAiming() == 100 then
		Rightness = 0
		Upness = 0
	end

	ParticleEffect(self.MuzzleEffect, owner:GetShootPos() + owner:GetAimVector() * 20 + owner:EyeAngles():Right() * Rightness - owner:EyeAngles():Up() * Upness, owner:EyeAngles(), self)
	if SERVER and (self.CycleType == "auto") and self.ShellType and self.ShellType ~= "" then
		local effectdata = EffectData()
		effectdata:SetOrigin(owner:GetShootPos() + owner:GetAimVector() * 15 + owner:EyeAngles():Right() * Rightness - owner:EyeAngles():Up() * Upness)
		effectdata:SetAngles(owner:GetRight():Angle())
		effectdata:SetEntity(owner)
		util.Effect(self.ShellType, effectdata, true, true)
	elseif SERVER and (self.CycleType == "manual") and self.ShellType and self.ShellType ~= "" then
		timer.Simple(.4, function()
			if IsValid(self) and IsValid(owner) then
				local effectdata = EffectData()
				effectdata:SetOrigin(owner:GetShootPos() + owner:GetAimVector() * 15 + owner:EyeAngles():Right() * Rightness - owner:EyeAngles():Up() * Upness)
				effectdata:SetAngles(owner:GetRight():Angle())
				effectdata:SetEntity(owner)
				util.Effect(self.ShellType, effectdata, true, true)
			end
		end)
	end

	local Ang, Rec = owner:EyeAngles(), self.Primary.Recoil
	if owner:GetAlalnState("class") == "Gunslinger" or owner:GetAlalnState("class") == "Operative" then
		Rec = Rec * 0.5
	elseif owner:GetAlalnState("class") == "Berserker" then
		Rec = Rec * 1.2
	end

	local RecoilY = math.Rand(.020, .023) * Rec
	local RecoilX = math.Rand(-.018, .021) * Rec
	if (SERVER and game.SinglePlayer()) or CLIENT then owner:SetEyeAngles((Ang:Forward() + RecoilY * Ang:Up() + Ang:Right() * RecoilX):Angle()) end
	if not owner:OnGround() then owner:SetVelocity(owner:GetAimVector() * -10) end
	owner:ViewPunchReset()
	owner:BetterViewPunch(Angle(RecoilY * -30 * self.Primary.Recoil, RecoilX * -30 * self.Primary.Recoil, 0))
	self:TakePrimaryAmmo(1)
	local Extra = 0
	if owner:WaterLevel() >= 3 then Extra = 1 end
	local trigdelay, velmul = self.TriggerDelay, 1
	if owner:GetAlalnState("class") == "Gunslinger" or owner:GetAlalnState("class") == "Operative" then
		trigdelay = trigdelay * 0.7
		velmul = velmul * 0.6
	elseif owner:GetAlalnState("class") == "Berserker" then
		trigdelay = trigdelay * 1.2
		velmul = velmul * 1.3
	end

	if owner:OnGround() then owner:SetVelocity(owner:GetAimVector() * -40 * velmul) end
	self:SetNextPrimaryFire(CurTime() + trigdelay + self.CycleTime + Extra)
end