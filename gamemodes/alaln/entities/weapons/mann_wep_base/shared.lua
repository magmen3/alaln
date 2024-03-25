--[[
                                         bbbbbbbb            
NNNNNNNN        NNNNNNNN                 b::::::b            
N:::::::N       N::::::N                 b::::::b            
N::::::::N      N::::::N                 b::::::b            
N:::::::::N     N::::::N                  b:::::b            
N::::::::::N    N::::::N  aaaaaaaaaaaaa   b:::::bbbbbbbbb    
N:::::::::::N   N::::::N  a::::::::::::a  b::::::::::::::bb  
N:::::::N::::N  N::::::N  aaaaaaaaa:::::a b::::::::::::::::b 
N::::::N N::::N N::::::N           a::::a b:::::bbbbb:::::::b
N::::::N  N::::N:::::::N    aaaaaaa:::::a b:::::b    b::::::b
N::::::N   N:::::::::::N  aa::::::::::::a b:::::b     b:::::b
N::::::N    N::::::::::N a::::aaaa::::::a b:::::b     b:::::b
N::::::N     N:::::::::Na::::a    a:::::a b:::::b     b:::::b
N::::::N      N::::::::Na::::a    a:::::a b:::::bbbbbb::::::b
N::::::N       N:::::::Na:::::aaaa::::::a b::::::::::::::::b 
N::::::N        N::::::N a::::::::::aa:::ab:::::::::::::::b  
NNNNNNNN         NNNNNNN  aaaaaaaaaa  aaaabbbbbbbbbbbbbbbb   

]]
if SERVER then AddCSLuaFile() end
AddCSLuaFile("client.lua")
include("client.lua")
game.AddParticles("particles/pcfs_jack_muzzleflashes.pcf")
SWEP.Base = "alaln_base"
SWEP.PrintName = "Mann Wep Base"
SWEP.ViewModelFlip = true
SWEP.ViewModel = "models/weapons/v_pist_jivejeven.mdl"
SWEP.WorldModel = "models/weapons/w_pist_usp.mdl"
SWEP.HoldType = "pistol"
SWEP.Category = "Forsakened"
SWEP.Spawnable = false
SWEP.AdminOnly = true
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
-- основа база
SWEP.Primary.Sound = SWEP.CloseFireSound
SWEP.Primary.Damage = 20 -- урон оружия
SWEP.Primary.NumShots = 1 -- сколько пуль (дробей) вылетает за один выстрел (используется для дробовиков)
SWEP.Primary.Recoil = 1 -- отдача оружия
SWEP.Primary.ClipSize = 10 -- количество патрон в оружии
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize -- не трогать
SWEP.Primary.Tracer = 1 -- не трогать
SWEP.Primary.Automatic = false -- автоматическое ли оружие
SWEP.Primary.Ammo = "Pistol" -- тип патронов оружия (все типы написаны на гмод вики)
-- Secondary не трогать
SWEP.Secondary.Sound = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.CanAmmoShow = true
SWEP.DeathDroppable = true
SWEP.CommandDroppable = true
-- самое веселое
SWEP.VModelForSelector = false -- это ставить если у оружия нету нормальной world модели (используется в селекторе оружия)
SWEP.AimTime = 3 -- скорость прицеливания (чем меньше тем быстрее)
SWEP.BearTime = 1 -- скорость перехода оружия в состояние бега (чем меньше тем быстрее)
SWEP.SprintPos = Vector(-4, 0, -10) -- позиция оружия во время бега
SWEP.SprintAng = Angle(80, 0, 0) -- угол оружия во время бега
-- SWEP.IronSightsPos = Vector(0, 0, 0)
-- SWEP.IronSightsAng = Angle(0, 0, 0)
SWEP.AimPos = Vector(1.75, 0, 1.22) -- позиция оружия в прицеливании
-- SWEP.AimAng =  Angle(0, 0, 0) -- угол оружия в прицеливании (не обязательно)
SWEP.FuckedWorldModel = true -- веселуха
SWEP.FuckedWorldModelForward = 1 -- веселуха 2
SWEP.FuckedWorldModelUp = 1 -- короче идите все на
SWEP.ENT = "mann_ent_base" -- энтити оружия (в основном используется при выбрасывании)
SWEP.ShellType = "ShellEject" -- эффект выпадения гильзы (лучше не трогать)
SWEP.MuzzleEffect = "pcf_jack_mf_spistol" -- эффект выстрела (тоже лучше не трогать)
SWEP.ReloadTime = 3 -- время перезарядки в секундах (рекомендуется синхронизировать с анимацией)
SWEP.ReloadRate = .6 -- скорость анимации перезарядки (чем больше тем быстрее)
SWEP.ReloadSound = "snd_jack_hmcd_smp_reload.wav" -- звук перезарядки
SWEP.CloseFireSound = "hndg_beretta92fs/beretta92_fire1.wav" -- звук выстрела в близи
SWEP.FarFireSound = "m9/m9_dist.wav" -- звук выстрела с далека
SWEP.HipHoldType = "pistol" -- анимация держания оружия от третьего лица (в гмод вики все анимации есть)
SWEP.AimHoldType = "revolver" -- анимация держания оружия от третьего лица при прицеливании (в гмод вики все анимации есть)
SWEP.DownHoldType = "normal" -- анимация держания оружия от третьего лица во время беге (в гмод вики все анимации есть)
SWEP.BarrelLength = 1 -- длинна оружия (влияет только на расстояние от которого оружие не будет стрелять)
SWEP.HandlingPitch = math.random(95, 105) -- тон звука доставания (менять не обязательно)
SWEP.TriggerDelay = .15 -- скорострельность оружия (больше - медленнее)
SWEP.CycleTime = .025 -- скорость затвора (так же влияет на скорострельность) (для дробовиков и винтовок)
SWEP.Supersonic = true -- добавляет смешной звук ветра пулям
SWEP.Accuracy = 1 -- общий множитель разброса (лучше не трогать)
SWEP.Spread = .03 -- множитель разброса от бедра (чем меньше тем лучше)
SWEP.ShotPitch = math.random(97, 102) -- рандомный (от 97 до 102) тон звука выстрела (100 это стандартный тон)
SWEP.VReloadTime = 0 -- время перезарядки после которой поступают патроны (лучше не трогать)
SWEP.HipFireInaccuracy = .003 -- разброс от бедра (чем меньше тем лучше)
SWEP.CycleType = "auto" -- механизм (тип) выстрела или чето типо того (manual,revolving,auto)
SWEP.ReloadType = "magazine" -- тип перезарядки (individual,clip,magazine)
SWEP.LastFire = 0 -- я сам не знаю на че влияет
-- SWEP.DryFireAnim 		 =  "" -- анимация выстрела без патрон (не обязательно) (можно узнать с помощью easy animation tool)
-- SWEP.LastFireAnim 		 =  "" -- анимация последнего выстрела (не обязательно) (можно узнать с помощью easy animation tool)
-- SWEP.AfterReloadAnim	 	 =  "" -- для дробовиков
-- SWEP.CycleAnim			 =  "" -- для дробовиков
SWEP.FireAnim = "shoot1" -- анимация выстрела (можно узнать с помощью easy animation tool)
SWEP.DrawAnim = "draw" -- анимация доставания (можно узнать с помощью easy animation tool) 
SWEP.ReloadAnim = "reload" -- анимация перезарядки (можно узнать с помощью easy animation tool)
SWEP.ReloadInterrupted = false -- не трогать
-- ДАЛЬШЕ БОГА НЕТ . . .
local SurfaceHardness = {
	[MAT_METAL] = .6,
	[MAT_COMPUTER] = .5,
	[MAT_VENT] = .5,
	[MAT_GRATE] = .5,
	[MAT_FLESH] = .3,
	[MAT_ALIENFLESH] = .3,
	[MAT_SAND] = .1,
	[MAT_DIRT] = .2,
	[74] = .1,
	[85] = .2,
	[MAT_WOOD] = .3,
	[MAT_FOLIAGE] = .3,
	[MAT_CONCRETE] = .8,
	[MAT_TILE] = .7,
	[MAT_SLOSH] = .05,
	[MAT_PLASTIC] = .2,
	[MAT_GLASS] = .4
}

