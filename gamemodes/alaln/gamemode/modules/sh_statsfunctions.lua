local plyMeta = FindMetaTable("Player")
function plyMeta:GetHunger()
	return self:GetNWFloat("alaln-hunger", 0)
end

function plyMeta:SetHunger(hunger)
	if not hunger then
		DebugPrint("Error! Calling SetHunger() without args")
		return
	end

	self:SetNWFloat("alaln-hunger", hunger)
end

-- use negative values to reduce
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

-- use negative values to reduce
function plyMeta:AddCrazyness(crazyness)
	if not crazyness then
		DebugPrint("Error! Calling AddCrazyness() without args")
		return
	end

	self:SetCrazyness(math.Clamp(self:GetCrazyness() + crazyness, 0, 100))
end

local color_yellow = Color(255, 235, 0)
net.Receive("alaln-setclass", function(len, ply)
	local netply = net.ReadPlayer()
	local class = net.ReadString()
	netply:SetNWString("alaln-class", class)
	BetterChatPrint(ply, "You changed your class, you need to respawn to apply it.", color_yellow)
end)