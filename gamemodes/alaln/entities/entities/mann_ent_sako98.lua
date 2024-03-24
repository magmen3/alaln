AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "mann_ent_base"
ENT.PrintName = "Sako 98 Sporter Rifle"
ENT.Category = "Forsakened"
ENT.SWEP = "mann_wep_sako98"
ENT.Model = Model("models/weapons/tfa_nmrih/w_fa_sako85_ironsights.mdl")
ENT.Color = Color(200, 200, 200, 255)
ENT.ImpactSound = "physics/metal/weapon_impact_soft" .. math.random(1, 3) .. ".wav"
ENT.Spawnable = true
ENT.EntMass = 22
ENT.AmmoAmt = 5
ENT.AmmoType = "357"
ENT.RSound = "items/ammo_pickup.wav"
ENT.RSoundPitch = math.random(95, 105)