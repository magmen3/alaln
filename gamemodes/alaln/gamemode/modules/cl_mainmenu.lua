local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, net, system_HasFocus = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, net, system.HasFocus
local MenuSnds = {
	hover = Sound("in2/ui/buttonrollover.wav"),
	click = Sound("in2/ui/buttonclick.wav")
}

local MenuFonts = {
	small = "alaln-hudfontsmall",
	button = "alaln-hudfontbig",
	big = "alaln-hudfontvbig"
}

-- format: multiline
local MenuMusic = {
	"in2/victorian_meltdown.mp3",
	"in2/carnophage.mp3",
	"in2/identity_theft.mp3",
	"in2/maintenance_tunnels.mp3",
	"in2/waking.mp3",
	"placenta/music/whitewaking2.ogg",
	"placenta/music/thecoldflame.ogg",
	"placenta/music/todayisworst.ogg",
	"forsakened/brooms3.mp3"
}

local noisetex = Material("filmgrain/noise")
local noisetex2 = Material("filmgrain/noiseadd")
local muzon, Menu, rndtxt
local DevConVar = GetConVar("developer")
local randomstrings = {"RUN", "LIVER FAILURE FOREVER", "YOU'RE ALREADY DEAD", "KILL OR DIE"}
local randomoperstrings = {"I'm ready.", "Where am i?", "I need to escape this place...", "Where is my team?...", "For what we fighting?", "Why..."}
local textactive = true
local sndvolume = GetConVar("snd_musicvolume")
local function DrawMenu()
	if DevConVar:GetInt() >= 1 then return end
	textactive = true
	local MenuClrs = {
		bg = Color(15, 0, 0, 200),
		white = Color(165, 5, 5, 0)
	}

	local ply = LocalPlayer()
	local class = IsValid(ply) and ply:GetAlalnState("class") or "Psychopath"
	if IsValid(ply) then
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
	else
		MenuClrs.bg = Color(15, 0, 0, 200)
		MenuClrs.white = Color(165, 5, 5, 0)
	end

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

		if class ~= "Operative" then
			surface.SetMaterial(noisetex)
			surface.SetDrawColor(255, 0, 0, 20)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			surface.SetMaterial(noisetex2)
			surface.SetDrawColor(255, 0, 0, 20)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			surface.SetMaterial(noisetex)
			surface.SetDrawColor(0, 0, 255, 35)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			surface.SetMaterial(noisetex2)
			surface.SetDrawColor(0, 0, 255, 35)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end

		draw.SimpleText("Forsakened", MenuFonts.big, w / 4.5, h / 3, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		MenuClrs.white.a = MenuClrs.white.a / 2
		if textactive == true then -- С каждой подписочкой на канал мир становится добрее
			textactive = false
			if class == "Human" then
				rndtxt = "It's fine."
			elseif class == "Operative" then
				rndtxt = table.Random(randomoperstrings)
			else
				rndtxt = table.Random(randomstrings)
			end
		end

		draw.SimpleText("By " .. GAMEMODE.Author, MenuFonts.small, w / 4.5, h / 2.4, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		MenuClrs.white.a = MenuClrs.white.a * math.Rand(0.2, 0.8)
		draw.SimpleText(rndtxt, MenuFonts.button, w / 2, h / 1.1, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	timer.Simple(.5, function()
		if not IsValid(ply) then return end
		if not IsValid(DFrame) or DFrame == nil or DFrame.GoClose then return end
		local track
		if class == "Operative" then
			track = "placenta/music/afterlife.ogg"
		elseif class == "Human" then
			track = "placenta/music/brainmelter1.ogg"
		else
			track = table.Random(MenuMusic)
		end

		muzon = CreateSound(ply, track)
		muzon:Play()
		muzon:ChangeVolume(sndvolume:GetFloat() or 0.9)
	end)

	Menu = DFrame
	---------------------------- Play
	local PlayButton = vgui.Create("DButton", DFrame)
	PlayButton:SetPos(ScrW() / 4.5 - 150, ScrH() / 1.8 - 25)
	PlayButton:SetSize(300, 70)
	PlayButton:SetText("")
	PlayButton.DoClick = function()
		if DFrame.GoClose then return end
		if muzon and muzon:IsPlaying() then muzon:Stop() end
		surface.PlaySound(MenuSnds.click)
		closetime = CurTime() + .6
		DFrame.GoClose = true
	end

	local color
	local buttoncolor
	if IsValid(ply) and class == "Operative" then
		color = Color(0, 0, 55, 0)
		buttoncolor = Color(0, 0, 50, color.a)
	elseif IsValid(ply) and class == "Human" then
		color = Color(0, 55, 0, 0)
		buttoncolor = Color(0, 50, 0, color.a)
	else
		color = Color(55, 0, 0, 0)
		buttoncolor = Color(20, 0, 0, color.a)
	end

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
		draw.SimpleText("Play", MenuFonts.button, w / 2, h / 2, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	---------------------------- Options
	local OptionsButton = vgui.Create("DButton", DFrame)
	OptionsButton:SetPos(ScrW() / 4.5 - 150, ScrH() / 1.6 - 15)
	OptionsButton:SetSize(300, 70)
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
		draw.SimpleText("Settings", MenuFonts.button, w / 2, h / 2, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	---------------------------- Exit
	local ExitButton = vgui.Create("DButton", DFrame)
	ExitButton:SetPos(ScrW() / 4.5 - 150, ScrH() / 1.4 - 25)
	ExitButton:SetSize(300, 70)
	ExitButton:SetText("")
	ExitButton.DoClick = function()
		if muzon and muzon:IsPlaying() then muzon:Stop() end
		surface.PlaySound(MenuSnds.click)
		RunConsoleCommand("disconnect")
	end

	ExitButton.Paint = function(self, w, h)
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
		draw.SimpleText("Quit", MenuFonts.button, w / 2, h / 2, MenuClrs.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

concommand.Add("alaln_menu", function() DrawMenu() end)
local MenuActive = MenuActive or false
gameevent.Listen("OnRequestFullUpdate")
hook_Add("OnRequestFullUpdate", "alaln-mainmenu", function(data)
	local ply = Player(data.userid)
	if ply == LocalPlayer() and not MenuActive then
		if DevConVar:GetInt() >= 1 then return end
		DrawMenu()
		MenuActive = true
	end
end)

hook_Add("PreRender", "alaln-mainmenu", function()
	if input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible() then
		if DevConVar:GetInt() >= 1 then return end
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

hook_Add("RenderScreenspaceEffects", "alaln-mainmenu", function()
	if IsValid(Menu) and system_HasFocus() then
		DrawMotionBlur(0.18, 0.99, 0.05)
		DrawToyTown(2, ScrH() / 2)
		--DrawBokehDOF(1, 1, 5)
	end
end)