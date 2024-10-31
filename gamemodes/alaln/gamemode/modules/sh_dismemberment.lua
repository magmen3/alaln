--!! Need to rewrite
local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, net = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, net
local vecZero = Vector(0, 0, 0)
bonetohitgroup = {
	["ValveBiped.Bip01_Head1"] = 1,
	["ValveBiped.Bip01_R_UpperArm"] = 5,
	["ValveBiped.Bip01_R_Forearm"] = 5,
	["ValveBiped.Bip01_R_Hand"] = 5,
	["ValveBiped.Bip01_L_UpperArm"] = 4,
	["ValveBiped.Bip01_L_Forearm"] = 4,
	["ValveBiped.Bip01_L_Hand"] = 4,
	["ValveBiped.Bip01_Pelvis"] = 3,
	["ValveBiped.Bip01_Spine2"] = 2,
	["ValveBiped.Bip01_L_Thigh"] = 6,
	["ValveBiped.Bip01_L_Calf"] = 6,
	["ValveBiped.Bip01_L_Foot"] = 6,
	["ValveBiped.Bip01_R_Thigh"] = 7,
	["ValveBiped.Bip01_R_Calf"] = 7,
	["ValveBiped.Bip01_R_Foot"] = 7
}

RagdollDamageBoneMul = {
	[HITGROUP_LEFTLEG] = 0.5,
	[HITGROUP_RIGHTLEG] = 0.5,
	[HITGROUP_GENERIC] = 1,
	[HITGROUP_LEFTARM] = 0.5,
	[HITGROUP_RIGHTARM] = 0.5,
	[HITGROUP_CHEST] = 1,
	[HITGROUP_STOMACH] = 1,
	[HITGROUP_HEAD] = 4,
}

local function removeBone(rag, bone, phys_bone)
	rag:ManipulateBoneScale(bone, vecZero)
	--rag:ManipulateBonePosition(bone,vecInf) -- Thanks Rama (only works on certain graphics cards!)
	if rag.gibRemove[phys_bone] then return end
	local phys_obj = rag:GetPhysicsObjectNum(phys_bone)
	phys_obj:EnableCollisions(false)
	phys_obj:SetMass(0.01)
	--rag:RemoveInternalConstraint(phys_bone)
	constraint.RemoveAll(phys_obj)
	rag.gibRemove[phys_bone] = phys_obj
end

