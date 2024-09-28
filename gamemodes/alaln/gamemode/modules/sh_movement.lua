local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, net = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, net
-- Player's hull vectors, made it global for easier use
HullVector = {
	Min = Vector(-12, -12, 0),
	Max = Vector(12, 12, 64),
	Duck = Vector(12, 12, 42),
	Offset = Vector(0, 0, 64),
	DuckOffset = Vector(0, 0, 42)
}

-- Antibhop
hook_Add("OnPlayerHitGround", "alaln-antibhop", function(ply, water, floater, speed)
	--[[if not IsValid(ply) or not ply:Alive() then return end
	local vel = ply:GetVelocity()
	vel.z = 100
	ply:SetVelocity(-vel * 1.5)]]
	--if ply:GetAlalnState("stamina") > 25 then ply:AddAlalnState("stamina", -5) end
	local vel = ply:GetVelocity() -- NEW METHOD 🔥🔥🔥
	ply:SetVelocity(Vector(-(vel.x / 1.5), -(vel.y / 1.5), 0))
end)

-- Movement speed calculations
hook_Add("Move", "alaln-sprint", function(ply, mv)
	if not IsValid(ply) or not ply:Alive() then return end
	if not ply.CurrentWalk then ply.CurrentWalk = 1 end
	if not ply.CurrentSprint then ply.CurrentSprint = ply:GetWalkSpeed() end
	local walking, notforward = ply:KeyDown(IN_FORWARD), not ply:KeyDown(IN_FORWARD) and (ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_BACK))
	local staminamul, classmul = math.Clamp(ply:GetAlalnState("stamina") / 50, 0.6, 1.5), ply:GetAlalnState("class") == "Faster" and 1.15 or 1
	local armormul, armormuljump = ply:GetNWBool("HasArmor", false) and 0.95 or 1, ply:GetNWBool("HasArmor", false) and 0.8 or 1
	if walking and not notforward then
		ply.CurrentWalk = math.Clamp(ply.CurrentWalk + 3, 5, 140 * classmul * armormul * staminamul)
	elseif not walking and notforward then
		ply.CurrentWalk = math.Clamp(ply.CurrentWalk + 2, 5, 90 * classmul * armormul * staminamul)
	else
		ply.CurrentWalk = 1
	end

	ply:SetJumpPower(200 * armormuljump)
	ply:SetSlowWalkSpeed(ply:GetWalkSpeed() * 0.8 * armormuljump)
	ply:SetCrouchedWalkSpeed(ply:GetWalkSpeed() * 0.5 * armormuljump)
	if walking and ply:IsSprinting() then
		ply.CurrentSprint = math.Clamp(ply.CurrentSprint + 4, ply:GetWalkSpeed(), 280 * classmul * armormul * staminamul)
	else
		ply.CurrentSprint = ply:GetWalkSpeed() * armormul
	end

	ply:SetWalkSpeed(ply.CurrentWalk)
	ply:SetRunSpeed(ply.CurrentSprint)
end)

-- Toggle crouch
if CLIENT then
	local induck = false
	hook_Add("PlayerBindPress", "alaln-toggleduck", function(ply, bind, pressed) if string.find(bind, "duck") then return true end end)
	hook_Add("PlayerButtonDown", "alaln-toggleduck", function(ply, button)
		if button == input.GetKeyCode(input.LookupBinding("+duck")) and IsFirstTimePredicted() then
			induck = not induck
			if not induck then ply.crouchcd = CurTime() + 0.7 end
			if ply.crouchcd and ply.crouchcd > CurTime() and induck then induck = false end
		end
	end)

	hook_Add("CreateMove", "alaln-toggleduck", function(cmd)
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

local notallowedmv = {
	[MOVETYPE_NOCLIP] = true,
	[MOVETYPE_OBSERVER] = true
}

hook_Add("SetupMove", "alaln-overridemovement", function(ply, mv, cmd)
	local movetype = ply:GetMoveType()
	if not ply:Alive() or notallowedmv[movetype] then return end
	local pl = ply:GetTable()
	local ducking = mv:KeyDown(IN_DUCK)
	pl.PlayCrouchSound = false
	if ply:KeyPressed(IN_DUCK) and IsFirstTimePredicted() then pl.PlayCrouchSound = true end
	if pl.PlayCrouchSound then
		if ply:WaterLevel() <= 1 then
			if ply:Armor() >= 1 and ply:GetNWBool("HasArmor", false) == true then
				ply:EmitSound("npc/metropolice/gear" .. math.random(1, 6) .. ".wav", 40, 100, 1, CHAN_STATIC)
			else
				ply:EmitSound("npc/footsteps/softshoe_generic6.wav", 40, 100, 1, CHAN_STATIC)
			end
		end

		pl.PlayCrouchSound = false
		pl.PlayUnCrouchSoundLater = true
	end

	if pl.PlayUnCrouchSoundLater and not ducking then
		if ply:WaterLevel() <= 1 then
			if ply:Armor() >= 1 and ply:GetNWBool("HasArmor", false) == true then
				ply:EmitSound("npc/combine_soldier/gear" .. math.random(1, 6) .. ".wav", 40, 100, 1, CHAN_STATIC)
			else
				ply:EmitSound("npc/footsteps/softshoe_generic6.wav", 40, 100, 1, CHAN_STATIC)
			end
		end

		pl.PlayUnCrouchSoundLater = false
	end
end)

-- Custom player animations
hook_Add("CalcMainActivity", "alaln-playeranims", function(ply, vel)
	local plyvel, wep = vel:Length2D(), ply:GetActiveWeapon()
	local unarmed = (IsValid(wep) and wep:GetHoldType() == "normal") or not IsValid(wep)
	local isstanding = plyvel <= 0 and not ply:IsSprinting() and not ply:KeyDown(IN_DUCK) and ply:IsOnGround() and unarmed
	local isrunning = unarmed and plyvel > ply:GetRunSpeed() - 15 and ply:IsOnGround() and ply:IsSprinting()
	if ply:GetAlalnState("crazyness") >= 49 and isstanding then
		return ACT_IDLE, ply:LookupSequence("idle_all_angry")
		--elseif isstanding then
		--return ACT_IDLE, ply:LookupSequence("pose_agitated")
	end

	if ply:GetAlalnState("crazyness") >= 49 and isrunning then
		return ACT_RUN, ply:LookupSequence("run_all_panicked_01")
	elseif unarmed and isrunning then
		return ACT_RUN, ply:LookupSequence("run_all_02")
	end
end)

hook_Add("PlayerUse", "alaln-useanims", function(ply, ent) if IsValid(ply) and ply:Alive() and ply:IsPlayer() then ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_GIVE) end end)
function GM:PlayerStepSoundTime(ply, iType, bWalking)
	local fStepTime = 350
	local fMaxSpeed = ply:GetMaxSpeed()
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		if fMaxSpeed <= 100 then
			fStepTime = 420
		elseif fMaxSpeed <= 200 then
			fStepTime = 360
		else
			fStepTime = 315
		end
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		fStepTime = 450
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		fStepTime = 600
	end

	-- Step slower if crouching
	if ply:Crouching() then fStepTime = fStepTime + 100 end
	return fStepTime
