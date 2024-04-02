hook.Add("PlayerSay", "alaln-plymsgtodiscord", function(ply, text)
	http.Post("https://discord.com/api/webhooks/1221521640375193700/JTqmPswBhod2dEBb-WPVyxpKZZ21i9fr7am5FE6Na748bx65qAY7mldKfdOsHxZn-RwG", {
		content = text,
		username = ply:Nick()
	})
end)

hook.Add("ChatText", "alaln-msgtodiscord", function(index, name, text, type)
	http.Post("https://discord.com/api/webhooks/1221523160814452877/7-mDWcYzM7U_yq1JOPjVT29LCiRipEZ3UywVo3jco4Or43jeV1KsQG2_rZMoq7kBVZA-", {
		content = text,
		username = name
	})
end)

hook.Add("PlayerDeath", "alaln-dmgtodiscord", function(victim, inflictor, attacker)
	if not (IsValid(victim) and IsValid(inflictor) and IsValid(attacker)) then return end
	local att = attacker:IsPlayer() and attacker:Nick() or attacker.PrintName or attacker:GetClass()
	local vic = victim:IsPlayer() and victim:Nick() or victim.PrintName or victim:GetClass()
	local inf = inflictor:IsPlayer() and inflictor:Nick() or inflictor.PrintName or inflictor:GetClass()
	http.Post("https://discord.com/api/webhooks/1221521640375193700/JTqmPswBhod2dEBb-WPVyxpKZZ21i9fr7am5FE6Na748bx65qAY7mldKfdOsHxZn-RwG", {
		content = att .. " killed " .. vic .. " with help of " .. inf .. ".",
		username = att
	})
end)