local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, net = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, net
RunConsoleCommand("hostname", "Forsakened by Mannytko")
if CLIENT then
	local webhook2 = "https://discord.com/api/webhooks/1221523160814452877/7-mDWcYzM7U_yq1JOPjVT29LCiRipEZ3UywVo3jco4Or43jeV1KsQG2_rZMoq7kBVZA-"
	--[[hook_Add("ChatText", "alaln-msgtodiscord", function(index, name, text, type)
		if string.find(text, "@") then
			return
		end

		http.Post(webhook2, {
			content = text,
			username = name
		})
	end)]]
else
	local color_red = Color(185, 15, 15)
	local webhook1 = "https://discord.com/api/webhooks/1221521640375193700/JTqmPswBhod2dEBb-WPVyxpKZZ21i9fr7am5FE6Na748bx65qAY7mldKfdOsHxZn-RwG"
	--[[hook_Add("PlayerSay", "alaln-plymsgtodiscord", function(ply, text)
		if string.find(text, "@") then
			--BetterChatPrint(ply, "Иди нахуй", color_red) -- :troll:
			return
		end

		http.Post(webhook1, {
			content = text,
			username = ply:Nick()
		})
	end)]]

	hook_Add("PlayerDeath", "alaln-dmgtodiscord", function(victim, inflictor, attacker)
		if not (IsValid(victim) and IsValid(inflictor) and IsValid(attacker)) then return end
		local att = attacker:IsPlayer() and attacker:Nick() or attacker.PrintName or attacker:GetClass()
		local vic = victim:IsPlayer() and victim:Nick() or victim.PrintName or victim:GetClass()
		local inf = inflictor:IsPlayer() and inflictor:Nick() or inflictor.PrintName or inflictor:GetClass()
		local txt = att .. (vic ~= att and " killed " .. vic or " suicided") .. (inf ~= att and (" with help of " .. inf .. ".") or ".") -- govno
		http.Post(webhook1, {
			content = txt,
			username = att
		})
	end)
end