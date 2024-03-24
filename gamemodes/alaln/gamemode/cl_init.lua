include("shared.lua")
include("sh_rounds.lua")
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
local addmat_r = Material("ca/add_r")
local addmat_g = Material("ca/add_g")
local addmat_b = Material("ca/add_b")
local vgbm = Material("vgui/black")
-- credits to Mr. Point
function DrawCA(rx, gx, bx, ry, gy, by)
	render.UpdateScreenEffectTexture()
	addmat_r:SetTexture("$basetexture", render.GetScreenEffectTexture())
	addmat_g:SetTexture("$basetexture", render.GetScreenEffectTexture())
	addmat_b:SetTexture("$basetexture", render.GetScreenEffectTexture())
	render.SetMaterial(vgbm)
	render.DrawScreenQuad()
	render.SetMaterial(addmat_r)
	render.DrawScreenQuadEx(-rx / 2, -ry / 2, ScrW() + rx, ScrH() + ry)
	render.SetMaterial(addmat_g)
	render.DrawScreenQuadEx(-gx / 2, -gy / 2, ScrW() + gx, ScrH() + gy)
	render.SetMaterial(addmat_b)
	render.DrawScreenQuadEx(-bx / 2, -by / 2, ScrW() + bx, ScrH() + by)
end

-- effect hud
hook.Add("HUDPaint", "alaln-screffects", function()
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply:Alive()) or ply:GetMoveType() == MOVETYPE_NOCLIP then return end
	local frac = 1 - ply:Health() / ply:GetMaxHealth()
	local crazy = ply:GetCrazyness() / 7
	local clrmod = {
		["$pp_colour_addr"] = 0.05 + 0.01 * crazy,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0.01,
		["$pp_colour_brightness"] = -0.01 - 0.05 * frac,
		["$pp_colour_contrast"] = 0.95 - 0.15 * frac,
		["$pp_colour_colour"] = 0.85 - 0.15 * frac,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = -0.5
	}

	if ply:Alive() then
		DrawColorModify(clrmod)
		DrawBloom(0.8, 2, 4, 2, 5, 1, 1, 1, 3)
		DrawToyTown(1, ScrH() / 4 * frac)
		DrawSharpen(0.75, 0.75)
		DrawMaterialOverlay("fisheyelens", -0.04)
		if ply:Health() <= 40 then DrawMotionBlur(0.6 - 0.2 * frac, 0.8, 0.01) end
		local hp = frac * 8
		DrawCA(15 * hp + 5, 7 * hp + 5, 25, 9 * hp + 5, 6 * hp + 5, -5)
	end
end)

