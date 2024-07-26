--!! Надо взять потом туман из FPS Saving Fog вместо фога с омнипрожекта

local DarkLight = GetConVar("alaln_dark_light")
local function CreateFog()
	if DarkLight:GetBool() == false then return end
	local ply = LocalPlayer()
	if ply:GetMoveType() == MOVETYPE_NOCLIP then return false end
	render.FogStart(500)
	render.FogEnd(4000)
	render.FogColor(90, 90, 90)
	render.FogMaxDensity(1)
	render.FogMode(MATERIAL_FOG_LINEAR)
	return true
end

hook.Add("SetupWorldFog", "alaln-fog", CreateFog)
hook.Add("SetupSkyboxFog", "alaln-skyboxfog", CreateFog)