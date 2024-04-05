local crazyeffectcd = 0
local color_red = Color(165, 0, 0)
local color_yellow = Color(255, 170, 0)
local color_yellow2 = Color(255, 235, 0)
local agonysounds = {"vo/npc/male01/runforyourlife02.wav", "vo/npc/male01/pain07.wav", "vo/npc/male01/pain09.wav", "vo/npc/male01/no02.wav"}
local randagonystrings = {"OH SHIT", "IM HURT", "FUUUUUCK", "SOMEONE HELP ME", "PLEASE HELP ME"}
-- good alternative for stuff that needs think hook
timer.Create("alaln-globalenttimer", 0.5, 0, function()
	local entys = ents.GetAll()
	for _, ply in player.Iterator() do
		if IsValid(ply) and ply:Alive() then
			-------- Hunger --------
			if SERVER and SBOXMode:GetBool() == false then
				if ply:GetHunger() < 50 and ply:GetHunger() > 49.9 then
					BetterChatPrint(ply, "You are starving.", color_yellow2)
					if CLIENT then surface.PlaySound("common/warning.wav") end
				elseif ply:GetHunger() < 30 and ply:GetHunger() > 29.8 then
					BetterChatPrint(ply, "You are starving.", color_yellow)
					if CLIENT then surface.PlaySound("common/warning.wav") end
				elseif ply:GetHunger() < 1 and ply:GetHunger() > 0.85 then
					BetterChatPrint(ply, "You started starving to death.", color_red)
					if CLIENT then surface.PlaySound("common/warning.wav") end
				end

				if ply:GetHunger() <= 15 then
					ply:AddCrazyness(0.2)
					util.ScreenShake(ply:GetPos(), 0.1, 0.1, 0.1, 0)
				end

				if ply:GetHunger() >= 80 and ply:Health() < 50 then
					ply:SetHealth(ply:Health() + 1)
					ply:AddHunger(-0.2)
					ply:AddCrazyness(-0.005)
				elseif ply:GetHunger() <= 0 then
					ply:TakeDamage(math.random(3, 6))
					ply:AddCrazyness(0.25)
					ply:EmitSound("player/pl_pain" .. math.random(5, 7) .. ".wav", 50, math.random(90, 110), 0.5)
				elseif ply:GetHunger() >= 0 then
					ply:AddHunger(-0.05)
				end

				------------------------
				-------- Crazyness --------
				if ply:GetCrazyness() >= 0 then ply:AddCrazyness(-0.005) end
				if ply:GetCrazyness() == 10 then BetterChatPrint(ply, "You are feeling yourself strange...", color_red) end
				if ply:GetCrazyness() >= 50 and math.random(1, 4) == 2 then ply:EmitSound("kidneydagger/scramble" .. math.random(1, 10) .. ".wav") end
			end

			local movetype = ply:GetMoveType()
			if movetype ~= MOVETYPE_NOCLIP or ply:InVehicle() then
				ply:SetColor(color_white)
				ply:SetNoDraw(false)
				if SERVER then
					ply:GodDisable()
					ply:SetNoTarget(false)
				end
			else
				ply:SetColor(color_transparent)
				ply:SetNoDraw(true)
				if SERVER then
					ply:GodEnable()
					ply:SetNoTarget(true)
				end
			end

			if ply:IsOnFire() and ply:Health() <= ply:GetMaxHealth() / 20 then
				ply:SetModel("models/player/charple.mdl")
				ply:SetMaterial("models/charple/charple2_sheet")
			end

			if ply:GetNWBool("HasArmor", true) and ply:Armor() < 1 and ply:GetModel() ~= "models/player/charple.mdl" then
				ply:SetModel("models/player/corpse1.mdl")
				ply:SetSkin(0)
				ply:SetSubMaterial()
				ply:SetNWBool("HasArmor", false)
			end

			if ply:IsOnFire() and crazyeffectcd < CurTime() then
				ply:EmitSound(table.Random(agonysounds), 95, math.random(95, 100))
				crazyeffectcd = CurTime() + 3
				if SERVER then ply:Say(table.Random(randagonystrings), false) end
			end

			ply:AddScore(0.08)
			if ply:WaterLevel() >= 2 and ply:IsOnFire() and SERVER then ply:Extinguish() end
			if CLIENT and ply:GetCrazyness() >= 60 and math.random(1, 15) == 5 and crazyeffectcd < CurTime() then
				local rnd = math.random(1, 3)
				if rnd == 1 then
					surface.PlaySound("npc/barnacle/barnacle_pull" .. math.random(1, 4) .. ".wav")
				elseif rnd == 2 then
					surface.PlaySound("ambient/creatures/town_scared_breathing" .. math.random(1, 2) .. ".wav")
				else
					surface.PlaySound("vein/panic.mp3")
				end

				local viewang = ply:EyeAngles() + Angle(0, math.random(-180, 180), 0)
				ply:BetterViewPunch(Angle(0, 0, math.random(-50, 50)))
				ply:SetEyeAngles(viewang)
				chat.AddText(color_red, "You hear some strange sound...")
				if SERVER then util.ScreenShake(ply:GetPos(), 1, 2, 1, 0) end
				crazyeffectcd = CurTime() + 60
			end
		end
	end

	for _, ent in ipairs(entys) do
		if IsValid(ent) and ent:IsOnFire() then
			local entinsphere = ents.FindInSphere(ent:GetPos(), 95)
			for _, sphereent in ipairs(entinsphere) do
				if SERVER and sphereent:IsPlayer() and not sphereent:IsOnFire() and not sphereent:HasGodMode() then sphereent:Ignite(5, 150) end
			end
		end
	end
end)