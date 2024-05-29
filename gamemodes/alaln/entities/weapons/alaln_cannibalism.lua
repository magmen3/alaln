AddCSLuaFile()
SWEP.Base = "alaln_base"
SWEP.PrintName = "Claws"
SWEP.Category = "Forsakened"
SWEP.Purpose = "Kill and eat other people."
SWEP.Instructions = "LMB/RMB to attack and eat people."
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
SWEP.ViewModelFOV = 70
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
SWEP.HitDistance = 110
SWEP.HitRate = 0.9
SWEP.HitSound = {"physics/flesh/flesh_squishy_impact_hard1.wav", "physics/flesh/flesh_squishy_impact_hard2.wav", "physics/flesh/flesh_squishy_impact_hard3.wav", "physics/flesh/flesh_squishy_impact_hard4.wav"}
SWEP.SwingSound = Sound("npc/fast_zombie/claw_miss2.wav")
SWEP.Droppable = false
if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/alaln_fists")
	function SWEP:CalcViewModelView(ViewModel, OldEyePos, OldEyeAng, EyePos, EyeAng)
		local ply = LocalPlayer()
		if not (IsValid(ply) or ply:Alive()) or ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetNoDraw() then return end
		local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
		local sitvec = Vector(0, 0, ply:KeyDown(IN_DUCK) and 2.5 or 2)
		local eyeang = eye.Ang
		local vm_origin, vm_angles = EyePos + sitvec, eyeang
		return vm_origin, vm_angles
	end

	local color_red = Color(180, 0, 0)
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

SWEP.IconOverride = "editor/npc_maker"
function SWEP:Initialize()
	self:SetHoldType("knife")
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
		local trent = tr.Entity
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
					end
				end
			else
				if SERVER and string.find(trent:GetClass(), "prop_ragdoll") and mattypes[trent:GetMaterialType()] then
					trent:EmitSound(table.Random(self.HitSound), 100, 100)
					if trent:GetMaterial() ~= "models/zombie_fast/fast_zombie_sheet" then
						trent:SetMaterial("models/zombie_fast/fast_zombie_sheet", true)
						trent:SetColor(corpse_clr)
					else
						owner:EmitSound("npc/barnacle/barnacle_gulp" .. math.random(1, 2) .. ".wav", 55, math.random(90, 110))
						if owner:GetAlalnState("hunger") <= 95 then
							owner:AddAlalnState("hunger", trent:GetPhysicsObject():GetMass() * 2)
						elseif owner:GetAlalnState("hunger") >= 95 and owner:Health() < owner:GetMaxHealth() - 10 then
							owner:SetHealth(owner:Health() + trent:GetPhysicsObject():GetMass() * 1.5)
						end

						owner:AddAlalnState("score", math.random(1, 4))
						trent:Remove()
					end
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