end

-- Footsteps
hook_Add("PlayerFootstep", "alaln-plyfootstep", function(ply, pos, foot, sound, volume, rf)
	if not (IsValid(ply) or ply:Alive()) then return true end
	if CLIENT and ply == LocalPlayer() then
		if ply:WaterLevel() > 1 then return true end
		local vbs = math.Round(ply:GetVelocity():LengthSqr() / 20000, 1) or 0.4
		local punchang = Angle(vbs, math.Rand(-vbs, vbs), math.Rand(-vbs, vbs))
		ply:BetterViewPunch(punchang)
		if ply:GetMoveType() == MOVETYPE_LADDER then ply:BetterViewPunch(AngleRand(-5, 5)) end
		-- util.ScreenShake(ply:GetPos(), 0.1, 0.1, 1, 0)
	end

	if (CLIENT and ply == LocalPlayer()) or not IsValid(ply) then return end
	-- Server only part
	if ply:Armor() < 1 then
		if ply:GetAlalnState("class") ~= "Human" and ply:GetAlalnState("class") ~= "Operative" then
			ply:EmitSound("npc/footsteps/hardboot_generic" .. math.random(1, 6) .. ".wav", (ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_WALK)) and 40 or 60, math.random(90, 110))
		elseif ply:GetAlalnState("class") == "Human" then
			ply:EmitSound("vj_cofr/cof/simon/footsteps/concrete" .. math.random(1, 4) .. ".wav", (ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_WALK)) and 35 or 45, math.random(90, 110))
		elseif ply:GetAlalnState("class") == "Operative" then
			ply:EmitSound("npc/combine_soldier/gear" .. math.random(1, 6) .. ".wav", (ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_WALK)) and 35 or 40, math.random(90, 110))
		end
	end

	if (ply:IsSprinting() or ply:KeyDown(IN_DUCK)) and ply:Armor() < 1 then ply:EmitSound("npc/footsteps/softshoe_generic6.wav", 35, math.random(90, 110)) end
	if ply:Armor() >= 1 and ply:GetNWBool("HasArmor", false) == true then
		ply:EmitSound("npc/combine_soldier/gear" .. math.random(1, 6) .. ".wav", (ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_WALK)) and 35 or 40, math.random(90, 110))
		ply:EmitSound("physics/metal/metal_canister_impact_soft" .. math.random(1, 3) .. ".wav", (ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_WALK)) and 35 or 40, math.random(90, 110))
	end
	return true
end)

local ang_land = Angle(15, 0, 0)
hook_Add("OnPlayerJump", "alaln-playerjump", function(ply, speed)
	if not ply:Alive() then return end
	local class = ply:GetAlalnState("class")
	local vel = ply:GetVelocity()
	ply:SetVelocity(-vel * 0.5)
	if SERVER and class ~= "Operative" and class ~= "Human" then
		ply:EmitSound("placenta/speech/jump.wav", 60, math.random(95, 105))
	end
	ply:BetterViewPunch(-ang_land)
end)

function GM:HandlePlayerLanding(ply, velocity, WasOnGround)
	if ply:GetMoveType() == MOVETYPE_NOCLIP then return end
	if ply:IsOnGround() and not WasOnGround then
		ply:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_LAND, true)
		local class = ply:GetAlalnState("class")
		if SERVER and ply:Alive() and class ~= "Operative" and class ~= "Human" then
			ply:EmitSound("placenta/speech/land.wav", 60, math.random(95, 105))
		end
		ply:BetterViewPunch(ang_land)
	end
end