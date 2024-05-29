hook.Add("EntityTakeDamage", "alaln-enttakedamage", function(target, dmginfo)
	if not target:IsPlayer() or (target:IsPlayer() and target:HasGodMode()) then return end
	if dmginfo:GetDamageType() == DMG_BURN or target:IsOnFire() then
		if SERVER then util.ScreenShake(target:GetPos(), 0.3, 3, 5, 0) end
		target:BetterViewPunch(AngleRand(-5, 5))
		target:AddAlalnState("crazyness", 0.2)
	end

	local dmgpunch = dmginfo:GetDamage() * 0.6
	target:BetterViewPunch(AngleRand(-dmgpunch, dmgpunch))
	if dmginfo:GetDamageType() == 4 and dmginfo:GetDamage() >= 20 then dmginfo:ScaleDamage(0.85) end
	if dmginfo:GetDamage() > 30 and dmginfo:IsFallDamage() then
		if SERVER then util.ScreenShake(target:GetPos(), 1, 5, 5, 0) end
		dmginfo:ScaleDamage(2)
		if target:Armor() >= 1 then
			target:EmitSound("physics/metal/metal_canister_impact_soft" .. math.random(1, 3) .. ".wav", 80, math.random(80, 95))
			target:SetArmor(target:Armor() - dmginfo:GetDamage() * 0.6)
		end

		target:BetterViewPunch(Angle(-50, 0, 0))
		target:EmitSound("physics/body/body_medium_break4.wav", 100, math.random(90, 110))
	end

	if dmginfo:IsExplosionDamage() and dmginfo:GetDamage() > 25 then
		if SERVER then util.ScreenShake(target:GetPos(), 15, 15, 5, 0) end
		target:AddAlalnState("crazyness", 1)
		target:BetterViewPunch(AngleRand(-90, 90))
		dmginfo:ScaleDamage(2)
	end

	if target:IsPlayer() and dmginfo:IsDamageType(4) then -- Fists block
		local wep = target:GetActiveWeapon()
		if IsValid(wep) and wep.isInBlockDam then dmginfo:ScaleDamage(0.45) end
	end

	target:AddAlalnState("crazyness", dmginfo:GetDamage() * 0.1)
	if target:Armor() >= 1 then
		local armormul = 1 - (target:Armor() / target:GetMaxArmor())
		local armordmg = target:Armor() - (dmginfo:GetDamage() * 0.1)
		dmginfo:ScaleDamage(armormul)
		target:SetArmor(armordmg)
	end
end)

local nextheadshot = 0
hook.Add("ScalePlayerDamage", "alaln-headburnsound", function(ply, hitgroup, dmginfo)
	if dmginfo:GetDamage() > 1 and hitgroup == HITGROUP_HEAD and dmginfo:IsBulletDamage() and nextheadshot < CurTime() then
		local headshotsound = CreateSound(ply, "player/general/flesh_burn.wav")
		if SERVER then util.ScreenShake(ply:GetPos(), 1, 5, 4, 0) end
		ply:BetterViewPunch(Angle(-30, 0, 0))
		ply:AddAlalnState("crazyness", 0.5)
		dmginfo:ScaleDamage(10)
		if not headshotsound:IsPlaying() then
			headshotsound:Play()
			headshotsound:ChangeVolume(0, 3)
			timer.Simple(3, function()
				if not (IsValid(ply) or headshotsound:IsPlaying()) then return end
				headshotsound:Stop()
			end)
		end

		nextheadshot = CurTime() + 4
	end
end)

util.AddNetworkString("alaln-flinch")
hook.Add("ScalePlayerDamage", "alaln-flinchplayers", function(ply, grp)
	if IsValid(ply) and ply:IsPlayer() and ply:Alive() and not ply:GetNoDraw() then
		local group = nil
		local hitpos = {
			[HITGROUP_HEAD] = ACT_FLINCH_HEAD,
			[HITGROUP_CHEST] = ACT_FLINCH_STOMACH,
			[HITGROUP_STOMACH] = ACT_FLINCH_STOMACH,
			[HITGROUP_LEFTARM] = ACT_FLINCH_STOMACH,
			[HITGROUP_RIGHTARM] = ACT_FLINCH_STOMACH,
			[HITGROUP_LEFTLEG] = ply:GetSequenceActivity(ply:LookupSequence("flinch_01")),
			[HITGROUP_RIGHTLEG] = ply:GetSequenceActivity(ply:LookupSequence("flinch_02"))
		}

		if hitpos[grp] == nil then
			group = ACT_FLINCH_PHYSICS
		else
			group = hitpos[grp]
		end

		net.Start("alaln-flinch")
		net.WriteInt(group, 32)
		net.WriteEntity(ply)
		net.Broadcast()
	end
end)

hook.Add("GetFallDamage", "alaln-falldamage", function(ply, speed) return math.max(0, math.ceil(0.2418 * speed - 141.75)) end)