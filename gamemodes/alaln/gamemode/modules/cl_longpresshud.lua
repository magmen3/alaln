--[[ take this stuff ]]
--
local EMPTY_KEY = Material("gui/key.png")
-- SRC: https://gist.github.com/theawesomecoder61/d2c3a3d42bbce809ca446a85b4dda754
function draw.Arc(cx, cy, radius, thickness, startang, endang, roughness, color)
	surface.SetDrawColor(color)
	surface.DrawArc(surface.PrecacheArc(cx, cy, radius, thickness, startang, endang, roughness))
end

function surface.PrecacheArc(cx, cy, radius, thickness, startang, endang, roughness)
	local triarc = {}
	-- local deg2rad = math.pi / 180
	-- Define step
	local roughness = math.max(roughness or 1, 1)
	local step = roughness
	-- Correct start/end ang
	local startang, endang = startang or 0, endang or 0
	if startang > endang then step = math.abs(step) * -1 end
	-- Create the inner circle's points.
	local inner = {}
	local r = radius - thickness
	for deg = startang, endang, step do
		local rad = math.rad(deg)
		-- local rad = deg2rad * deg
		local ox, oy = cx + (math.cos(rad) * r), cy + (-math.sin(rad) * r)
		table.insert(inner, {
			x = ox,
			y = oy,
			u = (ox - cx) / radius + .5,
			v = (oy - cy) / radius + .5,
		})
	end

	-- Create the outer circle's points.
	local outer = {}
	for deg = startang, endang, step do
		local rad = math.rad(deg)
		-- local rad = deg2rad * deg
		local ox, oy = cx + (math.cos(rad) * radius), cy + (-math.sin(rad) * radius)
		table.insert(outer, {
			x = ox,
			y = oy,
			u = (ox - cx) / radius + .5,
			v = (oy - cy) / radius + .5,
		})
	end

	-- Triangulize the points.
	for tri = 1, #inner * 2 do -- twice as many triangles as there are degrees.
		local p1, p2, p3
		p1 = outer[math.floor(tri / 2) + 1]
		p3 = inner[math.floor((tri + 1) / 2) + 1]
		if tri % 2 == 0 then --if the number is even use outer.
			p2 = outer[math.floor((tri + 1) / 2)]
		else
			p2 = inner[math.floor((tri + 1) / 2)]
		end

		table.insert(triarc, {p1, p2, p3})
	end
	-- Return a table of triangles to draw.
	return triarc
end

function surface.DrawArc(arc) --Draw a premade arc.
	for k, v in ipairs(arc) do
		surface.DrawPoly(v)
	end
end

hook.Add("HUDPaint", "DrawUsablePrompt", function()
	local useable = LocalPlayer():GetUseEntity()
	if useable.IsProgressUsable and useable:IsProgressUsable() then
		if useable:GetDrawProgress() and useable:GetUser() == LocalPlayer() and LocalPlayer():KeyDown(IN_USE) and CurTime() < useable:GetEndTime() then
			surface.SetDrawColor(255, 255, 255)
			draw.NoTexture()
			surface.DrawLine(ScrW() / 2, ScrH() / 2 - 32, ScrW() / 2, ScrH() / 2 - 23) -- without this, the top of the ring looks jittery and dumb.  why?  who knows
			draw.Arc(ScrW() / 2, ScrH() / 2, 32, 10, -(((1 - math.abs((useable:GetEndTime() - CurTime()) / useable.TimeToUse)) * 360) - 90), 90, 3, Color(255, 255, 255)) --thanks datae
		end

		if useable:GetDrawKeyPrompt() then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(EMPTY_KEY)
			surface.DrawTexturedRect(ScrW() / 2 - 16, ScrH() / 2 - 16, 32, 32)
			surface.SetFont("CloseCaption_Bold")
			surface.SetTextColor(0, 0, 0)
			surface.SetTextPos(ScrW() / 2 - 8, ScrH() / 2 - 14)
			surface.DrawText("E")
		end
	end
end)