local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, net = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, net
DeriveGamemode("sandbox")
GM.Name = "Forsakened"
GM.Author = "Mannytko, Deka, and others listed on WS page"
GM.Email = "loh"
GM.Website = "https://discord.gg/gQ7Pp96ZHj"
GM.Stage = 1
--[[ --!! TODO: (Баги всякие непофикшенные искать через CTRL + F и --!! в поиск)
	1. Добавить различные препараты временно дающие баффы
	2. Переделать еду и транквилизаторы на базе свепов
	3. Добавить алтари, из которых можно получить рандомный бафф/вещь за очки
	4. Взять отсюда плавную камеру и сделать как в SCP:CB https://steamcommunity.com/sharedfiles/filedetails/?id=3166995133 https://steamcommunity.com/sharedfiles/filedetails/?id=3299669560
	5. Возможно починить баг с лестницами и хуллами с помощью этого аддо https://steamcommunity.com/sharedfiles/filedetails/?id=3233720748
	6. Еще мб это https://steamcommunity.com/sharedfiles/filedetails/?id=3241813281
	7. Выполнить все то что в Forsaken.txt написано
	8. Улучшенное третье лицо https://steamcommunity.com/sharedfiles/filedetails/?id=3246688602
	9. https://steamcommunity.com/sharedfiles/filedetails/?id=3035102687 https://gamebanana.com/mods/181756 Снайперка
]]
do
	local convarflags = bit.bor(FCVAR_REPLICATED, FCVAR_NOTIFY)
	CreateConVar("alaln_sboxmode", 0, convarflags, "Enable sandbox mode? (q menu, context menu, noclip, etc.)", 0, 1)
	CreateConVar("alaln_disable_monsters", 0, convarflags, "Disables monsters if you wan't to do", 0, 1)
	CreateConVar("alaln_dark_light", 0, convarflags, "Enable darkest lighting in maps? (experimental, not recommended)", 0, 1)
end

hook.Remove("PlayerTick", "TickWidgets")
hook.Remove("Think", "CheckSchedules")
timer.Remove("HostnameThink")
SBOXMode = GetConVar("alaln_sboxmode")
local color_yellow = Color(210, 210, 110)
local color_red = Color(185, 15, 15)
local color_blue = Color(0, 0, 190)
team.SetUp(1, "Survivors", color_red)
team.SetUp(2, "Purifiers", color_blue)
player_manager.AddValidModel("Purifier", "models/forsakened/purifier/masked_cop.mdl")
player_manager.AddValidHands("Purifier", "models/weapons/c_metrocop_hands.mdl", 0, "00000000")
local devconvar = GetConVar("developer")
function DebugPrint(message)
	if devconvar:GetInt() == 0 then return end
	if not message then
		MsgC(color_yellow, "Error! Calling DebugPrint() without args" .. message)
		return
	end

	MsgC(color_yellow, " [ALALN] " .. tostring(message) .. "\n")
end

-- Rubat moment x2 https://github.com/Facepunch/garrysmod-requests/issues/122
if SERVER then
	util.AddNetworkString("alaln-chatprint")
	-- Taken from wiremod
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
	--[[function BetterChatPrint(ply, msg, color) --!! чтоб ты падла здох
		if not (msg or color) then
			DebugPrint("Error! Calling BetterChatPrint() without args")
			return
		end

		chat.AddText(color, msg) -- скотина тупая
	end]]

	net.Receive("alaln-chatprint", function() chat.AddText(net.ReadColor(), net.ReadString()) end)
end

DarkLight = GetConVar("alaln_dark_light")
hook_Add("Initialize", "alaln-lighting", function()
	if DarkLight:GetBool() == false then return end
	timer.Simple(1, function()
		if SERVER then
			for i = 0, 63 do
				engine.LightStyle(i, "b")
			end

			RunConsoleCommand("sv_skyname", "sky_borealis01")
		else
			render.RedownloadAllLightmaps(true, true)
		end
	end)
end)

hook.Add("PostCleanupMap", "alaln-lighting", function()
	if DarkLight:GetBool() and SERVER then
		for i = 0, 63 do
			engine.LightStyle(i, "b")
		end
	end
end)

--!! HL2 use sounds (probably should use PlayerUse hook for this) -- Edit: nope, i shouldn't
if SERVER then
	hook_Add("FindUseEntity", "alaln-finduseent", function(ply, ent)
		if not ply:KeyPressed(IN_USE) or ply:KeyDown(IN_ATTACK2) or not ply:Alive() then return end
		if IsValid(ent) then
			ply:EmitSound("HL2Player.Use")
		else
			timer.Simple(0, function()
				if not IsValid(ply) then return end
				if IsValid(ply:GetEntityInUse()) then
					ply:EmitSound("HL2Player.Use")
				else
					ply:EmitSound("HL2Player.UseDeny")
				end
			end)
		end
	end)
end