local addmat_r = Material("ca/add_r")
local addmat_g = Material("ca/add_g")
local addmat_b = Material("ca/add_b")
local vgbm = Material("vgui/black")
-- credits to Mr. Point
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
	if not sun.obstruction == 0 or sun.obstruction == 0 then return end
	local sunpos = EyePos() + sun.direction * 1024 * 4
	local scrpos = sunpos:ToScreen()
	local dot = (sun.direction:Dot(EyeVector()) - 0.8) * 5
	if dot <= 0 then return end
	DrawSunbeams(0.1, 0.15 * dot * sun.obstruction, 0.1, scrpos.x / ScrW(), scrpos.y / ScrH())
end

-- screen effects
local noisetex = Material("filmgrain/noise")
local noisetex2 = Material("filmgrain/noiseadd")
local deathclrmod = {
	["$pp_colour_colour"] = 0,
	["$pp_colour_mulr"] = 1,
}

hook.Add("RenderScreenspaceEffects", "alaln-screffects", function()
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply:Alive()) or ply:GetMoveType() == MOVETYPE_NOCLIP then return end
	local frac = 1 - ply:Health() / ply:GetMaxHealth()
	local crazy = ply:GetCrazyness() >= 10 and ply:GetCrazyness() / 7 or 1
	local clrmod = {
		["$pp_colour_addr"] = 0.05 + 0.01 * crazy,
		["$pp_colour_addb"] = 0.01,
		["$pp_colour_brightness"] = -0.01 - 0.05 * frac,
		["$pp_colour_contrast"] = 0.95 - 0.15 * frac,
		["$pp_colour_colour"] = 0.85 - 0.15 * frac,
		["$pp_colour_mulb"] = -0.45
	}

	DrawSE()
	DrawBloom(0.8, 2, 4, 2, 5, 1, 1, 1, 3)
	DrawSharpen(0.75, 0.75)
	DrawMaterialOverlay("fisheyelens", -0.045)
	if ply:Alive() then
		DrawColorModify(clrmod)
		DrawToyTown(1, ScrH() / 4 * frac)
		if ply:Health() <= 40 then DrawMotionBlur(0.6 - 0.2 * frac, 0.8, 0.01) end
		local hp = frac * 8
		DrawCA(15 * hp + 5, 7 * hp + 5, 25, 9 * hp + 5, 6 * hp + 5, -5)
		surface.SetMaterial(noisetex)
		surface.SetDrawColor(165, 0, 0, 25 * frac)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		surface.SetMaterial(noisetex2)
		surface.SetDrawColor(165, 0, 0, 25 * frac)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	else
		DrawColorModify(deathclrmod)
	end
end)

local alpha_black = Color(20, 0, 0, 75)
local hudfontbig = "alaln-hudfontbig"
local hudfontsmall = "alaln-hudfontsmall"
-- hud
hook.Add("PostDrawHUD", "alaln-realhud", function()
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply:Alive()) then return end
	local hudcolor = Color(150, 0, 0, math.Rand(ply:Health() / ply:GetMaxHealth(), 1) * 255)
	draw.RoundedBox(5, ScrW() / 50, ScrH() - 110, 228, 85, alpha_black)
	draw.SimpleText(ply:Health(), hudfontbig, 153, ScrH() - 64, hudcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	if SBOXMode:GetBool() == false then
		draw.SimpleText("Score: " .. math.Round(ply:GetScore(), 0), hudfontsmall, ScrW() * 0.02, ScrH() * 0.79, hudcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Hunger: " .. math.Round(ply:GetHunger(), 0), hudfontsmall, ScrW() * 0.02, ScrH() * 0.88, hudcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		if ply:GetCrazyness() >= 10 then draw.SimpleText("Crazyness: " .. math.Round(ply:GetCrazyness(), 0), hudfontsmall, ScrW() * 0.02, ScrH() * 0.82, hudcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
	end

	if ply:Armor() > 0 then draw.SimpleText("Armor: " .. ply:Armor(), hudfontsmall, ScrW() * 0.02, ScrH() * 0.85, hudcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
end)

-- vignette
hook.Add("HUDPaintBackground", "alaln-healthvignette", function()
	local ply = LocalPlayer()
	local frac = ply:GetMaxHealth() - ply:Health()
	if not IsValid(ply) or ply:GetMoveType() == MOVETYPE_NOCLIP then return end
	alpha = math.Approach(frac or 200, 0, FrameTime() * 30)
	surface.SetDrawColor(0, 0, 0, 150 + alpha)
	surface.SetMaterial(Material("illuvignet.png"))
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
end)

-- player info hud
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

-- loot outline
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

	outline.SetRenderType(OUTLINE_RENDERTYPE_AFTER_EF)
	outline.Add(lootEnt, color_loot, OUTLINE_MODE_BOTH)
	outline.Add(wepEnt, color_wep, OUTLINE_MODE_BOTH)
	outline.SetRenderType(OUTLINE_RENDERTYPE_AFTER_EF)
end)

-- disable default hud
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