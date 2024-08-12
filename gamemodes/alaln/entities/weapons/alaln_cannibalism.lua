AddCSLuaFile()
SWEP.Base = "alaln_base"
SWEP.PrintName = "Claws"
SWEP.Category = "! Forsakened"
SWEP.Purpose = "Kill and eat other people with your bare hands."
SWEP.Instructions = "LMB/RMB to attack and eat people/corpses."
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.BobScale = -2
SWEP.SwayScale = -2
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Spawnable = true
SWEP.ViewModel = Model("models/weapons/v_models/v_demhands.mdl")
SWEP.WorldModel = ""
SWEP.DrawWorldModel = false
SWEP.ViewModelPositionOffset = Vector(-12, -1, 1)
SWEP.ViewModelAngleOffset = Angle(-1, 0, 0)
SWEP.ViewModelFOV = 120
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Anim = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Damage = math.random(24, 32)
SWEP.DamageType = DMG_SLASH
SWEP.ReachDistance = 100
SWEP.HitRate = 0.45
SWEP.HitSound = {"physics/flesh/flesh_squishy_impact_hard1.wav", "physics/flesh/flesh_squishy_impact_hard2.wav", "physics/flesh/flesh_squishy_impact_hard3.wav", "physics/flesh/flesh_squishy_impact_hard4.wav"}
SWEP.SwingSound = Sound("npc/fast_zombie/claw_miss2.wav")
SWEP.Droppable = false
SWEP.IconOverride = "editor/obsolete"
if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/alaln_fists")
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
		--ang.pitch = -ang.pitch
		ang:RotateAroundAxis(ang:Forward(), self.ViewModelAngleOffset.pitch)
		ang:RotateAroundAxis(ang:Right(), self.ViewModelAngleOffset.roll)
		ang:RotateAroundAxis(ang:Up(), self.ViewModelAngleOffset.yaw)
		return pos + angs:Forward() * forward + angs:Right() * right + angs:Up() * up, ang
	end

	local color_red = Color(185, 15, 15)
	function SWEP:DrawHUD()
		local owner = self:GetOwner()
		local tr = {}
		tr.start = owner:GetShootPos()
		local dir = Vector(1, 0, 0)
		dir:Rotate(owner:EyeAngles())
		tr.endpos = tr.start + dir * 500
		tr.filter = owner
		local traceResult = util.TraceLine(tr)
		local hitEnt = IsValid(traceResult.Entity) and traceResult.Entity:IsNPC() and color_red or color_white
		local frac = traceResult.Fraction
		local alpha = -(frac * 255 - 255) / 2
		surface.SetDrawColor(hitEnt.r, hitEnt.g, hitEnt.b, alpha)
		draw.NoTexture()
		Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, math.min(10, 6 / frac), 3)
	end
end

function SWEP:Initialize()
	self:SetHoldType("alaln_knife")
end

function SWEP:Deploy()
	local vm = self:GetOwner():GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence("idle"))
end

function SWEP:PrimaryAttack()
	--if self:GetOwner():IsSprinting() then return end
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

	if owner:OnGround() then
		owner:SetVelocity(owner:GetAimVector() * 150)
	else
		owner:SetVelocity(owner:GetAimVector() * 50)
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

local corpse_clr = Color(190, 165, 125)
local mattypes = {
	[MAT_FLESH] = true,
	[MAT_ALIENFLESH] = true,
	[MAT_ANTLION] = true
}

local color_red = Color(185, 15, 15)
local fleshmat = "models/zombie_fast/fast_zombie_sheet"
function SWEP:HitEffect()
	local owner = self:GetOwner()
	local tr2 = util.QuickTrace(owner:GetShootPos(), owner:GetAimVector() * self.ReachDistance, {owner})
	local pos1 = tr2.HitPos + tr2.HitNormal
	local pos2 = tr2.HitPos - tr2.HitNormal
	util.Decal("Blood", pos1, pos2)
	local vPoint = tr2.HitPos
	local effectdata = EffectData()
	effectdata:SetOrigin(vPoint)
	util.Effect("BloodImpact", effectdata)
