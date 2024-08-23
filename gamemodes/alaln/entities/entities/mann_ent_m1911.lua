AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "mann_ent_base"
ENT.PrintName = "Colt M1911"
ENT.Category = "! Forsakened"
ENT.SWEP = "mann_wep_m1911"
ENT.Model = Model("models/weapons/tfa_doi/w_m1911.mdl")
ENT.Color = Color(200, 200, 150, 255)
ENT.ImpactSound = "physics/metal/weapon_impact_soft" .. math.random(1, 3) .. ".wav"
ENT.Spawnable = true
ENT.EntMass = 25
ENT.AmmoAmt = 7
ENT.AmmoType = "Pistol"
ENT.RSoundPitch = math.random(95, 105)
ENT.IconOverride = "editor/ai_goal_standoff"