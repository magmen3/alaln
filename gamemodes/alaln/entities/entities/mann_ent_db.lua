AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "mann_ent_base"
ENT.PrintName = "Double Barrel Shotgun"
ENT.Category = "! Forsakened"
ENT.SWEP = "mann_wep_db"
ENT.Model = Model("models/weapons/tfa_nmrih/w_fa_sv10.mdl")
ENT.Color = Color(200, 200, 150, 255)
ENT.ImpactSound = "physics/metal/weapon_impact_soft" .. math.random(1, 3) .. ".wav"
ENT.Spawnable = true
ENT.EntMass = 35
ENT.AmmoAmt = 2
ENT.AmmoType = "buckshot"
ENT.RSound = "items/ammo_pickup.wav"
ENT.RSoundPitch = math.random(85, 95)
ENT.IconOverride = "editor/ai_goal_standoff"