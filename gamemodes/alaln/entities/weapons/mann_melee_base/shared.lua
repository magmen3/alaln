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
AddCSLuaFile()
AddCSLuaFile("client.lua")
include("client.lua")
SWEP.Base = "alaln_base"
SWEP.PrintName = "Mann's Melee Weapon Base"
SWEP.Category = "! Forsakened"
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
SWEP.Primary.Automatic = false
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
SWEP.Secondary.Automatic = false
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
SWEP.PitchMul = 1
-- SWEP.WMPos = Vector(2.5, -1, 0)
-- SWEP.WMAng = Angle(80, -30, 180)
SWEP.ENT = "mann_ent_base"
SWEP.Droppable = true
SWEP.MaxHP = 70
SWEP.HP = 70
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
		local vm = self:GetOwner():GetViewModel()
		if not IsFirstTimePredicted() then
			self:DoBFSAnimation(self.DeployAnim)
			vm:SetPlaybackRate(self.DeployAnimRate or 1)
			return
		end

		self:GetOwner():DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_PLACE)
		self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration())
		self:SetNextSecondaryFire(CurTime() + vm:SequenceDuration())
		self:SetHoldType(self.HoldType)
		self:DoBFSAnimation(self.DeployAnim)
		self:GetOwner():EmitSound(self.DeploySound)
		self:UpdateNextIdle()
		self:EnforceMeleeHolsterRules(self)
		return true
	end
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	if not IsFirstTimePredicted() then
		self:DoBFSAnimation(self.PrimaryAnim)
		owner:GetViewModel():SetPlaybackRate(self.PrimaryAnimRate or 1)
		return
	end

	owner:SetAnimation(PLAYER_ATTACK1)
	if self.SoundCL and CLIENT and owner ~= LocalPlayer() then
		owner:EmitSound(self.Primary.Sound, 75, math.random(95, 105))
	elseif not self.SoundCL and SERVER then
		owner:EmitSound(self.Primary.Sound, 75, math.random(95, 105))
	end

	owner:BetterViewPunch(self.PrimaryPunch)
	self:DoBFSAnimation(self.PrimaryAnim)
	owner:GetViewModel():SetPlaybackRate(self.PrimaryAnimRate or 1)
	local primdelay, secdelay = self.Primary.Delay, self.Secondary.Delay
	if owner:GetAlalnState("class") == "Berserker" or owner:GetAlalnState("class") == "Operative" then
		primdelay = primdelay * 0.7
		secdelay = secdelay * 0.7
	elseif owner:GetAlalnState("class") == "Gunslinger" then
		primdelay = primdelay * 1.2
		secdelay = secdelay * 1.2
	end

	self:SetNextPrimaryFire(CurTime() + primdelay)
	self:SetNextSecondaryFire(CurTime() + secdelay)
	local velmul = 1
	if owner:GetAlalnState("class") == "Gunslinger" then
		velmul = velmul * 0.6
	elseif owner:GetAlalnState("class") == "Berserker" or owner:GetAlalnState("class") == "Operative" then
		velmul = velmul * 1.3
	end

	if owner:OnGround() then
		owner:SetVelocity(owner:GetAimVector() * 150 * velmul)
	else
		owner:SetVelocity(owner:GetAimVector() * 20)
	end

	if self.PrimaryTimer then
		timer.Simple(self.PrimaryTimer, function()
			if IsValid(self) then
				self:SlashAttack()
				self:SetNextPrimaryFire(CurTime() + primdelay)
				self:SetNextSecondaryFire(CurTime() + secdelay)
			end
		end)
	else
		self:SlashAttack()
	end
end

