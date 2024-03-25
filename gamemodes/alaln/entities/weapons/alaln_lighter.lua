if SERVER then
	AddCSLuaFile()
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
	SWEP.AdminOnly = true
else
	SWEP.PrintName = "Lighter"
	SWEP.Purpose = "It's your trusty lighter. There are many lighters like this in the world, but this is the one that can save your life."
	SWEP.Instructions = "LMB to open/close lighter,\nRMB to ignite prop/entity you're looking at.\n\nThe engraving on the lighter says 'Do not put an open lighter in your pocket!'"
	SWEP.Category = "Forsakened"
	SWEP.Slot = 0
	SWEP.SlotPos = 0
	SWEP.BobScale = -2
	SWEP.SwayScale = -2
	SWEP.DrawAmmo = false
	SWEP.DrawSecondaryAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.ViewModelFOV = 77
	SWEP.IconOverride = "editor/env_firesource"
	function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
		if not IsValid(DrawModel) then
			DrawModel = ClientsideModel(self.WorldModel, RENDER_GROUP_OPAQUE_ENTITY)
			DrawModel:SetNoDraw(true)
		else
			DrawModel:SetModel(self.WorldModel)
			local vec = Vector(25, 25, 25)
			local ang = Vector(-48, -48, -48):Angle()
			cam.Start3D(vec, ang, 20, x, y + 35, wide, tall, 5, 4096)
			cam.IgnoreZ(true)
			render.SuppressEngineLighting(true)
			render.SetLightingOrigin(self:GetPos())
			render.ResetModelLighting(50 / 255, 50 / 255, 50 / 255)
			render.SetColorModulation(1, 1, 1)
			render.SetBlend(255)
			render.SetModelLighting(4, 1, 1, 1)
			DrawModel:SetRenderAngles(Angle(0, RealTime() * 30 % 360, 0))
			DrawModel:DrawModel()
			DrawModel:SetRenderAngles()
			render.SetColorModulation(1, 1, 1)
			render.SetBlend(1)
			render.SuppressEngineLighting(false)
			cam.IgnoreZ(false)
			cam.End3D()
		end

		self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
	end

	-- tried to make viewmodel like in The Forest
	function SWEP:CalcViewModelView(ViewModel, OldEyePos, OldEyeAng, EyePos, EyeAng)
		local ply = LocalPlayer()
		if not (IsValid(ply) or ply:Alive()) or ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetNoDraw() then return end
		local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
		local sitvec = Vector(0, 0, ply:KeyDown(IN_DUCK) and 2.5 or 2)
		local eyeang = eye.Ang
		--eyeang.x = 30 -- i hate nmrih viewmodels
		local vm_origin, vm_angles = EyePos + sitvec, eyeang
		return vm_origin, vm_angles
	end
end

SWEP.Base = "alaln_base"
SWEP.Spawnable = true
SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/tfa_nmrih/v_item_zippo.mdl")
SWEP.WorldModel = Model("models/weapons/tfa_nmrih/w_item_zippo.mdl")
SWEP.HoldType = "slam"
SWEP.IgniteHoldType = "pistol"
SWEP.HoldTypeOff = "normal"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.WorldModelPosition = Vector(3.5, -2, -2)
SWEP.WorldModelAngle = Angle(180)
SWEP.DeathDroppable = false
SWEP.CommandDroppable = false
game.AddParticles("particles/lighter.pcf")
PrecacheParticleSystem("lighter_flame")
function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:Holster(wep)
	local ply = self:GetOwner()
	if not IsValid(ply) or not ply:Alive() then return end
	if IsValid(ply:GetViewModel()) then ply:GetViewModel():StopParticles() end
	-- funnies
	if wep and wep ~= NULL and ply:Alive() and self:IsLit() then
		if math.random(1, 6) == 3 then
			if SERVER then
				ply:Ignite(5, 180)
				BetterChatPrint(ply, "You've done yourself a little trolling.", Color(165, 0, 0))
			end
			return true
		else
			if SERVER then
				BetterChatPrint(ply, "I think it's a bad idea to put an open lighter in your pocket...", Color(255, 170, 0))
			elseif CLIENT then
				surface.PlaySound("common/warning.wav")
			end
			return false
		end
	end

	self:EmitSound("player/weapon_holster_0" .. math.random(1, 5) .. ".wav", 100, 100)
	return true
end

function SWEP:Deploy()
	if not IsValid(self:GetOwner()) or not self:GetOwner():Alive() then return end
	self:EmitSound("player/weapon_draw_0" .. math.random(1, 5) .. ".wav", 100, 100)
	self:SetNWBool("Light", true)
	self:SetHoldType(self.HoldType)
	timer.Simple(self:SequenceDuration() - 0.8, function() if CLIENT and IsValid(self) then ParticleEffectAttach("lighter_flame", PATTACH_POINT_FOLLOW, self:GetOwner():GetViewModel(), 1) end end)
	return true
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:ToggleLighter()
	self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
end

function SWEP:CanPrimaryAttack()
	return self:GetNextPrimaryFire() < CurTime()
