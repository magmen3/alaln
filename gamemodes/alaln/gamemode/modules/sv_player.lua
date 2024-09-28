local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, concommand = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, concommand
local color_red = Color(185, 15, 15)
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
	if SBOXMode:GetBool() then ply:EmitSound("garrysmod/save_load" .. math.random(1, 3) .. ".wav") end
	ply:Spawn()
	timer.Simple(1, function()
		if not IsValid(ply) then return end
		ply:SetHull(HullVector.Min, HullVector.Max)
		ply:SetHullDuck(HullVector.Min, HullVector.Duck)
		ply:SetViewOffset(HullVector.Offset)
		ply:SetViewOffsetDucked(HullVector.DuckOffset)
		net.Start("alaln-sethull")
		net.WritePlayer(ply)
		net.Broadcast()
		local phys = ply:GetPhysicsObject()
		if phys:IsValid() then phys:SetMass(95) end
		ply:ScreenFade(SCREENFADE.IN, color_black, 3, 0)
	end)
end)

local color_yellow, color_blue, color_green = Color(210, 210, 110), Color(0, 0, 190), Color(110, 210, 110)
local berserkmat, cannibalmat = "models/in/other/corpse1_player_charple", "models/screamer/corpse9"
util.AddNetworkString("alaln-sethull")
function GM:PlayerLoadout(ply)
	local class = ply:GetAlalnState("class")
	--if math.random(1, 1000) == 999 and class ~= "Operative" then
	if ply:GetNWString("ChoosenOne", false) == true and class ~= "Operative" then
		ply:SetAlalnState("class", "Operative")
		for _, iply in player.Iterator() do
			if iply:GetAlalnState("class") ~= "Operative" then
				BetterChatPrint(iply, "HE is here. Do not give chance to HIM.", color_red) --!! Need to test
			end
		end
	end

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
	ply:GodDisable()
	ply:SetTeam(1)
	ply:SetMaterial()
	ply:SetSubMaterial()
	ply:SetNWBool("HasArmor", false)
	ply:SetNWBool("Gone", false)
	ply:SetNWInt("DrugUses", 0)
	ply.NextSpawnTime = CurTime() + 5
	ply:EmitSound("ambient/levels/citadel/strange_talk" .. math.random(1, 11) .. ".wav", 60, math.random(95, 105))
	if SBOXMode:GetBool() then
		ply:Give("weapon_physgun")
		ply:Give("gmod_tool")
		ply:SetAlalnState("score", 6666)
	else
		if class ~= "Operative" then ply:Give("alaln_lighter") end
		for i = 1, 3 do
			if ply:GetAlalnState("score") >= 2000 then ply:SetAlalnState("score", 0) end
		end
	end

	timer.Simple(.1, function()
		if class ~= "Psychopath" then
			BetterChatPrint(ply, "You are " .. class .. ".", color_red)
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
			ply:Give("mann_wep_m1911")
			ply:SetMaxHealth(101)
			ply:SetHealth(101)
			--ply:SetArmor(10)
			ply:SetSubMaterial(0, berserkmat)
			ply:SetAlalnState("crazyness", math.random(8, 12))
			BetterChatPrint(ply, "Before the madness outbreak, you were fascinated with guns, how they work, and how to shoot with them. This knowledge will save your life in this rotten world.", color_yellow)
		elseif class == "Berserker" then
			ply:Give("alaln_hands")
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
		elseif class == "Operative" then
			ply:SetTeam(2)
			ply:Give("alaln_hands")
			ply:Give("mann_wep_m16")
			ply:Give("mann_wep_g17")
			ply:Give("mann_melee_knife")
			ply:GiveAmmo(90, "AR2", true)
			ply:GiveAmmo(30, "Pistol", true)
			ply:SetAlalnState("crazyness", 25)
			--ply:Give("mann_wep_flaregun")
			ply:SetMaxHealth(120)
			ply:SetHealth(math.random(75, 95))
			ply:AllowFlashlight(true)
			ply:SetNWString("OperativeNum", math.random(125, 269))
			BetterChatPrint(ply, "Welcome back, №" .. ply:GetNWString("OperativeNum"), color_blue)
			timer.Simple(3, function()
				if not (IsValid(ply) or ply:Alive()) then return end
				BetterChatPrint(ply, "They know that you are here. You need to get out of here, and make it faster than they kill you.", color_blue)
			end)
		elseif class == "Human" then
			ply:EmitSound("beams/beamstart5.wav")
			ply:ScreenFade(SCREENFADE.OUT, color_green, 0.5, 0)
			ply:Give("alaln_hands")
			ply:SetAlalnState("crazyness", 0)
			ply:SetAlalnState("hunger", 100)
			ply:SetMaxHealth(100)
			ply:SetHealth(100)
			BetterChatPrint(ply, "Huh? Where am i?...", color_green)
		end
	end)

	ply:SetHull(HullVector.Min, HullVector.Max)
	ply:SetHullDuck(HullVector.Min, HullVector.Duck)
	ply:SetViewOffset(HullVector.Offset)
	ply:SetViewOffsetDucked(HullVector.DuckOffset)
	net.Start("alaln-sethull")
	net.WritePlayer(ply)
	net.Broadcast()
	local phys = ply:GetPhysicsObject()
	if phys:IsValid() then phys:SetMass(95) end
	ply:ScreenFade(SCREENFADE.IN, color_black, 3, 0)
	ply:SetupHands()
	ply:SetNWString("ChoosenOne", false)
