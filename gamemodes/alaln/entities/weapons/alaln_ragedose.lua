if SERVER then
   AddCSLuaFile()
end

if CLIENT then 
    SWEP.WepSelectIcon = surface.GetTextureID( "vgui/hud/item_gene_therapy" )
	SWEP.BounceWeaponIcon = true 
    SWEP.DrawWeaponInfoBox = true
end

SWEP.PrintName = "Genetherapy"
SWEP.Purpose = "Adds 50 armor"
SWEP.Instructions = "LMB to use,\nRMB to push."
SWEP.Category = "! Forsakened"
SWEP.Spawnable = true
SWEP.ViewModel = "models/weapons/nmrih/items/genetherapy/v_item_genetherapy.mdl"
SWEP.WorldModel = "models/weapons/nmrih/items/genetherapy/w_genetherapy.mdl"
SWEP.ViewModelPositionOffset = Vector(-6, 0, 0)
SWEP.ViewModelAngleOffset = Angle(0, 0, 0)
SWEP.ViewModelFOV = 130
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false 
SWEP.UseHands = true

SWEP.Primary.Ammo = "nmrih_genetherapy"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.IdleTimer = 0
SWEP.HitDistance = 45

local HealAmount = 0
local ArmorAmount = 50
local HealTime = 8.8
local AttackTime = 0.8

local SecondaryAttacking = false

local Crouched = 0
function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
	local owner = self:GetOwner()
	if not IsValid(owner) then return pos, ang end
	if owner:KeyDown(IN_DUCK) then
		Crouched = math.Clamp(Crouched + .05, 0, 2)
	else
		Crouched = math.Clamp(Crouched - .05, 0, 2)
	end

	local forward, right, up = self.ViewModelPositionOffset.x, self.ViewModelPositionOffset.y, self.ViewModelPositionOffset.z + Crouched
	local angs = owner:EyeAngles()
	local s, t = math.sin, CurTime()
	local offset = Vector(s(t * 1.5) * 0.5, s(t * 1.6) * 0.6, s(t * 1.7) * 0.8)
	--ang.pitch = -ang.pitch
	ang:RotateAroundAxis(ang:Forward(), self.ViewModelAngleOffset.pitch)
	ang:RotateAroundAxis(ang:Right(), self.ViewModelAngleOffset.roll)
	ang:RotateAroundAxis(ang:Up(), self.ViewModelAngleOffset.yaw)
	return pos + offset + angs:Forward() * forward + angs:Right() * right + angs:Up() * up, ang
end

function SWEP:Initialize()
    self:SetHoldType("pistol")
	
	IsInfectiousZombieAddonMounted = false
	
	if xdeif_Cure then
	    IsInfectiousZombieAddonMounted = true
	end
end  

function SWEP:Deploy()
    local owner = self:GetOwner() 

    self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime() + 0)
	if owner:GetAmmoCount(self.Primary.Ammo) == 0 then
        owner:StripWeapon("nmrih_genetherapy_consumable")
	end
	
	if owner:GetAmmoCount(self.Primary.Ammo) == 0 then return end
	self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	self.Idle = 0
	self.Move = 0
	self.Sprint = 0
	self.Consume = 0
	self.Attack = 0
	timer.Remove( "ConsumeTimerGenetherapyNMRIH" )
end

