DeriveGamemode("sandbox")
GM.Name = "Forsakened"
GM.Author = "Mannytko, Deka, patrickkane1997"
GM.Email = "loh"
GM.Website = "loh"
if not ConVarExists("alaln_sboxmode") then CreateConVar("alaln_sboxmode", 0, FCVAR_NOTIFY, "Enable sandbox mode? (q menu, context menu, noclip, etc.)", 0, 1) end
if not ConVarExists("alaln_dark_light") then CreateConVar("alaln_dark_light", 0, FCVAR_NOTIFY, "Enable darkest lighting in maps? (experimental, not recommended)", 0, 1) end
SBOXMode = GetConVar("alaln_sboxmode")
--[[ TODO:
	1. Добавить мусорки в которых типо лутаться можно если Е зажать
	2. Добавить систему очков и их накопление за убийства
	3. Доделать каннибала
	4. Добавить больше классов
	5. Добавить эээ как их там lens flare вроде ну в воркшопе аддон скачать и всё
]]
local color_yellow = Color(255, 170, 0)
local color_red = Color(165, 0, 0)
roundActive = false
team.SetUp(1, "Survivors", color_red)
local devconvar = GetConVar("developer")
function DebugPrint(message)
	if devconvar:GetInt() == 0 then return end
	if not message then
		MsgC(color_yellow, "Error! Calling DebugPrint() without args" .. message)
		return
	end

	MsgC(color_yellow, " [ALALN DEBUG]" .. tostring(message) .. "\n")
end

-- rubat moment https://github.com/Facepunch/garrysmod-requests/issues/122
if SERVER then
	util.AddNetworkString("alaln-chatprint")
	-- taken from wiremod
	function BetterChatPrint(ply, msg, color)
		if not (ply or msg or color) then
			DebugPrint("Error! Calling BetterChatPrint() without args")
			return
		end

		net.Start("alaln-chatprint")
		net.WriteColor(color)
		net.WriteString(msg)
		net.Send(ply)
	end
else
	net.Receive("alaln-chatprint", function() chat.AddText(net.ReadColor(), net.ReadString()) end)
end

local DarkLight = GetConVar("alaln_dark_light")
hook.Add("Initialize", "alaln-lighting", function()
	if DarkLight:GetBool() == false then return end
	timer.Simple(1, function()
		if SERVER then
			for i = 0, 63 do
				engine.LightStyle(i, "b")
			end
		else
			render.RedownloadAllLightmaps(true, true)
		end
	end)
end)

-- hl2 use sounds (probably should use PlayerUse hook for this)
if SERVER then
	hook.Add("FindUseEntity", "alaln-finduseent", function(ply, ent)
		if not ply:KeyPressed(IN_USE) or ply:KeyDown(IN_ATTACK2) then return end
		if IsValid(ent) then
			ply:EmitSound("HL2Player.Use")
		else
			timer.Simple(0, function()
				if IsValid(ply:GetEntityInUse()) then
					ply:EmitSound("HL2Player.Use")
				else
					ply:EmitSound("HL2Player.UseDeny")
				end
			end)
		end
	end)
end

local deathsounds = {"vo/npc/male01/pain07.wav", "vo/npc/male01/pain09.wav", "vo/npc/male01/no02.wav"}
hook.Add("PlayerDeathSound", "alaln-deathsound", function(ply)
	sound.Play(table.Random(deathsounds), ply:GetNWEntity("plyrag"):GetPos(), 100, math.random(95, 105))
	return true
end)