end

function SWEP:CanSecondaryAttack()
	return self:CanPrimaryAttack() and not self:GetOwner():IsSprinting()
end

function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() or not self:IsLit() then return end
	local ply = self:GetOwner()
	local pos = ply:EyePos()
	local trace = util.TraceLine({
		start = pos,
		endpos = pos + (ply:GetAimVector() * 128),
		filter = ply
	})

	local allowedmats = {MAT_ANTLION, MAT_BLOODYFLESH, MAT_FLESH, MAT_ALIENFLESH, MAT_FOLIAGE, MAT_GRASS, MAT_WOOD}
	-- ignite props/npcs
	if trace.Hit and IsValid(trace.Entity) and not trace.Entity:IsWorld() and table.HasValue(allowedmats, trace.MatType) and not trace.Entity:IsOnFire() then
		local vm = ply:GetViewModel()
		vm:SendViewModelMatchingSequence(vm:LookupSequence("reach_out_start"))
		self:SetHoldType(self.IgniteHoldType)
		timer.Simple(.5, function()
			if not (IsValid(self) or IsValid(trace.Entity)) then return end
			if not SERVER then return end
			trace.Entity:Ignite(15, 180)
		end)

		timer.Simple(1, function()
			if not IsValid(self) then return end
			vm:SendViewModelMatchingSequence(vm:LookupSequence("reach_out_end"))
			self:SetHoldType(self.HoldType)
		end)

		self:SetNextPrimaryFire(CurTime() + 2)
	end
end

function SWEP:Reload()
	return false
end

function SWEP:ToggleLighter()
	if self:IsLit() then
		-- Put Lighter away
		self:SendWeaponAnim(ACT_VM_HOLSTER)
		self:GetOwner():GetViewModel():StopParticles()
		timer.Simple(self:SequenceDuration() - 0.8, function() if IsValid(self) then self:SetNWBool("Light", false) end end)
		-- hate
		timer.Simple(self:SequenceDuration() - 0.25, function() if IsValid(self) then self:GetOwner():GetViewModel():SetNoDraw(true) end end)
		self:SetHoldType(self.HoldTypeOff)
		self:Holster()
	else
		-- Take Lighter Out
		self:SendWeaponAnim(ACT_VM_DRAW)
		self:SetNWBool("Light", true)
		timer.Simple(self:SequenceDuration(), function() if IsValid(self) then self:SendWeaponAnim(ACT_VM_IDLE) end end)
		self:GetOwner():GetViewModel():SetNoDraw(false)
		self:SetHoldType(self.HoldType)
		self:Deploy()
	end
end

function SWEP:IsLit()
	return self:GetNWBool("Light", true)
end

function SWEP:GetLightColor()
	return 212, 131, 43
end

if CLIENT then
	local NextThink = 0
	function SWEP:Think()
		if not IsValid(self) or CurTime() < NextThink then return end
		local ply = self:GetOwner()
		if self:IsLit() then
			local hand = ply:LookupBone("ValveBiped.Bip01_R_Hand")
			if not hand then return self:GetOwner():EyePos() end
			local pos = ply:GetBonePosition(hand) -- pos, ang
			if ply:GetViewModel() then
				local attach = ply:GetViewModel():GetAttachment(self:LookupAttachment("lighter_fire_point"))
				if attach then
					local lighterPos = attach.Pos
					if lighterPos then
						-- pos lies at the midpoint of the player's eyes and the lighter
						-- in order to light the visible portion of the view model and
						-- to allow for some visual light movement upon holstering
						pos = (lighterPos + pos) / 2
					end
				end
			end

			-- dynamic lights
			local dlight = DynamicLight(self:EntIndex())
			if dlight then
				local r, g, b = self:GetLightColor()
				dlight.pos = pos
				dlight.r = r
				dlight.g = g
				dlight.b = b
				dlight.brightness = 3
				dlight.size = 320
				dlight.decay = 128
				dlight.dietime = CurTime() + .1
				dlight.style = 1
			end
		end

		NextThink = CurTime() + .1
		return true
	end

	function SWEP:ViewModelDrawn()
		if not testvm then PrecacheParticleSystem("lighter_flame") end
	end

	function SWEP:DrawWorldModel()
		local ply = self:GetOwner()
		if IsValid(self.WM) then
			local wm = self.WM
			if IsValid(ply) then
				local offsetVec = self.WorldModelPosition
				local offsetAng = self.WorldModelAngle
				local boneid = ply:LookupBone("ValveBiped.Bip01_R_Hand")
				if not boneid then return end
				local matrix = ply:GetBoneMatrix(boneid)
				if not matrix then return end
				local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
				wm:SetPos(newPos)
				wm:SetAngles(newAng)
				wm:SetupBones()
			else
				wm:SetPos(self:GetPos())
				wm:SetAngles(self:GetAngles())
			end

			wm:DrawModel()
		else
			self.WM = ClientsideModel(self.WorldModel)
			self.WM:SetNoDraw(true)
		end
	end
end

function SWEP:ShouldDropOnDie()
	return false
end