AddCSLuaFile()
AddCSLuaFile("shared.lua")
if CLIENT then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.ViewModelFOV = 75
	SWEP.ViewModelPositionOffset = Vector(0, 0, 0)
	SWEP.ViewModelAngleOffset = Angle(0, 0, 0)
	SWEP.Slot = 1
	SWEP.SlotPos = 0
	SWEP.SwayScale = -2.5
	SWEP.BobScale = -3.5
	SWEP.IconOverride = "editor/ai_goal_police"
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

	local Crouched = 0
	function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
		local owner = self:GetOwner()
		if not IsValid(owner) then return pos, ang end
		if owner:KeyDown(IN_DUCK) then
			Crouched = math.Clamp(Crouched + .05, 0, 2)
		else
			Crouched = math.Clamp(Crouched - .05, 0, 2)
		end

		local forward, right, up = self.ViewModelPositionOffset.x, self.ViewModelPositionOffset.y, self.ViewModelPositionOffset.z + Crouched
		local angs = owner:EyeAngles()
		--ang.pitch = -ang.pitch
		local s, t = math.sin, CurTime()
		local offset = Vector(s(t * 1.5) * 0.5, s(t * 1.6) * 0.6, s(t * 1.7) * 0.8)
		ang:RotateAroundAxis(ang:Forward(), self.ViewModelAngleOffset.pitch)
		ang:RotateAroundAxis(ang:Right(), self.ViewModelAngleOffset.roll)
		ang:RotateAroundAxis(ang:Up(), self.ViewModelAngleOffset.yaw)
		return pos + offset + angs:Forward() * forward + angs:Right() * right + angs:Up() * up, ang
	end

	function SWEP:DrawWorldModel()
		if IsValid(self:GetOwner()) then
			local Pos, Ang = self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))
			if self.DatWorldModel then
				if Pos and Ang then
					self.DatWorldModel:SetRenderOrigin(Pos + Ang:Forward() * 3.9 + Ang:Right() - Ang:Up() * .5)
					Ang:RotateAroundAxis(Ang:Up(), 180)
					Ang:RotateAroundAxis(Ang:Right(), 90)
					self.DatWorldModel:SetRenderAngles(Ang)
					self.DatWorldModel:DrawModel()
				end
			else
				self.DatWorldModel = ClientsideModel(self.WorldModel)
				self.DatWorldModel:SetPos(self:GetPos())
				self.DatWorldModel:SetParent(self)
				self.DatWorldModel:SetNoDraw(true)
				self.DatWorldModel:SetModelScale(1, 0)
			end
		else
			self:DrawModel()
		end
	end

	local color_red = Color(185, 15, 15)
	function SWEP:DrawHUD()
		local owner = self:GetOwner()
		local tr = {}
		tr.start = owner:GetShootPos()
		local dir = Vector(1, 0, 0)
		dir:Rotate(owner:EyeAngles())
		tr.endpos = tr.start + dir * 500
		tr.filter = owner
		local traceResult = util.TraceLine(tr)
		local hitEnt = IsValid(traceResult.Entity) and traceResult.Entity:IsNPC() and color_red or color_white
		local frac = traceResult.Fraction
		local alpha = -(frac * 255 - 255) / 2
		surface.SetDrawColor(hitEnt.r, hitEnt.g, hitEnt.b, alpha)
		draw.NoTexture()
		Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, math.min(20, 5 / frac), 3)
	end
end