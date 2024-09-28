local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, net = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, net
if SERVER then
	AddCSLuaFile()
else
	SWEP.IconOverride = "editor/env_fire"
	SWEP.ViewModelPositionOffset = Vector(-22, -7, -12)
	SWEP.ViewModelAngleOffset = Angle(5, 0, 0)
	SWEP.DrawCrosshair = false
	SWEP.DrawAmmo = false
	SWEP.ViewModelFOV = 110
	SWEP.BobScale = -2
	SWEP.SwayScale = -2
	language.Add("hydrogen_peroxide", "Hydrogen Peroxide")
	language.Add("hydrogen_peroxide_ammo", "Hydrogen Peroxide")
	local color_red = Color(185, 15, 15)
	function SWEP:DrawHUD()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end
		local Wep = owner:GetActiveWeapon()
		if IsValid(Wep) then
			local tr = {}
			tr.start = owner:GetShootPos()
			local dir = Vector(1, 0, 0)
			dir:Rotate(owner:EyeAngles())
			tr.endpos = tr.start + dir * 500
			tr.filter = owner
			local traceResult = util.TraceLine(tr)
			local hitEnt = IsValid(traceResult.Entity) and traceResult.Entity:IsNPC() and color_red or color_white
			local frac = traceResult.Fraction
			surface.SetDrawColor(hitEnt)
			draw.NoTexture()
			Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, math.min(20, 5 / frac), 3)
		end
	end

	function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
		--if not PotatoMode:GetBool() then
		if not IsValid(DrawModel) then
			DrawModel = ClientsideModel(self.WorldModel, RENDER_GROUP_OPAQUE_ENTITY)
			DrawModel:SetNoDraw(true)
		else
			DrawModel:SetModel(self.WorldModel)
			local vec = Vector(55, 55, 55)
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

		--end
		self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
	end

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

SWEP.PrintName = "Flamethrower"
SWEP.Category = "! Forsakened"
SWEP.Purpose = "Burn those half-dead bastards to the ground."
SWEP.Instructions = "LMB to fire, \n R to inspect."
SWEP.Spawnable = true
SWEP.ViewModel = "models/weapons/last_year/c_flamethrower.mdl"
SWEP.WorldModel = "models/weapons/w_flamethr0wer.mdl"
SWEP.Slot = 3
SWEP.UseHands = true
SWEP.HoldType = "shotgun"
SWEP.FiresUnderwater = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = math.random(65, 85)
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "hydrogen_peroxide"
SWEP.Primary.Damage = 45
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.1
SWEP.Primary.Force = 7
SWEP.Primary.Delay = 0.09
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1
SWEP.ShootLife = 4
SWEP.ShootFeed = 0.5
function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Shooting")
end

function SWEP:Initialize()
	self.Primary.DefaultClip = math.random(65, 85)
	self:SetHoldType(self.HoldType)
	self:SetWeaponHoldType(self.HoldType)
	if SERVER then
		self.Hit = false
		self:SetShooting(false)
	end
end

function SWEP:GetShootPosition()
	local pos
	local ang
	if CLIENT then -- We're drawing the view model
		if LocalPlayer() == self:GetOwner() and GetViewEntity() == LocalPlayer() then
			local vm = LocalPlayer():GetViewModel()
			pos, ang = vm:GetAttachment(vm:LookupAttachment(1)).Pos, vm:GetAttachment(vm:LookupAttachment(1)).Ang
			pos = pos + ang:Forward() + ang:Right() + ang:Up()
		else -- We're drawing the world model
			local ply = self:GetOwner()
			if not self.hand then self.hand = ply:LookupAttachment("anim_attachment_rh") end
			local handData = ply:GetAttachment(self.hand)
			if not IsValid(handData) then return end
			ang = handData.Ang
			pos = handData.Pos + ang:Forward() * 28 + ang:Right() * 0.3 + ang:Up() * 4.5
		end
	end

	if SERVER then
		pos = self:GetOwner():GetShootPos()
		ang = self:GetOwner():EyeAngles()
		pos = pos + ang:Forward() * 1 + ang:Right() * 8 + ang:Up() * 5
	end
	return pos
end

