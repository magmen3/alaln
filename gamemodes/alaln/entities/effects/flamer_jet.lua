local math, table, Color, Vector, Angle, IsValid = math, table, Color, Vector, Angle, IsValid
-- Main function
function EFFECT:Init(data)
	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	-- Keep the start and end pos - we're going to interpolate between them
	self.StartPos = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)
	self.EndPos = data:GetOrigin()
	self:SetRenderBoundsWS(self.StartPos, self.EndPos)
	if not IsValid(self.WeaponEnt) then return end
	if not IsValid(self.WeaponEnt:GetOwner()) then return end
	self.owner = self.WeaponEnt:GetOwner()
	-- Used in the think hook to avoid early dismissals
	self.startTime = CurTime()
end

local beamMat = Material("effects/combinemuzzle2_dark")
function EFFECT:Render()
	if not IsValid(self.owner) then return end
	local eyeAngs = self.owner:EyeAngles()
	local pos
	if GetViewEntity() == self.owner then
		pos = self.WeaponEnt:GetShootPosition()
	else
		pos = self.owner:GetShootPos()
	end

	local vel = eyeAngs:Forward() * math.Rand(2300, 2700)
	-- Draw a beam
	render.SetMaterial(beamMat)
	render.DrawBeam(pos, pos + vel * 0.035, math.Rand(6, 10), math.Rand(0, 1), 1, Color(255, 255, 255, 255))
	-- Draw following particles
	local pe = ParticleEmitter(pos, false)
	local p = pe:Add("effects/combinemuzzle2_dark", pos + vel * 0.003)
	p:SetDieTime(0.2)
	p:SetVelocity(vel)
	p:SetGravity(Vector(1750 * math.Rand(-1, 1), 1750 * math.Rand(-1, 1), 1750 * math.Rand(-1, 1)))
	p:SetAirResistance(math.Rand(600, 1000))
	p:SetStartAlpha(math.Rand(100, 200))
	p:SetEndAlpha(0)
	p:SetStartSize(math.Rand(3, 8))
	p:SetEndSize(math.Rand(8, 38))
	p:SetRoll(math.Rand(0, math.pi))
	p:SetRollDelta(math.Rand(-40, 40))
	pe:Finish()
	-- Draw a light
	local dLight = DynamicLight(self.WeaponEnt:EntIndex())
	if dLight then
		dLight.Pos = pos
		dLight.r = 255
		dLight.g = 100
		dLight.b = 80
		dLight.Brightness = 2
		dLight.Decay = 30000
		dLight.Size = 250
		dLight.DieTime = CurTime() + 0.2
	end
end

-- Kill effect
function EFFECT:Think()
	if IsValid(self.owner) then
		self:SetRenderOrigin(self.owner:GetPos())
		local mins, maxs = self.owner:GetRenderBounds()
		self:SetRenderBounds(mins, maxs, Vector(500, 500, 500))
	end

	if not IsValid(self.WeaponEnt) then return false end
	if CurTime() < self.startTime + 0.1 then return true end
	return self.WeaponEnt:GetShooting()
end