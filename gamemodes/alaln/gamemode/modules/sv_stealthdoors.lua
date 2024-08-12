local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer_Create, math, util, net = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, timer, timer.Create, math, util, net
local entMeta = FindMetaTable("Entity")
local DoorClass = {"prop_door", "prop_door_rotating", "func_door", "func_door_rotating", "door", "func_breakable"}
function entMeta:IsDoor()
	local Class = self:GetClass()
	return DoorClass[Class] -- table.HasValue(DoorClass, Class)
end

function entMeta:StealthOpenDoor()
	if not self.stealthopen then
		self.stealthopen = true
		self.oldspeed = self:GetInternalVariable("Speed")
		self:SetSaveValue("Speed", self.oldspeed / 2)
		local uniqueIdent = self:EntIndex() and self:EntIndex() or tostring(self:GetPos())
		timer.Create("resetdoorstealthval" .. uniqueIdent, 4 * (self:GetInternalVariable("speed") / (self:GetClass() == "prop_door_rotating" and self:GetInternalVariable("distance") or self:GetInternalVariable("m_flMoveDistance"))), 1, function()
			if self:GetSaveTable().m_eDoorState ~= 1 and self:GetSaveTable().m_eDoorState ~= 3 then
				self:SetSaveValue("Speed", self.oldspeed)
				self.stealthopen = false
			else
				timer.Create("checkfordoorreset" .. uniqueIdent, 0.1, 0, function()
					if self:GetSaveTable().m_eDoorState ~= 1 and self:GetSaveTable().m_eDoorState ~= 3 then
						self:SetSaveValue("Speed", self.oldspeed)
						self.stealthopen = false
						timer.Remove("checkfordoorreset" .. uniqueIdent)
					end
				end)
			end
		end)
	end
end

hook_Add("AcceptInput", "alaln-stealthdoors", function(ent, inp, act, ply, val)
	if inp == "Use" and ent:IsDoor() and (ply:Crouching() or ply:KeyDown(IN_WALK)) then
		ent:StealthOpenDoor()
		if ent:GetInternalVariable("slavename") then
			for k, v in pairs(ents.FindByName(ent:GetInternalVariable("slavename"))) do
				v:StealthOpenDoor()
			end
		end

		-- it's safe to assume that a door's master will be the same class
		for k, v in pairs(ents.FindByClass(ent:GetClass())) do
			if ent == v:GetInternalVariable("m_hMaster") then v:StealthOpenDoor() end
		end

		if ent:GetInternalVariable("m_hMaster") and IsValid(ent:GetInternalVariable("m_hMaster")) and ent:GetInternalVariable("m_hMaster"):IsDoor() then ent:GetInternalVariable("m_hMaster"):StealthOpenDoor() end
	end
end)

hook_Add("EntityEmitSound", "alaln-stealthdoorssnd", function(data)
	if IsValid(data.Entity) and data.Entity:IsDoor() and data.Entity.stealthopen then
		data.Volume = data.Volume * 0.2
		return true
	end
end)