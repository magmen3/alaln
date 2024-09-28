local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, net = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, net
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("loader.lua")
include("loader.lua")
include("shared.lua")
resource.AddFile("resource/fonts/SMODGUI.ttf") -- I hope this thing works
local color_red = Color(185, 15, 15)
util.AddNetworkString("alaln-navmeshnotfound")
util.AddNetworkString("alaln-setclass")
function GM:Initialize()
	timer.Simple(1, function()
		if not navmesh.IsLoaded() then
			MsgC(color_red, " [ALALN] Navmesh not found! This maps not support Forsakened gamemode.\n")
			--local plys = player.GetAll()
			for _, ply in player.Iterator() do
				if ply:IsListenServerHost() then
					net.Start("alaln-navmeshnotfound")
					net.Send(ply)
				end
			end
		else
			MsgC(color_red, " [ALALN] Welcome to hell on earth.\n")
		end
	end)
end

-- Needful commands
RunConsoleCommand("sv_defaultdeployspeed", "1")
RunConsoleCommand("sv_rollangle", "-4")
RunConsoleCommand("sbox_maxnpcs", "128")
RunConsoleCommand("mp_show_voice_icons", "0")
local usecd = 0
hook_Add("KeyPress", "alaln-keypress", function(ply, key)
	if key == IN_ZOOM and not ply:IsTyping() and usecd < CurTime() then
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
				dmg:SetDamage(math.random(4, 8))
				dmg:SetDamageType(DMG_CLUB)
				dmg:SetDamageForce(ply:GetAimVector() * 500)
				dmg:SetDamagePosition(tr.HitPos)
				tr.Entity:TakeDamageInfo(dmg)
				ply:BetterViewPunch(AngleRand(-15, 15))
				if math.random(1, 2) == 2 then ply:TakeDamage(math.random(4, 8), ply, tr.Entity) end
				return
			elseif tr.Entity:GetClass() == "func_breakable_surf" then
				tr.Entity:Fire("shatter", "0.5 0.5 4", 0)
				ply:BetterViewPunch(AngleRand(-15, 15))
				if math.random(1, 2) == 2 then ply:TakeDamage(math.random(4, 8), ply, tr.Entity) end
			end

			usecd = CurTime() + 1
		end
	end
end)

function GM:PlayerCanSeePlayersChat(text, team, listener, speaker)
	if speaker == NULL then return true end
	return hook.Run("PlayerCanHearPlayersVoice", listener, speaker)
end

function GM:PlayerCanHearPlayersVoice(listener, talker)
	if not listener:IsValid() then return false end
	--[[local list_team = listener:Team()
	local talk_team = talker:Team()
	if talk_team == TEAM_SPECTATOR then return list_team == TEAM_SPECTATOR end]]
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

hook_Add("PlayerDisconnected", "alaln-returnconcommands", function(ply)
	ply:ConCommand("sv_rollangle 0")
	ply:ConCommand("cl_drawownshadow 0")
end)