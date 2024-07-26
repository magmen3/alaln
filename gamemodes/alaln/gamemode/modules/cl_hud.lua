local addmat_r = Material("ca/add_r")
local addmat_g = Material("ca/add_g")
local addmat_b = Material("ca/add_b")
local vgbm = Material("vgui/black")
-- Credits to Mr. Point
local function DrawCA(rx, gx, bx, ry, gy, by)
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

local function DrawSE()
	local sun = util.GetSunInfo()
	if not sun then return end
	if not sun.obstruction or sun.obstruction == 0 then return end
	local sunpos = EyePos() + sun.direction * 1024 * 4
	local scrpos = sunpos:ToScreen()
	local dot = (sun.direction:Dot(EyeVector()) - 0.8) * 5
	if dot <= 0 then return end
	DrawSunbeams(0.1, 0.15 * dot * sun.obstruction, 0.1, scrpos.x / ScrW(), scrpos.y / ScrH())
end

-- Screen effects
local noisetex, noisetex2 = Material("filmgrain/noise"), Material("filmgrain/noiseadd")
local deathclrmod = {
	["$pp_colour_colour"] = 0,
	["$pp_colour_mulr"] = 1,
}

local Height, Widgth = ScrH(), ScrW()
hook.Add("RenderScreenspaceEffects", "alaln-screffects", function()
	local ply = LocalPlayer()
	if not IsValid(ply) or ply:GetMoveType() == MOVETYPE_NOCLIP then return end
	local frac = 1 - ply:Health() / ply:GetMaxHealth()
	local crazy = ply:GetAlalnState("crazyness") >= 10 and ply:GetAlalnState("crazyness") / 7 or 1
	local clrmod = {
		["$pp_colour_addr"] = 0.05 + 0.01 * crazy,
		["$pp_colour_addb"] = 0.01,
		["$pp_colour_brightness"] = -0.01 - 0.05 * frac,
		["$pp_colour_contrast"] = 0.95 - 0.15 * frac,
		["$pp_colour_colour"] = 0.85 - 0.15 * frac,
		["$pp_colour_mulb"] = -0.45
	}

	if not PotatoMode:GetBool() then
		DrawSE()
		DrawBloom(0.8, 2, 4, 2, 5, 1, 1, 1, 3)
	end

	DrawSharpen(0.75, 0.75)
	DrawMaterialOverlay("fisheyelens", -0.045)
	if ply:Alive() then
		DrawColorModify(clrmod)
		DrawToyTown(1, Height / 4 * frac)
		if ply:WaterLevel() == 3 and not PotatoMode:GetBool() then DrawToyTown(15, ScrH() / 1.5) end
		if ply:Health() <= 40 or ply:WaterLevel() == 3 then DrawMotionBlur(0.6 - 0.2 * frac, 0.8, 0.01) end
		local hp = frac * 8
		DrawCA(15 * hp + 5, 7 * hp + 5, 25, 9 * hp + 5, 6 * hp + 5, -5)
		surface.SetMaterial(noisetex)
		surface.SetDrawColor(190, 0, 0, 25 * frac)
		surface.DrawTexturedRect(0, 0, Widgth, Height)
		surface.SetMaterial(noisetex2)
		surface.SetDrawColor(190, 0, 0, 100)
		surface.DrawTexturedRect(0, 0, Widgth, Height)
	else
		DrawColorModify(deathclrmod)
	end
end)

