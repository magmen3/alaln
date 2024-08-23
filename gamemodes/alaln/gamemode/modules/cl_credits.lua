local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, net, system_HasFocus = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, net, system.HasFocus
local noisetex = Material("vgui/black")
local sndvolume = GetConVar("snd_musicvolume")

local MenuSnds = {
	hover = Sound("in2/ui/buttonrollover.wav"),
	click = Sound("in2/ui/buttonclick.wav")
}

local MenuFonts = {
	small = "alaln-hudfontsmall",
	button = "alaln-hudfontbig",
	big = "alaln-hudfontvbig"
}

local MenuClrs = {
	bg = Color(15, 0, 0, 200),
	white = Color(165, 5, 5, 0)
}

function DrawCredits()
	local ply = LocalPlayer()
	local class = IsValid(ply) and ply:GetAlalnState("class") or "Psychopath"
	local up = 0
	--[[if IsValid(ply) then
		if IsValid(ply) and class == "Operative" then
			MenuClrs.bg = Color(0, 0, 25, 200)
			MenuClrs.white = Color(5, 5, 160, 0)
		elseif IsValid(ply) and class == "Human" then
			MenuClrs.bg = Color(0, 35, 0, 200)
			MenuClrs.white = Color(5, 170, 5, 0)
		else
			MenuClrs.bg = Color(15, 0, 0, 200)
			MenuClrs.white = Color(165, 5, 5, 0)
		end
	else]]
		MenuClrs.bg = Color(15, 0, 0, 200)
		MenuClrs.white = Color(165, 5, 5, 0)
	--end

	local opentime = CurTime() + 4
	local closetime = CurTime()
	local DFrame = vgui.Create("DFrame")
	DFrame:SetPos(0, 0)
	DFrame:SetSize(ScrW(), ScrH())
	DFrame:ShowCloseButton(false)
	DFrame:SetTitle("")
	DFrame:SetDraggable(false)
	DFrame:MakePopup()
	DFrame.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, MenuClrs.bg)
		if DFrame.GoClose then
			MenuClrs.bg.a = math.Clamp(655 * ((closetime - CurTime()) / 2), 0, 200)
			MenuClrs.white.a = math.Clamp(655 * ((closetime - CurTime()) / 2), 0, 255)
			if MenuClrs.white.a <= 0 then self:Close() end
		else
			MenuClrs.white.a = math.Clamp(655 * (1 - (opentime - CurTime()) / 4), 0, 255)
		end
		up = up + 0.7

		surface.SetMaterial(noisetex)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

		draw.SimpleText("Forsakened", MenuFonts.big, w / 2, h / 3 - up, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("Mannytko - main development, bad coding, game design, sound design, original story", MenuFonts.button, w / 2, h * 1.25 - up, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("Crackman - ideas, original gamemode idea, original story", MenuFonts.button, w / 2, h * 1.45 - up, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("Have a nice day. - ideas, story rewrite, music", MenuFonts.button, w / 2, h * 1.65 - up, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("P0lyakov - music that playing right now, sound design, ideas, story rewrite x2", MenuFonts.button, w / 2, h * 1.85 - up, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("Deka - help with code, ideas", MenuFonts.button, w / 2, h * 2.05 - up, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("Patrickkane1997 - minor help with weapons code, ideas", MenuFonts.button, w / 2, h * 2.25 - up, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("You - playing this bad gamemode, and watching this credits screen", MenuFonts.button, w / 2, h * 2.45 - up, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		draw.SimpleText("Main inspirations:", MenuFonts.button, w / 2, h * 3.25 - up, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("Industrial Nightmare/Dysphoria (GMod server)", MenuFonts.button, w / 2, h * 3.45 - up, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("A.L.A.L.N. (Doom mod)", MenuFonts.button, w / 2, h * 3.65 - up, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("Lost in Darkness (Doom mod)", MenuFonts.button, w / 2, h * 3.85 - up, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("Afraid of Monsters (Half-Life mod)", MenuFonts.button, w / 2, h * 4.05 - up, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("Cry of Fear (Half-Life mod/Standalone indie game)", MenuFonts.button, w / 2, h * 4.25 - up, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		MenuClrs.white.a = MenuClrs.white.a / 2
		draw.SimpleText("By " .. GAMEMODE.Author, MenuFonts.small, w / 2, h / 2.4 - up, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	Menu = DFrame
	---------------------------- Music
	timer.Simple(.5, function()
		if not IsValid(ply) then return end
		if not IsValid(DFrame) or DFrame == nil or DFrame.GoClose then return end
		local track = "forsakened/molochsrisingstar.mp3"
		muzon = CreateSound(ply, track)
		muzon:Play()
		muzon:ChangeVolume(sndvolume:GetFloat() or 0.9)
	end)
	
	---------------------------- Skip
	local PlayButton = vgui.Create("DButton", DFrame)
	PlayButton:SetPos(ScrW() / 45, ScrH() / 1.1)
	PlayButton:SetSize(200, 70)
	PlayButton:SetText("")
	PlayButton.DoClick = function()
		if DFrame.GoClose then return end
		timer.Simple(1, function()
			if muzon and muzon:IsPlaying() then muzon:Stop() end
		end)
		surface.PlaySound(MenuSnds.click)
		closetime = CurTime() + 1
		DFrame.GoClose = true
	end

	local color
	local buttoncolor
	--[[if IsValid(ply) and class == "Operative" then
		color = Color(0, 0, 55, 0)
		buttoncolor = Color(0, 0, 50, color.a)
	elseif IsValid(ply) and class == "Human" then
		color = Color(0, 55, 0, 0)
		buttoncolor = Color(0, 50, 0, color.a)
	else]]
		color = Color(55, 0, 0, 0)
		buttoncolor = Color(20, 0, 0, color.a)
	--end

	PlayButton.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, color)
		if self.Hovered then
			if not self.play then
				surface.PlaySound(MenuSnds.hover)
				self.play = true
			end
		else
			self.play = false
		end

		if DFrame.GoClose then
			color.a = math.Clamp(655 * ((closetime - CurTime()) / 2), 0, 100)
		else
			color.a = math.Clamp(655 * (1 - (opentime - CurTime()) / 4), 0, 100)
		end

		draw.RoundedBox(6, 0, 0, w, h, buttoncolor)
		MenuClrs.white.a = MenuClrs.white.a * 6
		draw.SimpleText("Skip", MenuFonts.button, w / 2, h / 2, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

concommand.Add("alaln_credits", function() DrawCredits() end)