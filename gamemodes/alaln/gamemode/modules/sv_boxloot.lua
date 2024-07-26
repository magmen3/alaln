ALALN_LootBoxTable = {
	-- Items
	{"alaln_food", 80},
	{"alaln_tranquilizator", 65},
	{"alaln_strangepills", 45},
	-- Weapons
	{"mann_ent_m1911", 12},
	{"mann_ent_g17", 9},
	{"mann_ent_hatchet", 16},
	{"mann_ent_knife", 20},
	{"mann_ent_hammer", 14},
	{"mann_ent_pm", 10},
	{"mann_ent_metalbat", 18},
	{"mann_ent_sw686", 6},
	{"alaln_flamethrower", 1},
}

ALALN_LootBoxModels = {
	-- Crates
	["models/props_junk/wood_crate001a.mdl"] = true,
	["models/props_junk/wood_crate001a_damaged.mdl"] = true,
	["models/props_junk/wood_crate002a.mdl"] = true,
	["models/props_junk/cardboard_box001a.mdl"] = true,
	["models/props_junk/cardboard_box001b.mdl"] = true,
	["models/props_junk/cardboard_box002a.mdl"] = true,
	["models/props_junk/cardboard_box002b.mdl"] = true,
	["models/props_junk/cardboard_box003a.mdl"] = true,
	["models/props_junk/cardboard_box003b.mdl"] = true,
	["models/props_lab/dogobject_wood_crate001a_damagedmax.mdl"] = true,
	["models/props_c17/FurnitureDresser001a.mdl"] = true,
	["models/props_c17/FurnitureDrawer001a.mdl"] = true
}

local function spawnLoot(ply, ent)
	if ALALN_LootBoxModels[ent:GetModel()] then
		local chance = math.random(1, 100)
		for _, loot in pairs(ALALN_LootBoxTable) do
			if chance <= loot[2] then
				local item = ents.Create(loot[1])
				item:SetPos(ent:GetPos())
				item:Spawn()
				break
			else
				chance = chance - loot[2]
			end
		end

		if math.random(1, 100) <= 10 then
			for i = 1, math.random(1, 3) do
				local item = ents.Create(table.Random(ALALN_LootBoxTable)[1])
				item:SetPos(ent:GetPos())
				item:Spawn()
			end
		end
	end
end

hook.Add("EntityTakeDamage", "alaln-lootboxes", function(ent, dmg)
	if ALALN_LootBoxModels[ent:GetModel()] and ent:Health() - dmg:GetDamage() <= 0 then
		spawnLoot(dmg:GetAttacker(), ent)
	end
end)