end

do
	-- format: multiline
	local humanmdls = {
		"models/player/group02/male_02.mdl",
		"models/player/group02/male_04.mdl",
		"models/player/group02/male_06.mdl",
		"models/player/group02/male_08.mdl"
	}

	local blue, green = Vector(0, 0, .3), Vector(0, .3, 0)
	function GM:PlayerSetModel(ply)
		ply:SetModel(Model("models/player/corpse1.mdl"))
		ply:SetPlayerColor((ply:GetPlayerColor() * 0.85) or VectorRand(0.15, 0.75))
		if ply:GetAlalnState("class") == "Operative" then
			ply:SetModel(Model("models/forsakened/purifier/masked_cop.mdl"))
			ply:SetPlayerColor(blue)
		elseif ply:GetAlalnState("class") == "Human" then
			ply:SetModel(table.Random(humanmdls))
			--if ply:Nick() == "krosovki2009" or ply:Nick() == "haveaniceday." then ply:SetModel(Model("models/player/group01/male_06.mdl")) end
			ply:SetPlayerColor(green)
		end
	end
end

hook_Add("PlayerSay", "alaln-chatvoice", function(ply, text)
	if not ply:Alive() then return false end
	if string.find(text, "@") or string.find(text, "*") or string.find(text, "/") or text == " " then return end
	local voice
	local class = ply:GetAlalnState("class")
	if class == "Operative" then
		voice = "placenta/death/arrhythmiavoice" .. math.random(1, 10) .. ".wav"
	elseif class == "Cannibal" then
		voice = "placenta/speech/kommissar" .. math.random(1, 4) .. ".wav"
	elseif class == "Berserker" or class == "Gunslinger" then
		voice = "placenta/speech/prisoner" .. math.random(1, 4) .. ".wav"
	elseif class == "Human" then
		voice = "placenta/speech/prole" .. math.random(1, 3) .. ".wav"
	else
		voice = "placenta/speech/korps" .. math.random(1, 4) .. ".wav"
	end

	if ply:GetAlalnState("crazyness") >= 75 and class ~= "Operative" then voice = "placenta/addict_aggrod" .. math.random(1, 9) .. ".wav" end
	ply:EmitSound(voice, string.find(text, "!") and 85 or 65, math.random(96, 104))
end)

