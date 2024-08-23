local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, net = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, net
local crazyeffectcd = 0
local color_red, color_yellow = Color(185, 15, 15), Color(210, 210, 110)
local agonysounds = {"vo/npc/male01/runforyourlife02.wav", "vo/npc/male01/pain07.wav", "vo/npc/male01/pain09.wav", "vo/npc/male01/no02.wav", "vo/npc/male01/strider_run.wav"}
local panicsounds = {"vo/npc/male01/runforyourlife02.wav", "vo/npc/male01/no02.wav", "vo/npc/male01/strider_run.wav"}
local randagonystrings = {"OH SHIT", "IM HURT", "FUUUUUCK", "SOMEONE HELP ME", "PLEASE HELP ME"}
local charplemat, berserkmat, cannibalmat = "models/charple/charple2_sheet", "models/in/other/corpse1_player_charple", "models/screamer/corpse9"
-- Good (no) alternative for stuff that needs think hook
timer_Create("alaln-globalenttimer", 0.5, 0, function()
	for _, ply in player.Iterator() do
		if IsValid(ply) and ply:Alive() then
			local hunger, crazyness = ply:GetAlalnState("hunger"), ply:GetAlalnState("crazyness")
			-------- Hunger --------
			if SBOXMode:GetBool() == false then
				if CLIENT and ply == LocalPlayer() then
					if hunger < 50 and hunger > 49.95 then
						BetterChatPrint(ply, "You are starving.", color_yellow)
						surface.PlaySound("common/warning.wav")
					elseif hunger < 30 and hunger > 29.95 then
						BetterChatPrint(ply, "You are starving.", color_yellow)
						surface.PlaySound("common/warning.wav")
					elseif hunger < 1 and hunger > 0.95 then
						BetterChatPrint(ply, "You started starving to death.", color_red)
						surface.PlaySound("common/warning.wav")
					end
				end

				if SERVER then
					if hunger <= 15 then
						ply:AddAlalnState("crazyness", 0.2)
						util.ScreenShake(ply:GetPos(), 0.1, 0.1, 0.1, 0)
					end

					if hunger >= 80 and ply:Health() <= 70 then
						ply:SetHealth(ply:Health() + 1)
						ply:AddAlalnState("hunger", -0.2)
						ply:AddAlalnState("crazyness", -0.005)
					elseif hunger <= 0 then
						ply:TakeDamage(math.random(3, 6))
						ply:AddAlalnState("crazyness", 0.25)
						ply:EmitSound("player/pl_pain" .. math.random(5, 7) .. ".wav", 50, math.random(90, 110), 0.5)
					elseif hunger >= 0 then
						ply:AddAlalnState("hunger", -0.05)
					end
				end

				-------- Crazyness --------
				if crazyness >= 0 then ply:AddAlalnState("crazyness", -0.005) end
				if CLIENT and ply == LocalPlayer() and crazyness == 10 then BetterChatPrint(ply, "You are feeling yourself strange...", color_red) end
				if crazyness >= 50 and math.random(1, 4) == 2 then ply:EmitSound("kidneydagger/scramble" .. math.random(1, 10) .. ".wav") end
			elseif SBOXMode:GetBool() == true and crazyness >= 1 then
				ply:SetAlalnState("crazyness", 0)
			end

			-------- Noclip nodraw --------
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
			
			local class = ply:GetAlalnState("class")
			-------- Drop on death (works like crap) --------
			if SERVER and ply:Health() <= 1 and ply:Alive() then
				if class ~= "Operative" and ply:GetActiveWeapon().Droppable then ply:DropWeapon() end
			end

			-------- Falling screams --------
			if movetype ~= MOVETYPE_NOCLIP and not ply:InVehicle() and ply:GetVelocity()[3] <= -900 and crazyeffectcd < CurTime() and ply:Alive() and class ~= "Operative" then
				ply:EmitSound(table.Random(panicsounds), 95, math.random(95, 100))
				crazyeffectcd = CurTime() + 3
			end

			-------- Stamina --------
			if movetype ~= MOVETYPE_NOCLIP and movetype ~= MOVETYPE_LADDER and ply:IsSprinting() and ply:GetAlalnState("stamina") >= 25 and ply:Alive() then
				ply:AddAlalnState("stamina", -0.3)
			elseif not ply:IsSprinting() and ply:GetAlalnState("stamina") < 50 and ply:Alive() then
				ply:AddAlalnState("stamina", 0.8)
			end

			-------- Stamina breath (broken) --------
			--[[if ply:Alive() and ply:GetAlalnState("stamina") <= 40 then --!! Сломанное говнище
				local sfx = CreateSound(ply, "player/breathe1.wav")
				sfx:PlayEx(1, 100)
				sfx:ChangeVolume(1 - ply:GetAlalnState("stamina") / 50, 0)
			elseif not ply:Alive() and sfx or ply:GetAlalnState("stamina") >= 40 and sfx then
				sfx:Stop()
			end]]

			-------- Change playermodel on fire --------
			if ply:IsOnFire() and ply:Health() <= ply:GetMaxHealth() / 20 and class ~= "Operative" then
				ply:SetModel(Model("models/player/charple.mdl"))
				ply:SetMaterial(charplemat)
			else
				if class == "Cannibal" then ply:SetSubMaterial(0, cannibalmat) end
				if class == "Berserker" or class == "Gunslinger" then ply:SetSubMaterial(0, berserkmat) end
			end

			-------- Reset material with armor --------
			if ply:GetNWBool("HasArmor", true) and ply:Armor() < 1 and ply:GetModel() ~= "models/player/charple.mdl" and class ~= "Operative" then
				ply:SetModel(Model("models/player/corpse1.mdl"))
				ply:SetSkin(0)
				ply:SetSubMaterial()
				if SERVER then ply:SetupHands() end
				if class == "Cannibal" then ply:SetSubMaterial(0, cannibalmat) end
				if class == "Berserker" or class == "Gunslinger" then ply:SetSubMaterial(0, berserkmat) end
				ply:SetNWBool("HasArmor", false)
			end

			-------- Chat scream when on fire --------
			if ply:IsOnFire() and crazyeffectcd < CurTime() and ply:Alive() and class ~= "Operative" then
				ply:EmitSound(table.Random(agonysounds), 95, math.random(95, 100))
				crazyeffectcd = CurTime() + 3
				if SERVER then ply:Say(table.Random(randagonystrings), false) end
			end

			-------- Passive score add --------
			ply:AddAlalnState("score", 0.015)
			
			-------- Extinguish in water --------
			if ply:WaterLevel() >= 2 and ply:IsOnFire() and SERVER then ply:Extinguish() end
			
			-------- Crazyness sounds --------
			if CLIENT and ply == LocalPlayer() and crazyness >= 60 and math.random(1, 15) == 5 and crazyeffectcd < CurTime() and ply:Alive() and class ~= "Operative" then
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
				crazyeffectcd = CurTime() + 60
			end
		end
	end

	-------- Ignite other objects when on fire --------
	for _, ent in ents.Iterator() do
		if IsValid(ent) and ent:IsOnFire() then
			local entinsphere = ents.FindInSphere(ent:GetPos(), 80)
			for _, sphereent in ipairs(entinsphere) do
				if SERVER and (sphereent:IsPlayer() and not sphereent:HasGodMode() or sphereent:IsNPC()) and not sphereent:IsOnFire() then sphereent:Ignite(3, 120) end
			end
		end
	end
end)