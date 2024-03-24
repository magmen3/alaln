DeriveGamemode("sandbox")
GM.Name = "Forsakened"
GM.Author = "Mannytko, Deka, patrickkane1997"
GM.Email = "loh"
GM.Website = "loh"
SBOXMode = CreateConVar("alaln_sboxmode", 0, FCVAR_NOTIFY, "Enable sandbox mode? (q menu, context menu, noclip, etc.)", 0, 1)
--[[ TODO:
	1. Add roundsystem (50%)
	2. Add class system with menu (50%)
	3. Add esc menu like in rxsend breach (0%)
	4. Add post-rock soundtrack
	5. Add some kind of inventory (0%)
	6. Find good npcs on vj base (done? maybe)
	7. Add more weapons (added revolver, need more)
	8. реализовать все идеи которые ракман кидал в виде txt
]]
local color_yellow = Color(255, 170, 0)
local color_red = Color(165, 0, 0)
roundActive = false
team.SetUp(1, "Survivors", color_red)
player_manager.AddValidModel("Forsakened Burned Survivor", "models/player/charple.mdl")
player_manager.AddValidHands("Forsakened Burned Survivor", "models/weapons/hd_hobo_hands.mdl")
function DebugPrint(message)
	if GetConVar("developer"):GetInt() == 0 then return end
	if not message then
		MsgC(color_yellow, "Error! Calling DebugPrint() without args" .. message)
		return
	end

	MsgC(color_yellow, " [ALALN DEBUG]" .. tostring(message) .. "\n")
end

hook.Add("PlayerNoClip", "alaln-noclip", function(ply, desiredState)
	if SBOXMode:GetInt() == 1 then return true end
	return false
end)

--[[hook.Add("PlayerSay", "Discord", function(ply, text) -- работает, можно с помощью этого ченибудь придумать
	http.Post("https://discordapp.com/api/webhooks/1184152663005347911/4dPY8tUjlaVNSBYaoHMYTQrq_XOSrlx35z-vZ0nKx5DOjesLusKixKFHbGnnwkJFpzYL", {content = text, username = ply:Nick()})
end)]]
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

local plymeta = FindMetaTable("Player")
function plymeta:GetHunger()
	return self:GetNWFloat("alaln-hunger", 0)
end

function plymeta:SetHunger(hunger)
	if not hunger then
		DebugPrint("Error! Calling SetHunger() without args")
		return
	end

	self:SetNWFloat("alaln-hunger", hunger)
end

-- use negative values to reduce
function plymeta:AddHunger(hunger)
	if not hunger then
		DebugPrint("Error! Calling AddHunger() without args")
		return
	end

	self:SetHunger(math.Clamp(self:GetHunger() + hunger, 0, 100))
end

function plymeta:GetCrazyness()
	return self:GetNWFloat("alaln-crazyness", 0)
end

function plymeta:SetCrazyness(crazyness)
	if not crazyness then
		DebugPrint("Error! Calling SetCrazyness() without args")
		return
	end

	self:SetNWFloat("alaln-crazyness", crazyness)
end

-- use negative values to reduce
function plymeta:AddCrazyness(crazyness)
	if not crazyness then
		DebugPrint("Error! Calling AddCrazyness() without args")
		return
	end

	self:SetCrazyness(math.Clamp(self:GetCrazyness() + crazyness, 0, 100))
end

local crazyeffectcd = 0
local color_yellow2 = Color(255, 235, 0)
-- good alternative for stuff that needs think hook
timer.Create("alaln-globalenttimer", 1, 0, function()
	local plys = player.GetAll()
	local entys = ents.GetAll()
	for _, ply in ipairs(plys) do
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
					ply:AddHunger(-0.3)
					ply:AddCrazyness(-0.01)
				elseif ply:GetHunger() <= 0 then
					ply:TakeDamage(10)
					ply:EmitSound("player/pl_pain" .. math.random(5, 7) .. ".wav", 50, math.random(90, 110), 0.5)
				elseif ply:GetHunger() >= 0 then
					ply:AddHunger(-0.15)
				end

				------------------------
				-------- Crazyness --------
				if ply:GetCrazyness() >= 0 then ply:AddCrazyness(-0.01) end
				if ply:GetCrazyness() == 10 then BetterChatPrint(ply, "You are feeling yourself strange...", color_red) end
				if ply:GetCrazyness() >= 45 and math.random(1, 4) == 2 then ply:EmitSound("kidneydagger/scramble" .. math.random(1, 10) .. ".wav") end
				if ply:GetNWBool("NeedToKillNow", false) == true then ply:Kill() end
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

			-- format: multiline
			local agonysounds = {
				"vo/npc/male01/runforyourlife02.wav",
				"vo/npc/male01/pain07.wav",
				"vo/npc/male01/pain09.wav",
				"vo/npc/male01/no02.wav"
			}

			if ply:IsOnFire() then
				if crazyeffectcd < CurTime() then
					ply:EmitSound(table.Random(agonysounds), 95, math.random(95, 100))
					crazyeffectcd = CurTime() + 3
				end

				ply:SetWalkSpeed(300)
			else
				ply:SetWalkSpeed(160)
			end

			if ply:WaterLevel() == 2 and ply:IsOnFire() and SERVER then ply:Extinguish() end
			-- ebal
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
				ply:ViewPunch(Angle(0, 0, math.random(-50, 50)))
				ply:SetEyeAngles(viewang)
				chat.AddText(color_red, "You hear some strange sound...")
				if SERVER then util.ScreenShake(ply:GetPos(), 1, 2, 1, 0) end
				crazyeffectcd = CurTime() + 60
			end
		end
	end

	for _, ent in ipairs(entys) do
		if IsValid(ent) and ent:IsOnFire() then
			local entinsphere = ents.FindInSphere(ent:GetPos(), 90)
			for _, sphereent in ipairs(entinsphere) do
				if SERVER and sphereent:IsPlayer() and not sphereent:IsOnFire() then sphereent:Ignite(5, 150) end
			end
		end
	end
end)

