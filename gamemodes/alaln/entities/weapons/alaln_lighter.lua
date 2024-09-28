AddCSLuaFile()
if SERVER then
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
	SWEP.AdminOnly = true
else
	SWEP.PrintName = "Lighter"
	SWEP.Purpose = "It's your trusty lighter. There are many lighters like this in the world, but this is the one that can save your life."
	SWEP.Instructions = "LMB to open/close lighter,\nRMB to ignite prop/entity you're looking at.\n\nThe engraving on the lighter says 'Do not put an open lighter in your pocket!'"
	SWEP.Category = "! Forsakened"
	SWEP.Slot = 0
	SWEP.SlotPos = 0
	SWEP.BobScale = -2
	SWEP.SwayScale = -2
	SWEP.DrawAmmo = false
	SWEP.DrawSecondaryAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.ViewModelPositionOffset = Vector(-10, 0, 0)
	SWEP.ViewModelAngleOffset = Angle(0, 0, 0)
	SWEP.ViewModelFOV = 120
	SWEP.IconOverride = "editor/env_firesource"
	function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
		--if not PotatoMode:GetBool() then
		if not IsValid(DrawModel) then
			DrawModel = ClientsideModel(self.WorldModel, RENDER_GROUP_OPAQUE_ENTITY)
			DrawModel:SetNoDraw(true)
		else
			DrawModel:SetModel(self.WorldModel)
			local vec = Vector(24, 24, 24)
			local ang = Vector(-24, -24, -24):Angle()
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

		--end
		self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
	end

	-- Tried to make viewmodel like in The Forest
	--[[function SWEP:CalcViewModelView(ViewModel, OldEyePos, OldEyeAng, EyePos, EyeAng)
		local ply = LocalPlayer()
		if not (IsValid(ply) or ply:Alive()) or ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetNoDraw() then return pos, ang end
		local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
		local sitvec = Vector(0, 0, ply:KeyDown(IN_DUCK) and 2.5 or 2)
		local eyeang = eye.Ang
		--eyeang.x = 30 -- I hate nmrih viewmodels
		local vm_origin, vm_angles = EyePos + sitvec, eyeang
		return vm_origin, vm_angles
	end]]
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
SWEP.Droppable = false
SWEP.HolsterTries = 0
SWEP.HolsterCD = 0
game.AddParticles("particles/lighter.pcf")
PrecacheParticleSystem("lighter_flame")
function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

local randholstrings = {"I think it's a bad idea to put an open lighter in your pocket...", "Did you read the engraving?", "I should probably close it before put it in pocket..."}
local randfirestrings = {"You've done yourself a little trolling.", "Seems like you should have been more careful to this thing."}
local color_red = Color(185, 15, 15)
local color_yellow = Color(210, 210, 110)
function SWEP:Holster(wep)
	local ply = self:GetOwner()
	if not IsValid(ply) or not ply:Alive() then return end
	if IsValid(ply:GetViewModel()) then ply:GetViewModel():StopParticles() end
	-- Funnies
	if wep and wep ~= NULL and ply:Alive() and self:IsLit() and self.HolsterCD < CurTime() then
		if ply:WaterLevel() >= 2 then return true end
		if math.random(1, 6) == 3 and self.HolsterTries > 1 then
			if SERVER then
				ply:Ignite(3, 140)
				BetterChatPrint(ply, table.Random(randfirestrings), color_red)
			end
			return true
		else
			if SERVER then
				BetterChatPrint(ply, table.Random(randholstrings), color_yellow)
			elseif CLIENT and ply == LocalPlayer() then
				surface.PlaySound(Sound("common/warning.wav"))
			end
			return false
		end

		self.HolsterTries = self.HolsterTries + 1
		self.HolsterCD = CurTime() + 1
	end

	self:EmitSound("player/weapon_holster_0" .. math.random(1, 5) .. ".wav")
	return true
end