local function recursive_bone(rag, bone, list)
	for i, bone in pairs(rag:GetChildBones(bone)) do
		if bone == 0 then --wtf
			continue
		end

		list[#list + 1] = bone
		recursive_bone(rag, bone, list)
	end
end

function Gib_RemoveBone(rag, bone, phys_bone)
	rag.gibRemove = rag.gibRemove or {}
	removeBone(rag, bone, phys_bone)
	local list = {}
	recursive_bone(rag, bone, list)
	for i, bone in pairs(list) do
		removeBone(rag, bone, rag:TranslateBoneToPhysBone(bone))
	end
end

concommand.Add("removebone", function(ply)
	local trace = ply:GetEyeTrace()
	local ent = trace.Entity
	if not IsValid(ent) then return end
	local phys_bone = trace.PhysicsBone
	if not phys_bone or phys_bone == 0 then return end
	Gib_RemoveBone(ent, ent:TranslatePhysBoneToBone(phys_bone), phys_bone)
end)

gib_ragdols = gib_ragdols or {}
local gib_ragdols = gib_ragdols
local function BodyExplode(pos)
	-- format: multiline
	local propModels = {
		"models/mosi/fnv/props/gore/gorehead03.mdl",
		"models/mosi/fnv/props/gore/gorehead02.mdl",
		"models/mosi/fnv/props/gore/gorehead04.mdl",
		"models/mosi/fnv/props/gore/gorearm03.mdl",
		"models/mosi/fnv/props/gore/gorearm.mdl",
		"models/mosi/fnv/props/gore/gorearm02.mdl",
		"models/mosi/fnv/props/gore/gorelegb01.mdl",
		"models/mosi/fnv/props/gore/goretorso02.mdl",
		"models/Gibs/HGIBS_rib.mdl",
		"models/mosi/fnv/props/gore/goretorso03.mdl"
	}

	for i = 1, #propModels do
		timer.Simple(0.1, function()
			local prop = ents.Create("prop_physics")
			if not IsValid(prop) then return end
			prop:SetModel(propModels[i])
			prop:SetPos(pos)
			prop:Spawn()
			local randomVelocity = Vector(math.random(-500, 500), math.random(-500, 500), math.random(-500, 500))
			prop:GetPhysicsObject():SetVelocity(randomVelocity)
			SafeRemoveEntityDelayed(prop, 45)
		end)
	end
	for i = 0, 6 do
		timer.Simple(0.1, function()
			local gib = ents.Create("alaln_food")
			if not IsValid(gib) then return end
			gib:SetPos(pos)
			gib.CannibalOnly = true
			gib:Spawn()
			gib:Activate()
			local randomVelocity = Vector(math.random(-150, 150), math.random(-500, 500), math.random(-150, 150)) / 2
			gib:GetPhysicsObject():SetVelocity(randomVelocity)
			SafeRemoveEntityDelayed(gib, 60)
		end)
	end
end

local function HeadExplode(pos)
	-- format: multiline
	local propModels = {
		"models/mosi/fnv/props/gore/gorehead03.mdl",
		"models/mosi/fnv/props/gore/gorehead02.mdl",
		"models/mosi/fnv/props/gore/gorehead06.mdl",
		"models/mosi/fnv/props/gore/gorehead05.mdl",
		"models/mosi/fnv/props/gore/gorehead04.mdl"
	}

	timer.Simple(0.1, function()
		for i = 1, #propModels do
			local prop = ents.Create("prop_physics")
			if not IsValid(prop) then return end
			prop:SetModel(propModels[i])
			prop:SetPos(pos)
			prop:Spawn()
			local randomVelocity = Vector(math.random(-150, 150), math.random(-500, 500), math.random(-150, 150))
			prop:GetPhysicsObject():SetVelocity(randomVelocity)
			SafeRemoveEntityDelayed(prop, 45)
		end
	end)
end

function Gib_Input(rag, bone, dmgInfo, player)
	if not IsValid(rag) then return end
	local hitgroup = bonetohitgroup[rag:GetBoneName(bone)]
	local gibRemove = rag.gibRemove
	if not gibRemove then
		rag.gibRemove = {}
		gibRemove = rag.gibRemove
		gib_ragdols[rag] = true
	end

	local phys_bone = rag:TranslateBoneToPhysBone(bone)
	local dmgPos = dmgInfo:GetDamagePosition()
	if dmgInfo:GetDamage() >= 50 and dmgInfo:IsDamageType(DMG_BLAST) then
		local bone = rag:LookupBone("ValveBiped.Bip01_Spine3")
		if bone and rag:GetPhysicsObjectNum(bone):Distance(dmgPos) <= 75 then
			rag:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(2, 4) .. ".wav")
			rag:EmitSound("physics/body/body_medium_break3.wav")
			rag:EmitSound("physics/flesh/flesh_bloody_break.wav", 75)
			rag:EmitSound("vj_cofr/fx/bodysplat.wav", 80)
			rag:Remove()
			return
		end
	end

	if hitgroup == HITGROUP_HEAD and not gibRemove[phys_bone] then
		rag:EmitSound("player/headshot" .. math.random(1, 2) .. ".wav")
		rag:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(2, 4) .. ".wav")
		rag:EmitSound("physics/body/body_medium_break3.wav")
		rag:EmitSound("physics/glass/glass_sheet_step" .. math.random(1, 4) .. ".wav", 90, 50)
		timer.Simple(0.05, function()
			if not IsValid(rag) then return end
			rag:EmitSound("physics/flesh/flesh_bloody_break.wav", 90, 75)
		end)

		Gib_RemoveBone(rag, bone, phys_bone)
		HeadExplode(rag:GetPhysicsObject(phys_bone):GetPos())
	end

	if dmgInfo:GetDamage() >= 300 and dmgInfo:IsDamageType(DMG_CRUSH + DMG_BLAST + DMG_VEHICLE + DMG_FALL) or rag:GetVelocity():Length() > 650 and dmgInfo:IsDamageType(DMG_CRUSH + DMG_BLAST + DMG_VEHICLE + DMG_FALL) then
		dmgInfo:ScaleDamage(5000)
		rag:EmitSound("player/headshot" .. math.random(1, 2) .. ".wav")
		rag:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(2, 4) .. ".wav")
		rag:EmitSound("physics/body/body_medium_break3.wav")
		rag:EmitSound("physics/glass/glass_sheet_step" .. math.random(1, 4) .. ".wav", 90, 50)
		rag:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(2, 4) .. ".wav")
		rag:EmitSound("physics/body/body_medium_break3.wav")
		rag:EmitSound("physics/flesh/flesh_bloody_break.wav", 75)
		rag:EmitSound("physics/flesh/flesh_bloody_impact_hard1.wav", 75)
		rag:Remove()
		BodyExplode(rag:GetPhysicsObject(phys_bone):GetPos())
	end

	rag:GetPhysicsObject():SetMass(20)
end

hook.Add("PlayerDeath", "Gib", function(ply)
	dmgInfo = ply.LastDMGInfo
	if not dmgInfo then return end
	if dmgInfo:GetDamage() >= 10 then
		timer.Simple(0, function()
			local rag = ply:GetNWEntity("plyrag")
			local bone = rag:LookupBone(ply.LastHitBoneName)
			if not IsValid(rag) or not bone then return end
			Gib_Input(rag, bone, dmgInfo, player)
		end)
	end
end)

function GetPhysicsBoneDamageInfo(ent, dmgInfo)
	local pos = dmgInfo:GetDamagePosition()
	local dir = dmgInfo:GetDamageForce():GetNormalized()
	dir:Mul(1024 * 8)
	local tr = {}
	tr.start = pos
	tr.endpos = pos + dir
	tr.filter = filter
	filterEnt = ent
	tr.ignoreworld = true
	local result = util.TraceLine(tr)
	if result.Entity ~= ent then
		tr.endpos = pos - dir
		return util.TraceLine(tr).PhysicsBone
	else
		return result.PhysicsBone
	end
end

hook.Add("EntityTakeDamage", "Gib", function(ent, dmgInfo)
	if not ent:IsRagdoll() then return end
	local phys_bone = GetPhysicsBoneDamageInfo(ent, dmgInfo)
	if phys_bone == 0 then --lol
		return
	end

	local hitgroup
	local bonename = ent:GetBoneName(ent:TranslatePhysBoneToBone(phys_bone))
	if bonetohitgroup[bonename] then hitgroup = bonetohitgroup[bonename] end
	local mul = RagdollDamageBoneMul[hitgroup]
	if not mul then return end
	if dmgInfo:GetDamage() * mul < 350 then return end
	Gib_Input(ent, ent:TranslatePhysBoneToBone(phys_bone), dmgInfo)
end)