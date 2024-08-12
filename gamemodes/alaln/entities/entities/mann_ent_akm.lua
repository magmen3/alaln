AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "mann_ent_base"
ENT.PrintName = "AKM"
ENT.Category = "! Forsakened"
ENT.SWEP = "mann_wep_akm"
ENT.Model = Model("models/weapons/tfa_ins2/w_akm_bw.mdl")
ENT.Color = Color(200, 200, 200, 255)
ENT.ImpactSound = "physics/metal/weapon_impact_soft" .. math.random(1, 3) .. ".wav"
ENT.Spawnable = true
ENT.EntMass = 40
ENT.AmmoAmt = 30
ENT.AmmoType = "AR2"
ENT.RSound = "items/ammo_pickup.wav"
ENT.RSoundPitch = math.random(90, 100)
ENT.IconOverride = "editor/ai_goal_standoff"