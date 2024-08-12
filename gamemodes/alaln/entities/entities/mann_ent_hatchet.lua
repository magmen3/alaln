AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "mann_ent_base"
ENT.PrintName = "Hatchet"
ENT.Category = "! Forsakened"
ENT.SWEP = "mann_melee_hatchet"
ENT.Model = Model("models/weapons/tfa_nmrih/w_me_hatchet.mdl")
ENT.Color = Color(200, 200, 200, 255)
ENT.ImpactSound = "physics/metal/metal_solid_impact_soft" .. math.random(1, 3) .. ".wav"
ENT.SecondSound = "physics/wood/wood_furniture_impact_soft" .. math.random(1, 3) .. ".wav"
ENT.Spawnable = true
ENT.EntMass = 20
ENT.Melee = true
ENT.IconOverride = "editor/ai_goal_police"