end

function SWEP.HitWait(self)
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local tr = util.TraceHull({
		start = owner:GetShootPos(),
		endpos = owner:GetShootPos() + owner:GetAimVector() * self.ReachDistance,
		filter = owner,
		mins = Vector(-5, -5, -5),
		maxs = Vector(5, 5, 5),
		mask = MASK_SHOT_HULL
	})

	if tr.Hit then
		local trent = tr.Entity
		if SERVER and not IsValid(trent) then self:EmitSound("Flesh.ImpactHard", 55, math.random(90, 110)) end
		if SERVER and string.find(trent:GetClass(), "player") then
			trent:EmitSound(table.Random(self.HitSound), 150, 100)
			if trent:Health() > self.Damage then
				local dmginfo = DamageInfo()
				dmginfo:SetAttacker(owner)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamage(self.Damage)
				dmginfo:SetDamageType(self.DamageType)
				trent:TakeDamageInfo(dmginfo)
			else
				local nade = ents.Create("prop_ragdoll")
				nade:SetModel(trent:GetModel())
				nade:SetPos(trent:GetPos())
				nade:SetAngles(trent:EyeAngles())
				trent:KillSilent()
				nade:Spawn()
			end

			self:HitEffect()
		else
			if SERVER and string.find(trent:GetClass(), "npc") then
				trent:EmitSound(table.Random(self.HitSound), 75, 100)
				local dmginfo = DamageInfo()
				dmginfo:SetAttacker(owner)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamage(self.Damage)
				dmginfo:SetDamageForce(owner:GetAimVector() * self.Damage)
				dmginfo:SetDamageType(self.DamageType)
				trent:TakeDamageInfo(dmginfo)
				if trent:Health() <= trent:GetMaxHealth() / 2 then
					if owner:GetAlalnState("hunger") <= 80 then
						owner:AddAlalnState("hunger", math.random(1, 10))
					elseif owner:GetAlalnState("hunger") >= 80 and owner:Health() < owner:GetMaxHealth() - 10 then
						owner:SetHealth(owner:Health() + math.random(1, 5))
						self:SetNextPrimaryFire(CurTime() + self.HitRate * 1.15)
						self:SetNextSecondaryFire(CurTime() + self.HitRate * 1.15)
					end

					owner:AddAlalnState("crazyness", -math.random(1, 5))
				end

				self:HitEffect()
			else
				if SERVER and string.find(trent:GetClass(), "prop_ragdoll") and mattypes[trent:GetMaterialType()] then
					trent:EmitSound(table.Random(self.HitSound), 100, 100)
					if trent:GetMaterial() ~= fleshmat then
						trent:SetMaterial(fleshmat, true)
						trent:SetColor(corpse_clr)
						self:SetNextPrimaryFire(CurTime() + self.HitRate * 2.5)
						self:SetNextSecondaryFire(CurTime() + self.HitRate * 2.5)
					else
						owner:EmitSound("npc/barnacle/barnacle_gulp" .. math.random(1, 2) .. ".wav", 55, math.random(90, 110))
						if owner:GetAlalnState("hunger") <= 95 then
							owner:AddAlalnState("hunger", trent:GetPhysicsObject():GetMass() * 2)
						elseif owner:GetAlalnState("hunger") >= 95 and owner:Health() < owner:GetMaxHealth() + 10 then
							owner:SetHealth(owner:Health() + trent:GetPhysicsObject():GetMass() * 1.5)
						end

						self:SetNextPrimaryFire(CurTime() + self.HitRate * 2.2)
						self:SetNextSecondaryFire(CurTime() + self.HitRate * 2.2)
						owner:AddAlalnState("score", math.random(1, 4))
						owner:AddAlalnState("crazyness", -math.random(1, 5))
						trent:Remove()
						if math.random(2, 6) == 4 then BetterChatPrint(owner, "You feel satisfied.", color_red) end
					end

					self:HitEffect()
				end
			end
		end
	end
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:Reload()
end