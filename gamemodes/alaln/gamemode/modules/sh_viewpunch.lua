-- я только щас заметил что эта херня использует SetEyeAngles и из за этого во время вьюпанча может нерегать :steamdeadpan:
if SERVER then
	util.AddNetworkString("alaln-viewpunch")
	local plyMeta = FindMetaTable("Player")
	function plyMeta:BetterViewPunch(angle)
		if not (self or angle) then
			DebugPrint("Error! Calling BetterViewPunch() without args")
			return
		end

		net.Start("alaln-viewpunch")
		net.WriteAngle(angle)
		net.Send(self)
	end
end

if CLIENT then
	local PUNCH_DAMPING = 9
	local PUNCH_SPRING_CONSTANT = 65
	local vp_punch_angle = Angle()
	local vp_punch_angle_velocity = Angle()
	local vp_punch_angle_last = vp_punch_angle
	hook.Add("Think", "alaln-viewpunchdecay", function()
		local ft = FrameTime()
		if not vp_punch_angle:IsZero() or not vp_punch_angle_velocity:IsZero() then
			vp_punch_angle = vp_punch_angle + vp_punch_angle_velocity * ft
			local damping = 1 - (PUNCH_DAMPING * ft)
			if damping < 0 then damping = 0 end
			vp_punch_angle_velocity = vp_punch_angle_velocity * damping
			local spring_force_magnitude = math.Clamp(PUNCH_SPRING_CONSTANT * ft, 0, 0.2 / ft)
			vp_punch_angle_velocity = vp_punch_angle_velocity - vp_punch_angle * spring_force_magnitude
			local x, y, z = vp_punch_angle:Unpack()
			vp_punch_angle = Angle(math.Clamp(x, -75, 75), math.Clamp(y, -140, 140), math.Clamp(z, -75, 75))
		else
			vp_punch_angle = Angle()
			vp_punch_angle_velocity = Angle()
		end
	end)

	hook.Add("Think", "alaln-viewpunchapply", function()
		if vp_punch_angle:IsZero() and vp_punch_angle_velocity:IsZero() then return end
		if LocalPlayer():InVehicle() then return end
		LocalPlayer():SetEyeAngles(LocalPlayer():EyeAngles() + vp_punch_angle - vp_punch_angle_last)
		vp_punch_angle_last = vp_punch_angle
	end)

	local function SetViewPunchAngles(angle)
		if not angle then return end
		vp_punch_angle = angle
	end

	local function SetViewPunchVelocity(angle)
		if not angle then return end
		vp_punch_angle_velocity = angle * 20
	end

	local function Viewpunch(angle)
		if not angle then return end
		if ThirdPerson:GetBool() then return end
		vp_punch_angle_velocity = vp_punch_angle_velocity + angle * 10
	end

	local plyMeta = FindMetaTable("Player")
	function plyMeta:BetterViewPunch(angle)
		Viewpunch(angle)
	end

	net.Receive("alaln-viewpunch", function()
		local angle = net.ReadAngle()
		Viewpunch(angle)
	end)
end