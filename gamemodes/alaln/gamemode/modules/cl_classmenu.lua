local CMClr = {
	ui = Color(20, 0, 0, 100),
	button = Color(20, 0, 0, 150),
	text = Color(150, 0, 0)
}

local hudfontsmall = "alaln-hudfontsmall"
-- class menu
--!! Надо будет переделать текст в классах чтобы под мониторы подходило разные
net.Receive("alaln-classmenu", function()
	--------------------------------------------------- Class Menu
	local frame = vgui.Create("DFrame")
	frame:SetSize(500, 700)
	frame:Center()
	frame:SetTitle("")
	frame:SetDraggable(false)
	frame:MakePopup()
	frame.Paint = function(self, w, h)
		draw.RoundedBox(5, 0, 0, w, h, CMClr.ui)
		draw.SimpleText("Select Class", hudfontsmall, 245, 30, CMClr.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	--------------------------------------------------- Model viewer
	--[[local model = vgui.Create("DModelPanel", frame)
	model:SetSize(300, 300)
	model:SetPos(-80, 100)
	model:SetModel("models/player/corpse1.mdl")

	function model:LayoutEntity(ent)
		ent:SetSequence(ent:LookupSequence("idle_all_angry"))
		ent:SetAngles(Angle(0, 60, 0))

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
		return LocalPlayer():GetPlayerColor()
	end]]
	--------------------------------------------------- Psychopath (Standard)
	local button1 = vgui.Create("DButton", frame)
	button1:SetText("")
	button1:SetPos(170, 100)
	button1:SetSize(150, 100)
	button1.Paint = function(self, w, h)
		draw.RoundedBox(5, 0, 0, w, h, CMClr.button)
		draw.SimpleText("Psychopath", hudfontsmall, 75, 50, CMClr.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local ply = LocalPlayer()
	button1.DoClick = function()
		DebugPrint("Selected Psychopath class")
		net.Start("alaln-setclass")
		net.WritePlayer(ply)
		net.WriteString("Psychopath")
		net.SendToServer()
		frame:Close()
	end

	--------------------------------------------------- Cannibal
	local button2 = vgui.Create("DButton", frame)
	button2:SetText("")
	button2:SetPos(170, 250)
	button2:SetSize(150, 100)
	button2.Paint = function(self, w, h)
		draw.RoundedBox(5, 0, 0, w, h, CMClr.button)
		draw.SimpleText("Cannibal (45)", hudfontsmall, 75, 50, CMClr.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	button2.DoClick = function()
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
	local button3 = vgui.Create("DButton", frame)
	button3:SetText("")
	button3:SetPos(145, 400)
	button3:SetSize(200, 100)
	button3.Paint = function(self, w, h)
		draw.RoundedBox(5, 0, 0, w, h, CMClr.button)
		draw.SimpleText("Berserker (75)", hudfontsmall, 100, 50, CMClr.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	button3.DoClick = function()
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
end)