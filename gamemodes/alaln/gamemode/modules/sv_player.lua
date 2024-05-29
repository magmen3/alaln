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

	ply:SetNWString("alaln-class", "Psychopath")
	ply:SetAlalnState("score", 0)
end)

local color_yellow = Color(255, 170, 0)
function GM:PlayerLoadout(ply)
	ply:SetAlalnState("hunger", 100)
	ply:SetAlalnState("crazyness", 0)
	ply:SetMaxHealth(150)
	ply:SetHealth(150)
	ply:SetWalkSpeed(160)
	ply:SetMaxSpeed(300)
	ply:SetJumpPower(180)
	ply:SetDuckSpeed(0.4)
	ply:SetUnDuckSpeed(0.4)
	ply:SetCrouchedWalkSpeed(0.6)
	ply:SetAlalnState("stamina", 50)
	ply:AllowFlashlight(false)
	ply:Flashlight(false)
	ply:SetCanZoom(false)
	ply:StopZooming()
	--ply:SetNWVector("ScrShake", vector_origin)
	ply:GodDisable()
	ply:SetTeam(1)
	ply:SetMaterial()
	ply:SetSubMaterial()
	ply:SetNWBool("HasArmor", false)
	if SBOXMode:GetInt() == 1 then
		ply:Give("weapon_physgun")
		ply:Give("gmod_tool")
	else
		ply:Give("alaln_lighter")
	end

	local class = ply:GetAlalnState("class")
	if class ~= "Psychopath" then
		BetterChatPrint(ply, "You are " .. class .. ".", color_red2)
	elseif class == "Psychopath" then
		BetterChatPrint(ply, "Your goal is to survive in this rotten place, and to do so for as long as possible.", color_yellow)
	elseif class == "Berserker" then
		ply:Give("alaln_fists")
		ply:SetMaxHealth(120)
		ply:SetHealth(120)
		ply:SetSubMaterial(0, "models/in/other/corpse1_player_charple")
		BetterChatPrint(ply, "Your goal is to survive with your perfectly honed melee weapon killing skill, while being pretty bad with firearms.", color_yellow)
	elseif class == "Cannibal" then
		ply:SetMaxHealth(100)
		ply:SetHealth(100)
		ply:Give("alaln_cannibalism")
		ply:SetAlalnState("crazyness", math.random(6, 18))
		ply:SetAlalnState("hunger", math.random(55, 75))
		ply:SetSubMaterial(0, "models/screamer/corpse9")
		BetterChatPrint(ply, "Your only goal is to kill to live, you cannot consume any other food than human flesh, and you harbor a hatred for all living things in this rotten world.", color_yellow)
	end

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
	if phys:IsValid() then phys:SetMass(95) end
	ply:ScreenFade(SCREENFADE.IN, color_black, 3, 0)
end

function GM:PlayerSetModel(ply)
	ply:SetModel(Model("models/player/corpse1.mdl"))
	ply:SetPlayerColor((ply:GetPlayerColor() * 0.85) or VectorRand(0.15, 0.75))
end

do
	-- name override for npc classes
	local NPCNames = {
		npc_zombie = "Zombie",
		npc_headcrab = "Headcrab",
		npc_metropolice = "Metrocop",
		npc_combine_s = "Combine",
		entityflame = "magic of fire"
	}

	local clr_blur = Color(100, 25, 25, 25)
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

		victim:SetDSP(31)
		if IsValid(attacker) and attacker:IsPlayer() then
			attacker:ScreenFade(SCREENFADE.IN, clr_blur, 0.5, 0)
			attacker:AddAlalnState("score", math.random(2, 5))
			attacker:AddAlalnState("crazyness", math.random(8, 24))
			if attacker:GetAlalnState("crazyness") >= 20 and attacker:GetAlalnState("crazyness") <= 40 and math.random(2, 4) == 2 then
				BetterChatPrint(attacker, "You feel terrible...", color_red)
			elseif attacker:GetAlalnState("crazyness") >= 60 and math.random(2, 6) == 4 then
				BetterChatPrint(attacker, "You feel satisfied.", color_red)
				attacker:AddAlalnState("crazyness", math.random(4, 16))
				attacker:AddAlalnState("hunger", -math.random(4, 16))
			end
		end
	end)
end

hook.Add("OnNPCKilled", "alaln-npcdeath", function(npc, attacker, inflictor)
	if attacker:IsPlayer() then
		attacker:ScreenFade(SCREENFADE.IN, clr_blur, 0.5, 0)
		attacker:AddAlalnState("score", math.random(1, 6))
	end
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

do
	-- format: multiline
	local randkillstrings = {
		"You bit your tongue and fell unconscious.",
		"You pushed your fingers into your eyes, realizing there was no escaping this anyway."
	}

	function GM:CanPlayerSuicide(ply)
		if not ply:Alive() then return false end
		BetterChatPrint(ply, table.Random(randkillstrings), color_red)
		return true
	end
end

do
	local usecd = 0
	local randvehstrings = {"It seems that you don't know how to use this thing.", "You don't really know how to use that thing.", "Do you really expect something from this garbage?", "You can't escape anyway. Even on this thing.", "There's not even gasoline in this thing."}
	function GM:CanPlayerEnterVehicle(ply, vehicle, role)
		if usecd > CurTime() then return false end
		BetterChatPrint(ply, table.Random(randvehstrings), color_red)
		usecd = CurTime() + 2
		return false
	end
end

do
	local deathsounds = {"vo/npc/male01/pain07.wav", "vo/npc/male01/pain09.wav", "vo/npc/male01/no02.wav"}
	hook.Add("PlayerDeathSound", "alaln-deathsound", function(ply)
		sound.Play(table.Random(deathsounds), ply:GetNWEntity("plyrag"):GetPos(), 100, math.random(95, 105))
		return true
	end)
end

do
	local dropstrings = {
		["*drop"] = true,
		["/drop"] = true,
		["!drop"] = true,
		["/dropweapon"] = true,
		["!dropweapon"] = true
	}

	local function DropWep(ply)
		local wep = ply:GetActiveWeapon()
		if IsValid(ply) and ply:Alive() and wep ~= nil and wep ~= NULL and wep.Droppable then ply:DropWeapon(wep) end
	end

	concommand.Add("drop", DropWep)
	concommand.Add("dropweapon", DropWep)
	concommand.Add("-drop", DropWep)
	concommand.Add("-dropweapon", DropWep)
	hook.Add("PlayerSay", "alaln-dropweapon", function(ply, text)
		if dropstrings[text] then
			DropWep(ply)
			return false
		end
	end)
end