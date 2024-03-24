AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_rounds.lua")
include("shared.lua")
include("sv_spawns.lua")
include("sv_ragdolls.lua")
include("sh_rounds.lua")
resource.AddFile("resource/fonts/SMODGUI.ttf")
local color_red = Color(180, 0, 0)
local color_red2 = Color(165, 0, 0)
util.AddNetworkString("alaln-navmeshnotfound")
util.AddNetworkString("alaln-setclass")
function GM:Initialize()
	if not navmesh.IsLoaded() then
		MsgC(color_red, " [ALALN] Navmesh not found! This maps not support Forsakened gamemode.\n")
		local plys = player.GetAll()
		for _, ply in ipairs(plys) do
			if ply:IsListenServerHost() then
				net.Start("alaln-navmeshnotfound")
				net.Send(ply)
			end
		end
	else
		MsgC(color_red, " [ALALN] Welcome to hell on earth.\n")
	end
end

-- name override for npc classes
local NPCNames = {
	npc_zombie = "Zombie",
	npc_headcrab = "Headcrab",
	npc_metropolice = "Metrocop",
	npc_combine_s = "Combine"
}

hook.Add("PlayerDeath", "alaln-plydeath", function(victim, inflictor, attacker)
	local plys = player.GetAll()
	for _, ply in ipairs(plys) do
		if IsValid(attacker) and victim ~= attacker then
			local attclass = attacker:GetClass()
			local attname = attacker:IsPlayer() and attacker:Name() or NPCNames[attclass] or attacker.PrintName or attacker:GetClass()
			BetterChatPrint(ply, victim:Name() .. " was killed by " .. attname .. ".", color_red2)
		else
			BetterChatPrint(ply, victim:Name() .. " died.", color_red2)
		end
	end

	RoundEndCheck()
end)

hook.Add("UpdateAnimation", "alaln-fixanims", function(ply, event, data) ply:RemoveGesture(ACT_GMOD_NOCLIP_LAYER) end)
hook.Add("PlayerConnect", "alaln-joinmessage", function(name, ip)
	local players = player.GetAll()
	for _, plys in ipairs(players) do
		BetterChatPrint(plys, name .. " Joining the hell.", color_red)
	end
end)

function GM:PlayerDeathThink(ply)
	ply:ScreenFade(SCREENFADE.OUT, color_black, 2, 0.5)
	if ply.NextSpawnTime and ply.NextSpawnTime > CurTime() then return end
	if roundActive == false then
		if ply:IsBot() or ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP) then ply:Spawn() end
		return true
	else
		return false
	end
end

hook.Add("PlayerSpawn", function(ply)
	if roundActive == true then
		ply:KillSilent()
		return
	else
		RoundStart()
	end
end)

