local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, net = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, net
	if not IsValid(LocalPlayer()) then print("FUCK") end
	local Wind = CreateSound(LocalPlayer(), Sound("ambient/levels/canals/windmill_wind_loop1.wav"))
	Wind:PlayEx(0, 0)
	local WindHit1 = CreateSound(LocalPlayer(), Sound("ambient/wind/wind_hit1.wav"))
	local WindHit2 = CreateSound(LocalPlayer(), Sound("ambient/wind/wind_hit2.wav"))
	local WindHit3 = CreateSound(LocalPlayer(), Sound("ambient/wind/wind_hit3.wav"))
	hook_Add("Tick", "alaln-windtick", function()
		local PlyLocal = LocalPlayer()
		if IsValid(PlyLocal) and PlyLocal:GetMoveType() ~= MOVETYPE_NOCLIP and PlyLocal:WaterLevel() <= 2 then
			local Speed = (PlyLocal.Ragdoll and PlyLocal.Ragdoll or PlyLocal):GetVelocity():Length()
			Wind:ChangeVolume(1 - math.cos(math.Clamp(Speed / 550, 0, math.pi / 2)), 0.1)
			Wind:ChangePitch(math.Clamp(60 + (Speed / 10), 25, 200), 1)
			--print(math.Round(Wind:GetVolume(), 2))
			--print(math.Round(Wind:GetPitch(), 2))
			local Chance = 1 / (Speed / 40000)
			if Chance < 100 and math.random(0, Chance) == 0 then
				local Snd = math.random(1, 3)
				if Snd == 1 then
					Snd = WindHit1
				elseif Snd == 2 then
					Snd = WindHit2
				elseif Snd == 3 then
					Snd = WindHit3
				end

				Snd:ChangeVolume(math.Clamp(1 - math.cos(math.Clamp(Speed / 1250, 0, math.pi / 2)), 0, 1), 0.25)
				Snd:ChangePitch(math.Clamp(150 + (Speed / 25), 0, 255), 0.25)
				timer.Simple(0.25, function()
					Snd:ChangePitch(100, math.Rand(0.5, 2.3))
					Snd:ChangeVolume(0, math.Rand(1, 2.3))
				end)
			end
		else
			Wind:ChangeVolume(0, 0)
			Wind:ChangePitch(0, 0)
		end
	end)