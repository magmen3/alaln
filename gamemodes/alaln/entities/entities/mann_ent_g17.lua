AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "mann_ent_base"
ENT.PrintName = "Glock-17"
ENT.Category = "! Forsakened"
ENT.SWEP = "mann_wep_g17"
ENT.Model = Model("models/weapons/tfa_nmrih/w_fa_glock17.mdl")
ENT.Color = Color(200, 200, 200, 255)
ENT.ImpactSound = "physics/metal/weapon_impact_soft" .. math.random(1, 3) .. ".wav"
ENT.Spawnable = true
ENT.EntMass = 25
ENT.AmmoAmt = 17
ENT.AmmoType = "Pistol"
ENT.RSound = "items/ammo_pickup.wav"
ENT.RSoundPitch = math.random(95, 105)
ENT.IconOverride = "editor/ai_goal_standoff"