hook.Add("PlayerInitialSpawn", function(ply)
	if not navmesh.IsLoaded() then
		MsgC(color_red, " [ALALN] Navmesh not found! This maps not support Forsakened gamemode.\n")
		BetterChatPrint(ply, "Navmesh not found! This maps not support Forsakened gamemode.", color_red)
		if ply:IsListenServerHost() then
			net.Start("alaln-navmeshnotfound")
			net.Send(ply)
		end
	end

	ply:SetNWString("Class", "Standard")
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
	ply:SetNWVector("ScrShake", vector_origin)
	ply:SetNWBool("NeedToKillNow", false)
	ply:SetSubMaterial()
	ply:CrosshairDisable()
	ply:GodDisable()
	ply:SetTeam(1)
	ply:SetMaterial()
	ply:SetNWBool("HasArmor", false)
	if SBOXMode:GetInt() == 1 then
		ply:Give("weapon_physgun")
		ply:Give("gmod_tool")
	else
		ply:Give("alaln_lighter")
	end

	if ply:GetNWString("alaln-class", "Standard") == "Berserker" then
		ply:Give("alaln_fists")
		ply:SetHunger(60)
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
	ply:ScreenFade(SCREENFADE.IN, color_black, 2, 0)
end

function GM:PlayerSetModel(ply)
	ply:SetModel("models/player/corpse1.mdl")
	ply:SetPlayerColor(ply:GetPlayerColor() * 0.85)
end

local nextheadshot = 0
hook.Add("EntityTakeDamage", "alaln-enttakedamage", function(target, dmginfo)
	if not target:IsPlayer() or (target:IsPlayer() and target:HasGodMode()) then return end
	if dmginfo:GetDamageType() == DMG_BURN or target:IsOnFire() then
		if SERVER then util.ScreenShake(target:GetPos(), 0.3, 3, 5, 0) end
		target:ViewPunch(AngleRand(-5, 5))
		target:AddCrazyness(0.2)
	end

	local damag = dmginfo:GetDamage() * 0.6
	target:ViewPunch(AngleRand(-damag, damag))
	if dmginfo:GetDamageType() == 4 and dmginfo:GetDamage() >= 20 then dmginfo:ScaleDamage(0.85) end
	if dmginfo:GetDamage() > 1 and target:LastHitGroup(HITGROUP_HEAD) and dmginfo:IsBulletDamage() and nextheadshot < CurTime() then
		local headshotsound = CreateSound(target, "player/general/flesh_burn.wav")
		if SERVER then util.ScreenShake(target:GetPos(), 1, 5, 4, 0) end
		target:ViewPunch(Angle(-30, 0, 0))
		target:AddCrazyness(0.5)
		dmginfo:ScaleDamage(10)
		if not headshotsound:IsPlaying() then
			headshotsound:Play()
			headshotsound:ChangeVolume(0, 3)
			timer.Simple(3, function()
				if not (IsValid(target) or headshotsound:IsPlaying()) then return end
				headshotsound:Stop()
			end)
		end

		nextheadshot = CurTime() + 4
	end

	if dmginfo:GetDamage() > 30 and dmginfo:IsFallDamage() then
		if SERVER then util.ScreenShake(target:GetPos(), 1, 5, 5, 0) end
		dmginfo:ScaleDamage(2)
		if target:Armor() >= 1 then
			target:EmitSound("physics/metal/metal_canister_impact_soft" .. math.random(1, 3) .. ".wav", 80, math.random(80, 95))
			target:SetArmor(target:Armor() - dmginfo:GetDamage() * 0.6)
		end

		target:ViewPunch(Angle(-50, 0, 0))
		target:EmitSound("physics/body/body_medium_break4.wav", 100, math.random(90, 110))
	end

	if dmginfo:IsExplosionDamage() and dmginfo:GetDamage() > 25 then
		if SERVER then util.ScreenShake(target:GetPos(), 15, 15, 5, 0) end
		target:AddCrazyness(1)
		target:ViewPunch(AngleRand(-90, 90))
		dmginfo:ScaleDamage(2)
	end

	if target:IsPlayer() and dmginfo:IsDamageType(4) then -- fists block
		local wep = target:GetActiveWeapon()
		if IsValid(wep) and wep.isInBlockDam then dmginfo:ScaleDamage(0.45) end
	end

	target:AddCrazyness(dmginfo:GetDamage() * 0.1)
	target:SetArmor(target:Armor() - dmginfo:GetDamage() * 0.1)
end)

-- needful commands
RunConsoleCommand("sv_defaultdeployspeed", 1)
RunConsoleCommand("sv_rollangle", 2)
RunConsoleCommand("sbox_maxnpcs", 128)
RunConsoleCommand("sv_drc_disable_thirdperson", 1)
local usecd = 0
hook.Add("KeyPress", "alaln-keypress", function(ply, key)
	if key == IN_ZOOM and usecd < CurTime() then
		ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)
		ply:ConCommand("checkammo")
		usecd = CurTime() + 1
	end

	if key == IN_USE and usecd < CurTime() then
		local tr = ply:GetEyeTrace()
		-- press e on windows to break them
		if IsValid(tr.Entity) and (tr.Entity:GetClass() == "func_breakable" or tr.Entity:GetClass() == "func_breakable_surf") and tr.HitPos:Distance(tr.StartPos) < 50 then
			ply:DoAnimationEvent(ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND)
			if tr.Entity:GetClass() == "func_breakable" then
				local dmg = DamageInfo()
				dmg:SetAttacker(ply)
				dmg:SetInflictor(ply)
				dmg:SetDamage(10)
				dmg:SetDamageType(DMG_CLUB)
				dmg:SetDamageForce(ply:GetAimVector() * 500)
				dmg:SetDamagePosition(tr.HitPos)
				tr.Entity:TakeDamageInfo(dmg)
				ply:ViewPunch(AngleRand(-15, 15))
				if math.random(1, 2) == 2 then ply:TakeDamage(math.random(3, 6), ply, tr.Entity) end
				return
			elseif tr.Entity:GetClass() == "func_breakable_surf" then
				tr.Entity:Fire("shatter", "0.5 0.5 4", 0)
				ply:ViewPunch(AngleRand(-15, 15))
				if math.random(1, 2) == 2 then ply:TakeDamage(math.random(3, 6), ply, tr.Entity) end
			end

			usecd = CurTime() + 1
		end
	end
end)

