--[[

BBBBBBBBBBBBBBBBB   EEEEEEEEEEEEEEEEEEEEEETTTTTTTTTTTTTTTTTTTTTTT         AAA               
B::::::::::::::::B  E::::::::::::::::::::ET:::::::::::::::::::::T        A:::A              
B::::::BBBBBB:::::B E::::::::::::::::::::ET:::::::::::::::::::::T       A:::::A             
BB:::::B     B:::::BEE::::::EEEEEEEEE::::ET:::::TT:::::::TT:::::T      A:::::::A            
  B::::B     B:::::B  E:::::E       EEEEEETTTTTT  T:::::T  TTTTTT     A:::::::::A           
  B::::B     B:::::B  E:::::E                     T:::::T            A:::::A:::::A          
  B::::BBBBBB:::::B   E::::::EEEEEEEEEE           T:::::T           A:::::A A:::::A         
  B:::::::::::::BB    E:::::::::::::::E           T:::::T          A:::::A   A:::::A        
  B::::BBBBBB:::::B   E:::::::::::::::E           T:::::T         A:::::A     A:::::A       
  B::::B     B:::::B  E::::::EEEEEEEEEE           T:::::T        A:::::AAAAAAAAA:::::A      
  B::::B     B:::::B  E:::::E                     T:::::T       A:::::::::::::::::::::A     
  B::::B     B:::::B  E:::::E       EEEEEE        T:::::T      A:::::AAAAAAAAAAAAA:::::A    
BB:::::BBBBBB::::::BEE::::::EEEEEEEE:::::E      TT:::::::TT   A:::::A             A:::::A   
B:::::::::::::::::B E::::::::::::::::::::E      T:::::::::T  A:::::A               A:::::A  
B::::::::::::::::B  E::::::::::::::::::::E      T:::::::::T A:::::A                 A:::::A 
BBBBBBBBBBBBBBBBB   EEEEEEEEEEEEEEEEEEEEEE      TTTTTTTTTTTAAAAAAA                   AAAAAAA

]]
if SERVER then AddCSLuaFile() end
AddCSLuaFile("client.lua")
include("client.lua")
SWEP.Base = "alaln_base"
SWEP.PrintName = "Mann Melee Wep Base"
SWEP.Category = "Forsakened"
SWEP.Spawnable = false
SWEP.AdminOnly = true
SWEP.ViewModel = "models/weapons/v_knife.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.HoldType = "melee"
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.MeleeHolsterSlot = 1
SWEP.SoundCL = false
SWEP.Primary.Sound = "weapons/slam/throw.wav"
SWEP.Primary.Damage = 20
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = -1
SWEP.Primary.ClipSize = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.6
SWEP.Primary.Force = 400
SWEP.PrimaryAnim = "vm_knifeonly_swipe"
SWEP.PrimaryAnimDelay = .5
SWEP.PrimaryAnimRate = 1
SWEP.PrimaryPunch = Angle(0, -5, 0)
SWEP.AttPrimaryPunch = Angle(0, 5, 0)
SWEP.PrimaryTimer = 0.1
SWEP.Secondary.Sound = "weapons/slam/throw.wav"
SWEP.Secondary.Damage = 40
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Delay = 0.8
SWEP.Secondary.Force = 400
SWEP.SecondaryAnim2 = false
SWEP.SecAnimTwoDelay = 1
SWEP.SecondaryAnim = "vm_knifeonly_swipe"
SWEP.SecondaryAnimDelay = .5
SWEP.SecondaryAnimRate = 1
SWEP.SecondaryPunch = Angle(0, 5, 0)
SWEP.AttSecondaryPunch = Angle(0, -5, 0)
SWEP.SecondaryTimer = 0.1
SWEP.AllowSecondAttack = false
SWEP.DmgType = DMG_SLASH
SWEP.AllowBackStab = true
SWEP.BackStabMul = 1.5
SWEP.SlashSound = "nmrihimpact/sharp_heavy1.wav"
SWEP.StabSound = "nmrihimpact/sharp_heavy5.wav"
SWEP.HitWorldSound = "nmrihimpact/concrete/concrete_impact_bullet5.wav"
SWEP.ReachDistance = 60
SWEP.VModelForSelector = false
SWEP.IdleAnim = "vm_knifeonly_idle"
SWEP.DeployAnim = "vm_knifeonly_raise"
SWEP.DeployAnimRate = 1
SWEP.DeploySound = "player/weapon_draw_0" .. math.random(1, 5) .. ".wav"
-- SWEP.WMPos = Vector(2.5, -1, 0)
-- SWEP.WMAng = Angle(80, -30, 180)
SWEP.ENT = "mann_ent_base"
SWEP.DeathDroppable = true
SWEP.CommandDroppable = true
function SWEP:Initialize()
	self:SetNextIdle(CurTime() + 1.5)
	self:SetHoldType(self.HoldType)