function SWEP:Initialize()
	self.NextFrontBlockCheckTime = CurTime()
	self:SetHoldType(self.HipHoldType)
	self:SetAiming(0)
	self:SetSprinting(0)
	self:SetReady(true)
	if self.CustomColor then self:SetColor(self.CustomColor) end
	self:SetReloading(false)
end

function SWEP:ShouldDropOnDie()
	return true
end

function SWEP:PreDrawViewModel()
	if self.Scoped and (self:GetAiming() >= 99) then return true end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Ready")
	self:NetworkVar("Int", 0, "Aiming")
	self:NetworkVar("Int", 1, "Sprinting")
	self:NetworkVar("Bool", 1, "Reloading")
end

function SWEP:BulletCallback(att, tr, dmg)
	return {
		effects = true,
		damage = true
	}
end

if CLIENT then
	local stuncd = 0
	function SWEP:Stun()
		DrawToyTown(2, 110 * ScrH() / 200)
		if math.random(1, 60) == 20 and not self.Primary.Automatic then
			if stuncd < CurTime() then
				DebugPrint("stunned semi-auto")
				surface.PlaySound("mann/tinnitus.wav")
				DrawToyTown(3, 200 * ScrH() / 200)
				if math.random(1, 2) == 2 then
					self:GetOwner():SetDSP(11, true)
					timer.Simple(3, function()
						if not IsValid(self) then return end
						self:GetOwner():SetDSP(0)
					end)
				end

				stuncd = CurTime() + 15
			end
		elseif math.random(1, 80) == 30 and self.Primary.Automatic then
			DebugPrint("stunned semi-auto")
			surface.PlaySound("mann/tinnitus.wav")
			DrawToyTown(3, 200 * ScrH() / 200)
			if math.random(1, 2) == 2 then
				self:GetOwner():SetDSP(11, true)
				timer.Simple(5, function()
					if not IsValid(self) then return end
					self:GetOwner():SetDSP(0)
				end)
			end
		end
	end
