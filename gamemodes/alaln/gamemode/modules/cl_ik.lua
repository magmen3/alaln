-- Taken from IK Foot addon by Fraddy15, edited by Mannytko
local render, Material, hook, hook_Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, color_white, vector_origin, angle_zero, vector_up, GetConVar = render, Material, hook, hook.Add, LocalPlayer, ScrW, ScrH, table, draw, surface, Color, Vector, Color(255, 255, 255, 255), Vector(0, 0, 0), Angle(0, 0, 0), Vector(0, 0, 1), GetConVar
local function CanManipulateBones(ply)
	if ply:InVehicle() or not ply:Alive() then return false end
	if istable(ActionGmod) and ply:IsDive() then return false end
	if istable(prone) and ply:IsProne() then return false end
	return true
end

--local ikDebug = GetConVar("developer")
--local COLOR_RED = Color(255, 0, 0)
local mins = Vector(-3, -3, 0)
local maxs = Vector(3, 3, 5)
hook.Add("PostPlayerDraw", "IKFoot_PostPlayerDraw", function(ply)
	if IsValid(ply) then
		local ikFoot = not PotatoMode:GetBool()
		local lFoot = ply:LookupBone("ValveBiped.Bip01_L_Foot")
		local rFoot = ply:LookupBone("ValveBiped.Bip01_R_Foot")
		local lCalf = ply:LookupBone("ValveBiped.Bip01_L_Calf")
		local rCalf = ply:LookupBone("ValveBiped.Bip01_R_Calf")
		local lThigh = ply:LookupBone("ValveBiped.Bip01_L_Thigh")
		local rThigh = ply:LookupBone("ValveBiped.Bip01_R_Thigh")
		if lFoot and rFoot and lCalf and rCalf and lThigh and rThigh then
			local basePos = Vector()
			local lerpTime = math.Clamp(FrameTime() * 20, 0, 1)
			local result = {
				basePos = basePos,
				baseAng = Angle(),
				lCalf = Angle(),
				rCalf = Angle(),
				lThigh = Angle(),
				rThigh = Angle(),
				lFoot = Angle(),
				rFoot = Angle(),
			}

			if not ply.IKResult then ply.IKResult = result end
			if not ply.IKResetManipulationBones then ply.IKResetManipulationBones = false end
			if ikFoot then
				local groundDist = 42
				local groundZDist = vector_up * groundDist
				local lFootPos, lFootAng = ply:GetBonePosition(lFoot)
				local rFootPos, rFootAng = ply:GetBonePosition(rFoot)
				if lFootPos and rFootPos and lFootAng and rFootAng then
					local lFootForward = lFootAng:Forward()
					lFootForward.z = 0
					lFootForward:Normalize()
					local rFootForward = rFootAng:Forward()
					rFootForward.z = 0
					rFootForward:Normalize()
					local lToePos = lFootPos + lFootForward * 8
					local rToePos = rFootPos + rFootForward * 8
					local lLegStart = Vector(lFootPos.x, lFootPos.y, ply:GetPos().z + 30)
					local rLegStart = Vector(rFootPos.x, rFootPos.y, ply:GetPos().z + 30)
					local lToeStart = Vector(lToePos.x, lToePos.y, ply:GetPos().z + 30)
					local rToeStart = Vector(rToePos.x, rToePos.y, ply:GetPos().z + 30)
					local lLegTrace = util.TraceHull({
						start = lLegStart,
						endpos = lLegStart - groundZDist,
						mins = mins,
						maxs = maxs,
						filter = ply
					})

					local rLegTrace = util.TraceHull({
						start = rLegStart,
						endpos = rLegStart - groundZDist,
						mins = mins,
						maxs = maxs,
						filter = ply
					})

					local lTraceToe = util.TraceHull({
						start = lToeStart,
						endpos = lToeStart - groundZDist,
						mins = mins,
						maxs = maxs,
						filter = ply
					})

					local rTraceToe = util.TraceHull({
						start = rToeStart,
						endpos = rToeStart - groundZDist,
						mins = mins,
						maxs = maxs,
						filter = ply
					})

					local lDist = 30
					local rDist = 30
					if ply:OnGround() then
						lDist = lLegTrace.Fraction * groundDist
						rDist = rLegTrace.Fraction * groundDist
					end

					local lFootDir = lTraceToe.HitPos - lLegTrace.HitPos
					local rFootDir = rTraceToe.HitPos - rLegTrace.HitPos
					if lLegTrace.Hit or rLegTrace.Hit then
						local maxDistance = math.max(math.max(rDist, lDist) - 30, 0)
						result.basePos = basePos + Vector(0, 0, -maxDistance)
						local rAlpha = -math.deg(math.asin(math.Clamp((rDist - maxDistance - 30) / 17, -1, 1)))
						result.rCalf = Angle(0, rAlpha, 0)
						result.rThigh = Angle(0, -rAlpha, 0)
						local lAlpha = -math.deg(math.asin(math.Clamp((lDist - maxDistance - 30) / 17, -1, 1)))
						result.lCalf = Angle(0, lAlpha, 0)
						result.lThigh = Angle(0, -lAlpha, 0)
						result.lFoot = Angle(0, lFootDir:Angle().p, 0)
						result.rFoot = Angle(0, rFootDir:Angle().p, 0)
					end

					local plyVel = ply:GetVelocity()
					local plyAng = ply:GetAimVector():Angle()
					local leanY = math.Clamp(plyVel:Dot(plyAng:Right()) / 20, -4, 4)
					result.baseAng = Angle(0, leanY, 0)
					ply.IKResult.basePos = LerpVector(lerpTime, ply.IKResult.basePos, result.basePos)
					ply.IKResult.baseAng = LerpAngle(lerpTime, ply.IKResult.baseAng, result.baseAng)
					ply.IKResult.rCalf = LerpAngle(lerpTime, ply.IKResult.rCalf, result.rCalf)
					ply.IKResult.lCalf = LerpAngle(lerpTime, ply.IKResult.lCalf, result.lCalf)
					ply.IKResult.rThigh = LerpAngle(lerpTime, ply.IKResult.rThigh, result.rThigh)
					ply.IKResult.lThigh = LerpAngle(lerpTime, ply.IKResult.lThigh, result.lThigh)
					ply.IKResult.lFoot = LerpAngle(lerpTime, ply.IKResult.lFoot, result.lFoot)
					ply.IKResult.rFoot = LerpAngle(lerpTime, ply.IKResult.rFoot, result.rFoot)
					--[[if ikDebug:GetInt() > 0 and CanManipulateBones(ply) then
						if lLegTrace.Hit then
							render.DrawWireframeBox(lLegTrace.HitPos, lFootDir:Angle(), mins, maxs, COLOR_RED, true)
							render.DrawLine(lLegStart, lLegTrace.HitPos, COLOR_RED)
						else
							render.DrawWireframeBox(lLegTrace.HitPos, Angle(), mins, maxs, color_white, true)
							render.DrawLine(lLegStart, lLegTrace.HitPos, color_white)
						end

						if rLegTrace.Hit then
							render.DrawWireframeBox(rLegTrace.HitPos, rFootDir:Angle(), mins, maxs, COLOR_RED, true)
							render.DrawLine(rLegStart, rLegTrace.HitPos, COLOR_RED)
						else
							render.DrawWireframeBox(rLegTrace.HitPos, Angle(), mins, maxs, color_white, true)
							render.DrawLine(rLegStart, rLegTrace.HitPos, color_white)
						end
					end]]
				end
			end

			--[[if ikDebug:GetInt() > 1 then
				local bottom, top = Vector()
				if ply:Crouching() then
					bottom, top = ply:GetHullDuck()
				else
					bottom, top = ply:GetHull()
				end

				render.DrawWireframeBox(ply:GetPos(), Angle(), bottom, top, color_white, true)
			end]]
			if ikFoot and CanManipulateBones(ply) then
				ply:ManipulateBonePosition(0, ply.IKResult.basePos)
				ply:ManipulateBoneAngles(0, ply.IKResult.baseAng)
				ply:ManipulateBoneAngles(lCalf, ply.IKResult.lCalf)
				ply:ManipulateBoneAngles(rCalf, ply.IKResult.rCalf)
				ply:ManipulateBoneAngles(lThigh, ply.IKResult.lThigh)
				ply:ManipulateBoneAngles(rThigh, ply.IKResult.rThigh)
				ply:ManipulateBoneAngles(lFoot, ply.IKResult.lFoot)
				ply:ManipulateBoneAngles(rFoot, ply.IKResult.rFoot)
				ply.IKResetManipulationBones = false
			elseif not ply.IKResetManipulationBones then
				ply:ManipulateBonePosition(0, vector_origin)
				ply:ManipulateBoneAngles(0, angle_zero)
				ply:ManipulateBoneAngles(lCalf, angle_zero)
				ply:ManipulateBoneAngles(rCalf, angle_zero)
				ply:ManipulateBoneAngles(lThigh, angle_zero)
				ply:ManipulateBoneAngles(rThigh, angle_zero)
				ply:ManipulateBoneAngles(lFoot, angle_zero)
				ply:ManipulateBoneAngles(rFoot, angle_zero)
				ply.IKResetManipulationBones = true
			end
		end
	end
end)