end

function SWEP:ShouldDropOnDie()
	return true
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextIdle")
end

function SWEP:Deploy()
	if IsValid(self) and IsValid(self:GetOwner()) then
		if not IsFirstTimePredicted() then
			self:DoBFSAnimation(self.DeployAnim)
			self:GetOwner():GetViewModel():SetPlaybackRate(self.DeployAnimRate or 1)
			return
		end

		self:GetOwner():DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_PLACE)
		self:SetNextPrimaryFire(CurTime() + self:GetOwner():GetViewModel():SequenceDuration())
		self:SetNextSecondaryFire(CurTime() + self:GetOwner():GetViewModel():SequenceDuration())
		self:SetHoldType(self.HoldType)
		self:DoBFSAnimation(self.DeployAnim)
		self:GetOwner():EmitSound(self.DeploySound, 75, math.random(95, 105))
		self:UpdateNextIdle()
		self:EnforceMeleeHolsterRules(self)
		return true
	end
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then
		self:DoBFSAnimation(self.PrimaryAnim)
		self:GetOwner():GetViewModel():SetPlaybackRate(self.PrimaryAnimRate or 1)
		return
	end

	if self.SoundCL and CLIENT and self:GetOwner() ~= LocalPlayer() then
		self:GetOwner():EmitSound(self.Primary.Sound, 75, math.random(95, 105))
	elseif not self.SoundCL then
		self:GetOwner():EmitSound(self.Primary.Sound, 75, math.random(95, 105))
	end

	self:GetOwner():ViewPunch(self.PrimaryPunch)
	self:DoBFSAnimation(self.PrimaryAnim)
	self:GetOwner():GetViewModel():SetPlaybackRate(self.PrimaryAnimRate or 1)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	if self.PrimaryTimer then
		timer.Simple(self.PrimaryTimer, function()
			if IsValid(self) then
				self:SlashAttack()
				self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
				self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
			end
		end)
	else
		self:SlashAttack()
	end
end

function SWEP:SecondaryAttack()
	if not self.AllowSecondAttack then return end
	if not IsFirstTimePredicted() then
		self:DoBFSAnimation(self.SecondaryAnim)
		self:GetOwner():GetViewModel():SetPlaybackRate(self.SecondaryAnimRate or 1)
		return
	end

	if self.SoundCL and CLIENT and self:GetOwner() ~= LocalPlayer() then
		self:GetOwner():EmitSound(self.Secondary.Sound, 75, math.random(95, 105))
	elseif not self.SoundCL then
		self:GetOwner():EmitSound(self.Secondary.Sound, 75, math.random(95, 105))
	end

	self:GetOwner():ViewPunch(self.SecondaryPunch)
	self:DoBFSAnimation(self.SecondaryAnim)
	if self.SecondaryAnim2 then
		timer.Simple(self.SecAnimTwoDelay, function()
			if IsValid(self) then
				self:DoBFSAnimation(self.SecondaryAnim2)
				if self.SoundCL and CLIENT and self:GetOwner() ~= LocalPlayer() then
					self:GetOwner():EmitSound(self.Secondary2Sound, 75, math.random(95, 105))
				else
					self:GetOwner():EmitSound(self.Secondary2Sound, 75, math.random(95, 105))
				end
			end
		end)
	end

	self:GetOwner():DoAnimationEvent(ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND)
	self:GetOwner():GetViewModel():SetPlaybackRate(self.SecondaryAnimRate or 1)
	self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	if self.SecondaryTimer then
		timer.Simple(self.SecondaryTimer, function()
			if IsValid(self) then
				self:StabAttack()
				self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
				self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
			end
		end)
	else
		self:StabAttack()
	end