hook.Add("PlayerFootstep", "alaln-plyfootstep", function(ply, pos, foot, sound, volume, rf)
	if not (IsValid(ply) or ply:Alive()) then return false end
	-- that screenshake thing works on near player ONLY ON SERVER, LOL
	-- on client this would shake screen for all player (wtf?)
	if SERVER then util.ScreenShake(ply:GetPos(), 0.1, 0.1, 1, 0) end
	local vbs = math.Round(ply:GetVelocity():LengthSqr() / 60000, 1) or 0.3 -- возвращает число где то около 0.3 при ходьбе и 0.7 при беге
	ply:ViewPunch(Angle(vbs, math.Rand(-vbs, vbs), math.Rand(-vbs, vbs)))
	if (CLIENT and ply == LocalPlayer()) or not IsValid(ply) then return end
	if ply:Armor() < 1 then ply:EmitSound("npc/footsteps/hardboot_generic" .. math.random(1, 6) .. ".wav", (ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_WALK)) and 40 or 60, math.random(90, 110)) end
	if (ply:IsSprinting() or ply:KeyDown(IN_DUCK)) and ply:Armor() < 1 then ply:EmitSound("npc/footsteps/softshoe_generic6.wav", 35, math.random(90, 110)) end
	if ply:Armor() >= 1 then
		ply:EmitSound("npc/combine_soldier/gear" .. math.random(1, 6) .. ".wav", (ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_WALK)) and 35 or 40, math.random(90, 110))
		ply:EmitSound("physics/metal/metal_canister_impact_soft" .. math.random(1, 3) .. ".wav", (ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_WALK)) and 35 or 40, math.random(90, 110))
	end
	return true
end)

hook.Add("CalcMainActivity", "alaln-crazyanims", function(ply, vel)
	local plyvel = vel:Length2D()
	local wep = ply:GetActiveWeapon()
	local unarmed = (IsValid(wep) and wep:GetHoldType() == "normal") or not IsValid(wep)
	local isstanding = plyvel <= 0 and not ply:IsSprinting() and not ply:KeyDown(IN_DUCK) and ply:IsOnGround() and unarmed
	local isrunning = unarmed and plyvel > ply:GetRunSpeed() - 10 and ply:IsOnGround() and ply:IsSprinting()
	if ply:GetCrazyness() >= 49 and isstanding then
		return ACT_IDLE, ply:LookupSequence("idle_all_angry")
		--elseif isstanding then
		--return ACT_IDLE, ply:LookupSequence("pose_agitated")
	end

	if ply:GetCrazyness() >= 49 and isrunning then
		return ACT_RUN, ply:LookupSequence("run_all_panicked_01")
	elseif unarmed and isrunning then
		return ACT_RUN, ply:LookupSequence("run_all_02")
	end
end)

--------------------------------------------------------------------
local roundTimeStart = CurTime()
-- format: multiline
local rndsound = {
	"music/hl2_song10.mp3",
	"music/hl2_song13.mp3",
	"music/hl2_song30.mp3",
	"music/hl2_song33.mp3",
	"music/radio1.mp3",
	"in2/maintenance_tunnels.mp3"
}

local playsound = true
local color = Color(150, 0, 0, 250)
local hudfont = "alaln-hudfontbig"
local randomstrings = {"RUN", "LIVER FAILURE FOREVER", "YOU'RE ALREADY DEAD", "KILL OR DIE"}
hook.Add("HUDPaint", "alaln-roundstartscreen", function()
	if roundActive == false then return end
	local ply = LocalPlayer()
	local startRound = roundTimeStart + 10 - CurTime()
	if startRound > 0 and ply:Alive() then
		if playsound then
			playsound = false
			surface.PlaySound(table.Random(rndsound))
		end

		ply:ScreenFade(SCREENFADE.IN, color_black, 3, 0.5)
		draw.DrawText("You are Survivor", hudfont, ScrW() / 2, ScrH() / 2, Color(color.r, color.g, color.b, math.Clamp(startRound - 0.5, 0, math.Rand(0.7, 1)) * 255), TEXT_ALIGN_CENTER)
		draw.DrawText("Forsakened", hudfont, ScrW() / 2, ScrH() / 8, Color(color.r, color.g, color.b, math.Clamp(startRound - 0.5, 0, math.Rand(0.7, 1)) * 255), TEXT_ALIGN_CENTER)
		draw.DrawText(table.Random(randomstrings), hudfont, ScrW() / 2, ScrH() / 1.2, Color(color.r, color.g, color.b, math.Clamp(startRound - 0.5, 0, math.Rand(0, 0.1)) * 255), TEXT_ALIGN_CENTER)
		return
	end
end)

