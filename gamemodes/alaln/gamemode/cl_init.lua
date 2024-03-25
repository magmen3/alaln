include("shared.lua")
include("cl_hud.lua")
include("cl_classmenu.lua")
include("cl_mainmenu.lua")
hook.Add("SpawnMenuOpen", "alaln-spawnmenu", function() if SBOXMode:GetInt() == 0 then return false end end)
hook.Add("ContextMenuOpen", "alaln-contextmenu", function() if SBOXMode:GetInt() == 0 then return false end end)
local function CreateFonts()
	surface.CreateFont("alaln-hudfontbig", {
		font = "SMODGUI", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
		extended = false,
		size = 64,
		weight = 500,
		blursize = 0,
		scanlines = 3,
		antialias = false,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = true,
		additive = false,
		outline = false,
	})

	surface.CreateFont("alaln-hudfontsmall", {
		font = "SMODGUI", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
		extended = false,
		size = 32,
		weight = 500,
		blursize = 0,
		scanlines = 2,
		antialias = false,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = true,
		additive = false,
		outline = false,
	})

	surface.CreateFont("alaln-hudfontvsmall", {
		font = "SMODGUI", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
		extended = false,
		size = 18,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	})
end

CreateFonts()
hook.Add("AdjustMouseSensitivity", "alaln-sprintsensivity", function()
	local ply = LocalPlayer()
	if not IsValid(ply) or ply:GetMoveType() == MOVETYPE_NOCLIP then return end
	if not ply:Alive() then return end
	local frac = math.max(0.4, ply:Health() / ply:GetMaxHealth())
	local sens = math.max(0.2, frac - (ply:OnGround() and 0.65 or 0.5))
	if (ply:GetMoveType() == MOVETYPE_WALK and ply:IsSprinting()) or not ply:OnGround() then return sens end
	return frac
end)

local BadNames = {
	["CHudHealth"] = false,
	["CHudBattery"] = false,
	["CHudAmmo"] = false,
	["CHudSecondaryAmmo"] = false,
	["CHudCrosshair"] = false,
	["CHudDamageIndicator"] = false,
	["CHudGeiger"] = false
}

hook.Add("HUDShouldDraw", "alaln-hidedefaulthud", function(name) return BadNames[name] end)
local BadType = {
	["joinleave"] = true,
	["namechange"] = true,
	["servermsg"] = false,
	["teamchange"] = true
}

function GM:ChatText(index, name, text, type)
	return BadType[type]
end

hook.Add("DrawDeathNotice", "alaln-hidekillfeed", function()
	return false -- return 0, 0
end)

hook.Add("PlayerStartVoice", "alaln-hideimageonvoice", function() return true end)
function ScrShake(ply, amount)
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
end

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

gameevent.Listen("player_spawn")
hook.Add("player_spawn", "alaln-networkplyhull", function(data)
	local ply = Player(data.userid)
	if BRANCH ~= "x86-64" then
		for i = 1, 10 do
			ply:ChatPrint("Даун поставь x64 бету")
		end
	end

	--hook.Run("Player Spawn",ply)
	if ply.SetHull then
		ply:SetHull(ply:GetNWVector("HullMin"), ply:GetNWVector("Hull"))
		ply:SetHullDuck(ply:GetNWVector("HullMin"), ply:GetNWVector("HullDuck"))
	end
end)

------------------------------------------
local wish_limit_upper = -60
local wish_limit_lower = 60
local lerped_limit_upper = -50
local lerped_limit_lower = 50
hook.Add("CreateMove", "alaln-view_limit", function(cmd)
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
	local ply, Amt, Sporadicness = LocalPlayer(), 30, 20
	local Wep = ply:GetActiveWeapon()
	if ply:KeyDown(IN_DUCK) then Amt = Amt / 2 end
	if IsValid(Wep) and Wep.GetAiming and (Wep:GetAiming() >= 99) then
		if Wep.Scoped and (ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT)) then
			Sporadicness = Sporadicness * 2
			Amt = Amt * 2
		end

		local S = .05
		local EAng = cmd:GetViewAngles()
		local FT = FrameTime()
		WDir = (WDir + FT * VectorRand() * Sporadicness):GetNormalized()
		EAng.pitch = math.NormalizeAngle(EAng.pitch + WDir.z * FT * Amt * S)
		EAng.yaw = math.NormalizeAngle(EAng.yaw + WDir.x * FT * Amt * S)
		cmd:SetViewAngles(EAng)
	end
end)

local color_yellow = Color(255, 235, 0)
concommand.Add("checkammo", function()
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if not (IsValid(wep) and IsValid(ply) and ply:Alive()) then return end
	local ammo, ammobag = wep:GetMaxClip1(), wep:Clip1()
	if ammo <= 0 then return end
	--surface.PlaySound("common/wpn_denyselect.wav")
	--chat.AddText(Color(255, 235, 0), "You can't check ammo on this weapon.")
	surface.PlaySound("physics/metal/weapon_footstep" .. math.random(1, 2) .. ".wav")
	local text
	if ammobag > ammo - 1 then
		text = "Full magazine."
	elseif ammobag > ammo - ammo / 3 then
		text = "~ Almost full magazine."
	elseif ammobag > ammo / 3 then
		text = "~ Half magazine."
	elseif ammobag >= 1 then
		text = "~ Almost empty magazine."
	elseif ammobag < 1 then
		text = "Empty magazine."
	end

	chat.AddText(color_yellow, text)
end, nil, "Check your current gun ammo", FCVAR_NONE)

