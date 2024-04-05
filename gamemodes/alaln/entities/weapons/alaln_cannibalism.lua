AddCSLuaFile()
SWEP.Base = "alaln_base"
SWEP.PrintName = "Claws"
SWEP.Category = "Forsakened"
SWEP.Purpose = "Kill and eat other people."
SWEP.Instructions = "LMB/RMB to attack and eat people."
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.Spawnable = true
SWEP.ViewModel = Model("models/weapons/v_models/V_demhands.mdl")
SWEP.WorldModel = ""
SWEP.DrawWorldModel = false
SWEP.ViewModelFOV = 65
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Anim = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Damage = math.random(24, 32)
SWEP.DamageType = DMG_SLASH
SWEP.HitDistance = 75
SWEP.HitRate = 1
SWEP.HitSound = {"physics/flesh/flesh_squishy_impact_hard1.wav", "physics/flesh/flesh_squishy_impact_hard2.wav", "physics/flesh/flesh_squishy_impact_hard3.wav", "physics/flesh/flesh_squishy_impact_hard4.wav"}
SWEP.SwingSound = Sound("npc/fast_zombie/claw_miss2.wav")
if CLIENT then SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/alaln_fists") end
SWEP.IconOverride = "halflife/lab1_cmpm3000"
function SWEP:Initialize()
	self:SetHoldType("fist")
end

function SWEP:Deploy()
	local vm = self:GetOwner():GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence("idle"))
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	local vm = owner:GetViewModel()
	if IsValid(vm) then
		if self.Anim == 1 then
			vm:SendViewModelMatchingSequence(vm:LookupSequence("attack1"))
			self.Anim = 0
		else
			vm:SendViewModelMatchingSequence(vm:LookupSequence("attack2"))
			self.Anim = 1
		end
	end

	owner:SetAnimation(PLAYER_ATTACK1)
	self:SetNextPrimaryFire(CurTime() + self.HitRate)
	self:SetNextSecondaryFire(CurTime() + self.HitRate)
	owner:EmitSound(self.SwingSound, 75, 100)
	timer.Simple(0.1, function()
		if not (IsValid(self) or IsValid(owner)) then return end
		self.HitWait(self)
	end)
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end

local corpse_clr = Color(195, 120, 100)
function SWEP.HitWait(self)
	local owner = self:GetOwner()
	local tr = util.TraceHull({
		start = owner:GetShootPos(),
		endpos = owner:GetShootPos() + owner:GetAimVector() * self.HitDistance,
		filter = owner,
		mins = Vector(-5, -5, -5),
		maxs = Vector(5, 5, 5),
		mask = MASK_SHOT_HULL
	})

	if tr.Hit then
		if SERVER and string.find(tr.Entity:GetClass(), "player") then
			tr.Entity:EmitSound(table.Random(self.HitSound), 150, 100)
			if tr.Entity:Health() > self.Damage then
				local dmginfo = DamageInfo()
				dmginfo:SetAttacker(owner)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamage(self.Damage)
				dmginfo:SetDamageType(self.DamageType)
				tr.Entity:TakeDamageInfo(dmginfo)
			else
				local nade = ents.Create("prop_ragdoll")
				nade:SetModel(tr.Entity:GetModel())
				nade:SetPos(tr.Entity:GetPos())
				nade:SetAngles(tr.Entity:EyeAngles())
				tr.Entity:KillSilent()
				nade:Spawn()
			end
		else
			if SERVER and string.find(tr.Entity:GetClass(), "npc") then
				tr.Entity:EmitSound(table.Random(self.HitSound), 75, 100)
				local dmginfo = DamageInfo()
				dmginfo:SetAttacker(owner)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamage(self.Damage)
				dmginfo:SetDamageForce(owner:GetAimVector() * self.Damage)
				dmginfo:SetDamageType(self.DamageType)
				tr.Entity:TakeDamageInfo(dmginfo)
			else
				if SERVER and string.find(tr.Entity:GetClass(), "prop_ragdoll") then
					if tr.Entity:GetMaterialType() == MAT_FLESH then
						tr.Entity:EmitSound(table.Random(self.HitSound), 100, 100)
						if tr.Entity:GetMaterial() ~= "models/zombie_fast/fast_zombie_sheet" then
							tr.Entity:SetMaterial("models/zombie_fast/fast_zombie_sheet", true)
							tr.Entity:SetColor(corpse_clr)
						else
							owner:EmitSound("npc/barnacle/barnacle_gulp" .. math.random(1, 2) .. ".wav", 55, math.random(90, 110))
							owner:AddHunger(tr.Entity:GetPhysicsObject():GetMass() / 2)
							owner:AddScore(math.random(2, 5))
							tr.Entity:Remove()
						end
					end

					if tr.Entity:GetMaterialType() == MAT_ALIENFLESH or tr.Entity:GetMaterialType() == MAT_ANTLION then
						tr.Entity:EmitSound(table.Random(self.HitSound), 75, 100)
						if tr.Entity:GetMaterial() ~= "models/antlion/antlion_innards" then
							tr.Entity:SetMaterial("models/antlion/antlion_innards", true)
							tr.Entity:SetColor(corpse_clr)
						else
							owner:EmitSound("npc/barnacle/barnacle_gulp" .. math.random(1, 2) .. ".wav", 55, math.random(90, 110))
							owner:AddHunger(tr.Entity:GetPhysicsObject():GetMass() / 2)
							owner:AddScore(math.random(3, 6))
							tr.Entity:Remove()
						end
					end
				end
			end
		end
	end
end

function SWEP:OnDrop()
	self:Remove() -- You can't drop fists
end

function SWEP:Reload()
end