local alpha_black = Color(20, 0, 0, 75)
local hudfontbig = "alaln-hudfontbig"
local hudfontsmall = "alaln-hudfontsmall"
-- Info HUD
hook.Add("PostDrawHUD", "alaln-realhud", function()
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply:Alive()) then return end
	local hudcolor = Color(150, 0, 0, math.Rand(ply:Health() / ply:GetMaxHealth(), 1) * 255)
	draw.RoundedBox(5, ScrW() / 50, ScrH() - 110, 228, 85, alpha_black)
	draw.SimpleText(ply:Health(), hudfontbig, 153, ScrH() - 64, hudcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	if SBOXMode:GetBool() == false then
		draw.SimpleText("Score: " .. math.Round(ply:GetAlalnState("score"), 0), hudfontsmall, ScrW() * 0.02, ScrH() * 0.79, hudcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Hunger: " .. math.Round(ply:GetAlalnState("hunger"), 0), hudfontsmall, ScrW() * 0.02, ScrH() * 0.88, hudcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		if ply:GetAlalnState("crazyness") >= 10 then draw.SimpleText("Crazyness: " .. math.Round(ply:GetAlalnState("crazyness"), 0), hudfontsmall, ScrW() * 0.02, ScrH() * 0.82, hudcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
	end

	if ply:Armor() > 0 then draw.SimpleText("Armor: " .. ply:Armor(), hudfontsmall, ScrW() * 0.02, ScrH() * 0.85, hudcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
end)

-- Vignette
do
	local vignettemat = Material("illuvignet.png")
	local Crouched = 0
	hook.Add("HUDPaintBackground", "alaln-healthvignette", function()
		local ply = LocalPlayer()
		local frac = ply:GetMaxHealth() - ply:Health()
		if not IsValid(ply) or ply:GetMoveType() == MOVETYPE_NOCLIP then return end
		if ply:KeyDown(IN_DUCK) then
			Crouched = math.Clamp(Crouched + .04, 1, 2)
		else
			Crouched = math.Clamp(Crouched - .04, 1, 2)
		end

		alpha = math.Approach(frac or 200, 0, FrameTime() * 30)
		surface.SetDrawColor(0, 0, 0, 150 * Crouched + alpha)
		surface.SetMaterial(vignettemat)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end)
end

-- Player info hud
local PIClr = {
	nick = Color(220, 220, 220, 200),
	healthy = Color(15, 220, 15, 200),
	wounded = Color(200, 200, 15, 200),
	sevwounded = Color(200, 125, 15, 200),
	barely = Color(165, 15, 15, 200)
}

function GM:HUDDrawTargetID()
	return false
end

hook.Add("HUDPaint", "alaln-playerinfo", function()
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
		elseif health <= 50 then
			healthStatus = "Severely Wounded"
			healthColor = PIClr.sevwounded
		elseif health <= 25 then
			healthStatus = "Barely Standing"
			healthColor = PIClr.barely
		end

		draw.SimpleText(healthStatus, "alaln-hudfontvsmall", pos.x, pos.y + 18, healthColor, TEXT_ALIGN_CENTER)
	end
end)

-- Loot outline
local color_loot = Color(0, 255, 0)
local color_wep = Color(220, 0, 0)
hook.Add("PreDrawHalos", "alaln-loothalo", function()
	if not LocalPlayer():Alive() then return end
	local pos = LocalPlayer():GetPos()
	local entsInRange = ents.FindInSphere(pos, 256)
	local lootEnt, wepEnt = {}, {}
	for _, ent in ipairs(entsInRange) do
		if not IsValid(ent) then return end
		if (string.match(ent:GetClass(), "mann_") or string.match(ent:GetClass(), "alaln_")) and not IsValid(ent:GetOwner()) and not ent:GetNoDraw() then
			if (ent:IsWeapon() and ent:GetMaxClip1() > 0) or ent.Base == "mann_ent_base" then
				table.insert(wepEnt, ent)
			else
				table.insert(lootEnt, ent)
			end
		end
	end

	outline.Add(lootEnt, color_loot, OUTLINE_MODE_BOTH)
	outline.Add(wepEnt, color_wep, OUTLINE_MODE_BOTH)
	outline.SetRenderType(OUTLINE_RENDERTYPE_BEFORE_VM) -- Finally fixed
end)

-- Disable default hud
local BadNames = {
	["CHudHealth"] = false,
	["CHudBattery"] = false,
	["CHudAmmo"] = false,
	["CHudSecondaryAmmo"] = false,
	["CHudCrosshair"] = false,
	["CHudDamageIndicator"] = false,
	["CHudGeiger"] = false,
	["CHudPoisonDamageIndicator"] = false,
	["CHudSquadStatus"] = false,
	["CHudZoom"] = false
}

hook.Add("HUDShouldDraw", "alaln-hidedefaulthud", function(name) return BadNames[name] end)
hook.Add("ScoreboardShow", "alaln-scoreboard", function()
	if SBOXMode:GetBool() == true or not LocalPlayer():Alive() then return end
	return true
end)

-------------------------------------------------------
-- Lens flare (taken from old addon from 2013 by Mahalis and modified by me)
local iris = surface.GetTextureID("effects/lensflare/iris")
local flare = surface.GetTextureID("effects/lensflare/flare")
local color_ring = surface.GetTextureID("effects/lensflare/color_ring")
local bar = surface.GetTextureID("effects/lensflare/bar")
local function mulW(x, f)
	return (x - ScrW() / 2) * f + ScrW() / 2
end

local function mulH(y, f)
	return (y - ScrH() / 2) * f + ScrH() / 2
end

local function CenteredSprite(x, y, sz)
	surface.DrawTexturedRect(x - sz / 2, y - sz / 2, sz, sz)
end

local function DrawFlare()
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply:Alive()) or ply:GetMoveType() == MOVETYPE_NOCLIP or PotatoMode:GetBool() then return end
	local sun = util.GetSunInfo()
	if not sun or not sun.obstruction or sun.obstruction == 0 then return end
	local sunpos = (EyePos() + sun.direction * 4096):ToScreen()
	local rSz = ScrW() * 0.15
	local aMul = math.Clamp((sun.direction:Dot(EyeVector()) - 0.4) * (1 - math.pow(1 - sun.obstruction, 2)), 0, 1) * 2
	if aMul == 0 then return end
	surface.SetTexture(flare)
	surface.SetDrawColor(255, 255, 255, 350 * aMul)
	CenteredSprite(sunpos.x, sunpos.y, rSz * 10)
	surface.SetTexture(color_ring)
	surface.SetDrawColor(255, 255, 255, 800 * math.pow(aMul, 3))
	CenteredSprite(mulW(sunpos.x, 0.5), mulH(sunpos.y, 0.5), rSz * 8)
	surface.SetTexture(bar)
	surface.SetDrawColor(255, 255, 255, 255 * aMul)
	CenteredSprite(mulW(sunpos.x, 1), mulH(sunpos.y, 1), rSz * 5)
	surface.SetTexture(iris)
	surface.SetDrawColor(255, 230, 180, 255 * math.pow(aMul, 3))
	CenteredSprite(mulW(sunpos.x, 1.8), mulH(sunpos.y, 1.8), rSz * 0.15)
	surface.SetDrawColor(255, 230, 180, 255 * math.pow(aMul, 3))
	CenteredSprite(mulW(sunpos.x, 1.82), mulH(sunpos.y, 1.82), rSz * 0.1)
	surface.SetDrawColor(255, 230, 180, 255 * math.pow(aMul, 3))
	CenteredSprite(mulW(sunpos.x, 1.5), mulH(sunpos.y, 1.5), rSz * 0.05)
	surface.SetDrawColor(255, 230, 180, 255 * math.pow(aMul, 3))
	CenteredSprite(mulW(sunpos.x, 0.6), mulH(sunpos.y, 0.6), rSz * 0.05)
	surface.SetDrawColor(255, 230, 180, 255 * math.pow(aMul, 3))
	CenteredSprite(mulW(sunpos.x, 0.59), mulH(sunpos.y, 0.59), rSz * 0.15)
	surface.SetDrawColor(255, 230, 180, 255 * math.pow(aMul, 3))
	CenteredSprite(mulW(sunpos.x, 0.3), mulH(sunpos.y, 0.3), rSz * 0.1)
	surface.SetDrawColor(255, 230, 180, 255 * math.pow(aMul, 3))
	CenteredSprite(mulW(sunpos.x, -0.7), mulH(sunpos.y, -0.7), rSz * 0.1)
	surface.SetDrawColor(255, 230, 180, 255 * math.pow(aMul, 3))
	CenteredSprite(mulW(sunpos.x, -0.72), mulH(sunpos.y, -0.72), rSz * 0.15)
	surface.SetDrawColor(255, 230, 180, 255 * math.pow(aMul, 3))
	CenteredSprite(mulW(sunpos.x, -0.73), mulH(sunpos.y, -0.73), rSz * 0.05)
	surface.SetDrawColor(255, 230, 180, 255 * math.pow(aMul, 3))
	CenteredSprite(mulW(sunpos.x, -0.9), mulH(sunpos.y, -0.9), rSz * 0.1)
	surface.SetDrawColor(255, 230, 180, 255 * math.pow(aMul, 3))
	CenteredSprite(mulW(sunpos.x, -0.92), mulH(sunpos.y, -0.92), rSz * 0.05)
	surface.SetDrawColor(255, 230, 180, 255 * math.pow(aMul, 3))
	CenteredSprite(mulW(sunpos.x, -1.3), mulH(sunpos.y, -1.3), rSz * 0.15)
	surface.SetDrawColor(255, 230, 180, 255 * math.pow(aMul, 3))
	CenteredSprite(mulW(sunpos.x, -1.5), mulH(sunpos.y, -1.5), rSz)
	surface.SetDrawColor(255, 230, 180, 255 * math.pow(aMul, 3))
	CenteredSprite(mulW(sunpos.x, -1.7), mulH(sunpos.y, -1.7), rSz * 0.1)
end

hook.Add("RenderScreenspaceEffects", "alaln-lensflare", DrawFlare)
-------------------------------------------------------
-- Pickup hud
local PickTable = {}
local PickLerp = {}
hook.Add("HUDWeaponPickedUp", "alaln-pickuphud", function(weapon)
	table.insert(PickTable, weapon:GetPrintName())
	timer.Simple(5, function()
		table.remove(PickTable, 1)
		table.remove(PickLerp, 1)
	end)
end)

hook.Add("HUDItemPickedUp", "alaln-pickuphud", function(itemName)
	table.insert(PickTable, "#" .. itemName)
	timer.Simple(5, function()
		table.remove(PickTable, 1)
		table.remove(PickLerp, 1)
	end)
end)

hook.Add("HUDAmmoPickedUp", "alaln-pickuphud", function(ammo, ammout)
	table.insert(PickTable, ammo .. " - " .. ammout)
	timer.Simple(5, function()
		table.remove(PickTable, 1)
		table.remove(PickLerp, 1)
	end)
end)

local ammoclr = Color(160, 0, 0)
hook.Add("HUDDrawPickupHistory", "alaln-pickuphud", function()
	for i = 1, table.Count(PickTable) do
		if PickTable[i] then
			PickLerp[i] = Lerp(5 * FrameTime(), PickLerp[i] or 0, (i - 1) * 40)
			draw.DrawText("Found " .. PickTable[i], "alaln-hudfontsmall", ScrW() - 30, ScrH() / 3 + PickLerp[i], ammoclr, TEXT_ALIGN_RIGHT)
		end
	end
	return false
end)