local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector
local CMClr = {
	ui = Color(20, 0, 0, 220),
	button = Color(20, 0, 0, 200),
	text = Color(185, 15, 15)
}

local CMClr_Oper = {
	ui = Color(0, 0, 20, 220),
	button = Color(0, 0, 20, 200),
	text = Color(0, 0, 190)
}

local hudfontsmall, hudfontbig, modelang = "alaln-hudfontsmall", "alaln-hudfontbig", Angle(0, 60, 0)
-- class menu
--!! TODO: Надо будет переделать текст в классах чтобы под мониторы подходило разные
net.Receive("alaln-classmenu", function()
	local ply = LocalPlayer()
	if IsValid(ply) and ply:Alive() then
		local class = ply:GetAlalnState("class")
		if class ~= "Operative" then
			CMClr = CMClr
		else
			CMClr = CMClr_Oper
		end
	end

	--------------------------------------------------- Class Menu
	local frame = vgui.Create("DFrame")
	frame:SetSize(800, 1000)
	frame:Center()
	frame:SetTitle("")
	frame:SetDraggable(false)
	frame:MakePopup()
	frame.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, CMClr.ui)
		draw.SimpleText("Select Class", hudfontbig, 400, 50, CMClr.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	--------------------------------------------------- Model viewer
	if IsValid(ply) and ply:Alive() then
		local class = ply:GetAlalnState("class")
		local model = vgui.Create("DModelPanel", frame)
		model:SetSize(700, 700)
		model:SetPos(-150, 200)
		local mdl -- i fucking hate this stupid game that can't even get model on client
		if class ~= "Operative" then
			mdl = "models/player/corpse1.mdl"
		elseif class == "Operative" then
			mdl = "models/forsakened/purifier/masked_cop.mdl"
		end

		model:SetModel(mdl or ply:GetModel())
		function model:LayoutEntity(ent)
			ent:SetSequence(ent:LookupSequence("idle_all_scared"))
			ent:SetAngles(modelang)
			ent:SetMaterial(ply:GetMaterial())
			ent:SetColor(ply:GetColor())
			ent:SetRenderFX(15)
			for i = 0, 16 do
				ent:SetSubMaterial(i, ply:GetSubMaterial(i))
			end

			ent:SetSkin(ply:GetSkin())
			if IsValid(model.Entity) then
				local mn, mx = model.Entity:GetRenderBounds()
				local size = 0
				size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
				size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
				size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
				model:SetFOV(85)
				model:SetCamPos(Vector(size / 2, size / 2, size / 2))
				model:SetLookAt((mn + mx) * 0.5)
			end
		end

		function model.Entity:GetPlayerColor()
			return ply:GetPlayerColor()
		end
	end

	--------------------------------------------------- Psychopath (Standard)
	local button_psycho = vgui.Create("DButton", frame)
	button_psycho:SetText("")
	button_psycho:SetPos(445, 100)
	button_psycho:SetSize(200, 100)
	button_psycho.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, CMClr.button)
		draw.SimpleText("Psychopath", hudfontsmall, 100, 50, CMClr.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	button_psycho.DoClick = function()
		net.Start("alaln-setclass")
		net.WritePlayer(ply)
		net.WriteString("Psychopath")
		net.SendToServer()
		frame:Close()
	end

	--------------------------------------------------- Faster
	local button_faster = vgui.Create("DButton", frame)
	button_faster:SetText("")
	button_faster:SetPos(445, 250)
	button_faster:SetSize(200, 100)
	button_faster.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, CMClr.button)
		draw.SimpleText("Faster", hudfontsmall, 100, 50, CMClr.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	button_faster.DoClick = function()
		net.Start("alaln-setclass")
		net.WritePlayer(ply)
		net.WriteString("Faster")
		net.SendToServer()
		frame:Close()
	end

	--------------------------------------------------- Cannibal
	local button_cannibal = vgui.Create("DButton", frame)
	button_cannibal:SetText("")
	button_cannibal:SetPos(445, 400)
	button_cannibal:SetSize(200, 100)
	button_cannibal.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, CMClr.button)
		draw.SimpleText("Cannibal (45)", hudfontsmall, 100, 50, CMClr.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	button_cannibal.DoClick = function()
		DebugPrint("Selected Cannibal class")
		if ply:GetAlalnState("score") < 45 then
			BetterChatPrint("You need more score to choose this class.", CMClr.text)
			return
		end

		net.Start("alaln-setclass")
		net.WritePlayer(ply)
		net.WriteString("Cannibal")
		net.SendToServer()
		frame:Close()
	end

	--------------------------------------------------- Berserker
	local button_berserk = vgui.Create("DButton", frame)
	button_berserk:SetText("")
	button_berserk:SetPos(445, 550)
	button_berserk:SetSize(200, 100)
	button_berserk.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, CMClr.button)
		draw.SimpleText("Berserker (75)", hudfontsmall, 100, 50, CMClr.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	button_berserk.DoClick = function()
		DebugPrint("Selected Berserker class")
		if ply:GetAlalnState("score") < 75 then
			BetterChatPrint("You need more score to choose this class.", CMClr.text)
			return
		end

		net.Start("alaln-setclass")
		net.WritePlayer(ply)
		net.WriteString("Berserker")
		net.SendToServer()
		frame:Close()
	end

	--------------------------------------------------- Gunslinger
	local button_gunslinger = vgui.Create("DButton", frame)
	button_gunslinger:SetText("")
	button_gunslinger:SetPos(445, 700)
	button_gunslinger:SetSize(200, 100)
	button_gunslinger.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, CMClr.button)
		draw.SimpleText("Gunslinger (95)", hudfontsmall, 100, 50, CMClr.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	button_gunslinger.DoClick = function()
		DebugPrint("Selected Gunslinger class")
		if ply:GetAlalnState("score") < 95 then
			BetterChatPrint("You need more score to choose this class.", CMClr.text)
			return
		end

		net.Start("alaln-setclass")
		net.WritePlayer(ply)
		net.WriteString("Gunslinger")
		net.SendToServer()
		frame:Close()
	end

	--------------------------------------------------- Operative (TEST)
	local button_operative = vgui.Create("DButton", frame)
	button_operative:SetText("")
	button_operative:SetPos(445, 850)
	button_operative:SetSize(200, 100)
	button_operative.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, CMClr.button)
		draw.SimpleText("Operative (TEST)", hudfontsmall, 100, 50, CMClr.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	button_operative.DoClick = function()
		DebugPrint("Selected Operative class")
		if not ply:IsSuperAdmin() then
			BetterChatPrint("You are not admin.", CMClr.text)
			return
		end

		net.Start("alaln-setclass")
		net.WritePlayer(ply)
		net.WriteString("Operative")
		net.SendToServer()
		frame:Close()
	end
	--------------------------------------------------- Human (TEST)
	--[[local button_human = vgui.Create("DButton", frame)
	button_human:SetText("")
	button_human:SetPos(445, 100)
	button_human:SetSize(200, 100)
	button_human.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, CMClr.button)
		draw.SimpleText("Human (TEST)", hudfontsmall, 100, 50, CMClr.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	button_human.DoClick = function()
		DebugPrint("Selected Human class")
		if not ply:IsSuperAdmin() then
			BetterChatPrint("You are not admin.", CMClr.text)
			return
		end

		net.Start("alaln-setclass")
		net.WritePlayer(ply)
		net.WriteString("Human")
		net.SendToServer()
		frame:Close()
	end]]
end)