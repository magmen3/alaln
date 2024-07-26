include("shared.lua")
include("loader.lua")
CreateClientConVar("alaln_potatomode", 0, true, false, "Enable low-end PC mode?", 0, 1)
PotatoMode = GetConVar("alaln_potatomode")
RunConsoleCommand("cl_drawownshadow", "1")
local BadType = {
	["joinleave"] = true,
	["namechange"] = true,
	["servermsg"] = false,
	["teamchange"] = true
}

function GM:ChatText(index, name, text, type)
	return BadType[type]
end

hook.Add("DrawDeathNotice", "alaln-hidekillfeed", function()
	return false -- return 0, 0
end)

hook.Add("PlayerStartVoice", "alaln-hideimageonvoice", function() return true end)
gameevent.Listen("player_spawn")
hook.Add("player_spawn", "alaln-networkplyhull", function(data)
	local ply = Player(data.userid)
	--[[if BRANCH ~= "x86-64" then
		for i = 1, 10 do
			ply:ChatPrint("Поставь x64 бету")
		end
	end]]

	ply:SetDSP(0)
	if ply.SetHull then
		ply:SetHull(ply:GetNWVector("HullMin"), ply:GetNWVector("Hull"))
		ply:SetHullDuck(ply:GetNWVector("HullMin"), ply:GetNWVector("HullDuck"))
	end
end)

local color_yellow = Color(255, 235, 0)
concommand.Add("checkammo", function()
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if not (IsValid(wep) and IsValid(ply) and ply:Alive()) then return end
	local ammo, ammobag = wep:GetMaxClip1(), wep:Clip1()
	if ammo <= 0 then return end
	--surface.PlaySound("common/wpn_denyselect.wav")
	--chat.AddText(Color(255, 235, 0), "You can't check ammo on this weapon.")
	surface.PlaySound("physics/metal/weapon_footstep" .. math.random(1, 2) .. ".wav")
	local text
	if ammobag > ammo - 1 then
		text = "Full magazine."
	elseif ammobag > ammo - ammo / 3 then
		text = "~ Almost full magazine."
	elseif ammobag > ammo / 3 then
		text = "~ Half magazine."
	elseif ammobag >= 1 then
		text = "~ Almost empty magazine."
	elseif ammobag < 1 then
		text = "Empty magazine."
	end

	BetterChatPrint(text, color_yellow)
end, nil, "Check your current gun ammo", FCVAR_NONE)

local color_button = Color(165, 0, 0)
local color_ui = Color(0, 0, 0, 150)
net.Receive("alaln-navmeshnotfound", function()
	local navframe = vgui.Create("DFrame")
	navframe:SetSize(500, 500)
	navframe:Center()
	navframe:SetTitle("")
	navframe:SetDraggable(false)
	navframe:ShowCloseButton(true)
	navframe:MakePopup()
	navframe.Paint = function(self, w, h)
		draw.RoundedBox(5, 0, 0, w, h, color_ui)
		draw.SimpleText("Navmesh not found!", hudfontsmall, 245, 30, color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local button1 = vgui.Create("DButton", navframe)
	button1:SetText("")
	button1:SetPos(170, 100)
	button1:SetSize(150, 100)
	button1.Paint = function(self, w, h)
		draw.RoundedBox(5, 0, 0, w, h, color_button)
		draw.SimpleText("Change map in main menu", hudfontsmall, 75, 50, color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	button1.DoClick = function()
		navframe:Close()
		LocalPlayer():ConCommand("disconnect")
	end
end)

net.Receive("alaln-ragplayercolor", function()
	local ent = net.ReadEntity()
	local col = net.ReadVector()
	if IsValid(ent) and isvector(col) then
		function ent:GetPlayerColor()
			return col
		end
	end
end)

net.Receive("alaln-flinch", function(len)
	local gest = net.ReadInt(32)
	local ply = net.ReadEntity()
	if not IsValid(ply) then return end
	ply:AnimRestartGesture(GESTURE_SLOT_FLINCH, gest, true)
end)
--[[ --!! Надо либо сделать альтернативу этой херне хомиградовской либо чет свое чтобы при каждом спавне появлялось
local roundTimeStart = CurTime()
-- format: multiline
local rndsound = {
	--"music/hl2_song10.mp3",
	--"music/hl2_song13.mp3",
	--"music/hl2_song30.mp3",
	--"music/hl2_song33.mp3",
	"in2/waking.mp3"
}

local playsound = true
local color = Color(150, 0, 0, 250)
local hudfont = "alaln-hudfontbig"
local randomstrings = {"RUN", "LIVER FAILURE FOREVER", "YOU'RE ALREADY DEAD", "KILL OR DIE"}
local text
hook.Add("HUDPaint", "alaln-roundstartscreen", function()
	local ply = LocalPlayer()
	local startRound = roundTimeStart + 10 - CurTime()
	if startRound > 0 and ply:Alive() then
		if playsound then
			playsound = false
			surface.PlaySound(table.Random(rndsound))
			text = table.Random(randomstrings)
		end

		ply:ScreenFade(SCREENFADE.IN, color_black, 3, 0.5)
		draw.DrawText("You are Survivor", hudfont, ScrW() / 2, ScrH() / 2, Color(color.r, color.g, color.b, math.Clamp(startRound - 0.5, 0, math.Rand(0.7, 1)) * 255), TEXT_ALIGN_CENTER)
		draw.DrawText("Forsakened", hudfont, ScrW() / 2, ScrH() / 8, Color(color.r, color.g, color.b, math.Clamp(startRound - 0.5, 0, math.Rand(0.7, 1)) * 255), TEXT_ALIGN_CENTER)
		draw.DrawText(text, hudfont, ScrW() / 2, ScrH() / 1.2, Color(color.r, color.g, color.b, math.Clamp(startRound - 0.5, 0, math.Rand(0, 0.1)) * 255), TEXT_ALIGN_CENTER)
		return
	end
end)]]