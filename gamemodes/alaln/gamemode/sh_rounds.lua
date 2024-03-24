--!! Доделать либо снести хуню эту
function RoundStart()
	local alive = 0
	local plys = player.GetAll()
	for _, ply in ipairs(plys) do
		if ply:Alive() then alive = alive + 1 end
	end

	if alive >= table.Count(plys) and table.Count(plys) > 1 then roundActive = true end
	DebugPrint("Round started: " .. tostring(roundActive))
	RoundEndCheck()
end

function RoundEndCheck()
	DebugPrint("Round active: " .. tostring(roundActive))
	if roundActive == false then return end
	timer.Create("alaln-roundcheckdelay", 1, 1, function()
		local survivors = team.GetPlayers(1)
		for _, surv in ipairs(survivors) do
			if surv:Alive() then survalive = survalive + 1 end
		end

		DebugPrint("Surv alive:" .. tostring(survalive))
		if survalive == 0 then EndRound("Demons win") end
	end)
end

function RoundEnd(reason)
	DebugPrint("Round ended because " .. reason or "no reason given")
	timer.Create("alaln-roundcleanup", 3, 1, function()
		game.CleanUpMap()
		local plys = player.GetAll()
		for _, ply in ipairs(plys) do
			if ply:Alive() then
				ply:StripWeapons()
				ply:KillSilent()
			end
		end

		roundActive = false
	end)
end