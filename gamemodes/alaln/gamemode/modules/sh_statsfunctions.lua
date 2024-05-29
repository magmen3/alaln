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

function plyMeta:SetAlalnState(type, amt)
	if type == "hunger" then
		self:SetNWFloat("alaln-hunger", math.Clamp(amt, 0, 100))
	elseif type == "crazyness" then
		self:SetNWFloat("alaln-crazyness", math.Clamp(amt, 0, 100))
	elseif type == "class" then
		net.Start("alaln-setclass")
		net.WritePlayer(ply)
		net.WriteString(amt)
		net.SendToServer()
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
local color_yellow = Color(255, 235, 0)
net.Receive("alaln-setclass", function(len, ply)
	local netply = net.ReadPlayer()
	local class = net.ReadString()
	netply:SetNWString("alaln-class", class)
	local score --!! TODO: Переделать это в виде таблицы
	if class == "Cannibal" and ply:GetAlalnScore() >= 45 then -- Stupid shit
		score = 45
		BetterChatPrint(ply, "You changed your class, you need to respawn to apply it.", color_yellow)
	elseif class == "Berserker" and ply:GetAlalnScore() >= 75 then
		score = 75
		BetterChatPrint(ply, "You changed your class, you need to respawn to apply it.", color_yellow)
	elseif class == "Psychopath" then
		score = 0
		BetterChatPrint(ply, "You changed your class, you need to respawn to apply it.", color_yellow)
	else
		score = 0
	end

	netply:AddAlalnState("score", -score)
end)
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