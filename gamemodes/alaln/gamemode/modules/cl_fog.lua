--!! TODO: Взять потом туман из FPS Saving Fog вместо фога с омнипрожекта
local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector
local DarkLight = GetConVar("alaln_dark_light")
local function CreateFog()
	local ply = LocalPlayer()
	local crazyness, class = ply:GetAlalnState("crazyness"), ply:GetAlalnState("class")
	if DarkLight:GetBool() == true and not ((math.random(1, 24) == 16 and crazyness >= 85) or (class == "Cannibal" and crazyness >= 90)) then
		if ply:GetMoveType() == MOVETYPE_NOCLIP then return false end
		render.FogStart(500)
		render.FogEnd(4000)
		if DarkLight:GetBool() == false then
			render.FogColor(90, 90, 90)
		else
			render.FogColor(5, 5, 10)
		end

		render.FogMaxDensity(1)
		render.FogMode(MATERIAL_FOG_LINEAR)
		return true
	elseif (math.random(1, 24) == 16 and crazyness >= 85) or (class == "Cannibal" and crazyness >= 90) then
		--if ply:GetMoveType() == MOVETYPE_NOCLIP then return false end
		render.FogStart(500)
		render.FogEnd(1500)
		render.FogColor(25, 0, 0)
		render.FogMaxDensity(1)
		render.FogMode(MATERIAL_FOG_LINEAR)
		return true
	else
		return
	end
end

hook_Add("SetupWorldFog", "alaln-fog", CreateFog)
hook_Add("SetupSkyboxFog", "alaln-skyboxfog", CreateFog)