function SWEP:Think()
    local owner = self:GetOwner()
	if not IsValid(owner) then return end
	
    if self.Idle == 0 and self.IdleTimer <= CurTime() then
		self:SendWeaponAnim(ACT_VM_IDLE)  
        self.Idle = 1
    end
	
	if SecondaryAttacking == false then
		if self.Consume == 1 then
			self.ViewModelFOV = 110
		end

	    if owner:KeyDown(IN_FORWARD + IN_BACK + IN_MOVELEFT + IN_MOVERIGHT) and self.Move == 0 and self.Consume == 0 then
	        if self.Move == 0 and self.IdleTimer <= CurTime() then
		        self:SendWeaponAnim(ACT_VM_IDLE_LOWERED)  
		        self.Move = 1
		    end
	    elseif not owner:KeyDown(IN_FORWARD + IN_BACK + IN_MOVELEFT + IN_MOVERIGHT) and self.Consume == 0 then
	        if self.Move == 1 and self.IdleTimer <= CurTime() then
		        self.Move = 0
			    self.Idle = 0
		    end
	    end
	 
	    if owner:KeyDown(IN_FORWARD) and owner:KeyDown(IN_SPEED) and self.Sprint == 0 and self.Consume == 0 then
	        if self.Sprint == 0 and self.IdleTimer <= CurTime() then
		        self:SendWeaponAnim(ACT_VM_SPRINT_IDLE)  
		        self.Sprint = 1
				self.ViewModelFOV = 100
		    end
	    elseif not owner:KeyDown(IN_SPEED) and self.Consume == 0 then
	        if self.Sprint == 1 and self.IdleTimer <= CurTime() then
		        self.Sprint = 0
			    self.Idle = 0
			    self.Move = 0
				self.ViewModelFOV = 130
		    end
	    end
	end
end

function SWEP:PrimaryAttack()
    local owner = self.Owner
	local ent = self.Owner
	
	if owner:GetAmmoCount(self.Primary.Ammo) == 0 then return end
	
	if SecondaryAttacking == false then
	    self.Idle = 1
	    self.Move = 1
	    self.Consume = 1
	    self:SetNextPrimaryFire(CurTime() + HealTime + 0)
        self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	
	    timer.Create("ConsumeTimerGenetherapyNMRIH", HealTime, 1, function()
            HealGeneNMRIH(ent, self)
        end)
	end
end

function HealGeneNMRIH(ent, self)
    local activeWeapon = ent:GetActiveWeapon()
	
	if IsValid(self) then
        if ( IsValid( ent ) && SERVER ) and activeWeapon:GetClass() == "nmrih_genetherapy_consumable" then
		    if GetConVar("convar_consumablesnmrih_earmor"):GetBool() then
		        ent:SetHealth(math.min(ent:GetMaxHealth(), ent:Health() + HealAmount))
		        ent:SetArmor(math.min(ent:GetMaxArmor(), ent:Armor() + ArmorAmount))
			    ent:RemoveAmmo(1, "nmrih_genetherapy")
			end
			
			if IsInfectiousZombieAddonMounted == true and GetConVar("convar_consumablesnmrih_ecureinf"):GetBool() then
			    vacc = 1
			    xdeif_NeedleHit( ent, vial, self )
			    xdeif_Cure( ent, vacc, incu )
			end
		
		    self:Deploy()
        end
	end
end

-- Trace code was copied from GMod's fists.lua (https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/weapons/weapon_fists.lua)
function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
	local tr = util.TraceLine( {
		start = owner:GetShootPos(),
		endpos = owner:GetShootPos() + owner:GetAimVector() * self.HitDistance,
		filter = owner,
		mask = MASK_SHOT_HULL
	} )
	if ( !IsValid( tr.Entity ) ) then
		tr = util.TraceHull( {
			start = owner:GetShootPos(),
			endpos = owner:GetShootPos() + owner:GetAimVector() * self.HitDistance,
			filter = owner,
			mins = Vector( -10, -10, -8 ),
			maxs = Vector( 10, 10, 8 ),
			mask = MASK_SHOT_HULL
		} )
	end
	
	if self.Consume == 1 then return end
	SecondaryAttacking = true
	self:SetNextSecondaryFire(CurTime() + AttackTime + 0)
    self:SendWeaponAnim(ACT_VM_HITCENTER)
	
    timer.Create("AttackTimer", 0.3, 1, function()
	    if SERVER then
	        if tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
		        local dmginfo = DamageInfo()
			
                dmginfo:SetDamage(10)
                dmginfo:SetAttacker(self.Owner)
                dmginfo:SetInflictor(self)
                dmginfo:SetDamageType(DMG_CRUSH)
                tr.Entity:TakeDamageInfo(dmginfo)
		    end
	    end        
    end)
	
	timer.Create("AttackCD", AttackTime, 1, function()
        SecondaryAttacking = false
		self.Idle = 0
	    self.Move = 0
	    self.Sprint = 0
    end)
end