end

function SWEP:PrimaryAttack()
	self.ReloadInterrupted = true
	if not self:GetReady() then return end
	if self:GetSprinting() > 10 then return end
	if not (self:Clip1() > 0) then
		self:EmitSound("weapons/firearms/hndg_glock17/glock17_dryfire.wav", 55, 100)
		self:SetNextPrimaryFire(CurTime() + (self.Primary.Automatic and .35 or .25))
		if self.DryFireAnim then self:DoBFSAnimation(self.DryFireAnim) end
		return
	end

	if not IsFirstTimePredicted() then
		if (self:Clip1() == 1) and self.LastFireAnim then
			self:DoBFSAnimation(self.LastFireAnim)
		elseif self:Clip1() > 0 then
			self:DoBFSAnimation(self.FireAnim)
		end
		return
	end

	self.LastFire = CurTime()
	local WaterMul = 1
	if self:GetOwner():WaterLevel() >= 3 then WaterMul = .5 end
	local dmgAmt, InAcc = self.Primary.Damage * math.Rand(.9, 1.1) * WaterMul, 1 - self.Accuracy
	if not (self:GetAiming() > 99) then InAcc = InAcc + self.HipFireInaccuracy end
	local BulletTraj = (self:GetOwner():GetAimVector() + VectorRand() * InAcc):GetNormalized()
	local bullet = {}
	bullet.Num = self.Primary.NumShots
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Dir = BulletTraj
	bullet.Spread = Vector(self.Spread, self.Spread, 0)
	bullet.Tracer = 1
	bullet.TracerName = "Tracer"
	bullet.Force = dmgAmt / 10
	bullet.Damage = dmgAmt
	bullet.Callback = function(ply, tr) ply:GetActiveWeapon():BulletCallbackFunc(dmgAmt, ply, tr, dmg, false, true, false) end
	self:GetOwner():FireBullets(bullet)
	if self.Supersonic then self:BallisticSnap(BulletTraj) end
	if CLIENT then self:Stun() end
	if (self:Clip1() == 1) and self.LastFireAnim then
		self:DoBFSAnimation(self.LastFireAnim)
	elseif self:Clip1() > 0 then
		self:DoBFSAnimation(self.FireAnim)
		if self.FireAnimRate then self:GetOwner():GetViewModel():SetPlaybackRate(self.FireAnimRate) end
	end

	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	local Pitch = self.ShotPitch * math.Rand(.95, 1)
	if SERVER then
		local Dist = 75
		self:GetOwner():EmitSound(self.CloseFireSound, Dist, Pitch)
		self:GetOwner():EmitSound(self.FarFireSound, Dist * 2, Pitch)
		if self.ExtraFireSound then sound.Play(self.ExtraFireSound, self:GetOwner():GetShootPos() + VectorRand(), Dist - 5, Pitch) end
		if self.CycleType == "manual" then
			timer.Simple(.2, function()
				if IsValid(self) and IsValid(self:GetOwner()) then
					self:DoBFSAnimation(self.CycleAnim)
					self:EmitSound(self.CycleSound, 55, 100)
				end
			end)
		end
	end

	local Rightness, Upness = 4, 2
	if self:GetAiming() == 100 then
		Rightness = 0
		Upness = 0
	end

	ParticleEffect(self.MuzzleEffect, self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 20 + self:GetOwner():EyeAngles():Right() * Rightness - self:GetOwner():EyeAngles():Up() * Upness, self:GetOwner():EyeAngles(), self)
	if SERVER and (self.CycleType == "auto") and self.ShellType and self.ShellType ~= "" then
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 15 + self:GetOwner():EyeAngles():Right() * Rightness - self:GetOwner():EyeAngles():Up() * Upness)
		effectdata:SetAngles(self:GetOwner():GetRight():Angle())
		effectdata:SetEntity(self:GetOwner())
		util.Effect(self.ShellType, effectdata, true, true)
	elseif SERVER and (self.CycleType == "manual") and self.ShellType and self.ShellType ~= "" then
		timer.Simple(.4, function()
			if IsValid(self) and IsValid(self:GetOwner()) then
				local effectdata = EffectData()
				effectdata:SetOrigin(self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 15 + self:GetOwner():EyeAngles():Right() * Rightness - self:GetOwner():EyeAngles():Up() * Upness)
				effectdata:SetAngles(self:GetOwner():GetRight():Angle())
				effectdata:SetEntity(self:GetOwner())
				util.Effect(self.ShellType, effectdata, true, true)
			end
		end)
	end

	local Ang, Rec = self:GetOwner():EyeAngles(), self.Primary.Recoil
	local RecoilY = math.Rand(.020, .023) * Rec
	local RecoilX = math.Rand(-.018, .021) * Rec
	if (SERVER and game.SinglePlayer()) or CLIENT then self:GetOwner():SetEyeAngles((Ang:Forward() + RecoilY * Ang:Up() + Ang:Right() * RecoilX):Angle()) end
	if not self:GetOwner():OnGround() then self:GetOwner():SetVelocity(-self:GetOwner():GetAimVector() * 10) end
	self:GetOwner():ViewPunchReset()
	self:GetOwner():ViewPunch(Angle(RecoilY * -30 * self.Primary.Recoil, RecoilX * -30 * self.Primary.Recoil, 0))
	self:TakePrimaryAmmo(1)
	local Extra = 0
	if self:GetOwner():WaterLevel() >= 3 then Extra = 1 end
	self:SetNextPrimaryFire(CurTime() + self.TriggerDelay + self.CycleTime + Extra)
