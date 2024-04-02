hook.Add("SpawnMenuOpen", "alaln-spawnmenu", function() if SBOXMode:GetInt() == 0 then return false end end)
hook.Add("ContextMenuOpen", "alaln-contextmenu", function() if SBOXMode:GetInt() == 0 then return false end end)
hook.Add("PlayerNoClip", "alaln-noclip", function(ply, desiredState) return SBOXMode:GetBool() end)
hook.Add("PlayerSpray", "alaln-sprays", function() return true end)
-- format: multiline
local BadSpawns = {
	"PlayerGiveSWEP",
	"PlayerSpawnEffect",
	"PlayerSpawnNPC",
	"PlayerSpawnObject",
	"PlayerSpawnProp",
	"PlayerSpawnRagdoll",
	"PlayerSpawnSENT",
	"PlayerSpawnSWEP",
	"PlayerSpawnVehicle"
}

-- disables spawn console exploit
local function BlockSpawn(ply)
	if not SBOXMode:GetBool() then BetterChatPrint(ply, "Don't do that.", color_red2) end
	return SBOXMode:GetBool()
end

for _, v in ipairs(BadSpawns) do
	hook.Add(v, "alaln-blockspawn", BlockSpawn)
end