net.Receive("alaln-navmeshnotfound", function()
	local navframe = vgui.Create("DFrame")
	navframe:SetSize(500, 500)
	navframe:Center()
	navframe:SetTitle("")
	navframe:SetDraggable(false)
	navframe:ShowCloseButton(true)
	navframe:MakePopup()
	navframe.Paint = function(self, w, h)
		draw.RoundedBox(5, 0, 0, w, h, color_ui)
		draw.SimpleText("Navmesh not found!", hudfontsmall, 245, 30, color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local button1 = vgui.Create("DButton", navframe)
	button1:SetText("")
	button1:SetPos(170, 100)
	button1:SetSize(150, 100)
	button1.Paint = function(self, w, h)
		draw.RoundedBox(5, 0, 0, w, h, color_button)
		draw.SimpleText("Change map in main menu", hudfontsmall, 75, 50, color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	button1.DoClick = function()
		navframe:Close()
		LocalPlayer():ConCommand("disconnect")
	end
end)

net.Receive("alaln-ragplayercolor", function()
	local ent = net.ReadEntity()
	local col = net.ReadVector()
	if IsValid(ent) and isvector(col) then
		function ent:GetPlayerColor()
			return col
		end
	end
end)

net.Receive("DoPlayerFlinch", function(len)
	local gest = net.ReadInt(32)
	local ply = net.ReadEntity()
	if not IsValid(ply) then return end
	ply:AnimRestartGesture(GESTURE_SLOT_FLINCH, gest, true)
end)

hook.Add("ScoreboardShow", "alaln-scoreboard", function()
	if SBOXMode:GetBool() == true or not LocalPlayer():Alive() then return end
	return true
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
function GM:HUDDrawTargetID()
	return false
end

local PIClr = {
	nick = Color(220, 220, 220, 200),
	healthy = Color(15, 220, 15, 200),
	wounded = Color(200, 200, 15, 200),
	sevwounded = Color(200, 125, 15, 200),
	barely = Color(165, 15, 15, 200)
}

hook.Add("HUDPaint", "PlayerInfo", function()
	local target = LocalPlayer():GetEyeTrace().Entity
	if IsValid(target) and target:IsPlayer() and target:GetPos():Distance(LocalPlayer():GetPos()) <= 400 then
		if target:GetNoDraw() then return end
		local pos = (target:GetPos() + Vector(0, 0, 75)):ToScreen()
		local health = target:Health()
		draw.SimpleText(target:Nick(), "alaln-hudfontvsmall", pos.x, pos.y, PIClr.nick, TEXT_ALIGN_CENTER)
		local healthStatus = "Healthy"
		local healthColor = PIClr.healthy
		if health <= 75 then
			healthStatus = "Wounded"
			healthColor = PIClr.wounded
		end

		if health <= 50 then
			healthStatus = "Severely Wounded"
			healthColor = PIClr.sevwounded
		end

		if health <= 25 then
			healthStatus = "Barely Standing"
			healthColor = PIClr.barely
		end

		draw.SimpleText(healthStatus, "alaln-hudfontvsmall", pos.x, pos.y + 18, healthColor, TEXT_ALIGN_CENTER)
	end
end)

local roundTimeStart = CurTime()
-- format: multiline
local rndsound = {
	"music/hl2_song10.mp3",
	"music/hl2_song13.mp3",
	"music/hl2_song30.mp3",
	"music/hl2_song33.mp3",
	"music/radio1.mp3",
	"in2/maintenance_tunnels.mp3"
}

local playsound = true
local color = Color(150, 0, 0, 250)
local hudfont = "alaln-hudfontbig"
local randomstrings = {"RUN", "LIVER FAILURE FOREVER", "YOU'RE ALREADY DEAD", "KILL OR DIE"}
local text
hook.Add("HUDPaint", "alaln-roundstartscreen", function()
	if true then return end
	local ply = LocalPlayer()
	local startRound = roundTimeStart + 10 - CurTime()
	if startRound > 0 and ply:Alive() then
		if playsound then
			playsound = false
			surface.PlaySound(table.Random(rndsound))
			text = table.Random(randomstrings)
		end

		ply:ScreenFade(SCREENFADE.IN, color_black, 3, 0.5)
		draw.DrawText("You are Survivor", hudfont, ScrW() / 2, ScrH() / 2, Color(color.r, color.g, color.b, math.Clamp(startRound - 0.5, 0, math.Rand(0.7, 1)) * 255), TEXT_ALIGN_CENTER)
		draw.DrawText("Forsakened", hudfont, ScrW() / 2, ScrH() / 8, Color(color.r, color.g, color.b, math.Clamp(startRound - 0.5, 0, math.Rand(0.7, 1)) * 255), TEXT_ALIGN_CENTER)
		draw.DrawText(text, hudfont, ScrW() / 2, ScrH() / 1.2, Color(color.r, color.g, color.b, math.Clamp(startRound - 0.5, 0, math.Rand(0, 0.1)) * 255), TEXT_ALIGN_CENTER)
		return
	end
end)