end

function SWEP:SecondaryAttack()
end

-- wat
function SWEP:Think()
	if SERVER then
		if (self.ReloadType == "individual") and self:GetReloading() then
			if self.VReloadTime < CurTime() then
				if (self:Clip1() < self.Primary.ClipSize) and (self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0) and not self.ReloadInterrupted then
					self:SetClip1(self:Clip1() + 1)
					self:GetOwner():RemoveAmmo(1, self.Primary.Ammo)
					self:StallAnimation(self.ReloadAnim, 1)
					timer.Simple(.01, function() self:ReadyAfterAnim(self.InsertAnim) end)
					sound.Play(self.ReloadSound, self:GetOwner():GetShootPos(), 55, 100)
				else
					self:SetReloading(false)
					self:ReadyAfterAnim(self.AfterReloadAnim)
					timer.Simple(.25, function() if IsValid(self) and IsValid(self:GetOwner()) then self:EmitSound(self.CycleSound, 55, 90) end end)
					timer.Simple(.5, function() if IsValid(self) and IsValid(self:GetOwner()) then self:SetReady(true) end end)
				end
			end
		end

		local Sprintin, Aimin, AimAmt, SprintAmt = self:GetOwner():IsSprinting(), self:GetOwner():KeyDown(IN_ATTACK2), self:GetAiming(), self:GetSprinting()
		if (Sprintin or self:FrontBlocked()) and self:GetReady() then
			self:SetSprinting(math.Clamp(SprintAmt + 40 * (1 / self.BearTime), 0, 100))
			self:SetAiming(math.Clamp(AimAmt - 40 * (1 / self.AimTime), 0, 100))
		elseif Aimin and self:GetOwner():OnGround() and not ((self.CycleType == "manual") and (self.LastFire + .75 > CurTime())) then
			self:SetAiming(math.Clamp(AimAmt + 20 * (1 / self.AimTime), 0, 100))
			self:SetSprinting(math.Clamp(SprintAmt - 20 * (1 / self.BearTime), 0, 100))
		else
			self:SetAiming(math.Clamp(AimAmt - 40 * (1 / self.AimTime), 0, 100))
			self:SetSprinting(math.Clamp(SprintAmt - 20 * (1 / self.BearTime), 0, 100))
		end

		local HoldType = self.HipHoldType
		if SprintAmt > 90 then
			HoldType = self.DownHoldType
		elseif Aimin and not self:GetOwner():KeyDown(IN_DUCK) then
			HoldType = self.AimHoldType
		else
			HoldType = self.HipHoldType
		end

		self:SetHoldType(HoldType)
	end
