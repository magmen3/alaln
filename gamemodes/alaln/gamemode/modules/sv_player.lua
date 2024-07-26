local hook_Add, math, Color, Vector = hook.Add, math, Color, Vector
local color_red = Color(180, 0, 0)
local color_red2 = Color(165, 0, 0)
hook_Add("PlayerInitialSpawn", "alaln-initialspawn", function(ply)
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
	if SBOXMode:GetBool() then
		ply:EmitSound("garrysmod/save_load" .. math.random(1, 3) .. ".wav")
	else
		ply:EmitSound("ambient/levels/citadel/strange_talk" .. math.random(1, 11) .. ".wav")
	end
end)

local color_yellow = Color(255, 170, 0)
local berserkmat = "models/in/other/corpse1_player_charple"
local cannibalmat = "models/in/other/corpse1_player_charple"
function GM:PlayerLoadout(ply)
	ply:SetAlalnState("hunger", 100)
	ply:SetAlalnState("crazyness", 0)
	ply:SetMaxHealth(150)
	ply:SetHealth(150)
	ply:SetWalkSpeed(160)
	ply:SetMaxSpeed(300)
	ply:SetJumpPower(220)
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
	ply.NextSpawnTime = CurTime() + 5
	if SBOXMode:GetBool() then
		ply:Give("weapon_physgun")
		ply:Give("gmod_tool")
		ply:SetAlalnState("score", 6666)
	else
		ply:Give("alaln_lighter")
		for i = 1, 3 do
			if ply:GetAlalnState("score") >= 2000 then ply:SetAlalnState("score", 0) end
		end
	end

	local class = ply:GetAlalnState("class")
	if class ~= "Psychopath" then
		BetterChatPrint(ply, "You are " .. class .. ".", color_red2)
	elseif class == "Psychopath" then
		ply:Give("alaln_hands")
		ply:SetAlalnState("crazyness", math.random(2, 6))
		BetterChatPrint(ply, "Your goal is to survive in this rotten place, and to do so for as long as possible.", color_yellow)
	end

	if class == "Faster" then
		ply:Give("alaln_hands")
		ply:SetAlalnState("crazyness", math.random(3, 7))
		ply:SetAlalnState("hunger", math.random(85, 95))
		ply:SetMaxHealth(80)
		ply:SetHealth(80)
		BetterChatPrint(ply, "Before the madness outbreak, you were an athlete, and you ran well. Now you're gonna need that while you're still alive.", color_yellow)
	elseif class == "Gunslinger" then
		ply:Give("alaln_hands")
		ply:SetMaxHealth(101)
		ply:SetHealth(101)
		--ply:SetArmor(10)
		ply:SetSubMaterial(0, berserkmat)
		ply:SetAlalnState("crazyness", math.random(8, 12))
		BetterChatPrint(ply, "Before the madness outbreak, you were fascinated with guns, how they work, and how to shoot with them. This knowledge will save your life in this rotten world.", color_yellow)
	elseif class == "Berserker" then
		ply:Give("alaln_fists")
		ply:SetMaxHealth(120)
		ply:SetHealth(120)
		ply:SetSubMaterial(0, berserkmat)
		ply:SetAlalnState("crazyness", math.random(4, 8))
		ply:SetAlalnState("hunger", math.random(76, 85))
		BetterChatPrint(ply, "Your goal is to survive with your perfectly honed melee weapon killing skill, while being pretty bad with firearms.", color_yellow)
	elseif class == "Cannibal" then
		ply:Give("alaln_hands")
		ply:SetMaxHealth(100)
		ply:SetHealth(100)
		ply:Give("alaln_cannibalism")
		ply:SetAlalnState("crazyness", math.random(6, 18))
		ply:SetAlalnState("hunger", math.random(55, 75))
		ply:SetSubMaterial(0, cannibalmat)
		BetterChatPrint(ply, "Your only goal is to kill to live, you cannot consume any other food than human flesh, and you harbor a hatred for all living things in this insane world.", color_yellow)
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
	ply:SetupHands()
end