end

function SWEP:SlashAttack()
	if CLIENT then return end
	local ply = self:GetOwner()
	self:UpdateNextIdle()
	ply:SetAnimation(PLAYER_ATTACK1)
	ply:ViewPunch(self.AttPrimaryPunch)
	ply:LagCompensation(true)
	local tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * self.ReachDistance, {ply})
	local pos1 = tr.HitPos + tr.HitNormal
	local pos2 = tr.HitPos - tr.HitNormal
	if (tr.HitPos - ply:GetShootPos()):Length() < 80 then
		if SERVER and tr.HitWorld then ply:EmitSound(self.HitWorldSound, 75, math.random(95, 105)) end
		if self.DmgType == DMG_SLASH then
			if IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_ragdoll" then
				local vPoint = tr.HitPos
				local effectdata = EffectData()
				effectdata:SetOrigin(vPoint)
				util.Effect("BloodImpact", effectdata)
			end

			if SERVER then
				if IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_ragdoll" then
					util.Decal("Blood", pos1, pos2)
				else
					util.Decal("ManhackCut", pos1, pos2)
				end
			end
		end

		if IsValid(tr.Entity) and SERVER then
			local dmginfo = DamageInfo()
			dmginfo:SetDamageType(self.DmgType)
			dmginfo:SetAttacker(ply)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamagePosition(tr.HitPos)
			dmginfo:SetDamageForce(ply:GetForward() * self.Primary.Force)
			local angle = ply:GetAngles().y - tr.Entity:GetAngles().y
			if angle < -180 then angle = 360 + angle end
			if self.AllowBackStab and angle <= 90 and angle >= -90 then
				dmginfo:SetDamage(self.Primary.Damage * self.BackStabMul)
				DebugPrint("slash back DMG = " .. dmginfo:GetDamage())
			else
				dmginfo:SetDamage(self.Primary.Damage)
				DebugPrint("slash front DMG = " .. dmginfo:GetDamage())
			end

			if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
				ply:EmitSound(self.SlashSound, 75, math.random(95, 105))
			else
				if IsValid(tr.Entity:GetPhysicsObject()) then
					local dmginfo2 = DamageInfo()
					dmginfo2:SetDamageType(self.DmgType)
					dmginfo2:SetAttacker(ply)
					dmginfo2:SetInflictor(self)
					dmginfo2:SetDamagePosition(tr.HitPos)
					dmginfo2:SetDamageForce(ply:GetForward() * self.Primary.Force * 7)
					dmginfo2:SetDamage(self.Primary.Damage / 4)
					tr.Entity:TakeDamageInfo(dmginfo2)
					if tr.Entity:GetClass() == "prop_ragdoll" then
						ply:EmitSound(self.SlashSound, 75, math.random(95, 105))
					else
						ply:EmitSound(self.HitWorldSound, 75, math.random(95, 105))
					end
				end
			end

			tr.Entity:TakeDamageInfo(dmginfo)
		end
	end

	ply:LagCompensation(false)
end

