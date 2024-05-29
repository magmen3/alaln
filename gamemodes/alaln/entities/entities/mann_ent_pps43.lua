AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "mann_ent_base"
ENT.PrintName = "PPS-43"
ENT.Category = "Forsakened"
ENT.SWEP = "mann_wep_pps43"
ENT.Model = Model("models/w_models/weapons/w_smg_a.mdl")
ENT.Color = Color(200, 200, 200, 255)
ENT.ImpactSound = "physics/metal/weapon_impact_soft" .. math.random(1, 3) .. ".wav"
ENT.Spawnable = true
ENT.EntMass = 35
ENT.AmmoAmt = 35
ENT.AmmoType = "pistol"
ENT.RSound = "items/ammo_pickup.wav"
ENT.RSoundPitch = math.random(90, 100)