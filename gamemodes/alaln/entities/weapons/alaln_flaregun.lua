AddCSLuaFile()
SWEP.Base = "weapon_vj_flaregun"
SWEP.Spawnable = true
SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/tfa_nmrih/v_fa_flaregun.mdl")
SWEP.WorldModel = Model("models/weapons/tfa_nmrih/w_fa_flaregun.mdl")
SWEP.Droppable = false
SWEP.WorldModelPosition = Vector(5.5, -1.5, -1.5)
SWEP.WorldModelAngle = Angle(180, 180, 0)
SWEP.HolsterSlot = 2
SWEP.Primary.DefaultClip = 3
SWEP.Droppable = true
if SERVER then
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
	SWEP.AdminOnly = true
else
	SWEP.Category = "! Forsakened"
	SWEP.PrintName = "Flare Gun"
	SWEP.Slot = 2
	SWEP.SlotPos = 2
	SWEP.BobScale = -2
	SWEP.SwayScale = -2
	SWEP.DrawAmmo = false
	SWEP.DrawSecondaryAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.ViewModelPositionOffset = Vector(-11, -0.5, 0)
	SWEP.ViewModelAngleOffset = Angle(-5, 0, 0)
	SWEP.ViewModelFOV = 110
	SWEP.IconOverride = "editor/env_explosion"
	SWEP.DrawWeaponInfoBox = true
	SWEP.Author = ""
	SWEP.Contact = ""
	SWEP.Purpose = "PLACEHOLDER" --!!
	SWEP.Instructions = "LMB to fire."
	local color_red = Color(180, 0, 0)
	function SWEP:DrawHUD()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end
		local Wep = owner:GetActiveWeapon()
		if IsValid(Wep) then
			local tr = {}
			tr.start = owner:GetShootPos()
			local dir = Vector(1, 0, 0)
			dir:Rotate(owner:EyeAngles())
			tr.endpos = tr.start + dir * 500
			tr.filter = owner
			local traceResult = util.TraceLine(tr)
			local hitEnt = IsValid(traceResult.Entity) and traceResult.Entity:IsNPC() and color_red or color_white
			local frac = traceResult.Fraction
			surface.SetDrawColor(hitEnt)
			draw.NoTexture()
			Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, math.min(20, 5 / frac), 3)
		end
	end

	local alpha_black = Color(25, 0, 0, 250)
	function SWEP:PrintWeaponInfo(x, y, alpha)
		if self.DrawWeaponInfoBox == false then return end
		if self.InfoMarkup == nil then
			local str
			local title_color = "<color=185, 0, 0, 255>"
			local text_color = "<color=165, 0, 0, 255>"
			str = "<font=alaln-hudfontvsmall>"
			if self.Purpose ~= "" then str = str .. title_color .. "Description:</color>\n" .. text_color .. self.Purpose .. "</color>\n\n" end
			if self.Instructions ~= "" then str = str .. title_color .. "Instruction:</color>\n" .. text_color .. self.Instructions .. "</color>\n" end
			str = str .. "</font>"
			self.InfoMarkup = markup.Parse(str, 250)
		end

		draw.RoundedBox(5, x - 5, y - 6, 280, self.InfoMarkup:GetHeight() + 18, alpha_black)
		self.InfoMarkup:Draw(x + 5, y + 5, nil, nil, 255)
	end

	function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
		--if not PotatoMode:GetBool() then
			if not IsValid(DrawModel) then
				DrawModel = ClientsideModel(self.WorldModel, RENDER_GROUP_OPAQUE_ENTITY)
				DrawModel:SetNoDraw(true)
			else
				DrawModel:SetModel(self.WorldModel)
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
		ang:RotateAroundAxis(ang:Forward(), self.ViewModelAngleOffset.pitch)
		ang:RotateAroundAxis(ang:Right(), self.ViewModelAngleOffset.roll)
		ang:RotateAroundAxis(ang:Up(), self.ViewModelAngleOffset.yaw)
		return pos + angs:Forward() * forward + angs:Right() * right + angs:Up() * up, ang
	end

	function SWEP:DrawWorldModel()
		local ply = self:GetOwner()
		if IsValid(self.WM) then
			local wm = self.WM
			if IsValid(ply) then
				local offsetVec = self.WorldModelPosition
				local offsetAng = self.WorldModelAngle
				local boneid = ply:LookupBone("ValveBiped.Bip01_R_Hand")
				if not boneid then return end
				local matrix = ply:GetBoneMatrix(boneid)
				if not matrix then return end
				local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
				wm:SetPos(newPos)
				wm:SetAngles(newAng)
				wm:SetupBones()
			else
				wm:SetPos(self:GetPos())
				wm:SetAngles(self:GetAngles())
			end

			wm:DrawModel()
		else
			self.WM = ClientsideModel(self.WorldModel)
			self.WM:SetNoDraw(true)
		end
	end
end