function SWEP:StabAttack()
	if CLIENT then return end
	local ply = self:GetOwner()
	self:UpdateNextIdle()
	ply:SetAnimation(PLAYER_ATTACK1)
	ply:ViewPunch(self.AttSecondaryPunch)
	ply:LagCompensation(true)
	local tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * self.ReachDistance, {ply})
	local pos1 = tr.HitPos + tr.HitNormal
	local pos2 = tr.HitPos - tr.HitNormal
	if (tr.HitPos - ply:GetShootPos()):Length() < 80 then
		if SERVER and tr.HitWorld then ply:EmitSound(self.HitWorldSound, 75, math.random(95, 105)) end
		if self.DmgType == DMG_SLASH then
			if IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_ragdoll" then
				local vPoint = tr.HitPos
				local effectdata = EffectData()
				effectdata:SetOrigin(vPoint)
				util.Effect("BloodImpact", effectdata)
			end

			if SERVER then
				if IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_ragdoll" then
					util.Decal("Blood", pos1, pos2)
				else
					util.Decal("ManhackCut", pos1, pos2)
				end
			end
		end

		if IsValid(tr.Entity) and SERVER then
			local secdmginfo = DamageInfo()
			secdmginfo:SetDamageType(self.DmgType)
			secdmginfo:SetAttacker(ply)
			secdmginfo:SetInflictor(self)
			secdmginfo:SetDamagePosition(tr.HitPos)
			secdmginfo:SetDamageForce(ply:GetForward() * self.Secondary.Force)
			local angle = ply:GetAngles().y - tr.Entity:GetAngles().y
			if angle < -180 then angle = 360 + angle end
			if self.AllowBackStab and angle <= 90 and angle >= -90 then
				secdmginfo:SetDamage(self.Secondary.Damage * self.BackStabMul)
				DebugPrint("stab back DMG = " .. secdmginfo:GetDamage())
			else
				secdmginfo:SetDamage(self.Secondary.Damage)
				DebugPrint("stab front DMG = " .. secdmginfo:GetDamage())
			end

			if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
				ply:EmitSound(self.StabSound, 75, math.random(95, 105))
			else
				if IsValid(tr.Entity:GetPhysicsObject()) then
					local secdmginfo2 = DamageInfo()
					secdmginfo2:SetDamageType(self.DmgType)
					secdmginfo2:SetAttacker(ply)
					secdmginfo2:SetInflictor(self)
					secdmginfo2:SetDamagePosition(tr.HitPos)
					secdmginfo2:SetDamageForce(ply:GetForward() * self.Secondary.Force * 7)
					secdmginfo2:SetDamage(self.Secondary.Damage / 4)
					tr.Entity:TakeDamageInfo(secdmginfo2)
					if tr.Entity:GetClass() == "prop_ragdoll" then
						ply:EmitSound(self.StabSound, 75, math.random(95, 105))
					else
						ply:EmitSound(self.HitWorldSound, 75, math.random(95, 105))
					end
				end
			end

			tr.Entity:TakeDamageInfo(secdmginfo)
		end
	end

	ply:LagCompensation(false)
end

function SWEP:Reload()
	return false
end

function SWEP:DoBFSAnimation(anim)
	if self:GetOwner() then
		local vm = self:GetOwner():GetViewModel()
		vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
	end
end

function SWEP:UpdateNextIdle()
	if self:GetOwner() then
		local vm = self:GetOwner():GetViewModel()
		self:SetNextIdle(CurTime() + vm:SequenceDuration() + self.Primary.Delay + self.PrimaryAnimRate * 2)
	end
end

function SWEP:EnforceMeleeHolsterRules(newWep)
	if CLIENT then return end
	if newWep ~= self then -- only enforce rules for us
		return
	end

	for key, wep in pairs(self:GetOwner():GetWeapons()) do
		-- conflict
		if wep.MeleeHolsterSlot and self.MeleeHolsterSlot and (wep.MeleeHolsterSlot == self.MeleeHolsterSlot) and wep ~= self then self:GetOwner():DropWeapon(wep) end
	end
end

function SWEP:Holster(newWep)
	self:EnforceMeleeHolsterRules(newWep)
	return true
end

function SWEP:OnDrop()
	local Ent = ents.Create(self.ENT)
	Ent:SetPos(self:GetPos())
	Ent:SetAngles(self:GetAngles())
	Ent:Spawn()
	Ent:Activate()
	Ent:GetPhysicsObject():SetVelocity(self:GetVelocity() / 2)
	self:Remove()
end

function SWEP:Think()
	local Time = CurTime()
	if self:GetNextIdle() < Time then
		self:DoBFSAnimation(self.IdleAnim)
		self:UpdateNextIdle()
	end
end