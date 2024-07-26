-- Default weapon base edited for optimization purposes
SWEP.PrintName = "Scripted Weapon"
SWEP.Category = "! Forsakened"
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.ViewModelFOV = 75
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.Spawnable = false
SWEP.AdminOnly = true
SWEP.Primary.ClipSize = 0 -- Size of a clip
SWEP.Primary.DefaultClip = 0 -- Default number of bullets in a clip
SWEP.Primary.Automatic = false -- Automatic/Semi Auto
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = 0 -- Size of a clip
SWEP.Secondary.DefaultClip = 0 -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false -- Automatic/Semi Auto
SWEP.Secondary.Ammo = "none"
--[[---------------------------------------------------------
	Name: SWEP:Initialize()
	Desc: Called when the weapon is first loaded
-----------------------------------------------------------]]
function SWEP:Initialize()
	self:SetHoldType("normal")
end

--[[---------------------------------------------------------
	Name: SWEP:PrimaryAttack()
	Desc: +attack1 has been pressed
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()
	-- Make sure we can shoot first
	if not self:CanPrimaryAttack() then return end
end

--[[---------------------------------------------------------
	Name: SWEP:SecondaryAttack()
	Desc: +attack2 has been pressed
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()
	-- Make sure we can shoot first
	if not self:CanSecondaryAttack() then return end
end

--[[---------------------------------------------------------
	Name: SWEP:Reload()
	Desc: Reload is being pressed
-----------------------------------------------------------]]
function SWEP:Reload()
	self:DefaultReload(ACT_VM_RELOAD)
end

--[[---------------------------------------------------------
	Name: SWEP:Think()
	Desc: Called every frame
-----------------------------------------------------------]]
function SWEP:Think()
end

--[[---------------------------------------------------------
	Name: SWEP:Holster( weapon_to_swap_to )
	Desc: Weapon wants to holster
	RetV: Return true to allow the weapon to holster
-----------------------------------------------------------]]
function SWEP:Holster(wep)
	return true
end

--[[---------------------------------------------------------
	Name: SWEP:Deploy()
	Desc: Whip it out
-----------------------------------------------------------]]
function SWEP:Deploy()
	return true
end

--[[---------------------------------------------------------
	Name: SWEP:ShootEffects()
	Desc: A convenience function to create shoot effects
-----------------------------------------------------------]]
function SWEP:ShootEffects()
	local owner = self:GetOwner()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) -- View model animation
	owner:MuzzleFlash() -- Crappy muzzle light
	owner:SetAnimation(PLAYER_ATTACK1) -- 3rd Person Animation
end

--[[---------------------------------------------------------
	Name: SWEP:ShootBullet()
	Desc: A convenience function to shoot bullets
-----------------------------------------------------------]]
function SWEP:ShootBullet(damage, num_bullets, aimcone, ammo_type, force, tracer)
	local owner = self:GetOwner()
	local bullet = {}
	bullet.Num = num_bullets
	bullet.Src = owner:GetShootPos() -- Source
	bullet.Dir = owner:GetAimVector() -- Dir of bullet
	bullet.Spread = Vector(aimcone, aimcone, 0) -- Aim Cone
	bullet.Tracer = tracer or 5 -- Show a tracer on every x bullets
	bullet.Force = force or 1 -- Amount of force to give to phys objects
	bullet.Damage = damage
	bullet.AmmoType = ammo_type or self.Primary.Ammo
	owner:FireBullets(bullet)
	self:ShootEffects()
end

--[[---------------------------------------------------------
	Name: SWEP:TakePrimaryAmmo()
	Desc: A convenience function to remove ammo
-----------------------------------------------------------]]
function SWEP:TakePrimaryAmmo(num)
	-- Doesn't use clips
	if self:Clip1() <= 0 then
		if self:Ammo1() <= 0 then return end
		self:GetOwner():RemoveAmmo(num, self:GetPrimaryAmmoType())
		return
	end

	self:SetClip1(self:Clip1() - num)
end

--[[---------------------------------------------------------
	Name: SWEP:TakeSecondaryAmmo()
	Desc: A convenience function to remove ammo
-----------------------------------------------------------]]
function SWEP:TakeSecondaryAmmo(num)
	-- Doesn't use clips
	if self:Clip2() <= 0 then
		if self:Ammo2() <= 0 then return end
		self:GetOwner():RemoveAmmo(num, self:GetSecondaryAmmoType())
		return
	end

	self:SetClip2(self:Clip2() - num)
end

--[[---------------------------------------------------------
	Name: SWEP:CanPrimaryAttack()
	Desc: Helper function for checking for no ammo
-----------------------------------------------------------]]
function SWEP:CanPrimaryAttack()
	if self:Clip1() <= 0 then
		self:EmitSound("Weapon_Pistol.Empty")
		self:SetNextPrimaryFire(CurTime() + 0.2)
		self:Reload()
		return false
	end
	return true
end

--[[---------------------------------------------------------
	Name: SWEP:CanSecondaryAttack()
	Desc: Helper function for checking for no ammo
-----------------------------------------------------------]]
function SWEP:CanSecondaryAttack()
	if self:Clip2() <= 0 then
		self:EmitSound("Weapon_Pistol.Empty")
		self:SetNextSecondaryFire(CurTime() + 0.2)
		return false
	end
	return true
end

--[[---------------------------------------------------------
	Name: OnRemove
	Desc: Called just before entity is deleted
-----------------------------------------------------------]]
function SWEP:OnRemove()
end

--[[---------------------------------------------------------
	Name: OwnerChanged
	Desc: When weapon is dropped or picked up by a new player
-----------------------------------------------------------]]
function SWEP:OwnerChanged()
end

--[[---------------------------------------------------------
	Name: Ammo1
	Desc: Returns how much of ammo1 the player has
-----------------------------------------------------------]]
function SWEP:Ammo1()
	return self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType())
end

--[[---------------------------------------------------------
	Name: Ammo2
	Desc: Returns how much of ammo2 the player has
-----------------------------------------------------------]]
function SWEP:Ammo2()
	return self:GetOwner():GetAmmoCount(self:GetSecondaryAmmoType())
end

--[[---------------------------------------------------------
	Name: DoImpactEffect
	Desc: Callback so the weapon can override the impact effects it makes
		 return true to not do the default thing - which is to call UTIL_ImpactTrace in c++
-----------------------------------------------------------]]
function SWEP:DoImpactEffect(tr, nDamageType)
	return false
end