function SWEP:Deploy()
	self:GetOwner():DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_PLACE)
	self:SendWeaponAnim(ACT_VM_DRAW)
	--self:EmitSound("sbible/Chamber_Decompressing-SoundBible.wav", 75, math.random(80, 120)) -- weapons/flamer/deploy2.wav
	self:EmitSound("weapons/smod_flamethrower/snd_jack_warmineprepare.wav", 65, math.random(80, 120))
	self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
	self:NextThink(CurTime() + self:SequenceDuration())
	self.Hiss = CreateSound(self:GetOwner(), Sound("weapons/smod_flamethrower/idle.wav")) -- forsakened/imgonnaflameyourass.mp3
	return true
end

function SWEP:Reload()
	if not self:CanPrimaryAttack() then return end
	self:GetOwner():DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_PLACE)
	self:SendWeaponAnim(ACT_VM_RELOAD)
	if self:Ammo1() > 0 and self:GetOwner():WaterLevel() < 2 and CLIENT and self:GetOwner() == LocalPlayer() then
		surface.PlaySound("forsakened/imgonnaflameyourass.mp3")
		--self:EmitSound("forsakened/imgonnaflameyourass.mp3", 65, 100)
	end

	self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
	self:NextThink(CurTime() + self:SequenceDuration())
	timer.Simple(self:SequenceDuration(), function() if IsValid(self) and IsValid(self:GetOwner()) then self:SendWeaponAnim(ACT_VM_DRAW) end end)
	self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if self:Ammo1() <= 0 or self:GetOwner():WaterLevel() >= 2 then
		self:SetShooting(false)
		self:EmitSound("weapons/smod_flamethrower/empty.wav")
		self:SetNextPrimaryFire(CurTime() + 0.6)
		return
	end

	if not self:CanPrimaryAttack() then return end
	if not self:GetShooting() then
		self:SetShooting(true)
		local effectdata = EffectData()
		effectdata:SetEntity(self)
		util.Effect("flamer_jet", effectdata)
	end

	if SERVER then
		local forwardBoost = math.Rand(20, 40)
		local frac = self:GetOwner():GetEyeTrace().Fraction
		if frac < 0.001245 then forwardBoost = 1 end
		local forward = self:GetOwner():EyeAngles():Forward()
		local pos = self:GetShootPosition() + forward * forwardBoost
		local vel = forward * math.Rand(300, 380)
		local tracehull = {}
		tracehull.start = pos
		tracehull.endpos = pos + vel
		tracehull.filter = self:GetOwner()
		--tracehull.ignoreworld = true
		tracehull.mins = Vector(-8, -8, -8)
		tracehull.maxs = Vector(8, 8, 8)
		tracehull.mask = MASK_SHOT
		local trhull = util.TraceHull(tracehull)
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker(self:GetOwner())
		dmginfo:SetInflictor(self)
		dmginfo:SetDamageForce(self:GetOwner():GetAimVector() * 1000)
		dmginfo:SetDamagePosition(self:GetOwner():GetShootPos())
		if math.random(1, 150) == 149 then self:Ignite(3) end
		if trhull.Hit then
			if IsValid(trhull.Entity) then
				local phys = trhull.Entity:GetPhysicsObject()
				if IsValid(phys) then phys:SetVelocity(vel / 2) end
				dmginfo:SetDamage(trhull.Entity:Health() / 200 + math.random(5, 15))
				local g = math.random(1, 3)
				if g == 1 then
					dmginfo:SetDamageType(DMG_SLOWBURN)
				elseif g == 2 then
					dmginfo:SetDamageType(DMG_BLAST)
				elseif g == 3 then
					dmginfo:SetDamageType(DMG_BURN)
					trhull.Entity:Ignite(4)
				end

				trhull.Entity:TakeDamageInfo(dmginfo)
			else
				for k, v in pairs(ents.FindAlongRay(self:GetOwner():GetShootPos(), trhull.HitPos + self:GetOwner():GetAimVector() * 32, Vector(-16, -16, -16), Vector(16, 16, 16))) do
					if IsValid(v) and v ~= self:GetOwner() and not v:IsWeapon() then
						dmginfo:SetDamage(v:Health() / 100 + math.random(5, 15))
						local g = math.random(1, 3)
						if g == 1 then
							dmginfo:SetDamageType(DMG_SLOWBURN)
						elseif g == 2 then
							dmginfo:SetDamageType(DMG_BLAST)
						elseif g == 3 then
							dmginfo:SetDamageType(DMG_BURN)
							if math.random() < 0.5 then v:Ignite(4) end
						end
						--util.BlastDamageInfo(dmginfo,trhull.HitPos,16)
					end
				end
			end
		end

		if self:GetOwner():KeyPressed(IN_ATTACK) or not self.Sound then
			self:SendWeaponAnim(ACT_VM_RECOIL2)
			self.Sound = CreateSound(self:GetOwner(), Sound("weapons/smod_flamethrower/fireloop.wav"))
		end

		if self:Ammo1() > 0 then if self.Sound then self.Sound:PlayEx(0.5, math.random(80, 110)) end end
	end

	self:TakePrimaryAmmo(1)
	self:GetOwner():BetterViewPunch(AngleRand(-5, 5))
	if self:GetOwner():OnGround() then self:GetOwner():SetVelocity(self:GetOwner():GetAimVector() * -25) end
	self:ShootEffects()
	if SERVER and vFireInstalled then
		local life = math.Rand(4, 8) * self.ShootLife
		local owner = self:GetOwner()
		-- Determine how far forward we should spawn the fireball (we wish to extend it by default for animation purposes)
		local forwardBoost = math.Rand(20, 40)
		local frac = owner:GetEyeTrace().Fraction
		-- We're looking into an obstacle, spawn the fireball exactly on the barrel
		if frac < 0.001245 then forwardBoost = 1 end
		local forward = self:GetOwner():EyeAngles():Forward()
		local pos = self:GetShootPosition() + forward * forwardBoost
		local vel = forward * math.Rand(900, 1000)
		local feedCarry = math.Rand(3, 8) * self.ShootFeed
		CreateVFireBall(life, feedCarry, pos, vel, owner)
	end
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:PlayCloseSound()
	self:EmitSound("weapons/smod_flamethrower/off.wav", 75, math.random(90, 110)) -- weapons/flamer/close2.wav
	if SERVER then self:GetOwner():EmitSound("weapons/smod_flamethrower/close.wav", 75, math.random(90, 110)) end
