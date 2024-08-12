AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "mann_ent_base"
ENT.PrintName = "KM-2000"
ENT.Category = "! Forsakened"
ENT.SWEP = "mann_melee_knife"
ENT.Model = Model("models/weapons/w_km2000_knife.mdl")
ENT.Color = Color(200, 200, 150, 255)
ENT.ImpactSound = "physics/metal/metal_solid_impact_soft" .. math.random(1, 3) .. ".wav"
ENT.SecondSound = "physics/metal/metal_grenade_impact_hard" .. math.random(1, 3) .. ".wav"
ENT.Spawnable = true
ENT.EntMass = 15
ENT.Melee = true
ENT.IconOverride = "editor/ai_goal_police"