AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "mann_ent_base"
ENT.PrintName = "M16"
ENT.Category = "! Forsakened"
ENT.SWEP = "mann_wep_m16"
ENT.Model = Model("models/weapons/tfa_nmrih/w_fa_m16a4.mdl")
ENT.Color = Color(200, 200, 200, 255)
ENT.ImpactSound = "physics/metal/weapon_impact_soft" .. math.random(1, 3) .. ".wav"
ENT.Spawnable = true
ENT.EntMass = 40
ENT.AmmoAmt = 30
ENT.AmmoType = "AR2"
ENT.RSoundPitch = math.random(90, 100)
ENT.IconOverride = "editor/ai_goal_standoff"