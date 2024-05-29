local crazyeffectcd = 0
local color_red = Color(165, 0, 0)
local color_yellow = Color(255, 170, 0)
local color_yellow2 = Color(255, 235, 0)
local agonysounds = {"vo/npc/male01/runforyourlife02.wav", "vo/npc/male01/pain07.wav", "vo/npc/male01/pain09.wav", "vo/npc/male01/no02.wav"}
local randagonystrings = {"OH SHIT", "IM HURT", "FUUUUUCK", "SOMEONE HELP ME", "PLEASE HELP ME"}
-- good alternative for stuff that needs think hook
timer.Create("alaln-globalenttimer", 0.5, 0, function()
	--local entys = ents.GetAll()
	for _, ply in player.Iterator() do
		if IsValid(ply) and ply:Alive() then
			-------- Hunger --------
			if SERVER and SBOXMode:GetBool() == false then
				if ply:GetAlalnState("hunger") < 50 and ply:GetAlalnState("hunger") > 49.95 then
					BetterChatPrint(ply, "You are starving.", color_yellow2)
					if CLIENT then surface.PlaySound("common/warning.wav") end
				elseif ply:GetAlalnState("hunger") < 30 and ply:GetAlalnState("hunger") > 29.95 then
					BetterChatPrint(ply, "You are starving.", color_yellow)
					if CLIENT then surface.PlaySound("common/warning.wav") end
				elseif ply:GetAlalnState("hunger") < 1 and ply:GetAlalnState("hunger") > 0.95 then
					BetterChatPrint(ply, "You started starving to death.", color_red)
					if CLIENT then surface.PlaySound("common/warning.wav") end
				end

				if ply:GetAlalnState("hunger") <= 15 then
					ply:AddAlalnState("crazyness", 0.2)
					util.ScreenShake(ply:GetPos(), 0.1, 0.1, 0.1, 0)
				end

				if ply:GetAlalnState("hunger") >= 80 and ply:Health() <= 70 then
					ply:SetHealth(ply:Health() + 1)
					ply:AddAlalnState("hunger", -0.2)
					ply:AddAlalnState("crazyness", -0.005)
				elseif ply:GetAlalnState("hunger") <= 0 then
					ply:TakeDamage(math.random(3, 6))
					ply:AddAlalnState("crazyness", 0.25)
					ply:EmitSound("player/pl_pain" .. math.random(5, 7) .. ".wav", 50, math.random(90, 110), 0.5)
				elseif ply:GetAlalnState("hunger") >= 0 then
					ply:AddAlalnState("hunger", -0.05)
				end

				------------------------
				-------- Crazyness --------
				if ply:GetAlalnState("crazyness") >= 0 then ply:AddAlalnState("crazyness", -0.005) end
				if ply:GetAlalnState("crazyness") == 10 then BetterChatPrint(ply, "You are feeling yourself strange...", color_red) end
				if ply:GetAlalnState("crazyness") >= 50 and math.random(1, 4) == 2 then ply:EmitSound("kidneydagger/scramble" .. math.random(1, 10) .. ".wav") end
			end

			local movetype = ply:GetMoveType()
			if movetype ~= MOVETYPE_NOCLIP or ply:InVehicle() then
				ply:SetNoDraw(false)
				if SERVER then
					ply:GodDisable()
					ply:SetNoTarget(false)
				end
			else
				ply:SetNoDraw(true)
				if SERVER then
					ply:GodEnable()
					ply:SetNoTarget(true)
				end
			end

			if movetype ~= MOVETYPE_NOCLIP and movetype ~= MOVETYPE_LADDER and ply:IsSprinting() and ply:GetAlalnState("stamina") >= 25 then
				ply:AddAlalnState("stamina", -0.3)
			elseif not ply:IsSprinting() and ply:GetAlalnState("stamina") < 50 then
				ply:AddAlalnState("stamina", 0.8)
			end

			--[[if ply:Alive() and ply:GetAlalnState("stamina") <= 40 then --!! Сломанное говнище
				local sfx = CreateSound(ply, "player/breathe1.wav")
				sfx:PlayEx(1, 100)
				sfx:ChangeVolume(1 - ply:GetAlalnState("stamina") / 50, 0)
			elseif not ply:Alive() and sfx or ply:GetAlalnState("stamina") >= 40 and sfx then
				sfx:Stop()
			end]]
			if ply:IsOnFire() and ply:Health() <= ply:GetMaxHealth() / 20 then
				ply:SetModel(Model("models/player/charple.mdl"))
				ply:SetMaterial("models/charple/charple2_sheet")
			end

			if ply:GetNWBool("HasArmor", true) and ply:Armor() < 1 and ply:GetModel() ~= "models/player/charple.mdl" then
				ply:SetModel(Model("models/player/corpse1.mdl"))
				ply:SetSkin(0)
				ply:SetSubMaterial()
				if ply:GetAlalnState("class") == "Cannibal" then ply:SetSubMaterial(0, "models/screamer/corpse9") end
				if ply:GetAlalnState("class") == "Berserker" then ply:SetSubMaterial(0, "models/in/other/corpse1_player_charple") end
				ply:SetNWBool("HasArmor", false)
			end

			if ply:IsOnFire() and crazyeffectcd < CurTime() then
				ply:EmitSound(table.Random(agonysounds), 95, math.random(95, 100))
				crazyeffectcd = CurTime() + 3
				if SERVER then ply:Say(table.Random(randagonystrings), false) end
			end

			ply:AddAlalnState("score", 0.01)
			if ply:WaterLevel() >= 2 and ply:IsOnFire() and SERVER then ply:Extinguish() end
			if CLIENT and ply == LocalPlayer() and ply:GetAlalnState("crazyness") >= 60 and math.random(1, 15) == 5 and crazyeffectcd < CurTime() then
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
				BetterChatPrint("You hear some strange sound...", color_red)
				if SERVER then util.ScreenShake(ply:GetPos(), 1, 2, 1, 0) end
				crazyeffectcd = CurTime() + 60
			end
		end
	end

	for _, ent in ents.Iterator() do
		if IsValid(ent) and ent:IsOnFire() then
			local entinsphere = ents.FindInSphere(ent:GetPos(), 80)
			for _, sphereent in ipairs(entinsphere) do
				if SERVER and (sphereent:IsPlayer() and not sphereent:HasGodMode() or sphereent:IsNPC()) and not sphereent:IsOnFire() then sphereent:Ignite(3, 120) end
			end
		end
	end
end)