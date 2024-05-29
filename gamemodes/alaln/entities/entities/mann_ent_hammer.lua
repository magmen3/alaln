AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "mann_ent_base"
ENT.PrintName = "Claw Hammer"
ENT.Category = "Forsakened"
ENT.SWEP = "mann_melee_hammer"
ENT.Model = Model("models/weapons/tfa_nmrih/w_tool_barricade.mdl")
ENT.Color = Color(200, 200, 200, 255)
ENT.ImpactSound = "physics/metal/metal_solid_impact_soft" .. math.random(1, 3) .. ".wav"
ENT.SecondSound = "physics/wood/wood_furniture_impact_soft" .. math.random(1, 3) .. ".wav"
ENT.Spawnable = true
ENT.EntMass = 18
ENT.Melee = true