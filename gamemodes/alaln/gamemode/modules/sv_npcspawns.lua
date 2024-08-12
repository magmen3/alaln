local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, net = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, net
ALALN_NPCTable = {
	-- Monsters
	{"npc_vj_cofr_slower1", 40},
	{"npc_vj_cofr_crawler", 28},
	{"npc_vj_cofrc_cutter", 31},
	{"npc_vj_cofr_upper", 30},
	{"npc_vj_cofr_faster_male", 32},
	{"npc_vj_cofr_crazyrunner", 28},
	{"npc_vj_cofr_dreamer", 9},
	{"npc_vj_cofr_suicider", 3},
	{"npc_vj_cofr_humanflower", 4}
}

local NPCConVar = GetConVar("alaln_disable_monsters")
local SBOXMode = GetConVar("alaln_sboxmode")
local npcCount = 0
local function spawnNPC()
	if SBOXMode:GetBool() then return end
	if NPCConVar:GetBool() then return end
	if not navmesh.IsLoaded() then return end
	if npcCount >= 24 then return end
	local npc = table.Random(ALALN_NPCTable)
	if math.random(100) <= npc[2] then
		local snpc = ents.Create(npc[1])
		if not IsValid(snpc) then return end
		local navAreas = navmesh.GetAllNavAreas()
		local area = table.Random(navAreas)
		local pos = area:GetRandomPoint() + Vector(math.random(-5, 5), math.random(-5, 5), 10)
		local tr = util.TraceLine({
			start = pos,
			endpos = pos + Vector(0, 0, -10000),
			mask = MASK_WATER
		})

		if tr.Hit then return end
		snpc:SetPos(pos)
		snpc:Spawn()
		print(snpc.PrintName or "none", snpc:GetClass() or "none")
		npcCount = npcCount + 1
		timer.Create("alaln-npcremove-" .. snpc:EntIndex(), 120, 1, function()
			if not IsValid(snpc) then return end
			snpc:Remove()
		end)
	end
end

hook_Add("EntityRemoved", "alaln-npcremove", function(ent, fullUpdate)
	if NPCConVar:GetBool() then return end
	if fullUpdate then return end
	if npcCount and ent:IsValid() then
		npcCount = npcCount - 1
		if timer.Exists("alaln-npcremove-" .. ent:EntIndex()) then timer.Remove("alaln-npcremove-" .. ent:EntIndex()) end
	end
end)

local function spawnNPCTimer()
	if not navmesh.IsLoaded() then return end
	if NPCConVar:GetBool() then return end
	for i = 1, 18 do
		spawnNPC()
	end

	if npcCount >= 24 then
		timer.Create("alaln-npcspawn", 64, 0, spawnNPCTimer)
	else
		timer.Create("alaln-npcspawn", math.random(12, 32), 0, spawnNPCTimer)
	end
end

spawnNPCTimer()