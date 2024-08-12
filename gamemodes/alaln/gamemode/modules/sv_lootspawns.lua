local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, net = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, net
ALALN_LootTable = {
	-- Items
	{"alaln_food", 85},
	{"alaln_tranquilizator", 55},
	{"alaln_garbage", 35},
	{"alaln_armor", 25},
	{"alaln_strangepills", 35},
	{"alaln_phantomloot", 10},
	-- Weapons
	{"mann_ent_akm", 3},
	{"mann_ent_pps43", 4},
	{"mann_ent_m1911", 12},
	{"mann_ent_db", 7},
	{"mann_ent_g17", 8},
	{"mann_ent_hammer", 14},
	{"mann_ent_hatchet", 16},
	{"mann_ent_knife", 20},
	{"mann_ent_pm", 9},
	{"mann_ent_metalbat", 18},
	{"mann_ent_fireaxe", 10},
	{"mann_ent_sw686", 7},
	{"mann_ent_mosin", 6},
	{"mann_wep_flaregun", 4}
}

local SBOXMode = GetConVar("alaln_sboxmode")
local lootCount = 0
local function spawnLoot()
	if SBOXMode:GetBool() then return end
	if lootCount >= 80 then return end
	if not navmesh.IsLoaded() then return end
	local loot = table.Random(ALALN_LootTable)
	if math.random(100) <= loot[2] then
		local item = ents.Create(loot[1])
		if not IsValid(item) then return end
		local navAreas = navmesh.GetAllNavAreas()
		local area = table.Random(navAreas)
		local pos = area:GetRandomPoint() + Vector(math.random(-5, 5), math.random(-5, 5), 10)
		local tr = util.TraceLine({
			start = pos,
			endpos = pos + Vector(0, 0, -10000),
			mask = MASK_WATER
		})

		if tr.Hit then return end
		item:SetPos(pos)
		item:Spawn()
		item.IsLoot = true
		print(item.PrintName or "none", item:GetClass() or "none")
		lootCount = lootCount + 1
		timer.Create("alaln-lootremove-" .. item:EntIndex(), 95, 1, function()
			if not IsValid(item) or item:GetClass() == "alaln_garbage" then return end
			item:Remove()
		end)
	end
end

hook_Add("EntityRemoved", "alaln-lootremove", function(ent, fullUpdate)
	if fullUpdate then return end
	if lootCount and ent:IsValid() and ent.IsLoot then
		lootCount = lootCount - 1
		if timer.Exists("alaln-lootremove-" .. ent:EntIndex()) then timer.Remove("alaln-lootremove-" .. ent:EntIndex()) end
	end
end)

local function spawnLootTimer()
	for i = 1, 24 do
		spawnLoot()
	end

	if lootCount >= 80 then
		timer.Create("alaln-lootspawn", 64, 0, spawnLootTimer)
	else
		timer.Create("alaln-lootspawn", math.random(12, 32), 0, spawnLootTimer)
	end
end

spawnLootTimer()
local function RandArea()
	if not navmesh.IsLoaded() then return end
	local navAreas = navmesh.GetAllNavAreas()
	local indoorAreas = {}
	for _, area in ipairs(navAreas) do
		local pos = area:GetRandomPoint()
		local tr = util.TraceLine({
			start = pos,
			endpos = pos + Vector(0, 0, 10000),
			mask = MASK_OPAQUE
		})

		if not tr.HitSky and tr.Contents ~= CONTENTS_WATER then table.insert(indoorAreas, area) end
	end

	if #indoorAreas > 0 then
		local area = table.Random(indoorAreas)
		return area:GetRandomPoint()
	else
		local area = table.Random(navAreas)
		return area:GetRandomPoint()
	end
end

hook_Add("PlayerSpawn", "alaln-randplyspawn", function(ply)
	if not navmesh.IsLoaded() then return end
	local pos = RandArea()
	ply:SetPos(pos + Vector(math.random(-5, 5), math.random(-5, 5), 10))
end)