function SWEP:SecondaryAttack()
	if not self.AllowSecondAttack then return end
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	if not IsFirstTimePredicted() then
		self:DoBFSAnimation(self.SecondaryAnim)
		owner:GetViewModel():SetPlaybackRate(self.SecondaryAnimRate or 1)
		return
	end

	owner:SetAnimation(PLAYER_ATTACK1)
	if self.SoundCL and CLIENT and owner ~= LocalPlayer() then
		owner:EmitSound(self.Secondary.Sound, 75, math.random(95, 105))
	elseif not self.SoundCL and SERVER then
		owner:EmitSound(self.Secondary.Sound, 75, math.random(95, 105))
	end

	owner:BetterViewPunch(self.SecondaryPunch)
	self:DoBFSAnimation(self.SecondaryAnim)
	if self.SecondaryAnim2 then
		timer.Simple(self.SecAnimTwoDelay, function()
			if IsValid(self) then
				self:DoBFSAnimation(self.SecondaryAnim2)
				if self.SoundCL and CLIENT and owner ~= LocalPlayer() then
					owner:EmitSound(self.Secondary2Sound, 75, math.random(95, 105))
				else
					owner:EmitSound(self.Secondary2Sound, 75, math.random(95, 105))
				end
			end
		end)
	end

	local primdelay, secdelay = self.Primary.Delay, self.Secondary.Delay
	if owner:GetAlalnState("class") == "Berserker" or owner:GetAlalnState("class") == "Operative" then
		primdelay = primdelay * 0.7
		secdelay = secdelay * 0.7
	elseif owner:GetAlalnState("class") == "Gunslinger" then
		primdelay = primdelay * 1.2
		secdelay = secdelay * 1.2
	end

	owner:DoAnimationEvent(ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND)
	owner:GetViewModel():SetPlaybackRate(self.SecondaryAnimRate or 1)
	self:SetNextPrimaryFire(CurTime() + secdelay)
	self:SetNextSecondaryFire(CurTime() + secdelay)
	local velmul = 1
	if owner:GetAlalnState("class") == "Gunslinger" then
		velmul = velmul * 0.6
	elseif owner:GetAlalnState("class") == "Berserker" or owner:GetAlalnState("class") == "Operative" then
		velmul = velmul * 1.3
	end

	if owner:OnGround() then
		owner:SetVelocity(owner:GetAimVector() * 250 * velmul)
	else
		owner:SetVelocity(owner:GetAimVector() * 30)
	end

	if self.SecondaryTimer then
		timer.Simple(self.SecondaryTimer, function()
			if IsValid(self) then
				self:StabAttack()
				self:SetNextPrimaryFire(CurTime() + secdelay)
				self:SetNextSecondaryFire(CurTime() + secdelay)
			end
		end)
	else
		self:StabAttack()
	end
end

function SWEP:SlashAttack()
	if CLIENT then return end
	local owner = self:GetOwner()
	local velmul = 1
	if owner:GetAlalnState("class") == "Gunslinger" then
		velmul = velmul * 0.6
	elseif owner:GetAlalnState("class") == "Berserker" or owner:GetAlalnState("class") == "Operative" then
		velmul = velmul * 1.3
	end

	if owner:OnGround() then
		owner:SetVelocity(owner:GetAimVector() * 250 * velmul)
	else
		owner:SetVelocity(owner:GetAimVector() * 40)
	end

	self:UpdateNextIdle()
	owner:BetterViewPunch(self.AttPrimaryPunch)
	owner:LagCompensation(true)
	local tr = util.QuickTrace(owner:GetShootPos(), owner:GetAimVector() * self.ReachDistance, {owner})
	local pos1 = tr.HitPos + tr.HitNormal
	local pos2 = tr.HitPos - tr.HitNormal
	if (tr.HitPos - owner:GetShootPos()):Length() < 80 then
		if SERVER and tr.HitWorld then owner:EmitSound(self.HitWorldSound, 75, math.random(95, 105) * self.PitchMul or 1) end
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

		if SERVER and IsValid(tr.Entity) then
			local dmginfo = DamageInfo()
			dmginfo:SetDamageType(self.DmgType)
			dmginfo:SetAttacker(owner)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamagePosition(tr.HitPos)
			dmginfo:SetDamageForce(owner:GetForward() * self.Primary.Force)
			local angle = owner:GetAngles().y - tr.Entity:GetAngles().y
			if angle < -180 then angle = 360 + angle end
			if self.AllowBackStab and angle <= 90 and angle >= -90 then
				dmginfo:SetDamage(self.Primary.Damage * self.BackStabMul * ((owner:GetAlalnState("class") == "Berserker" or owner:GetAlalnState("class") == "Operative") and 1.8 or 1))
				DebugPrint("slash back DMG = " .. dmginfo:GetDamage())
			else
				dmginfo:SetDamage(self.Primary.Damage * ((owner:GetAlalnState("class") == "Berserker" or owner:GetAlalnState("class") == "Operative") and 1.8 or 1))
				DebugPrint("slash front DMG = " .. dmginfo:GetDamage())
			end

			if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
				owner:EmitSound(self.SlashSound, 75, math.random(95, 105))
			else
				if IsValid(tr.Entity:GetPhysicsObject()) then
					local dmginfo2 = DamageInfo()
					dmginfo2:SetDamageType(self.DmgType)
					dmginfo2:SetAttacker(owner)
					dmginfo2:SetInflictor(self)
					dmginfo2:SetDamagePosition(tr.HitPos)
					dmginfo2:SetDamageForce(owner:GetForward() * self.Primary.Force * 7)
					dmginfo2:SetDamage(self.Primary.Damage / 4)
					tr.Entity:TakeDamageInfo(dmginfo2)
					if tr.Entity:GetClass() == "prop_ragdoll" then
						owner:EmitSound(self.SlashSound, 75, math.random(95, 105))
					else
						owner:EmitSound(self.HitWorldSound, 75, math.random(95, 105))
					end
				end
			end

			tr.Entity:TakeDamageInfo(dmginfo)
		end

		if SERVER and (tr.HitWorld or IsValid(tr.Entity)) then self.HP = self.HP - (self.Primary.Damage / 30) end
	end

	owner:LagCompensation(false)
end

