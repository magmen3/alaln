local MenuSnds = {
	hover = Sound("in2/ui/buttonrollover.wav"),
	click = Sound("in2/ui/buttonclick.wav")
}

local MenuFonts = {
	small = "alaln-hudfontvsmall",
	button = "alaln-hudfontsmall",
	big = "alaln-hudfontbig"
}

-- format: multiline
local MenuMusic = {
	"in2/victorian_meltdown.mp3",
	"in2/carnophage.mp3",
	"in2/identity_theft.mp3",
	"in2/maintenance_tunnels.mp3"
}

local muzon
local Menu
local function DrawMenu()
	local MenuClrs = {
		bg = Color(10, 0, 0, 255),
		white = Color(165, 5, 5, 0)
	}

	local opentime = CurTime() + 5
	local closetime = CurTime()
	local DFrame = vgui.Create("DFrame")
	DFrame:SetPos(0, 0)
	DFrame:SetSize(ScrW(), ScrH())
	DFrame:ShowCloseButton(false)
	DFrame:SetTitle("")
	DFrame:SetDraggable(false)
	DFrame:MakePopup()
	DFrame.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, MenuClrs.bg)
		if DFrame.GoClose then
			MenuClrs.bg.a = math.Clamp(655 * ((closetime - CurTime()) / 2), 0, 255)
			MenuClrs.white.a = math.Clamp(655 * ((closetime - CurTime()) / 2), 0, 255)
			if MenuClrs.white.a <= 0 then self:Close() end
		else
			MenuClrs.white.a = math.Clamp(655 * (1 - (opentime - CurTime()) / 4), 0, 255)
		end

		draw.SimpleText("Forsakened", MenuFonts.big, w / 2, h / 3, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		MenuClrs.white.a = MenuClrs.white.a / 6
		draw.SimpleText("By Mannytko and Deka", MenuFonts.small, w / 2, h / 2.4, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	if IsValid(LocalPlayer()) then
		local track = table.Random(MenuMusic)
		muzon = CreateSound(LocalPlayer(), track)
		muzon:Play()
	end

	Menu = DFrame
	---------------------------- Play
	local PlayButton = vgui.Create("DButton", DFrame)
	PlayButton:SetPos(ScrW() / 2 - 150, ScrH() / 1.8 - 25)
	PlayButton:SetSize(300, 50)
	PlayButton:SetText("")
	PlayButton.DoClick = function()
		if DFrame.GoClose then return end
		if muzon and muzon:IsPlaying() then muzon:Stop() end
		surface.PlaySound(MenuSnds.click)
		closetime = CurTime() + 1
		DFrame.GoClose = true
	end

	local color = Color(55, 0, 0, 0)
	PlayButton.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, color)
		if self.Hovered then
			if not self.play then
				surface.PlaySound(MenuSnds.hover)
				self.play = true
			end
		else
			self.play = false
		end

		if DFrame.GoClose then
			color.a = math.Clamp(655 * ((closetime - CurTime()) / 2), 0, 255)
		else
			color.a = math.Clamp(655 * (1 - (opentime - CurTime()) / 4), 0, 255)
		end

		draw.RoundedBox(5, 0, 0, w, h, Color(20, 0, 0, color.a))
		MenuClrs.white.a = MenuClrs.white.a * 6
		draw.SimpleText("Play", MenuFonts.button, w / 2, h / 2, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	---------------------------- Options
	local OptionsButton = vgui.Create("DButton", DFrame)
	OptionsButton:SetPos(ScrW() / 2 - 150, ScrH() / 1.6 - 25)
	OptionsButton:SetSize(300, 50)
	OptionsButton:SetText("")
	OptionsButton.DoClick = function()
		if DFrame.GoClose then return end
		if muzon and muzon:IsPlaying() then muzon:Stop() end
		surface.PlaySound(MenuSnds.click)
		closetime = CurTime() + .3
		DFrame.GoClose = true
		gui.ActivateGameUI()
	end

	OptionsButton.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, color)
		if self.Hovered then
			if not self.play then
				surface.PlaySound(MenuSnds.hover)
				self.play = true
			end
		else
			self.play = false
		end

		if DFrame.GoClose then
			color.a = math.Clamp(655 * ((closetime - CurTime()) / 2), 0, 255)
		else
			color.a = math.Clamp(655 * (1 - (opentime - CurTime()) / 4), 0, 255)
		end

		draw.RoundedBox(5, 0, 0, w, h, Color(20, 0, 0, color.a))
		draw.SimpleText("Settings", MenuFonts.button, w / 2, h / 2, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	---------------------------- Exit
	local ExitButton = vgui.Create("DButton", DFrame)
	ExitButton:SetPos(ScrW() / 2 - 150, ScrH() / 1.4 - 25)
	ExitButton:SetSize(300, 50)
	ExitButton:SetText("")
	ExitButton.DoClick = function()
		if muzon and muzon:IsPlaying() then muzon:Stop() end
		surface.PlaySound(MenuSnds.click)
		RunConsoleCommand("disconnect")
	end

	ExitButton.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, color)
		if self.Hovered then
			if not self.play then
				surface.PlaySound(MenuSnds.hover)
				self.play = true
			end
		else
			self.play = false
		end

		if DFrame.GoClose then
			color.a = math.Clamp(655 * ((closetime - CurTime()) / 2), 0, 255)
		else
			color.a = math.Clamp(655 * (1 - (opentime - CurTime()) / 4), 0, 255)
		end

		draw.RoundedBox(5, 0, 0, w, h, Color(20, 0, 0, color.a))
		draw.SimpleText("Quit", MenuFonts.button, w / 2, h / 2, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

concommand.Add("alaln_menu", function() DrawMenu() end)
local MenuActive = MenuActive or false
gameevent.Listen("OnRequestFullUpdate")
hook.Add("OnRequestFullUpdate", "alaln-mainmenu", function(data)
	if not MenuActive then
		DrawMenu()
		MenuActive = true
	end
end)

hook.Add("PreRender", "alaln-mainmenu", function()
	if input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible() then
		if IsValid(Menu) then
			if muzon and muzon:IsPlaying() then muzon:Stop() end
			gui.HideGameUI()
			Menu:Remove()
		else
			gui.HideGameUI()
			DrawMenu()
		end
	end
end)