end

function SWEP:Reload()
	self.ReloadInterrupted = false
	if not IsFirstTimePredicted() then return end
	if not (IsValid(self) and IsValid(self:GetOwner())) then return end
	if not self:GetReady() then return end
	if self:GetSprinting() > 0 then return end
	if (self:Clip1() < self.Primary.ClipSize) and (self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0) then
		local TacticalReload = self:Clip1() > 0
		self:SetReady(false)
		self:GetOwner():SetAnimation(PLAYER_RELOAD)
		if (self.ReloadType == "clip") or (self.ReloadType == "magazine") then
			if TacticalReload and self.TacticalReloadAnim then
				self:DoBFSAnimation(self.TacticalReloadAnim)
			else
				self:DoBFSAnimation(self.ReloadAnim)
			end

			self:GetOwner():GetViewModel():SetPlaybackRate(self.ReloadRate)
			self.Weapon:EmitSound(self.ReloadSound, 65, 100)
			if SERVER then
				if self.CycleType == "revolving" then
					timer.Simple(self.ReloadTime / 3, function()
						if IsValid(self) and IsValid(self:GetOwner()) and self.ShellType and self.ShellType ~= "" then
							for i = 1, self.Primary.ClipSize - self:Clip1() do
								local effectdata = EffectData()
								effectdata:SetOrigin(self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Forearm")))
								effectdata:SetAngles((-vector_up):Angle())
								effectdata:SetEntity(self:GetOwner())
								util.Effect(self.ShellType, effectdata, true, true)
							end
						end
					end)
				end

				local ReloadAdd = 0
				if not TacticalReload then ReloadAdd = .2 end
				timer.Simple(self.ReloadTime + ReloadAdd, function()
					if IsValid(self) and IsValid(self:GetOwner()) then
						self:SetReady(true)
						local Missing, Have = self.Primary.ClipSize - self:Clip1(), self:GetOwner():GetAmmoCount(self.Primary.Ammo)
						if Missing <= Have then
							self:GetOwner():RemoveAmmo(Missing, self.Primary.Ammo)
							self:SetClip1(self.Primary.ClipSize)
						elseif Missing > Have then
							self:SetClip1(self:Clip1() + Have)
							self:GetOwner():RemoveAmmo(Have, self.Primary.Ammo)
						end
					end
				end)
			end
		elseif self.ReloadType == "individual" then
			self:SetReloading(true)
			self:ReadyAfterAnim(self.ReloadAnim)
		end
	end
end

function SWEP:ReadyAfterAnim(anim)
	self:DoBFSAnimation(anim)
	self:GetOwner():GetViewModel():SetPlaybackRate(self.ReloadRate)
	local Time = (self:GetOwner():GetViewModel():SequenceDuration() / self.ReloadRate) + .01
	self.VReloadTime = CurTime() + Time
end

function SWEP:Deploy()
	if IsValid(self) and IsValid(self:GetOwner()) then
		if not IsFirstTimePredicted() then
			self:DoBFSAnimation(self.DrawAnim)
			self:GetOwner():GetViewModel():SetPlaybackRate(.1)
			return
		end

		self:DoBFSAnimation(self.DrawAnim)
		self:GetOwner():GetViewModel():SetPlaybackRate(.5)
		self:SetReady(false)
		self:GetOwner():DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_PLACE)
		self:EmitSound("weapons/firearms/holster_out" .. math.random(1, 5) .. ".wav", 70, self.HandlingPitch)
		self:EnforceHolsterRules(self)
		self:GetOwner():GetViewModel():StopParticles()
		timer.Simple(1.5, function() if IsValid(self) then self:SetReady(true) end end)
		return true
	end