function SWEP:Deploy()
	local ply = self:GetOwner()
	if not IsValid(ply) or not ply:Alive() then return end
	if ply:WaterLevel() >= 2 then return end
	self:EmitSound("player/weapon_draw_0" .. math.random(1, 5) .. ".wav", 60)
	self:SetNWBool("Light", true)
	self:SetHoldType(self.HoldType)
	timer.Simple(0.6, function() if CLIENT and IsValid(self) and IsValid(ply:GetViewModel()) then ParticleEffectAttach("lighter_flame", PATTACH_POINT_FOLLOW, ply:GetViewModel(), 1) end end)
	return true
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	if self:GetOwner():WaterLevel() >= 2 then return end
	self:ToggleLighter()
	self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
end

function SWEP:CanPrimaryAttack()
	return self:GetNextPrimaryFire() < CurTime()
end

function SWEP:CanSecondaryAttack()
	return self:CanPrimaryAttack() and not self:GetOwner():IsSprinting()
end

local allowedmats = {MAT_ANTLION, MAT_BLOODYFLESH, MAT_FLESH, MAT_ALIENFLESH, MAT_FOLIAGE, MAT_GRASS, MAT_WOOD, MAT_CARDBOARD, MAT_PAPER}
function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() or not self:IsLit() then return end
	local ply = self:GetOwner()
	if ply:WaterLevel() >= 2 then return end
	local pos = ply:EyePos()
	local trace = util.TraceLine({
		start = pos,
		endpos = pos + (ply:GetAimVector() * 128),
		filter = ply
	})

	-- ignite props/npcs
	if trace.Hit and IsValid(trace.Entity) and not trace.Entity:IsWorld() and table.HasValue(allowedmats, trace.MatType) and not trace.Entity:IsOnFire() and trace.Entity:WaterLevel() < 1 then -- table.HasValue(allowedmats, trace.MatType)
		local vm = ply:GetViewModel()
		if IsValid(vm) then vm:SendViewModelMatchingSequence(vm:LookupSequence("reach_out_start")) end
		self:SetHoldType(self.IgniteHoldType)
		timer.Simple(.5, function()
			if not (IsValid(self) or IsValid(trace.Entity)) then return end
			if not SERVER then return end
			if trace.Entity:IsNPC() then ply:AddAlalnState("score", math.random(1, 4)) end
			trace.Entity:Ignite(5, 140)
		end)

		timer.Simple(1, function()
			if not IsValid(self) or not IsValid(vm) then return end
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
	local owner = self:GetOwner()
	local vm = owner:GetViewModel()
	if not IsValid(owner) or not IsValid(vm) then -- I HATE THIS FUCKIGN SHITJFASFDFSDAFASDFASD
		return
	end

	if self:IsLit() then
		-- Put Lighter away
		self:SendWeaponAnim(ACT_VM_HOLSTER)
		vm:StopParticles()
		timer.Simple(0.8, function() if IsValid(self) then self:SetNWBool("Light", false) end end)
		timer.Simple(0.4, function() if IsValid(self) and IsValid(vm) and self:GetNWBool("Light", false) == true then vm:SetNoDraw(true) end end)
		self:SetHoldType(self.HoldTypeOff)
		self:Holster()
	else
		if owner:WaterLevel() >= 2 then return end
		-- Take Lighter Out
		self:SendWeaponAnim(ACT_VM_DRAW)
		self:SetNWBool("Light", true)
		timer.Simple(self:SequenceDuration(), function() if IsValid(self) then self:SendWeaponAnim(ACT_VM_IDLE) end end)
		if IsValid(self) and IsValid(vm) and self:GetNWBool("Light", false) == true then vm:SetNoDraw(false) end
		self:SetHoldType(self.HoldType)
		self:Deploy()
	end
end

function SWEP:IsLit()
	return self:GetNWBool("Light", true)
end

if CLIENT then
	local NextThink = 0
	local r, g, b = 212, 131, 43
	function SWEP:Think()
		if not IsValid(self) or CurTime() < NextThink then return end
		local ply = self:GetOwner()
		if self:IsLit() then
			if ply:WaterLevel() >= 2 then return end
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
				dlight.pos = pos
				dlight.r = r
				dlight.g = g
				dlight.b = b
				dlight.brightness = 2
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