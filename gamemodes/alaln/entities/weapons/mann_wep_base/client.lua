local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, net = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, net
AddCSLuaFile()
AddCSLuaFile("shared.lua")
if CLIENT then
	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = true
	SWEP.ViewModelFOV = 80
	SWEP.Slot = 2
	SWEP.SlotPos = 0
	SWEP.Instructions = ""
	SWEP.Purpose = ""
	SWEP.IconOverride = "editor/ai_goal_standoff"
	local color_red = Color(185, 15, 15)
	local clr_white = Color(255, 255, 255)
	function SWEP:DrawHUD()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end
		local Wep = owner:GetActiveWeapon()
		if IsValid(Wep) and self:GetReady() then
			local tr = {}
			tr.start = owner:GetShootPos()
			local dir = Vector(1, 0, 0)
			dir:Rotate(owner:EyeAngles())
			tr.endpos = tr.start + dir * 500
			tr.filter = owner
			local traceResult = util.TraceLine(tr)
			local hitEnt = IsValid(traceResult.Entity) and traceResult.Entity:IsNPC() and color_red or clr_white
			hitEnt.a = (Wep:GetAiming() * 2) + 55
			local frac = traceResult.Fraction
			surface.SetDrawColor(hitEnt)
			draw.NoTexture()
			Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, math.min(20, 5 / frac), 3)
		end

		local ScpMat = surface.GetTextureID("gmod/scope")
		if IsValid(Wep) then
			if Wep.GetAiming and (Wep:GetAiming() > 5) then
				if Wep.Scoped then
					if Wep:GetAiming() >= 99 then
						local W, H = ScrW(), ScrH()
						surface.SetDrawColor(color_black)
						surface.SetTexture(ScpMat)
						surface.DrawTexturedRect(300, -1, W / 1.5 + 1, H + 1)
						surface.SetDrawColor(color_black)
						surface.DrawRect(-1, H / 2, W + 1, 2)
						surface.DrawRect((W / 2) + 5, -1, 2, H + 1)
						surface.DrawRect(0, 0, W / 6, H)
						surface.DrawRect(H * 1.46, 0, W / 5, H)
					end
				else
					DrawToyTown(2, Wep:GetAiming() * ScrH() / 200)
					self.SwayScale = -1.5
					self.BobScale = -1.5
				end
			else
				self.SwayScale = -2
				self.BobScale = -2
			end
		end
	end

	function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
		--if not PotatoMode:GetBool() then
		if not IsValid(DrawModel) then
			if self.VModelForSelector then
				DrawModel = ClientsideModel(self.ViewModel, RENDER_GROUP_OPAQUE_ENTITY)
			else
				DrawModel = ClientsideModel(self.WorldModel, RENDER_GROUP_OPAQUE_ENTITY)
			end

			DrawModel:SetNoDraw(true)
		else
			if self.VModelForSelector then
				DrawModel:SetModel(self.ViewModel)
			else
				DrawModel:SetModel(self.WorldModel)
			end

			local vec = Vector(55, 55, 55)
			local ang = Vector(-48, -48, -48):Angle()
			cam.Start3D(vec, ang, 20, x, y + 35, wide, tall, 5, 4096)
			cam.IgnoreZ(true)
			render.SuppressEngineLighting(true)
			render.SetLightingOrigin(self:GetPos())
			render.ResetModelLighting(50 / 255, 50 / 255, 50 / 255)
			render.SetColorModulation(1, 1, 1)
			render.SetBlend(255)
			render.SetModelLighting(4, 1, 1, 1)
			DrawModel:SetRenderAngles(Angle(0, RealTime() * 30 % 360, 0))
			DrawModel:DrawModel()
			DrawModel:SetRenderAngles()
			render.SetColorModulation(1, 1, 1)
			render.SetBlend(1)
			render.SuppressEngineLighting(false)
			cam.IgnoreZ(false)
			cam.End3D()
		end

		--end
		self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
	end

	function SWEP:TranslateFOV(FoV)
		local Wep = self:GetOwner():GetActiveWeapon()
		if IsValid(Wep) and Wep.GetAiming then
			local Aim = Wep:GetAiming()
			if Aim > 99 then
				if Wep.Scoped then
					FoV = Wep.ScopeFoV or 10
				else
					FoV = 0
				end
			end
		end

		self:GetOwner():SetFOV(FoV, .05)
	end

	function SWEP:AdjustMouseSensitivity()
		local Wep = self:GetOwner():GetActiveWeapon()
		if IsValid(Wep) and Wep.GetAiming then
			local Aim = Wep:GetAiming()
			if Aim > 99 then
				if Wep.Scoped then
					return 0.2
				else
					return 0.5
				end
			end
		end
	end

	local function CleanINS2ProxyHands()
		local HandsEnt = INS2_HandsEnt
		if IsValid(HandsEnt) then
			HandsEnt:RemoveEffects(EF_BONEMERGE)
			HandsEnt:RemoveEffects(EF_BONEMERGE_FASTCULL)
			HandsEnt:SetParent(NULL)
			HandsEnt:Remove()
		end
	end

	local function tryParentHands(Hands, ViewModel, Player, Weapon)
		if not (IsValid(ViewModel) or IsValid(Weapon) or Weapon.InsHands) then
			CleanINS2ProxyHands()
			return
		end

		if not IsValid(Hands) then return end
		if ViewModel:LookupBone("R ForeTwist") and not ViewModel:LookupBone("ValveBiped.Bip01_R_Hand") then
			local HandsEnt = INS2_HandsEnt
			if not IsValid(HandsEnt) then
				INS2_HandsEnt = ClientsideModel("models/weapons/tfa_ins2/c_ins2_pmhands.mdl")
				INS2_HandsEnt:SetNoDraw(true)
				HandsEnt = INS2_HandsEnt
			end

			HandsEnt:SetParent(ViewModel)
			HandsEnt:SetPos(ViewModel:GetPos())
			HandsEnt:SetAngles(ViewModel:GetAngles())
			if not HandsEnt:IsEffectActive(EF_BONEMERGE) then
				HandsEnt:AddEffects(EF_BONEMERGE)
				HandsEnt:AddEffects(EF_BONEMERGE_FASTCULL)
			end

			Hands:SetParent(HandsEnt)
		else
			CleanINS2ProxyHands()
		end
	end

	hook_Add("PreDrawPlayerHands", "alaln-inshands", tryParentHands)
end