hook.Add("GetFallDamage", "alaln-falldamage", function(ply, speed) return math.max(0, math.ceil(0.2418 * speed - 141.75)) end)
function GM:PlayerCanSeePlayersChat(text, team, listener, speaker)
	if speaker == NULL then return true end
	return hook.Run("PlayerCanHearPlayersVoice", listener, speaker)
end

function GM:PlayerCanHearPlayersVoice(listener, talker)
	if not listener:IsValid() then return false end
	local list_team = listener:Team()
	local talk_team = talker:Team()
	if talk_team == TEAM_SPECTATOR then return list_team == TEAM_SPECTATOR end
	if listener:GetPos():DistToSqr(talker:GetPos()) <= 562500 then -- 750 * 750
		return true, true
	end
	return false
end

util.AddNetworkString("alaln-classmenu")
function GM:ShowTeam(ply)
	net.Start("alaln-classmenu")
	net.Send(ply)
end

util.AddNetworkString("DoPlayerFlinch")
hook.Add("ScalePlayerDamage", "alaln-flinchplayers", function(ply, grp)
	if IsValid(ply) and ply:IsPlayer() and ply:Alive() and not ply:GetNoDraw() then
		local group = nil
		local hitpos = {
			[HITGROUP_HEAD] = ACT_FLINCH_HEAD,
			[HITGROUP_CHEST] = ACT_FLINCH_STOMACH,
			[HITGROUP_STOMACH] = ACT_FLINCH_STOMACH,
			[HITGROUP_LEFTARM] = ACT_FLINCH_STOMACH,
			[HITGROUP_RIGHTARM] = ACT_FLINCH_STOMACH,
			[HITGROUP_LEFTLEG] = ply:GetSequenceActivity(ply:LookupSequence("flinch_01")),
			[HITGROUP_RIGHTLEG] = ply:GetSequenceActivity(ply:LookupSequence("flinch_02"))
		}

		if hitpos[grp] == nil then
			group = ACT_FLINCH_PHYSICS
		else
			group = hitpos[grp]
		end

		net.Start("DoPlayerFlinch")
		net.WriteInt(group, 32)
		net.WriteEntity(ply)
		net.Broadcast()
	end
end)

-- format: multiline
local spawn = {
	"PlayerGiveSWEP",
	"PlayerSpawnEffect",
	"PlayerSpawnNPC",
	"PlayerSpawnObject",
	"PlayerSpawnProp",
	"PlayerSpawnRagdoll",
	"PlayerSpawnSENT",
	"PlayerSpawnSWEP",
	"PlayerSpawnVehicle"
}

local function BlockSpawn(ply)
	if not SBOXMode:GetBool() then BetterChatPrint(ply, "Don't do that.", color_red2) end
	return SBOXMode:GetBool()
end

for _, v in ipairs(spawn) do
	hook.Add(v, "BlockSpawn", BlockSpawn)
end