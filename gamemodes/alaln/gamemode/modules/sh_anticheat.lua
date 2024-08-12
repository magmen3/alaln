local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, net = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, net
hook_Add("SpawnMenuOpen", "alaln-spawnmenu", function()
	return SBOXMode:GetBool() --if SBOXMode:GetInt() == 0 then return false end end)
end)

hook_Add("ContextMenuOpen", "alaln-contextmenu", function()
	return SBOXMode:GetBool() --function() if SBOXMode:GetInt() == 0 then return false end end)
end)

hook_Add("PlayerNoClip", "alaln-noclip", function()
	return SBOXMode:GetBool() --function(ply, desiredState) return SBOXMode:GetBool() end)
end)

hook_Add("PlayerSpray", "alaln-sprays", function() return true end)
do
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

	local color_red = Color(185, 15, 15)
	-- disables spawn console exploit
	local function BlockSpawn(ply)
		if not SBOXMode:GetBool() then BetterChatPrint(ply, "Don't do that.", color_red) end
		return SBOXMode:GetBool()
	end

	for _, v in ipairs(BadSpawns) do
		hook_Add(v, "alaln-blockspawn", BlockSpawn)
	end
end

local function RemoveEnts()
	if SBOXMode:GetBool() then return end
	for k, ent in ents.Iterator do
		if not IsValid(ent) then return end
		if ent:IsWeapon() or ent:GetClass():match("^weapon_") or ent:GetClass():match("^item_") then ent:Remove() end
	end
end

hook_Add("InitPostEntity", "alaln-removeents", RemoveEnts)
hook_Add("PostCleanupMap", "alaln-removeents", RemoveEnts)