end

function SWEP:EnforceHolsterRules(newWep)
	if CLIENT then return end
	if newWep ~= self then -- only enforce rules for us
		return
	end

	for key, wep in pairs(self:GetOwner():GetWeapons()) do
		-- conflict
		if wep.HolsterSlot and self.HolsterSlot and (wep.HolsterSlot == self.HolsterSlot) and not (wep == self) then self:GetOwner():DropWeapon(wep) end
	end
end

function SWEP:StallAnimation(anim, time)
	self:DoBFSAnimation(self.ReloadAnim)
	self.VReloadTime = self.VReloadTime + .1
	self:GetOwner():GetViewModel():SetPlaybackRate(.1)
end

function SWEP:DoBFSAnimation(anim)
	if self:GetOwner() and self:GetOwner().GetViewModel then
		local vm = self:GetOwner():GetViewModel()
		vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
	end
end

function SWEP:UpdateNextIdle()
	local vm = self:GetOwner():GetViewModel()
	self:SetNextIdle(CurTime() + vm:SequenceDuration())
end

function SWEP:Holster(newWep)
	self:EmitSound("weapons/firearms/holster_in" .. math.random(1, 4) .. ".wav", 70, self.HandlingPitch)
	self:EnforceHolsterRules(newWep)
	self:SetReady(false)
	if self:GetOwner():GetViewModel():IsValid() then self:GetOwner():GetViewModel():StopParticles() end
	return true
end

function SWEP:OnRemove()
end

function SWEP:OnRestore()
end

function SWEP:Precache()
end

function SWEP:OwnerChanged()
end

function SWEP:FrontBlocked()
	local Time = CurTime()
	if self.NextFrontBlockCheckTime < Time then
		self.NextFrontBlockCheckTime = Time + .25
		local ShootVec, Ang, ShootPos = self:GetOwner():GetAimVector(), self:GetOwner():GetAngles(), self:GetOwner():GetShootPos()
		ShootPos = ShootPos + ShootVec * 15
		Ang.p = 0
		Ang.r = 0
		local Tr = util.TraceLine({
			start = ShootPos - Ang:Forward() * 5,
			endpos = ShootPos + (ShootVec * self.BarrelLength) + Ang:Forward() * 15,
			filter = {self:GetOwner()}
		})

		if Tr.Hit then
			self.FrontallyBlocked = true
		else
			self.FrontallyBlocked = false
		end
	end
	return self.FrontallyBlocked
end

