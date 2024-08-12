local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, net = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, net
local plyMeta = FindMetaTable("Player")
function plyMeta:GetAlalnState(type)
	if type == "hunger" then
		return self:GetNWFloat("alaln-hunger", 0)
	elseif type == "crazyness" then
		return self:GetNWFloat("alaln-crazyness", 0)
	elseif type == "class" then
		return self:GetNWString("alaln-class", "Psychopath")
	elseif type == "score" then
		return self:GetNWFloat("alaln-score", 0)
	elseif type == "stamina" then
		return self:GetNWFloat("alaln-stamina", 50)
	end
end

local color_yellow = Color(210, 210, 110)
function plyMeta:SetAlalnState(type, amt)
	if type == "hunger" then
		self:SetNWFloat("alaln-hunger", math.Clamp(amt, 0, 100))
	elseif type == "crazyness" then
		self:SetNWFloat("alaln-crazyness", math.Clamp(amt, 0, 100))
	elseif type == "class" then
		if CLIENT then
			net.Start("alaln-setclass")
			net.WritePlayer(ply)
			net.WriteString(amt or "Psychopath")
			net.SendToServer()
		else
			self:SetNWString("alaln-class", amt or "Psychopath")
			local score
			local text
			if amt == "Cannibal" and self:GetAlalnState("score") >= 45 then -- Stupid shit
				score = 45
				text = "You changed your class, you need to respawn to apply it."
			elseif amt == "Berserker" and self:GetAlalnState("score") >= 75 then
				score = 75
				text = "You changed your class, you need to respawn to apply it."
			elseif amt == "Psychopath" or class == "Faster" then
				score = 0
				text = "You changed your class, you need to respawn to apply it."
			elseif amt == "Gunslinger" and self:GetAlalnState("score") >= 95 then
				score = 95
				text = "You changed your class, you need to respawn to apply it."
			elseif amt == "Operative" then
				score = 0
				text = ""
			elseif amt == "Human" then
				score = 0
				text = ""
			else
				score = 0
				text = ""
			end

			if text and text ~= "" then BetterChatPrint(self, text, color_yellow) end
			self:AddAlalnState("score", -score)
			if amt ~= "Operative" and self:Alive() and SERVER then self:Kill() end
		end

		self:SetNWString("alaln-class", amt or "Psychopath")
	elseif type == "score" then
		self:SetNWFloat("alaln-score", math.Clamp(amt, 0, 6666))
	elseif type == "stamina" then
		self:SetNWFloat("alaln-stamina", math.Clamp(amt, 0, 50))
	end
end

function plyMeta:AddAlalnState(type, amt)
	if type == "hunger" then
		self:SetAlalnState("hunger", math.Clamp(self:GetAlalnState("hunger") + amt, 0, 100))
	elseif type == "crazyness" then
		self:SetAlalnState("crazyness", math.Clamp(self:GetAlalnState("crazyness") + amt, 0, 100))
	elseif type == "score" then
		self:SetAlalnState("score", math.Clamp(self:GetAlalnState("score") + amt, 0, 6666))
	elseif type == "stamina" then
		self:SetAlalnState("stamina", math.Clamp(self:GetAlalnState("stamina") + amt, 0, 50))
	end
end

net.Receive("alaln-setclass", function(len, ply)
	local netply = net.ReadPlayer()
	local class = net.ReadString()
	netply:SetNWString("alaln-class", class)
	local score --!! TODO: Переделать это в виде таблицы
	local text
	if class == "Cannibal" and ply:GetAlalnState("score") >= 45 then -- Stupid shit
		score = 45
		text = "You changed your class, you need to respawn to apply it."
	elseif class == "Berserker" and ply:GetAlalnState("score") >= 75 then
		score = 75
		text = "You changed your class, you need to respawn to apply it."
	elseif class == "Psychopath" or class == "Faster" then
		score = 0
		text = "You changed your class, you need to respawn to apply it."
	elseif class == "Gunslinger" and ply:GetAlalnState("score") >= 95 then
		score = 95
		text = "You changed your class, you need to respawn to apply it."
	elseif class == "Operative" then
		score = 0
		text = ""
	elseif class == "Human" then
		score = 0
		text = ""
	else
		score = 0
		text = ""
	end

	if text and text ~= "" then BetterChatPrint(ply, text, color_yellow) end
	netply:AddAlalnState("score", -score)
	if class ~= "Operative" and class ~= "Human" and netply:Alive() and SERVER then netply:Kill() end
end)
------------------------------------------------------------------- LEGACY: Need to remove
--[[function plyMeta:GetHunger()
	return self:GetNWFloat("alaln-hunger", 0)
end

function plyMeta:SetHunger(hunger)
	if not hunger then
		DebugPrint("Error! Calling SetHunger() without args")
		return
	end

	self:SetNWFloat("alaln-hunger", hunger)
end

-- Use negative values to reduce
function plyMeta:AddHunger(hunger)
	if not hunger then
		DebugPrint("Error! Calling AddHunger() without args")
		return
	end

	self:SetHunger(math.Clamp(self:GetHunger() + hunger, 0, 100))
end

function plyMeta:GetCrazyness()
	return self:GetNWFloat("alaln-crazyness", 0)
end

function plyMeta:SetCrazyness(crazyness)
	if not crazyness then
		DebugPrint("Error! Calling SetCrazyness() without args")
		return
	end

	self:SetNWFloat("alaln-crazyness", crazyness)
end

-- Use negative values to reduce
function plyMeta:AddCrazyness(crazyness)
	if not crazyness then
		DebugPrint("Error! Calling AddCrazyness() without args")
		return
	end

	self:SetCrazyness(math.Clamp(self:GetCrazyness() + crazyness, 0, 100))
end

function plyMeta:GetAlalnClass()
	return self:GetNWString("alaln-class", "Psychopath")
end]]
-- Score
--[[function plyMeta:GetAlalnScore()
	return self:GetNWFloat("alaln-score", 0)
end

function plyMeta:SetScore(score)
	if not score then
		DebugPrint("Error! Calling SetScore() without args")
		return
	end

	self:SetNWFloat("alaln-score", score)
end

-- Use negative values to reduce
function plyMeta:AddAlalnScore(score)
	if not score then
		DebugPrint("Error! Calling AddAlalnScore() without args")
		return
	end

	self:SetScore(math.Clamp(self:GetAlalnScore() + score, 0, 6666))
end

-- Movement stamina
function plyMeta:GetStamina()
	return self:GetNWFloat("alaln-stamina", 50)
end

function plyMeta:SetStamina(stamina)
	if not stamina then
		DebugPrint("Error! Calling SetStamina() without args")
		return
	end

	self:SetNWFloat("alaln-stamina", stamina)
end

-- Use negative values to reduce
function plyMeta:AddStamina(stamina)
	if not stamina then
		DebugPrint("Error! Calling AddAlalnStamina() without args")
		return
	end

	self:SetStamina(math.Clamp(self:GetStamina() + stamina, 1, 50))
end]]