local alpha_black = Color(20, 0, 0, 75)
local hudfontbig = "alaln-hudfontbig"
local hudfontsmall = "alaln-hudfontsmall"
-- the REAL hud
hook.Add("PostDrawHUD", "alaln-realhud", function()
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply:Alive()) then return end
	local hudcolor = Color(150, 0, 0, math.Rand(ply:Health() / ply:GetMaxHealth(), 1) * 255)
	draw.RoundedBox(5, ScrW() / 50, ScrH() - 110, 228, 85, alpha_black)
	draw.SimpleText(ply:Health(), hudfontbig, 153, ScrH() - 64, hudcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	if SBOXMode:GetBool() == false then
		draw.SimpleText("Hunger: " .. math.Round(ply:GetHunger(), 0), hudfontsmall, ScrW() * 0.02, ScrH() * 0.88, hudcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		if ply:GetCrazyness() >= 10 then draw.SimpleText("Crazyness: " .. math.Round(ply:GetCrazyness(), 0), hudfontsmall, ScrW() * 0.02, ScrH() * 0.82, hudcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
	end

	if ply:Armor() > 0 then draw.SimpleText("Armor: " .. ply:Armor(), hudfontsmall, ScrW() * 0.02, ScrH() * 0.85, hudcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
end)

hook.Add("HUDPaintBackground", "alaln-healthvignette", function()
	local ply = LocalPlayer()
	local frac = ply:GetMaxHealth() - ply:Health()
	if not IsValid(ply) or ply:GetMoveType() == MOVETYPE_NOCLIP then return end
	alpha = math.Approach(frac or 200, 0, FrameTime() * 30)
	surface.SetDrawColor(0, 0, 0, 150 + alpha)
	surface.SetMaterial(Material("illuvignet.png"))
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
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
	["servermsg"] = true,
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
hook.Add("CalcView", "alaln-calcview", function(ply, vec, ang, fov, znear, zfar)
	if not (ply or IsValid(ply)) or ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetNoDraw() then return end
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
	local angol = LerpAngle(0.01, anglerp, ang1)
	local pozishon = ThirdPerson:GetBool() and util.TraceLine({
		start = eye.Pos,
		endpos = eye.Pos + angol:Up() * 1 + angol:Right() * 15 + angol:Forward() * -45,
		filter = ply,
	}).HitPos or vec

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

local color_loot = Color(0, 200, 0)
local color_wep = Color(220, 0, 0)
hook.Add("PostDrawEffects", "alaln-loothalo", function()
	local pos = LocalPlayer():GetPos()
	local entsInRange = ents.FindInSphere(pos, 384)
	local lootEnt, wepEnt = {}, {}
	for i = 1, #entsInRange do
		local ent = entsInRange[i]
		if not IsValid(ent) then return end
		if (string.match(ent:GetClass(), "mann_") or string.match(ent:GetClass(), "alaln_")) and not IsValid(ent:GetOwner()) and not ent:GetNoDraw() then
			if (ent:IsWeapon() and ent:GetMaxClip1() > 0) or ent.Base == "mann_ent_base" then
				table.insert(wepEnt, ent)
			else
				table.insert(lootEnt, ent)
			end
		end
	end

	outline.Add(lootEnt, color_loot, OUTLINE_MODE_VISIBLE)
	outline.Add(wepEnt, color_wep, OUTLINE_MODE_VISIBLE)
end)

local color_ui = Color(20, 0, 0, 100)
local color_button = Color(20, 0, 0, 150)
local color_text = Color(150, 0, 0)
local function SetClass(ply, class)
	if not (ply or class) then
		DebugPrint("Error! Calling SetClass() without args")
		return
	end

	ply:SetNWString("Class", class)
	ply:SetNWBool("NeedToKillNow", true)
end

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

	chat.AddText(Color(255, 235, 0), text)
end, nil, "Check your current gun ammo", FCVAR_NONE)

net.Receive("alaln-classmenu", function()
	--------------------------------------------------- Class Menu
	local frame = vgui.Create("DFrame")
	frame:SetSize(500, 500)
	frame:Center()
	frame:SetTitle("")
	frame:SetDraggable(false)
	frame:MakePopup()
	frame.Paint = function(self, w, h)
		draw.RoundedBox(5, 0, 0, w, h, color_ui)
		draw.SimpleText("Select Class", hudfontsmall, 245, 30, color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	--------------------------------------------------- Model viewer
	--[[local model = vgui.Create("DModelPanel", frame)
	model:SetSize(300, 300)
	model:SetPos(-80, 100)
	model:SetModel("models/player/corpse1.mdl")

	function model:LayoutEntity(ent)
		ent:SetSequence(ent:LookupSequence("idle_all_angry"))
		ent:SetAngles(Angle(0, 60, 0))

		if IsValid(model.Entity) then
			local mn, mx = model.Entity:GetRenderBounds()
			local size = 0
			size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
			size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
			size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
			model:SetFOV(85)
			model:SetCamPos(Vector(size / 2, size / 2, size / 2))
			model:SetLookAt((mn + mx) * 0.5)
		end
	end

	function model.Entity:GetPlayerColor()
		return LocalPlayer():GetPlayerColor()
	end]]
	--------------------------------------------------- Standard
	local button1 = vgui.Create("DButton", frame)
	button1:SetText("")
	button1:SetPos(170, 100)
	button1:SetSize(150, 100)
	button1.Paint = function(self, w, h)
		draw.RoundedBox(5, 0, 0, w, h, color_button)
		draw.SimpleText("Standard", hudfontsmall, 75, 50, color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	button1.DoClick = function()
		DebugPrint("Selected Standard class")
		SetClass(LocalPlayer(), "Standard")
		print(LocalPlayer():GetNWString("Class"))
		frame:Close()
	end

	--------------------------------------------------- Cannibal
	local button2 = vgui.Create("DButton", frame)
	button2:SetText("")
	button2:SetPos(170, 250)
	button2:SetSize(150, 100)
	button2.Paint = function(self, w, h)
		draw.RoundedBox(5, 0, 0, w, h, color_button)
		draw.SimpleText("Cannibal", hudfontsmall, 75, 50, color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	button2.DoClick = function()
		DebugPrint("Selected Cannibal class")
		SetClass(LocalPlayer(), "Cannibal")
		print(LocalPlayer():GetNWString("Class"))
		frame:Close()
	end
end)

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

hook.Add("HUDPaint", "PlayerInfo", function()
	local target = LocalPlayer():GetEyeTrace().Entity
	if IsValid(target) and target:IsPlayer() and target:GetPos():Distance(LocalPlayer():GetPos()) <= 400 then
		if target:GetNoDraw() then return end
		local pos = (target:GetPos() + Vector(0, 0, 75)):ToScreen()
		local health = target:Health()
		draw.SimpleText(target:Nick(), "alaln-hudfontvsmall", pos.x, pos.y, color_white, TEXT_ALIGN_CENTER)
		local healthStatus = "Healthy"
		local healthColor = Color(0, 255, 0)
		if health <= 75 then
			healthStatus = "Wounded"
			healthColor = Color(255, 255, 0)
		end

		if health <= 50 then
			healthStatus = "Severely Wounded"
			healthColor = Color(255, 165, 0)
		end

		if health <= 25 then
			healthStatus = "Barely Standing"
			healthColor = Color(139, 0, 0)
		end

		draw.SimpleText(healthStatus, "alaln-hudfontvsmall", pos.x, pos.y + 18, healthColor, TEXT_ALIGN_CENTER)
	end
end)