end

function SWEP:Think()
	if not self:CanPrimaryAttack() then return end
	if SERVER then if self:Ammo1() > 0 then if self.Hiss then self.Hiss:PlayEx(0.1, math.random(80, 110)) end end end
	if self.Hiss and self.Hiss:IsPlaying() and self:Ammo1() < 1 then self.Hiss:Stop() end
	if self.Sound and self.Sound:IsPlaying() and self:Ammo1() < 1 then
		self.Sound:Stop()
		self:SetShooting(false)
		self:PlayCloseSound()
	end

	if self:GetOwner():KeyReleased(IN_ATTACK) or (not self:GetOwner():KeyDown(IN_ATTACK) and self.Sound) then
		if self.Sound then
			self:SendWeaponAnim(ACT_VM_RECOIL3)
			self.Sound:Stop()
			self.Sound = nil
			if self:Ammo1() > 0 then
				self:PlayCloseSound()
				if not game.SinglePlayer() then self:CallOnClient("PlayCloseSound", "") end
			end
		end

		self:SetShooting(false)
		self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
	end
end

function SWEP:CanPrimaryAttack()
	if self.Hit == true then return false end
	if (self:Clip1() <= 0) and self.Primary.ClipSize > -1 then
		self:SetNextPrimaryFire(CurTime() + 0.5)
		self:EmitSound("Weapons/smod_flamethrower/empty.wav")
		return false
	end
	return true
end

function SWEP:OnDrop()
	self:Holster()
end

function SWEP:OnRemove()
	self:Holster()
end

function SWEP:Holster()
	if self.Hit == true then return false end
	self:SetShooting(false)
	if self.Sound then
		self.Sound:Stop()
		self.Sound = nil
	end

	if self.Hiss then
		self.Hiss:Stop()
		self.Hiss = nil
	end

	if IsValid(self) then self:EmitSound("weapons/smod_flamethrower/undeploy.wav", 65, math.random(90, 110)) end
	if CLIENT then
		local lply = LocalPlayer()
		if self:GetOwner() == lply then
			for i = 0, 2 do
				if not IsValid(lply) then return end
				lply:StopSound("forsakened/imgonnaflameyourass.mp3")
			end
		end
	end
	return true
end

