-- antibhop & sprint
hook.Add("OnPlayerHitGround", "alaln-antibhop", function(ply, water, floater, speed) ply.JumpPenalty = CurTime() + 0.25 end)
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
		local new = vel * 0.95
		new.z = vel.z
		mv:SetVelocity(new)
	end
end)

-- toggle crouch
if CLIENT then
	local induck = false
	hook.Add("PlayerBindPress", "alaln-toggleduck", function(ply, bind, pressed) if string.find(bind, "duck") then return true end end)
	hook.Add("PlayerButtonDown", "alaln-toggleduck", function(ply, button)
		if button == input.GetKeyCode(input.LookupBinding("+duck")) and IsFirstTimePredicted() then
			induck = not induck
			if not induck then ply.crouchcd = CurTime() + 0.7 end
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

-- player animations
hook.Add("CalcMainActivity", "alaln-playeranims", function(ply, vel)
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

hook.Add("PlayerUse", "alaln-useanims", function(ply, ent) if IsValid(ply) and ply:Alive() and ply:IsPlayer() then ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_GIVE) end end)
-- footsteps
hook.Add("PlayerFootstep", "alaln-plyfootstep", function(ply, pos, foot, sound, volume, rf)
	if not (IsValid(ply) or ply:Alive()) then return false end
	-- that screenshake thing works on near player ONLY ON SERVER (wtf?)
	-- on client this would shake screen for all player (wtf???)
	if SERVER then util.ScreenShake(ply:GetPos(), 0.1, 0.1, 1, 0) end
	local vbs = math.Round(ply:GetVelocity():LengthSqr() / 60000, 1) or 0.3 -- returns ~0.3 on walking and ~0.7 on running
	local punchang = Angle(vbs, math.Rand(-vbs, vbs), math.Rand(-vbs, vbs))
	ply:ViewPunch(punchang)
	if (CLIENT and ply == LocalPlayer()) or not IsValid(ply) then return end
	-- server only part
	if ply:Armor() < 1 then ply:EmitSound("npc/footsteps/hardboot_generic" .. math.random(1, 6) .. ".wav", (ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_WALK)) and 40 or 60, math.random(90, 110)) end
	if (ply:IsSprinting() or ply:KeyDown(IN_DUCK)) and ply:Armor() < 1 then ply:EmitSound("npc/footsteps/softshoe_generic6.wav", 35, math.random(90, 110)) end
	if ply:Armor() >= 1 then
		ply:EmitSound("npc/combine_soldier/gear" .. math.random(1, 6) .. ".wav", (ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_WALK)) and 35 or 40, math.random(90, 110))
		ply:EmitSound("physics/metal/metal_canister_impact_soft" .. math.random(1, 3) .. ".wav", (ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_WALK)) and 35 or 40, math.random(90, 110))
	end
	return true
end)