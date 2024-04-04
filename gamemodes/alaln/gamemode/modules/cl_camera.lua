--[[function ScrShake(ply, amount)
	if not (ply or amount) then
		DebugPrint("Error! Calling ScrShake() without args")
		return
	end

	ply:SetNWVector("ScrShake", ply:GetNWVector("ScrShake") + VectorRand(-amount, amount))
end

function GetScrShake(ply)
	if not ply then
		DebugPrint("Error! Calling GetScrShake() without args")
		return
	end
	return ply:GetNWVector("ScrShake")
end]]
ThirdPerson = CreateClientConVar("alaln_thirdperson", 0, false, false, "Enable thirdperson?", 0, 1)
local eyevecsuperpuper = Vector(0, 0, 1)
hook.Add("CalcView", "alaln-calcview", function(ply, vec, ang, fov, znear, zfar)
	if not (ply or IsValid(ply)) or ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetNoDraw() or ply:GetViewEntity() ~= ply then return end
	if not ply:Alive() then return end
	--[[local plyrag
	local plyrageye
	if not ply:Alive() then
		plyrag = ply:GetNWEntity("plyrag")
		plyrageye = (IsValid(plyrag) and not isbool(plyrag)) and plyrag:GetAttachment(plyrag:LookupAttachment("eyes"))
	end]]
	local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
	local ang1 = LerpAngle(0.15, LocalPlayer():EyeAngles(), eye.Ang)
	local MyLerp = Lerp(FrameTime(), -5, 0.1)
	local anglerp = LerpAngle(MyLerp / 4, ang1, ang)
	local angol = LerpAngle(FrameTime(), anglerp, ang1)
	local pozishon = ThirdPerson:GetBool() and util.TraceLine({
		start = eye.Pos,
		endpos = eye.Pos + angol:Up() * 1 + angol:Right() * 15 + angol:Forward() * -45,
		filter = ply,
	}).HitPos or vec + eyevecsuperpuper

	local view = {
		origin = pozishon,
		angles = angol,
		fov = fov + math.min(20, ply:GetVelocity():Length2D() * 0.03),
		znear = znear,
		zfar = zfar,
		drawviewer = ThirdPerson:GetBool()
	}
	return view
end)

hook.Add("AdjustMouseSensitivity", "alaln-sprintsensivity", function()
	local ply = LocalPlayer()
	if not IsValid(ply) or ply:GetMoveType() == MOVETYPE_NOCLIP then return end
	if not ply:Alive() then return end
	local frac = math.max(0.4, ply:Health() / ply:GetMaxHealth())
	local sens = math.max(0.2, frac - (ply:OnGround() and 0.65 or 0.5))
	if (ply:GetMoveType() == MOVETYPE_WALK and ply:IsSprinting()) or not ply:OnGround() then return sens end
	return frac
end)

local wish_limit_upper = -60
local wish_limit_lower = 60
local lerped_limit_upper = -50
local lerped_limit_lower = 50
hook.Add("CreateMove", "alaln-viewlimit", function(cmd)
	local ply = LocalPlayer()
	if not ply:Alive() or LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP then return end
	local ang = cmd:GetViewAngles()
	wish_limit_upper = -60
	wish_limit_lower = 60
	if ply:KeyDown(IN_DUCK) or ply:IsSprinting() then
		wish_limit_upper = wish_limit_upper + 15
		wish_limit_lower = wish_limit_lower - 10
	end

	lerped_limit_upper = Lerp(FrameTime() * 10, lerped_limit_upper, wish_limit_upper)
	lerped_limit_lower = Lerp(FrameTime() * 10, lerped_limit_lower, wish_limit_lower)
	ang.x = math.Clamp(ang.x, lerped_limit_upper, lerped_limit_lower)
	cmd:SetViewAngles(ang)
end)

local WDir = VectorRand():GetNormalized()
hook.Add("CreateMove", "alaln-weaponshake", function(cmd)
	local ply, amt, spr = LocalPlayer(), 30, 20
	local wep = ply:GetActiveWeapon()
	if ply:KeyDown(IN_DUCK) then amt = amt / 2 end
	if IsValid(wep) and wep.GetAiming and (wep:GetAiming() >= 99) then
		if wep.Scoped and (ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT)) then
			spr = spr * 2
			amt = amt * 2
		end

		local S = .05
		local EAng = cmd:GetViewAngles()
		local FT = FrameTime()
		WDir = (WDir + FT * VectorRand() * spr):GetNormalized()
		EAng.pitch = math.NormalizeAngle(EAng.pitch + WDir.z * FT * amt * S)
		EAng.yaw = math.NormalizeAngle(EAng.yaw + WDir.x * FT * amt * S)
		cmd:SetViewAngles(EAng)
	end
end)

local function VectorMA(start, scale, direction, dest)
	dest.x = start.x + direction.x * scale
	dest.y = start.y + direction.y * scale
	dest.z = start.z + direction.z * scale
end

local lagscale = 15
local function CalcViewModelLag(vm, origin, angles, original_angles)
	local vOriginalOrigin = Vector(origin.x, origin.y, origin.z)
	local vOriginalAngles = Angle(angles.x, angles.y, angles.z)
	vm.m_vecLastFacing = vm.m_vecLastFacing or angles:Forward()
	local forward = angles:Forward()
	if FrameTime() ~= 0.0 then
		local vDifference = forward - vm.m_vecLastFacing
		local flSpeed = 5.0
		local flDiff = vDifference:Length()
		if (flDiff > lagscale) and (lagscale > 0.0) then
			local flScale = flDiff / lagscale
			flSpeed = flSpeed * flScale
		end

		VectorMA(vm.m_vecLastFacing, flSpeed * FrameTime(), vDifference, vm.m_vecLastFacing)
		vm.m_vecLastFacing:Normalize()
		VectorMA(origin, 15.0, vDifference * -0.5, origin)
	end

	local right, up
	right = original_angles:Right()
	up = original_angles:Up()
	local pitch = original_angles[1]
	if pitch > 180.0 then
		pitch = pitch - 360.0
	elseif pitch < -180.0 then
		pitch = pitch + 360.0
	end

	if lagscale == 0.0 then
		origin = vOriginalOrigin
		angles = vOriginalAngles
	end

	VectorMA(origin, -pitch * 0.035, forward, origin)
	VectorMA(origin, -pitch * 0.03, right, origin)
	VectorMA(origin, -pitch * 0.02, up, origin)
end

local function doLag(weapon, vm, oldPos, oldAng, pos, ang)
	if IsValid(weapon) and weapon.GetAiming and weapon:GetAiming() > 65 then
		vm.m_vecLastFacing = ang:Forward()
	else
		CalcViewModelLag(vm, pos, ang, oldAng)
	end
end

hook.Add("CalcViewModelView", "HL2ViewModelSway", doLag)