function SWEP:DoBoom(attacker, time)
	if self.Hit ~= true then
		self.Hit = true
		self:Ignite(time + 1)
		self:GetOwner():EmitSound("weapons/smod_flamethrower/FS_MAGNETIC_NORMAL" .. math.random(1, 3) .. ".wav")
		self:GetOwner():EmitSound("physics/metal/metal_sheet_impact_bullet1.wav", 75, math.random(95, 105))
		self:GetOwner():EmitSound("ambient/fire/ignite.wav")
		self:GetOwner():EmitSound("ambient/fire/mtov_flame2.wav")
		self:GetOwner():Ignite(time + 1)
		if self.Sound then
			self.Sound:Stop()
			self.Sound = nil
		end

		if self.Hiss then
			self.Hiss:Stop()
			self.Hiss = nil
		end
	end

	local gun = self
	timer.Simple(time, function()
		if IsValid(gun) then
			local blastpos = self:GetOwner():GetPos() + Vector(0, 0, 32)
			local dmginfo2 = DamageInfo()
			if not IsValid(attacker) then
				dmginfo2:SetAttacker(gun)
			else
				dmginfo2:SetAttacker(attacker)
			end

			dmginfo2:SetInflictor(gun)
			dmginfo2:SetDamage(150)
			dmginfo2:SetDamageType(DMG_BLAST)
			util.BlastDamageInfo(dmginfo2, blastpos, 256)
			local exp = ents.Create("env_explosion")
			exp:SetPos(gun.Owner:GetPos())
			exp:SetKeyValue("iMagnitude", "0")
			exp:Spawn()
			exp:Activate()
			exp:Fire("Explode", 0, 0)
			exp:Fire("Remove", 0, 0.2)
			for i = 0, 2 do
				local sparks = ents.Create("spark_shower")
				sparks:SetPos(gun.Owner:GetPos())
				sparks:SetAngles(Angle(0, math.random(0, 10) * 36, 0))
				sparks:Spawn()
				sparks:Activate()
			end

			self:Remove()
		end
	end)
end

hook_Add("DoPlayerDeath", "alaln-flamersnd", function(v, a, dmg)
	if IsValid(v) then
		if IsValid(v:GetActiveWeapon()) then
			local gun = v:GetActiveWeapon()
			if gun:GetClass() == "alaln_flamethrower" then
				if gun.Sound then
					gun.Sound:Stop()
					gun.Sound = nil
				end

				if gun.Hiss then
					gun.Hiss:Stop()
					gun.Hiss = nil
				end
			end
		end
	end
end)

if SERVER then
	hook_Add("EntityTakeDamage", "alaln-flamer_mg", function(target, dmg)
		if target:IsPlayer() then
			if IsValid(target:GetActiveWeapon()) and target:GetActiveWeapon():GetClass() == "alaln_flamethrower" then
				if IsValid(dmg:GetAttacker()) and dmg:GetAttacker() ~= target then
					local wep = target:GetActiveWeapon()
					local TrueVec = (target:GetPos() - dmg:GetAttacker():GetPos()):GetNormalized()
					local LookVec = target:GetAimVector()
					local DotProduct = LookVec:DotProduct(TrueVec)
					local ApproachAngle = math.deg(math.asin(DotProduct)) + 10
					if ApproachAngle > 50 and math.random() < 0.5 then
						if wep.Hit ~= true and wep:Ammo1() > 19 then
							wep:DoBoom(dmg:GetAttacker(), 2)
							target:PrintMessage(HUD_PRINTTALK, "Your tank was hit!")
						end
					end
				end
			end
		end
	end)