--------------------------------------------------------------------
if CLIENT then
	local induck = false
	hook.Add("PlayerBindPress", "alaln-toggleduck", function(ply, bind, pressed) if string.find(bind, "duck") then return true end end)
	hook.Add("PlayerButtonDown", "alaln-toggleduck", function(ply, button)
		if button == input.GetKeyCode(input.LookupBinding("+duck")) and IsFirstTimePredicted() then
			induck = not induck
			if not induck then ply.crouchcd = CurTime() + 1 end
			if ply.crouchcd and ply.crouchcd > CurTime() and induck then induck = false end
		end
	end)

	hook.Add("CreateMove", "alaln-toggleduck", function(cmd)
		local ply = LocalPlayer()
		if induck then
			LocalPlayer():SetDuckSpeed(0.1)
			LocalPlayer():SetUnDuckSpeed(0.1)
			cmd:AddKey(IN_DUCK)
		else
			cmd:RemoveKey(IN_DUCK)
		end

		local movetype = ply:GetMoveType()
		if movetype == MOVETYPE_OBSERVER and induck then cmd:RemoveKey(IN_DUCK) end
		if not cmd:KeyDown(IN_DUCK) then induck = false end
	end)
end

hook.Add("OnPlayerHitGround", "alaln-antibhop", function(ply, water, floater, speed) ply.JumpPenalty = CurTime() + 0.3 end)
hook.Add("Move", "alaln-sprint", function(ply, mv)
	if not ply.CurrentWalk then ply.CurrentWalk = 2 end
	if not ply.CurrentSprint then ply.CurrentSprint = ply:GetWalkSpeed() end
	local walking = ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_BACK)
	if walking then
		ply.CurrentWalk = math.Clamp(ply.CurrentWalk + 8, 5, 160)
	else
		ply.CurrentWalk = 2
	end

	if walking and ply:IsSprinting() then
		ply.CurrentSprint = math.Clamp(ply.CurrentSprint + 5, ply:GetWalkSpeed(), 300)
	else
		ply.CurrentSprint = ply:GetWalkSpeed()
	end

	ply:SetWalkSpeed(ply.CurrentWalk)
	ply:SetRunSpeed(ply.CurrentSprint)
	if ply.JumpPenalty and ply.JumpPenalty >= CurTime() then
		local vel = mv:GetVelocity()
		local new = vel * 0.97
		new.z = vel.z
		mv:SetVelocity(new)
	end
end)

hook.Add("SetupMove", "alaln-overridemovement", function(ply, mv, cmd)
	local movetype = ply:GetMoveType()
	if not ply:Alive() or movetype == MOVETYPE_NOCLIP or movetype == MOVETYPE_OBSERVER then return end
	local pl = ply:GetTable()
	local ducking = mv:KeyDown(IN_DUCK)
	pl.PlayCrouchSound = false
	if ply:KeyPressed(IN_DUCK) and IsFirstTimePredicted() then pl.PlayCrouchSound = true end
	if pl.PlayCrouchSound then
		if ply:Armor() >= 1 then
			ply:EmitSound("npc/metropolice/gear" .. math.random(1, 6) .. ".wav", 40, math.random(100, 105), 1, CHAN_STATIC)
		else
			ply:EmitSound("npc/footsteps/softshoe_generic6.wav", 40, math.random(100, 105), 1, CHAN_STATIC)
		end

		pl.PlayCrouchSound = false
		pl.PlayUnCrouchSoundLater = true
	end

	if pl.PlayUnCrouchSoundLater and not ducking then
		if ply:Armor() >= 1 then
			ply:EmitSound("npc/combine_soldier/gear" .. math.random(1, 6) .. ".wav", 40, math.random(100, 105), 1, CHAN_STATIC)
		else
			ply:EmitSound("npc/footsteps/softshoe_generic6.wav", 40, math.random(100, 105), 1, CHAN_STATIC)
		end

		pl.PlayUnCrouchSoundLater = false
	end
end)

hook.Add("PlayerDeathSound", "alaln-deathsound", function(ply)
	local deathsounds = {"vo/npc/male01/pain07.wav", "vo/npc/male01/pain09.wav", "vo/npc/male01/no02.wav"}
	sound.Play(table.Random(deathsounds), ply:GetNWEntity("plyrag"):GetPos(), 100, math.random(95, 105))
	return true
end)

hook.Add("PlayerSpray", "alaln-sprays", function() return true end)