do
	-- name override for npc classes or entity classes
	local NPCNames = {
		npc_zombie = "Zombie",
		npc_headcrab = "Headcrab",
		npc_metropolice = "Metrocop",
		npc_combine_s = "Combine",
		entityflame = "magic of fire"
	}

	local clr_blur = Color(25, 25, 125, 25)
	local vecup = Vector(5, 5, 40)
	local operloot = {"mann_ent_m16", "mann_ent_knife", "mann_ent_g17", "alaln_food"}
	hook_Add("PlayerDeath", "alaln-plydeath", function(victim, inflictor, attacker)
		for _, ply in player.Iterator() do
			if IsValid(attacker) and victim ~= attacker then
				local attclass = attacker:GetClass()
				local attname = attacker:IsPlayer() and attacker:Name() or NPCNames[attclass] or attacker.PrintName or attacker:GetClass()
				BetterChatPrint(ply, victim:Name() .. " was killed by " .. attname .. ".", color_red)
			else
				BetterChatPrint(ply, victim:Name() .. " died.", color_red)
			end
		end

		if victim:GetNWBool("HasArmor", false) then victim:EmitSound("hl1/fvox/flatline.wav", 100, math.random(90, 110)) end
		victim.NextSpawnTime = CurTime() + 5
		victim:SetDSP(31)
		if IsValid(attacker) and attacker:IsPlayer() then
			attacker:ScreenFade(SCREENFADE.IN, clr_blur, 0.5, 0)
			attacker:AddAlalnState("score", math.random(2, 5))
			if attacker:GetAlalnState("class") ~= "Operative" then attacker:AddAlalnState("crazyness", math.random(8, 24)) end
			if attacker:GetAlalnState("crazyness") >= 15 and attacker:GetAlalnState("crazyness") <= 40 and math.random(2, 4) == 2 and attacker:GetAlalnState("class") ~= "Operative" then
				BetterChatPrint(attacker, "You feel terrible...", color_red)
			elseif attacker:GetAlalnState("crazyness") >= 60 and math.random(2, 6) == 4 or attacker:GetAlalnState("class") == "Operative" and math.random(2, 6) == 4 then
				BetterChatPrint(attacker, "You feel satisfied.", color_red)
				attacker:AddAlalnState("crazyness", math.random(4, 16))
				attacker:AddAlalnState("hunger", -math.random(4, 16))
			end
		end

		timer.Simple(2, function() if IsValid(victim) and not victim:Alive() and victim:GetNWBool("Gone", false) == false then victim:SetNWBool("Gone", true) end end)
		local victimpos = victim:GetPos() + vecup
		if victim:GetAlalnState("class") == "Operative" then
			for _, loot in ipairs(operloot) do
				local Ent = ents.Create(loot)
				if IsValid(Ent) then
					Ent:SetPos(victimpos)
					Ent:SetAngles(AngleRand(-90, 90))
					Ent:Spawn()
					Ent:Activate()
					if IsValid(Ent:GetPhysicsObject()) then Ent:GetPhysicsObject():SetVelocity(victim:GetVelocity() / 2) end
				end
			end
			--[[local Ent = ents.Create("alaln_survivorkit")
			if IsValid(Ent) then
				Ent:SetPos(victimpos)
				Ent:SetAngles(AngleRand(-90, 90))
				Ent:Spawn()
				Ent:Activate()
				if IsValid(Ent:GetPhysicsObject()) then Ent:GetPhysicsObject():SetVelocity(victim:GetVelocity() / 2) end
			end]]
			victim:SetAlalnState("score", 0)
			timer.Simple(.5, function() victim:SetAlalnState("class", "Psychopath") end)
		end

		timer.Simple(.5, function()
			if IsValid(victim) and victim:GetNWString("ChoosenOne", false) == true and class ~= "Operative" then
				victim:SetAlalnState("class", "Operative")
			end
		end)
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
	-- format: multiline
	local plysndstrings = {
		"ambient/voices/cough1.wav",
		"ambient/voices/cough2.wav",
		"ambient/voices/cough3.wav",
		"ambient/voices/cough4.wav"
	}

	timer.Create("alaln-randomplysounds", math.random(75, 85), 0, function()
		for _, ply in player.Iterator() do
			if ply:Alive() and not ply:GetNoDraw() and ply:WaterLevel() < 2 and ply:GetAlalnState("class") ~= "Operative" then
				ply:BetterViewPunch(AngleRand(-12, 12))
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

	local suicideang = Angle(-500, 0, 0)
	function GM:CanPlayerSuicide(ply)
		if not ply:Alive() then return false end
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and wep.Base == "mann_wep_base" and wep:Clip1() >= 1 and wep:GetReady() then
			BetterChatPrint(ply, "You put the barrel of " .. wep:GetPrintName() .. " to your forehead and pulled the trigger.", color_red)
			ply:BetterViewPunch(suicideang)
			wep:SetHoldType("camera")
			wep:PrimaryAttack()
			ply:EmitSound("forsakened/suicide.mp3")
			timer.Simple(.15, function()
				if not (IsValid(ply) or ply:Alive()) then return end
				if ply:GetAlalnState("class") ~= "Operative" then ply:DropWeapon() end
				ply:Kill()
			end)
			return false
		else
			BetterChatPrint(ply, table.Random(randkillstrings), color_red)
			return true
		end
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
		if ply:GetAlalnState("class") ~= "Operative" then
			sound.Play(table.Random(deathsounds), ply:GetNWEntity("plyrag"):GetPos(), 100, math.random(95, 105))
		else
			sound.Play("npc/metropolice/die" .. math.random(1, 4) .. ".wav", ply:GetNWEntity("plyrag"):GetPos(), 100, math.random(90, 95))
		end
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
			ply:BetterViewPunch(AngleRand(-32, 32))
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