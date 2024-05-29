include("ai_translations.lua")
include("sh_anim.lua")
include("shared.lua")
SWEP.Slot = 0 -- Slot in the weapon selection menu
SWEP.SlotPos = 2 -- Position in the slot
SWEP.DrawAmmo = false -- Should draw the default HL2 ammo counter
SWEP.DrawCrosshair = true -- Should draw the default crosshair
SWEP.DrawWeaponInfoBox = true -- Should draw the weapon info box
SWEP.BounceWeaponIcon = false -- Should the weapon icon bounce?
SWEP.SwayScale = -2 -- The scale of the viewmodel sway
SWEP.BobScale = -2 -- The scale of the viewmodel bob
SWEP.RenderGroup = RENDERGROUP_OPAQUE
SWEP.WepSelectIcon = surface.GetTextureID("vgui/entities/drc_default")
SWEP.IconOverride = "vgui/entities/drc_default"
function SWEP:DrawHUD()
end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	surface.SetDrawColor(255, 255, 255, alpha or 255)
	surface.SetTexture(self.WepSelectIcon)
	y = y + 10
	x = x + 10
	wide = wide - 20
	surface.DrawTexturedRect(x, y, wide, wide / 2)
	self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
end

-- Circle
function Circle(x, y, radius, seg)
	local cir = {}
	table.insert(cir, {
		x = x,
		y = y,
		u = 0.5,
		v = 0.5
	})

	for i = 0, seg do
		local a = math.rad((i / seg) * -360)
		table.insert(cir, {
			x = x + math.sin(a) * radius,
			y = y + math.cos(a) * radius,
			u = math.sin(a) / 2 + 0.5,
			v = math.cos(a) / 2 + 0.5
		})
	end

	local a = math.rad(0) -- This is needed for non absolute segment counts
	table.insert(cir, {
		x = x + math.sin(a) * radius,
		y = y + math.cos(a) * radius,
		u = math.sin(a) / 2 + 0.5,
		v = math.cos(a) / 2 + 0.5
	})

	surface.DrawPoly(cir)
end

local alpha_black = Color(20, 0, 0, 75)
function SWEP:PrintWeaponInfo(x, y, alpha)
	if self.DrawWeaponInfoBox == false then return end
	if self.InfoMarkup == nil then
		local str
		local title_color = "<color=150, 0, 0, 255>"
		local text_color = "<color=125, 0, 0, 255>"
		str = "<font=alaln-hudfontvsmall>"
		if self.Purpose ~= "" then str = str .. title_color .. "Description:</color>\n" .. text_color .. self.Purpose .. "</color>\n\n" end
		if self.Instructions ~= "" then str = str .. title_color .. "Instruction:</color>\n" .. text_color .. self.Instructions .. "</color>\n" end
		str = str .. "</font>"
		self.InfoMarkup = markup.Parse(str, 250)
	end

	draw.RoundedBox(5, x - 5, y - 6, 280, self.InfoMarkup:GetHeight() + 18, alpha_black)
	self.InfoMarkup:Draw(x + 5, y + 5, nil, nil, 255)
end

--[[---------------------------------------------------------
	Name: SWEP:FreezeMovement()
	Desc: Return true to freeze moving the view
-----------------------------------------------------------]]
function SWEP:FreezeMovement()
	return false
end

--[[---------------------------------------------------------
	Name: SWEP:ViewModelDrawn( viewModel )
	Desc: Called straight after the viewmodel has been drawn
-----------------------------------------------------------]]
function SWEP:ViewModelDrawn(vm)
end

--[[---------------------------------------------------------
	Name: OnRestore
	Desc: Called immediately after a "load"
-----------------------------------------------------------]]
function SWEP:OnRestore()
end

--[[---------------------------------------------------------
	Name: CustomAmmoDisplay
	Desc: Return a table
-----------------------------------------------------------]]
function SWEP:CustomAmmoDisplay()
end

--[[---------------------------------------------------------
	Name: GetViewModelPosition
	Desc: Allows you to re-position the view model
-----------------------------------------------------------]]
function SWEP:GetViewModelPosition(pos, ang)
	return pos, ang
end

--[[---------------------------------------------------------
	Name: TranslateFOV
	Desc: Allows the weapon to translate the player's FOV (clientside)
-----------------------------------------------------------]]
function SWEP:TranslateFOV(current_fov)
	return current_fov
end

--[[---------------------------------------------------------
	Name: DrawWorldModel
	Desc: Draws the world model (not the viewmodel)
-----------------------------------------------------------]]
function SWEP:DrawWorldModel()
	self:DrawModel()
end

--[[---------------------------------------------------------
	Name: DrawWorldModelTranslucent
	Desc: Draws the world model (not the viewmodel)
-----------------------------------------------------------]]
function SWEP:DrawWorldModelTranslucent()
	self:DrawModel()
end

--[[---------------------------------------------------------
	Name: AdjustMouseSensitivity
	Desc: Allows you to adjust the mouse sensitivity.
-----------------------------------------------------------]]
function SWEP:AdjustMouseSensitivity()
	return nil
end

--[[---------------------------------------------------------
	Name: GetTracerOrigin
	Desc: Allows you to override where the tracer comes from (in first person view)
		 returning anything but a vector indicates that you want the default action
-----------------------------------------------------------]]
function SWEP:GetTracerOrigin()
end

--[[---------------------------------------------------------
	Name: FireAnimationEvent
	Desc: Allows you to override weapon animation events
-----------------------------------------------------------]]
function SWEP:FireAnimationEvent(pos, ang, event, options)
	if not self.CSMuzzleFlashes then return end
	-- CS Muzzle flashes
	if event == 5001 or event == 5011 or event == 5021 or event == 5031 then
		local data = EffectData()
		data:SetFlags(0)
		data:SetEntity(self:GetOwner():GetViewModel())
		data:SetAttachment(math.floor((event - 4991) / 10))
		data:SetScale(1)
		if self.CSMuzzleX then
			util.Effect("CS_MuzzleFlash_X", data)
		else
			util.Effect("CS_MuzzleFlash", data)
		end
		return true
	end
end