function SWEP:StabAttack()
	if CLIENT then return end
	local owner = self:GetOwner()
	local velmul = 1
	if owner:GetAlalnState("class") == "Gunslinger" then
		velmul = velmul * 0.6
	elseif owner:GetAlalnState("class") == "Berserker" or owner:GetAlalnState("class") == "Operative" then
		velmul = velmul * 1.3
	end

	if owner:OnGround() then
		owner:SetVelocity(owner:GetAimVector() * 400 * velmul)
	else
		owner:SetVelocity(owner:GetAimVector() * 40)
	end

	self:UpdateNextIdle()
	owner:BetterViewPunch(self.AttSecondaryPunch)
	owner:LagCompensation(true)
	local tr = util.QuickTrace(owner:GetShootPos(), owner:GetAimVector() * self.ReachDistance, {owner})
	local pos1 = tr.HitPos + tr.HitNormal
	local pos2 = tr.HitPos - tr.HitNormal
	if (tr.HitPos - owner:GetShootPos()):Length() < 80 then
		if SERVER and tr.HitWorld then owner:EmitSound(self.HitWorldSound, 75, math.random(95, 105) * self.PitchMul or 1) end
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

		--util.ScreenShake(tr.HitPos, 0.25, 0.25, 0.25, 0)
		if IsValid(tr.Entity) and SERVER then
			local secdmginfo = DamageInfo()
			secdmginfo:SetDamageType(self.DmgType)
			secdmginfo:SetAttacker(owner)
			secdmginfo:SetInflictor(self)
			secdmginfo:SetDamagePosition(tr.HitPos)
			secdmginfo:SetDamageForce(owner:GetForward() * self.Secondary.Force)
			local angle = owner:GetAngles().y - tr.Entity:GetAngles().y
			if angle < -180 then angle = 360 + angle end
			if self.AllowBackStab and angle <= 90 and angle >= -90 then
				secdmginfo:SetDamage(self.Secondary.Damage * self.BackStabMul * ((owner:GetAlalnState("class") == "Berserker" or owner:GetAlalnState("class") == "Operative") and 1.8 or 1))
				DebugPrint("stab back DMG = " .. secdmginfo:GetDamage())
			else
				secdmginfo:SetDamage(self.Secondary.Damage * ((owner:GetAlalnState("class") == "Berserker" or owner:GetAlalnState("class") == "Operative") and 1.8 or 1))
				DebugPrint("stab front DMG = " .. secdmginfo:GetDamage())
			end

			if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
				owner:EmitSound(self.StabSound, 75, math.random(95, 105))
			else
				if IsValid(tr.Entity:GetPhysicsObject()) then
					local secdmginfo2 = DamageInfo()
					secdmginfo2:SetDamageType(self.DmgType)
					secdmginfo2:SetAttacker(owner)
					secdmginfo2:SetInflictor(self)
					secdmginfo2:SetDamagePosition(tr.HitPos)
					secdmginfo2:SetDamageForce(owner:GetForward() * self.Secondary.Force * 7)
					secdmginfo2:SetDamage(self.Secondary.Damage / 4)
					tr.Entity:TakeDamageInfo(secdmginfo2)
					if tr.Entity:GetClass() == "prop_ragdoll" then
						owner:EmitSound(self.StabSound, 75, math.random(95, 105))
					else
						owner:EmitSound(self.HitWorldSound, 75, math.random(95, 105))
					end
				end
			end

			tr.Entity:TakeDamageInfo(secdmginfo)
		end

		if SERVER and (tr.HitWorld or IsValid(tr.Entity)) then self.HP = self.HP - (self.Secondary.Damage / 35) end
	end

	owner:LagCompensation(false)
end

function SWEP:Reload()
	return false
end

function SWEP:DoBFSAnimation(anim)
	if IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetViewModel()) then
		local vm = self:GetOwner():GetViewModel()
		vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
	end
end

function SWEP:UpdateNextIdle()
	if IsValid(self:GetOwner()) then
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
	if IsValid(self) then
		local Ent = ents.Create(self.ENT)
		if IsValid(Ent) then
			Ent:SetPos(self:GetPos())
			Ent:SetAngles(self:GetAngles())
			Ent:Spawn()
			Ent:Activate()
			if IsValid(Ent:GetPhysicsObject()) then Ent:GetPhysicsObject():SetVelocity(self:GetVelocity() / 2) end
		end

		self:Remove()
	end
end

function SWEP:Think()
	local Time = CurTime()
	if self:GetNextIdle() < Time then
		self:DoBFSAnimation(self.IdleAnim)
		self:UpdateNextIdle()
	end

	--if SERVER then DebugPrint("hp" .. self.HP .. " maxhp " .. self.MaxHP) end
	if SERVER and self.HP <= 1 then
		self:GetOwner():EmitSound("physics/metal/metal_box_break" .. math.random(1, 2) .. ".wav", 55, math.random(95, 105))
		self:Remove()
	end
end