else -- client
	local function bezier(p0, p1, p2, p3, t)
		local e = p0 + t * (p1 - p0)
		local f = p1 + t * (p2 - p1)
		local g = p2 + t * (p3 - p2)
		local h = e + t * (f - e)
		local i = f + t * (g - f)
		local p = h + t * (i - h)
		return p
	end

	local cable = Material("cable/egon_hose")
	local WorldModel = ClientsideModel(SWEP.WorldModel)
	--WorldModel:SetSkin(1)
	WorldModel:SetNoDraw(true)
	function SWEP:DrawWorldModel()
		--self:Drawspiral()
		--self:DrawModel()
		local _Owner = self:GetOwner()
		local ownervalid = IsValid(_Owner)
		if ownervalid then
			-- Specify a good position
			local offsetVec = Vector(22, 0, 0)
			local offsetAng = Angle(180, 90, 0)
			local boneid = _Owner:LookupBone("ValveBiped.Bip01_R_Hand") -- Right Hand
			if not boneid then return end
			local matrix = _Owner:GetBoneMatrix(boneid)
			if not matrix then return end
			local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
			WorldModel:SetPos(newPos)
			WorldModel:SetAngles(newAng)
			WorldModel:SetupBones()
			if LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 35000 then
				local bonepos, boneang = _Owner:GetBonePosition(_Owner:LookupBone("ValveBiped.Bip01_Spine1"))
				local pos = self:LocalToWorld(Vector(00, 0, 45))
				local ang = self:LocalToWorldAngles(Angle(0, 90, 90))
				--local startPos = self:LocalToWorld( Vector(-8,-3.77,10.48) )
				local startPos = bonepos + boneang:Forward() * 4 + boneang:Right() * -1 + boneang:Up() * -9
				local p2 = self:LocalToWorld(Vector(-8, -17.77, -10))
				local p3 = self:LocalToWorld(Vector(0, -20, 20))
				local endPos = self:LocalToWorld(Vector(0.06, -20.3, 37))
				local id = _Owner:LookupAttachment("anim_attachment_rh")
				local attachment = _Owner:GetAttachment(id)
				if not attachment then return end
				endPos = attachment.Pos + attachment.Ang:Forward() * -6 + attachment.Ang:Right() * 1.7 + attachment.Ang:Up() * -3.5
				p3 = endPos + attachment.Ang:Right() * 0 + attachment.Ang:Up() * 0
				for i = 1, 10 do
					local de = ownervalid and 1 or 2
					if (not ownervalid and i > 1) or ownervalid then
						local sp = bezier(startPos, p2, p3, endPos, (i - de) / 10)
						local ep = bezier(startPos, p2, p3, endPos, i / 10)
						render.SetMaterial(cable)
						render.DrawBeam(sp, ep, 2, 1, 2, Color(100, 100, 100, 255))
					end
				end
			end
		else
			WorldModel:SetPos(self:GetPos())
			WorldModel:SetAngles(self:GetAngles())
		end

		WorldModel:DrawModel()
	end

	hook_Add("PostPlayerDraw", "SMOD_Flamer_Pack_Draw", function(ply)
		local wep = ply:GetWeapon("alaln_flamethrower")
		if not IsValid(wep) or not wep == ply:GetActiveWeapon() then return end
		if ply:GetActiveWeapon():IsValid() then
			if ply:GetActiveWeapon():GetClass() == "alaln_flamethrower" then
				if not IsValid(ply.EgonPackModel) then ply.EgonPackModel = ClientsideModel("models/weapons/w_fire_pack.mdl", RENDERGROUP_BOTH) end
				if not IsValid(ply.EgonPackModel) then -- We are still invalid, bail
					return
				end

				ply.EgonPackModel:SetNoDraw(true)
				ply.EgonPackModel:SetModel("models/weapons/w_fire_pack.mdl")
				local pos, ang = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Spine1"))
				ang:RotateAroundAxis(ang:Up(), 180)
				ang:RotateAroundAxis(ang:Forward(), -120)
				ang:RotateAroundAxis(ang:Right(), 90)
				local len = ply:GetVelocity():Length()
				if ply:GetVelocity():Distance(ply:GetForward() * len) < ply:GetVelocity():Distance(ply:GetForward() * -len) then
					ang:RotateAroundAxis(ang:Right(), math.min(ply:GetVelocity():Length() / 8, 55) - 5) -- Forward
				else
					ang:RotateAroundAxis(ang:Right(), -math.min(ply:GetVelocity():Length() / 8, 55) + 5)
				end

				if ply:GetVelocity():Distance(ply:GetRight() * len) < ply:GetVelocity():Distance(ply:GetRight() * -len) then
					--ang:RotateAroundAxis( ang:Right(), math.min( ply:GetVelocity():Length() / 8, 55 ) - 5 ) -- Right
				else
					ang:RotateAroundAxis(ang:Up(), -math.min(ply:GetVelocity():Length() / 16, 30) + 5)
				end

				ply.EgonPackModel:SetModelScale(0.75)
				ply.EgonPackModel:SetPos(pos + Vector(0, 0, 3))
				ply.EgonPackModel:SetAngles(ang)
				ply.EgonPackModel:DrawModel()
			end
		end
	end)
end