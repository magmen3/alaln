ALALN_LootTable = {
	-- Items
	{"alaln_food", 85},
	{"alaln_tranquilizator", 45},
	{"alaln_armor", 20},
	-- Monsters
	{"npc_vj_cofr_slower1", 25},
	{"npc_vj_cofr_crawler", 18},
	{"npc_vj_cofrc_crazyrumpel", 23},
	{"npc_vj_cofrc_cutter", 21},
	{"npc_vj_cofr_upper", 20},
	{"npc_vj_cofraom_handcrab", 16},
	{"npc_vj_cofrc_slowerno_boss", 16},
	{"npc_vj_cofrc_faceless_boss", 15},
	{"npc_vj_cofr_dreamer_runner", 15},
	{"npc_vj_cofr_faster_male", 15},
	{"npc_vj_cofr_crazyrunner", 14},
	{"npc_vj_cofraom_hellhound", 8},
	{"npc_vj_cofr_dreamer", 6},
	{"npc_vj_cofr_humanflower", 2},
	-- Weapons
	{"mann_ent_akm", 4},
	{"mann_ent_m1911", 12},
	{"mann_ent_db", 7},
	{"mann_ent_g17", 8},
	{"mann_ent_hatchet", 16},
	{"mann_ent_knife", 20},
	{"mann_ent_pm", 9},
	{"mann_ent_metalbat", 18},
	{"mann_ent_sw686", 7},
	{"mann_ent_sako98", 6},
}

local SBOXMode = GetConVar("alaln_sboxmode")
local lootCount = 0
local function spawnLoot()
	if SBOXMode:GetBool() then return end
	if lootCount >= 45 then return end
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
		print(item.PrintName or "none", item:GetClass() or "none")
		lootCount = lootCount + 1
	end
end

local function spawnLootTimer()
	for i = 1, 25 do
		spawnLoot()
	end

	if lootCount >= 45 then
		timer.Simple(250, spawnLootTimer)
	else
		timer.Simple(math.random(24, 95), spawnLootTimer)
	end
end

spawnLootTimer()
local function RandArea()
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

hook.Add("PlayerSpawn", "alaln-randplyspawn", function(ply)
	local pos = RandArea()
	ply:SetPos(pos + Vector(math.random(-5, 5), math.random(-5, 5), 10))
end)