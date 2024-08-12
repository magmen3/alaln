AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "mann_ent_base"
ENT.PrintName = "Flare Gun"
ENT.Category = "! Forsakened"
ENT.SWEP = "mann_wep_flaregun"
ENT.Model = Model("models/weapons/tfa_nmrih/w_fa_flaregun.mdl")
ENT.Color = Color(200, 200, 200, 255)
ENT.ImpactSound = "physics/metal/weapon_impact_soft" .. math.random(1, 3) .. ".wav"
ENT.Spawnable = true
ENT.EntMass = 20
ENT.AmmoAmt = 1
ENT.AmmoType = "357"
ENT.RSound = "items/ammo_pickup.wav"
ENT.RSoundPitch = math.random(85, 95)
ENT.IconOverride = "editor/ai_goal_standoff"