-- format: multiline
local plyspawns = {
	["gm_construct"] = {
		Vector(
			1051, 
			-1362, 
			-79
		),
		Vector(
			1186, 
			-484, 
			-79
		),
		Vector(
			707, 
			4369, 
			-31
		),
		Vector(
			-4011, 
			5235, 
			-31
		),
		Vector(
			-2999, 
			-1161, 
			112
		),
		Vector(
			-2287, 
			-2394, 
			290
		),
		Vector(
			-5384, 
			-3337, 
			290
		)
	}
}

hook.Add("PlayerSpawn", "alaln-randomplyspawn", function(ply)
	if SBOXMode:GetBool() == true then return end
	if plyspawns[game.GetMap()] then ply:SetPos(table.Random(plyspawns[game.GetMap()])) end
end)

----------------------------------------------------------------------------------------
util.AddNetworkString("DrawProps")
PropSpawnTable = {} --Будем узнавать колво
local PropLoot = {
	[1] = {
		Type = "npcs_stage1",
		Loot = {"npc_vj_cofraom_twitcher_da"}
	},
	[2] = {
		Type = "npcs_stage1",
		Loot = {"npc_vj_cofr_slower1", "npc_vj_cofr_slower3", "npc_vj_cofr_faster_male", "npc_vj_cofr_crazyrunner"}
	},
	[3] = {
		Type = "loot",
		Loot = {"mann_ent_metalbat", "mann_ent_hatchet", "mann_ent_g17", "alaln_food", "alaln_armor"}
	}
}

function SpawnPropTimer()
	if SBOXMode:GetBool() == true then return end
	local navmeshareas = navmesh.GetAllNavAreas()
	if not (#PropSpawnTable >= 32) then
		local Randompos = navmeshareas[math.random(#navmeshareas)]:GetCenter()
		--[[for k,v in ipairs(ents.FindInPVS(Randompos)) do
			if v:IsPlayer() then

				SpawnPropTimer()

				return 
			end
		end]]
		local rand = math.random(1, 2)
		local RandTable = PropLoot[rand]
		local prop
		if RandTable.Type == "prop_physics" then
			prop = ents.Create(RandTable.Type)
			prop:SetModel(RandTable.Loot[math.random(#RandTable.Loot)])
		else
			prop = ents.Create(RandTable.Loot[math.random(#RandTable.Loot)])
		end

		print(" CREATED:", RandTable.Type, prop:GetClass())
		if not IsValid(prop) then return end
		prop:Spawn()
		prop:SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
		local mins = prop:OBBMins()
		local maxs = prop:OBBMaxs()
		local dir = prop:GetUp()
		local len = 60
		local tr = util.TraceHull({
			start = Randompos + dir * len,
			endpos = vector_origin,
			mins = mins,
			maxs = maxs,
		})

		if tr.HitWorld then
			prop:Remove()
			SpawnPropTimer()
			return
		end

		local SpawnPos = Randompos + Vector(0, 0, maxs.z - mins.z)
		prop:SetPos(SpawnPos)
		--Entity(1):SetPos(prop:GetPos())
		--print(prop:GetPos())
		timer.Simple(2, function()
			if not IsValid(prop) then return end
			prop:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		end)

		table.insert(PropSpawnTable, prop)
		prop:CallOnRemove("TableRemove", function() table.RemoveByValue(PropSpawnTable, prop) end)
		net.Start("DrawProps")
		net.WriteTable(PropSpawnTable)
		net.Broadcast()
	else
		timer.Remove("prop_spawn")
		timer.Create("prop_remove", 60, 0, RemovePropTimer)
	end
end

function RemovePropTimer()
	if SBOXMode:GetBool() == true then return end
	if #PropSpawnTable >= 64 then
		local prop = table.Random(PropSpawnTable)
		print(" REMOVED:", prop:GetClass())
		prop:Remove()
	else
		timer.Remove("prop_remove")
		timer.Create("prop_spawn", 3, 0, SpawnPropTimer)
	end
end

hook.Add("PostCleanupMap", "RandomLootDelete", function()
	if SBOXMode:GetBool() == true then return end
	PropSpawnTable = {}
	timer.Remove("prop_remove")
	timer.Remove("prop_spawn")
	timer.Create("prop_spawn", 3, 0, SpawnPropTimer)
end)