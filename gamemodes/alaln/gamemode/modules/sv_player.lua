local color_red = Color(180, 0, 0)
local color_red2 = Color(165, 0, 0)
hook.Add("PlayerInitialSpawn", "alaln-initialspawn", function(ply)
	if not navmesh.IsLoaded() then
		MsgC(color_red, " [ALALN] Navmesh not found! This map does not support Forsakened gamemode.\n")
		BetterChatPrint(ply, "Navmesh not found! This map does not support Forsakened gamemode.", color_red)
		if ply:IsListenServerHost() then
			net.Start("alaln-navmeshnotfound")
			net.Send(ply)
		end
	end

	ply:SetNWString("alaln-class", "Standard")
	ply:SetScore(0)
end)

function GM:PlayerLoadout(ply)
	ply:SetHunger(100)
	ply:SetCrazyness(0)
	ply:SetMaxHealth(150)
	ply:SetHealth(150)
	ply:SetWalkSpeed(160)
	ply:SetMaxSpeed(300)
	ply:SetJumpPower(180)
	ply:SetDuckSpeed(0.4)
	ply:SetUnDuckSpeed(0.4)
	ply:SetCrouchedWalkSpeed(0.6)
	ply:AllowFlashlight(false)
	ply:Flashlight(false)
	ply:SetCanZoom(false)
	ply:StopZooming()
	--ply:SetNWVector("ScrShake", vector_origin)
	ply:SetSubMaterial()
	ply:GodDisable()
	ply:SetTeam(1)
	ply:SetMaterial()
	ply:SetNWBool("HasArmor", false)
	ply.NextSpawnTime = CurTime() + 5
	if SBOXMode:GetInt() == 1 then
		ply:Give("weapon_physgun")
		ply:Give("gmod_tool")
	else
		ply:Give("alaln_lighter")
	end

	if ply:GetNWString("alaln-class", "Standard") == "Berserker" then
		ply:Give("alaln_fists")
		ply:SetMaxHealth(120)
		ply:SetHealth(120)
	end

	if ply:GetNWString("alaln-class", "Standard") == "Cannibal" then
		ply:SetMaxHealth(100)
		ply:SetHealth(100)
		ply:SetCrazyness(math.random(6, 18))
		ply:SetHunger(math.random(55, 75))
		ply:SetMaterial("models/screamer/corpse9")
	end

	if ply:GetNWString("alaln-class", "Standard") ~= "Standard" then BetterChatPrint(ply, "You are " .. ply:GetNWString("alaln-class", "Standard") .. ".", color_red2) end
	local size = 12
	local DEFAULT_VIEW_OFFSET = Vector(0, 0, 64)
	local DEFAULT_VIEW_OFFSET_DUCKED = Vector(0, 0, 42)
	ply:SetNWVector("HullMin", Vector(-size, -size, 0))
	ply:SetNWVector("Hull", Vector(size, size, DEFAULT_VIEW_OFFSET[3]))
	ply:SetNWVector("HullDuck", Vector(size, size, DEFAULT_VIEW_OFFSET_DUCKED[3]))
	ply:SetHull(ply:GetNWVector("HullMin"), ply:GetNWVector("Hull"))
	ply:SetHullDuck(ply:GetNWVector("HullMin"), ply:GetNWVector("HullDuck"))
	ply:SetViewOffset(DEFAULT_VIEW_OFFSET)
	ply:SetViewOffsetDucked(DEFAULT_VIEW_OFFSET_DUCKED)
	ply.SetHull = true
	local phys = ply:GetPhysicsObject()
	if phys:IsValid() then phys:SetMass(80) end
	ply:ScreenFade(SCREENFADE.IN, color_black, 3, 0)
end

function GM:PlayerSetModel(ply)
	ply:SetModel("models/player/corpse1.mdl")
	ply:SetPlayerColor(ply:GetPlayerColor() * 0.85)
end

-- name override for npc classes
local NPCNames = {
	npc_zombie = "Zombie",
	npc_headcrab = "Headcrab",
	npc_metropolice = "Metrocop",
	npc_combine_s = "Combine",
	entityflame = "magic of fire"
}

hook.Add("PlayerDeath", "alaln-plydeath", function(victim, inflictor, attacker)
	for _, ply in player.Iterator() do
		if IsValid(attacker) and victim ~= attacker then
			local attclass = attacker:GetClass()
			local attname = attacker:IsPlayer() and attacker:Name() or NPCNames[attclass] or attacker.PrintName or attacker:GetClass()
			BetterChatPrint(ply, victim:Name() .. " was killed by " .. attname .. ".", color_red2)
		else
			BetterChatPrint(ply, victim:Name() .. " died.", color_red2)
		end
	end

	if IsValid(attacker) and attacker:IsPlayer() then
		attacker:AddScore(math.random(3, 8))
		attacker:AddCrazyness(math.random(8, 24))
		if attacker:GetCrazyness() >= 20 and attacker:GetCrazyness() <= 40 and math.random(2, 4) == 2 then
			BetterChatPrint(attacker, "You feel terrible...", color_red)
		elseif attacker:GetCrazyness() >= 60 and math.random(2, 6) == 4 then
			BetterChatPrint(attacker, "You feel satisfied.", color_red)
			attacker:AddCrazyness(math.random(4, 16))
			attacker:AddHunger(-math.random(4, 16))
		end
	end

	victim.NextSpawnTime = CurTime() + 5
end)

hook.Add("PlayerConnect", "alaln-joinmessage", function(name, ip)
	for _, ply in player.Iterator() do
		BetterChatPrint(ply, name .. " Joining the hell.", color_red)
	end
end)

function GM:PlayerDeathThink(ply)
	ply:ScreenFade(SCREENFADE.OUT, color_black, 2.5, 0.5)
	if ply.NextSpawnTime and ply.NextSpawnTime > CurTime() then
		return
	else
		if ply:IsBot() or ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP) then ply:Spawn() end
	end
end

local randkillstrings = {"You already dead.", "Suicide is not escape.", "This does not help you", "You can't escape from this", "NO"}
local usecd = 0
function GM:CanPlayerSuicide(ply)
	if usecd > CurTime() then return false end
	BetterChatPrint(ply, table.Random(randkillstrings), color_red)
	usecd = CurTime() + 2
	return false
end

local randvehstrings = {"It seems that you don't know how to use this thing.", "You don't really know how to use that thing.", "Do you really expect something from this garbage?", "You can't escape anyway. Even on this thing.", "There's not even gasoline in this thing."}
function GM:CanPlayerEnterVehicle(ply, vehicle, role)
	if usecd > CurTime() then return false end
	BetterChatPrint(ply, table.Random(randvehstrings), color_red)
	usecd = CurTime() + 2
	return false
end