function GM:PlayerSetModel(ply)
	ply:SetModel(Model("models/player/corpse1.mdl"))
	ply:SetPlayerColor((ply:GetPlayerColor() * 0.85) or VectorRand(0.15, 0.75))
	if ply:Nick() == "krosovki2009" or ply:Nick() == "haveaniceday." then ply:SetModel(Model("models/player/group01/male_06.mdl")) end
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

	local clr_blur = Color(25, 25, 125, 25)
	hook_Add("PlayerDeath", "alaln-plydeath", function(victim, inflictor, attacker)
		for _, ply in player.Iterator() do
			if IsValid(attacker) and victim ~= attacker then
				local attclass = attacker:GetClass()
				local attname = attacker:IsPlayer() and attacker:Name() or NPCNames[attclass] or attacker.PrintName or attacker:GetClass()
				BetterChatPrint(ply, victim:Name() .. " was killed by " .. attname .. ".", color_red2)
			else
				BetterChatPrint(ply, victim:Name() .. " died.", color_red2)
			end
		end

		if victim:GetNWBool("HasArmor", false) then victim:EmitSound("hl1/fvox/flatline.wav", 100, math.random(90, 110)) end
		victim.NextSpawnTime = CurTime() + 5
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

	hook_Add("OnNPCKilled", "alaln-npcdeath", function(npc, attacker, inflictor)
		if attacker:IsPlayer() then
			attacker:ScreenFade(SCREENFADE.IN, clr_blur, 0.5, 0)
			attacker:AddAlalnState("score", math.random(1, 6))
		end
	end)
end

hook_Add("PlayerConnect", "alaln-joinmessage", function(name, ip)
	for _, ply in player.Iterator() do
		BetterChatPrint(ply, name .. " joining the hell.", color_red)
	end
end)

hook_Add("UpdateAnimation", "alaln-fixanims", function(ply, event, data) ply:RemoveGesture(ACT_GMOD_NOCLIP_LAYER) end)
function GM:PlayerDeathThink(ply)
	ply:ScreenFade(SCREENFADE.OUT, color_black, 2.5, 0.5)
	if ply.NextSpawnTime and ply.NextSpawnTime > CurTime() then
		return
	else
		local pressed = ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP)
		if ply:IsBot() or pressed then ply:Spawn() end
	end
end

do
	local plysndstrings = {"ambient/voices/cough1.wav", "ambient/voices/cough2.wav", "ambient/voices/cough3.wav", "ambient/voices/cough4.wav"}
	timer.Create("alaln-randomplysounds", math.random(75, 85), 0, function()
		if CLIENT then return end
		for _, ply in player.Iterator() do
			if ply:Alive() and not ply:GetNoDraw() and ply:WaterLevel() < 2 then
				ply:BetterViewPunch(AngleRand(-3, 8))
				ply:EmitSound(table.Random(plysndstrings), 60, math.random(85, 95))
			end
		end
	end)
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
		if SBOXMode:GetBool() then return true end
		if usecd > CurTime() then return false end
		BetterChatPrint(ply, table.Random(randvehstrings), color_red)
		usecd = CurTime() + 2
		return false
	end
end

do
	local deathsounds = {"vo/npc/male01/pain07.wav", "vo/npc/male01/pain08.wav", "vo/npc/male01/pain09.wav", "vo/npc/male01/no02.wav"}
	hook_Add("PlayerDeathSound", "alaln-deathsound", function(ply)
		if not IsValid(ply:GetNWEntity("plyrag")) then return false end
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
		if IsValid(ply) and ply:Alive() and wep ~= nil and wep ~= NULL and wep.Droppable then
			ply:DoAnimationEvent(ACT_GMOD_GESTURE_MELEE_SHOVE_1HAND)
			ply:BetterViewPunch(AngleRand(-3, 3))
			ply:DropWeapon(wep)
		end
	end

	concommand.Add("drop", DropWep)
	concommand.Add("dropweapon", DropWep)
	concommand.Add("-drop", DropWep)
	concommand.Add("-dropweapon", DropWep)
	hook_Add("PlayerSay", "alaln-dropweapon", function(ply, text)
		if dropstrings[text] then
			DropWep(ply)
			return false
		end
	end)
end

function GM:PlayerSetHandsModel(ply, ent)
	if ply:Armor() <= 0 then
		local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetModel())
		local info = player_manager.TranslatePlayerHands(simplemodel)
		if info then
			ent:SetModel(info.model)
			ent:SetSkin(info.skin)
			ent:SetBodyGroups(info.body)
		end
	else
		ent:SetModel(Model("models/weapons/c_arms_hev.mdl"))
	end

	if ply:GetAlalnState("class") == "Berserker" or ply:GetAlalnState("class") == "Gunslinger" then
		ent:SetBodyGroups("11111")
	else
		ent:SetBodyGroups("00000")
	end
end