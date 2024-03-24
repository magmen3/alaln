local lootTable = {
	{
		"predmetik1", -- че тут хочешь то и ставь :steamhappy:
		100
	},
	{"predmetik2", 75},
	{"predmetik3", 50},
	{"predmetik4", 25}
}

local lootCount = 0
local function spawnLoot()
	if lootCount >= 30 then return end
	local loot = table.Random(lootTable)
	if math.random(100) <= loot[2] then
		local item = ents.Create(loot[1])
		if not IsValid(item) then return end
		local navAreas = navmesh.GetAllNavAreas()
		local area = table.Random(navAreas)
		local pos = area:GetRandomPoint()
		item:SetPos(pos)
		item:Spawn()
		lootCount = lootCount + 1
	end
end

local function spawnLootTimer()
	for i = 1, 5 do
		spawnLoot()
	end

	if lootCount >= 30 then
		timer.Simple(300, spawnLootTimer) -- nonlag system )))
	else
		timer.Simple(math.random(60, 120), spawnLootTimer)
	end
end

spawnLootTimer()