AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "mann_ent_base"
ENT.PrintName = "Makarov PM"
ENT.Category = "! Forsakened"
ENT.SWEP = "mann_wep_pm"
ENT.Model = Model("models/weapons/tfa_ins2/w_pm.mdl")
ENT.Color = Color(200, 200, 200, 255)
ENT.ImpactSound = "physics/metal/weapon_impact_soft" .. math.random(1, 3) .. ".wav"
ENT.Spawnable = true
ENT.EntMass = 20
ENT.AmmoAmt = 8
ENT.AmmoType = "pistol"
ENT.RSoundPitch = math.random(95, 105)
ENT.IconOverride = "editor/ai_goal_standoff"