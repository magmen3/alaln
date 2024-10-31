local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, net = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, net
ALALN_NPCTable = {
	-- Monsters (Stage 1)
	{"npc_vj_cofrc_slower1", 40},
	{"npc_vj_cofrc_crawler", 28},
	{"npc_vj_cofrc_monsterblack", 27},
	{"npc_vj_cofrc_faceless_claw", 27},
	{"npc_vj_cofrc_cutter", 31},
	{"npc_vj_cofr_upper", 30},
	{"npc_vj_cofrc_faceless_mummy", 30},
	{"npc_vj_cofrc_sewmo", 29},
	{"npc_vj_cofrc_children", 29},
	{"npc_vj_cofrc_faster", 32},
	{"npc_vj_cofrc_faster2", 32},
	{"npc_vj_cofrc_crazyrunner", 28},
	{"npc_vj_cofr_dreamer", 9},
	{"npc_vj_cofrc_suicider2", 3},
	{"npc_vj_cofr_humanflower", 3},
	{"npc_vj_cofr_watro", 3}
}

ALALN_NPCTable_Stage2 = {
	-- Monsters (Stage 2)
	{"npc_vj_cofraom_twitcher1_hd", 40},
	{"npc_vj_cofraom_twitcher2_hd", 40},
	{"npc_vj_cofraom_twitcher3_hd", 35},
	{"npc_vj_cofraom_twitcher4_hd", 35},
	{"npc_vj_cofraom_wheelchair", 20},
	{"npc_vj_cofrc_slower3_ooi", 20},
	{"npc_vj_cofrc_psycho_le", 15},
	{"npc_vj_cofrc_croucher", 15},
	{"npc_vj_cofraom_handcrab_hd", 10},
	{"npc_vj_cofraom_handcrab", 10},
	{"npc_vj_cofrc_children_hh", 10},
	{"npc_vj_cofraom_ghost_hd", 5},
	{"npc_vj_cofrc_baby_ooi", 5},
	{"npc_vj_cofraom_spitter_hd", 2},
	{"npc_vj_cofraom_spitter", 2},
}

local NPCConVar = GetConVar("alaln_disable_monsters")
local SBOXMode = GetConVar("alaln_sboxmode")
npcCount = 0
local function spawnNPC()
	if SBOXMode:GetBool() or NPCConVar:GetBool() then return end
	if not navmesh.IsLoaded() or npcCount >= 35 then return end
	local npc = GAMEMODE.Stage == 2 and table.Random(ALALN_NPCTable_Stage2) or table.Random(ALALN_NPCTable)
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
		timer.Create("alaln-npcremove-" .. snpc:EntIndex(), 140, 1, function()
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

	if npcCount >= 35 then
		timer.Create("alaln-npcspawn", 35, 0, spawnNPCTimer)
	else
		timer.Create("alaln-npcspawn", math.random(15, 25), 0, spawnNPCTimer)
	end
end

spawnNPCTimer()