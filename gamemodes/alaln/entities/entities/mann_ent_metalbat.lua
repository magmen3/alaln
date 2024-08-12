AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "mann_ent_base"
ENT.PrintName = "Metal Bat"
ENT.Category = "! Forsakened"
ENT.SWEP = "mann_melee_metalbat"
ENT.Model = Model("models/weapons/tfa_nmrih/w_me_bat_metal.mdl")
ENT.Color = Color(200, 200, 200, 255)
ENT.ImpactSound = "physics/metal/metal_solid_impact_soft" .. math.random(1, 3) .. ".wav"
ENT.SecondSound = "physics/metal/metal_grenade_impact_hard" .. math.random(1, 3) .. ".wav"
ENT.Spawnable = true
ENT.EntMass = 25
ENT.Melee = true
ENT.IconOverride = "editor/ai_goal_police"