function SWEP:BulletCallbackFunc(dmgAmt, ply, tr, dmg, tracer, hard, multi)
	if self.Primary.NumShots > 1 then return end
	if tr.HitSky then return end
	if tr.MatType == MAT_FLESH then
		util.Decal("Impact.Flesh", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		timer.Simple(.05, function()
			local Tr = util.QuickTrace(tr.HitPos + tr.HitNormal, -tr.HitNormal * 10)
			if Tr.Hit then util.Decal("Impact.Flesh", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal) end
		end)
	end

	if hard then self:RicochetOrPenetrate(tr) end
end

function SWEP:RicochetOrPenetrate(initialTrace)
	local AVec, IPos, TNorm, SMul = initialTrace.Normal, initialTrace.HitPos, initialTrace.HitNormal, SurfaceHardness[initialTrace.MatType]
	if not SMul then SMul = .5 end
	local ApproachAngle = -math.deg(math.asin(TNorm:DotProduct(AVec)))
	local MaxRicAngle = 60 * SMul
	-- all the way through
	if ApproachAngle > (MaxRicAngle * 1.25) then
		local MaxDist, SearchPos, SearchDist, Penetrated = (self.Primary.Damage / SMul) * .15, IPos, 5, false
		while (not Penetrated) and (SearchDist < MaxDist) do
			SearchPos = IPos + AVec * SearchDist
			local PeneTrace = util.QuickTrace(SearchPos, -AVec * SearchDist)
			if (not PeneTrace.StartSolid) and PeneTrace.Hit then
				Penetrated = true
			else
				SearchDist = SearchDist + 5
			end
		end

		if Penetrated then
			self:FireBullets({
				Attacker = self:GetOwner(),
				Damage = 1,
				Force = 1,
				Num = 1,
				Tracer = 0,
				TracerName = "",
				Dir = -AVec,
				Spread = vector_origin,
				Src = SearchPos + AVec
			})

			self:FireBullets({
				Attacker = self:GetOwner(),
				Damage = self.Primary.Damage * .65,
				Force = self.Primary.Damage / 85,
				Num = 1,
				Tracer = 0,
				TracerName = "",
				Dir = AVec,
				Spread = vector_origin,
				Src = SearchPos + AVec
			})
		end
	elseif ApproachAngle < (MaxRicAngle * .75) then
		-- ping whiiiizzzz
		sound.Play("snd_jack_hmcd_ricochet_" .. math.random(1, 2) .. ".wav", IPos, 70, math.random(90, 100))
		local NewVec = AVec:Angle()
		NewVec:RotateAroundAxis(TNorm, 180)
		local AngDiffNormal = math.deg(math.acos(NewVec:Forward():Dot(TNorm))) - 90
		NewVec:RotateAroundAxis(NewVec:Right(), AngDiffNormal * .7) -- bullets actually don't ricochet elastically
		NewVec = NewVec:Forward()
		self:FireBullets({
			Attacker = self:GetOwner(),
			Damage = self.Primary.Damage * .5,
			Force = self.Primary.Damage / 85,
			Num = 1,
			Tracer = 0,
			TracerName = "",
			Dir = -NewVec,
			Spread = vector_origin,
			Src = IPos + TNorm
		})
	end
end

function SWEP:OnDrop()
	local Ent = ents.Create(self.ENT)
	Ent:SetPos(self:GetPos())
	Ent:SetAngles(self:GetAngles())
	Ent:Spawn()
	Ent:Activate()
	Ent.RoundsInMag = self:Clip1()
	Ent:GetPhysicsObject():SetVelocity(self:GetVelocity() / 2)
	self:Remove()
end

function SWEP:BallisticSnap(traj)
	if CLIENT then return end
	if not self.Supersonic then return end
	if self.Primary.NumShots > 1 then return end
	local Src = self:GetOwner():GetShootPos()
	local TrDat = {
		start = Src,
		endpos = Src + traj * 20000,
		filter = {self:GetOwner()}
	}

	local Tr, EndPos = util.TraceLine(TrDat), Src + traj * 20000
	if Tr.Hit or Tr.HitSky then EndPos = Tr.HitPos end
	local Dist = (EndPos - Src):Length()
	if Dist > 1000 then
		for i = 1, math.floor(Dist / 500) do
			local SoundSrc = Src + traj * i * 500
			local plys = player.GetAll()
			for key, ply in ipairs(plys) do
				if ply ~= self:GetOwner() then
					local PlyPos = ply:GetPos()
					if (PlyPos - SoundSrc):Length() < 500 then
						local Snd = "snd_jack_hmcd_bc_" .. math.random(1, 7) .. ".wav"
						local Pitch = math.random(90, 110)
						sound.Play(Snd, ply:GetShootPos(), 50, Pitch)
					end
				end
			end
		end
	end
end

if CLIENT then
	local Crouched = 0
	local LastSprintGotten = 0
	local LastAimGotten = 0
	local LastExtraAim = 0
	function SWEP:GetViewModelPosition(pos, ang)
		if not IsValid(self:GetOwner()) then return pos, ang end
		local FT = FrameTime()
		local SprintGotten = Lerp(.1, LastSprintGotten, self:GetSprinting())
		LastSprintGotten = SprintGotten
		local AimGotten = Lerp(.1, LastAimGotten, self:GetAiming())
		LastAimGotten = AimGotten
		local Aim, Sprint, Up, Forward, Right = AimGotten, SprintGotten / 100, ang:Up(), ang:Forward(), ang:Right()
		local ExtraAim = 0
		if self:GetOwner():KeyDown(IN_FORWARD) or self:GetOwner():KeyDown(IN_BACK) or self:GetOwner():KeyDown(IN_MOVELEFT) or self:GetOwner():KeyDown(IN_MOVERIGHT) then
			ExtraAim = Lerp(4 * FT, LastExtraAim, 1)
		else
			ExtraAim = Lerp(4 * FT, LastExtraAim, 0)
		end

		LastExtraAim = ExtraAim
		local Vec = self.AimPos * (Aim / 100)
		if self.CloseAimPos and (Aim > 0) then Vec = Vec + self.CloseAimPos * ExtraAim end
		if (Aim > 0) and self:GetReady() and self.AimAng then
			ang:RotateAroundAxis(ang:Right(), self.AimAng.p * Aim / 100)
			ang:RotateAroundAxis(ang:Up(), self.AimAng.y * Aim / 100)
			ang:RotateAroundAxis(ang:Forward(), self.AimAng.r * Aim / 100)
		end

		if (Sprint > 0) and self:GetReady() then
			pos = pos + Up * self.SprintPos.z * Sprint + Forward * self.SprintPos.y * Sprint + Right * self.SprintPos.x * Sprint
			ang:RotateAroundAxis(ang:Right(), self.SprintAng.p * Sprint)
			ang:RotateAroundAxis(ang:Up(), self.SprintAng.y * Sprint)
			ang:RotateAroundAxis(ang:Forward(), self.SprintAng.r * Sprint)
		end

		pos = pos + Vec.x * Right + Vec.y * Forward + Vec.z * Up
		if self:GetOwner():KeyDown(IN_DUCK) then
			Crouched = math.Clamp(Crouched + .05, 0, 1)
		else
			Crouched = math.Clamp(Crouched - .05, 0, 1)
		end

		Crouched = Crouched * (1 - (Aim / 100))
		pos = pos + Up * Crouched
		return pos, ang
	end

	function SWEP:DrawWorldModel()
		if IsValid(self:GetOwner()) then
			if self.FuckedWorldModel then
				if not self.WModel then
					self.WModel = ClientsideModel(self.WorldModel)
					self.WModel:SetPos(self:GetOwner():GetPos())
					self.WModel:SetParent(self:GetOwner())
					self.WModel:SetNoDraw(true)
				else
					local pos, ang = self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))
					if pos and ang then
						self.WModel:SetRenderOrigin(pos + ang:Right() + ang:Up() * self.FuckedWorldModelUp + ang:Forward() * self.FuckedWorldModelForward)
						ang:RotateAroundAxis(ang:Forward(), 180)
						ang:RotateAroundAxis(ang:Right(), 10)
						self.WModel:SetRenderAngles(ang)
						self.WModel:DrawModel()
					end
				end
			else
				self:DrawModel()
			end

			local pos, ang = self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))
		end
	end

	function SWEP:FireAnimationEvent(pos, ang, event, name)
		return true
	end
	-- I do all this, bitch
end