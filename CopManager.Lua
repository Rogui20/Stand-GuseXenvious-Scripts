util.require_natives(1676318796)

Wait = util.yield
joaat = util.joaat
Print = util.toast
json = require "json"

local ArmoredVehsT = {}
local ArmoredVehicle = false

local RelationshipChanged = true

function LoadJSONFile(Path)
    local MyTable = {}
    local File = io.open( Path, "r" )

    if File then
        -- read all contents of file into a string
        local Contents = File:read( "*a" )
        MyTable = json.decode(Contents)
        io.close( File )
        return MyTable
    end
    return nil
end
local CopsAimAtHead = true
local CopsSwitchToNearestTarget = true

local TaskStatusFunctionsT = {}

TaskStatusFunctionsT[0+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 0 then
		local OffsetToGive = TaskArgs.OperationOffset
		if TaskArgs.OperationSide == 0 then
			OffsetToGive = -TaskArgs.OperationOffset
		end
		if TaskArgs.OperationSide == 1 then
			OffsetToGive = TaskArgs.OperationOffset
		end
		OperationT[peds].X = OperationT[peds].Vect.x + ((OperationT[peds].RVect.x * OffsetToGive) - (OperationT[peds].FVect.x * (TaskArgs.OperationStatus+1)))
		OperationT[peds].Y = OperationT[peds].Vect.y + ((OperationT[peds].RVect.y * OffsetToGive) - (OperationT[peds].FVect.y * (TaskArgs.OperationStatus+1)))
		OperationT[peds].Z = OperationT[peds].Vect.z + ((OperationT[peds].RVect.z * OffsetToGive) - (OperationT[peds].FVect.z * (TaskArgs.OperationStatus+1)))
		OperationT[peds].YOffset = TaskArgs.OperationStatus
		TaskArgs.OperationStatus = TaskArgs.OperationStatus + 1
		if TaskArgs.OperationStatus > 1 then
			TaskArgs.OperationStatus = 0
			TaskArgs.OperationSide = TaskArgs.OperationSide + 1
			if TaskArgs.OperationSide > 1 then
				TaskArgs.OperationSide = 0
				TaskArgs.OperationOffset = TaskArgs.OperationOffset + 1.0
			end
		end
		if RequestControlOfEntity(peds) then
			PED.SET_PED_COMBAT_MOVEMENT(peds, 0)
			TASK.TASK_GO_TO_COORD_ANY_MEANS(peds, OperationT[peds].X, OperationT[peds].Y, OperationT[peds].Z, 3.5, 0, false, 0, -1.0)
			OperationT[peds].TaskStatus = 1
			if OperationT[peds].YOffset == 1 then
				PED.SET_PED_MAX_MOVE_BLEND_RATIO(peds, 1.0)
				PED.RESET_PED_MOVEMENT_CLIPSET(peds, 0.55)
				PED.RESET_PED_STRAFE_CLIPSET(peds)
			else
				PED.SET_PED_USING_ACTION_MODE(peds, false, -1, "DEFAULT_ACTION")
				PED.SET_PED_MOVEMENT_CLIPSET(peds, "move_ped_crouched", 0.55)
				PED.SET_PED_STRAFE_CLIPSET(peds, "move_ped_crouched_strafing")
			end
		end
	end
end
TaskStatusFunctionsT[1+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 1 then
		if ENTITY.IS_ENTITY_AT_COORD(peds, OperationT[peds].X, OperationT[peds].Y, OperationT[peds].Z, 10.0, 10.0, 100.0, false, true, 0) then
			if RequestControlOfEntity(peds) then
				TASK.TASK_ACHIEVE_HEADING(peds, TaskArgs.OperationHeading, 10000)
				OperationT[peds].TaskStatus = 2
			end
		end
	end
end
TaskStatusFunctionsT[2+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 2 then
		if not PED.IS_PED_RAGDOLL(peds) then
			if RequestControlOfEntity(peds) then
				if ENTITY.IS_ENTITY_AT_COORD(peds, OperationT[peds].X, OperationT[peds].Y, OperationT[peds].Z, 20.0, 20.0, 100.0, false, true, 0) then
					local PedPos = ENTITY.GET_ENTITY_COORDS(peds)
					local AdjustedX = (OperationT[peds].X - PedPos.x) * 2.0
					local AdjustedY = (OperationT[peds].Y - PedPos.y) * 2.0
					local AdjustedZ = (OperationT[peds].Z - PedPos.z) * 2.0
					local ActualVelocity = ENTITY.GET_ENTITY_VELOCITY(peds)
					ENTITY.SET_ENTITY_VELOCITY(peds, AdjustedX, AdjustedY, ActualVelocity.z)
					if ENTITY.IS_ENTITY_AT_COORD(peds, OperationT[peds].X, OperationT[peds].Y, OperationT[peds].Z, 0.2, 0.2, 100.0, false, true, 0) then
						ENTITY.SET_ENTITY_VELOCITY(peds, 0.0, 0.0, 0.0)
						OperationT[peds].TaskStatus = 3
					end
				else
					ENTITY.SET_ENTITY_COORDS(peds, OperationT[peds].X, OperationT[peds].Y, OperationT[peds].Z)
				end
			end
		end
	end
end
TaskStatusFunctionsT[3+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 3 then
		if OperationT[peds].YOffset == 0 then
			if RequestControlOfEntity(peds) then
				PED.SET_PED_USING_ACTION_MODE(peds, false, -1, "DEFAULT_ACTION")
				PED.SET_PED_MOVEMENT_CLIPSET(peds, "move_ped_crouched", 0.55)
				PED.SET_PED_STRAFE_CLIPSET(peds, "move_ped_crouched_strafing")
			end
		end
		if TaskArgs.ShootsT[peds] == nil then
			if RequestControlOfEntity(peds) then
				if TaskArgs.HitCoords ~= nil then
					--if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_AIM_GUN_AT_COORD")) == 7 then
						TASK.TASK_AIM_GUN_AT_COORD(peds, TaskArgs.HitCoords.x, TaskArgs.HitCoords.y, TaskArgs.HitCoords.z, 10000, false, false)
					--end
				end
			end
		end
	end
end
TaskStatusFunctionsT[4+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 4 then
		if not ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 30.0, 30.0, 30.0, false, true, false) then
			if OperationT[peds].IsPilot then
				if RequestControlOfEntity(peds) then
					--TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(peds, PlayerPed, math.random(-10, 10), math.random(-10, 10), math.random(-10, 10), 100.0, -1, 5.0, true)
					TASK.TASK_VEHICLE_MISSION_PED_TARGET(peds, OperationT[peds].VehHandle, PlayerPed, 4, 100.0, 0, 20.0, 10.0, true)
					OperationT[peds].TaskStatus = 5
				end
			else
				OperationT[peds].TaskStatus = 5
			end
		else
			OperationT[peds].TaskStatus = 5
		end
	end
end
TaskStatusFunctionsT[5+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 5 then
		if ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 30.0, 30.0, 30.0, false, true, false) then
			OperationT[peds].TaskStatus = 0
		end
	end
end
TaskStatusFunctionsT[6+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 6 then
		if ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 50.0, 50.0, 230.0, false, true, false) then
			OperationT[peds].TaskStatus = 7
		end
	end
end
TaskStatusFunctionsT[7+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 7 then
		if ENTITY.DOES_ENTITY_EXIST(OperationT[peds].VehHandle) then
			if PED.IS_PED_IN_ANY_VEHICLE(peds, false) then
				if VEHICLE.IS_ANY_PED_RAPPELLING_FROM_HELI(OperationT[peds].VehHandle) then
					TASK.CLEAR_PED_TASKS(peds)
					OperationT[peds].TaskStatus = 8
				end
			else
				OperationT[peds].TaskStatus = 0
			end
		else
			OperationT[peds].TaskStatus = 0
		end
	end
end
TaskStatusFunctionsT[8+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 8 then
		if ENTITY.DOES_ENTITY_EXIST(OperationT[peds].VehHandle) then
			if PED.IS_PED_IN_ANY_VEHICLE(peds, false) then
				if not VEHICLE.IS_ANY_PED_RAPPELLING_FROM_HELI(OperationT[peds].VehHandle) then
					TASK.CLEAR_PED_TASKS(peds)
					OperationT[peds].TaskStatus = 9
				end
			else
				OperationT[peds].TaskStatus = 0
			end
		else
			OperationT[peds].TaskStatus = 0
		end
	end
end
TaskStatusFunctionsT[10+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 10 then
		if RequestControlOfEntity(peds) then
			TASK.TASK_RAPPEL_FROM_HELI(peds, 10.0)
			if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_RAPPEL_FROM_HELI")) ~= 7 then
				OperationT[peds].TaskStatus = 11
			end
		end
	end
end
TaskStatusFunctionsT[11+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 11 then
		if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_RAPPEL_FROM_HELI")) == 7 then
			OperationT[peds].TaskStatus = 0
		end
	end
end
TaskStatusFunctionsT[12+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 12 then
		if OperationT[peds].Bits == nil then
			OperationT[peds].Bits = 0
		end
		if OperationT[peds].TargetTimer == nil then
			OperationT[peds].TargetTimer = 0
		end
		if OperationT[peds].Target == nil then
			OperationT[peds].Target = 0
		end
		if OperationT[peds].TargetTimer <= 0 then
			OperationT[peds].TargetTimer = 100
			local NewTarget = GetAllPedNearestTarget(peds, false, true, false, false, {1})
			--GetPedNearestTarget(peds)
			if NewTarget ~= 0 then
				if NewTarget ~= OperationT[peds].Target then
					OperationT[peds].Target = NewTarget
					OperationT[peds].Bits = 0
				end
			end
		else
			OperationT[peds].TargetTimer = OperationT[peds].TargetTimer - 1
		end
		if OperationT[peds].Target ~= 0 then
			if ENTITY.DOES_ENTITY_EXIST(OperationT[peds].Target) and not ENTITY.IS_ENTITY_DEAD(OperationT[peds].Target) then
				local HasClearLos = ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, OperationT[peds].Target, 17)
				local VehHandle = PED.GET_VEHICLE_PED_IS_IN(peds, true)
				if VehHandle ~= 0 and PED.IS_PED_IN_VEHICLE(peds, VehHandle) then
					local Ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(VehHandle, -1, false)
					if Ped == peds then
						if not is_bit_set(OperationT[peds].Bits, 1) then
							if HasClearLos then
								OperationT[peds].Bits = set_bit(OperationT[peds].Bits, 1)
								TASK.TASK_VEHICLE_SHOOT_AT_PED(peds, OperationT[peds].Target, 20.0)
								TASK.TASK_VEHICLE_CHASE(peds, OperationT[peds].Target)
								if is_bit_set(OperationT[peds].Bits, 2) then
									OperationT[peds].Bits = clear_bit(OperationT[peds].Bits, 2)
								end
							end
						else
							if PED.IS_PED_SHOOTING(peds) then
								OperationT[peds].Bits = clear_bit(OperationT[peds].Bits, 1)
							end
						end
						if not is_bit_set(OperationT[peds].Bits, 2) then
							if not HasClearLos then
								OperationT[peds].Bits = set_bit(OperationT[peds].Bits, 2)
								TASK.TASK_VEHICLE_CHASE(peds, OperationT[peds].Target)
							end
						end
					else
						if not is_bit_set(OperationT[peds].Bits, 1) then
							if HasClearLos then
								OperationT[peds].Bits = set_bit(OperationT[peds].Bits, 1)
								TASK.TASK_VEHICLE_SHOOT_AT_PED(peds, OperationT[peds].Target, 20.0)
								if is_bit_set(OperationT[peds].Bits, 2) then
									OperationT[peds].Bits = clear_bit(OperationT[peds].Bits, 2)
								end
							end
						else
							if PED.IS_PED_SHOOTING(peds) then
								OperationT[peds].Bits = clear_bit(OperationT[peds].Bits, 1)
							end
						end
					end
				else
					if not is_bit_set(OperationT[peds].Bits, 3) then
						if HasClearLos then
							OperationT[peds].Bits = set_bit(OperationT[peds].Bits, 3)
							TASK.TASK_GO_TO_ENTITY_WHILE_AIMING_AT_ENTITY(peds, OperationT[peds].Target, OperationT[peds].Target, 3.0, true, 0.15, 1.0, true, true, joaat("FIRING_PATTERN_FULL_AUTO"))
							PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, true)
							if is_bit_set(OperationT[peds].Bits, 4) then
								OperationT[peds].Bits = clear_bit(OperationT[peds].Bits, 4)
							end
						end
					end
					if not is_bit_set(OperationT[peds].Bits, 4) then
						if not HasClearLos then
							OperationT[peds].Bits = set_bit(OperationT[peds].Bits, 4)
							TASK.TASK_GO_TO_ENTITY(peds, OperationT[peds].Target, 30000, 10.0, 3.0, 100.0, 0)
							PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, true)
						end
					end
				end
			else
				if OperationT[peds].Bits ~= 0 then
					OperationT[peds].Bits = 0
					OperationT[peds].Target = 0
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
					TASK.CLEAR_PED_TASKS(peds)
				end
			end
		else
			OperationT[peds].Bits = 0
		end
	end
end
TaskStatusFunctionsT[13+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 13 then
		local Target = PED.GET_PED_TARGET_FROM_COMBAT_PED(peds, 0)
		if Target ~= 0 then
			OperationT[peds].Target = Target
			if RequestControlOfEntity(peds) then
				local TargetCoords = ENTITY.GET_ENTITY_COORDS(Target)
				local VehHandle = OperationT[peds].VehHandle
				if VehHandle ~= 0 then
					if OperationT[peds].IsPilot then
						TASK.TASK_VEHICLE_DRIVE_TO_COORD(peds, VehHandle, TargetCoords.x, TargetCoords.y, TargetCoords.z, 100.0, 1, ENTITY.GET_ENTITY_MODEL(VehHandle), 1, 20.0, 4.0)
					end
				else
					TASK.TASK_GO_TO_ENTITY(peds, Target, 30000, 10.0, 3.0, 100.0, 0)
				end
				PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, true)
				OperationT[peds].TaskStatus = 14
			end
		else
			if OperationT[peds].TargetAttempts == nil then
				OperationT[peds].TargetAttempts = 0
			end
			OperationT[peds].TargetAttempts = OperationT[peds].TargetAttempts + 1
			if OperationT[peds].TargetAttempts > 3 then
				OperationT[peds].TaskStatus = 12
				OperationT[peds].TargetAttempts = 0
			end
		end
	end
end
TaskStatusFunctionsT[14+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 14 then
		if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, OperationT[peds].Target, 17) then
			if RequestControlOfEntity(peds) then
				TASK.TASK_COMBAT_PED(peds, OperationT[peds].Target, 0, 16)
				OperationT[peds].TaskStatus = 12
			end
		end
	end
end
TaskStatusFunctionsT[15+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 15 then
		local CanCall = true
		local VehHandle = OperationT[peds].VehHandle
		if VehHandle ~= 0 then
			local VehClass = VEHICLE.GET_VEHICLE_CLASS(VehHandle)
			if VehClass == 15 or VehHandle == 16 then
				CanCall = false
			end
		end
		if CanCall then
			OperationT[peds].TaskStatus = 16
		else
			OperationT[peds].TaskStatus = 100
		end
	end
end
TaskStatusFunctionsT[16+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 16 then
		if ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 30.0, 30.0, 30.0, false, true, false) then
			if PlayerVeh ~= 0 then
				if PED.IS_PED_IN_VEHICLE(PlayerPed, PlayerVeh, true) then
					if TaskArgs.SeatsFilled < 9 then
						if RequestControlOfEntity(peds) then
							if VEHICLE.IS_VEHICLE_SEAT_FREE(PlayerVeh, TaskArgs.SeatsFilled, true) then
								TASK.TASK_ENTER_VEHICLE(peds, PlayerVeh, 10000, TaskArgs.SeatsFilled, 2.0, 1, 0)
								PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, true)
								--PED.SET_PED_CONFIG_FLAG(peds, 402, true)
								--PED.SET_PED_COMBAT_ATTRIBUTES(peds, 3, false)
								--PED.SET_PED_FLEE_ATTRIBUTES(peds, 2048, false)
								OperationT[peds].TaskStatus = 17
							end
							TaskArgs.SeatsFilled = TaskArgs.SeatsFilled + 1
						end
					else
						OperationT[peds].TaskStatus = 100
					end
				else
					OperationT[peds].TaskStatus = 100
				end
			else
				OperationT[peds].TaskStatus = 100
			end
		end
	end
end
TaskStatusFunctionsT[17+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 17 then
		if PlayerVeh ~= 0 then
			if PED.IS_PED_IN_VEHICLE(peds, PlayerVeh, true) then
				if RequestControlOfEntity(peds) then
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, true)
					OperationT[peds].TaskStatus = 100
				end
			end
		end
	end
end
TaskStatusFunctionsT[18+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 18 then
		if PlayerVeh ~= 0 then
			if PED.IS_PED_IN_VEHICLE(peds, PlayerVeh, true) then
				if RequestControlOfEntity(peds) then
					TASK.TASK_LEAVE_VEHICLE(peds, PlayerVeh, 0)
					OperationT[peds].TaskStatus = 100
				end
			else
				OperationT[peds].TaskStatus = 100
			end
		else
			OperationT[peds].TaskStatus = 100
		end
	end
end
TaskStatusFunctionsT[19+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 19 then
		if TaskArgs.PedsToPointedArea[peds] == nil and ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 100.0, 100.0, 100.0, false, true, false) then
			if TaskArgs.PointedAreaSet < TaskArgs.MissionCopCount / 2 then
				if TaskArgs.HasHit then
					if TaskArgs.HitCoords ~= nil then
						local VehHandle = OperationT[peds].VehHandle
						if VehHandle ~= 0 then
							if OperationT[peds].IsPilot then
								local VehClass = VEHICLE.GET_VEHICLE_CLASS(VehHandle)
								if VehClass ~= 15 and VehHandle ~= 16 then
									if RequestControlOfEntity(peds) then
										TASK.TASK_VEHICLE_DRIVE_TO_COORD(peds, VehHandle, TaskArgs.HitCoords.x, TaskArgs.HitCoords.y, TaskArgs.HitCoords.z, 100.0, 1, ENTITY.GET_ENTITY_MODEL(VehHandle), 1, 10.0, 4.0)
										PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, true)
										TaskArgs.PedsToPointedArea[peds] = 0
										OperationT[peds].TaskStatus = 20
										OperationT[peds].HitPos = {x = TaskArgs.HitCoords.x, y = TaskArgs.HitCoords.y, z = TaskArgs.HitCoords.z}
										TaskArgs.PointedAreaSet = TaskArgs.PointedAreaSet + 1
										TaskArgs.PointedPeds = TaskArgs.PointedPeds + 1
									end
								end
							else
								OperationT[peds].TaskStatus = 100
							end
						else
							if RequestControlOfEntity(peds) then
								TASK.TASK_GO_TO_COORD_ANY_MEANS(peds, TaskArgs.HitCoords.x, TaskArgs.HitCoords.y, TaskArgs.HitCoords.z, 3.5, 0, false, 0, -1.0)
								PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, true)
								TaskArgs.PedsToPointedArea[peds] = 0
								OperationT[peds].TaskStatus = 20
								OperationT[peds].HitPos = {x = TaskArgs.HitCoords.x, y = TaskArgs.HitCoords.y, z = TaskArgs.HitCoords.z}
								TaskArgs.PointedAreaSet = TaskArgs.PointedAreaSet + 1
								TaskArgs.PointedPeds = TaskArgs.PointedPeds + 1
							end
						end
					else
						OperationT[peds].TaskStatus = 100
					end
				else
					OperationT[peds].TaskStatus = 100
				end
			else
				OperationT[peds].TaskStatus = 100
			end
		else
			OperationT[peds].TaskStatus = 100
			if TaskArgs.PedsToPointedArea[peds] ~= nil then
				TaskArgs.PedsToPointedArea[peds] = nil
			end
		end
	end
end
TaskStatusFunctionsT[20+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 20 then
		if ENTITY.IS_ENTITY_AT_COORD(peds, OperationT[peds].HitPos.x, OperationT[peds].HitPos.y, OperationT[peds].HitPos.z, 10.0, 10.0, 10.0, false, true, 0) then
			if RequestControlOfEntity(peds) then
				PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
				TASK.CLEAR_PED_TASKS(peds)
				OperationT[peds].TaskStatus = 101
			end
		end
	end
end
TaskStatusFunctionsT[21+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 21 then
		if ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 30.0, 30.0, 30.0, false, true, false) then
			local VehHandle = OperationT[peds].VehHandle
			if VehHandle ~= 0 then
				local VehClass = VEHICLE.GET_VEHICLE_CLASS(VehHandle)
				if VehClass ~= 15 and VehHandle ~= 16 then
					if RequestControlOfEntity(peds) then
						TASK.TASK_LEAVE_VEHICLE(peds, VehHandle, 0)
						OperationT[peds].TaskStatus = 100
					end
				else
					OperationT[peds].TaskStatus = 100	
				end
			else
				OperationT[peds].TaskStatus = 100
			end
		else
			OperationT[peds].TaskStatus = 100
		end
	end
end
TaskStatusFunctionsT[22+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 22 then
		if ENTITY.IS_ENTITY_AT_COORD(peds, OperationT[peds].HitPos.x, OperationT[peds].HitPos.y, OperationT[peds].HitPos.z, 10.0, 10.0, 10.0, false, true, 0) then
			if RequestControlOfEntity(peds) then
				PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
				TASK.CLEAR_PED_TASKS(peds)
				OperationT[peds].TaskStatus = 100
			end
		end
	end
end
TaskStatusFunctionsT[23+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 23 then
		if TaskArgs.TargetPed ~= 0 then
			if RequestControlOfEntity(peds) then
				TASK.TASK_COMBAT_PED(peds, TaskArgs.TargetPed, 0, 16)
				OperationT[peds].TaskStatus = 28
				OperationT[peds].Target = TaskArgs.TargetPed
			end
		else
			OperationT[peds].TaskStatus = 100
		end
	end
end
TaskStatusFunctionsT[24+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 24 then
		if TaskArgs.OffsetsAttach ~= nil and TaskArgs.RotsAttach ~= nil then
			if TaskArgs.AttachedNum < TaskArgs.MaxAttachs then
				if ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 30.0, 30.0, 30.0, false, true, false) then
					if not PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
						if PlayerVeh ~= 0 then
							if PED.IS_PED_IN_VEHICLE(PlayerPed, PlayerVeh, true) then
								if RequestControlOfEntity(peds) then
									PED.SET_PED_USING_ACTION_MODE(peds, false, -1, "DEFAULT_ACTION")
									PED.SET_PED_MOVEMENT_CLIPSET(peds, "move_ped_crouched", 0.55)
									PED.SET_PED_STRAFE_CLIPSET(peds, "move_ped_crouched_strafing")
									ENTITY.ATTACH_ENTITY_TO_ENTITY(peds, PlayerVeh, 0, TaskArgs.OffsetsAttach[TaskArgs.AttachedNum+1].x, TaskArgs.OffsetsAttach[TaskArgs.AttachedNum+1].y,
									TaskArgs.OffsetsAttach[TaskArgs.AttachedNum+1].z, TaskArgs.RotsAttach[TaskArgs.AttachedNum+1].x,
									TaskArgs.RotsAttach[TaskArgs.AttachedNum+1].y, TaskArgs.RotsAttach[TaskArgs.AttachedNum+1].z, false, false, false, false, 2, true, false)
									TaskArgs.AttachedNum = TaskArgs.AttachedNum + 1
									OperationT[peds].TaskStatus = 100
								end
							end
						end
					end
				else
					OperationT[peds].TaskStatus = 100	
				end
			else
				OperationT[peds].TaskStatus = 100
			end
		else
			OperationT[peds].TaskStatus = 100
		end
	end
end
local MinRadius = 0.5
TaskStatusFunctionsT[25+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 25 then
		local Target = 0
		if OperationT[peds].Target ~= nil then
			Target = OperationT[peds].Target
		else
			Target = PED.GET_PED_TARGET_FROM_COMBAT_PED(peds, 0)
		end
		if Target ~= 0 then
			if CopsSwitchToNearestTarget then
				local NewTarget = GetPedNearestTarget(peds)
				if NewTarget ~= 0 then
					Target = NewTarget
				end
			end
			OperationT[peds].Target = Target
			if not ENTITY.IS_ENTITY_DEAD(Target) and not PED.IS_PED_DEAD_OR_DYING(Target) and ENTITY.DOES_ENTITY_EXIST(Target) then
				if RequestControlOfEntity(peds) then
					local VehHandle = OperationT[peds].VehHandle
					if not PED.IS_PED_IN_ANY_VEHICLE(peds, false) then
						if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, Target, 17) then
							--local BonePos = PED.GET_PED_BONE_COORDS(Target, 0x322C --[[head]], 0.0, 0.0, 0.0)
							if CopsAimAtHead then
								PED.SET_PED_RESET_FLAG(Target, 108, true)
							end
							if not ENTITY.IS_ENTITY_AT_ENTITY(peds, Target, MinRadius, MinRadius, MinRadius, false, true, false) then
								--TASK.TASK_GO_TO_ENTITY_WHILE_AIMING_AT_ENTITY(peds, Target, Target, 3.0, true, 5.5, 4.0, true, true, joaat("FIRING_PATTERN_FULL_AUTO"))
								--TASK.TASK_GO_TO_ENTITY_WHILE_AIMING_AT_COORD(peds, Target, BonePos.x, BonePos.y, BonePos.z, 3.0, true, 2.0, 4.0, true, true, joaat("FIRING_PATTERN_FULL_AUTO"))
								TASK.TASK_SHOOT_AT_ENTITY(peds, Target, -1, joaat("FIRING_PATTERN_FULL_AUTO"))
								OperationT[peds].TaskStatus = 32
							else
								if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_COMBAT")) == 7 then
									TASK.TASK_COMBAT_PED(peds, Target, 0, 16)
								end
							end
						else
							TASK.TASK_GO_TO_ENTITY(peds, Target, -1, 1.0, 3.0, 2.0, 0)
							OperationT[peds].TaskStatus = 26
						end
						--TASK.TASK_GO_TO_ENTITY_WHILE_AIMING_AT_COORD(peds, Target, BonePos.x, BonePos.y, BonePos.z, 3.0, true, 2.0, 4.0, true, true, joaat("FIRING_PATTERN_FULL_AUTO"))
						PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, true)
						
					else
						if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_COMBAT")) == 7 then
							if CopsAimAtHead then
								PED.SET_PED_RESET_FLAG(Target, 108, true)
							end
							TASK.TASK_COMBAT_PED(peds, Target, 0, 16)
						end
					end
				end
			else
				if RequestControlOfEntity(peds) then
					OperationT[peds].Target = nil
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
					TASK.CLEAR_PED_TASKS(peds)
				end
			end
		else
			if RequestControlOfEntity(peds) then
				OperationT[peds].Target = nil
				PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
			end
		end
	end
end
TaskStatusFunctionsT[26+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 26 then
		if CopsSwitchToNearestTarget then
			local NewTarget = GetPedNearestTarget(peds)
			if NewTarget ~= 0 then
				OperationT[peds].Target = NewTarget
			end
		end
		if OperationT[peds].Target ~= 0 then
			if not ENTITY.IS_ENTITY_DEAD(OperationT[peds].Target) and not PED.IS_PED_DEAD_OR_DYING(OperationT[peds].Target) and ENTITY.DOES_ENTITY_EXIST(OperationT[peds].Target) then
				if CopsAimAtHead then
					PED.SET_PED_RESET_FLAG(OperationT[peds].Target, 108, true)
				end
				if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, OperationT[peds].Target, 17) then
					OperationT[peds].TaskStatus = 25
					TASK.CLEAR_PED_TASKS(peds)
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
				end
			else
				if RequestControlOfEntity(peds) then
					OperationT[peds].TaskStatus = 25
					TASK.CLEAR_PED_TASKS(peds)
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
				end
			end
		end
	end
end
TaskStatusFunctionsT[27+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 27 then
		if not ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 30.0, 30.0, 30.0, false, true, false) then
			if RequestControlOfEntity(peds) then
				local IsInVeh = PED.IS_PED_IN_ANY_VEHICLE(PlayerPed, true)
				local FVect = nil
				if IsInVeh then
					FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(PlayerPed)
				else
					FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(peds)
				end
				local MultiplierToGive = 5
				if IsInVeh then
					MultiplierToGive = -50
				end
				local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
				local AdjustedX = PPos.x + FVect.x * (MultiplierToGive + TaskArgs.OffsetBringedPeds)
				local AdjustedY = PPos.y + FVect.y * (MultiplierToGive + TaskArgs.OffsetBringedPeds)
				local AdjustedZ = PPos.z + FVect.z * (MultiplierToGive + TaskArgs.OffsetBringedPeds)
				local DidHit = memory.alloc(1)
				local EndCoords = v3.new()
				local Normal = v3.new()
				local HitEntity = memory.alloc_int()
				
				local Handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
					PPos.x, PPos.y, PPos.z,
					AdjustedX, AdjustedY, AdjustedZ,
					-1,
					PlayerPed, 7
				)
				SHAPETEST.GET_SHAPE_TEST_RESULT(Handle, DidHit, EndCoords, Normal, HitEntity)
				if memory.read_byte(DidHit) ~= 0 then
					if not MISC.IS_POSITION_OCCUPIED(EndCoords.x, EndCoords.y, EndCoords.z - 1.0, 1.0, false, true, true, false, false, PlayerPed, true) then
						ENTITY.SET_ENTITY_COORDS(peds, EndCoords.x, EndCoords.y, EndCoords.z - 1.0)
						OperationT[peds].TaskStatus = 100
					else
						TaskArgs.OffsetBringedPeds = TaskArgs.OffsetBringedPeds + 1
					end
				else
					if not MISC.IS_POSITION_OCCUPIED(AdjustedX, AdjustedY, AdjustedZ - 1.0, 1.0, false, true, true, false, false, PlayerPed, true) then
						ENTITY.SET_ENTITY_COORDS(peds, AdjustedX, AdjustedY, AdjustedZ - 1.0)
						OperationT[peds].TaskStatus = 100
					else
						TaskArgs.OffsetBringedPeds = TaskArgs.OffsetBringedPeds + 1
					end
				end
				if OperationT[peds].TPAttempts == nil then
					OperationT[peds].TPAttempts = 0
				end
				OperationT[peds].TPAttempts = OperationT[peds].TPAttempts + 1
				if OperationT[peds].TPAttempts > 100 then
					OperationT[peds].TaskStatus = 100
				end
			end
		else
			OperationT[peds].TaskStatus = 100
		end
	end
end

local CopsRushedFollow = false
local DistanceMult = 0.5
TaskStatusFunctionsT[28+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 28 then
		local Target = 0
		if OperationT[peds].Target ~= nil then
			Target = OperationT[peds].Target
		else
			Target = PED.GET_PED_TARGET_FROM_COMBAT_PED(peds, 0)
		end
		if Target ~= 0 then
			if CopsSwitchToNearestTarget then
				local NewTarget = GetPedNearestTarget(peds)
				if NewTarget ~= 0 then
					OperationT[peds].Target = NewTarget
					Target = NewTarget
				end
			end
			if not ENTITY.IS_ENTITY_DEAD(Target) and not PED.IS_PED_DEAD_OR_DYING(Target) and ENTITY.DOES_ENTITY_EXIST(Target) then
				if RequestControlOfEntity(peds) then
					local VehHandle = PED.GET_VEHICLE_PED_IS_IN(peds, false)
					if not PED.IS_PED_IN_ANY_VEHICLE(peds, false) then
						if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, Target, 17) then
							if CopsAimAtHead then
								PED.SET_PED_RESET_FLAG(Target, 108, true)
							end
							if not ENTITY.IS_ENTITY_AT_ENTITY(peds, Target, MinRadius, MinRadius, MinRadius, false, true, false) then
								TASK.TASK_GO_TO_ENTITY_WHILE_AIMING_AT_ENTITY(peds, Target, Target, 3.0, true, 0.15, 1.0, true, true, joaat("FIRING_PATTERN_FULL_AUTO"))
							else
								if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_COMBAT")) == 7 then
									TASK.TASK_COMBAT_PED(peds, Target, 0, 16)
								end
							end
							PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, true)
							OperationT[peds].TaskStatus = 31
						else
							TASK.TASK_GO_TO_ENTITY(peds, Target, -1, 1.0, 3.0, 2.0, 0)
							PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, true)
							OperationT[peds].TaskStatus = 30
						end
					else
						if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_COMBAT")) == 7 then
							if CopsAimAtHead then
								PED.SET_PED_RESET_FLAG(Target, 108, true)
							end
							TASK.TASK_COMBAT_PED(peds, Target, 0, 16)
							--PED.SET_PED_COMBAT_ATTRIBUTES(peds, 3, false)
						end
						if CopsRushedFollow then
							if ENTITY.DOES_ENTITY_EXIST(VehHandle) and VehHandle ~= PlayerVeh then
								local VehClass = VEHICLE.GET_VEHICLE_CLASS(VehHandle)
								if VehClass ~= 15 and VehClass ~= 16 then
									local VehPos = ENTITY.GET_ENTITY_COORDS(VehHandle)
									local TargetPos = ENTITY.GET_ENTITY_COORDS(Target)
									local Distance = MISC.GET_DISTANCE_BETWEEN_COORDS(TargetPos.x, TargetPos.y, TargetPos.z, VehPos.x, VehPos.y, VehPos.z, true)
									if TaskArgs.CopsRushWithTP then
										if Distance > 300.0 then
											if RequestControlOfEntity(VehHandle) then
												local OutPos = v3.new()
												local Heading = memory.alloc(8)
												local NumLanes = memory.alloc(8)
												local RandomX = TargetPos.x + (math.random() < 0.5 and math.random(-50, -30) or math.random(30, 50))
												local RandomY = TargetPos.y + (math.random() < 0.5 and math.random(-50, -30) or math.random(30, 50))
												local RandomZ = TargetPos.z + (math.random() < 0.5 and math.random(-50, -30) or math.random(30, 50))
												local Found = PATHFIND.GET_NTH_CLOSEST_VEHICLE_NODE_WITH_HEADING(RandomX, RandomY, RandomZ, 1, OutPos, Heading, NumLanes, 1, 3.0, 0.0)
												if Found then
													if not MISC.IS_POSITION_OCCUPIED(OutPos.x, OutPos.y, OutPos.z, 2.0, false, true, true, false, false, 0, true) then
														ENTITY.SET_ENTITY_COORDS(VehHandle, OutPos.x, OutPos.y, OutPos.z)
														ENTITY.SET_ENTITY_HEADING(VehHandle, memory.read_float(Heading))
													end
												end
											end
										end
									end
									if OperationT[peds].LastDistance == nil then
										OperationT[peds].LastDistance = Distance
									end
									local NormZ = 0.0
									local EntSpeed = ENTITY.GET_ENTITY_SPEED_VECTOR(VehHandle, true)
									local EntSpeedTotal = ENTITY.GET_ENTITY_SPEED(VehHandle)
									local BoneIndex = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(VehHandle, "steeringwheel")
									local EntVel = ENTITY.GET_ENTITY_VELOCITY(VehHandle)
									local FVect, RVect, UpVect, Vect = v3.new(), v3.new(), v3.new(), v3.new()
									ENTITY.GET_ENTITY_MATRIX(VehHandle, FVect, RVect, UpVect, Vect)
									local AdjustedVect = {x = VehPos.x + FVect.x * 6.0, y = VehPos.y + FVect.y * 6.0, z = VehPos.z + FVect.z * 6.0}
									local Norm = v3.new()
									if BoneIndex ~= 0 then
										local Rot = ENTITY.GET_ENTITY_BONE_OBJECT_ROTATION(VehHandle, BoneIndex)
										Norm = v3.normalise(Rot)
										NormZ = Rot.y
									end
									local NormZAbs = math.abs(NormZ)
									if Distance <= OperationT[peds].LastDistance then
										if RequestControlOfEntity(VehHandle) then
											if EntSpeed.y > 3.0 and EntSpeed.y < 50.0 then
												ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, NormZ * 0.005 * EntSpeed.y, (1.0 - NormZAbs) * 0.01 * EntSpeed.y, 0.0, 0, true, true, false)
											end
											local ForceZ = 0.0
											EntSpeed = ENTITY.GET_ENTITY_SPEED_VECTOR(VehHandle, true)
											if ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(VehHandle) > 1.1 then --or EntSpeed.x > 1.0 or EntSpeed.x < -1.0 then
												ForceZ = -1.50
											end
											ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, 0.0, 0.0, ForceZ, 0, false, true, false)
											if EntSpeed.y >= 3.0 then
												ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, NormZ * 0.005 * EntSpeed.y, -NormZAbs * 0.01 * EntSpeed.y, 0.0, 0, true, true, false)
											end
											local AdjustedVect2 = {x = VehPos.x + FVect.x * EntSpeed.y * DistanceMult, y = VehPos.y + FVect.y * EntSpeed.y * DistanceMult, z = VehPos.z + FVect.z * EntSpeed.y * DistanceMult}
											local EndCoords2, DidHit2, EntHit2, SurfaceNormal2 = ShapeTestNav(VehHandle, VehPos, AdjustedVect2)
											if DidHit2 and EntSpeed.y >= 2.0 then
												ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, 0.0, -1.0, 0.0, 0, true, true, false)
											end
											local AdjustedVect3 = {x = VehPos.x + RVect.x * 2.0, y = VehPos.y + RVect.y * 2.0, z = VehPos.z + RVect.z * 2.0}
											local EndCoords3, DidHit3, EntHit3, SurfaceNormal3 = ShapeTestNav(VehHandle, VehPos, AdjustedVect3)
											if DidHit3 then
												ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, -1.0, 0.0, 0.0, 0, true, true, false)
											end
											local AdjustedVect4 = {x = VehPos.x - RVect.x * 2.0, y = VehPos.y - RVect.y * 2.0, z = VehPos.z - RVect.z * 2.0}
											local EndCoords4, DidHit4, EntHit4, SurfaceNormal4 = ShapeTestNav(VehHandle, VehPos, AdjustedVect4)
											if DidHit4 then
												ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, 1.0, 0.0, 0.0, 0, true, true, false)
											end
											ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 5, 0.0, 0.0, -NormZ * 0.0005 * EntSpeed.y, 0, false, true, false)
										end
									else
										if Distance < OperationT[peds].LastDistance then
											OperationT[peds].LastDistance = Distance
										end
									end
								end
							end
						end
					end
					OperationT[peds].Target = Target
				end
			else
				if RequestControlOfEntity(peds) then
					OperationT[peds].Target = nil
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
					TASK.CLEAR_PED_TASKS(peds)
				end
			end
		else
			if RequestControlOfEntity(peds) then
				OperationT[peds].Target = nil
				PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
			end
		end
	end
end
TaskStatusFunctionsT[29+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 29 then
		if CopsSwitchToNearestTarget then
			local NewTarget = GetPedNearestTarget(peds)
			if NewTarget ~= 0 then
				OperationT[peds].Target = NewTarget
			end
		end
		if OperationT[peds].Target ~= 0 then
			if not ENTITY.IS_ENTITY_DEAD(OperationT[peds].Target) and not PED.IS_PED_DEAD_OR_DYING(OperationT[peds].Target) and ENTITY.DOES_ENTITY_EXIST(OperationT[peds].Target) then
				if PED.IS_PED_SHOOTING(peds) then
					OperationT[peds].TaskStatus = 28
				end
			else
				if RequestControlOfEntity(peds) then
					OperationT[peds].TaskStatus = 28
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
					TASK.CLEAR_PED_TASKS(peds)
					OperationT[peds].Target = nil
				end
			end
		end
	end
end
TaskStatusFunctionsT[30+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 30 then
		if OperationT[peds].TaskAttempts == nil then
			OperationT[peds].TaskAttempts = 0
		else
			if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_GO_TO_ENTITY")) == 7 then
				OperationT[peds].TaskAttempts = OperationT[peds].TaskAttempts + 1
			end
		end
		if CopsSwitchToNearestTarget then
			local NewTarget = GetPedNearestTarget(peds)
			if NewTarget ~= 0 then
				OperationT[peds].Target = NewTarget
			end
		end
		if OperationT[peds].Target ~= 0 and OperationT[peds].TaskAttempts < 10 then
			if not ENTITY.IS_ENTITY_DEAD(OperationT[peds].Target) and not PED.IS_PED_DEAD_OR_DYING(OperationT[peds].Target) and ENTITY.DOES_ENTITY_EXIST(OperationT[peds].Target) then
				if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, OperationT[peds].Target, 17) then
					if RequestControlOfEntity(peds) then
						OperationT[peds].TaskStatus = 28
						PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
						TASK.CLEAR_PED_TASKS(peds)
					end
				end
			else
				if RequestControlOfEntity(peds) then
					OperationT[peds].TaskStatus = 28
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
					TASK.CLEAR_PED_TASKS(peds)
					OperationT[peds].Target = nil
					OperationT[peds].TaskAttempts = nil
				end
			end
		else
			if RequestControlOfEntity(peds) then
				OperationT[peds].TaskStatus = 28
				PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
				TASK.CLEAR_PED_TASKS(peds)
				OperationT[peds].Target = nil
				OperationT[peds].TaskAttempts = nil
			end
		end
	end
end
TaskStatusFunctionsT[31+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 31 then
		if CopsSwitchToNearestTarget then
			local NewTarget = GetPedNearestTarget(peds)
			if NewTarget ~= 0 then
				if OperationT[peds].Target ~= NewTarget then
				
					if RequestControlOfEntity(peds) then
						OperationT[peds].TaskStatus = 28
						PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
						TASK.CLEAR_PED_TASKS(peds)
					end
				end
			end
		end
		if OperationT[peds].Target ~= 0 then
			if not ENTITY.IS_ENTITY_DEAD(OperationT[peds].Target) and not PED.IS_PED_DEAD_OR_DYING(OperationT[peds].Target) and ENTITY.DOES_ENTITY_EXIST(OperationT[peds].Target) then
				if CopsAimAtHead then
					PED.SET_PED_RESET_FLAG(OperationT[peds].Target, 108, true)
				end
				if not ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, OperationT[peds].Target, 17) or
				ENTITY.IS_ENTITY_AT_ENTITY(peds, OperationT[peds].Target, MinRadius, MinRadius, MinRadius, false, true, false) then
					if RequestControlOfEntity(peds) then
						OperationT[peds].TaskStatus = 28
						PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
						TASK.CLEAR_PED_TASKS(peds)
					end
				end
			else
				if RequestControlOfEntity(peds) then
					OperationT[peds].TaskStatus = 28
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
					TASK.CLEAR_PED_TASKS(peds)
					OperationT[peds].Target = nil
				end
			end
		end
	end
end
TaskStatusFunctionsT[32+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 32 then
		if OperationT[peds].Target ~= 0 then
			if not ENTITY.IS_ENTITY_DEAD(OperationT[peds].Target) and not PED.IS_PED_DEAD_OR_DYING(OperationT[peds].Target) and ENTITY.DOES_ENTITY_EXIST(OperationT[peds].Target) then
				if CopsAimAtHead then
					PED.SET_PED_RESET_FLAG(OperationT[peds].Target, 108, true)
				end
			else
				if RequestControlOfEntity(peds) then
					OperationT[peds].TaskStatus = 25
					TASK.CLEAR_PED_TASKS(peds)
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
				end
			end
		end
	end
end

TaskStatusFunctionsT[33+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 33 then
		if ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 30.0, 30.0, 10.0, false, true, 0) then	
			if not PED.IS_PED_IN_ANY_VEHICLE(peds, false) then
				local OffsetToGive = TaskArgs.OperationOffset
				if TaskArgs.OperationSide == 0 then
					OffsetToGive = -TaskArgs.OperationOffset
				end
				if TaskArgs.OperationSide == 1 then
					OffsetToGive = TaskArgs.OperationOffset
				end
				OperationT[peds].X = OperationT[peds].Vect.x + ((OperationT[peds].RVect.x * OffsetToGive) - (OperationT[peds].FVect.x * (TaskArgs.OperationStatus + 10)))
				OperationT[peds].Y = OperationT[peds].Vect.y + ((OperationT[peds].RVect.y * OffsetToGive) - (OperationT[peds].FVect.y * (TaskArgs.OperationStatus + 10)))
				OperationT[peds].Z = OperationT[peds].Vect.z + ((OperationT[peds].RVect.z * OffsetToGive) - (OperationT[peds].FVect.z * (TaskArgs.OperationStatus + 10)))
				--local PedPos = ENTITY.GET_ENTITY_COORDS(peds)
				--local AdjustedVect = {x = OperationT[peds].X, y = OperationT[peds].Y, z = OperationT[peds].Z - 2.0}
				--local EndCoords, DidHit = ShapeTestNav(peds, PedPos, AdjustedVect, 19)
				--if DidHit then
				--	OperationT[peds].X = EndCoords.x
				--	OperationT[peds].Y = EndCoords.y
				--	OperationT[peds].Z = EndCoords.z
				--end
				OperationT[peds].YOffset = TaskArgs.OperationStatus
				OperationT[peds].XOffset = OffsetToGive
				TaskArgs.OperationStatus = TaskArgs.OperationStatus + 1
				if TaskArgs.OperationStatus > 4 then
					TaskArgs.OperationStatus = 0
					TaskArgs.OperationSide = TaskArgs.OperationSide + 1
					if TaskArgs.OperationSide > 1 then
						TaskArgs.OperationSide = 0
						TaskArgs.OperationOffset = TaskArgs.OperationOffset + 1.0
					end
				end
				if RequestControlOfEntity(peds) then
					PED.SET_PED_COMBAT_MOVEMENT(peds, 0)
					--TASK.TASK_GO_TO_COORD_ANY_MEANS(peds, OperationT[peds].X, OperationT[peds].Y, OperationT[peds].Z, 3.5, 0, false, 0, -1.0)
					TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(peds, PlayerPed, OperationT[peds].XOffset, OperationT[peds].YOffset, -1, 100.0, -1, 0.1, true)
					OperationT[peds].TaskStatus = 34
				end
			else
				if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_LEAVE_ANY_VEHICLE")) == 7 then
					if RequestControlOfEntity(peds) then
						TASK.TASK_LEAVE_ANY_VEHICLE(peds, 0, 16)
					end
				end
			end
		end
	end
end

TaskStatusFunctionsT[34+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 34 then
		if CopsSwitchToNearestTarget then
			local NewTarget = GetPedNearestTarget(peds)
			if NewTarget ~= 0 then
				OperationT[peds].Target = NewTarget
			end
		end
		--if ENTITY.IS_ENTITY_AT_COORD(peds, OperationT[peds].X, OperationT[peds].Y, OperationT[peds].Z, 3.0, 3.0, 3.0, false, true, 0) then
		if TaskArgs.IsAiming or TASK.GET_SCRIPT_TASK_STATUS(peds, "SCRIPT_TASK_FOLLOW_TO_OFFSET_OF_ENTITY") == 7
		or OperationT[peds].Target ~= nil then
			OperationT[peds].TaskStatus = 35
		end
	end
end

TaskStatusFunctionsT[35+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 35 then
		OperationT[peds].X = TaskArgs.PlayerCoords.x + ((TaskArgs.RVect.x * OperationT[peds].XOffset) - (TaskArgs.FVect.x * (OperationT[peds].YOffset)))
		OperationT[peds].Y = TaskArgs.PlayerCoords.y + ((TaskArgs.RVect.y * OperationT[peds].XOffset) - (TaskArgs.FVect.y * (OperationT[peds].YOffset)))
		OperationT[peds].Z = TaskArgs.PlayerCoords.z + ((TaskArgs.RVect.z * OperationT[peds].XOffset) - (TaskArgs.FVect.z * (OperationT[peds].YOffset)))
		local Target = 0
		if CopsSwitchToNearestTarget then
			local NewTarget = GetPedNearestTarget(peds)
			if NewTarget ~= 0 then
				OperationT[peds].Target = NewTarget
			end
		end
		if OperationT[peds].Target == nil then
			Target = PED.GET_PED_TARGET_FROM_COMBAT_PED(peds, 0)
		else
			Target = OperationT[peds].Target
		end
		if Target == 0 then
			if not ENTITY.IS_ENTITY_AT_COORD(peds, OperationT[peds].X, OperationT[peds].Y, OperationT[peds].Z, 1.0, 1.0, 1.0, false, true, 0) then
				if RequestControlOfEntity(peds) then
					if TaskArgs.IsAiming then
						if TaskArgs.HitCoords ~= nil then
							TASK.TASK_GO_TO_COORD_WHILE_AIMING_AT_COORD(peds, OperationT[peds].X, OperationT[peds].Y, OperationT[peds].Z,
							TaskArgs.HitCoords.x, TaskArgs.HitCoords.y, TaskArgs.HitCoords.z, 3.5, TaskArgs.IsPlayerShooting, 0.5, 2.0, true, 0, true, joaat("FIRING_PATTERN_FULL_AUTO"))
							OperationT[peds].TaskStatus = 36
						end
					else
						--TASK.TASK_GO_TO_COORD_ANY_MEANS(peds, OperationT[peds].X, OperationT[peds].Y, OperationT[peds].Z, 3.5, 0, false, 0, -1.0)
						TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(peds, PlayerPed, OperationT[peds].XOffset, -OperationT[peds].YOffset, -1, 100.0, -1, 0.5, true)
						OperationT[peds].TaskStatus = 34
					end
				end
			else
				if RequestControlOfEntity(peds) then
					if TaskArgs.IsAiming then
						if TaskArgs.HitCoords ~= nil then
							if not TaskArgs.IsPlayerShooting then
								TASK.TASK_AIM_GUN_AT_COORD(peds, TaskArgs.HitCoords.x, TaskArgs.HitCoords.y, TaskArgs.HitCoords.z, 10000, false, false)
							else
								TASK.TASK_SHOOT_AT_COORD(peds, TaskArgs.HitCoords.x, TaskArgs.HitCoords.y, TaskArgs.HitCoords.z, 3000, joaat("FIRING_PATTERN_FULL_AUTO"))
								OperationT[peds].TaskStatus = 39
							end
						end
					else
						--TASK.TASK_GO_TO_COORD_ANY_MEANS(peds, OperationT[peds].X, OperationT[peds].Y, OperationT[peds].Z, 3.5, 0, false, 0, -1.0)
						TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(peds, PlayerPed, OperationT[peds].XOffset, -OperationT[peds].YOffset, -1, 100.0, -1, 0.5, true)
						OperationT[peds].TaskStatus = 34
					end
				end
			end
		else
			--if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, Target, 17) then
				if RequestControlOfEntity(peds) then
					if CopsAimAtHead then
						PED.SET_PED_RESET_FLAG(Target, 108, true)
					end
					--TASK.CLEAR_PED_TASKS(peds)
					PED.SET_PED_COMBAT_ATTRIBUTES(peds, 26, true)
					--TASK.TASK_AIM_GUN_AT_ENTITY(peds, Target, 3000, true)
					TASK.TASK_GO_TO_COORD_WHILE_AIMING_AT_ENTITY(peds, OperationT[peds].X, OperationT[peds].Y,
					OperationT[peds].Z, Target, 3.5, true, 1.0, 4.0, false, 0, true, joaat("FIRING_PATTERN_FULL_AUTO"), -1)
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, true)
					OperationT[peds].Target = Target
					OperationT[peds].TaskStatus = 37
				end
			--end
		end
	end
end

TaskStatusFunctionsT[36+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 36 then
		if TaskArgs.IsPlayerShooting then
			if RequestControlOfEntity(peds) then
				OperationT[peds].X = TaskArgs.PlayerCoords.x + ((TaskArgs.RVect.x * OperationT[peds].XOffset) - (TaskArgs.FVect.x * (OperationT[peds].YOffset)))
				OperationT[peds].Y = TaskArgs.PlayerCoords.y + ((TaskArgs.RVect.y * OperationT[peds].XOffset) - (TaskArgs.FVect.y * (OperationT[peds].YOffset)))
				OperationT[peds].Z = TaskArgs.PlayerCoords.z + ((TaskArgs.RVect.z * OperationT[peds].XOffset) - (TaskArgs.FVect.z * (OperationT[peds].YOffset)))
				TASK.TASK_GO_TO_COORD_WHILE_AIMING_AT_COORD(peds, OperationT[peds].X, OperationT[peds].Y, OperationT[peds].Z,
				TaskArgs.HitCoords.x, TaskArgs.HitCoords.y, TaskArgs.HitCoords.z, 3.5, TaskArgs.IsPlayerShooting, 0.5, 2.0, true, 0, true, joaat("FIRING_PATTERN_FULL_AUTO"))
			end
		end
		if ENTITY.IS_ENTITY_AT_COORD(peds, OperationT[peds].X, OperationT[peds].Y, OperationT[peds].Z, 1.0, 1.0, 1.0, false, true, 0) then
			OperationT[peds].TaskStatus = 35
		end
	end
end

TaskStatusFunctionsT[37+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 37 then
		if not ENTITY.IS_ENTITY_DEAD(OperationT[peds].Target) and not PED.IS_PED_DEAD_OR_DYING(OperationT[peds].Target) and ENTITY.DOES_ENTITY_EXIST(OperationT[peds].Target)
		and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, OperationT[peds].Target, 17) then
			if CopsAimAtHead then
				PED.SET_PED_RESET_FLAG(OperationT[peds].Target, 108, true)
			end
			if not ENTITY.IS_ENTITY_AT_COORD(peds, OperationT[peds].X, OperationT[peds].Y, OperationT[peds].Z, 1.0, 1.0, 1.0, false, true, 0) then
				if RequestControlOfEntity(peds) then
					--if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_SHOOT_AT_ENTITY")) ~= 7 then
					--	TASK.CLEAR_PED_TASKS(peds)
					--end
					OperationT[peds].X = TaskArgs.PlayerCoords.x + ((TaskArgs.RVect.x * OperationT[peds].XOffset) - (TaskArgs.FVect.x * (OperationT[peds].YOffset)))
					OperationT[peds].Y = TaskArgs.PlayerCoords.y + ((TaskArgs.RVect.y * OperationT[peds].XOffset) - (TaskArgs.FVect.y * (OperationT[peds].YOffset)))
					OperationT[peds].Z = TaskArgs.PlayerCoords.z + ((TaskArgs.RVect.z * OperationT[peds].XOffset) - (TaskArgs.FVect.z * (OperationT[peds].YOffset)))
					TASK.TASK_GO_TO_COORD_WHILE_AIMING_AT_ENTITY(peds, OperationT[peds].X, OperationT[peds].Y,
					OperationT[peds].Z, OperationT[peds].Target, 3.5, true, 1.0, 4.0, true --[[Use Navmesh]], 0, true, joaat("FIRING_PATTERN_FULL_AUTO"), -1)
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, true)
					--if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_GO_TO_COORD_WHILE_AIMING_AT_ENTITY")) ~= 7 then
						OperationT[peds].TaskStatus = 38
					--end
				end
			else
				if RequestControlOfEntity(peds) then
					OperationT[peds].X = TaskArgs.PlayerCoords.x + ((TaskArgs.RVect.x * OperationT[peds].XOffset) - (TaskArgs.FVect.x * (OperationT[peds].YOffset)))
					OperationT[peds].Y = TaskArgs.PlayerCoords.y + ((TaskArgs.RVect.y * OperationT[peds].XOffset) - (TaskArgs.FVect.y * (OperationT[peds].YOffset)))
					OperationT[peds].Z = TaskArgs.PlayerCoords.z + ((TaskArgs.RVect.z * OperationT[peds].XOffset) - (TaskArgs.FVect.z * (OperationT[peds].YOffset)))
					--TASK.CLEAR_PED_TASKS(peds)
					TASK.TASK_SHOOT_AT_ENTITY(peds, OperationT[peds].Target, -1, joaat("FIRING_PATTERN_FULL_AUTO"))
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, true)
					OperationT[peds].TaskStatus = 38
				end
			end
		else
			if RequestControlOfEntity(peds) then
				TASK.CLEAR_PED_TASKS(peds)
				PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
				OperationT[peds].TaskStatus = 35
				OperationT[peds].Target = nil
			end
		end
	end
end
TaskStatusFunctionsT[38+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 38 then
		if OperationT[peds].TaskDelay == nil then
			OperationT[peds].TaskDelay = 0
		end
		OperationT[peds].TaskDelay = OperationT[peds].TaskDelay + 1
		if OperationT[peds].TaskDelay > 100 then
			OperationT[peds].TaskDelay = 0
			OperationT[peds].TaskStatus = 37
			OperationT[peds].X = TaskArgs.PlayerCoords.x + ((TaskArgs.RVect.x * OperationT[peds].XOffset) - (TaskArgs.FVect.x * (OperationT[peds].YOffset)))
			OperationT[peds].Y = TaskArgs.PlayerCoords.y + ((TaskArgs.RVect.y * OperationT[peds].XOffset) - (TaskArgs.FVect.y * (OperationT[peds].YOffset)))
			OperationT[peds].Z = TaskArgs.PlayerCoords.z + ((TaskArgs.RVect.z * OperationT[peds].XOffset) - (TaskArgs.FVect.z * (OperationT[peds].YOffset)))
		end
	end
end

TaskStatusFunctionsT[39+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 39 then
		--if ENTITY.IS_ENTITY_AT_COORD(peds, OperationT[peds].X, OperationT[peds].Y, OperationT[peds].Z, 3.0, 3.0, 3.0, false, true, 0) then
		if PED.IS_PED_SHOOTING(peds) or OperationT[peds].Target ~= nil then
			OperationT[peds].TaskStatus = 35
		end
	end
end

TaskStatusFunctionsT[40+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 40 then
		if OperationT[peds].HasTasked == nil then
			if RequestControlOfEntity(peds) then
				TASK.TASK_GO_STRAIGHT_TO_COORD(peds, TaskArgs.HitCoords.x, TaskArgs.HitCoords.y, TaskArgs.HitCoords.z, 3.0, -1, 40000.0, 0.1)
				--OperationT[peds].TaskStatus = 100
				--util.copy_to_clipboard(string.format("%.3f", TaskArgs.HitCoords.x))
				OperationT[peds].HasTasked = 0
			end
		end
	end
end

TaskStatusFunctionsT[41+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 41 then
		
	end
end

TaskStatusFunctionsT[100+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	OperationT[peds] = nil
end
local SupportedVehiclesAttachs = {}

--[[
local ConstructsDir = filesystem.stand_dir().."Constructs\\"
if filesystem.exists(ConstructsDir) then
	for filesystem.list_files(ConstructsDir) as path do
		local Contents = LoadJSONFile(path)
		if Contents ~= nil then
			local Found = false
			SupportedVehiclesAttachs[#SupportedVehiclesAttachs+1] = {}
			SupportedVehiclesAttachs[#SupportedVehiclesAttachs].Model = string.lower(Contents.model)
			SupportedVehiclesAttachs[#SupportedVehiclesAttachs].Offsets = {}
			SupportedVehiclesAttachs[#SupportedVehiclesAttachs].Rotation = {}
			SupportedVehiclesAttachs[#SupportedVehiclesAttachs].FoundNum = 0
			for index, values in pairs(Contents.children) do
				if values.type == "PED" then
					Found = true
					SupportedVehiclesAttachs[#SupportedVehiclesAttachs].Offsets[#SupportedVehiclesAttachs[#SupportedVehiclesAttachs].Offsets + 1] = {x = values.offset.x, y = values.offset.y, z = values.offset.z}
					SupportedVehiclesAttachs[#SupportedVehiclesAttachs].Rotation[#SupportedVehiclesAttachs[#SupportedVehiclesAttachs].Rotation + 1] = {x = values.rotation.x, y = values.rotation.y, z = values.rotation.z}
					SupportedVehiclesAttachs[#SupportedVehiclesAttachs].FoundNum = SupportedVehiclesAttachs[#SupportedVehiclesAttachs].FoundNum + 1
				end
			end
			if not Found then
				table.remove(SupportedVehiclesAttachs, #SupportedVehiclesAttachs)
			end
		end
	end
end
]]

local NULL <const> = 0

local CayoCopsGlobalAddr = 2657921+1+442 --463

function SplitGlobals(GlobalString)
	local String = GlobalString
	local Value = String:gsub("%[(.-)]", "+1")
	local NewValue = Value:gsub("%a", "")
	local NewValue2 = NewValue:gsub("._", "+")
	local NewValue3 = NewValue2:gsub("_", "")
	local _Text, SymbolCount = NewValue3:gsub("+", "")
	local PatternCount = "(%d+)"
	for i = 1, SymbolCount do
		PatternCount = PatternCount .. "+(%d+)"
	end
	local Global, Global2, Global3, Global4, Global5, Global6, Global7 = NewValue3:match(PatternCount)
	local GlobalNumber = 0
	if Global ~= nil then
		GlobalNumber = GlobalNumber + tonumber(Global)
	end
	if Global2 ~= nil then
		GlobalNumber = GlobalNumber + tonumber(Global2)
	end
	if Global3 ~= nil then
		GlobalNumber = GlobalNumber + tonumber(Global3)
	end
	if Global4 ~= nil then
		GlobalNumber = GlobalNumber + tonumber(Global4)
	end
	if Global5 ~= nil then
		GlobalNumber = GlobalNumber + tonumber(Global5)
	end
	if Global6 ~= nil then
		GlobalNumber = GlobalNumber + tonumber(Global6)
	end
	if Global7 ~= nil then
		GlobalNumber = GlobalNumber + tonumber(Global7)
	end
	return GlobalNumber
end

local BBattle2_Peds = SplitGlobals("Local_5223.f_92[*25*]")
local BBattle2_NextPed = 25

local Addr = 0
local Addr2 = 0
local Addr3 = 0
local police3_FirstAddr = 0
local police3_Addrs = {}
local polmav_Addrs = {}
local fbi2_Addrs = {}
local sheriff_Addrs = {}
local sheriff2_Addrs = {}
local predator_Addrs = {}
local copped_Addrs = {}
local sheriffped_Addrs = {}
local swatped_Addrs = {}
local mesa3_Addrs = {}
local blackopsPed_Addrs = {}
local CanSetModels = false
--local RelPlayersBitsAddr = SplitGlobals("Global_2657704[PLAYER::PLAYER_ID() /*463*/].f_253")
local RelAddrs = {}
if NETWORK.GET_ONLINE_VERSION() == "1.70" then
	--Addr = 0x7FF66E4E63F0
	for i = 0, 29 do
		--RelAddrs[i+1] = memory.script_global(RelPlayersBitsAddr + 463 * i)
	end
	Addr = memory.scan("C0 C0 00 00 0C C2 00 00 0C 42 00 00 F0 41 00 00 B4 41 00 00 0C 42 ?")
	--Addr = memory.scan("GTA5")
	--Addr = Addr + 0x257FBC0-0x142C --0x0257AA80
	--Print(string.format("%X", Addr))
	--util.copy_to_clipboard(string.format("%X", Addr))
	if Addr ~= 0 then
		--Addr2 = memory.read_long(Addr+0x26)
		--Addr3 = memory.read_long(Addr2+0x8)
		--Addr4 = memory.read_long(Addr3+0xB0)
		Addr2 = memory.read_long(Addr+0x16)
		Addr3 = memory.read_long(Addr2+0x8)
		Addr4 = memory.read_long(Addr3+0xB0)
		police3_FirstAddr = Addr4
		local AddressToScan = police3_FirstAddr - 8 * 4000
		local MaxFoundAddrs = 7
		for i = 0, 8000 do
			local Value = memory.read_int(AddressToScan + 8 * i)
			if #police3_Addrs < MaxFoundAddrs then
				if Value == joaat("police3") then
					police3_Addrs[#police3_Addrs+1] = AddressToScan + 8 * i
					CanSetModels = true
				end
			end
			if #polmav_Addrs < MaxFoundAddrs then
				if Value == joaat("polmav") then
					polmav_Addrs[#polmav_Addrs+1] = AddressToScan + 8 * i
				end
			end
			if #fbi2_Addrs < MaxFoundAddrs then
				if Value == joaat("fbi2") then
					fbi2_Addrs[#fbi2_Addrs+1] = AddressToScan + 8 * i
				end
			end
			if #sheriff_Addrs < MaxFoundAddrs then
				if Value == joaat("sheriff") then
					sheriff_Addrs[#sheriff_Addrs+1] = AddressToScan + 8 * i
				end
			end
			if #sheriff2_Addrs < MaxFoundAddrs then
				if Value == joaat("sheriff2") then
					sheriff2_Addrs[#sheriff2_Addrs+1] = AddressToScan + 8 * i
				end
			end
			if #predator_Addrs < MaxFoundAddrs then
				if Value == joaat("predator") then
					predator_Addrs[#predator_Addrs+1] = AddressToScan + 8 * i
				end
			end
			if #copped_Addrs < MaxFoundAddrs then
				if Value == joaat("s_m_y_cop_01") then
					copped_Addrs[#copped_Addrs+1] = AddressToScan + 8 * i
					--Print("Found Cop")
				end
			end
			if #sheriffped_Addrs < MaxFoundAddrs then
				if Value == joaat("s_m_y_sheriff_01") then
					sheriffped_Addrs[#sheriffped_Addrs+1] = AddressToScan + 8 * i
					--Print("Found Sheriff")
				end
			end
			if #swatped_Addrs < MaxFoundAddrs then
				if Value == joaat("s_m_y_swat_01") then
					swatped_Addrs[#swatped_Addrs+1] = AddressToScan + 8 * i
					--Print("Found SWAT")
				end
			end
			if #mesa3_Addrs < MaxFoundAddrs then
				if Value == joaat("mesa3") then
					mesa3_Addrs[#mesa3_Addrs+1] = AddressToScan + 8 * i
				end
			end
			if #blackopsPed_Addrs < MaxFoundAddrs then
				if Value == joaat("s_m_y_blackops_01") then
					blackopsPed_Addrs[#blackopsPed_Addrs+1] = AddressToScan + 8 * i
				end
			end
		end
	end
	--Print("Found Police3 Addrs "..#police3_Addrs)
	--Print("Found Polmav Addrs "..#polmav_Addrs)
	--Print("Found FBI2 Addrs "..#fbi2_Addrs)
	--Print("Found Sheriff Addrs "..#sheriff_Addrs)
	--Print("Found Sheriff2 Addrs "..#sheriff2_Addrs)
	--Print("Found Cop Addrs "..#copped_Addrs)
	--Print("Found Sheriff Addrs "..#sheriffped_Addrs)
	--Print("Found SWAT Addrs "..#swatped_Addrs)
end

local AiHateRel = "rgFM_AiHate"
local AiLikeRel = "rgFM_AiLike"
local AiLikeHateAiHateRel = "rgFM_AiLike_HateAiHate"
local AiHateAiHateRel = "rgFM_HateAiHate"
local AiHateEveryone = "rgFM_HateEveryOne"

local WeaponsForCops = {
	"weapon_pistol",
	"weapon_pistol_mk2",
	"weapon_appistol",
	"weapon_pistol50",
	"weapon_navyrevolver",
	"weapon_stungun_mp",
	"weapon_flaregun",
	"weapon_heavypistol",
	"weapon_raypistol",
	"weapon_gadgetpistol",
	"weapon_microsmg",
	"weapon_assaultsmg",
	"weapon_smg",
	"weapon_smg_mk2",
	"weapon_combatpdw",
	"weapon_machinepistol",
	"weapon_minismg",
	"weapon_raycarbine",
	"weapon_tecpistol",
	"weapon_pumpshotgun",
	"weapon_sawnoffshotgun",
	"weapon_assaultshotgun",
	"weapon_musket",
	"weapon_heavyshotgun",
	"weapon_dbshotgun",
	"weapon_autoshotgun",
	"weapon_combatshotgun",
	"weapon_assaultrifle",
	"weapon_assaultrifle_mk2",
	"weapon_carbinerifle",
	"weapon_carbinerifle_mk2",
	"weapon_specialcarbine",
	"weapon_specialcarbine_mk2",
	"weapon_bullpuprifle",
	"weapon_bullpuprifle_mk2",
	"weapon_compactrifle",
	"weapon_militaryrifle",
	"weapon_heavyrifle",
	"weapon_tacticalrifle",
	"weapon_mg",
	"weapon_combatmg",
	"weapon_combatmg_mk2",
	"weapon_gusenberg",
	"weapon_sniperrifle",
	"weapon_heavysniper",
	"weapon_heavysniper_mk2",
	"weapon_marksmanrifle",
	"weapon_marksmanrifle_mk2",
	"weapon_precisionrifle",
	"weapon_rpg",
	"weapon_grenadelauncher",
	"weapon_minigun",
	"weapon_firework",
	"weapon_railgun",
	"weapon_hominglauncher",
	"weapon_compactlauncher",
	"weapon_rayminigun",
	"weapon_emplauncher"
}

local GiveWeaponOptions = {
	"Force Cop Weapon",
	"Auto Give Cop Weapon",
	"Random Cop Weapon",
	"Random Cop Weapon By Chance",
	"High Chance With Explosive Guns"
}



local VehicleModels = {
	"polmav",
	"savage",
	"annihilator",
	"valkyrie",
	"hunter",
	"buzzard",
	"khanjali",
	"rhino",
	"dune3",
	"caracara",
	"speedo4",
	"squaddie",
	"winky",
	"elegy",
	"elegy2",
	"caracara2",
	"tampa3",
	"nightshark",
	"technical3",
	"technical",
	"sultan2",
	"infernus2",
	"rcbandito",
	"insurgent3",
	"riata",
	"mesa3",
	"bruiser",
	"bruiser2",
	"bruiser3",
	"barrage",
	"apc",
	"cargobob",
	"cargobob2",
	"akula",
	"seasparrow",
	"patrolboat",
	"longfin",
	"dinghy5",
	"marquis",
	"tug",
	"hydra",
	"lazer",
	"polgauntlet",
	"aleutian",
	"asterope2",
	"dorado",
	"turismo3",
	"vivanite",
	"fbi"
}
local PedModels = {
	"mp_m_bogdangoon",
	"u_m_y_juggernaut_01",
	"mp_m_avongoon",
	"g_m_m_cartelguards_01",
	"g_m_m_cartelguards_02",
	"s_f_y_cop_01",
	"s_m_m_movspace_01",
	"ig_englishdave_02",
	"ig_gustavo",
	"ig_helmsmanpavel",
	"u_m_y_rsranger_01",
	"s_m_y_blackops_01",
	"s_m_y_blackops_02",
	"s_m_y_blackops_03",
	"a_m_y_motox_01",
	"a_m_y_motox_02",
	"s_m_y_valet_01",
	"u_m_y_pogo_01",
	"ig_avon",
	"s_m_m_highsec_03",
	"s_m_y_westsec_02",
	"s_m_m_snowcop_01",
	"csb_bogdan",
	"csb_avon",
	"hc_gunman",
	"mp_m_fibsec_01",
	--"mp_m_freemode_01",
	--"mp_f_freemode_01",
	"u_m_y_zombie_01"
}

local SelectedVehicleModels = {"nightshark"}
local SelectedPedModels = {"mp_m_bogdangoon"}
local ModelPresetsT = {
	"Bogdan Army",
	"Cops Super Cars",
	"Cops Armored Cars",
	"Casino Guards",
	"Heist Crews",
	"Cayo Perico Guards",
	"Space Rangers",
	"Hydra Bogdans",
	"FIB",
	"SWAT"
}

local CopSettingsMenu = menu.list(menu.my_root(), "Cop Settings", {}, "Which settings apply to cops.")
local CopModelSettings = nil
local RandomModels = false
local HasAppliedRandomModels = false
local RandomModelsEverytime = false
local CopyPlayerOutfitToCop = false
local RandomMerryweather = false
if CanSetModels then
	CopModelSettings = menu.list(CopSettingsMenu, "Cop Model Settings", {}, "Change cop ped and vehicles models.")
	menu.list_select(CopModelSettings, "Police Helicopter", {"polmavmodel"}, "", VehicleModels, 1, function(OnChange)
		for i = 1, #polmav_Addrs do
			memory.write_int(polmav_Addrs[i], joaat(VehicleModels[OnChange]))
		end
	end)
	menu.list_select(CopModelSettings, "Police3", {"police3model"}, "", VehicleModels, 1, function(OnChange)
		for i = 1, #police3_Addrs do
			memory.write_int(police3_Addrs[i], joaat(VehicleModels[OnChange]))
		end
	end)
	menu.list_select(CopModelSettings, "FBI2", {"fbi2model"}, "", VehicleModels, 1, function(OnChange)
		for i = 1, #fbi2_Addrs do
			memory.write_int(fbi2_Addrs[i], joaat(VehicleModels[OnChange]))
		end
	end)
	menu.list_select(CopModelSettings, "Sheriff", {"sheriffmodel"}, "", VehicleModels, 1, function(OnChange)
		for i = 1, #sheriff_Addrs do
			memory.write_int(sheriff_Addrs[i], joaat(VehicleModels[OnChange]))
		end
	end)
	menu.list_select(CopModelSettings, "Sheriff2", {"sheriff2model"}, "", VehicleModels, 1, function(OnChange)
		for i = 1, #sheriff2_Addrs do
			memory.write_int(sheriff2_Addrs[i], joaat(VehicleModels[OnChange]))
		end
	end)
	menu.list_select(CopModelSettings, "Predator", {"predatorboatmodel"}, "", VehicleModels, 1, function(OnChange)
		for i = 1, #predator_Addrs do
			memory.write_int(predator_Addrs[i], joaat(VehicleModels[OnChange]))
		end
	end)
	menu.list_select(CopModelSettings, "Cop Ped", {"coppedmodel"}, "", PedModels, 1, function(OnChange)
		for i = 1, #copped_Addrs do
			memory.write_int(copped_Addrs[i], joaat(PedModels[OnChange]))
		end
		SelectedPedModels[1] = PedModels[OnChange]
	end)
	menu.list_select(CopModelSettings, "Sheriff Ped", {"sheriffpedmodel"}, "", PedModels, 1, function(OnChange)
		for i = 1, #sheriffped_Addrs do
			memory.write_int(sheriffped_Addrs[i], joaat(PedModels[OnChange]))
		end
		SelectedPedModels[2] = PedModels[OnChange]
	end)
	menu.list_select(CopModelSettings, "SWAT Ped", {"swatpedmodel"}, "", PedModels, 1, function(OnChange)
		for i = 1, #swatped_Addrs do
			memory.write_int(swatped_Addrs[i], joaat(PedModels[OnChange]))
		end
		SelectedPedModels[3] = PedModels[OnChange]
	end)
	menu.action(CopModelSettings, "Bypass Law Vehicles", {}, "To spawn cops and SWATS inside different police vehicles", function(toggle)
		local AddrDispatch = memory.scan("8b ? ? ? ? ? 41 8b f1 45 8a d0 c1 e8 1f 40 8a ea 41 84 c4 75")
		if AddrDispatch ~= 0 then
			local AddrTarget = AddrDispatch + 21
			memory.write_byte(AddrTarget, 0xEB)
		end
		local AddrSWATDispatch = memory.scan("74 ? 3b 05 ? ? ? ? 74 ? 3b 05 ? ? ? ? 75 ? ? b0 01")
		if AddrSWATDispatch ~= 0 then
			local AddrTarget = AddrSWATDispatch + 16
			memory.write_byte(AddrTarget, 0x90)
			memory.write_byte(AddrTarget + 1, 0x90)
		end
	end)
	menu.toggle(CopModelSettings, "Set Random Cop Models", {}, "", function(toggle)
		RandomModels = toggle
		if not RandomModels then
			HasAppliedRandomModels = false
		end
		if RandomModels then
			SetRandomModels()
			HasAppliedRandomModels = true
		end
	end, RandomModels)
	menu.toggle(CopModelSettings, "Random Models Everytime", {}, "", function(toggle)
		RandomModelsEverytime = toggle
	end, RandomModelsEverytime)
	menu.list_action(CopModelSettings, "Model Presets", {"copmodelpresets"}, "Set all models at once with defined presets.", ModelPresetsT, function(OnChange)
		if OnChange == 1 then
			SetCopModels("dune3", "mp_m_bogdangoon", "caracara", "savage", "csb_bogdan", "mp_m_bogdangoon", "dune3", "technical3")
		end
		if OnChange == 2 then
			SetCopModels("police2", "s_m_y_cop_01", "polgauntlet", "buzzard", "s_m_y_swat_01", "s_m_y_cop_01", "police2", "polgauntlet")
		end
		if OnChange == 3 then
			SetCopModels("tampa3", "s_m_y_cop_01", "speedo4", "buzzard", "s_m_y_swat_01", "s_m_y_cop_01", "tampa3", "speedo4")
		end
		if OnChange == 4 then
			SetCopModels("kamacho", "s_m_y_westsec_02", "hellion", "buzzard", "s_m_m_highsec_03", "s_m_y_westsec_02", "kamacho", "hellion")
		end
		if OnChange == 5 then
			SetCopModels("toros", "hc_gunman", "italigto", "swift", "s_m_y_marine_01", "hc_gunman", "toros", "italigto")
		end
		if OnChange == 6 then
			SetCopModels("hermes", "g_m_m_cartelguards_01", "hotknife", "volatus", "g_m_m_cartelguards_02", "g_m_m_cartelguards_01", "hermes", "hotknife")
		end
		if OnChange == 7 then
			SetCopModels("dominator5", "u_m_y_rsranger_01", "imperator2", "annihilator", "s_m_m_movspace_01", "u_m_y_rsranger_01", "dominator5", "imperator2")
		end
		if OnChange == 8 then
			SetCopModels("hydra", "mp_m_bogdangoon", "hydra", "hydra", "csb_bogdan", "mp_m_bogdangoon", "hydra", "hydra")
		end
		if OnChange == 9 then
			SetCopModels("fbi", "mp_m_fibsec_01", "fbi", "frogger", "mp_m_fibsec_01", "mp_m_fibsec_01", "fib", "fib")
		end
		if OnChange == 10 then
			SetCopModels("police2", "s_m_y_swat_01", "police2", "buzzard", "s_m_y_swat_01", "s_m_y_swat_01", "police2", "police2")
		end
	end)
	local CopOutfitSettingsMenu = menu.list(CopModelSettings, "Cop Outfit Settings", {}, "If cop model is mp_m_freemode_01 or mp_f_freemode_01 then this menu section is usable.")
	menu.toggle(CopOutfitSettingsMenu, "Copy My Outfit To Cop", {}, "", function(toggle)
		CopyPlayerOutfitToCop = toggle
	end, CopyPlayerOutfitToCop)
	local OtherDispatchesModelsMenu = menu.list(CopModelSettings, "Other Dispatches", {}, "")
	local MerryweatherDispatchModelsMenu = menu.list(OtherDispatchesModelsMenu, "Merryweather", {}, "")
	menu.list_select(MerryweatherDispatchModelsMenu, "Mesa3", {"mesa3model"}, "", VehicleModels, 1, function(OnChange)
		for i = 1, #mesa3_Addrs do
			memory.write_int(mesa3_Addrs[i], joaat(VehicleModels[OnChange]))
		end
	end)
	menu.list_select(MerryweatherDispatchModelsMenu, "Blackops Ped", {"blackopspedmodel"}, "", PedModels, 1, function(OnChange)
		for i = 1, #blackopsPed_Addrs do
			memory.write_int(blackopsPed_Addrs[i], joaat(PedModels[OnChange]))
		end
		SelectedPedModels[14] = PedModels[OnChange]
	end)
	--menu.toggle(MerryweatherDispatchModelsMenu, "Random Army", {}, "Will randomize this dispatch models.", function(toggle)
	--	RandomMerryweather = toggle
	--end, RandomMerryweather)
end
local AllyCopSettingsMenu = menu.list(CopSettingsMenu, "Ally Cop Settings", {}, "Which settings apply to ally cops.")
local HostileCopSettingsMenu = menu.list(CopSettingsMenu, "Hostile Cop Settings", {}, "Which settings apply to hostile cops.")
local CopWeaponsMenu = menu.list(CopSettingsMenu, "Cop Weapon Loadout", {}, "Weapons settings for cops.")
local AdvancedSettingsMenu = menu.list(CopSettingsMenu, "Advanced Settings", {}, "")

local CopsAttackEveryone = false
menu.toggle(HostileCopSettingsMenu, "Cops Attack Everyone", {}, "If cops see a player, will start attacking.", function(toggle)
	CopsAttackEveryone = toggle
	RelationshipChanged = true
end, CopsAttackEveryone)

local MakeCopsAttackEveryone = false
menu.toggle(HostileCopSettingsMenu, "Make Cops Attack Everyone", {}, "Cops will attack the nearest player, no need to see the player to start the attack.", function(toggle)
	MakeCopsAttackEveryone = toggle
	RelationshipChanged = true
end, MakeCopsAttackEveryone)

local ZombieMode = false
menu.toggle(HostileCopSettingsMenu, "Zombie Mode", {}, "", function(toggle)
	ZombieMode = toggle
	RelationshipChanged = true
end, ZombieMode)

local SelectedForcedPedWeaponHash = 0
local CopsForcedWeaponList = menu.list_select(CopWeaponsMenu, "Forced Cop Weapon", {"forcedcopweapon"}, "Cops will be forced to use the selected weapon.", WeaponsForCops, 1, function(on_change)
	SelectedForcedPedWeaponHash = joaat(WeaponsForCops[on_change])
end)

local SelectedAutoGivePedWeaponHash = 0
local CopsAutoGiveWeaponList = menu.list_select(CopWeaponsMenu, "Auto Give Cop Weapon", {"autogivecopweapon"}, "Auto give this weapon to cops.", WeaponsForCops, 26, function(on_change)
	SelectedAutoGivePedWeaponHash = joaat(WeaponsForCops[on_change])
end)

local SelectedGiveWeaponType = 4
menu.list_select(CopWeaponsMenu, "Give Weapon Settings", {"giveweaponsettings"}, "Set how cops will get weapons.", GiveWeaponOptions, SelectedGiveWeaponType, function(on_change)
	SelectedGiveWeaponType = on_change
end)

local RandomWeaponComponents = true
menu.toggle(CopWeaponsMenu, "Random Weapon Components", {}, "", function(toggle)
	RandomWeaponComponents = toggle
end, RandomWeaponComponents)

local FlashlightForAllCopWeapons = false
menu.toggle(CopWeaponsMenu, "Flashlight For All Cop Weapons", {}, "", function(toggle)
	FlashlightForAllCopWeapons = toggle
end, FlashlightForAllCopWeapons)

local EnableWeaponSettsForCops = true
menu.toggle(CopWeaponsMenu, "Enable Weapon Settings", {}, "", function(toggle)
	EnableWeaponSettsForCops = toggle
end, EnableWeaponSettsForCops)

local AllowExplosives = false
menu.toggle(CopWeaponsMenu, "Enable Weapon Explosive Guns", {}, "", function(toggle)
	AllowExplosives = toggle
end, AllowExplosives)

local GivePistol = true
menu.toggle(CopWeaponsMenu, "Give Pistol", {}, "", function(toggle)
	GivePistol = toggle
end, GivePistol)

local UseBestWeapon = true
menu.toggle(CopWeaponsMenu, "Use Best Weapon", {}, "", function(toggle)
	UseBestWeapon = toggle
end, UseBestWeapon)

local FirstRemoveWeaps = false
menu.toggle(CopWeaponsMenu, "First Remove Weaps", {}, "", function(toggle)
	FirstRemoveWeaps = toggle
end, FirstRemoveWeaps)

local AutomaticGenCops = true
menu.toggle(CopSettingsMenu, "Automatically Generate Cops", {}, "If this is enabled, wanted level will be set to 5 stars and will set 0 stars when 50 cops is generated.", function(toggle)
	AutomaticGenCops = toggle
end, AutomaticGenCops)

local MaxCopsToEdit = 30
menu.slider(CopSettingsMenu, "Max Cops To Edit", {"maxcopstoedit"}, "Set the max amount of cops to turn into mission entity and edit.", 1, 80, MaxCopsToEdit, 1, function(on_change)
	MaxCopsToEdit = on_change
end)

local MakeCopsAsMissionEntities = true
menu.toggle(AdvancedSettingsMenu, "Make Cops As Mission Entities", {}, "This will make the game generate more cops.", function(toggle)
	MakeCopsAsMissionEntities = toggle
end, MakeCopsAsMissionEntities)

local SetCopsNotMigrateControl = true
menu.toggle(AdvancedSettingsMenu, "Set Cops Not Migrate Control", {}, "To maintain control of cops and not lose control.", function(toggle)
	SetCopsNotMigrateControl = toggle
end, SetCopsNotMigrateControl)

local CopsForMission = true
menu.toggle(AdvancedSettingsMenu, "Edit Normal Cops", {}, "Edit cops with default models.", function(toggle)
	CopsForMission = toggle
end, CopsForMission)

local CopsModelForMission = true
menu.toggle(AdvancedSettingsMenu, "Edit Cops With Different Model", {}, "Edit some other cops with another model.", function(toggle)
	CopsModelForMission = toggle
end, CopsModelForMission)

local AddBlipsForCopsDifferentModel = true
menu.toggle(AdvancedSettingsMenu, "Add Blip For Different Cop Ped Models", {}, "Add red blips for hostile peds or blue blips for ally peds.", function(toggle)
	AddBlipsForCopsDifferentModel = toggle
end, AddBlipsForCopsDifferentModel)

local IgnoreDeadCops = true
menu.toggle(AdvancedSettingsMenu, "Ignore Dead Cops", {}, "Cop count will not consider dead cops, if one dies, another spawns instantly.", function(toggle)
	IgnoreDeadCops = toggle
end, IgnoreDeadCops)

local UpgradeCopCars = true
menu.toggle(CopSettingsMenu, "Upgrade Cop Cars", {}, "Cop cars will have a random upgrade.", function(toggle)
	UpgradeCopCars = toggle
end, UpgradeCopCars)
local IncreaseCopCarSpeed = true
menu.toggle(CopSettingsMenu, "Increase Cop Car Speed 1000x", {}, "Super fast!", function(toggle)
	IncreaseCopCarSpeed = toggle
end, IncreaseCopCarSpeed)

local SetCopCarsColours = true
menu.toggle(CopSettingsMenu, "Set Cop Cars Colours", {}, "Random colors.", function(toggle)
	SetCopCarsColours = toggle
end, SetCopCarsColours)

local PR, PG, PB = 0, 0, 255
local SR, SG, SB = 0, 0, 0
local CopCarDefaultColoursMenu = menu.list(CopSettingsMenu, "Cop Car Default Colours", {}, "Change the color that will be set to all cop vehicles.")
menu.slider(CopCarDefaultColoursMenu, "Primary Red", {"primaryrcolour"}, "", 0, 255, PR, 1, function(OnChange)
	PR = OnChange
end)
menu.slider(CopCarDefaultColoursMenu, "Primary Green", {"primarygcolour"}, "", 0, 255, PG, 1, function(OnChange)
	PG = OnChange
end)
menu.slider(CopCarDefaultColoursMenu, "Primary Blue", {"primarybcolour"}, "", 0, 255, PB, 1, function(OnChange)
	PB = OnChange
end)
menu.slider(CopCarDefaultColoursMenu, "Secondary Red", {"secondaryrcolour"}, "", 0, 255, SR, 1, function(OnChange)
	SR = OnChange
end)
menu.slider(CopCarDefaultColoursMenu, "Secondary Green", {"secondarygcolour"}, "", 0, 255, SG, 1, function(OnChange)
	SG = OnChange
end)
menu.slider(CopCarDefaultColoursMenu, "Secondary Blue", {"secondarybcolour"}, "", 0, 255, SB, 1, function(OnChange)
	SB = OnChange
end)
local SetDefaultColours = false
menu.toggle(CopCarDefaultColoursMenu, "Enable Default Colours", {}, "", function(toggle)
	SetDefaultColours = toggle
end, SetDefaultColours)

local SetCopPassengersIntoTurretSeat = true
menu.toggle(CopSettingsMenu, "Put Cops Into Turret Seats", {}, "", function(toggle)
	SetCopPassengersIntoTurretSeat = toggle
end, SetCopPassengersIntoTurretSeat)

local OnlyEditOwnedCops = false
menu.toggle(AdvancedSettingsMenu, "Only Edit Owned Cops", {}, "", function(toggle)
	OnlyEditOwnedCops = toggle
end, OnlyEditOwnedCops)

local CopAttributesSettingsMenu = menu.list(CopSettingsMenu, "Cop Attributes Settings", {}, "Like HP and whatever.")
local EliteCops = true
menu.toggle(CopAttributesSettingsMenu, "Set Elite Cops", {}, "More HP, no ragdoll and no critical hits.", function(toggle)
	EliteCops = toggle
end, EliteCops)

local StrongCops = true
menu.toggle(CopAttributesSettingsMenu, "Set Strong Cops", {}, "No cover, no LOS to shoot.", function(toggle)
	StrongCops = toggle
end, StrongCops)

local InvincibleCops = false
menu.toggle(CopAttributesSettingsMenu, "Set Invincible Cops", {}, "", function(toggle)
	InvincibleCops = toggle
end, InvincibleCops)

local InvincibleCopVehicles = false
menu.toggle(CopAttributesSettingsMenu, "Set Invincible Cop Vehicles", {}, "", function(toggle)
	InvincibleCopVehicles = toggle
end, InvincibleCopVehicles)

local RushedCops = true
menu.toggle(CopAttributesSettingsMenu, "Maintain Min Distance", {}, "To rush.", function(toggle)
	RushedCops = toggle
end, RushedCops)
local RamMode = false
menu.toggle(CopAttributesSettingsMenu, "Ram Mode", {}, "To crush.", function(toggle)
	RamMode = toggle
end, RamMode)
local ChaseWithNav = false
menu.toggle(CopAttributesSettingsMenu, "Chase using navmesh", {}, "", function(toggle)
	ChaseWithNav = toggle
end, ChaseWithNav)
local ThrowSmokeGrenade = false
menu.toggle(CopAttributesSettingsMenu, "Throw Smoke Grenade", {}, "", function(toggle)
	ThrowSmokeGrenade = toggle
end, ThrowSmokeGrenade)
local InstantAim = true
menu.toggle(CopAttributesSettingsMenu, "Instant Aim", {}, "", function(toggle)
	InstantAim = toggle
end, InstantAim)
local SprintEverytime = false
menu.toggle(CopAttributesSettingsMenu, "Sprint Everytime", {}, "", function(toggle)
	SprintEverytime = toggle
end, SprintEverytime)

local MiscCopSettings = menu.list(CopSettingsMenu, "Misc Settings", {}, "")

local CopsShootCustomBullets = false
menu.toggle(MiscCopSettings, "Cops Shoot Custom Bullet", {}, "Let it more OP.", function(toggle)
	CopsShootCustomBullets = toggle
end, CopsShootCustomBullets)

local CopsInHeliShootMissile = false
menu.toggle(MiscCopSettings, "Cops In Flying Veh Shoot Missile", {}, "", function(toggle)
	CopsInHeliShootMissile = toggle
end, CopsInHeliShootMissile)

local RandomCopComponents = false
menu.toggle(CopSettingsMenu, "Set Cops Random Components", {}, "Outfit.", function(toggle)
	RandomCopComponents = toggle
end, RandomCopComponents)

local RandomCopModelComponents = true
menu.toggle(CopSettingsMenu, "Set Different Cops Random Components", {}, "Outfit.", function(toggle)
	RandomCopModelComponents = toggle
end, RandomCopModelComponents)

local SetNetworkID = true
menu.toggle(AdvancedSettingsMenu, "Set a Network ID", {}, "To maintain control...", function(toggle)
	SetNetworkID = toggle
end, SetNetworkID)

local CopsFollowInVehTask = true
menu.toggle(AllyCopSettingsMenu, "All Cops In Veh Follow You", {}, "", function(toggle)
	CopsFollowInVehTask = toggle
end, CopsFollowInVehTask)

local CopsFollowTask = true
menu.toggle(AllyCopSettingsMenu, "All Cops Follow You", {}, "", function(toggle)
	CopsFollowTask = toggle
end, CopsFollowTask)

local CopsFollowAsBodyguard = false
menu.toggle(AllyCopSettingsMenu, "Cops Follow As Bodyguard", {}, "", function(toggle)
	CopsFollowAsBodyguard = toggle
end, CopsFollowAsBodyguard)

local BringFarCopsCloser = true
menu.toggle(AllyCopSettingsMenu, "Auto Bring Far Cops Back To You", {}, "", function(toggle)
	BringFarCopsCloser = toggle
end, BringFarCopsCloser)
local TPCopsBackToVehicle = true
menu.toggle(AllyCopSettingsMenu, "TP Cops Back To Their Vehicle", {}, "Works if cops are mission entities, and the cops will be back to their vehicle case if you're in vehicle.", function(toggle)
	TPCopsBackToVehicle = toggle
end, TPCopsBackToVehicle)
local AlwaysTPCopsBackToVehicle = true
menu.toggle(AllyCopSettingsMenu, "Always TP Cops Back To Their Vehicle", {}, "Works if cops are mission entities.", function(toggle)
	AlwaysTPCopsBackToVehicle = toggle
end, AlwaysTPCopsBackToVehicle)

local BringIfOutsideOfVehicle = false
menu.toggle(AllyCopSettingsMenu, "Bring If Im Outside Vehicle", {}, "", function(toggle)
	BringIfOutsideOfVehicle = toggle
end, BringIfOutsideOfVehicle)

local CopsCanAttackPlayers = false
menu.toggle(AllyCopSettingsMenu, "Cops Can Attack Players", {}, "", function(toggle)
	CopsCanAttackPlayers = toggle
	RelationshipChanged = true
end, CopsCanAttackPlayers)

local CopsCanAttackPlayersV2 = false
menu.toggle(AllyCopSettingsMenu, "Cops Can Attack Players V2", {}, "", function(toggle)
	CopsCanAttackPlayersV2 = toggle
	RelationshipChanged = true
end, CopsCanAttackPlayersV2)

local AvoidAttackingFriends = true
menu.toggle(AllyCopSettingsMenu, "Avoid Attacking Friends", {}, "Automatically will avoid attacking people of your CEO or Biker Club.", function(toggle)
	AvoidAttackingFriends = toggle
	RelationshipChanged = true
end, AvoidAttackingFriends)

local AvoidAttackSpeficPlayers = false
menu.toggle(AllyCopSettingsMenu, "Avoid Attacking Specific Players", {}, "Works with avoiding attack friends toggled.", function(toggle)
	AvoidAttackSpeficPlayers = toggle
	RelationshipChanged = true
end, AvoidAttackSpeficPlayers)

local PlayersToAvoidAttackT = {}
local PlayersToAvoidAttackMenu = menu.list(AllyCopSettingsMenu, "Which Players Avoid Attack", {}, "Select players to avoid the attack.", function()UpdatePlayersList()end, function()UpdatePlayersList()end)

local AvoidPlayerBits = 0
for i = 1, 30 do
    if PlayersToAvoidAttackT[i] == nil then
		local PlayerID = PLAYER.PLAYER_ID()
        local PlayerName = "---"
        if NETWORK.NETWORK_IS_PLAYER_ACTIVE(i-1) then
            PlayerName = PLAYER.GET_PLAYER_NAME(i-1)
        end
        PlayersToAvoidAttackT[i] = {}
        PlayersToAvoidAttackT[i].Include = PlayerID+1 == i
        PlayersToAvoidAttackT[i].MenuPTR = menu.toggle(PlayersToAvoidAttackMenu, PlayerName, {}, "", function(OnChange)
			PlayersToAvoidAttackT[i].Include = OnChange
			if PlayersToAvoidAttackT[i].Include == true then
				SetBitsToAvoidAttackPlayers(i)
			else
				SetBitsToAvoidAttackPlayers(i)
			end
			RelationshipChanged = true
		end, PlayersToAvoidAttackT[i].Include)
    end
end

function UpdatePlayersList()
    for i = 1, 30 do
        if PlayersToAvoidAttackT[i] ~= nil then
            local PlayerName = "---"
            if NETWORK.NETWORK_IS_PLAYER_ACTIVE(i-1) then
                PlayerName = PLAYER.GET_PLAYER_NAME(i-1)
            end
            menu.set_menu_name(PlayersToAvoidAttackT[i].MenuPTR, PlayerName)
        end
    end
end

function SetBitsToAvoidAttackPlayers(Bit)
	if not is_bit_set(AvoidPlayerBits, Bit) then
		AvoidPlayerBits = set_bit(AvoidPlayerBits, Bit)
	else
		AvoidPlayerBits = clear_bit(AvoidPlayerBits, Bit)
	end
end

players.on_leave(function(CallBack)
	if is_bit_set(AvoidPlayerBits, CallBack + 1) then
		AvoidPlayerBits = clear_bit(AvoidPlayerBits, CallBack + 1)
		menu.set_value(PlayersToAvoidAttackT[CallBack + 1].MenuPTR, false)
	end
end)

local AddBlipsForAllyCops = true
menu.toggle(AllyCopSettingsMenu, "Add Blip For Ally Cops", {}, "", function(toggle)
	AddBlipsForAllyCops = toggle
end, AddBlipsForAllyCops)

local RemoveCopsFromVeh = false
menu.toggle(AllyCopSettingsMenu, "Remove Cops From Vehicle", {}, "", function(toggle)
	RemoveCopsFromVeh = toggle
end, RemoveCopsFromVeh)
local TPIfImInAInterior = false
menu.toggle(AllyCopSettingsMenu, "TP Cops To Me If Interior", {}, "", function(toggle)
	TPIfImInAInterior = toggle
end, TPIfImInAInterior)

local PutCopsIntoPlayerVeh = false
menu.toggle(AllyCopSettingsMenu, "Put Cops Into Your Vehicle", {}, "", function(toggle)
	PutCopsIntoPlayerVeh = toggle
end, PutCopsIntoPlayerVeh)
local AllyAttacksHostiles = false
menu.toggle(AllyCopSettingsMenu, "Auto Attack Hostile Peds", {}, "", function(toggle)
	AllyAttacksHostiles = toggle
end, AllyAttacksHostiles)
local DistanceNeededToAttack = 100.0
menu.slider_float(AllyCopSettingsMenu, "Needed Range To Attack", {"autoattackrange"}, "Distance needed between peds to start the attack.", 10000, 1000000, 10000, 1000, function(OnChange)
	DistanceNeededToAttack = OnChange / 100
end)
local SetAllyPedHateToAiHate = true
menu.toggle(AllyCopSettingsMenu, "Set Ally Ped Hate To Ai Enemy", {}, "Made for missions, if ally sees a enemy ped, will attack.", function(toggle)
	SetAllyPedHateToAiHate = toggle
end, SetAllyPedHateToAiHate)
local UseCustomsTasksKeys = true
menu.toggle(AllyCopSettingsMenu, "Set Custom Tasks To Use With Keys", {}, "A menu with commands will appear and you will be able to leade cops.", function(toggle)
	UseCustomsTasksKeys = toggle
end, UseCustomsTasksKeys)
local CopsRushToNearestTarget = true
menu.toggle(AllyCopSettingsMenu, "Cops Rush To Nearest Enemy", {}, "Works with custom tasks keys.", function(toggle)
	CopsRushToNearestTarget = toggle
end, CopsRushToNearestTarget)
menu.toggle(AllyCopSettingsMenu, "Cops Switch To Nearest Target", {}, "Devastation.", function(toggle)
	CopsSwitchToNearestTarget = toggle
end, CopsSwitchToNearestTarget)
local CopsRushWithTP = false
menu.toggle(AllyCopSettingsMenu, "Cops Rush With Teleport", {}, "", function(toggle)
	CopsRushWithTP = toggle
end, CopsRushWithTP)
menu.toggle(AllyCopSettingsMenu, "Set Cops Aim At Head", {}, "One hit kill.", function(toggle)
	CopsAimAtHead = toggle
end, CopsAimAtHead)
local ControlVehicle = false
menu.toggle(AllyCopSettingsMenu, "Control Vehicle Being Passenger", {}, "Useful for using turrets.", function(toggle)
	ControlVehicle = toggle
end, ControlVehicle)

local MiscCustomTasksMenu = menu.list(AllyCopSettingsMenu, "Misc Custom Behaviour", {}, "")
local CopsShootWhereYouShoot = false
menu.toggle(MiscCustomTasksMenu, "Cops Shoot Where You Shoot", {}, "", function(toggle)
	CopsShootWhereYouShoot = toggle
end, CopsShootWhereYouShoot)
local CopsShootWhereYouAim = false
menu.toggle(MiscCustomTasksMenu, "Cops Shoot Where You Aim", {}, "", function(toggle)
	CopsShootWhereYouAim = toggle
end, CopsShootWhereYouAim)
menu.toggle(MiscCustomTasksMenu, "Cops Rushed Follow", {}, "", function(toggle)
	CopsRushedFollow = toggle
end, CopsRushedFollow)
local CopsFollowLikeSnake = false
menu.toggle(MiscCustomTasksMenu, "Cops Follow Like Snake", {}, "", function(toggle)
	CopsFollowLikeSnake = toggle
end, CopsFollowLikeSnake)
local CopsFollowLikeSnake2 = false
menu.toggle(MiscCustomTasksMenu, "Cops Follow Like Snake 2", {}, "", function(toggle)
	CopsFollowLikeSnake2 = toggle
end, CopsFollowLikeSnake2)
local SetDefensiveSphereToPlayer = false
menu.toggle(MiscCustomTasksMenu, "Set Defensive Sphere To Player", {}, "", function(toggle)
	SetDefensiveSphereToPlayer = toggle
end, SetDefensiveSphereToPlayer)
--menu.list_select(AllyCopSettingsMenu, "Cop Relationship Type", {"allycoprelationship"}, "Set if cops will be able to attack players or only npcs.", table<int, table> options, 1, function on_change)

local CopsForcedBeingNearSphere = false
menu.toggle(AllyCopSettingsMenu, "Cops Forced Being Near Sphere", {}, "Cops will be bringed to near player with velocity.", function(toggle)
	CopsForcedBeingNearSphere = toggle
end, CopsForcedBeingNearSphere)

local CopsHelpInMissions = false
menu.toggle(AllyCopSettingsMenu, "Cops Help In Missions", {}, "Disable Use Custom Tasks Keys to Work. Help into supported missions.", function(toggle)
	CopsHelpInMissions = toggle
end, CopsHelpInMissions)

local GlobalCopCount = 0
local ArmySpawnerMenu = menu.list(menu.my_root(), "Army Spawner", {}, "Use with Apply Cop Settings on.")
menu.action(ArmySpawnerMenu, "Spawn Bikers", {}, "", function(toggle)
	local PedModel = joaat("g_m_y_lost_01")
	local VehModel = joaat("avarus")
	while not RequestModelFunc(PedModel) or not RequestModelFunc(VehModel) do
		Wait()
	end
	local PlayerPed = PLAYER.PLAYER_PED_ID()
	local Pos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
	local CamRot = CAM.GET_GAMEPLAY_CAM_ROT(2)
	local CamRotInst = CAM.GET_GAMEPLAY_CAM_ROT(2)
	--CamRot.z = CamRot.z - 180.0
	local Dir = CamRot:toDir()
	local JumpOffset = 4.0
	local Amount = 10
	for k = 1, Amount do
		if GlobalCopCount < MaxCopsToEdit then
			local V3 = v3.new(Pos.x + Dir.x * JumpOffset * k, Pos.y + Dir.y * JumpOffset * k, Pos.z + 1.0)
			--if not MISC.IS_POSITION_OCCUPIED(V3.x, V3.y, V3.z, 1.0, false, true, --[[Ped]] false, false, false, 0, true) then
				local Veh = VEHICLE.CREATE_VEHICLE(VehModel, V3.x, V3.y, V3.z, CamRotInst.z, true, true, true)
				local Ped = PED.CREATE_PED(6, PedModel, V3.x, V3.y, V3.z, CamRotInst.z, true, true)
				PED.SET_PED_INTO_VEHICLE(Ped, Veh, -1)
				PED.SET_PED_RELATIONSHIP_GROUP_HASH(Ped, joaat("COP"))
				local EntAddr = entities.handle_to_pointer(Veh) + 0xD8
				if EntAddr ~= 0 then
					memory.write_int(EntAddr, 329858)-- 329858)
				end
				local EntAddr = entities.handle_to_pointer(Ped) + 0xD8
				if EntAddr ~= 0 then
					--Print(memory.read_int(Addr))
					--util.copy_to_clipboard(memory.read_int(Addr))
					memory.write_int(EntAddr, 329858)-- 329858)
				end
				PED.SET_PED_AS_COP(Ped, true)
				GlobalCopCount = GlobalCopCount + 1
			--end
		end
	end
	STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(PedModel)
	STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(VehModel)
end)

local RenderCopCount = true
menu.toggle(menu.my_root(), "Show Cop Count HUD", {}, "", function(toggle)
	RenderCopCount = toggle
end, RenderCopCount)

local CopsAreAllies = true
menu.toggle(menu.my_root(), "Make Cops As Allies", {}, "", function(toggle)
	CopsAreAllies = toggle
	RelationshipChanged = true
end, CopsAreAllies)

local ExperimentalFeaturesMenu = menu.list(CopSettingsMenu, "Experimental Features", {}, "")
local TryNetworkCopsBlips = false
menu.toggle(ExperimentalFeaturesMenu, "Network Cops Blips", {}, "Not only you will see the blips.", function(toggle)
	TryNetworkCopsBlips = toggle
end, TryNetworkCopsBlips)

local OtherDispatchesMenu = menu.list(CopSettingsMenu, "Other Distpaches", {}, "")
local MerryweatherDispatchMenu = menu.list(OtherDispatchesMenu, "Merryweather", {}, "")
local EditMerryweather = false
menu.toggle(MerryweatherDispatchMenu, "Edit Merryweather", {}, "", function(toggle)
	EditMerryweather = toggle
	if EditMerryweather then
		if SelectedPedModels[14] == nil then
			SelectedPedModels[14] = "s_m_y_blackops_01"
		end
	else
		SelectedPedModels[14] = nil
	end
end, EditMerryweather)
local DispatchesEnum = {"Merryweather"}
local DispatchesNum = {14}

local SelectedDispatch = 14
menu.list_select(OtherDispatchesMenu, "Call Which Dispatch", {"callwhichdispatch"}, "", DispatchesEnum, 1, function(on_change)
	SelectedDispatch = DispatchesNum[on_change]
end)
local DispatchUnits = 40
menu.slider(OtherDispatchesMenu, "Dispatch Units", {"dispatchunits"}, "How much units the dispatch will create.", 1, 80, DispatchUnits, 1, function(on_change)
	DispatchUnits = on_change
end)
local IncidentIndex = 0
local CallDispatch = false
menu.toggle(OtherDispatchesMenu, "Call Dispatch", {}, "", function(toggle)
	CallDispatch = toggle
	if CallDispatch then
		local IncidentAddr = memory.alloc(8)
		local Entity = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID())
		local Pos = ENTITY.GET_ENTITY_COORDS(Entity)
		local DispatchID = SelectedDispatch
		local RelHash = 0 --joaat(AiLikeRel)
		local Sucess = MISC.CREATE_INCIDENT_WITH_ENTITY(DispatchID, Entity, DispatchUnits, 0.0, IncidentAddr, RelHash, 1)
		if Sucess then
			local IncidentID = memory.read_int(IncidentAddr)
			IncidentIndex = IncidentID
			Print("Dispatch called sucess.")
		else
			Print("Failed calling dispatch.")
		end
	else
		if IncidentIndex ~= 0 then
			if MISC.IS_INCIDENT_VALID(IncidentIndex) then
				MISC.DELETE_INCIDENT(IncidentIndex)
			end
			IncidentIndex = 0
		end
	end
end, CallDispatch)
local AutomaticCallDispatch = false
menu.toggle(OtherDispatchesMenu, "Auto Call Dispatch", {}, "Will call dispatch until reach the amount of cops set.", function(toggle)
	AutomaticCallDispatch = toggle
	if SelectedPedModels[14] == nil then
		SelectedPedModels[14] = "s_m_y_blackops_01"
	end
end)
local CopCustomRelMenu = menu.list(CopSettingsMenu, "Custom Relationship Settings", {}, "For DEVs.")

local KnownCustomRelationships = {
	"relRescueContactPlayer",
	"relAssetBurner",
	"relHeadHunterPlayer"
}

local CustomRelText = "relRescueContactPlayer"

menu.list_select(CopCustomRelMenu, "Known Custom Rels", {"setknowncustomrel"}, "Known custom relationships list.", KnownCustomRelationships, 1, function(on_change)
	CustomRelText = joaat(KnownCustomRelationships[on_change])
end)

local CopsCustomRelationship = false
menu.toggle(CopCustomRelMenu, "Set Cops Custom Relationship", {}, "", function(toggle)
	CopsCustomRelationship = toggle
	RelationshipChanged = true
end, CopsCustomRelationship)

menu.text_input(CopCustomRelMenu, "Custom Relationship Name", {"copcustomrelationship"}, "Write a missing custom relationship name to set.", function(on_change)
	CustomRelText = on_change
	RelationshipChanged = true
end)

local SetCopsMyRelationship = false
menu.toggle(CopCustomRelMenu, "Set To My Relationship", {}, "", function(toggle)
	SetCopsMyRelationship = toggle
	RelationshipChanged = true
end, SetCopsMyRelationship)
local SelectedTaskTXT = {
	{TXT = "Everyone crouch near", ColourG = 255, Task = 1},
	{TXT = "Follow in formation", ColourG = 255, Task = 12},
	{TXT = "Make half go to pointed area", ColourG = 255, Task = 5},
	{TXT = "TP all cops to me", ColourG = 255, Task = 10},
	{TXT = "Call to enter my vehicle", ColourG = 255, Task = 3},
	{TXT = "Call to exit my vehicle", ColourG = 255, Task = 4},
	{TXT = "Closer cops exit vehicle", ColourG = 255, Task = 6},
	{TXT = "Call to stay above veh", ColourG = 255, Task = 8},
	{TXT = "Attack nearest ped in screen", ColourG = 255, Task = 7},
	{TXT = "Mega rush mode", ColourG = 255, Task = 2},
	{TXT = "Rushed combat mode", ColourG = 255, Task = 9},
	{TXT = "Super rushed combat mode", ColourG = 255, Task = 11},
	{TXT = "Go straight to coord", ColourG = 255, Task = 13}
}
local AvailableTasks = {
	1, 5, 10, 3, 4, 6, 8, 7, 9, 11, 2, 13
}

local CustomTasksFunctions = {
	function(Args, PlayerPed, TableT, HitCoords, FVect, RVect, UpVect, Vect)
		if Args.OperationButton then
			Args.OperationHeading = ENTITY.GET_ENTITY_HEADING(PlayerPed)
			Args.OperationStatus = 0
			Args.OperationSide = 0
			Args.OperationOffset = 1.0
			ENTITY.GET_ENTITY_MATRIX(PlayerPed, FVect, RVect, UpVect, Vect)
			TableT[1] = TableT[1] + 1
		end
		if TableT[1] == 1 then
			SelectedTaskTXT[1].ColourG = 20
		else
			SelectedTaskTXT[1].ColourG = 255
		end
		if Args.HitCoords == nil then
			local IsAiming = CAM.IS_AIM_CAM_ACTIVE()
			if IsAiming then
				Args.HitCoords = RaycastFromCamera(PlayerPed, 1000.0)
			end
			Args.HasHit = Args.IsPlayerShooting
		end
	end,
	function(Args, PlayerPed, TableT, HitCoords, FVect, RVect, UpVect, Vect)
		if Args.OperationButton then
			TableT[2] = TableT[2] + 1
		end
		if TableT[2] == 1 then
			SelectedTaskTXT[2].ColourG = 20
		else
			SelectedTaskTXT[2].ColourG = 255
		end
	end,
	function(Args, PlayerPed, TableT, HitCoords, FVect, RVect, UpVect, Vect)
		if Args.OperationButton then
			Args.SeatsFilled = 0
			TableT[3] = 1
		end
		if TableT[3] == 1 then
			SelectedTaskTXT[3].ColourG = 20
			TableT[3] = 0
		else
			SelectedTaskTXT[3].ColourG = 255
		end
	end,
	function(Args, PlayerPed, TableT, HitCoords, FVect, RVect, UpVect, Vect)
		if Args.OperationButton then
			TableT[4] = 1
		end
		if TableT[4] == 1 then
			SelectedTaskTXT[4].ColourG = 20
			TableT[4] = 0
		else
			SelectedTaskTXT[4].ColourG = 255
		end
	end,
	function(Args, PlayerPed, TableT, HitCoords, FVect, RVect, UpVect, Vect)
		if Args.OperationButton then
			TableT[5] = 1
			Args.HitCoords, Args.HasHit = RaycastFromCamera(PlayerPed, 1000.0)
		end
		if TableT[5] == 1 then
			SelectedTaskTXT[5].ColourG = 20
			TableT[5] = 0
		else
			SelectedTaskTXT[5].ColourG = 255
		end
	end,
	function(Args, PlayerPed, TableT, HitCoords, FVect, RVect, UpVect, Vect)
		if Args.OperationButton then
			TableT[6] = 1
		end
		if TableT[6] == 1 then
			SelectedTaskTXT[6].ColourG = 20
			TableT[6] = 0
		else
			SelectedTaskTXT[6].ColourG = 255
		end
	end,
	function(Args, PlayerPed, TableT, HitCoords, FVect, RVect, UpVect, Vect)
		if Args.OperationButton then
			TableT[7] = 1
			local PedsT = entities.get_all_peds_as_handles()
			local ClosestPeds = {}
			local PlayerPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
			for index, peds in pairs(PedsT) do
				if peds ~= PlayerPed then
					if not ENTITY.IS_ENTITY_DEAD(peds) then
						if not PED.IS_PED_DEAD_OR_DYING(peds, true) then
							if ENTITY.IS_ENTITY_ON_SCREEN(peds) then
								if not DECORATOR.DECOR_EXIST_ON(peds, "Casino_Game_Info_Decorator") then
									local TargetRelHash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(peds)
									if PED.GET_RELATIONSHIP_BETWEEN_GROUPS(Args.RelHash, TargetRelHash) ~= 1 then
										local PedCoords = ENTITY.GET_ENTITY_COORDS(peds)
										local Distance = MISC.GET_DISTANCE_BETWEEN_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z, PedCoords.x, PedCoords.y, PedCoords.z, true)
										ClosestPeds[#ClosestPeds+1] = {Handle = peds, Distance = Distance}
									end
								end
							end
						end
					end
				end
			end
			local ClosestDist = 10000.0
			local ClosestHandle = 0
			for i = 1, #ClosestPeds do
				if ClosestPeds[i].Distance < ClosestDist then
					ClosestDist = ClosestPeds[i].Distance
					ClosestHandle = ClosestPeds[i].Handle
				end
			end
			Args.TargetPed = ClosestHandle
		end
		if TableT[7] == 1 then
			SelectedTaskTXT[7].ColourG = 20
			TableT[7] = 0
		else
			SelectedTaskTXT[7].ColourG = 255
		end
	end,
	function(Args, PlayerPed, TableT, HitCoords, FVect, RVect, UpVect, Vect)
		if Args.OperationButton then
			TableT[8] = TableT[8] + 1
			Args.OffsetsAttach = nil
			Args.RotsAttach = nil
			Args.AttachedNum = 0
			Args.MaxAttachs = 0
			local FoundModel = false
			local PlayerVeh = PED.GET_VEHICLE_PED_IS_IN(PlayerPed, true)
			if PlayerVeh ~= 0 then
				local Model = ENTITY.GET_ENTITY_MODEL(PlayerVeh)
				for i = 1, #SupportedVehiclesAttachs do
					if Model == joaat(SupportedVehiclesAttachs[i].Model) then
						Args.OffsetsAttach = SupportedVehiclesAttachs[i].Offsets
						Args.RotsAttach = SupportedVehiclesAttachs[i].Rotation
						Args.MaxAttachs = SupportedVehiclesAttachs[i].FoundNum
						FoundModel = true
						break
					end
				end
				if not FoundModel then
					local Min, Max = v3.new(), v3.new()
					MISC.GET_MODEL_DIMENSIONS(Model, Min, Max)
					local Class = VEHICLE.GET_VEHICLE_CLASS(PlayerVeh)
					if Class == 15 then
						Max.z = Min.z + 1.75
					end
					Args.OffsetsAttach = {}
					Args.RotsAttach = {}
					for i = 1, 15 do
						Args.OffsetsAttach[#Args.OffsetsAttach+1] = {x = 1.5, y = 0.5 * i, z = Max.z}-- * 2.0}
						Args.RotsAttach[#Args.RotsAttach+1] = {x = 0.0, y = 0.0, z = -90.0}
						Args.MaxAttachs = Args.MaxAttachs + 1
						Args.OffsetsAttach[#Args.OffsetsAttach+1] = {x = -1.5, y = 0.5 * i, z = Max.z}-- * 2.0}
						Args.RotsAttach[#Args.RotsAttach+1] = {x = 0.0, y = 0.0, z = 90.0}
						Args.MaxAttachs = Args.MaxAttachs + 1
						Args.OffsetsAttach[#Args.OffsetsAttach+1] = {x = 1.5, y = -0.5 * i, z = Max.z}-- * 2.0}
						Args.RotsAttach[#Args.RotsAttach+1] = {x = 0.0, y = 0.0, z = -90.0}
						Args.MaxAttachs = Args.MaxAttachs + 1
						Args.OffsetsAttach[#Args.OffsetsAttach+1] = {x = -1.5, y = -0.5 * i, z = Max.z}-- * 2.0}
						Args.RotsAttach[#Args.RotsAttach+1] = {x = 0.0, y = 0.0, z = 90.0}
						Args.MaxAttachs = Args.MaxAttachs + 1
					end
				end
			end
		end
		if TableT[8] == 1 then
			SelectedTaskTXT[8].ColourG = 20
		else
			SelectedTaskTXT[8].ColourG = 255
		end
	end,
	function(Args, PlayerPed, TableT, HitCoords, FVect, RVect, UpVect, Vect)
		if Args.OperationButton then
			TableT[9] = TableT[9] + 1
		end
		if TableT[9] == 1 then
			SelectedTaskTXT[9].ColourG = 20
		else
			SelectedTaskTXT[9].ColourG = 255
		end
	end,
	function(Args, PlayerPed, TableT, HitCoords, FVect, RVect, UpVect, Vect)
		if Args.OperationButton then
			TableT[10] = 1
		end
		if TableT[10] == 1 then
			SelectedTaskTXT[10].ColourG = 20
			TableT[10] = 0
		else
			SelectedTaskTXT[10].ColourG = 255
		end
	end,
	function(Args, PlayerPed, TableT, HitCoords, FVect, RVect, UpVect, Vect)
		if Args.OperationButton then
			TableT[11] = TableT[11] + 1
		end
		if TableT[11] == 1 then
			SelectedTaskTXT[11].ColourG = 20
		else
			SelectedTaskTXT[11].ColourG = 255
		end
	end,
	function(Args, PlayerPed, TableT, HitCoords, FVect, RVect, UpVect, Vect)
		if Args.OperationButton then
			TableT[12] = TableT[12] + 1
		end
		if TableT[12] == 1 then
			SelectedTaskTXT[12].ColourG = 20
			Args.OperationHeading = ENTITY.GET_ENTITY_HEADING(PlayerPed)
			Args.OperationStatus = 0
			Args.OperationSide = 0
			Args.OperationOffset = 1.0
			Args.IsAiming = CAM.IS_AIM_CAM_ACTIVE()
			ENTITY.GET_ENTITY_MATRIX(PlayerPed, FVect, RVect, UpVect, Vect)
			if Args.HitCoords == nil then
				Args.HitCoords = RaycastFromCamera(PlayerPed, 1000.0)
				Args.HasHit = Args.IsPlayerShooting
			end
			Args.FVect = FVect
			Args.RVect = RVect
			Args.UpVect = UpVect
			Args.Vect = Vect
			Args.PlayerCoords = Vect
		else
			SelectedTaskTXT[12].ColourG = 255
			Args.IsAiming = false
		end
	end,
	function(Args, PlayerPed, TableT, HitCoords, FVect, RVect, UpVect, Vect)
		if Args.OperationButton then
			TableT[13] = 1
		end
		if TableT[13] == 1 then
			SelectedTaskTXT[13].ColourG = 20
			TableT[13] = 0
		else
			SelectedTaskTXT[13].ColourG = 255
		end
		if Args.HitCoords == nil then
			Args.HitCoords = RaycastFromCamera(PlayerPed, 1000.0)
			Args.HasHit = Args.IsPlayerShooting
		end
	end,
}

local CustomTasksArgsFunctions = {
	function(Args, OperationsTable, OperationT, peds, Veh, FVect, RVect, UpVect, Vect)
		if Args.OperationButton and OperationsTable[1] < 2 then
			local TaskToSet = 0
			local IsPilot = false
			if Veh ~= 0 then
				local VehClass = VEHICLE.GET_VEHICLE_CLASS(Veh)
				local IsAircraft = VehClass == 15 or VehClass == 16
				local Ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false)
				if IsAircraft then
					if VehClass == 15 then
						if VEHICLE.DOES_VEHICLE_ALLOW_RAPPEL(Veh) then
							if Ped == peds and VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, 0, false) == 0 then
								TaskToSet = 6
							else
								TaskToSet = 10
							end
						end
					else
						TaskToSet = 12
					end
				else
					TaskToSet = 4
				end
				if Ped == peds then
					IsPilot = true
				end
			end
			OperationT[peds] = {
				Handle = peds, XOffset = 0.0, YOffset = Args.OperationStatus,
				X = 0.0, Y = 0.0, Z = 0.0, Heading = Args.OperationHeading,
				TaskStatus = TaskToSet, VehHandle = Veh, FVect = FVect, RVect = RVect, UpVect = UpVect,
				Vect = Vect, IsPilot = IsPilot
			}
		end
	end,
	function(Args, OperationsTable, OperationT, peds, Veh, FVect, RVect, UpVect, Vect)
		if OperationsTable[2] < 2 then
			if Args.OperationButton then
				local IsPilot = false
				if Veh ~= 0 then
					IsPilot = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds
				end
				OperationT[peds] = {
					Handle = peds, XOffset = 0.0, YOffset = 0,
					X = 0.0, Y = 0.0, Z = 0.0, Heading = 0,
					TaskStatus = 12, VehHandle = Veh, FVect = FVect, RVect = RVect, UpVect = UpVect,
					Vect = Vect, IsPilot = IsPilot
				}
			end
		end
	end,
	function(Args, OperationsTable, OperationT, peds, Veh, FVect, RVect, UpVect, Vect)
		if OperationsTable[3] < 2 then
			if Args.OperationButton then
				local IsPilot = false
				if Veh ~= 0 then
					IsPilot = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds
				end
				OperationT[peds] = {
					Handle = peds, XOffset = 0.0, YOffset = 0,
					X = 0.0, Y = 0.0, Z = 0.0, Heading = 0,
					TaskStatus = 15, VehHandle = Veh, FVect = FVect, RVect = RVect, UpVect = UpVect,
					Vect = Vect, IsPilot = IsPilot
				}
			end
		end
	end,
	function(Args, OperationsTable, OperationT, peds, Veh, FVect, RVect, UpVect, Vect)
		if OperationsTable[4] < 2 then
			if Args.OperationButton then
				local IsPilot = false
				if Veh ~= 0 then
					IsPilot = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds
				end
				OperationT[peds] = {
					Handle = peds, XOffset = 0.0, YOffset = 0,
					X = 0.0, Y = 0.0, Z = 0.0, Heading = 0,
					TaskStatus = 18, VehHandle = Veh, FVect = FVect, RVect = RVect, UpVect = UpVect,
					Vect = Vect, IsPilot = IsPilot
				}
			end
		end
	end,
	function(Args, OperationsTable, OperationT, peds, Veh, FVect, RVect, UpVect, Vect)
		if OperationsTable[5] < 2 then
			if Args.OperationButton then
				local IsPilot = false
				if Veh ~= 0 then
					IsPilot = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds
				end
				OperationT[peds] = {
					Handle = peds, XOffset = 0.0, YOffset = 0,
					X = 0.0, Y = 0.0, Z = 0.0, Heading = 0,
					TaskStatus = 19, VehHandle = Veh, FVect = FVect, RVect = RVect, UpVect = UpVect,
					Vect = Vect, IsPilot = IsPilot
				}
			end
		end
	end,
	function(Args, OperationsTable, OperationT, peds, Veh, FVect, RVect, UpVect, Vect)
		if OperationsTable[6] < 2 then
			if Args.OperationButton then
				local IsPilot = false
				if Veh ~= 0 then
					IsPilot = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds
				end
				OperationT[peds] = {
					Handle = peds, XOffset = 0.0, YOffset = 0,
					X = 0.0, Y = 0.0, Z = 0.0, Heading = 0,
					TaskStatus = 21, VehHandle = Veh, FVect = FVect, RVect = RVect, UpVect = UpVect,
					Vect = Vect, IsPilot = IsPilot
				}
			end
		end
	end,
	function(Args, OperationsTable, OperationT, peds, Veh, FVect, RVect, UpVect, Vect)
		if OperationsTable[7] < 2 then
			if Args.OperationButton then
				local IsPilot = false
				if Veh ~= 0 then
					IsPilot = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds
				end
				OperationT[peds] = {
					Handle = peds, XOffset = 0.0, YOffset = 0,
					X = 0.0, Y = 0.0, Z = 0.0, Heading = 0,
					TaskStatus = 23, VehHandle = Veh, FVect = FVect, RVect = RVect, UpVect = UpVect,
					Vect = Vect, IsPilot = IsPilot
				}
			end
		end
	end,
	function(Args, OperationsTable, OperationT, peds, Veh, FVect, RVect, UpVect, Vect)
		if OperationsTable[8] < 2 then
			if Args.OperationButton then
				local IsPilot = false
				if Veh ~= 0 then
					IsPilot = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds
				end
				OperationT[peds] = {
					Handle = peds, XOffset = 0.0, YOffset = 0,
					X = 0.0, Y = 0.0, Z = 0.0, Heading = 0,
					TaskStatus = 24, VehHandle = Veh, FVect = FVect, RVect = RVect, UpVect = UpVect,
					Vect = Vect, IsPilot = IsPilot
				}
			end
		end
	end,
	function(Args, OperationsTable, OperationT, peds, Veh, FVect, RVect, UpVect, Vect)
		if OperationsTable[9] < 2 then
			if Args.OperationButton then
				local IsPilot = false
				if Veh ~= 0 then
					IsPilot = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds
				end
				OperationT[peds] = {
					Handle = peds, XOffset = 0.0, YOffset = 0,
					X = 0.0, Y = 0.0, Z = 0.0, Heading = 0,
					TaskStatus = 25, VehHandle = Veh, FVect = FVect, RVect = RVect, UpVect = UpVect,
					Vect = Vect, IsPilot = IsPilot
				}
			end
		end
	end,
	function(Args, OperationsTable, OperationT, peds, Veh, FVect, RVect, UpVect, Vect)
		if OperationsTable[10] < 2 then
			if Args.OperationButton then
				local IsPilot = false
				if Veh ~= 0 then
					IsPilot = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds
				end
				OperationT[peds] = {
					Handle = peds, XOffset = 0.0, YOffset = 0,
					X = 0.0, Y = 0.0, Z = 0.0, Heading = 0,
					TaskStatus = 27, VehHandle = Veh, FVect = FVect, RVect = RVect, UpVect = UpVect,
					Vect = Vect, IsPilot = IsPilot
				}
			end
		end
	end,
	function(Args, OperationsTable, OperationT, peds, Veh, FVect, RVect, UpVect, Vect)
		if OperationsTable[11] < 2 then
			if Args.OperationButton then
				local IsPilot = false
				if Veh ~= 0 then
					IsPilot = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds
				end
				OperationT[peds] = {
					Handle = peds, XOffset = 0.0, YOffset = 0,
					X = 0.0, Y = 0.0, Z = 0.0, Heading = 0,
					TaskStatus = 28, VehHandle = Veh, FVect = FVect, RVect = RVect, UpVect = UpVect,
					Vect = Vect, IsPilot = IsPilot
				}
			end
		end
	end,
	function(Args, OperationsTable, OperationT, peds, Veh, FVect, RVect, UpVect, Vect)
		if OperationsTable[12] < 2 then
			if Args.OperationButton then
				local IsPilot = false
				if Veh ~= 0 then
					IsPilot = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds
				end
				OperationT[peds] = {
					Handle = peds, XOffset = 0.0, YOffset = 0,
					X = 0.0, Y = 0.0, Z = 0.0, Heading = 0,
					TaskStatus = 33, VehHandle = Veh, FVect = FVect, RVect = RVect, UpVect = UpVect,
					Vect = Vect, IsPilot = IsPilot
				}
			end
		end
	end,
	function(Args, OperationsTable, OperationT, peds, Veh, FVect, RVect, UpVect, Vect)
		if OperationsTable[13] < 2 then
			if Args.OperationButton then
				local IsPilot = false
				if Veh ~= 0 then
					IsPilot = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds
				end
				OperationT[peds] = {
					Handle = peds, XOffset = 0.0, YOffset = 0,
					X = 0.0, Y = 0.0, Z = 0.0, Heading = 0,
					TaskStatus = 40, VehHandle = Veh, FVect = FVect, RVect = RVect, UpVect = UpVect,
					Vect = Vect, IsPilot = IsPilot
				}
			end
		end
	end
}

local BlipsToFind = {
	0,
	1,
	2,
	306,
	408,
	432,
	433,
	478,
	501,
	523,
	549,
	556,
	568,
	615,
	765,
	868,
}

local NavTest = false
local NavZ = 0.0
local NavRightOffset = 5.0
local Crouch = false
local RelHashBackupAddr = SplitGlobals("Global_1837306.f_6")
local ApplyCopSettings = false
menu.toggle(menu.my_root(), "Apply Cop Settings", {}, "", function(toggle)
	ApplyCopSettings = toggle
	local CopAIMissionRelHash = -1235282855
	local EnemyAIMissionRelHash = 671184796
	local FriendlyAll = -607974925
	local ScanTick = 0
	if not ApplyCopSettings then
		DeleteDispatchFunc()
		RelationshipChanged = true
		STREAMING.REMOVE_ANIM_DICT("move_ped_crouched")
		for index, peds in pairs(entities.get_all_peds_as_handles()) do
			if peds ~= PLAYER.PLAYER_PED_ID() then
				if ENTITY.IS_ENTITY_A_MISSION_ENTITY(peds) then
					local CanEditCop = false
					if OnlyEditOwnedCops then
						local PlayerID = PLAYER.PLAYER_ID()
						if get_entity_owner(peds) == PlayerID then
							CanEditCop = true
						end
					else
						CanEditCop = true
					end
					if CanEditCop then
						local DecorInt = DECORATOR.DECOR_GET_INT(peds, "Casino_Game_Info_Decorator")
						if DecorInt == 31 or DecorInt == 32 then
							util.create_thread(function ()
								local Tick = 0
								while not RequestControlOfEntity(peds) and Tick < 1000 do
									Tick = Tick + 1
									Wait()
								end
								local NetID = NETWORK.PED_TO_NET(peds)
								if NetID ~= 0 then
									NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PLAYER.PLAYER_ID(), false)
								end
								entities.delete_by_handle(peds)
							end)
						end
					end
				end
			end
			for index, vehs in pairs(entities.get_all_vehicles_as_handles()) do
				if ENTITY.IS_ENTITY_A_MISSION_ENTITY(vehs) then
					local CanEditCop = false
					if OnlyEditOwnedCops then
						local PlayerID = PLAYER.PLAYER_ID()
						if get_entity_owner(peds) == PlayerID then
							CanEditCop = true
						end
					else
						CanEditCop = true
					end
					if CanEditCop then
						local DecorInt = DECORATOR.DECOR_GET_INT(vehs, "Casino_Game_Info_Decorator")
						if DecorInt == 31 or DecorInt == 32 then
							util.create_thread(function ()
								local Tick = 0
								--while not RequestControlOfEntity(vehs) and Tick < 1000 do
								--	Tick = Tick + 1
								--	Wait()
								--end
								local NetID = NETWORK.VEH_TO_NET(vehs)
								if NetID ~= 0 then
									NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PLAYER.PLAYER_ID(), false)
								end
								entities.delete_by_handle(vehs)
							end)
						end
					end
				end
			end
		end
		if AutomaticGenCops then
			local PlayerID = PLAYER.PLAYER_ID()
			PLAYER.SET_PLAYER_WANTED_LEVEL(PlayerID, 0, false)
			PLAYER.SET_PLAYER_WANTED_LEVEL_NOW(PlayerID, false)
		end
		for i = 0, 29 do
			local RelTarget = joaat("rgFM_Team"..i)
			PED.SET_RELATIONSHIP_BETWEEN_GROUPS(3, joaat("rgFM_AiAmbientGangMerc[".. 0 .. "]"), RelTarget)
			PED.SET_RELATIONSHIP_BETWEEN_GROUPS(3, RelTarget, joaat("rgFM_AiAmbientGangMerc[".. 0 .. "]"))
			PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, joaat(AiHateRel), RelTarget)
			PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, RelTarget, joaat(AiHateRel))
		end
		if SetAllyPedHateToAiHate then
			if PED.DOES_RELATIONSHIP_GROUP_EXIST(FriendlyAll) then
				PED.SET_RELATIONSHIP_BETWEEN_GROUPS(3, FriendlyAll, CopAIMissionRelHash)
				PED.SET_RELATIONSHIP_BETWEEN_GROUPS(3, FriendlyAll, EnemyAIMissionRelHash)
			end
		end
	end
	local AiTeam1Hash = joaat("rgFM_AiPed20000")
	local SelectedTeam = -607974925
	--local FriendlyAll = AiTeam1Hash
	local DeadPeds = {}
	local BlipColorToGive = 1
	local EditedDamageEnts = {}
	local EditedDamageEntsHandles = {}
	if ApplyCopSettings then
		local CallDispatchDelay = 0
		local HasDeletedDispatch = false
		PlayerID = PLAYER.PLAYER_ID()
		local RelHashBackup = memory.read_int(memory.script_global(RelHashBackupAddr))
		local HasSetHate = false
		local FreemodeBackupHeliAddr = memory.script_local("freemode", 7041)
		local TriesTick = 0
		local TasksT = {}
		local OperationT = {}
		local TaskNum = 4
		local SelectedTask = SelectedTaskTXT[TaskNum].Task
		local OperationsTable = {}
		local NumCreatedTasks = 13
		local FoundCopVehs = {}
		local CopVehsT = {}
		local OwnedCopVehsT = {}
		local PedsT = {}
		local StoredCoordsT = {}
		local IterationsNumber = 0
		local ZombiesT = {}
		local FoundZombiesT = {}
		local IteratedPedsT = {}
		local IteratedPedsHandlesT = {}
		local CopsToSetBlipsT = {}
		local CopsHandlesToSetBlipsT = {}
		local IndexToWrite = 0
		local BulletsPerPed = {}
		for i = 1, NumCreatedTasks do
			OperationsTable[i] = 0
		end
		local TaskArgs = {
			OperationStatus = 0,
			OperationSide = 0,
			OperationOffset = 1.25,
			OperationButton = false,
			OperationHeading = 0.0,
			SeatsFilled = 0,
			HitCoords = nil,
			IsPlayerShooting = false,
			TargetPed = 0,
			OffsetsAttach = nil,
			RotsAttach = nil,
			AttachedNum = 0,
			MaxAttachs = 0,
			RelHash = 0,
			ShootsT = {},
			PedsToPointedArea = {},
			PointedAreaSet = 0,
			PointedPeds = 0,
			OffsetBringedPeds = 0,
			CopsRushWithTP = CopsRushWithTP,
			PlayerCoords = nil,
			IsAiming = false
		}
		local NavsT = {}
		local HostileNum = 1
		local LastCopCount = 0
		local ClearedWantedLevel = false
		local HasSetCanTakeDamage = false
		local PMin, PMax = v3.new(), v3.new()
		local HasGotModelDimensions = false
		local CopsIndexesInMissionT = {}
		local CopsInMissionT = {}
		while ApplyCopSettings do
			local PlayerPed = PLAYER.PLAYER_PED_ID()
			local IsInVeh = PED.IS_PED_IN_ANY_VEHICLE(PlayerPed, false)
			TaskArgs.IsPlayerShooting = PED.IS_PED_SHOOTING(PlayerPed)
			local PlayerVeh = PED.GET_VEHICLE_PED_IS_IN(PlayerPed, false)
			if IsInVeh then
				if PlayerVeh ~= 0 then
					if not HasGotModelDimensions then
						HasGotModelDimensions = true
						MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(PlayerVeh), PMin, PMax)
					end
				end
			else
				HasGotModelDimensions = false
			end
			SelectedTask = SelectedTaskTXT[TaskNum].Task
			if SetAllyPedHateToAiHate then
				if not HasSetHate then
					if PED.DOES_RELATIONSHIP_GROUP_EXIST(FriendlyAll) then
						PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, FriendlyAll, CopAIMissionRelHash)
						PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, FriendlyAll, EnemyAIMissionRelHash)
						HasSetHate = true
					end
				end
			end
			local FoundHostiles = {}
			TaskArgs.HitCoords = nil
			TaskArgs.HasHit = false
			TaskArgs.CopsRushWithTP = CopsRushWithTP
			local FVect, RVect, UpVect, Vect = v3.new(), v3.new(), v3.new(), v3.new()
			if UseCustomsTasksKeys then
				local SwitchReleased = PAD.IS_CONTROL_JUST_RELEASED(0, 47) or PAD.IS_DISABLED_CONTROL_JUST_RELEASED(0, 47)
				if SwitchReleased then
					TaskNum = TaskNum + 1
					if TaskNum > #SelectedTaskTXT then
						TaskNum = 1
					end
					if TaskNum < 1 then
						TaskNum = #SelectedTaskTXT
					end
					SelectedTask = SelectedTaskTXT[TaskNum].Task
					AUDIO.PLAY_SOUND_FRONTEND(-1, "LOCAL_PLYR_CASH_COUNTER_INCREASE", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", false)
					for i = 1, NumCreatedTasks do
						OperationsTable[i] = 0
						SelectedTaskTXT[i].ColourG = 255
					end
				end
				PAD.DISABLE_CONTROL_ACTION(0, 85, true)
				Draw2DText(SelectedTaskTXT[TaskNum].TXT, 0.7, 0.5, 0.5, 0.5, 200, SelectedTaskTXT[SelectedTask].ColourG, 20, 200, 1.0)
				if not STREAMING.HAS_ANIM_SET_LOADED("move_ped_crouched") then
					STREAMING.REQUEST_ANIM_SET("move_ped_crouched")
				end
				TaskArgs.OperationButton = PAD.IS_CONTROL_JUST_PRESSED(0, 46) or PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 46)
				if TaskArgs.OperationButton then
					AUDIO.PLAY_SOUND_FRONTEND(-1, "Collect", "DLC_Low2_Ibi_Sounds", false)
				end
				CustomTasksFunctions[SelectedTask](TaskArgs, PlayerPed, OperationsTable, TaskArgs.HitCoords, FVect, RVect, UpVect, Vect)
			end
			PlayerID = PLAYER.PLAYER_ID()
			local PlayerGroup = PLAYER.GET_PLAYER_GROUP(PlayerID)
			local PlTeamRel = 536121530
			local MissionCopCount = 0
			local PlRel = PED.GET_PED_RELATIONSHIP_GROUP_HASH(PlayerPed)
			local CustomRelExists = false
			if CopsShootWhereYouShoot then
				if TaskArgs.IsPlayerShooting then
					TaskArgs.HitCoords = v3.new()
					TaskArgs.HasHit = WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(PlayerPed, TaskArgs.HitCoords)
					if not TaskArgs.HasHit then
						local CamRot = CAM.GET_GAMEPLAY_CAM_ROT(2)
						local FVect = CamRot:toDir()
						local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
						local AdjustedX = PPos.x + FVect.x * 1000
						local AdjustedY = PPos.y + FVect.y * 1000
						local AdjustedZ = PPos.z + FVect.z * 1000
						local DidHit = memory.alloc(1)
						local EndCoords = v3.new()
						local Normal = v3.new()
						local HitEntity = memory.alloc_int()
					
						local Handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
							PPos.x, PPos.y, PPos.z,
							AdjustedX, AdjustedY, AdjustedZ,
							-1,
							PlayerPed, 7
						)
						SHAPETEST.GET_SHAPE_TEST_RESULT(Handle, DidHit, EndCoords, Normal, HitEntity)
						if memory.read_byte(DidHit) ~= 0 then
							TaskArgs.HitCoords.x = EndCoords.x
							TaskArgs.HitCoords.y = EndCoords.y
							TaskArgs.HitCoords.z = EndCoords.z
						else
							TaskArgs.HitCoords.x = AdjustedX
							TaskArgs.HitCoords.y = AdjustedY
							TaskArgs.HitCoords.z = AdjustedZ
						end
						TaskArgs.HasHit = true
					end
				end
			end
			if CopsShootWhereYouAim then
				if TaskArgs.HitCoords == nil then
					local IsAiming = CAM.IS_AIM_CAM_ACTIVE()
					if IsAiming then
						TaskArgs.HitCoords = v3.new()
						local CamRot = CAM.GET_GAMEPLAY_CAM_ROT(2)
						local FVect = CamRot:toDir()
						local PPos = CAM.GET_GAMEPLAY_CAM_COORD()
						local AdjustedX = PPos.x + FVect.x * 1000
						local AdjustedY = PPos.y + FVect.y * 1000
						local AdjustedZ = PPos.z + FVect.z * 1000
						local DidHit = memory.alloc(1)
						local EndCoords = v3.new()
						local Normal = v3.new()
						local HitEntity = memory.alloc_int()
					
						local Handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
							PPos.x, PPos.y, PPos.z,
							AdjustedX, AdjustedY, AdjustedZ,
							-1,
							PlayerPed, 7
						)
						SHAPETEST.GET_SHAPE_TEST_RESULT(Handle, DidHit, EndCoords, Normal, HitEntity)
						if memory.read_byte(DidHit) ~= 0 then
							TaskArgs.HitCoords.x = EndCoords.x
							TaskArgs.HitCoords.y = EndCoords.y
							TaskArgs.HitCoords.z = EndCoords.z
						else
							TaskArgs.HitCoords.x = AdjustedX
							TaskArgs.HitCoords.y = AdjustedY
							TaskArgs.HitCoords.z = AdjustedZ
						end
						TaskArgs.HasHit = true
					end
				end
			end
			if RandomModels then
				if PLAYER.GET_PLAYER_WANTED_LEVEL(PlayerID) <= 0 then
					if not HasAppliedRandomModels then
						HasAppliedRandomModels = true
						SetRandomModels()
					end
				else
					HasAppliedRandomModels = false
				end
			end
			if RelationshipChanged then
				if not SetCopsMyRelationship then
					if CopsCustomRelationship then
						if PED.DOES_RELATIONSHIP_GROUP_EXIST(joaat(CustomRelText)) then
							CustomRelExists = true
							SelectedTeam = joaat(CustomRelText)
							if CopsAreAllies then
								BlipColorToGive = 3
							else
								BlipColorToGive = 1
							end
						end
					end
					if not CustomRelExists then
						if CopsAreAllies then
							BlipColorToGive = 3
							if not CopsCanAttackPlayers then
								if PED.DOES_RELATIONSHIP_GROUP_EXIST(FriendlyAll) then
									SelectedTeam = FriendlyAll
								else
									if PED.DOES_RELATIONSHIP_GROUP_EXIST(joaat(AiLikeHateAiHateRel)) and PED.GET_RELATIONSHIP_BETWEEN_GROUPS(PlRel, joaat(AiLikeHateAiHateRel)) == 1 then
										SelectedTeam = joaat(AiLikeHateAiHateRel)
									else
										SelectedTeam = PlRel
									end
								end
							else
								local CanSetRel = false
								local RelTarget = joaat("rgFM_Team"..PlayerID)
								local RelHash = joaat("rgFM_AiAmbientGangMerc[".. 0 .. "]")
								if not AvoidAttackingFriends then
									PED.SET_RELATIONSHIP_BETWEEN_GROUPS(1, RelHash, RelTarget)
									PED.SET_RELATIONSHIP_BETWEEN_GROUPS(1, RelTarget, RelHash)
								else
									if FreemodeBackupHeliAddr ~= 0 then
										if AvoidAttackSpeficPlayers then
											if not is_bit_set(AvoidPlayerBits, PlayerID+1) then
												AvoidPlayerBits = set_bit(AvoidPlayerBits, PlayerID+1)
											end
											memory.write_int(FreemodeBackupHeliAddr, AvoidPlayerBits)
										end
										if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("am_backup_heli")) == 0 then
											if TriesTick <= 0 then
												menu.trigger_commands("helibackup")
												TriesTick = 50
											else
												if TriesTick > 0 then
													TriesTick = TriesTick - 1
												end
											end
										else
											TriesTick = 0
											CanSetRel = true
										end
									end
								end
								local MyRelTeam = PED.GET_PED_RELATIONSHIP_GROUP_HASH(PlayerPed)
								if CanSetRel then
									MyRelTeam = RelHashBackup
									RelTarget = RelHashBackup
									RelHash = RelHashBackup
								end
								if MyRelTeam ~= RelTarget then
									--SelectedTeam = joaat("rgFM_AiAmbientGangMerc[".. 0 .. "]")
									SelectedTeam = MyRelTeam
								else
									SelectedTeam = RelHash
									if AvoidAttackingFriends then
										if not CanSetRel then
											if PED.GET_RELATIONSHIP_BETWEEN_GROUPS(SelectedTeam, MyRelTeam) ~= 1 then
												SelectedTeam = joaat(AiLikeHateAiHateRel)
												if PED.GET_RELATIONSHIP_BETWEEN_GROUPS(SelectedTeam, MyRelTeam) ~= 1 then
													SelectedTeam = joaat(AiLikeRel)
												end
											end
										end
									end
								end
							end
							if CopsCanAttackPlayersV2 then
								local MyRelTeam = PED.GET_PED_RELATIONSHIP_GROUP_HASH(PlayerPed)
								SelectedTeam = joaat(AiHateRel)
								for i = 1, 30 do
									if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i-1) then
										if is_bit_set(AvoidPlayerBits, i) then
											local TargetRel = PED.GET_PED_RELATIONSHIP_GROUP_HASH(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(i-1))
											PED.SET_RELATIONSHIP_BETWEEN_GROUPS(1, SelectedTeam, TargetRel)
											PED.SET_RELATIONSHIP_BETWEEN_GROUPS(1, TargetRel, SelectedTeam)
										else
											local TargetRel = PED.GET_PED_RELATIONSHIP_GROUP_HASH(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(i-1))
											PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, SelectedTeam, TargetRel)
											PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, TargetRel, SelectedTeam)
										end
									end
								end
								PED.SET_RELATIONSHIP_BETWEEN_GROUPS(1, SelectedTeam, MyRelTeam)
								PED.SET_RELATIONSHIP_BETWEEN_GROUPS(1, MyRelTeam, SelectedTeam)
							end
						else
							BlipColorToGive = 1
							if CopsAttackEveryone or ZombieMode then
								if PED.DOES_RELATIONSHIP_GROUP_EXIST(joaat(AiHateRel)) then
									SelectedTeam = joaat(AiHateRel)
								else
									SelectedTeam = joaat("COP")
									if ZombieMode then
										SelectedTeam = joaat("GANG_1")
									end
								end
							else
								SelectedTeam = joaat("COP")
							end
						end
					end
				else
					SelectedTeam = PED.GET_PED_RELATIONSHIP_GROUP_HASH(PlayerPed)
					BlipColorToGive = 3
				end
				RelationshipChanged = false
			end
			TaskArgs.RelHash = SelectedTeam
			if not PED.DOES_RELATIONSHIP_GROUP_EXIST(FriendlyAll) then
				HasSetHate = false
			end
			--Print(SelectedTeam == joaat(AiHateRel))
			local InteriorPlayerPed = INTERIOR.GET_INTERIOR_FROM_ENTITY(PlayerPed)
			for index, peds in pairs(PedsT) do
				if DECORATOR.DECOR_GET_INT(peds, "Casino_Game_Info_Decorator") == 31 then
					MissionCopCount = MissionCopCount + 1
					if IgnoreDeadCops then
						if ENTITY.IS_ENTITY_DEAD(peds) then
							MissionCopCount = MissionCopCount - 1
						end
					end
				end
				if CopsRushToNearestTarget then
					if peds ~= PlayerPed then
						if not PED.IS_PED_A_PLAYER(peds) then
							if SelectedTask == 9 or SelectedTask == 11 or SelectedTask == 12 then
								if not ENTITY.IS_ENTITY_DEAD(peds) and not PED.IS_PED_DEAD_OR_DYING(peds) then
									local RelType = PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PlayerPed)
									local CombatTarget = PED.GET_PED_TARGET_FROM_COMBAT_PED(peds, 0)
									if RelType ~= 1 or CombatTarget == PlayerPed then
										if ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 200.0, 200.0, 3000.0, false, true, false) then
											FoundHostiles[#FoundHostiles+1] = peds
										end
									end
								end
							end
							--if SelectedTask == 12 then
							--	if not ENTITY.IS_ENTITY_DEAD(peds) and not PED.IS_PED_DEAD_OR_DYING(peds) then
							--		local RelType = PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PlayerPed)
							--		local CombatTarget = PED.GET_PED_TARGET_FROM_COMBAT_PED(peds, 0)
							--		if RelType == 5 or CombatTarget == PlayerPed then
							--			if ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 200.0, 200.0, 3000.0, false, true, false)
							--			and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PlayerPed, 17) then
							--				FoundHostiles[#FoundHostiles+1] = peds
							--			end
							--		end
							--	end
							--end
						end
					end
				end
			end
			ClearedWantedLevel = false
			if RandomModelsEverytime then
				if LastCopCount ~= MissionCopCount then
					LastCopCount = MissionCopCount
					PLAYER.SET_PLAYER_WANTED_LEVEL(PlayerID, 0, false)
					PLAYER.SET_PLAYER_WANTED_LEVEL_NOW(PlayerID, false)
					ClearedWantedLevel = true
				end
			end
			GlobalCopCount = MissionCopCount
			if MissionCopCount < MaxCopsToEdit then
				PedsT = entities.get_all_peds_as_handles()
			else
				if ScanTick <= 0 then
					PedsT = entities.get_all_peds_as_handles()
					ScanTick = 100
				end
				ScanTick = ScanTick - 1
			end
			if RenderCopCount then
				directx.draw_text(0.7, 0.7, "Cops "..MissionCopCount, ALIGN_CENTRE, 1.0, {r = 0.0, g = 1.0 , b = 1.0, a = 1.0}, false)
			end
			if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller")) > 0 or
				SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller_2020")) > 0 then
				if not HasSetCanTakeDamage then
					HasSetCanTakeDamage = true
					SetMissionEntitiesCanTakeDamage()
				end
			else
				HasSetCanTakeDamage = false
			end
			local BikerResupplyScript = false
			if CopsHelpInMissions then
				BikerResupplyScript = SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("gb_illicit_goods_resupply")) > 0
			end
			if AutomaticCallDispatch then
				if MissionCopCount < MaxCopsToEdit then
					HasDeletedDispatch = false
					if IncidentIndex == 0 then
						if CallDispatchDelay <= 0 then
							CallDispatchDelay = 100
							CallDispatchFunc()
						else
							CallDispatchDelay = CallDispatchDelay - 1
						end
					end
				else
					if not HasDeletedDispatch then
						HasDeletedDispatch = true
						DeleteDispatchFunc()
						CallDispatchDelay = 0
					end
				end
			end
			for index, peds in pairs(PedsT) do
				if peds ~= PlayerPed then
					if IteratedPedsT[peds] == nil then
						if ENTITY.DOES_ENTITY_EXIST(peds) then
							--if EditedDamageEnts[peds] ~= nil then
							--	if ENTITY.IS_ENTITY_DEAD(peds) or PED.IS_PED_A_PLAYER(peds) or PED.IS_PED_DEAD_OR_DYING(peds) then
							--		EditedDamageEnts[peds] = nil
							--	end
							--end
							if not PED.IS_PED_A_PLAYER(peds) then
								if not ENTITY.IS_ENTITY_DEAD(peds) then
									local EntScript = ENTITY.GET_ENTITY_SCRIPT(peds, 0)
									if EntScript == "GB_HEADHUNTER" or EntScript == "GB_BIKER_RESCUE_CONTACT" or "FM_Mission_Controller"
									or "FM_Mission_Controller_2020" then
										if EditedDamageEnts[peds] == nil then
											if RequestControlOfEntity(peds) then
												ENTITY.SET_ENTITY_ONLY_DAMAGED_BY_PLAYER(peds, false)
												local Veh = PED.GET_VEHICLE_PED_IS_IN(peds, false)
												if Veh ~= 0 then
													ENTITY.SET_ENTITY_ONLY_DAMAGED_BY_PLAYER(Veh, false)
													ENTITY.SET_ENTITY_CAN_ONLY_BE_DAMAGED_BY_SCRIPT_PARTICIPANTS(Veh, false)
												end
												if RelHashBackup ~= 0 then
													ENTITY.SET_ENTITY_CAN_BE_DAMAGED_BY_RELATIONSHIP_GROUP(peds, true, RelHashBackup)
												end
												ENTITY.SET_ENTITY_CAN_BE_DAMAGED_BY_RELATIONSHIP_GROUP(peds, true, SelectedTeam)
												ENTITY.SET_ENTITY_CAN_ONLY_BE_DAMAGED_BY_SCRIPT_PARTICIPANTS(peds, false)
												EditedDamageEnts[peds] = peds
												EditedDamageEntsHandles[#EditedDamageEntsHandles+1] = peds
											end
										end
									end
								end
								if CopsRushToNearestTarget then
									if #FoundHostiles > 0 then
										if HostileNum > #FoundHostiles then
											HostileNum = 1
										end
										if OperationT[peds] ~= nil then
											if OperationT[peds].Target == nil then
												if SelectedTask ~= 12 then
													OperationT[peds].Target = FoundHostiles[HostileNum]
													HostileNum = HostileNum + 1
												else
													if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, FoundHostiles[HostileNum], 17) then
														OperationT[peds].Target = FoundHostiles[HostileNum]
														HostileNum = HostileNum + 1
													end
												end
											end
										end
									end
								end
								local CanEditCop = false
								if OnlyEditOwnedCops then
									if NETWORK.NETWORK_IS_GAME_IN_PROGRESS() then
										if get_entity_owner(peds) == PlayerID then
											CanEditCop = true
										end
									else
										CanEditCop = true
									end
								else
									CanEditCop = true
								end
								local IsCopModel = IsCopPedModel(peds)
								local HaveCopRel = IsWithCopRel(peds)
								local CanAddBlip = false
								if not ENTITY.IS_ENTITY_A_MISSION_ENTITY(peds) then
									if not ENTITY.IS_ENTITY_DEAD(peds) then
										if CanEditCop then
											if MissionCopCount < MaxCopsToEdit then
												if EntScript == nil then
													local CanApplyDecor = false
													local DecorApplied = false
													if CopsModelForMission then
														if IsCopModel then
															CanApplyDecor = true
														end
													end
													if CopsForMission then
														if HaveCopRel then
															CanApplyDecor = true
														end
													end
													if CanApplyDecor and MakeCopsAsMissionEntities then
														if RequestControlOfEntity(peds) then
															if DECORATOR.DECOR_SET_INT(peds, "Casino_Game_Info_Decorator", 31) then
																ENTITY.SET_ENTITY_AS_MISSION_ENTITY(peds, false, true)
																local PedAddr = entities.handle_to_pointer(peds) + 0xD8
																if PedAddr ~= 0 then
																	memory.write_int(PedAddr, 460962)
																end
																DecorApplied = true
																if SetNetworkID then
																	local NetID = NETWORK.PED_TO_NET(peds)
																	if NetID ~= 0 then
																		NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PlayerID, true)
																	end
																end
																local Veh = PED.GET_VEHICLE_PED_IS_IN(peds, false)
																if Veh ~= 0 then
																	if FoundCopVehs[Veh] == nil then
																		local Peds = {}
																		for i = -1, 9 do
																			local Ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, i, false)
																			if Ped ~= 0 then
																				Peds[#Peds+1] = Ped
																			end
																		end
																		FoundCopVehs[Veh] = Veh
																		CopVehsT[#CopVehsT+1] = {Handle = Veh, HasSetToMissionEnt = false, Passengers = Peds, Tick = 0, VehDestroyed = false}
																	end
																	OwnedCopVehsT[peds] = Veh
																end
															end
														end
													else
														if CopsForMission then
															if HaveCopRel then
																CanApplyDecor = true
															end
														end
														if CopsModelForMission then
															if IsCopModel then
																CanApplyDecor = true
															end
														end
														if CanApplyDecor then
															if not DECORATOR.DECOR_EXIST_ON(peds, "Casino_Game_Info_Decorator") then
																if RequestControlOfEntity(peds) then
																	DECORATOR.DECOR_SET_INT(peds, "Casino_Game_Info_Decorator", 31)
																	DecorApplied = true
																end
															end
														else
															IteratedPedsT[peds] = 0
															IteratedPedsHandlesT[#IteratedPedsHandlesT+1] = peds
														end
													end
													if DecorApplied then
														MissionCopCount = MissionCopCount + 1
														RequestControlOfEntity(peds)
														PED.SET_PED_RELATIONSHIP_GROUP_HASH(peds, SelectedTeam)
														--PED.SET_PED_FLEE_ATTRIBUTES(peds, 512, true)
														if not ZombieMode then
															PED.SET_PED_CONFIG_FLAG(peds, 134, true)
															PED.SET_PED_CONFIG_FLAG(peds, 173, true)
															PED.SET_PED_CONFIG_FLAG(peds, 251, true)
															PED.SET_PED_CONFIG_FLAG(peds, 255, true)
															PED.SET_PED_CONFIG_FLAG(peds, 400, true)
															if FirstRemoveWeaps then
																WEAPON.REMOVE_ALL_PED_WEAPONS(peds, false)
															end
															if GivePistol then
																WEAPON.GIVE_WEAPON_TO_PED(peds, joaat("weapon_pistol"), 99999, false, false)
															end
															if UseBestWeapon then
																PED.SET_PED_COMBAT_ATTRIBUTES(peds, 54, true)
															end
															if EnableWeaponSettsForCops then
																GiveCorrectWeaponsToPed(peds)
															end
															if RandomWeaponComponents then
																Set_Weapon_Components(peds)
															end
															if IsCopModel or HaveCopRel then
																SetPedCombatAbilities(peds)
																PED.SET_PED_FIRING_PATTERN(peds, joaat("FIRING_PATTERN_FULL_AUTO"))
																PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(peds, 1)
															end
															if EliteCops then
																ENTITY.SET_ENTITY_MAX_HEALTH(peds, 300)
																PED.SET_PED_MAX_HEALTH(peds, 300)
																ENTITY.SET_ENTITY_HEALTH(peds, 300)
																PED.SET_PED_SUFFERS_CRITICAL_HITS(peds, false)
																PED.SET_RAGDOLL_BLOCKING_FLAGS(peds, 1)
															end
															if StrongCops then
																PED.SET_PED_COMBAT_MOVEMENT(peds, 2)
																PED.SET_PED_FIRING_PATTERN(peds, joaat("FIRING_PATTERN_FULL_AUTO"))
																PED.SET_PED_CONFIG_FLAG(peds, 208, true)
																PED.SET_PED_COMBAT_ATTRIBUTES(peds, 23, false)
																PED.SET_PED_COMBAT_ATTRIBUTES(peds, 0, false)
																PED.SET_PED_COMBAT_ATTRIBUTES(peds, 13, true)
																PED.SET_PED_COMBAT_ATTRIBUTES(peds, 28, true)
																PED.SET_PED_COMBAT_ATTRIBUTES(peds, 30, true)
																PED.SET_PED_COMBAT_ATTRIBUTES(peds, 83, false)
																PED.SET_PED_COMBAT_ATTRIBUTES(peds, 26, true)
																PED.SET_PED_COMBAT_ATTRIBUTES(peds, 41, true)
																PED.SET_PED_COMBAT_ATTRIBUTES(peds, 7, false)
																PED.SET_COMBAT_FLOAT(peds, 2, 400.0)
															end
															if InvincibleCops then
																ENTITY.SET_ENTITY_INVINCIBLE(peds, true)
															end
															if RushedCops then
																PED.SET_PED_COMBAT_ATTRIBUTES(peds, 31, true)
															end
															if RamMode then
																PED.SET_PED_COMBAT_ATTRIBUTES(peds, 52, true)
															end
															if ChaseWithNav then
																PED.SET_PED_COMBAT_ATTRIBUTES(peds, 69, true)
															end
															if ThrowSmokeGrenade then
																PED.SET_PED_COMBAT_ATTRIBUTES(peds, 60, true)
																--PED.SET_PED_CONFIG_FLAG(peds, 300, true)
															end
															if CopsShootWhereYouShoot or CopsShootWhereYouAim or UseCustomsTasksKeys then
																PED.SET_PED_FIRING_PATTERN(peds, joaat("FIRING_PATTERN_FULL_AUTO"))
																PED.SET_PED_CONFIG_FLAG(peds, 113, false)
																PED.SET_PED_CONFIG_FLAG(peds, 208, true)
																PED.SET_PED_COMBAT_ATTRIBUTES(peds, 2, true)
															end
														else
															--ENTITY.SET_ENTITY_PROOFS(peds, false, false, false, false, true, false, false, false)
															WEAPON.REMOVE_ALL_PED_WEAPONS(peds, false)
															SetPedCombatAbilities(peds)
															--PED.SET_PED_SUFFERS_CRITICAL_HITS(peds, false)
															--PED.SET_RAGDOLL_BLOCKING_FLAGS(peds, 1)
															SetPedHealth(peds, 150)
															PED.SET_PED_ARMOUR(peds, 0)
															--ZombieMode
															--WEAPON.GIVE_WEAPON_TO_PED(peds, joaat("weapon_knife"), 99999, false, false)
															--PED.SET_PED_CONFIG_FLAG(peds, 314, true)
															PED.SET_PED_CONFIG_FLAG(peds, 435, true)
															PED.SET_COMBAT_FLOAT(peds, 7, 1.0)
														end
														local Veh = PED.GET_VEHICLE_PED_IS_IN(peds, false)
														if Veh ~= 0 then
															if InvincibleCopVehicles then
																ENTITY.SET_ENTITY_INVINCIBLE(Veh, true)
															end
															if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds then
																--if IsArmoredVehModel(Veh) then
																	--PED.SET_PED_COMBAT_ATTRIBUTES(peds, 52, true)
																	PED.SET_PED_COMBAT_ATTRIBUTES(peds, 53, true)
																--end
															end
														end
														if not CopyPlayerOutfitToCop then
															local AppliedOutfit = false
															if RandomCopModelComponents then
																if IsCopModel then
																	SetPedRandomOutfit(peds)
																	AppliedOutfit = true
																end
															end
															if RandomCopComponents then
																if not AppliedOutfit then
																	if HaveCopRel then
																		SetPedRandomOutfit(peds)
																	end
																end
															end
														else
															CopyPlayerOutfit(peds, PlayerPed)
														end
														local Veh = PED.GET_VEHICLE_PED_IS_IN(peds, false)
														if Veh ~= 0 then
															if Veh ~= PlayerVeh then
																if UpgradeCopCars then
																	if DECORATOR.DECOR_GET_INT(Veh, "Casino_Game_Info_Decorator") ~= 31 then
																		RequestControlOfEntity(Veh)
																		DECORATOR.DECOR_SET_INT(Veh, "Casino_Game_Info_Decorator", 31)
																		VEHICLE.SET_VEHICLE_WHEEL_TYPE(Veh, math.random(0, 12))
																		VEHICLE.SET_VEHICLE_MOD_KIT(Veh, 0)
																		for k = 0, 48 do
																			local NumMods = entities.get_upgrade_max_value(Veh, k)
																			if NumMods > 0 then
																				local Rand = math.random(0, NumMods)
																				if Rand <= -1 then
																					Rand = 0
																				end
																				entities.set_upgrade_value(Veh, k, Rand, true)
																			else
																				if math.random(0, 1) == 1 then
																					entities.set_upgrade_value(Veh, k, NumMods, true)
																				end
																			end
																		end
																		local CanSetColours = true
																		if not SetCopCarsColours then
																			if VEHICLE.GET_VEHICLE_CLASS(Veh) == 18 then
																				CanSetColours = false
																			end
																		end
																		if CanSetColours then
																			local PRed, PGreen, PBlue, SRed, SGreen, SBlue = math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255)  
																			if SetDefaultColours then
																				PRed, PGreen, PBlue, SRed, SGreen, SBlue = PR, PG, PB, SR, SG, SB
																			end
																			VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(Veh, PRed, PGreen, PBlue)
																			VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(Veh, SRed, SGreen, SBlue)
																			VEHICLE.SET_VEHICLE_COLOURS(Veh, math.random(0, 160), math.random(0, 160))
																		end
																	end
																end
																if IncreaseCopCarSpeed then
																	VEHICLE.MODIFY_VEHICLE_TOP_SPEED(Veh, 1000.0)
																end
																RequestControlOfEntity(Veh)
																DECORATOR.DECOR_SET_INT(Veh, "Casino_Game_Info_Decorator", 31)
																if SetCopPassengersIntoTurretSeat then
																	local HasSetInTurretSeat = false
																	if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) ~= peds then
																		for i = -1, 9 do
																			if not HasSetInTurretSeat then
																				if VEHICLE.IS_TURRET_SEAT(Veh, i) then
																					if VEHICLE.IS_VEHICLE_SEAT_FREE(Veh, i, true) then
																						HasSetInTurretSeat = true
																						RequestControlOfEntity(peds)
																						PED.SET_PED_INTO_VEHICLE(peds, Veh, i)
																					end
																				end
																			end
																		end
																	end
																end
															end
														end
													end
												end
											end
										end
									end
								end
								local DecorInt = DECORATOR.DECOR_GET_INT(peds, "Casino_Game_Info_Decorator")
								if ENTITY.IS_ENTITY_A_MISSION_ENTITY(peds) then
									if DecorInt == 32 then
										if RequestControlOfEntity(peds) then
											local NetID = NETWORK.PED_TO_NET(peds)
											if NetID ~= 0 then
												NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PlayerID, false)
											end
											entities.delete_by_handle(peds)
										end
									end
								end
								if DecorInt == 31 then
									if CanEditCop then
										if PED.GET_PED_RELATIONSHIP_GROUP_HASH(peds) ~= SelectedTeam then
											RequestControlOfEntity(peds)
											PED.SET_PED_RELATIONSHIP_GROUP_HASH(peds, SelectedTeam)
										end
										if PutCopsIntoPlayerVeh then
											if PlayerVeh ~= 0 then
												for i = -1, 9 do
													if VEHICLE.IS_VEHICLE_SEAT_FREE(PlayerVeh, i, true) then
														if RequestControlOfEntity(peds) then
															PED.SET_PED_INTO_VEHICLE(peds, PlayerVeh, i)
														end
													end
												end
											end
										end
										if TryNetworkCopsBlips then
											if CopsToSetBlipsT[peds] == nil then
												CopsHandlesToSetBlipsT[#CopsHandlesToSetBlipsT+1] = {Handle = peds, NetID = 0}
												CopsToSetBlipsT[peds] = 0
											end
										end
									end
									if ENTITY.IS_ENTITY_DEAD(peds) then
										if not IgnoreDeadCops then
											if DeadPeds[peds] == nil then
												util.create_thread(function()
													DeadPeds[peds] = {}
													Wait(10000)
													while not RequestControlOfEntity(peds) and ENTITY.DOES_ENTITY_EXIST(peds) do
														Wait()
													end
													if ENTITY.DOES_ENTITY_EXIST(peds) then
														local NetID = NETWORK.PED_TO_NET(peds)
														if NetID ~= 0 then
															NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PlayerID, false)
														end
														DECORATOR.DECOR_SET_INT(peds, "Casino_Game_Info_Decorator", 32)
														entities.delete_by_handle(peds)
													end
													DeadPeds[peds] = nil
												end)
											end
										else
											if RequestControlOfEntity(peds) then
												set_entity_as_no_longer_needed(peds)
												DECORATOR.DECOR_SET_INT(peds, "Casino_Game_Info_Decorator", 30)
											end
										end
									end
									CanAddBlip = false
									if AddBlipsForAllyCops then
										if not IsCopModel then
											CanAddBlip = true
										end
									end
									if AddBlipsForCopsDifferentModel then
										if IsCopModel then
											CanAddBlip = true
										end
									end
									if CanEditCop then
										if InstantAim then
											PED.SET_PED_RESET_FLAG(peds, 56, true)
										end
										if SprintEverytime then
											if RequestControlOfEntity(peds) then
												PED.SET_PED_MIN_MOVE_BLEND_RATIO(peds, 3.0)
												PED.SET_PED_MAX_MOVE_BLEND_RATIO(peds, 3.0)
											end
										end
										if CanAddBlip then
											if not TryNetworkCopsBlips then
												if not HUD.DOES_PED_HAVE_AI_BLIP(peds) then
													RequestControlOfEntity(peds)
													HUD.SET_PED_HAS_AI_BLIP_WITH_COLOUR(peds, true, BlipColorToGive)
													HUD.SET_PED_AI_BLIP_HAS_CONE(peds, false)
													HUD.SET_PED_AI_BLIP_FORCED_ON(peds, true)
												end
											end
										end
									else
										if CanAddBlip then
											if not HUD.DOES_PED_HAVE_AI_BLIP(peds) then
												HUD.SET_PED_HAS_AI_BLIP_WITH_COLOUR(peds, true, 2)
												HUD.SET_PED_AI_BLIP_HAS_CONE(peds, false)
												HUD.SET_PED_AI_BLIP_FORCED_ON(peds, true)
											end
										end
									end
									if CopsAreAllies then
										if CanEditCop then
											local Veh = PED.GET_VEHICLE_PED_IS_IN(peds, false)
											if RequestControlOfEntity(peds) then
												--local Addr = entities.handle_to_pointer(peds) + 0xD8
												--Print(memory.read_int(Addr))
												if CopsShootCustomBullets then
													local PTFXAsset = "weap_gr_weapons"
													local PTFXName = "bullet_tracer_gr_tintable"
													if not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(PTFXAsset) then
														STREAMING.REQUEST_NAMED_PTFX_ASSET(PTFXAsset)
													else
														local TimerMilis = util.current_time_millis()
														if BulletsPerPed[peds] == nil then
															if not ENTITY.IS_ENTITY_DEAD(peds) then
																local TargetPed = PED.GET_PED_TARGET_FROM_COMBAT_PED(peds, 0)
																if TargetPed ~= 0 then
																	if not ENTITY.IS_ENTITY_DEAD(TargetPed) then
																		if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, TargetPed, 17) then
																			local TimeStep = SYSTEM.TIMESTEP()
																			BulletsPerPed[peds] = TimerMilis
																			local PedPos = ENTITY.GET_ENTITY_COORDS(peds)
																			local Velocity = ENTITY.GET_ENTITY_VELOCITY(TargetPed)
																			--local TargetPos = ENTITY.GET_ENTITY_COORDS(TargetPed)
																			local BonePos = PED.GET_PED_BONE_COORDS(TargetPed, 0x322C --[[head]], 0.0, 0.0, 0.0)
																			Velocity:mul(TimeStep)
																			BonePos:add(Velocity)
																			MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(PedPos.x, PedPos.y, PedPos.z, BonePos.x, BonePos.y, BonePos.z, 10, true, joaat("weapon_navyrevolver"), peds, true--[[VFX]], true, 10.0, peds, 0)
																			local Rot = v3.lookAt(PedPos, BonePos)
																			GRAPHICS.USE_PARTICLE_FX_ASSET(PTFXAsset)
																			GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(PTFXName, PedPos.x, PedPos.y, PedPos.z, Rot.y, Rot.x - 90.0, Rot.z - 90.0, 1.0, false, false, false, false)
																			if CopsInHeliShootMissile then
																				if PED.IS_PED_IN_FLYING_VEHICLE(peds) then
																					MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(PedPos.x, PedPos.y, PedPos.z, BonePos.x, BonePos.y, BonePos.z, 10, true, joaat("weapon_rpg"), peds, true--[[VFX]], true, -1.0, peds, 0)
																				end
																			end
																		end
																	end
																end
															end
														else
															if TimerMilis > BulletsPerPed[peds]+500 then
																BulletsPerPed[peds] = nil
															end
														end
													end
												end
												NETWORK.SET_ENTITY_VISIBLE_IN_CUTSCENE(peds, true, true)
												NETWORK.SET_ENTITY_VISIBLE_IN_CUTSCENE(peds, true, false)
												if SetCopsNotMigrateControl then
													entities.set_can_migrate(peds, false)
												end
												if CopsHelpInMissions then
													if CopsIndexesInMissionT[peds] == nil then
														CopsIndexesInMissionT[peds] = 0
														CopsInMissionT[#CopsInMissionT+1] = {Handle = peds, Bits = 0, Target = 0, TaskCoords = {x = 0.0, y = 0.0, z = 0.0}, Timer = 0}
													end
												end
												if SetDefensiveSphereToPlayer then
													if not PED.IS_PED_DEFENSIVE_AREA_ACTIVE(peds, false) then
														local PlayerPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
														PED.SET_PED_SPHERE_DEFENSIVE_AREA(peds, PlayerPos.x, PlayerPos.y, PlayerPos.z, 7.0, false, false)
														PED.SET_PED_CONFIG_FLAG(peds, 436, true)
														PED.SET_PED_COMBAT_ATTRIBUTES(peds, 37, true)
													end
												end
												if CopsForcedBeingNearSphere then
													local IsInSphere = ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 30.0, 30.0, 30.0, false, true, false)
													local Mul = 1.0
													local MoreZ = 0.0
													local PlayerPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
													if PED.IS_PED_IN_ANY_VEHICLE(peds, false) then
														if Veh ~= 0 then
															local VModel = ENTITY.GET_ENTITY_MODEL(Veh)
															if not VEHICLE.IS_THIS_MODEL_A_PLANE(VModel) and not VEHICLE.IS_THIS_MODEL_A_HELI(VModel) then
																ENTITY.SET_ENTITY_COLLISION(Veh, false, false)
																local VehPos = ENTITY.GET_ENTITY_COORDS(Veh)
																local HitPos, HitBool = ShapeTestNav(Veh, VehPos, {x = VehPos.x, y = VehPos.y, z = VehPos.z - 300.0}, -1)
																if not HitBool then
																	MoreZ = MoreZ + 5.0
																end
																local SubVar = v3.sub(PlayerPos, VehPos)
																SubVar.z = SubVar.z + MoreZ
																if not HitBool or not IsInSphere then
																	ENTITY.SET_ENTITY_VELOCITY(Veh, SubVar.x * Mul, SubVar.y * Mul, SubVar.z * Mul)
																	DECORATOR.DECOR_SET_INT(Veh, "hunt_score", 1)
																	ENTITY.SET_ENTITY_ANGULAR_VELOCITY(Veh, 0.0, 0.0, 0.0)
																else
																	ENTITY.SET_ENTITY_COLLISION(Veh, true, true)
																	if DECORATOR.DECOR_GET_INT(Veh, "hunt_score") == 1 then
																		DECORATOR.DECOR_SET_INT(Veh, "hunt_score", 2)
																		ENTITY.SET_ENTITY_VELOCITY(Veh, 0.0, 0.0, 0.0)
																	end
																end
															end
														end
													else
														ENTITY.SET_ENTITY_COLLISION(peds, false, false)
														local PedPos = ENTITY.GET_ENTITY_COORDS(peds)
														local HitPos, HitBool = ShapeTestNav(peds, {x = PedPos.x, y = PedPos.y, z = PedPos.z + 1.0}, {x = PedPos.x, y = PedPos.y, z = PedPos.z - 300.0}, -1)
														if not HitBool then
															MoreZ = MoreZ + 5.0
														end
														local SubVar = v3.sub(PlayerPos, PedPos)
														SubVar.z = SubVar.z + MoreZ
														if not HitBool or not IsInSphere then
															ENTITY.SET_ENTITY_VELOCITY(peds, SubVar.x * Mul, SubVar.y * Mul, SubVar.z * Mul)
														else
															ENTITY.SET_ENTITY_COLLISION(peds, true, true)
														end
													end
												end
											end
											if OperationT[peds] == nil then
												if not ENTITY.IS_ENTITY_DEAD(peds) then
													if ArmoredVehicle then
														if ENTITY.GET_ENTITY_MODEL(Veh) ~= joaat("technical") then
															for a = 1, #ArmoredVehsT do
																if VEHICLE.IS_VEHICLE_SEAT_FREE(ArmoredVehsT[a].Handle, 1, true) then
																	PED.SET_PED_INTO_VEHICLE(peds, ArmoredVehsT[a].Handle, 1)
																	PED.SET_PED_COMBAT_ATTRIBUTES(peds, 3, false)
																end
															end
														end
													end
													local IsPedInGroup = PED.IS_PED_IN_GROUP(peds)
													if not IsPedInGroup then
														if not UseCustomsTasksKeys then
															if CopsFollowAsBodyguard then
																local CanSetInGroup = true
																if Veh ~= 0 then
																	local VehModel = ENTITY.GET_ENTITY_MODEL(Veh)
																	local IsAPlane = VEHICLE.IS_THIS_MODEL_A_PLANE(VehModel)
																	local IsAHeli = VEHICLE.IS_THIS_MODEL_A_HELI(VehModel)
																	if IsAPlane or IsAHeli then
																		CanSetInGroup = false
																	end
																end
																if CanSetInGroup then
																	if GetPedGroupSize(PlayerGroup) < 7 then
																		if ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 30.0, 30.0, 30.0, false, true, false) then
																			if RequestControlOfEntity(peds) then
																				PED.SET_PED_AS_GROUP_MEMBER(peds, PlayerGroup)
																				PED.SET_PED_NEVER_LEAVES_GROUP(peds, true)
																				PED.SET_GROUP_SEPARATION_RANGE(PlayerGroup, 9999.0)
																				PED.SET_GROUP_FORMATION_SPACING(PlayerGroup, 1.0, -1.0, -1.0)
																				PED.SET_GROUP_FORMATION(PlayerGroup, 1)
																				TASK.CLEAR_PED_TASKS(peds)
																			end
																		end
																	end
																end
															end
														end
													end
													IsPedInGroup = PED.IS_PED_IN_GROUP(peds)
													local IsPedInVeh = PED.IS_PED_IN_ANY_VEHICLE(peds, false)
													if CopsFollowInVehTask then
														if not PED.IS_PED_IN_COMBAT(peds, 0) then
															if IsPedInVeh then
																if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_SHOOT_AT_COORD")) == 7 then
																	if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds then
																		local VehModel = ENTITY.GET_ENTITY_MODEL(Veh)
																		local IsAPlane = VEHICLE.IS_THIS_MODEL_A_PLANE(VehModel)
																		local IsAHeli = VEHICLE.IS_THIS_MODEL_A_HELI(VehModel)
																		if not IsAPlane and not IsAHeli then
																			if not IsPedInGroup then
																				if not ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 100.0, 100.0, 100.0, false, true, false) then
																					if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_MISSION")) == 7 then
																						if RequestControlOfEntity(peds) then
																							TASK.TASK_VEHICLE_MISSION_PED_TARGET(peds, Veh, PlayerPed, 4, 1000.0, 64+512+2048+262144, 50.0, 10.0, true)
																						end
																					end
																				end
																			end
																		else
																			if not ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 150.0, 150.0, 200.0, false, true, false) then
																				if IsAHeli then
																					if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_MISSION")) == 7 then
																						if RequestControlOfEntity(peds) then
																							TASK.TASK_HELI_MISSION(peds, Veh, 0, PlayerPed, 0.0, 0.0, 1500.0, 4, 100.0, 120.0, 0, 100, 50, -1.0, 0)
																						end
																					end
																				end
																				if IsAPlane then
																					if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_MISSION")) == 7 then
																						if RequestControlOfEntity(peds) then
																							TASK.TASK_PLANE_MISSION(peds, Veh, 0, PlayerPed, 0, 0, 0, 4, 1000.0, 50.0, 0.0, 50.0, 30.0, true)
																						end
																					end
																				end
																			end
																		end
																	end
																end
															end
														end
													end
													if CopsFollowTask then
														if not IsPedInVeh then
															if not IsPedInGroup then
																if OperationT[peds] == nil and NavsT[peds] == nil then
																	if not PED.IS_PED_IN_COMBAT(peds, 0) then
																		if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_SHOOT_AT_COORD")) == 7 then
																			if ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 50.0, 50.0, 50.0, false, true, false) then
																				if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_FOLLOW_TO_OFFSET_OF_ENTITY")) == 7 then
																					if RequestControlOfEntity(peds) then
																						TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(peds, PlayerPed, math.random(-10, 10), math.random(-10, 10), math.random(-10, 10), 100.0, -1, 5.0, true)
																					end
																				end
																			end
																		end
																	end
																end
															end
														end
													end
													if AllyAttacksHostiles then
														if not PED.IS_PED_IN_COMBAT(peds, 0) then
															TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(peds, DistanceNeededToAttack, 0)
														end
													end
													if CopsRushWithTP then
														local TargetPed = PED.GET_PED_TARGET_FROM_COMBAT_PED(peds, 0)
														if TargetPed ~= 0 then
															if not ENTITY.IS_ENTITY_DEAD(TargetPed) then
																if not ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, TargetPed, 17) or not ENTITY.IS_ENTITY_AT_ENTITY(peds, TargetPed, 30.0, 30.0, 30.0, false, true, 0) then
																	local PedPos = ENTITY.GET_ENTITY_COORDS(peds)
																	local TargetPos = ENTITY.GET_ENTITY_COORDS(TargetPed)
																	TargetPos.z = TargetPos.z + 1.0
																	local NewVAdjusted = {
																		x = TargetPos.x - PedPos.x,
																		y = TargetPos.y - PedPos.y,
																		z = TargetPos.z - PedPos.z
																	}
																	ENTITY.SET_ENTITY_COLLISION(peds, false, false)
																	ENTITY.SET_ENTITY_VELOCITY(peds, NewVAdjusted.x, NewVAdjusted.y, NewVAdjusted.z)
																else
																	ENTITY.SET_ENTITY_COLLISION(peds, true, true)
																end
															else
																ENTITY.SET_ENTITY_COLLISION(peds, true, true)
															end
														else
															ENTITY.SET_ENTITY_COLLISION(peds, true, true)
														end
													end
													if BringFarCopsCloser then
														local CanGo = true
														if BringIfOutsideOfVehicle then
															if IsInVeh then
																CanGo = false
															end
														end
														if CanGo then
															if not PED.IS_PED_IN_COMBAT(peds, 0) then
																if not ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 100.0, 100.0, 100.0, false, true, false) then
																	if TPCopsBackToVehicle then
																		if not RemoveCopsFromVeh then
																			if InteriorPlayerPed == 0 then
																				if IsInVeh or AlwaysTPCopsBackToVehicle then
																					if OwnedCopVehsT[peds] ~= nil then
																						if ENTITY.DOES_ENTITY_EXIST(OwnedCopVehsT[peds]) then
																							Veh = OwnedCopVehsT[peds]
																							if ENTITY.IS_ENTITY_DEAD(Veh) then
																								VEHICLE.SET_VEHICLE_FIXED(Veh)
																							end
																							if not PED.IS_PED_IN_VEHICLE(peds, Veh, false) then
																								if RequestControlOfEntity(peds) then
																									for i = -1, 9 do
																										if VEHICLE.IS_VEHICLE_SEAT_FREE(OwnedCopVehsT[peds], i, false) then
																											PED.SET_PED_INTO_VEHICLE(peds, OwnedCopVehsT[peds], i)
																											break
																										end
																									end
																								end
																							end
																						else
																							OwnedCopVehsT[peds] = nil
																						end
																					end
																				end
																			end
																		end
																	end
																	if RequestControlOfEntity(peds) then
																		if not RemoveCopsFromVeh then
																			if Veh ~= 0 then
																				local CheckRadius = 700.0
																				if TPIfImInAInterior then
																					if InteriorPlayerPed ~= 0 then
																						CheckRadius = 100.0
																					end
																				end
																				if RequestControlOfEntity(Veh) then
																					if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds then
																						local VehClass = VEHICLE.GET_VEHICLE_CLASS(Veh)
																						if VehClass ~= 15 and VehClass ~= 16 then
																							if not ENTITY.IS_ENTITY_AT_ENTITY(Veh, PlayerPed, CheckRadius, CheckRadius, CheckRadius, false, true, false) then
																								local FVect = nil
																								local Multiplier = 100
																								if IsInVeh then
																									FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(PlayerPed)
																									Multiplier = -100
																								else
																									local CamRot = CAM.GET_GAMEPLAY_CAM_ROT(2)
																									CamRot.z = -CamRot.z
																									FVect = CamRot:toDir()
																								end
																								local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
																								local AdjustedX = PPos.x + FVect.x * Multiplier
																								local AdjustedY = PPos.y + FVect.y * Multiplier
																								local AdjustedZ = PPos.z + FVect.z * Multiplier
																								local DidHit = memory.alloc(1)
																								local EndCoords = v3.new()
																								local Normal = v3.new()
																								local HitEntity = memory.alloc_int()
																							
																								local Handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
																									PPos.x, PPos.y, PPos.z,
																									AdjustedX, AdjustedY, AdjustedZ,
																									-1,
																									PlayerPed, 7
																								)
																								SHAPETEST.GET_SHAPE_TEST_RESULT(Handle, DidHit, EndCoords, Normal, HitEntity)
																								local EntTarget = Veh
																								local CheckSz = 2.0
																								if TPIfImInAInterior then
																									if InteriorPlayerPed ~= 0 then
																										EntTarget = peds
																										CheckSz = 0.5
																									end
																								end
																								if memory.read_byte(DidHit) ~= 0 then
																									if not MISC.IS_POSITION_OCCUPIED(EndCoords.x - FVect.x * 5.0, EndCoords.y - FVect.y * 5.0, (EndCoords.z - 1.0) - FVect.z * 5.0, CheckSz, false, true, true, false, false, 0, true) then
																										ENTITY.SET_ENTITY_COORDS(EntTarget, EndCoords.x - FVect.x * 5.0, EndCoords.y - FVect.y * 5.0, (EndCoords.z - 1.0) - FVect.z * 5.0)
																									end
																								else
																									if not MISC.IS_POSITION_OCCUPIED(AdjustedX - FVect.x * 5.0, AdjustedY - FVect.y * 5.0, (AdjustedZ - 1.0) - FVect.z * 5.0, CheckSz, false, true, true, false, false, 0, true) then
																										ENTITY.SET_ENTITY_COORDS(EntTarget, AdjustedX - FVect.x * 5.0, AdjustedY - FVect.y * 5.0, (AdjustedZ - 1.0) - FVect.z * 5.0)
																									end
																								end
																							end
																						else
																							if not ENTITY.IS_ENTITY_AT_ENTITY(Veh, PlayerPed, 700.0, 700.0, 700.0, false, true, false) then
																								local FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(peds)
																								local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
																								local AdjustedX = PPos.x + FVect.x * 100
																								local AdjustedY = PPos.y + FVect.y * 100
																								local AdjustedZ = PPos.z + FVect.z * 100
																								if not MISC.IS_POSITION_OCCUPIED(AdjustedX, AdjustedY, AdjustedZ + 100.0, 1.0, false, true, true, false, false, PlayerPed, true) then
																									ENTITY.SET_ENTITY_COORDS(Veh, AdjustedX, AdjustedY, AdjustedZ + 100.0)
																								end
																							end
																						end
																					end
																				end
																			else
																				local FVect = nil
																				if IsInVeh then
																					FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(PlayerPed)
																				else
																					FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(peds)
																				end
																				local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
																				local MultiplierToGive = 5
																				if IsInVeh then
																					MultiplierToGive = -50
																				end
																				local AdjustedX = PPos.x + FVect.x * MultiplierToGive
																				local AdjustedY = PPos.y + FVect.y * MultiplierToGive
																				local AdjustedZ = PPos.z + FVect.z * MultiplierToGive
																				local DidHit = memory.alloc(1)
																				local EndCoords = v3.new()
																				local Normal = v3.new()
																				local HitEntity = memory.alloc_int()
																			
																				local Handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
																					PPos.x, PPos.y, PPos.z,
																					AdjustedX, AdjustedY, AdjustedZ,
																					-1,
																					PlayerPed, 7
																				)
																				SHAPETEST.GET_SHAPE_TEST_RESULT(Handle, DidHit, EndCoords, Normal, HitEntity)
																				if memory.read_byte(DidHit) ~= 0 then
																					if not MISC.IS_POSITION_OCCUPIED(EndCoords.x, EndCoords.y, EndCoords.z - 1.0, 2.0, false, true, true, false, false, PlayerPed, true) then
																						ENTITY.SET_ENTITY_COORDS(peds, EndCoords.x, EndCoords.y, EndCoords.z - 1.0)
																					end
																				else
																					if not MISC.IS_POSITION_OCCUPIED(AdjustedX, AdjustedY, AdjustedZ - 1.0, 2.0, false, true, true, false, false, PlayerPed, true) then
																						ENTITY.SET_ENTITY_COORDS(peds, AdjustedX, AdjustedY, AdjustedZ - 1.0)
																					end
																				end
																			end
																		else
																			local FVect = nil
																			if IsInVeh then
																				FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(PlayerPed)
																			else
																				FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(peds)
																			end
																			local MultiplierToGive = 5
																			if IsInVeh then
																				MultiplierToGive = -50
																			end
																			local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
																			local AdjustedX = PPos.x + FVect.x * MultiplierToGive
																			local AdjustedY = PPos.y + FVect.y * MultiplierToGive
																			local AdjustedZ = PPos.z + FVect.z * MultiplierToGive
																			local DidHit = memory.alloc(1)
																			local EndCoords = v3.new()
																			local Normal = v3.new()
																			local HitEntity = memory.alloc_int()
																		
																			local Handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
																				PPos.x, PPos.y, PPos.z,
																				AdjustedX, AdjustedY, AdjustedZ,
																				-1,
																				PlayerPed, 7
																			)
																			SHAPETEST.GET_SHAPE_TEST_RESULT(Handle, DidHit, EndCoords, Normal, HitEntity)
																			if memory.read_byte(DidHit) ~= 0 then
																				if not MISC.IS_POSITION_OCCUPIED(EndCoords.x, EndCoords.y, EndCoords.z - 1.0, 2.0, false, true, true, false, false, PlayerPed, true) then
																					ENTITY.SET_ENTITY_COORDS(peds, EndCoords.x, EndCoords.y, EndCoords.z - 1.0)
																				end
																			else
																				if not MISC.IS_POSITION_OCCUPIED(AdjustedX, AdjustedY, AdjustedZ - 1.0, 2.0, false, true, true, false, false, PlayerPed, true) then
																					ENTITY.SET_ENTITY_COORDS(peds, AdjustedX, AdjustedY, AdjustedZ - 1.0)
																				end
																			end
																		end
																	end
																end
															end
														end
													end
												end
											end
											if UseCustomsTasksKeys then
												CustomTasksArgsFunctions[SelectedTask](TaskArgs, OperationsTable, OperationT, peds, Veh,
												FVect, RVect, UpVect, Vect)
												for k = 1, NumCreatedTasks do
													if OperationsTable[k] > 1 then
														if RequestControlOfEntity(peds) then
															PED.SET_PED_COMBAT_MOVEMENT(peds, 2)
															TASK.CLEAR_PED_TASKS(peds)
															PED.SET_PED_MAX_MOVE_BLEND_RATIO(peds, 1.0)
															PED.RESET_PED_MOVEMENT_CLIPSET(peds, 0.55)
															PED.RESET_PED_STRAFE_CLIPSET(peds)
															PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
															ENTITY.DETACH_ENTITY(peds, true, true)
															OperationT[peds] = nil
														end
													end
												end
											end
											if CopsShootWhereYouShoot or CopsShootWhereYouAim or SelectedTask == 1 then
												if not PED.IS_PED_IN_ANY_VEHICLE(peds, false) then
													if not WEAPON.IS_PED_ARMED(peds, 4) then
														local BestWeapon = WEAPON.GET_BEST_PED_WEAPON(peds, false)
														WEAPON.SET_CURRENT_PED_WEAPON(peds, BestWeapon, true)
													end
													if TaskArgs.HasHit then
														if TaskArgs.HitCoords ~= nil then
															if TaskArgs.ShootsT[peds] == nil then
																if RequestControlOfEntity(peds) then
																	TASK.TASK_SHOOT_AT_COORD(peds, TaskArgs.HitCoords.x, TaskArgs.HitCoords.y, TaskArgs.HitCoords.z, 3000, joaat("FIRING_PATTERN_FULL_AUTO"))
																	if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_SHOOT_AT_COORD")) ~= 7 then
																		TaskArgs.ShootsT[peds] = 0
																	end
																end
															end
														end
													end
												else
													if TaskArgs.HitCoords ~= nil then
														if TaskArgs.HasHit then
															if TasksT[peds] == nil then
																if RequestControlOfEntity(peds) then
																	local VehicleWeap = memory.alloc(8)
																	if WEAPON.GET_CURRENT_PED_VEHICLE_WEAPON(peds, VehicleWeap) then
																		TASK.TASK_VEHICLE_SHOOT_AT_COORD(peds, TaskArgs.HitCoords.x, TaskArgs.HitCoords.y, TaskArgs.HitCoords.z, 20.0)
																		if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_SHOOT_AT_COORD")) ~= 7 then
																			TasksT[peds] = 9
																		end
																	else
																		if SetPedVehicleWeapon(peds) then
																			TASK.TASK_VEHICLE_SHOOT_AT_COORD(peds, TaskArgs.HitCoords.x, TaskArgs.HitCoords.y, TaskArgs.HitCoords.z, 20.0)
																			if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_SHOOT_AT_COORD")) ~= 7 then
																				TasksT[peds] = 9
																			end
																		end
																	end
																end
															end
														end
													end
												end
												if PED.IS_PED_SHOOTING(peds) then
													if TasksT[peds] ~= nil then
														TasksT[peds] = TasksT[peds] + 1
														if TasksT[peds] > 10 then
															if RequestControlOfEntity(peds) then
																TASK.CLEAR_PED_TASKS(peds)
																TasksT[peds] = nil
															end
														end
													end
												end
											end
										end
									else
										if CanEditCop then
											if CopsAttackEveryone then
												if MakeCopsAttackEveryone then
													if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_COMBAT_HATED_TARGETS_AROUND_PED")) == 7 then
														TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(peds, 1000.0, 0)
													end
												end
											end
											if ZombieMode then
												if not ENTITY.IS_ENTITY_DEAD(peds) then
													if FoundZombiesT[peds] == nil then
														FoundZombiesT[peds] = peds
														ZombiesT[#ZombiesT+1] = {
															Handle = peds,
															Task = 0,
															Bits = 0,
															Target = 0
														}
													end
												end
												--if not PED.IS_PED_IN_COMBAT(peds, 0) then
												--	if not ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 100.0, 100.0, 100.0, false, true, 0) then
												--		if RequestControlOfEntity(peds) then
												--			local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
												--			local OutPos, FoundCoords = find_right_spawn_normal(PPos.x, PPos.y, PPos.z, 40.0, 70.0)
												--			if FoundCoords then
												--				if not MISC.IS_POSITION_OCCUPIED(OutPos.x, OutPos.y, OutPos.z, 1.0, false, true, true, false, false, PlayerPed, true) then
												--					ENTITY.SET_ENTITY_COORDS(peds, OutPos.x, OutPos.y, OutPos.z)
												--					ENTITY.SET_ENTITY_HEADING(peds, math.random(0, 360))
												--				end
												--			end
												--		end
												--	end
												--end
												--if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_COMBAT_HATED_TARGETS_AROUND_PED")) == 7 then
												--	if RequestControlOfEntity(peds) then
												--		TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(peds, 1000.0, 0)
												--	end
												--end
											end
										end
									end
								end
								if TaskArgs.ShootsT[peds] ~= nil then
									TaskArgs.ShootsT[peds] = TaskArgs.ShootsT[peds] + 1
									if PED.IS_PED_SHOOTING(peds) or TaskArgs.ShootsT[peds] > 100 then
										TaskArgs.ShootsT[peds] = nil
									end
								end
								if OperationT[peds] ~= nil then
									if DECORATOR.DECOR_EXIST_ON(peds, "Casino_Game_Info_Decorator") then
										if not ENTITY.IS_ENTITY_DEAD(peds) then
											if TaskStatusFunctionsT[OperationT[peds].TaskStatus+1] ~= nil then
												TaskStatusFunctionsT[OperationT[peds].TaskStatus+1](OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
											end
										else
											OperationT[peds] = nil
										end
									else
										OperationT[peds] = nil
									end
								end
							end
						end
					end
				end
			end
			for i = 1, #IteratedPedsHandlesT do
				if IteratedPedsHandlesT[i] ~= nil then
					if not ENTITY.DOES_ENTITY_EXIST(IteratedPedsHandlesT[i]) then
						IteratedPedsT[IteratedPedsHandlesT[i]] = nil
						IteratedPedsHandlesT[i] = nil
					end
				end
			end
			local BBattle2 = SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_content_business_battles")) > 0
			for i = 1, #CopsHandlesToSetBlipsT do
				if CopsHandlesToSetBlipsT[i] ~= nil then
					if ENTITY.DOES_ENTITY_EXIST(CopsHandlesToSetBlipsT[i].Handle) and not ENTITY.IS_ENTITY_DEAD(CopsHandlesToSetBlipsT[i].Handle) then
						if CopsHandlesToSetBlipsT[i].NetID == 0 then
							local NetID = 0
							if BBattle2 then
								util.spoof_script("fm_content_business_battles", function()
									if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
										util.request_script_host("fm_content_business_battles")
										NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
									end
									if NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
										ENTITY.SET_ENTITY_AS_MISSION_ENTITY(CopsHandlesToSetBlipsT[i].Handle, false, true)
										if ENTITY.GET_ENTITY_SCRIPT(CopsHandlesToSetBlipsT[i].Handle, 0) == "fm_content_business_battles" then
											NetID = NETWORK.PED_TO_NET(CopsHandlesToSetBlipsT[i].Handle)
											if NetID ~= 0 then
												memory.write_int(memory.script_local("fm_content_business_battles", BBattle2_Peds + BBattle2_NextPed * IndexToWrite), NetID)
												IndexToWrite = IndexToWrite + 1
												if IndexToWrite > 29 then
													IndexToWrite = 0
												end
											end
										end
									end
								end)
							end
							CopsHandlesToSetBlipsT[i].NetID = NetID
						end
					else
						CopsToSetBlipsT[CopsHandlesToSetBlipsT[i].Handle] = nil
						CopsHandlesToSetBlipsT[i] = nil
					end
				end
			end
			for i = 1, NumCreatedTasks do
				if OperationsTable[i] > 1 then
					OperationsTable[i] = 0
				end
			end
			TaskArgs.PointedAreaSet = 0
			if TaskArgs.PointedPeds > MaxCopsToEdit then
				for index, peds in pairs(TaskArgs.PedsToPointedArea) do
					peds = nil
				end
				TaskArgs.PointedPeds = 0
			end
			--TaskArgs.TargetPed = 0
			TaskArgs.OffsetsAttach = nil
			TaskArgs.RotsAttach = nil
			TaskArgs.OffsetBringedPeds = 0
			local RotSpd = 8.0
			local Normalise = false
			local SpdMul = 10.0
			local VehSpeed = 0.0
			local PVehRot = v3.new()
			local PlayerRot = ENTITY.GET_ENTITY_ROTATION(PlayerPed, 5)
			local PlayerOffset = v3.new()
			local PlayerPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
			if PlayerVeh ~= 0 then
				VehSpeed = ENTITY.GET_ENTITY_SPEED(PlayerVeh)
				PVehRot = ENTITY.GET_ENTITY_ROTATION(PlayerVeh, 5)
				PlayerOffset = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PlayerVeh, 0.0, (-PMax.y * 2.0) - 1.0, 0.0)
			else
				VehSpeed = ENTITY.GET_ENTITY_SPEED(PlayerPed)
				PVehRot = ENTITY.GET_ENTITY_ROTATION(PlayerPed, 5)
				PlayerOffset = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PlayerPed, 0.0, (-PMax.y * 2.0) - 1.0, 0.0)
			end
			if CopsFollowLikeSnake then
				if ENTITY.GET_ENTITY_SPEED(PlayerPed) > 0.0 then
					--local PlayerPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
					if #StoredCoordsT < 5000 then
						StoredCoordsT[#StoredCoordsT+1] = {Pos = PlayerPos, Rot = PlayerRot}
					else
						table.remove(StoredCoordsT, 1)
						StoredCoordsT[#StoredCoordsT+1] = {Pos = PlayerPos, Rot = PlayerRot}
					end
				end
			end
			local FirstAliveID = 0
			local LastID = 1
			local LastIDIsDead = false
			for i = 1, #CopVehsT do
				if CopVehsT[i] ~= nil then
					if ENTITY.DOES_ENTITY_EXIST(CopVehsT[i].Handle) then
						CopVehsT[i].VehDestroyed = ENTITY.IS_ENTITY_DEAD(CopVehsT[i].Handle)
						if not CopVehsT[i].VehDestroyed then
							if FirstAliveID == 0 then
								FirstAliveID = i
							end
						end
						if CopsFollowLikeSnake then
							if #StoredCoordsT > 100 then
								local Index = (#StoredCoordsT - 25) - 25 * i
								if StoredCoordsT[Index] ~= nil then
									if not ENTITY.IS_ENTITY_AT_COORD(CopVehsT[i].Handle, StoredCoordsT[Index].Pos.x, StoredCoordsT[Index].Pos.y, StoredCoordsT[Index].Pos.z, 20.0, 20.0, 20.0, false, true, 0) then
										ENTITY.SET_ENTITY_COORDS(CopVehsT[i].Handle, StoredCoordsT[Index].Pos.x, StoredCoordsT[Index].Pos.y, StoredCoordsT[Index].Pos.z)
									end
									if PlayerVeh ~= 0 then
										SetEntitySpeedToCoord(CopVehsT[i].Handle, StoredCoordsT[Index].Pos, SpdMul, false, false, false, 0.0, 0.0, 0.0, false, false)
										RotateEntityToTargetRotation(CopVehsT[i].Handle, StoredCoordsT[Index].Rot, RotSpd, false)
									end
								end
							end
						end
						if CopsFollowLikeSnake2 then
							if not CopVehsT[i].VehDestroyed then
								if CopVehsT[i].CurRot == nil then
									CopVehsT[i].CurRot = ENTITY.GET_ENTITY_ROTATION(CopVehsT[i].Handle, 2)
									local Min, Max = v3.new(), v3.new()
									MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(CopVehsT[i].Handle), Min, Max)
									CopVehsT[i].ModelMin = Min
									CopVehsT[i].ModelMax = Max
									if i == FirstAliveID then
										ENTITY.SET_ENTITY_COORDS(CopVehsT[i].Handle, PlayerOffset.x, PlayerOffset.y, PlayerOffset.z)
										ENTITY.SET_ENTITY_ROTATION(CopVehsT[i].Handle, PVehRot.x, PVehRot.y, PVehRot.z, 5)
									else
										local Offset = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(CopVehsT[LastID].Handle, 0.0, (-CopVehsT[LastID].ModelMax.y  * 2.0) + 1.0, 0.0)
										CopVehsT[i].CurRot = ENTITY.GET_ENTITY_ROTATION(CopVehsT[LastID].Handle, 2)
										ENTITY.SET_ENTITY_COORDS(CopVehsT[i].Handle, Offset.x, Offset.y, Offset.z)
										ENTITY.SET_ENTITY_ROTATION(CopVehsT[i].Handle, CopVehsT[i].CurRot.x, CopVehsT[i].CurRot.y, CopVehsT[i].CurRot.z, 2)
									end
								end
								if i == FirstAliveID then
									--CopVehsT[i].CurRot = InterpolateRotWithLimit(CopVehsT[i].CurRot, PVehRot, 1.0, VehSpeed)
									--local Offset = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PlayerVeh, 0.0, -PMax.y + PMin.y, 0.0)
									local IsInAir = ENTITY.IS_ENTITY_IN_AIR(CopVehsT[i].Handle)
									SetEntitySpeedToCoord(CopVehsT[i].Handle, PlayerOffset, math.clamp(VehSpeed, 0.0, 1.0), false, false, IsInAir, 0.0, 0.0, 0.0, false, false)
									--local Txt = "CopVehsT[1].CurRot: x: "..string.format("%0.3f", CopVehsT[i].CurRot.x).." y: "..string.format("%0.3f", CopVehsT[i].CurRot.y).." z: "..string.format("%0.3f", CopVehsT[i].CurRot.z)
									--directx.draw_text(0.7, 0.5, Txt, ALIGN_CENTRE, 1.0, {r = 0.0, g = 1.0 , b = 1.0, a = 1.0}, false)
									local CopVehPos = ENTITY.GET_ENTITY_COORDS(CopVehsT[i].Handle)
									--local LookAt = V3_LookAt(Pos, PlayerPos)
									local SLookAt = v3.lookAt(CopVehPos, PlayerPos)
									--local Txt = "LookAt: x: "..string.format("%0.3f", LookAt.x).." y: "..string.format("%0.3f", LookAt.y).." z: "..string.format("%0.3f", LookAt.z)
									--directx.draw_text(0.7, 0.5, Txt, ALIGN_CENTRE, 1.0, {r = 0.0, g = 1.0 , b = 1.0, a = 1.0}, false)
									--local Txt2 = "SLookAt: x: "..string.format("%0.3f", SLookAt.x).." y: "..string.format("%0.3f", SLookAt.y).." z: "..string.format("%0.3f", SLookAt.z)
									--directx.draw_text(0.7, 0.55, Txt2, ALIGN_CENTRE, 1.0, {r = 0.0, g = 1.0 , b = 1.0, a = 1.0}, false)
									--SLookAt.x = 0.0 --wrap180(SLookAt.x - 90.0)
									--SLookAt.y = 0.0 --wrap180(SLookAt.x - 90.0)
									CopVehsT[i].CurRot = SLookAt
								else
									--local OtherVehRot = ENTITY.GET_ENTITY_ROTATION(CopVehsT[i-1].Handle, 5)
									--CopVehsT[i].CurRot = InterpolateRotWithLimit(CopVehsT[i].CurRot, OtherVehRot, 1.0, VehSpeed)
									local IsInAir = ENTITY.IS_ENTITY_IN_AIR(CopVehsT[i].Handle)
									local Offset = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(CopVehsT[LastID].Handle, 0.0, (-CopVehsT[LastID].ModelMax.y  * 2.0) + 1.0, 0.0)
									SetEntitySpeedToCoord(CopVehsT[i].Handle, Offset, math.clamp(VehSpeed, 0.0, 1.0), false, false, IsInAir, 0.0, 0.0, 0.0, false, false)
									--CopVehsT[i].CurRot = ENTITY.GET_ENTITY_ROTATION(CopVehsT[LastID].Handle, 5)
									local CopVehPos = ENTITY.GET_ENTITY_COORDS(CopVehsT[i].Handle)
									local ToPos = ENTITY.GET_ENTITY_COORDS(CopVehsT[LastID].Handle)
									local LookAt = v3.lookAt(CopVehPos, ToPos)
									--LookAt.x = 0.0--wrap180(LookAt.x - 90.0)
									--LookAt.y = 0.0--wrap180(LookAt.x - 90.0)
									--LookAt.z = wrap180(LookAt.z - 90.0)
									CopVehsT[i].CurRot = LookAt
								end
								local NewRot = convertRotationXYZtoZYX(CopVehsT[i].CurRot.x, CopVehsT[i].CurRot.y, CopVehsT[i].CurRot.z)
								RotateEntityToTargetRotation(CopVehsT[i].Handle, NewRot, 1.0, false)
								--if i == FirstAliveID then
								--	local Txt = "CopVehsT[i].CurRot: x: "..string.format("%0.3f", CopVehsT[i].CurRot.x).." y: "..string.format("%0.3f", CopVehsT[i].CurRot.y).." z: "..string.format("%0.3f", CopVehsT[i].CurRot.z)
								--	directx.draw_text(0.7, 0.5, Txt, ALIGN_CENTRE, 1.0, {r = 0.0, g = 1.0 , b = 1.0, a = 1.0}, false)
								--	local Txt2 = "NewRot: x: "..string.format("%0.3f", NewRot.x).." y: "..string.format("%0.3f", NewRot.y).." z: "..string.format("%0.3f", NewRot.z)
								--	directx.draw_text(0.7, 0.55, Txt2, ALIGN_CENTRE, 1.0, {r = 0.0, g = 1.0 , b = 1.0, a = 1.0}, false)
								--	local Txt3 = "PVehRot: x: "..string.format("%0.3f", PVehRot.x).." y: "..string.format("%0.3f", PVehRot.y).." z: "..string.format("%0.3f", PVehRot.z)
								--	directx.draw_text(0.7, 0.6, Txt3, ALIGN_CENTRE, 1.0, {r = 0.0, g = 1.0 , b = 1.0, a = 1.0}, false)
								--end
							end
						end
						if CopVehsT[i].VehDestroyed then
							LastIDIsDead = true
						else
							LastIDIsDead = false
							LastID = i
						end
						if CopsRushedFollow then
							if CopVehsT[i].Passengers[1] ~= nil then
								if OperationT[CopVehsT[i].Passengers[1]] == nil then
									local VehHandle = CopVehsT[i].Handle
									local VehClass = VEHICLE.GET_VEHICLE_CLASS(VehHandle)
									if VehClass ~= 15 and VehClass ~= 16 then
										local VehPos = ENTITY.GET_ENTITY_COORDS(VehHandle)
										local TargetPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
										local Distance = MISC.GET_DISTANCE_BETWEEN_COORDS(TargetPos.x, TargetPos.y, TargetPos.z, VehPos.x, VehPos.y, VehPos.z, true)
										if CopVehsT[i].LastDistance == nil then
											CopVehsT[i].LastDistance = Distance
										end
										local NormZ = 0.0
										local EntSpeed = ENTITY.GET_ENTITY_SPEED_VECTOR(VehHandle, true)
										local EntSpeedTotal = ENTITY.GET_ENTITY_SPEED(VehHandle)
										local BoneIndex = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(VehHandle, "steeringwheel")
										local EntVel = ENTITY.GET_ENTITY_VELOCITY(VehHandle)
										local FVect, RVect, UpVect, Vect = v3.new(), v3.new(), v3.new(), v3.new()
										ENTITY.GET_ENTITY_MATRIX(VehHandle, FVect, RVect, UpVect, Vect)
										local AdjustedVect = {x = VehPos.x + FVect.x * 6.0, y = VehPos.y + FVect.y * 6.0, z = VehPos.z + FVect.z * 6.0}
										local Norm = v3.new()
										if BoneIndex ~= 0 then
											local Rot = ENTITY.GET_ENTITY_BONE_OBJECT_ROTATION(VehHandle, BoneIndex)
											Norm = v3.normalise(Rot)
											NormZ = Rot.y
										end
										local NormZAbs = math.abs(NormZ)
										if Distance <= CopVehsT[i].LastDistance then
											if RequestControlOfEntity(VehHandle) then
												if EntSpeed.y > 3.0 and EntSpeed.y < 50.0 then
													ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, NormZ * 0.005 * EntSpeed.y, (1.0 - NormZAbs) * 0.01 * EntSpeed.y, 0.0, 0, true, true, false)
												end
												local ForceZ = 0.0
												EntSpeed = ENTITY.GET_ENTITY_SPEED_VECTOR(VehHandle, true)
												if ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(VehHandle) > 1.1 then --or EntSpeed.x > 1.0 or EntSpeed.x < -1.0 then
													ForceZ = -1.50
												end
												ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, 0.0, 0.0, ForceZ, 0, false, true, false)
												if EntSpeed.y >= 3.0 then
													ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, NormZ * 0.005 * EntSpeed.y, -NormZAbs * 0.01 * EntSpeed.y, 0.0, 0, true, true, false)
												end
												local AdjustedVect2 = {x = VehPos.x + FVect.x * EntSpeed.y * DistanceMult, y = VehPos.y + FVect.y * EntSpeed.y * DistanceMult, z = VehPos.z + FVect.z * EntSpeed.y * DistanceMult}
												local EndCoords2, DidHit2, EntHit2, SurfaceNormal2 = ShapeTestNav(VehHandle, VehPos, AdjustedVect2)
												if DidHit2 and EntSpeed.y >= 2.0 then
													ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, 0.0, -1.0, 0.0, 0, true, true, false)
												end
												local AdjustedVect3 = {x = VehPos.x + RVect.x * 2.0, y = VehPos.y + RVect.y * 2.0, z = VehPos.z + RVect.z * 2.0}
												local EndCoords3, DidHit3, EntHit3, SurfaceNormal3 = ShapeTestNav(VehHandle, VehPos, AdjustedVect3)
												if DidHit3 then
													ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, -1.0, 0.0, 0.0, 0, true, true, false)
												end
												local AdjustedVect4 = {x = VehPos.x - RVect.x * 2.0, y = VehPos.y - RVect.y * 2.0, z = VehPos.z - RVect.z * 2.0}
												local EndCoords4, DidHit4, EntHit4, SurfaceNormal4 = ShapeTestNav(VehHandle, VehPos, AdjustedVect4)
												if DidHit4 then
													ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, 1.0, 0.0, 0.0, 0, true, true, false)
												end
												ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 5, 0.0, 0.0, -NormZ * 0.0005 * EntSpeed.y, 0, false, true, false)
											end
										else
											if Distance < CopVehsT[i].LastDistance then
												CopVehsT[i].LastDistance = Distance
											end
										end
									end
								end
							end
						end
						if not CopVehsT[i].HasSetToMissionEnt then
							if RequestControlOfEntity(CopVehsT[i].Handle) then
								ENTITY.SET_ENTITY_AS_MISSION_ENTITY(CopVehsT[i].Handle, false, true)
								local VehAddr = entities.handle_to_pointer(CopVehsT[i].Handle) + 0xD8
								if VehAddr ~= 0 then
									memory.write_int(VehAddr, 460962)
								end
								CopVehsT[i].NetID = 0
								if SetNetworkID then
									local NetID = NETWORK.VEH_TO_NET(CopVehsT[i].Handle)
									if NetID ~= 0 then
										NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PlayerID, true)
										CopVehsT[i].NetID = NetID
									end
								end
								CopVehsT[i].HasSetToMissionEnt = true
							end
						end
						local Peds = CopVehsT[i].Passengers
						local Count = 0
						local DeadCount = 0
						for k = 1, #Peds do
							if ENTITY.DOES_ENTITY_EXIST(Peds[k]) then
								local IsDead = ENTITY.IS_ENTITY_DEAD(Peds[k])
								if not ENTITY.IS_ENTITY_AT_ENTITY(Peds[k], CopVehsT[i].Handle, 130.0, 130.0, 130.0, false, true, 0) and not IsDead then
									Count = Count + 1
								end
								if IsDead then
									DeadCount = DeadCount + 1
								else
									if ControlVehicle then
										if CopVehsT[i].Tick <= 0 then
											if PlayerVeh == CopVehsT[i].Handle then
												if VEHICLE.GET_PED_IN_VEHICLE_SEAT(CopVehsT[i].Handle, -1, false) == Peds[k] then
													local LRNormal = PAD.GET_CONTROL_NORMAL(0, 30)
													local UDNormal = -PAD.GET_CONTROL_NORMAL(0, 31)
													if LRNormal ~= 0.0 or UDNormal ~= 0.0 then
														local FVect, RVect, UpVect, Vect = v3.new(), v3.new(), v3.new(), v3.new()
														ENTITY.GET_ENTITY_MATRIX(CopVehsT[i].Handle, FVect, RVect, UpVect, Vect)
														local AdjustedVect = {
															x = Vect.x + ((FVect.x * 10.0 * UDNormal) + (RVect.x * 5.0 * LRNormal)),
															y = Vect.y + ((FVect.y * 10.0 * UDNormal) + (RVect.y * 5.0 * LRNormal)),
															z = Vect.z + ((FVect.z * 10.0 * UDNormal) + (RVect.z * 5.0 * LRNormal))
														}
														TASK.TASK_VEHICLE_DRIVE_TO_COORD(Peds[k], CopVehsT[i].Handle, AdjustedVect.x, AdjustedVect.y, AdjustedVect.z, 100.0, 1, ENTITY.GET_ENTITY_MODEL(CopVehsT[i].Handle), 262144, 1.0, 40000.0)
														CopVehsT[i].Tick = 2
													end
												end
											end
										else
											CopVehsT[i].Tick = CopVehsT[i].Tick - 1
										end
									end
								end
							end
						end
						if DeadCount >= #Peds then --Count >= #Peds or ENTITY.IS_ENTITY_DEAD(CopVehsT[i].Handle) or DeadCount >= #Peds then
							if RequestControlOfEntity(CopVehsT[i].Handle) then
								set_entity_as_no_longer_needed(CopVehsT[i].Handle)
							end
						else
							--if not ENTITY.IS_ENTITY_A_MISSION_ENTITY(CopVehsT[i].Handle) then --or not ENTITY.IS_ENTITY_DEAD(CopVehsT[i].Handle) then
								--CopVehsT[i].HasSetToMissionEnt = false
							--end
						end
					else
						FoundCopVehs[CopVehsT[i].Handle] = nil
						table.remove(CopVehsT, i)
					end
				end
			end
			--ZombieMode
			local MoveDict = "move_characters@ballas@core"
			if ZombieMode then
				--if not STREAMING.HAS_CLIP_SET_LOADED(MoveDict) then 
				--	STREAMING.REQUEST_CLIP_SET(MoveDict)
				--end
			end
			for i = 1, #ZombiesT do
				if ZombiesT[i] ~= nil then
					if ENTITY.DOES_ENTITY_EXIST(ZombiesT[i].Handle) then
						if not ENTITY.IS_ENTITY_DEAD(ZombiesT[i].Handle) then
							--if STREAMING.HAS_CLIP_SET_LOADED(MoveDict) then
							--	PED.SET_PED_MOVEMENT_CLIPSET(ZombiesT[i].Handle, MoveDict, 0.25)
							--end
							--PED.SET_PED_MOVEMENT_CLIPSET(ZombiesT[i].Handle, "move_m@multiplayer", 0.25)
							PED.SET_PED_MIN_MOVE_BLEND_RATIO(ZombiesT[i].Handle, 3.0)
							--PED.SET_PED_MAX_MOVE_BLEND_RATIO(ZombiesT[i].Handle, 3.0)
							PED.SET_PED_USING_ACTION_MODE(ZombiesT[i].Handle, false, -1, 0)
							if ZombiesT[i].Target == 0 then
								TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(ZombiesT[i].Handle, 100.0, 0)
								Target = PED.GET_PED_TARGET_FROM_COMBAT_PED(ZombiesT[i].Handle, 0)
								if Target ~= 0 then
									ZombiesT[i].Target = Target
								else
									ZombiesT[i].Target = GetPedNearestTarget(ZombiesT[i].Handle, false)
								end
								if not ENTITY.IS_ENTITY_AT_ENTITY(ZombiesT[i].Handle, PlayerPed, 100.0, 100.0, 100.0, false, true, 0) then
									if RequestControlOfEntity(ZombiesT[i].Handle) then
										local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
										local OutPos, FoundCoords = find_right_spawn_normal(PPos.x, PPos.y, PPos.z, 40.0, 70.0)
										if FoundCoords then
											if not MISC.IS_POSITION_OCCUPIED(OutPos.x, OutPos.y, OutPos.z, 1.0, false, true, true, false, false, PlayerPed, true) then
												ENTITY.SET_ENTITY_COORDS(ZombiesT[i].Handle, OutPos.x, OutPos.y, OutPos.z)
												ENTITY.SET_ENTITY_HEADING(ZombiesT[i].Handle, math.random(0, 360))
											end
										end
									end
								end
							end
							if ZombiesT[i].Target ~= 0 then
								if ENTITY.DOES_ENTITY_EXIST(ZombiesT[i].Target) and not ENTITY.IS_ENTITY_DEAD(ZombiesT[i].Target)
								and ENTITY.IS_ENTITY_AT_ENTITY(ZombiesT[i].Handle, ZombiesT[i].Target, 100.0, 100.0, 100.0, false, true, 0) then
									--TASK.TASK_GO_TO_ENTITY(ZombiesT[i].Handle, ZombiesT[i].Target, -1, 0.5, 3.0, 0.1, 0)
									--TASK.TASK_COMBAT_PED(ZombiesT[i].Handle, ZombiesT[i].Target, 134217728, 0)
									if PED.IS_PED_ON_VEHICLE(ZombiesT[i].Target) then
										if not ENTITY.IS_ENTITY_AT_ENTITY(ZombiesT[i].Handle, ZombiesT[i].Target, 3.0, 3.0, 3.0, false, true, 0) then
											local FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(ZombiesT[i].Target)
											local Cors = ENTITY.GET_ENTITY_COORDS(ZombiesT[i].Target)
											local NewCors = {x = Cors.x + FVect.x, y = Cors.y + FVect.y, z = Cors.z + FVect.z}
											if not MISC.IS_POSITION_OCCUPIED(NewCors.x, NewCors.y, NewCors.z, 1.0, false, false, true, false, false, ZombiesT[i].Target, true) then
												ENTITY.SET_ENTITY_COORDS(ZombiesT[i].Handle, NewCors.x, NewCors.y, NewCors.z, true, false, false, true)
											end
										end
									end
									ZombiesT[i].Target = GetPedNearestTarget(ZombiesT[i].Handle, false)
								else
									ZombiesT[i].Target = 0
									TASK.CLEAR_PED_TASKS(ZombiesT[i].Handle)
								end
							end
						else
							set_entity_as_no_longer_needed(ZombiesT[i].Handle)
							table.remove(ZombiesT, i)
							break
						end
					else
						table.remove(ZombiesT, i)
						break
					end
				end
			end
			for i = 1, #EditedDamageEntsHandles do
				if EditedDamageEntsHandles[i] ~= nil then
					if ENTITY.DOES_ENTITY_EXIST(EditedDamageEntsHandles[i]) and not ENTITY.IS_ENTITY_DEAD(EditedDamageEntsHandles[i]) then
						local peds = EditedDamageEntsHandles[i]
						if RequestControlOfEntity(peds) then
							ENTITY.SET_ENTITY_ONLY_DAMAGED_BY_PLAYER(peds, false)
							local Veh = PED.GET_VEHICLE_PED_IS_IN(peds, false)
							if Veh ~= 0 then
								ENTITY.SET_ENTITY_ONLY_DAMAGED_BY_PLAYER(Veh, false)
								ENTITY.SET_ENTITY_CAN_ONLY_BE_DAMAGED_BY_SCRIPT_PARTICIPANTS(Veh, false)
							end
							if RelHashBackup ~= 0 then
								ENTITY.SET_ENTITY_CAN_BE_DAMAGED_BY_RELATIONSHIP_GROUP(peds, true, RelHashBackup)
							end
							ENTITY.SET_ENTITY_CAN_BE_DAMAGED_BY_RELATIONSHIP_GROUP(peds, true, SelectedTeam)
							ENTITY.SET_ENTITY_CAN_ONLY_BE_DAMAGED_BY_SCRIPT_PARTICIPANTS(peds, false)
						end
					else
						EditedDamageEnts[EditedDamageEntsHandles[i]] = nil
						EditedDamageEntsHandles[i] = nil
					end
				end
			end
			TaskArgs.MissionCopCount = MissionCopCount
			if ApplyCopSettings then
				if AutomaticGenCops then
					if not ClearedWantedLevel then
						if MissionCopCount >= MaxCopsToEdit then
							PLAYER.SET_PLAYER_WANTED_LEVEL(PlayerID, 0, false)
							PLAYER.SET_PLAYER_WANTED_LEVEL_NOW(PlayerID, false)
						else
							PLAYER.SET_DISPATCH_COPS_FOR_PLAYER(PlayerID, true)
							PLAYER.SET_MAX_WANTED_LEVEL(5)
							PLAYER.SET_PLAYER_WANTED_LEVEL(PlayerID, 5, false)
							PLAYER.SET_PLAYER_WANTED_LEVEL_NOW(PlayerID, false)
						end
					end
				end
			end
			if CopsHelpInMissions then
				local Blips = {}
				local PlayerPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
				for k = 1, #BlipsToFind do
					local Blip = HUD.GET_CLOSEST_BLIP_INFO_ID(BlipsToFind[k])
					if Blip ~= 0 then
						local Entity = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(Blip)
						Blips[#Blips+1] = {Handle = Blip, Coords = HUD.GET_BLIP_COORDS(Blip), Color = HUD.GET_BLIP_COLOUR(Blip), Entity = Entity, EntityType = ENTITY.GET_ENTITY_TYPE(Entity)}
					end
				end
				
				for k = 1, #CopsInMissionT do
					if ENTITY.DOES_ENTITY_EXIST(CopsInMissionT[k].Handle) and not ENTITY.IS_ENTITY_DEAD(CopsInMissionT[k].Handle) then
						local InCombat = PED.IS_PED_IN_COMBAT(CopsInMissionT[k].Handle, 0) and CopsInMissionT[k].CombatTarget == 0
						local PCoords = ENTITY.GET_ENTITY_COORDS(CopsInMissionT[k].Handle)
						if not is_bit_set(CopsInMissionT[k].Bits, 1) then
							OperationT[CopsInMissionT[k].Handle] = nil
							if not InCombat then
								if #Blips > 0 then
									local RandomID = math.random(#Blips)
									CopsInMissionT[k].BlipHandle = Blips[RandomID].Handle
									if Blips[RandomID].Color == 1 then
										if Blips[RandomID].Entity ~= 0 then
											if Blips[RandomID].EntityType == 1 then
												if ENTITY.DOES_ENTITY_EXIST(Blips[RandomID].Entity) and not ENTITY.IS_ENTITY_DEAD(Blips[RandomID].Entity) then
													TASK.TASK_COMBAT_PED(CopsInMissionT[k].Handle, Blips[RandomID].Entity, 0, 16)
													CopsInMissionT[k].Target = Blips[RandomID].Entity
													CopsInMissionT[k].CombatTarget = Blips[RandomID].Entity
													CopsInMissionT[k].TargetType = Blips[RandomID].EntityType
													CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 1)
													if not is_bit_set(CopsInMissionT[k].Bits, 2) then
														CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 2)
													end
												end
											elseif Blips[RandomID].EntityType == 2 then
												if ENTITY.DOES_ENTITY_EXIST(Blips[RandomID].Entity) and not ENTITY.IS_ENTITY_DEAD(Blips[RandomID].Entity) then
													local Veh = PED.GET_VEHICLE_PED_IS_IN(CopsInMissionT[k].Handle, true)
													if Veh ~= 0 then
														if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == CopsInMissionT[k].Handle then
															CopsInMissionT[k].TargetType = Blips[RandomID].EntityType
															CopsInMissionT[k].Target = Blips[RandomID].Entity
															local Coords = ENTITY.GET_ENTITY_COORDS(Blips[RandomID].Entity)
															TASK.TASK_VEHICLE_MISSION(CopsInMissionT[k].Handle, Veh, Blips[RandomID].Entity, 6, 1000.0, 1, 1, 4.0, true)
															CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 1)
															if not is_bit_set(CopsInMissionT[k].Bits, 2) then
																CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 2)
															end
														end
													end
												end
											elseif Blips[RandomID].EntityType == 3 then
												if ENTITY.DOES_ENTITY_EXIST(Blips[RandomID].Entity) and not ENTITY.IS_ENTITY_DEAD(Blips[RandomID].Entity) then
													local Veh = PED.GET_VEHICLE_PED_IS_IN(CopsInMissionT[k].Handle, true)
													if Veh ~= 0 and not ENTITY.IS_ENTITY_AT_ENTITY(CopsInMissionT[k].Handle, Blips[RandomID].Entity, 30.0, 30.0, 30.0, false, true, false) then
														if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == CopsInMissionT[k].Handle then
															CopsInMissionT[k].TaskCoord = Blips[RandomID].Coords
															CopsInMissionT[k].TargetType = Blips[RandomID].EntityType
															CopsInMissionT[k].Target = Blips[RandomID].Entity
															local TaskID = memory.alloc(8)
															TASK.OPEN_SEQUENCE_TASK(TaskID)
															TASK.TASK_VEHICLE_DRIVE_TO_COORD(0, Veh, Blips[RandomID].Coords.x, Blips[RandomID].Coords.y, Blips[RandomID].Coords.z, 1000.0, 1, ENTITY.GET_ENTITY_MODEL(Veh), 786469, 4.0, 30.0)
															TASK.TASK_GO_TO_ENTITY_WHILE_AIMING_AT_ENTITY(0, Blips[RandomID].Entity, Blips[RandomID].Entity, 2.0, true, 0.1, 0.1, true, false, joaat("FIRING_PATTERN_FULL_AUTO"))
															TASK.CLOSE_SEQUENCE_TASK(memory.read_int(TaskID))
															TASK.TASK_PERFORM_SEQUENCE(CopsInMissionT[k].Handle, memory.read_int(TaskID))
															CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 1)
															if not is_bit_set(CopsInMissionT[k].Bits, 2) then
																CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 2)
															end
														end
													else
														CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 1)
														if not is_bit_set(CopsInMissionT[k].Bits, 2) then
															CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 2)
														end
														CopsInMissionT[k].TaskCoord = Blips[RandomID].Coords
														CopsInMissionT[k].TargetType = Blips[RandomID].EntityType
														CopsInMissionT[k].Target = Blips[RandomID].Entity
														TASK.TASK_GO_TO_ENTITY_WHILE_AIMING_AT_ENTITY(CopsInMissionT[k].Handle, Blips[RandomID].Entity, Blips[RandomID].Entity, 2.0, true, 0.1, 0.1, true, false, joaat("FIRING_PATTERN_FULL_AUTO"))
													end
												end
											end
										end
									elseif Blips[RandomID].Color == 2 or Blips[RandomID].Color == 3 or Blips[RandomID].Color == 5 then
										if Blips[RandomID].Entity ~= 0 then
											if Blips[RandomID].EntityType == 2 then
												local Veh = PED.GET_VEHICLE_PED_IS_IN(CopsInMissionT[k].Handle, true)
												if Veh ~= 0 and not ENTITY.IS_ENTITY_AT_ENTITY(CopsInMissionT[k].Handle, Blips[RandomID].Entity, 30.0, 30.0, 30.0, false, true, false) then
													if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == CopsInMissionT[k].Handle then
														CopsInMissionT[k].TaskCoord = Blips[RandomID].Coords
														CopsInMissionT[k].TargetType = Blips[RandomID].EntityType
														CopsInMissionT[k].Target = Blips[RandomID].Entity
														local TaskID = memory.alloc(8)
														TASK.OPEN_SEQUENCE_TASK(TaskID)
														TASK.TASK_VEHICLE_DRIVE_TO_COORD(0, Veh, Blips[RandomID].Coords.x, Blips[RandomID].Coords.y, Blips[RandomID].Coords.z, 1000.0, 1, ENTITY.GET_ENTITY_MODEL(Veh), 786469, 4.0, 30.0)
														TASK.TASK_ENTER_VEHICLE(0, Veh, -1, -1, 3.0, 0, 0, 0)
														TASK.CLOSE_SEQUENCE_TASK(memory.read_int(TaskID))
														TASK.TASK_PERFORM_SEQUENCE(CopsInMissionT[k].Handle, memory.read_int(TaskID))
														CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 1)
														if not is_bit_set(CopsInMissionT[k].Bits, 4) then
															CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 4)
														end
													end
												else
													CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 1)
													if not is_bit_set(CopsInMissionT[k].Bits, 4) then
														CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 4)
													end
													CopsInMissionT[k].TaskCoord = Blips[RandomID].Coords
													CopsInMissionT[k].TargetType = Blips[RandomID].GetEntityType
													CopsInMissionT[k].Target = Blips[RandomID].Entity
													TASK.TASK_ENTER_VEHICLE(CopsInMissionT[k].Handle, Veh, -1, -1, 3.0, 0, 0, 0)
												end
											elseif Blips[RandomID].EntityType == 3 then
												if OBJECT.IS_OBJECT_A_PORTABLE_PICKUP(Blips[RandomID].Entity) then
													local Veh = PED.GET_VEHICLE_PED_IS_IN(CopsInMissionT[k].Handle, true)
													if Veh ~= 0 and not ENTITY.IS_ENTITY_AT_ENTITY(CopsInMissionT[k].Handle, Blips[RandomID].Entity, 30.0, 30.0, 30.0, false, true, false) then
														if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == CopsInMissionT[k].Handle then
															CopsInMissionT[k].TaskCoord = Blips[RandomID].Coords
															CopsInMissionT[k].TargetType = Blips[RandomID].EntityType
															CopsInMissionT[k].Target = Blips[RandomID].Entity
															local TaskID = memory.alloc(8)
															TASK.OPEN_SEQUENCE_TASK(TaskID)
															TASK.TASK_VEHICLE_DRIVE_TO_COORD(0, Veh, Blips[RandomID].Coords.x, Blips[RandomID].Coords.y, Blips[RandomID].Coords.z, 1000.0, 1, ENTITY.GET_ENTITY_MODEL(Veh), 786469, 4.0, 30.0)
															TASK.TASK_GO_TO_ENTITY(0, Blips[RandomID].Entity, -1, 0.1, 3.0, 0.5, 1)
															TASK.CLOSE_SEQUENCE_TASK(memory.read_int(TaskID))
															TASK.TASK_PERFORM_SEQUENCE(CopsInMissionT[k].Handle, memory.read_int(TaskID))
															CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 1)
															if not is_bit_set(CopsInMissionT[k].Bits, 3) then
																CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 3)
															end
														end
													else
														CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 1)
														if not is_bit_set(CopsInMissionT[k].Bits, 3) then
															CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 3)
														end
														CopsInMissionT[k].TaskCoord = Blips[RandomID].Coords
														CopsInMissionT[k].TargetType = Blips[RandomID].GetEntityType
														CopsInMissionT[k].Target = Blips[RandomID].Entity
														TASK.TASK_GO_TO_ENTITY(CopsInMissionT[k].Handle, Blips[RandomID].Entity, -1, 0.1, 3.0, 0.5, 1)
													end
												end
											end
										else
											local Veh = PED.GET_VEHICLE_PED_IS_IN(CopsInMissionT[k].Handle, true)
											if Veh ~= 0 then
												if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == CopsInMissionT[k].Handle then
													CopsInMissionT[k].TaskCoord = Blips[RandomID].Coords
													CopsInMissionT[k].TargetType = Blips[RandomID].EntityType
													CopsInMissionT[k].Target = Blips[RandomID].Entity
													TASK.TASK_VEHICLE_DRIVE_TO_COORD(CopsInMissionT[k].Handle, Veh, Blips[RandomID].Coords.x, Blips[RandomID].Coords.y, Blips[RandomID].Coords.z, 1000.0, 1, ENTITY.GET_ENTITY_MODEL(Veh), 786469, 4.0, 30.0)
													CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 1)
													if not is_bit_set(CopsInMissionT[k].Bits, 5) then
														CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 5)
													end
												end
											else
												CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 1)
												if not is_bit_set(CopsInMissionT[k].Bits, 5) then
													CopsInMissionT[k].Bits = set_bit(CopsInMissionT[k].Bits, 5)
												end
												CopsInMissionT[k].TaskCoord = Blips[RandomID].Coords
												CopsInMissionT[k].TargetType = Blips[RandomID].GetEntityType
												CopsInMissionT[k].Target = Blips[RandomID].Entity
												TASK.TASK_GO_TO_COORD_ANY_MEANS(CopsInMissionT[k].Handle, Blips[RandomID].Coords.x, Blips[RandomID].Coords.y, Blips[RandomID].Coords.z, 3.0, 0, true, 786469, -1.0)
											end
										end
									end
								end
							end
						else
							if OperationT[CopsInMissionT[k].Handle] == nil then
								OperationT[CopsInMissionT[k].Handle] = {
									Handle = CopsInMissionT[k].Handle, XOffset = 0.0, YOffset = 0,
									X = 0.0, Y = 0.0, Z = 0.0, Heading = 0,
									TaskStatus = 41, VehHandle = Veh, FVect = FVect, RVect = RVect, UpVect = UpVect,
									Vect = Vect, IsPilot = false
								}
							end
							if is_bit_set(CopsInMissionT[k].Bits, 2) then
								if CopsInMissionT[k].Target ~= 0 then
									if CopsInMissionT[k].TargetType == 1 or CopsInMissionT[k].TargetType == 2 then
										if not ENTITY.DOES_ENTITY_EXIST(CopsInMissionT[k].Target) or ENTITY.IS_ENTITY_DEAD(CopsInMissionT[k].Target)
										or not HUD.DOES_BLIP_EXIST(CopsInMissionT[k].BlipHandle) then
											CopsInMissionT[k].Bits = clear_bit(CopsInMissionT[k].Bits, 1)
											CopsInMissionT[k].Bits = clear_bit(CopsInMissionT[k].Bits, 2)
											TASK.CLEAR_PED_TASKS(CopsInMissionT[k].Handle)
											CopsInMissionT[k].Target = 0
											CopsInMissionT[k].TargetType = 0
											CopsInMissionT[k].CombatTarget = 0
										else
											local TCoords = ENTITY.GET_ENTITY_COORDS(CopsInMissionT[k].Target)
											local Distance = DistanceBetween(PCoords.x, PCoords.y, PCoords.z, TCoords.x, TCoords.y, TCoords.z)
											if Distance > 30.0 then
												if TASK.GET_SCRIPT_TASK_STATUS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_VEHICLE_MISSION")) == 7 then
													local Veh = PED.GET_VEHICLE_PED_IS_IN(CopsInMissionT[k].Handle, true)
													if Veh == 0 then
														Veh = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(CopsInMissionT[k].Handle)
													end
													if Veh == 0 and TASK.GET_SCRIPT_TASK_STATUS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_GO_TO_COORD_ANY_MEANS")) == 7 then
														TASK.TASK_GO_TO_COORD_ANY_MEANS(CopsInMissionT[k].Handle, PlayerPos.x, PlayerPos.y, PlayerPos.z, 3.0, 0, true, 786469, -1.0)
													end
													if Veh ~= 0 then
														local CanCall = true
														if PED.IS_PED_IN_VEHICLE(CopsInMissionT[k].Handle, Veh, false) then
															local Ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false)
															if Ped ~= 0 then
																if Ped ~= CopsInMissionT[k].Handle then
																	CanCall = false
																end
															end
														end
														if CanCall then
															TASK.TASK_VEHICLE_MISSION_PED_TARGET(CopsInMissionT[k].Handle, Veh, CopsInMissionT[k].Target, 2, 1000.0, 786469, 4.0, 8.0, true)
														end
													end
												end
											else
												if CopsInMissionT[k].TargetType == 1 then
													if not PED.IS_PED_IN_COMBAT(CopsInMissionT[k].Handle, 0) then
														TASK.TASK_COMBAT_PED(CopsInMissionT[k].Handle, CopsInMissionT[k].Target, 0, 16)
													end
												else
													if TASK.GET_SCRIPT_TASK_STATUS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_GO_TO_ENTITY_WHILE_AIMING_AT_ENTITY")) == 7 then
														TASK.TASK_GO_TO_ENTITY_WHILE_AIMING_AT_ENTITY(CopsInMissionT[k].Handle, CopsInMissionT[k].Target, CopsInMissionT[k].Target, 2.0, true, 0.1, 0.1, true, false, joaat("FIRING_PATTERN_FULL_AUTO"))
													end
												end
											end
										end
									end
									if CopsInMissionT[k].TargetType == 3 then
										if ENTITY.DOES_ENTITY_EXIST(CopsInMissionT[k].Target) then
											if OBJECT.HAS_OBJECT_BEEN_BROKEN(CopsInMissionT[k].Target, true)
											or not HUD.DOES_BLIP_EXIST(CopsInMissionT[k].BlipHandle) then
												CopsInMissionT[k].Bits = clear_bit(CopsInMissionT[k].Bits, 1)
												CopsInMissionT[k].Bits = clear_bit(CopsInMissionT[k].Bits, 2)
												TASK.CLEAR_PED_TASKS(CopsInMissionT[k].Handle)
												CopsInMissionT[k].Target = 0
												CopsInMissionT[k].TargetType = 0
												CopsInMissionT[k].CombatTarget = 0
											else
												local TCoords = ENTITY.GET_ENTITY_COORDS(CopsInMissionT[k].Target)
												local Distance = DistanceBetween(PCoords.x, PCoords.y, PCoords.z, TCoords.x, TCoords.y, TCoords.z)
												if Distance > 30.0 then
													if TASK.GET_SCRIPT_TASK_STATUS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_VEHICLE_DRIVE_TO_COORD")) == 7 then
														local Veh = PED.GET_VEHICLE_PED_IS_IN(CopsInMissionT[k].Handle, true)
														if Veh == 0 then
															Veh = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(CopsInMissionT[k].Handle)
														end
														if Veh == 0 and TASK.GET_SCRIPT_TASK_STATUS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_GO_TO_COORD_ANY_MEANS")) == 7 then
															TASK.TASK_GO_TO_COORD_ANY_MEANS(CopsInMissionT[k].Handle, PlayerPos.x, PlayerPos.y, PlayerPos.z, 3.0, 0, true, 786469, -1.0)
														end
														if Veh ~= 0 then
															local CanCall = true
															if PED.IS_PED_IN_VEHICLE(CopsInMissionT[k].Handle, Veh, false) then
																local Ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false)
																if Ped ~= 0 then
																	if Ped ~= CopsInMissionT[k].Handle then
																		CanCall = false
																	end
																end
															end
															if CanCall then
																TASK.TASK_VEHICLE_DRIVE_TO_COORD(CopsInMissionT[k].Handle, Veh, TCoords.x, TCoords.y, TCoords.z, 1000.0, 1, ENTITY.GET_ENTITY_MODEL(Veh), 786469, 4.0, 30.0)
															end
														end
													end
												else
													if TASK.GET_SCRIPT_TASK_STATUS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_GO_TO_ENTITY_WHILE_AIMING_AT_ENTITY")) == 7 then
														TASK.TASK_GO_TO_ENTITY_WHILE_AIMING_AT_ENTITY(CopsInMissionT[k].Handle, CopsInMissionT[k].Target, CopsInMissionT[k].Target, 2.0, true, 0.1, 0.1, true, false, joaat("FIRING_PATTERN_FULL_AUTO"))
													end
												end
											end
										else
											CopsInMissionT[k].Bits = clear_bit(CopsInMissionT[k].Bits, 1)
											CopsInMissionT[k].Bits = clear_bit(CopsInMissionT[k].Bits, 2)
											TASK.CLEAR_PED_TASKS(CopsInMissionT[k].Handle)
											CopsInMissionT[k].Target = 0
											CopsInMissionT[k].TargetType = 0
											CopsInMissionT[k].CombatTarget = 0
										end
									end
								else
									CopsInMissionT[k].Bits = clear_bit(CopsInMissionT[k].Bits, 1)
									CopsInMissionT[k].Bits = clear_bit(CopsInMissionT[k].Bits, 2)
									TASK.CLEAR_PED_TASKS(CopsInMissionT[k].Handle)
									CopsInMissionT[k].Target = 0
									CopsInMissionT[k].TargetType = 0
									CopsInMissionT[k].CombatTarget = 0
								end
							end
							if is_bit_set(CopsInMissionT[k].Bits, 3) then
								if CopsInMissionT[k].Target ~= 0 then
									if CopsInMissionT[k].TargetType == 3 then
										if not ENTITY.DOES_ENTITY_EXIST(CopsInMissionT[k].Target) or ENTITY.IS_ENTITY_DEAD(CopsInMissionT[k].Target) then
											CopsInMissionT[k].Bits = clear_bit(CopsInMissionT[k].Bits, 1)
											CopsInMissionT[k].Bits = clear_bit(CopsInMissionT[k].Bits, 3)
											TASK.CLEAR_PED_TASKS(CopsInMissionT[k].Handle)
											CopsInMissionT[k].Target = 0
											CopsInMissionT[k].TargetType = 0
										else
											if not ENTITY.IS_ENTITY_ATTACHED_TO_ANY_PED(CopsInMissionT[k].Target) then
												if ENTITY.IS_ENTITY_AT_ENTITY(CopsInMissionT[k].Handle, CopsInMissionT[k].Target, 2.0, 2.0, 2.0, false, true, false) and not
												ENTITY.IS_ENTITY_AT_ENTITY(CopsInMissionT[k].Handle, PlayerPed, 10.0, 10.0, 10.0, false, true, false) then
													if RequestControlOfEntity(CopsInMissionT[k].Target) then
														OBJECT.ATTACH_PORTABLE_PICKUP_TO_PED(CopsInMissionT[k].Target, CopsInMissionT[k].Handle)
													end
												end
												local TCoords = ENTITY.GET_ENTITY_COORDS(CopsInMissionT[k].Target)
												local Distance = DistanceBetween(PCoords.x, PCoords.y, PCoords.z, TCoords.x, TCoords.y, TCoords.z)
												if Distance > 30.0 then
													if TASK.GET_SCRIPT_TASK_STATUS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_VEHICLE_DRIVE_TO_COORD")) == 7 then
														local Veh = PED.GET_VEHICLE_PED_IS_IN(CopsInMissionT[k].Handle, true)
														if Veh == 0 then
															Veh = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(CopsInMissionT[k].Handle)
														end
														if Veh == 0 and TASK.GET_SCRIPT_TASK_STATUS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_GO_TO_COORD_ANY_MEANS")) == 7 then
															TASK.TASK_GO_TO_COORD_ANY_MEANS(CopsInMissionT[k].Handle, TCoords.x, TCoords.y, TCoords.z, 3.0, 0, true, 786469, -1.0)
														end
														if Veh ~= 0 then
															local CanCall = true
															if PED.IS_PED_IN_VEHICLE(CopsInMissionT[k].Handle, Veh, false) then
																local Ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false)
																if Ped ~= 0 then
																	if Ped ~= CopsInMissionT[k].Handle then
																		CanCall = false
																	end
																end
															end
															if CanCall then
																TASK.TASK_VEHICLE_DRIVE_TO_COORD(CopsInMissionT[k].Handle, Veh, TCoords.x, TCoords.y, TCoords.z, 1000.0, 1, ENTITY.GET_ENTITY_MODEL(Veh), 786469, 4.0, 20.0)
															end
														end
													end
												else
													if not PED.IS_PED_IN_COMBAT(CopsInMissionT[k].Handle, 0) then
														if TASK.GET_SCRIPT_TASK_STATUS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_GO_TO_ENTITY")) == 7 then
															TASK.TASK_GO_TO_ENTITY(CopsInMissionT[k].Handle, CopsInMissionT[k].Target, -1, 0.1, 3.0, 0.5, 1)
														end
													end
												end
											else
												if ENTITY.IS_ENTITY_ATTACHED_TO_ENTITY(CopsInMissionT[k].Target, CopsInMissionT[k].Handle) then
													if not ENTITY.IS_ENTITY_AT_ENTITY(CopsInMissionT[k].Handle, PlayerPed, 10.0, 10.0, 10.0, false, true, false) then
														if TASK.GET_SCRIPT_TASK_STATUS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_VEHICLE_MISSION")) == 7 then
															local Veh = PED.GET_VEHICLE_PED_IS_IN(CopsInMissionT[k].Handle, true)
															if Veh == 0 then
																Veh = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(CopsInMissionT[k].Handle)
															end
															if Veh == 0 and TASK.SCRIPT_TASK_GO_TO_COORD_ANY_MEANS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_GO_TO_COORD_ANY_MEANS")) == 7 then
																TASK.TASK_GO_TO_COORD_ANY_MEANS(CopsInMissionT[k].Handle, PlayerPos.x, PlayerPos.y, PlayerPos.z, 3.0, 0, true, 786469, -1.0)
															end
															if Veh ~= 0 then
																local CanCall = true
																if PED.IS_PED_IN_VEHICLE(CopsInMissionT[k].Handle, Veh, false) then
																	local Ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false)
																	if Ped ~= 0 then
																		if Ped ~= CopsInMissionT[k].Handle then
																			CanCall = false
																		end
																	end
																end
																if CanCall then
																	TASK.TASK_VEHICLE_MISSION_PED_TARGET(CopsInMissionT[k].Handle, Veh, PlayerPed, 4, 1000.0, 786469, 10.0, 8.0, true)
																end
															end
														end
													else
														if not ENTITY.IS_ENTITY_ATTACHED_TO_ENTITY(CopsInMissionT[k].Target, PlayerPed) then
															if RequestControlOfEntity(CopsInMissionT[k].Target) then
																ENTITY.DETACH_ENTITY(CopsInMissionT[k].Target, true, true)
															end
														end
													end
												else
													CopsInMissionT[k].Bits = clear_bit(CopsInMissionT[k].Bits, 1)
													CopsInMissionT[k].Bits = clear_bit(CopsInMissionT[k].Bits, 3)
													TASK.CLEAR_PED_TASKS(CopsInMissionT[k].Handle)
													CopsInMissionT[k].Target = 0
													CopsInMissionT[k].TargetType = 0
												end
											end
										end
									end
								end
							end
							if is_bit_set(CopsInMissionT[k].Bits, 4) then
								if CopsInMissionT[k].Target ~= 0 then
									if CopsInMissionT[k].TargetType == 2 then
										if not ENTITY.DOES_ENTITY_EXIST(CopsInMissionT[k].Target) or ENTITY.IS_ENTITY_DEAD(CopsInMissionT[k].Target) then
											CopsInMissionT[k].Bits = clear_bit(CopsInMissionT[k].Bits, 1)
											CopsInMissionT[k].Bits = clear_bit(CopsInMissionT[k].Bits, 4)
											TASK.CLEAR_PED_TASKS(CopsInMissionT[k].Handle)
											CopsInMissionT[k].Target = 0
											CopsInMissionT[k].TargetType = 0
										else
											local InVeh = PED.IS_PED_IN_VEHICLE(CopsInMissionT[k].Handle, CopsInMissionT[k].Target, false)
											if not InVeh then
												local TCoords = ENTITY.GET_ENTITY_COORDS(CopsInMissionT[k].Target)
												local Distance = DistanceBetween(PCoords.x, PCoords.y, PCoords.z, TCoords.x, TCoords.y, TCoords.z)
												if Distance > 30.0 then
													if TASK.GET_SCRIPT_TASK_STATUS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_VEHICLE_MISSION")) == 7 then
														local Veh = PED.GET_VEHICLE_PED_IS_IN(CopsInMissionT[k].Handle, true)
														if Veh == 0 then
															Veh = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(CopsInMissionT[k].Handle)
														end
														if Veh == 0 and TASK.GET_SCRIPT_TASK_STATUS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_GO_TO_COORD_ANY_MEANS")) == 7 then
															TASK.TASK_GO_TO_COORD_ANY_MEANS(CopsInMissionT[k].Handle, PlayerPos.x, PlayerPos.y, PlayerPos.z, 3.0, 0, true, 786469, -1.0)
														end
														if Veh ~= 0 then
															local CanCall = true
															if PED.IS_PED_IN_VEHICLE(CopsInMissionT[k].Handle, Veh, false) then
																local Ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false)
																if Ped ~= 0 then
																	if Ped ~= CopsInMissionT[k].Handle then
																		CanCall = false
																	end
																end
															end
															if CanCall then
																TASK.TASK_VEHICLE_MISSION(CopsInMissionT[k].Handle, Veh, CopsInMissionT[k].Target, 4, 1000.0, 786469, 20.0, 8.0, true)
															end
														end
													end
												else
													local Ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(CopsInMissionT[k].Target, -1, false)
													if Ped ~= 0 then
														if PED.GET_RELATIONSHIP_BETWEEN_PEDS(CopsInMissionT[k].Handle, Ped) ~= 1 then
															if TASK.GET_SCRIPT_TASK_STATUS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_ENTER_VEHICLE")) == 7 then
																TASK.TASK_ENTER_VEHICLE(CopsInMissionT[k].Handle, CopsInMissionT[k].Target, -1, -1, 3.0, 0, 0, 0)
															end
														end
													else
														if TASK.GET_SCRIPT_TASK_STATUS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_ENTER_VEHICLE")) == 7 then
															TASK.TASK_ENTER_VEHICLE(CopsInMissionT[k].Handle, CopsInMissionT[k].Target, -1, -1, 3.0, 0, 0, 0)
														end
													end
												end
											else
												if TASK.GET_SCRIPT_TASK_STATUS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_VEHICLE_MISSION")) == 7 then
													local Veh = CopsInMissionT[k].Target
													if Veh ~= 0 then
														TASK.TASK_VEHICLE_MISSION_PED_TARGET(CopsInMissionT[k].Handle, Veh, PlayerPed, 4, 1000.0, 786469, 10.0, 8.0, true)
													end
												end
											end
										end
									end
								end
							end
							if is_bit_set(CopsInMissionT[k].Bits, 5) then
								if not PED.IS_PED_IN_COMBAT(CopsInMissionT[k].Handle, 0) then
									local Distance = DistanceBetween(PCoords.x, PCoords.y, PCoords.z, CopsInMissionT[k].TaskCoord.x, CopsInMissionT[k].TaskCoord.y, CopsInMissionT[k].TaskCoord.z)
									if Distance > 30.0 then
										if TASK.GET_SCRIPT_TASK_STATUS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_VEHICLE_DRIVE_TO_COORD")) == 7 then
											local Veh = PED.GET_VEHICLE_PED_IS_IN(CopsInMissionT[k].Handle, true)
											if Veh == 0 then
												Veh = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(CopsInMissionT[k].Handle)
											end
											if Veh == 0 and TASK.GET_SCRIPT_TASK_STATUS(CopsInMissionT[k].Handle, joaat("SCRIPT_TASK_GO_TO_COORD_ANY_MEANS")) == 7 then
												TASK.TASK_GO_TO_COORD_ANY_MEANS(CopsInMissionT[k].Handle, CopsInMissionT[k].TaskCoord.x, CopsInMissionT[k].TaskCoord.y, CopsInMissionT[k].TaskCoord.z, 3.0, 0, true, 786469, -1.0)
											end
											if Veh ~= 0 then
												local CanCall = true
												if PED.IS_PED_IN_VEHICLE(CopsInMissionT[k].Handle, Veh, false) then
													local Ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false)
													if Ped ~= 0 then
														if Ped ~= CopsInMissionT[k].Handle then
															CanCall = false
														end
													end
												end
												if CanCall then
													TASK.TASK_VEHICLE_DRIVE_TO_COORD(CopsInMissionT[k].Handle, Veh, CopsInMissionT[k].TaskCoord.x, CopsInMissionT[k].TaskCoord.y, CopsInMissionT[k].TaskCoord.z, 1000.0, 1, ENTITY.GET_ENTITY_MODEL(Veh), 786469, 4.0, 20.0)
													
												end
											end
										end
									end
								end
								if ENTITY.IS_ENTITY_AT_COORD(CopsInMissionT[k].Handle, CopsInMissionT[k].TaskCoord.x, CopsInMissionT[k].TaskCoord.y, CopsInMissionT[k].TaskCoord.z, 10.0, 10.0, 10.0, false, true, 0)
								or not HUD.DOES_BLIP_EXIST(CopsInMissionT[k].BlipHandle) then
									CopsInMissionT[k].Bits = clear_bit(CopsInMissionT[k].Bits, 1)
									CopsInMissionT[k].Bits = clear_bit(CopsInMissionT[k].Bits, 5)
									TASK.CLEAR_PED_TASKS(CopsInMissionT[k].Handle)
									CopsInMissionT[k].Target = 0
									CopsInMissionT[k].TargetType = 0
								end
							end
						end
					else
						CopsIndexesInMissionT[CopsInMissionT[k].Handle] = nil
						table.remove(CopsInMissionT, k)
						break
					end
				end
			end
			Wait()
		end
	end
end)


menu.toggle_loop(menu.my_root(), "Enable Cops In Cayo Perico", {}, "", function(toggle)
	local PlayerId = PLAYER.PLAYER_ID()
	local Addr = memory.script_global(CayoCopsGlobalAddr + 463 * PlayerId)
	local Value = memory.read_int(Addr)
	if is_bit_set(Value, 1) then
		memory.write_int(Addr, clear_bit(Value, 1))
	end
end)

local OnlyShowCopBlips = false
menu.toggle(menu.my_root(), "Only Show Cop Blips", {}, "", function(toggle)
	OnlyShowCopBlips = toggle
	while OnlyShowCopBlips do
		Wait()
		local PlayerPed = PLAYER.PLAYER_PED_ID()
		local MissionCopCount = 0
		for index, peds in pairs(entities.get_all_peds_as_handles()) do
			if peds ~= PlayerPed then
				if not PED.IS_PED_A_PLAYER(peds) then
					local DecorInt = DECORATOR.DECOR_GET_INT(peds, "Casino_Game_Info_Decorator")
					if DecorInt == 31 then
						MissionCopCount = MissionCopCount + 1
						if not HUD.DOES_PED_HAVE_AI_BLIP(peds) then
							HUD.SET_PED_HAS_AI_BLIP_WITH_COLOUR(peds, true, 2)
							HUD.SET_PED_AI_BLIP_HAS_CONE(peds, false)
							HUD.SET_PED_AI_BLIP_FORCED_ON(peds, true)
						end
					end
				end
			end
		end
		if RenderCopCount then
			directx.draw_text(0.7, 0.7, "Cops "..MissionCopCount, ALIGN_CENTRE, 1.0, {r = 0.0, g = 1.0 , b = 1.0, a = 1.0}, false)
		end
	end
end, OnlyShowCopBlips)

function is_bit_set(value, bit)
    bit = bit - 1
    return (value & (1 << bit)) ~= 0
end

function clear_bit(value, bit)
    bit = bit - 1;
    return value & ~(1 << bit)
end

function set_bit(value, bit)
    bit = bit - 1;
    return value | 1 << bit
end

local WeaponsLevel1 = {
	"weapon_pistol50",
	"weapon_heavypistol",
	"weapon_microsmg",
	"weapon_minismg",
	"weapon_tecpistol"
}

local WeaponsLevel2 = {
	"weapon_appistol",
	"weapon_gadgetpistol",
	"weapon_assaultsmg",
	"weapon_smg",
	"weapon_smg_mk2",
	"weapon_machinepistol",
	"weapon_pumpshotgun"
}

local WeaponsLevel3 = {
	"weapon_navyrevolver",
	"weapon_combatpdw",
	"weapon_sawnoffshotgun",
	"weapon_assaultshotgun",
	"weapon_heavyshotgun",
	"weapon_dbshotgun",
	"weapon_autoshotgun",
	"weapon_combatshotgun",
	"weapon_carbinerifle",
	"weapon_carbinerifle_mk2",
	"weapon_specialcarbine",
	"weapon_specialcarbine_mk2",
	"weapon_bullpuprifle",
	"weapon_bullpuprifle_mk2",
	"weapon_compactrifle",
	"weapon_militaryrifle",
	"weapon_heavyrifle",
	"weapon_tacticalrifle",
	"weapon_gusenberg"
}

local WeaponsLevel4 = {
	"weapon_mg",
	"weapon_combatmg",
	"weapon_combatmg_mk2",
}

local WeaponsLevel5 = {
	"weapon_sniperrifle",
	"weapon_heavysniper",
	"weapon_heavysniper_mk2",
	"weapon_marksmanrifle",
	"weapon_marksmanrifle_mk2",
	"weapon_precisionrifle",
}

local WeaponsLevel6 = {
	"weapon_rpg",
	"weapon_grenadelauncher",
	"weapon_minigun",
	"weapon_firework",
	"weapon_railgun",
	"weapon_hominglauncher",
	"weapon_compactlauncher",
	"weapon_emplauncher"
}

function GiveCorrectWeaponsToPed(Ped)
	if EnableWeaponSettsForCops then
		if SelectedGiveWeaponType == 1 then
			WEAPON.REMOVE_ALL_PED_WEAPONS(Ped, true)
			WEAPON.GIVE_WEAPON_TO_PED(Ped, SelectedForcedPedWeaponHash, 99999, false, true)
		end
		if SelectedGiveWeaponType == 2 then
			WEAPON.GIVE_WEAPON_TO_PED(Ped, SelectedAutoGivePedWeaponHash, 99999, false, true)
		end
		if SelectedGiveWeaponType == 3 then
			WEAPON.REMOVE_ALL_PED_WEAPONS(Ped, true)
			local RandomWeapHash = joaat(WeaponsForCops[math.random(#WeaponsForCops)])
			WEAPON.GIVE_WEAPON_TO_PED(Ped, RandomWeapHash, 99999, false, true)
		end
		if SelectedGiveWeaponType == 4 then
			local ChosenWeaponHash = 0
			local RandomChance = math.random(0, 120)
			if RandomChance <= 20 then
				ChosenWeaponHash = joaat(WeaponsLevel1[math.random(#WeaponsLevel1)])
			end
			if RandomChance > 20 and RandomChance <= 40 then
				ChosenWeaponHash = joaat(WeaponsLevel2[math.random(#WeaponsLevel2)])
			end
			if RandomChance > 40 and RandomChance <= 60 then
				ChosenWeaponHash = joaat(WeaponsLevel3[math.random(#WeaponsLevel3)])
			end
			if RandomChance > 60 and RandomChance <= 80 then
				ChosenWeaponHash = joaat(WeaponsLevel4[math.random(#WeaponsLevel4)])
			end
			if RandomChance > 80 and RandomChance <= 100 then
				ChosenWeaponHash = joaat(WeaponsLevel5[math.random(#WeaponsLevel5)])
			end
			if AllowExplosives then
				if RandomChance > 100 and RandomChance <= 120 then
					ChosenWeaponHash = joaat(WeaponsLevel6[math.random(#WeaponsLevel6)])
				end
			else
				if RandomChance > 100 then
					ChosenWeaponHash = joaat(WeaponsLevel5[math.random(#WeaponsLevel5)])
				end
			end
			WEAPON.GIVE_WEAPON_TO_PED(Ped, ChosenWeaponHash, 99999, false, true)
		end
		if SelectedGiveWeaponType == 5 then
			local ChosenWeaponHash = 0
			local RandomChance = math.random(0, 120)
			if RandomChance <= 40 then
				local RandomLevel = math.random(1, 5)
				if RandomLevel == 1 then
					ChosenWeaponHash = joaat(WeaponsLevel1[math.random(#WeaponsLevel1)])
				end
				if RandomLevel == 2 then
					ChosenWeaponHash = joaat(WeaponsLevel2[math.random(#WeaponsLevel2)])
				end
				if RandomLevel == 3 then
					ChosenWeaponHash = joaat(WeaponsLevel3[math.random(#WeaponsLevel3)])
				end
				if RandomLevel == 4 then
					ChosenWeaponHash = joaat(WeaponsLevel4[math.random(#WeaponsLevel4)])
				end
				if RandomLevel == 5 then
					ChosenWeaponHash = joaat(WeaponsLevel5[math.random(#WeaponsLevel5)])
				end
			end
			if RandomChance > 40 and RandomChance <= 120 then
				ChosenWeaponHash = joaat(WeaponsLevel6[math.random(#WeaponsLevel6)])
			end
			WEAPON.GIVE_WEAPON_TO_PED(Ped, ChosenWeaponHash, 99999, false, true)
		end
	end
end

function IsWithCopRel(Ped)
	local RelHash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(Ped)
	if RelHash == joaat("COP") or RelHash == joaat("ARMY") then
		return true
	end
	return false
end

function IsCopPedModel(Ped)
	local PedModel = ENTITY.GET_ENTITY_MODEL(Ped)
	for i, value in pairs(SelectedPedModels) do
		if SelectedPedModels[i] ~= nil then
			if PedModel == joaat(SelectedPedModels[i]) then
				return true
			end
		end
	end
	return false
end

local ModelsToSet = {
	"tampa3",
	"savage",
	"nightshark",
	"khanjali",
	"buzzard",
	"menacer",
	"annihilator",
	"speedo4"
}
function IsArmoredVehModel(Veh)
	local VehModel = ENTITY.GET_ENTITY_MODEL(Veh)
	for i = 1, #ModelsToSet do
		if VehModel == joaat(ModelsToSet[i]) then
			return true
		end
	end
	return false
end

local MiscMenu = menu.list(menu.my_root(), "Misc Features", {}, "")

menu.action(MiscMenu, "Enable All Dispatch Services", {}, "", function(toggle)
	for i = 1, 15 do
		MISC.ENABLE_DISPATCH_SERVICE(i, true)
	end
end)

local PersonalVehSp = false
menu.toggle(MiscMenu, "Personal Vehicle Spawn Here", {}, "", function(toggle)
	PersonalVehSp = toggle
	if PersonalVehSp then
		local SpawnAddr = SplitGlobals("Global_2635562.f_683")
		SpawnAddr = memory.script_global(SpawnAddr)
		local Pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
		while PersonalVehSp do
			memory.write_float(SpawnAddr, Pos.x)
			memory.write_float(SpawnAddr+0x8, Pos.y)
			memory.write_float(SpawnAddr+0x10, Pos.z)
			Wait()
		end
	end
end)

menu.toggle_loop(MiscMenu, "Network Door", {}, "Some doors you aim will be able to open by other players.", function(toggle)
	local PlayerId = PLAYER.PLAYER_ID()
	if PLAYER.IS_PLAYER_FREE_AIMING(PlayerId) then
		local Entity = get_entity_player_is_aiming_at(PlayerId)
		if Entity ~= nil then
			--request_control_once(Entity)
			local Pos = ENTITY.GET_ENTITY_COORDS(Entity)
			local ModelHash = ENTITY.GET_ENTITY_MODEL(Entity)
			local DoorHash = memory.alloc(8)
			local Found = OBJECT.DOOR_SYSTEM_FIND_EXISTING_DOOR(Pos.x, Pos.y, Pos.z, ModelHash, DoorHash)
			if Found then
				OBJECT.DOOR_SYSTEM_SET_DOOR_STATE(memory.read_int(DoorHash), 0, true, false)
			end
		end
	end
end)

menu.toggle_loop(MiscMenu, "Set Aimed Entity Invincible", {}, "", function(toggle)
	local PlayerId = PLAYER.PLAYER_ID()
	if PLAYER.IS_PLAYER_FREE_AIMING(PlayerId) then
		local Entity, Ped = get_entity_player_is_aiming_at(PlayerId)
		if Entity ~= 0 then
			if RequestControlOfEntity(Entity) then
				ENTITY.SET_ENTITY_INVINCIBLE(Entity, true)
				Print("Is invincible now.")
			end
		end
		if Ped ~= 0 then
			if RequestControlOfEntity(Ped) then
				ENTITY.SET_ENTITY_INVINCIBLE(Ped, true)
				Print("Ped is invincible now.")
			end
		end
	end
end)

menu.action(MiscMenu, "Set My Rel Hash To", {}, "", function(toggle)
	local PlayerPed = PLAYER.PLAYER_PED_ID()
	PED.SET_PED_RELATIONSHIP_GROUP_HASH(PlayerPed, joaat("relAssetBurner"))
end)


local CollectAll = false
menu.toggle(MiscMenu, "B Battle Collect All 8 Crates", {""}, "", function(toggle)
	CollectAll = toggle
	while CollectAll do
		Wait()
		local pickups = entities.get_all_pickups_as_handles()
		for index, crates in ipairs(pickups) do
			if ENTITY.GET_ENTITY_SCRIPT(crates, 0) == "fm_content_business_battles"
			and not ENTITY.IS_ENTITY_ATTACHED_TO_ANY_PED(crates) then
                RequestControlOfEntity(crates)
				ENTITY.ATTACH_ENTITY_TO_ENTITY(crates, PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID()), 0, 0, 0, 0, 0, 0, 0, 0, true, true, false, 0, true)
				--OBJECT.ATTACH_PORTABLE_PICKUP_TO_PED(crates, PLAYER.PLAYER_PED_ID())
			end
		end
	end
end)

menu.toggle_loop(MiscMenu, "Kill List Veh Valkyrie", {""}, "", function(toggle)
	local HostSet = false
	local ChosenVehModel = joaat("tampa3")
	if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("am_kill_list")) > 0 then
		if not HostSet then
			NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
			HostSet = true
		end
		memory.write_int(memory.script_local("am_kill_list", 94+27), ChosenVehModel)
		local VehNetID = memory.read_int(memory.script_local("am_kill_list", 94+7+1))
		local VehHandle = 0
		util.spoof_script("am_kill_list", function()
			if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
				NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
			end
			if VehNetID > 0 then
				VehHandle = NETWORK.NET_TO_VEH(VehNetID)
			end
		end)
		if VehHandle > 0 then
			if ENTITY.GET_ENTITY_MODEL(VehHandle) == ChosenVehModel then
				memory.write_int(memory.script_local("am_kill_list", 94+27), joaat("buzzard"))
			end
		end
	else
		HostSet = false
	end
end)

menu.action(MiscMenu, "Start Kill List", {}, "", function(toggle)
	if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("am_kill_list")) > 0 then
		memory.write_int(memory.script_local("am_kill_list", 94+413), -4144)
		util.spoof_script("am_kill_list", function()
			if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
				NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
			end
		end)
	end
end)

menu.action(MiscMenu, "Bring Fortified Boxville", {}, "", function(toggle)
	for index, vehs in pairs(entities.get_all_vehicles_as_handles()) do
		if ENTITY.GET_ENTITY_SCRIPT(vehs, 0) == "GB_FORTIFIED" then
			if ENTITY.GET_ENTITY_MODEL(vehs) == joaat("boxville5") then
				local PlCoords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
				RequestControlOfEntity(vehs)
				ENTITY.SET_ENTITY_COORDS(vehs, PlCoords.x, PlCoords.y, PlCoords.z)
			end
		end
	end
end)

local SpamEnemies = false
menu.toggle(MiscMenu, "GB_FORTIFIED Spam Enemies", {}, "", function(toggle)
	SpamEnemies = toggle
	while SpamEnemies do
		local Delay = 0
		if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("gb_fortified")) > 0 then
			memory.write_int(memory.script_local("gb_fortified", 1108+331-26), 3)
			memory.write_int(memory.script_local("gb_fortified", 1108+331-7), 1)
			util.spoof_script("gb_fortified", function()
				if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
					util.request_script_host("gb_fortified")
					--NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
					Delay = 1000
				end
			end)
		end
		Wait(Delay)
	end
end)

--util.copy_to_clipboard(string.format("%X", memory.script_global(SplitGlobals("Global_2635560.f_683"))))

menu.toggle_loop(MiscMenu, "Business Battles Chaos", {""}, "Enemies will rush and respawn.", function(toggle)
	if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_content_business_battles")) > 0 then
		util.spoof_script("fm_content_business_battles", function()
			if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
				util.request_script_host("fm_content_business_battles")
				NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
			end
		end)
		for i = 0, 29 do
			memory.write_int(memory.script_local("fm_content_business_battles", (217+129+1+2) + 21 * i), 1024)
			memory.write_float(memory.script_local("fm_content_business_battles", (217+129+1+21) + 21 * i), -1)
		end
	end
end)

menu.toggle_loop(MiscMenu, "Cargo Plane Takedown", {""}, "am_plane_takedown", function(toggle)
	if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("am_plane_takedown")) > 0 then
		util.spoof_script("am_plane_takedown", function()
			if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
				NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
			end
		end)
		for i = 0, 29 do
			memory.write_int(memory.script_local("am_plane_takedown", 86+4), joaat("cargoplane"))
		end
	end
end)

menu.action(MiscMenu, "Cargo Plane Takedown Blip", {""}, "am_plane_takedown", function(toggle)
	for index, vehs in pairs(entities.get_all_vehicles_as_handles()) do
		if ENTITY.GET_ENTITY_SCRIPT(vehs, 0) == "AM_PLANE_TAKEDOWN" then
			local Ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehs, -1, false)
			if Ped ~= 0 then
				HUD.SET_PED_HAS_AI_BLIP_WITH_COLOUR(Ped, true, 1)
				HUD.SET_PED_AI_BLIP_HAS_CONE(Ped, false)
				HUD.SET_PED_AI_BLIP_FORCED_ON(Ped, true)
			end
		end
	end
end)

menu.action(MiscMenu, "Solo Tutorial Session", {}, "", function(toggle)
	if NETWORK.NETWORK_IS_IN_TUTORIAL_SESSION() then
		NETWORK.NETWORK_END_TUTORIAL_SESSION()
	else
		NETWORK.NETWORK_START_SOLO_TUTORIAL_SESSION()
	end
end)

local DevMenu = menu.list(menu.my_root(), "DEV Tools", {}, "")

menu.action(DevMenu, "Bypass Law Vehicles", {}, "To spawn cops and SWATS inside different police vehicles", function(toggle)
	local AddrDispatch = memory.scan("8d ? 58 89 ? ? e8 ? ? ? ? 84 c0 0f 84")
	--if AddrDispatch ~= 0 then
	--	local AddrTarget = AddrDispatch + 21
	--	memory.write_byte(AddrTarget, 0xEB)
	--end
	--local AddrSWATDispatch = memory.scan("74 ? 3b 05 ? ? ? ? 74 ? 3b 05 ? ? ? ? 75 ? ? b0 01")
	--if AddrSWATDispatch ~= 0 then
	--	local AddrTarget = AddrSWATDispatch + 16
	--	memory.write_byte(AddrTarget, 0x90)
	--	memory.write_byte(AddrTarget + 1, 0x90)
	--end
	--local NewAddr = memory.scan("C0 C0 00 00 0C C2 00 00 0C 42 00 00 F0 41 00 00 B4 41 00 00 0C 42 ?")
	Print(string.format("%X", AddrDispatch))
	util.copy_to_clipboard(string.format("%X", AddrDispatch))
end)

menu.action(DevMenu, "Component Variation", {}, "", function(toggle)
	local PlayerPed = PLAYER.PLAYER_PED_ID()
	local i = 0
	--local Drawable = PED.GET_PED_DRAWABLE_VARIATION(PlayerPed, i)
	--local Texture = PED.GET_PED_TEXTURE_VARIATION(PlayerPed, i)
	--Print("Drawable "..Drawable)
	--Print("Texture "..Texture)
	--if PED.IS_PED_COMPONENT_VARIATION_VALID(PlayerPed, i, Drawable, Texture) then
	--	Print("Valid")
	--end
	local Prop = PED.GET_PED_PROP_INDEX(PlayerPed, i)
	local Texture = PED.GET_PED_PROP_TEXTURE_INDEX(PlayerPed, i)
	Print("Drawable "..Prop)
	Print("Texture "..Texture)
	if Prop ~= 255 then
		--PED.SET_PED_PROP_INDEX(PlayerPed, i, Prop, Texture, true, 0)
	end
end)

menu.toggle_loop(DevMenu, "Get Events", {}, "", function(toggle)
	Print(SCRIPT.GET_NUMBER_OF_EVENTS(0))
end)


menu.action(DevMenu, "Get Group Size", {}, "", function(toggle)
	Print(GetPedGroupSize(PLAYER.GET_PLAYER_GROUP(PLAYER.PLAYER_ID())))
end)

menu.action(DevMenu, "Relationship Hash", {}, "", function(toggle)
	local PlayerID = PLAYER.PLAYER_ID()
	local RelTarget = joaat("rgFM_Team"..PlayerID)
	local MyRel = PED.GET_PED_RELATIONSHIP_GROUP_HASH(PLAYER.PLAYER_PED_ID())
	Print(RelTarget .. " MyRel " .. MyRel)
end)

menu.action(DevMenu, "Addr Test", {}, "", function(toggle)
	local Addr = memory.scan("C0 C0 00 00 0C C2 00 00 0C 42 00 00 F0 41 00 00 B4 41 00 00 0C 42 ?")
	local Addr2 = memory.read_long(Addr+0x16)
	local Addr3 = memory.read_long(Addr2+0x8)
	local Addr4 = memory.read_long(Addr3+0xB0)
	local FormatedString = string.format("%02X", Addr4)
	util.copy_to_clipboard(FormatedString)
	Print(FormatedString)
end)

menu.action(DevMenu, "Addr Get", {}, "", function(toggle)
	local Addr = memory.scan("C0 C0 00 00 0C C2 00 00 0C 42 00 00 F0 41 00 00 B4 41 00 00 0C 42 ?")
	local FormatedString = string.format("%02X", Addr)
	util.copy_to_clipboard(FormatedString)
	Print(FormatedString)
end)

menu.toggle_loop(DevMenu, "Wheel Heading", {}, "", function(toggle)
	local PlayerPed = PLAYER.PLAYER_PED_ID()
	local PlayerVeh = PED.GET_VEHICLE_PED_IS_IN(PlayerPed, false)
	if PlayerVeh ~= 0 then
		local BoneIndex = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(PlayerVeh, "steeringwheel")
		if BoneIndex ~= 0 then
			local Rot = ENTITY.GET_ENTITY_BONE_OBJECT_ROTATION(PlayerVeh, BoneIndex)
			local Norm = v3.normalise(Rot)
			directx.draw_text(0.7, 0.7, "Z "..(math.abs(Rot.y)), ALIGN_CENTRE, 1.0, {r = 0, g = 255 , b = 255, a = 200}, false)
		end
	end
end)

menu.action(DevMenu, "B Battle2 Args", {}, "", function(Toggle)
	memory.write_int(memory.script_global(SplitGlobals("Global_2698947.f_183")), 1)
    memory.write_int(memory.script_global(SplitGlobals("Global_2698947.f_184")), 2)
end)

menu.action(DevMenu, "B Battle2 0 Args", {}, "", function(Toggle)
	memory.write_int(memory.script_global(SplitGlobals("Global_2698947.f_183")), 0)
    memory.write_int(memory.script_global(SplitGlobals("Global_2698947.f_184")), 0)
end)

menu.action(DevMenu, "B Battle2 Args Solo", {}, "", function(Toggle)
	memory.write_int(memory.script_global(SplitGlobals("Global_2698947.f_183")), -1)
    memory.write_int(memory.script_global(SplitGlobals("Global_2698947.f_184")), 2)
end)

menu.action(DevMenu, "Set Population Budget 3", {}, "", function(Toggle)
	STREAMING.SET_VEHICLE_POPULATION_BUDGET(3)
	STREAMING.SET_PED_POPULATION_BUDGET(3)
end)
menu.action(DevMenu, "Populate Now", {}, "", function(Toggle)
	MISC.POPULATE_NOW()
end)
local SpamPopulate = false
menu.toggle(DevMenu, "Spam Populate Now", {}, "", function(Toggle)
	SpamPopulate = Toggle
	while SpamPopulate do
		STREAMING.SET_VEHICLE_POPULATION_BUDGET(3)
		STREAMING.SET_PED_POPULATION_BUDGET(3)
		PED.INSTANTLY_FILL_PED_POPULATION()
		VEHICLE.INSTANTLY_FILL_VEHICLE_POPULATION()
		MISC.POPULATE_NOW()
		Wait(1000)
	end
end)

menu.toggle_loop(DevMenu, "Density Multiplier", {}, "", function(Toggle)
	if Toggle then
		PED.SET_PED_DENSITY_MULTIPLIER_THIS_FRAME(10.0)
		PED.SET_SCENARIO_PED_DENSITY_MULTIPLIER_THIS_FRAME(10.0, 10.0)
	end
end)

local FastDriving = false
menu.toggle(MiscMenu, "Improved Driving", {}, "", function(toggle)
	FastDriving = toggle
	if FastDriving then
		local MaxSpeed = 80.0
		while FastDriving do
			local PlayerPed = PLAYER.PLAYER_PED_ID()
			local VehHandle = PED.GET_VEHICLE_PED_IS_IN(PlayerPed, false)
			if VehHandle ~= 0 then
				if VEHICLE.GET_PED_IN_VEHICLE_SEAT(VehHandle, -1, false) == PlayerPed then
					local VehClass = VEHICLE.GET_VEHICLE_CLASS(VehHandle)
					if VehClass ~= 8 and VehClass ~= 13 and VehClass ~= 15 and VehClass ~= 16 then
						local NormZ = 0.0
						local VehPos = ENTITY.GET_ENTITY_COORDS(VehHandle)
						local EntSpeed = ENTITY.GET_ENTITY_SPEED_VECTOR(VehHandle, true)
						local BoneIndex = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(VehHandle, "steeringwheel")
						local EntVel = ENTITY.GET_ENTITY_VELOCITY(VehHandle)
						local FVect, RVect, UpVect, Vect = v3.new(), v3.new(), v3.new(), v3.new()
						ENTITY.GET_ENTITY_MATRIX(VehHandle, FVect, RVect, UpVect, Vect)
						local AdjustedVect = {x = VehPos.x + FVect.x * 6.0, y = VehPos.y + FVect.y * 6.0, z = VehPos.z + FVect.z * 6.0}
						local Norm = v3.new()
						if BoneIndex ~= 0 then
							local Rot = ENTITY.GET_ENTITY_BONE_OBJECT_ROTATION(VehHandle, BoneIndex)
							Norm = v3.normalise(Rot)
							NormZ = Rot.y
							local NormZAbs = math.abs(NormZ)
							if EntSpeed.y > 3.0 and EntSpeed.y < MaxSpeed then
								ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, NormZ * 0.005 * EntSpeed.y, (1.0 - NormZAbs) * 0.01 * EntSpeed.y, 0.0, 0, true, true, false)
							end
							local ForceZ = 0.0
							EntSpeed = ENTITY.GET_ENTITY_SPEED_VECTOR(VehHandle, true)
							if ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(VehHandle) > 1.1 then --or EntSpeed.x > 1.0 or EntSpeed.x < -1.0 then
								ForceZ = -1.50
							end
							ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, 0.0, 0.0, ForceZ, 0, false, true, false)
							if EntSpeed.y >= 3.0 then
								local BNormal = PAD.GET_CONTROL_NORMAL(0, 72)
								ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, NormZ * 0.005 * EntSpeed.y, (-NormZAbs * 0.01 * EntSpeed.y) - BNormal, 0.0, 0, true, true, false)
							end
							--local AdjustedVect2 = {x = VehPos.x + FVect.x * EntSpeed.y * DistanceMult, y = VehPos.y + FVect.y * EntSpeed.y * DistanceMult, z = VehPos.z + FVect.z * EntSpeed.y * DistanceMult}
							--local EndCoords2, DidHit2, EntHit2, SurfaceNormal2 = ShapeTestNav(VehHandle, VehPos, AdjustedVect2)
							--if DidHit2 and EntSpeed.y >= 2.0 then
							--	ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, 0.0, -1.0, 0.0, 0, true, true, false)
							--end
							local AdjustedVect3 = {x = VehPos.x + RVect.x * 2.0, y = VehPos.y + RVect.y * 2.0, z = VehPos.z + RVect.z * 2.0}
							local EndCoords3, DidHit3, EntHit3, SurfaceNormal3 = ShapeTestNav(VehHandle, VehPos, AdjustedVect3)
							if DidHit3 then
								local CanSetVel = false
								if EntHit3 ~= 0 then
									if ENTITY.IS_ENTITY_A_VEHICLE(EntHit3) then
										CanSetVel = true
									end
								end
								if CanSetVel then
									ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, -1.0, 0.0, 0.0, 0, true, true, false)
								end
							end
							local AdjustedVect4 = {x = VehPos.x - RVect.x * 2.0, y = VehPos.y - RVect.y * 2.0, z = VehPos.z - RVect.z * 2.0}
							local EndCoords4, DidHit4, EntHit4, SurfaceNormal4 = ShapeTestNav(VehHandle, VehPos, AdjustedVect4)
							if DidHit4 then
								local CanSetVel = false
								if EntHit4 ~= 0 then
									if ENTITY.IS_ENTITY_A_VEHICLE(EntHit4) then
										CanSetVel = true
									end
								end
								if CanSetVel then
									ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, 1.0, 0.0, 0.0, 0, true, true, false)
								end
							end
							ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 5, 0.0, 0.0, -NormZ * 0.0005 * EntSpeed.y, 0, false, true, false)
						end
					end
				end
			end
			Wait()
		end
	end
end, FastDriving)

local DirectionDriving = false
menu.toggle(MiscMenu, "Direction Driving", {}, "", function(toggle)
	DirectionDriving = toggle
	if DirectionDriving then
		local MaxSpeed = 80.0
		while DirectionDriving do
			local PlayerPed = PLAYER.PLAYER_PED_ID()
			local VehHandle = PED.GET_VEHICLE_PED_IS_IN(PlayerPed, false)
			if VehHandle ~= 0 then
				if VEHICLE.GET_PED_IN_VEHICLE_SEAT(VehHandle, -1, false) == PlayerPed then
					local Pos = ENTITY.GET_ENTITY_COORDS(VehHandle)
					local EntVel = ENTITY.GET_ENTITY_VELOCITY(VehHandle)
					local NewV3 = v3.new(Pos.x + EntVel.x, Pos.y + EntVel.y, Pos.z + EntVel.z)
					local NewHeading = Pos:lookAt(NewV3)
					local CurRot = ENTITY.GET_ENTITY_ROTATION(VehHandle, 2)
					ENTITY.SET_ENTITY_ROTATION(VehHandle, NewHeading.x, NewHeading.y, NewHeading.z, 2)
				end
			end
			Wait()
		end
	end
end)

local CrouchAim = false
menu.toggle(MiscMenu, "Stealth Crouch Aim", {}, "When pressing stealth button, will crouch.", function(toggle)
	CrouchAim = toggle
	if not CrouchAim then
		local PlayerPed = PLAYER.PLAYER_PED_ID()
		PED.SET_PED_MAX_MOVE_BLEND_RATIO(PlayerPed, 1.0)
		PED.RESET_PED_MOVEMENT_CLIPSET(PlayerPed, 0.55)
		PED.RESET_PED_STRAFE_CLIPSET(PlayerPed)
		STREAMING.REMOVE_ANIM_DICT("move_ped_crouched")
	end
	if CrouchAim then
		Crouch = false
		local HasSetStrafe = false
		local HasSetWalkAnim = false
		local HasReseted = false
		local BlendDuration = 0.20
		while CrouchAim do
			local PlayerPed = PLAYER.PLAYER_PED_ID()
			CAM.DISABLE_ON_FOOT_FIRST_PERSON_VIEW_THIS_UPDATE()
			PAD.DISABLE_CONTROL_ACTION(0, 36, true)
			if not STREAMING.HAS_ANIM_SET_LOADED("move_ped_crouched") then
				STREAMING.REQUEST_ANIM_SET("move_ped_crouched")
			end
			if STREAMING.HAS_ANIM_SET_LOADED("move_ped_crouched") then
				if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 36) then
					if Crouch then
						Crouch = false
					else
						Crouch = true
					end
				end
				if Crouch then
					HasReseted = false
					if CAM.IS_AIM_CAM_ACTIVE() or PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) or CAM.IS_AIM_CAM_ACTIVE_IN_ACCURATE_MODE() then
						HasSetWalkAnim = false
						if not HasSetStrafe then
							if CanCrouch(PlayerPed) then
								PED.SET_PED_USING_ACTION_MODE(PlayerPed, false, -1, "DEFAULT_ACTION")
								PED.SET_PED_MOVEMENT_CLIPSET(PlayerPed, "move_ped_crouched", BlendDuration)
								PED.SET_PED_STRAFE_CLIPSET(PlayerPed, "move_ped_crouched_strafing")
								HasSetStrafe = true
							end
						end
					else
						HasSetStrafe = false
						if not HasSetWalkAnim then
							if CanCrouch(PlayerPed) then
								PED.SET_PED_USING_ACTION_MODE(PlayerPed, false, -1, "DEFAULT_ACTION")
								PED.SET_PED_MOVEMENT_CLIPSET(PlayerPed, "move_ped_crouched", BlendDuration)
								PED.SET_PED_STRAFE_CLIPSET(PlayerPed, "move_ped_crouched_strafing")
								HasSetWalkAnim = true
							end
						end
					end
				else
					HasSetStrafe = false
					HasSetWalkAnim = false
					if not HasReseted then
						PED.SET_PED_MAX_MOVE_BLEND_RATIO(PlayerPed, 1.0)
						PED.RESET_PED_MOVEMENT_CLIPSET(PlayerPed, BlendDuration)
						PED.RESET_PED_STRAFE_CLIPSET(PlayerPed)
						HasReseted = true
					end
				end
			end
			Wait()
		end
	end
end, CrouchAim)

function CanCrouch(PlayerPed)
	if PED.IS_PED_ON_FOOT(PlayerPed) and not PED.IS_PED_IN_ANY_VEHICLE(PlayerPed, true) and not PED.IS_PED_JUMPING(PlayerPed)
	and not PED.IS_PED_FALLING(PlayerPed) and not PED.IS_PED_DEAD_OR_DYING(PlayerPed, false) then
		return true
	end
	return false
end


function DoesValueExistInTable2(T, Value)
	for index, values in pairs(T) do
		if Value == values.OldVehicle then return true end
	end
	return false
end

function DoesValueExistInTable3(T, Value)
	for index, values in pairs(T) do
		if index == Value then return true end
	end
	return false
end

--Credit to Wiri for these functions
function get_entity_player_is_aiming_at(player)
	if not PLAYER.IS_PLAYER_FREE_AIMING(player) then
		return NULL
	end
	local Ped = 0
	local entity, pEntity = NULL, memory.alloc_int()
	if PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(player, pEntity) then
		entity = memory.read_int(pEntity)
	end
	if entity ~= NULL and ENTITY.IS_ENTITY_A_PED(entity) and PED.IS_PED_IN_ANY_VEHICLE(entity, false) then
		Ped = entity
		entity = PED.GET_VEHICLE_PED_IS_IN(entity, false)
	end
	return entity, Ped
end

function GetPedGroupSize(Group)
	local HasLeader, SizePtr = memory.alloc(1), memory.alloc(1)
	PED.GET_GROUP_SIZE(Group, HasLeader, SizePtr)
	return memory.read_int(SizePtr)
end

---@param entity Entity
function set_entity_as_no_longer_needed(entity)
	local pHandle = memory.alloc_int()
	memory.write_int(pHandle, entity)
	ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(pHandle)
end

function SetPedCombatAbilities(ped)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 1, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 3, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 13, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 21, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 38, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 443, true)
	--PED.SET_PED_COMBAT_MOVEMENT(ped, 2)
	--PED.SET_PED_COMBAT_ABILITY(ped, 2) 
	PED.SET_PED_COMBAT_RANGE(ped, 2)
	PED.SET_PED_SEEING_RANGE(ped, 900.0)
	PED.SET_PED_TARGET_LOSS_RESPONSE(ped, 1)
	PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
	PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, 400.0)
	PED.SET_COMBAT_FLOAT(ped, 10, 400.0)
end

function Random_Weapon_Components(ped, weaponHash, componentHash, setColor, AlwaysSet)
	if WEAPON.HAS_PED_GOT_WEAPON(ped, weaponHash, false) then
		local randomComponent = math.random(0, 1)
		if AlwaysSet ~= nil then
			if AlwaysSet then
				randomComponent = 1
			end
		end
		if randomComponent == 1 then
			WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(ped, weaponHash, componentHash)
		end
		if setColor then
			WEAPON.SET_PED_WEAPON_TINT_INDEX(ped, weaponHash, math.random(0, 7))
		end
	end
end

function Set_Weapon_Components(ped)
	Random_Weapon_Components(ped, joaat("weapon_appistol"), joaat("COMPONENT_APPISTOL_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_appistol"), joaat("COMPONENT_AT_PI_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_appistol"), joaat("COMPONENT_AT_PI_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_appistol"), joaat("COMPONENT_APPISTOL_VARMOD_SECURITY"), false)

	Random_Weapon_Components(ped, joaat("weapon_pistol50"), joaat("COMPONENT_PISTOL50_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_pistol50"), joaat("COMPONENT_AT_PI_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_pistol50"), joaat("COMPONENT_AT_AR_SUPP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_pistol50"), joaat("COMPONENT_PISTOL50_VARMOD_LUXE"), false)
	
	Random_Weapon_Components(ped, joaat("weapon_heavypistol"), joaat("COMPONENT_HEAVYPISTOL_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_heavypistol"), joaat("COMPONENT_AT_PI_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_heavypistol"), joaat("COMPONENT_AT_PI_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavypistol"), joaat("COMPONENT_HEAVYPISTOL_VARMOD_LUXE"), false)

	Random_Weapon_Components(ped, joaat("weapon_microsmg"), joaat("COMPONENT_MICROSMG_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_microsmg"), joaat("COMPONENT_AT_PI_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_microsmg"), joaat("COMPONENT_AT_SCOPE_MACRO"), false)
	Random_Weapon_Components(ped, joaat("weapon_microsmg"), joaat("COMPONENT_AT_AR_SUPP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_microsmg"), joaat("COMPONENT_MICROSMG_VARMOD_FRN"), false)

	Random_Weapon_Components(ped, joaat("weapon_combatpdw"), joaat("COMPONENT_COMBATPDW_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_combatpdw"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_combatpdw"), joaat("COMPONENT_AT_AR_AFGRIP"), false)
	Random_Weapon_Components(ped, joaat("weapon_combatpdw"), joaat("COMPONENT_AT_SCOPE_SMALL"), false)

	Random_Weapon_Components(ped, joaat("weapon_machinepistol"), joaat("COMPONENT_MACHINEPISTOL_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_machinepistol"), joaat("COMPONENT_AT_PI_SUPP"), false)

	Random_Weapon_Components(ped, joaat("weapon_minismg"), joaat("COMPONENT_MINISMG_CLIP_02"), true)
	
	Random_Weapon_Components(ped, joaat("weapon_tecpistol"), joaat("COMPONENT_TECPISTOL_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_tecpistol"), joaat("COMPONENT_AT_AR_SUPP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_tecpistol"), joaat("COMPONENT_AT_SCOPE_MACRO"), false)

	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun"), joaat("COMPONENT_AT_AR_FLSH"), true, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun"), joaat("COMPONENT_AT_SR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun"), joaat("COMPONENT_PUMPSHOTGUN_VARMOD_XM3"), false)

	Random_Weapon_Components(ped, joaat("weapon_combatshotgun"), joaat("COMPONENT_AT_AR_FLSH"), true, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_combatshotgun"), joaat("COMPONENT_AT_AR_SUPP"), false)

	Random_Weapon_Components(ped, joaat("weapon_assaultrifle"), joaat("COMPONENT_ASSAULTRIFLE_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle"), joaat("COMPONENT_ASSAULTRIFLE_CLIP_03"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle"), joaat("COMPONENT_AT_SCOPE_MACRO"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle"), joaat("COMPONENT_AT_AR_SUPP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle"), joaat("COMPONENT_AT_AR_AFGRIP"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle"), joaat("COMPONENT_ASSAULTRIFLE_VARMOD_LUXE"), false)

	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle"), joaat("COMPONENT_BULLPUPRIFLE_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle"), joaat("COMPONENT_AT_SCOPE_SMALL"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle"), joaat("COMPONENT_AT_AR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle"), joaat("COMPONENT_AT_AR_AFGRIP"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle"), joaat("COMPONENT_BULLPUPRIFLE_VARMOD_LOW"), false)

	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_AT_SCOPE_MACRO_02_MK2"), true)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_AT_SCOPE_SMALL_MK2"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_BULLPUPRIFLE_MK2_CLIP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_AT_SIGHTS"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_AT_BP_BARREL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_AT_AR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_AT_MUZZLE_07"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_AT_AR_AFGRIP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_BULLPUPRIFLE_MK2_CAMO"), false)
	Random_Weapon_Components(ped, joaat("weapon_bullpuprifle_mk2"), joaat("COMPONENT_BULLPUPRIFLE_MK2_CAMO_05"), false)

	Random_Weapon_Components(ped, joaat("weapon_compactrifle"), joaat("COMPONENT_COMPACTRIFLE_CLIP_02"), true)

	Random_Weapon_Components(ped, joaat("weapon_heavyrifle"), joaat("COMPONENT_HEAVYRIFLE_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_heavyrifle"), joaat("COMPONENT_HEAVYRIFLE_SIGHT_01"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavyrifle"), joaat("COMPONENT_AT_SCOPE_MEDIUM"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavyrifle"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_heavyrifle"), joaat("COMPONENT_AT_AR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavyrifle"), joaat("COMPONENT_AT_AR_AFGRIP"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavyrifle"), joaat("COMPONENT_HEAVYRIFLE_CAMO1"), false)

	Random_Weapon_Components(ped, joaat("weapon_mg"), joaat("COMPONENT_MG_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_mg"), joaat("COMPONENT_AT_SCOPE_SMALL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_mg"), joaat("COMPONENT_MG_VARMOD_LOWRIDER"), false)
	
	Random_Weapon_Components(ped, joaat("weapon_sniperrifle"), joaat("COMPONENT_AT_AR_SUPP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_sniperrifle"), joaat("COMPONENT_AT_SCOPE_MAX"), false)
	Random_Weapon_Components(ped, joaat("weapon_sniperrifle"), joaat("COMPONENT_AT_SCOPE_LARGE"), false)
	Random_Weapon_Components(ped, joaat("weapon_sniperrifle"), joaat("COMPONENT_SNIPERRIFLE_VARMOD_LUXE"), false)

	Random_Weapon_Components(ped, joaat("weapon_heavysniper"), joaat("COMPONENT_AT_SCOPE_LARGE"), true)
	Random_Weapon_Components(ped, joaat("weapon_heavysniper"), joaat("COMPONENT_AT_SCOPE_MAX"), false)

	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle"), joaat("COMPONENT_MARKSMANRIFLE_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle"), joaat("COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle"), joaat("COMPONENT_AT_AR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle"), joaat("COMPONENT_AT_AR_AFGRIP"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle"), joaat("COMPONENT_MARKSMANRIFLE_VARMOD_LUXE"), false)

	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_MARKSMANRIFLE_MK2_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM_MK2"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_AT_SIGHTS"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_AT_AR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_AT_MUZZLE_07"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_AT_AR_AFGRIP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_AT_MRFL_BARREL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_MARKSMANRIFLE_MK2_CAMO"), false)
	Random_Weapon_Components(ped, joaat("weapon_marksmanrifle_mk2"), joaat("COMPONENT_MARKSMANRIFLE_MK2_CAMO_07"), false)

	Random_Weapon_Components(ped, joaat("weapon_tacticalrifle"), joaat("COMPONENT_AT_AR_FLSH_REH"), true, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_tacticalrifle"), joaat("COMPONENT_TACTICALRIFLE_CLIP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_tacticalrifle"), joaat("COMPONENT_AT_AR_SUPP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_tacticalrifle"), joaat("COMPONENT_AT_AR_AFGRIP"), false)

	Random_Weapon_Components(ped, joaat("weapon_smg"), joaat("COMPONENT_SMG_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_smg"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_smg"), joaat("COMPONENT_AT_SCOPE_MACRO"), false)

	Random_Weapon_Components(ped, joaat("weapon_assaultsmg"), joaat("COMPONENT_ASSAULTSMG_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_assaultsmg"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_assaultsmg"), joaat("COMPONENT_AT_SCOPE_MACRO"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultsmg"), joaat("COMPONENT_AT_AR_SUPP_02"), false)

	Random_Weapon_Components(ped, joaat("weapon_assaultshotgun"), joaat("COMPONENT_ASSAULTSHOTGUN_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_assaultshotgun"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_assaultshotgun"), joaat("COMPONENT_AT_AR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultshotgun"), joaat("COMPONENT_AT_AR_AFGRIP"), false)

	Random_Weapon_Components(ped, joaat("weapon_carbinerifle"), joaat("COMPONENT_CARBINERIFLE_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle"), joaat("COMPONENT_AT_RAILCOVER_01"), false)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle"), joaat("COMPONENT_AT_SCOPE_MEDIUM"), false)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle"), joaat("COMPONENT_AT_AR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle"), joaat("COMPONENT_AT_AR_AFGRIP"), false)

	Random_Weapon_Components(ped, joaat("weapon_carbinerifle_mk2"), joaat("COMPONENT_CARBINERIFLE_MK2_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle_mk2"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle_mk2"), joaat("COMPONENT_AT_SIGHTS"), false)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle_mk2"), joaat("COMPONENT_AT_MUZZLE_07"), false)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle_mk2"), joaat("COMPONENT_AT_AR_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle_mk2"), joaat("COMPONENT_AT_CR_BARREL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_carbinerifle_mk2"), joaat("COMPONENT_CARBINERIFLE_MK2_CAMO"), false)

	Random_Weapon_Components(ped, joaat("weapon_combatmg"), joaat("COMPONENT_COMBATMG_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_combatmg"), joaat("COMPONENT_AT_SCOPE_MEDIUM"), false)
	Random_Weapon_Components(ped, joaat("weapon_combatmg"), joaat("COMPONENT_AT_AR_AFGRIP"), false)

	Random_Weapon_Components(ped, joaat("weapon_combatmg_mk2"), joaat("COMPONENT_COMBATMG_MK2_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_combatmg_mk2"), joaat("COMPONENT_AT_SCOPE_SMALL_MK2"), false)
	Random_Weapon_Components(ped, joaat("weapon_combatmg_mk2"), joaat("COMPONENT_AT_MUZZLE_07"), false)
	Random_Weapon_Components(ped, joaat("weapon_combatmg_mk2"), joaat("COMPONENT_AT_AR_AFGRIP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_combatmg_mk2"), joaat("COMPONENT_AT_MG_BARREL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_combatmg_mk2"), joaat("COMPONENT_COMBATMG_MK2_CAMO"), false)

	Random_Weapon_Components(ped, joaat("weapon_specialcarbine_mk2"), joaat("COMPONENT_SPECIALCARBINE_MK2_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine_mk2"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine_mk2"), joaat("COMPONENT_AT_SCOPE_MEDIUM_MK2"), false)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine_mk2"), joaat("COMPONENT_AT_MUZZLE_07"), false)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine_mk2"), joaat("COMPONENT_AT_AR_AFGRIP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine_mk2"), joaat("COMPONENT_AT_SC_BARREL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine_mk2"), joaat("COMPONENT_SPECIALCARBINE_MK2_CAMO_04"), false)

	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun_mk2"), joaat("COMPONENT_PUMPSHOTGUN_MK2_CLIP_EXPLOSIVE"), true)
	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun_mk2"), joaat("COMPONENT_AT_SCOPE_SMALL_MK2"), false)
	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun_mk2"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun_mk2"), joaat("COMPONENT_AT_SR_SUPP_03"), false)
	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun_mk2"), joaat("COMPONENT_AT_MUZZLE_08"), false)
	Random_Weapon_Components(ped, joaat("weapon_pumpshotgun_mk2"), joaat("COMPONENT_PUMPSHOTGUN_MK2_CAMO_02"), false)

	Random_Weapon_Components(ped, joaat("weapon_smg_mk2"), joaat("COMPONENT_SMG_MK2_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_smg_mk2"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_smg_mk2"), joaat("COMPONENT_AT_SIGHTS_SMG"), false)
	Random_Weapon_Components(ped, joaat("weapon_smg_mk2"), joaat("COMPONENT_AT_PI_SUPP"), false)
	Random_Weapon_Components(ped, joaat("weapon_smg_mk2"), joaat("COMPONENT_AT_MUZZLE_03"), false)
	Random_Weapon_Components(ped, joaat("weapon_smg_mk2"), joaat("COMPONENT_AT_SB_BARREL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_smg_mk2"), joaat("COMPONENT_SMG_MK2_CAMO_03"), false)

	Random_Weapon_Components(ped, joaat("weapon_assaultrifle_mk2"), joaat("COMPONENT_ASSAULTRIFLE_MK2_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle_mk2"), joaat("COMPONENT_AT_AR_AFGRIP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle_mk2"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle_mk2"), joaat("COMPONENT_AT_SIGHTS"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle_mk2"), joaat("COMPONENT_AT_MUZZLE_03"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle_mk2"), joaat("COMPONENT_AT_AR_BARREL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_assaultrifle_mk2"), joaat("COMPONENT_ASSAULTRIFLE_MK2_CAMO"), false)

	Random_Weapon_Components(ped, joaat("weapon_militaryrifle"), joaat("COMPONENT_MILITARYRIFLE_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_militaryrifle"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_militaryrifle"), joaat("COMPONENT_MILITARYRIFLE_SIGHT_01"), false)
	Random_Weapon_Components(ped, joaat("weapon_militaryrifle"), joaat("COMPONENT_AT_AR_SUPP"), false)

	Random_Weapon_Components(ped, joaat("weapon_specialcarbine"), joaat("COMPONENT_SPECIALCARBINE_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine"), joaat("COMPONENT_AT_SCOPE_MEDIUM"), false)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine"), joaat("COMPONENT_AT_AR_SUPP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_specialcarbine"), joaat("COMPONENT_AT_AR_AFGRIP"), false)

	Random_Weapon_Components(ped, joaat("weapon_heavyshotgun"), joaat("COMPONENT_HEAVYSHOTGUN_CLIP_03"), true)
	Random_Weapon_Components(ped, joaat("weapon_heavyshotgun"), joaat("COMPONENT_AT_AR_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_heavyshotgun"), joaat("COMPONENT_AT_AR_SUPP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavyshotgun"), joaat("COMPONENT_AT_AR_AFGRIP"), false)

	Random_Weapon_Components(ped, joaat("weapon_heavysniper_mk2"), joaat("COMPONENT_HEAVYSNIPER_MK2_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_heavysniper_mk2"), joaat("COMPONENT_AT_SCOPE_MAX"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavysniper_mk2"), joaat("COMPONENT_AT_SR_SUPP_03"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavysniper_mk2"), joaat("COMPONENT_AT_SR_BARREL_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavysniper_mk2"), joaat("COMPONENT_HEAVYSNIPER_MK2_CAMO_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_heavysniper_mk2"), joaat("COMPONENT_HEAVYSNIPER_MK2_CAMO_03"), false)

	Random_Weapon_Components(ped, joaat("weapon_gusenberg"), joaat("COMPONENT_GUSENBERG_CLIP_02"), true)

	Random_Weapon_Components(ped, joaat("weapon_pistol"), joaat("COMPONENT_PISTOL_CLIP_02"), true)
	Random_Weapon_Components(ped, joaat("weapon_pistol"), joaat("COMPONENT_AT_PI_FLSH"), false, FlashlightForAllCopWeapons)
	Random_Weapon_Components(ped, joaat("weapon_pistol"), joaat("COMPONENT_AT_PI_SUPP_02"), false)
	Random_Weapon_Components(ped, joaat("weapon_pistol"), joaat("COMPONENT_PISTOL_VARMOD_LUXE"), false)
end

---@param entity Entity
---@return integer address
function get_net_obj(entity)
	local pEntity = entities.handle_to_pointer(entity)
	return pEntity ~= NULL and memory.read_long(pEntity + 0xD0) or NULL
end


---@param entity Entity
---@return Player owner
function get_entity_owner(entity)
	local net_obj = get_net_obj(entity)
	return net_obj ~= NULL and memory.read_byte(net_obj + 0x49) or -1
end

function find_right_spawn_vehicle(posX, posY, posZ, minDist, maxDist)
	local outpos = v3.new()
	local outheading = memory.alloc(4)
	local foundCoord = PATHFIND.GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(posX + (math.random() < 0.5 and math.random(-maxDist, -minDist) or math.random(minDist, maxDist)), posY + (math.random() < 0.5 and math.random(-maxDist, -minDist) or math.random(minDist, maxDist)), posZ, outpos, outheading, 0, 3, 0)
	return outpos, memory.read_float(outheading), foundCoord
end

function find_right_spawn_normal(posX, posY, posZ, minDist, maxDist)
	local outpos = v3.new()
	local foundCoord = PATHFIND.GET_SAFE_COORD_FOR_PED(posX + (math.random() < 0.5 and math.random(-maxDist, -minDist) or math.random(minDist, maxDist)), posY + (math.random() < 0.5 and math.random(-maxDist, -minDist) or math.random(minDist, maxDist)), posZ, false, outpos, 16)
	return outpos, foundCoord
end

function SetPedHealth(ped, Health)
	PED.SET_PED_MAX_HEALTH(ped, Health)
	ENTITY.SET_ENTITY_MAX_HEALTH(ped, Health)
	ENTITY.SET_ENTITY_HEALTH(ped, Health)
end

util.on_stop(function()
	if CanSetModels then
		for i = 1, #police3_Addrs do
			memory.write_int(police3_Addrs[i], joaat("police3"))
		end
		for i = 1, #sheriff_Addrs do
			memory.write_int(sheriff_Addrs[i], joaat("sheriff"))
		end
		for i = 1, #polmav_Addrs do
			memory.write_int(polmav_Addrs[i], joaat("polmav"))
		end
		for i = 1, #sheriff2_Addrs do
			memory.write_int(sheriff2_Addrs[i], joaat("sheriff2"))
		end
		for i = 1, #fbi2_Addrs do
			memory.write_int(fbi2_Addrs[i], joaat("fbi2"))
		end
		for i = 1, #predator_Addrs do
			memory.write_int(predator_Addrs[i], joaat("predator"))
		end
		for i = 1, #copped_Addrs do
			memory.write_int(copped_Addrs[i], joaat("s_m_y_cop_01"))
		end
		for i = 1, #sheriffped_Addrs do
			memory.write_int(sheriffped_Addrs[i], joaat("s_m_y_sheriff_01"))
		end
		for i = 1, #swatped_Addrs do
			memory.write_int(swatped_Addrs[i], joaat("s_m_y_swat_01"))
		end
		for i = 1, #mesa3_Addrs do
			memory.write_int(mesa3_Addrs[i], joaat("mesa3"))
		end
		for i = 1, #blackopsPed_Addrs do
			memory.write_int(blackopsPed_Addrs[i], joaat("s_m_y_blackops_01"))
		end
	end
	if IncidentIndex ~= 0 then
		if MISC.IS_INCIDENT_VALID(IncidentIndex) then
			MISC.DELETE_INCIDENT(IncidentIndex)
		end
	end
end)

local VehicleModelsRandom = {
	"polmav",
	"savage",
	"annihilator",
	"valkyrie",
	"hunter",
	"buzzard",
	"khanjali",
	"rhino",
	"dune3",
	"caracara",
	"speedo4",
	"squaddie",
	"winky",
	"elegy",
	"elegy2",
	"caracara2",
	"tampa3",
	"nightshark",
	"technical3",
	"technical",
	"sultan2",
	"infernus2",
	"rcbandito",
	"insurgent3",
	"riata",
	"mesa3",
	"bruiser",
	"bruiser2",
	"bruiser3",
	"barrage",
	"apc",
	"cargobob",
	"cargobob2",
	"akula",
	"seasparrow"
}

function SetRandomModels()
	local RandomPolice3 = VehicleModelsRandom[math.random(#VehicleModelsRandom)]
	local RandomSheriff = VehicleModelsRandom[math.random(#VehicleModelsRandom)]
	local RandomPolmav = VehicleModelsRandom[math.random(#VehicleModelsRandom)]
	local RandomSheriff2 = VehicleModelsRandom[math.random(#VehicleModelsRandom)]
	local RandomFBI2 = VehicleModelsRandom[math.random(#VehicleModelsRandom)]
	local RandomCopPed = PedModels[math.random(#PedModels)]
	local RandomSheriffPed = PedModels[math.random(#PedModels)]
	local RandomSWATPed = PedModels[math.random(#PedModels)]
	for i = 1, #police3_Addrs do
		memory.write_int(police3_Addrs[i], joaat(RandomPolice3))
	end
	for i = 1, #sheriff_Addrs do
		memory.write_int(sheriff_Addrs[i], joaat(RandomSheriff))
	end
	for i = 1, #polmav_Addrs do
		memory.write_int(polmav_Addrs[i], joaat(RandomPolmav))
	end
	for i = 1, #sheriff2_Addrs do
		memory.write_int(sheriff2_Addrs[i], joaat(RandomSheriff2))
	end
	for i = 1, #fbi2_Addrs do
		memory.write_int(fbi2_Addrs[i], joaat(RandomFBI2))
	end
	for i = 1, #copped_Addrs do
		memory.write_int(copped_Addrs[i], joaat(RandomCopPed))
	end
	for i = 1, #sheriffped_Addrs do
		memory.write_int(sheriffped_Addrs[i], joaat(RandomSheriffPed))
	end
	for i = 1, #swatped_Addrs do
		memory.write_int(swatped_Addrs[i], joaat(RandomSWATPed))
	end
	SelectedPedModels[1] = RandomCopPed
	SelectedPedModels[2] = RandomSheriffPed
	SelectedPedModels[3] = RandomSWATPed
end

function SetCopModels(Police3, Cop, FBI2, Polmav, SWAT, SheriffPed, Sheriff, Sheriff2)
	local RandomPolice3 = Police3
	local RandomSheriff = Sheriff
	local RandomPolmav = Polmav
	local RandomSheriff2 = Sheriff2
	local RandomFBI2 = FBI2
	local RandomCopPed = Cop
	local RandomSheriffPed = SheriffPed
	local RandomSWATPed = SWAT
	for i = 1, #police3_Addrs do
		memory.write_int(police3_Addrs[i], joaat(RandomPolice3))
	end
	for i = 1, #sheriff_Addrs do
		memory.write_int(sheriff_Addrs[i], joaat(RandomSheriff))
	end
	for i = 1, #polmav_Addrs do
		memory.write_int(polmav_Addrs[i], joaat(RandomPolmav))
	end
	for i = 1, #sheriff2_Addrs do
		memory.write_int(sheriff2_Addrs[i], joaat(RandomSheriff2))
	end
	for i = 1, #fbi2_Addrs do
		memory.write_int(fbi2_Addrs[i], joaat(RandomFBI2))
	end
	for i = 1, #copped_Addrs do
		memory.write_int(copped_Addrs[i], joaat(RandomCopPed))
	end
	for i = 1, #sheriffped_Addrs do
		memory.write_int(sheriffped_Addrs[i], joaat(RandomSheriffPed))
	end
	for i = 1, #swatped_Addrs do
		memory.write_int(swatped_Addrs[i], joaat(RandomSWATPed))
	end
	SelectedPedModels[1] = RandomCopPed
	SelectedPedModels[2] = RandomSheriffPed
	SelectedPedModels[3] = RandomSWATPed
end

function SetMerryweatherModels(Mesa3, BlackopsPed)
	for i = 1, #mesa3_Addrs do
		memory.write_int(mesa3_Addrs[i], joaat(Mesa3))
	end
	for i = 1, #blackopsPed_Addrs do
		memory.write_int(blackopsPed_Addrs[i], joaat(BlackopsPed))
	end
	SelectedPedModels[14] = BlackopsPed
end

function SetPedRandomOutfit(Ped)
	--PED.SET_PED_DEFAULT_COMPONENT_VARIATION(Ped)
	PED.SET_PED_RANDOM_COMPONENT_VARIATION(Ped, 0)
	PED.SET_PED_RANDOM_PROPS(Ped)
	--[[
	for i = 1, 11 do
		local Drawables = PED.GET_NUMBER_OF_PED_DRAWABLE_VARIATIONS(Ped, i)
		if Drawables > 0 then
			Drawables = Drawables
			local RandomDrawable = math.random(0, Drawables-1)
			local Textures = PED.GET_NUMBER_OF_PED_TEXTURE_VARIATIONS(Ped, i, RandomDrawable)
			if Textures > 0 then
				Textures = Textures
				local RandomTexture = math.random(Textures-1)
				Print(Textures)
				local Palette = PED.GET_PED_PALETTE_VARIATION(Ped, i)
				if PED.IS_PED_COMPONENT_VARIATION_VALID(Ped, i, RandomDrawable, 0) then
					PED.SET_PED_COMPONENT_VARIATION(Ped, i, RandomDrawable, 0, -1)
				end
			end
		end
	end
	for i = 0, 8 do
		local Drawables = PED.GET_NUMBER_OF_PED_PROP_DRAWABLE_VARIATIONS(Ped, i)
		if Drawables > 0 then
			Drawables = Drawables
			local RandomDrawable = math.random(0, Drawables-1)
			local Textures = PED.GET_NUMBER_OF_PED_PROP_TEXTURE_VARIATIONS(Ped, i, RandomDrawable)
			if Textures > 0 then
				Textures = Textures
				PED.SET_PED_PROP_INDEX(Ped, i, RandomDrawable, math.random(0, Textures-1), false)
			end
		end
	end
	]]
end


local LightWeapons = {
	"weapon_appistol",
	"weapon_pistol50",
	"weapon_navyrevolver",
	"weapon_stungun_mp",
	"weapon_flaregun",
	"weapon_heavypistol",
	"weapon_raypistol",
	"weapon_gadgetpistol",
	"weapon_microsmg",
	"weapon_machinepistol",
	"weapon_minismg",
	"weapon_tecpistol"
}

function SetPedVehicleWeapon(Ped)
	for i = 1, #WeaponsForCops do
		local WeapHash = joaat(WeaponsForCops[i])
		if WEAPON.HAS_PED_GOT_WEAPON(Ped, WeapHash, 0) then
			local WeapHashAddr = memory.alloc(8)
			WEAPON.GET_CURRENT_PED_WEAPON(Ped, WeapHashAddr, true)
			if memory.read_int(WeapHashAddr) == WeapHash then
				return true
			else
				WEAPON.SET_CURRENT_PED_WEAPON(Ped, WeapHash, true)
				WEAPON.SET_CURRENT_PED_VEHICLE_WEAPON(Ped, WeapHash)
			end
		end
	end
	return false
end

function Draw2DText(Text, X, Y, Scale, Size, R, G, B, A, DropShadowDist)
	HUD.SET_TEXT_SCALE(Scale, Size)
	HUD.SET_TEXT_FONT(0)
    HUD.SET_TEXT_PROPORTIONAL(1)
    HUD.SET_TEXT_COLOUR(R, G, B, A)
    HUD.SET_TEXT_DROPSHADOW(DropShadowDist, 0, 0, 0, 255)
    HUD.SET_TEXT_EDGE(2, 0, 0, 0, 150)
    HUD.SET_TEXT_DROP_SHADOW()
    HUD.SET_TEXT_OUTLINE()
	HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("STRING")
	HUD.ADD_TEXT_COMPONENT_SUBSTRING_KEYBOARD_DISPLAY(Text)
	HUD.END_TEXT_COMMAND_DISPLAY_TEXT(X, Y, 0)
end

function RaycastFromCamera(PlayerPed, Distance, Flags)
	local FlagBits = -1
	if Flags ~= nil then
		FlagBits = Flags
	end
	local HitCoords = v3.new()
	local CamRot = CAM.GET_GAMEPLAY_CAM_ROT(2)
	local FVect = CamRot:toDir()
	local PPos = CAM.GET_GAMEPLAY_CAM_COORD()
	local AdjustedX = PPos.x + FVect.x * Distance
	local AdjustedY = PPos.y + FVect.y * Distance
	local AdjustedZ = PPos.z + FVect.z * Distance
	local DidHit = memory.alloc(1)
	local EndCoords = v3.new()
	local Normal = v3.new()
	local HitEntity = memory.alloc_int()
	
	local Handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
		PPos.x, PPos.y, PPos.z,
		AdjustedX, AdjustedY, AdjustedZ,
		FlagBits,
		PlayerPed, 7
	)
	SHAPETEST.GET_SHAPE_TEST_RESULT(Handle, DidHit, EndCoords, Normal, HitEntity)
	if memory.read_byte(DidHit) ~= 0 then
		HitCoords.x = EndCoords.x
		HitCoords.y = EndCoords.y
		HitCoords.z = EndCoords.z
	else
		HitCoords.x = AdjustedX
		HitCoords.y = AdjustedY
		HitCoords.z = AdjustedZ
	end
	return HitCoords, memory.read_byte(DidHit) ~= 0, memory.read_int(HitEntity)
end

function RaycastFromCameraAdjustedRot(PlayerPed, Distance, Flags, CamRot)
	local FlagBits = -1
	if Flags ~= nil then
		FlagBits = Flags
	end
	local RotNewV3 = v3.new(CamRot.x, CamRot.y, CamRot.z)
	local HitCoords = v3.new()
	local FVect = RotNewV3:toDir()
	local PPos = CAM.GET_GAMEPLAY_CAM_COORD()
	local AdjustedX = PPos.x + FVect.x * Distance
	local AdjustedY = PPos.y + FVect.y * Distance
	local AdjustedZ = PPos.z + FVect.z * Distance
	local DidHit = memory.alloc(1)
	local EndCoords = v3.new()
	local Normal = v3.new()
	local HitEntity = memory.alloc_int()
	
	local Handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
		PPos.x, PPos.y, PPos.z,
		AdjustedX, AdjustedY, AdjustedZ,
		FlagBits,
		PlayerPed, 7
	)
	SHAPETEST.GET_SHAPE_TEST_RESULT(Handle, DidHit, EndCoords, Normal, HitEntity)
	if memory.read_byte(DidHit) ~= 0 then
		HitCoords.x = EndCoords.x
		HitCoords.y = EndCoords.y
		HitCoords.z = EndCoords.z
	else
		HitCoords.x = AdjustedX
		HitCoords.y = AdjustedY
		HitCoords.z = AdjustedZ
	end
	return HitCoords, memory.read_byte(DidHit) ~= 0, memory.read_int(HitEntity)
end

function GetCamForwardCoords(Distance, CamRot)
	local HitCoords = v3.new()
	local FVect = CamRot:toDir()
	local PPos = CAM.GET_GAMEPLAY_CAM_COORD()
	local AdjustedX = PPos.x + FVect.x * Distance
	local AdjustedY = PPos.y + FVect.y * Distance
	local AdjustedZ = PPos.z + FVect.z * Distance
	return {x = AdjustedX, y = AdjustedY, z = AdjustedZ}
end

function ShapeTestNav(Entity, PPos, AdjustedVect, Flags)
	local FlagBits = -1
	if Flags ~= nil then
		FlagBits = Flags
	end
	local HitCoords = v3.new()
	local DidHit = memory.alloc(1)
	local EndCoords = v3.new()
	local Normal = v3.new()
	local HitEntity = memory.alloc_int()
	
	local Handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
		PPos.x, PPos.y, PPos.z,
		AdjustedVect.x, AdjustedVect.y, AdjustedVect.z,
		-1,
		Entity, 7
	)
	SHAPETEST.GET_SHAPE_TEST_RESULT(Handle, DidHit, EndCoords, Normal, HitEntity)
	if memory.read_byte(DidHit) ~= 0 then
		HitCoords.x = EndCoords.x
		HitCoords.y = EndCoords.y
		HitCoords.z = EndCoords.z
	else
		HitCoords.x = AdjustedVect.x
		HitCoords.y = AdjustedVect.y
		HitCoords.z = AdjustedVect.z
	end
	return HitCoords, memory.read_byte(DidHit) ~= 0, memory.read_int(HitEntity), Normal
end

function RotToQuat(rot)

	local quat = {}

	local pitch = math.rad(NormalizeEulerAngle(rot.x))
	local roll  = math.rad(NormalizeEulerAngle(rot.y))
	local yaw   = math.rad(NormalizeEulerAngle(rot.z))

    local cy = math.cos(yaw   * 0.5)
	local sy = math.sin(yaw   * 0.5)
	local cr = math.cos(roll  * 0.5)
	local sr = math.sin(roll  * 0.5)
	local cp = math.cos(pitch * 0.5)
	local sp = math.sin(pitch * 0.5)

	quat.x = cy * sp * cr - sy * cp * sr
	quat.y = cy * cp * sr + sy * sp * cr
	quat.z = sy * cr * cp - cy * sr * sp
	quat.w = cy * cr * cp + sy * sr * sp

	return quat

end

function QuatToRot(quat)

	local euler = {}

	local ysqr = quat.y * quat.y
	
	local t0 = 2.0 * (quat.w * quat.x + quat.y * quat.z)
	local t1 = 1.0 - 2.0 * (quat.x * quat.x + ysqr)
	euler.x = math.deg(math.atan2(t1, t0))
	
	local t2 = 2.0 * (quat.w * quat.y - quat.z * quat.x)
	local t2 = (t2 >  1.0) and  1.0 or t2
	local t2 = (t2 < -1.0) and -1.0 or t2
	euler.y = math.deg(math.asin(t2))
	
	local t3 = 2.0 * (quat.w * quat.z + quat.x * quat.y)
	local t4 = 1.0 - 2.0 * (ysqr + quat.z * quat.z)
	euler.z = math.deg(math.atan2(t4, t3))
	
	return euler

end

function Atan2_Function(x, y)

	if x > 0 then
		return math.atan(y / x)
	end

	if x < 0 and y >= 0 then
		return math.atan(y / x) + math.pi
	end

	if x < 0 and y < 0 then
		return math.atan(y / x) - math.pi
	end

	if x == 0 and y > 0 then
		return math.pi / 2
	end

	if x == 0 and y < 0 then
		return - (math.pi / 2)
	end

	if x == 0 and y == 0 then
		return nil
	end
end

function NormalizeEulerAngle(angle)
  
  while angle > 360 do
	Wait()
    angle = angle - 360
  end

  while angle < 0 do
	Wait()
    angle = angle + 360
  end

  return angle;

end

function RequestControlOfEntity(Entity)
	if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(Entity) then
		return true
	else
		return NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(Entity)
	end
end

local WhichMissionStartGlobal = SplitGlobals("Global_1886967[bParam0 /*609*/].f_10.f_32")
local InteriorsGlobal = SplitGlobals("Global_1886967[PLAYER::PLAYER_ID() /*609*/].f_536")
local MissionMenu = menu.list(menu.my_root(), "Missions", {}, "This will start some existing missions but edited to have something to do with cops in your side.")
local CalledTimes = 0
menu.action(MissionMenu, "Juggernaut Hunter Raid", {}, "Head Hunter but with powerful juggernauts, inside Life Invader.", function(toggle)
	local PlayerID = PLAYER.PLAYER_ID()
	if CalledTimes == 0 then
		if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("gb_headhunter")) == 0 then
			CalledTimes = 1
			memory.write_int(memory.script_global(WhichMissionStartGlobal + 609 * PlayerID), 166)
		end
		local InteriorsAddr = memory.script_global((InteriorsGlobal + 1) + 609 * PlayerID)
		local InteriorBits = memory.read_int(InteriorsAddr)
		if not is_bit_set(InteriorBits, 28) then
			memory.write_int(InteriorsAddr, set_bit(InteriorBits, 28))
		end
		while SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("gb_headhunter")) == 0 do
			Wait()
		end
		local EnemyPos = {
			{x = -1080.4959716797, y = -247.38218688965, z = 44.021259307861, heading = 272.7998046875},
			{x = -1075.7357177734, y = -247.38316345215, z = 44.021259307861, heading = 109.94403839111},
			{x = -1073.5018310547, y = -251.26336669922, z = 44.021144866943, heading = 24.946968078613},
			{x = -1070.2962646484, y = -248.71055603027, z = 44.021144866943, heading = 136.94508361816},
			{x = -1082.7797851562, y = -249.94247436523, z = 37.763290405273, heading = 161.91333007812},
			{x = -1087.3153076172, y = -252.57009887695, z = 37.763290405273, heading = 260.42572021484},
			{x = -1086.4970703125, y = -258.06216430664, z = 37.763290405273, heading = 325.92617797852},
			{x = -1074.0124511719, y = -251.79231262207, z = 37.763290405273, heading = 67.093109130859},
			{x = -1067.9763183594, y = -242.21368408203, z = 39.733184814453, heading = 217.19052124023},
			{x = -1065.7501220703, y = -246.55972290039, z = 39.733177185059, heading = 43.595375061035},
			{x = -1063.3648681641, y = -245.10153198242, z = 39.733177185059, heading = 111.81429290771},
			{x = -1063.9797363281, y = -243.65957641602, z = 39.733177185059, heading = 353.44216918945},
			{x = -1051.3376464844, y = -235.96850585938, z = 44.021179199219, heading = 117.43196868896},
			{x = -1056.4271240234, y = -241.15454101562, z = 44.021064758301, heading = 82.519561767578},
			{x = -1062.6623535156, y = -240.81518554688, z = 44.021137237549, heading = 144.05053710938},
			{x = -1061.4749755859, y = -244.7255859375, z = 44.021060943604, heading = 66.738822937012},
			{x = -1085.9837646484, y = -251.97950744629, z = 37.763298034668, heading = 282.31689453125}
		}
		local PositionNum = 1
		local EnemyAddrs = {
			SplitGlobals("Local_94.f_2[bVar0 /*26*/].f_1"),
			SplitGlobals("Local_94.f_2[iParam0 /*26*/].f_7[bVar1]"),
			SplitGlobals("Local_94.f_2[iParam0 /*26*/].f_3[iVar1].f_1"),
			SplitGlobals("Local_94.f_2[iParam0 /*26*/].f_3[iVar1].f_2")
		}
		local TriesCount = 0
		local EnemyModel = joaat("u_m_y_juggernaut_01")
		local CreatedEverything = false
		while not CreatedEverything do
			local IsHost = false
			local ScriptStatus = 0
			util.spoof_script("gb_headhunter", function()
				IsHost = NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT()
				if not IsHost then
					NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
				end
				IsHost = NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT()
				if IsHost then
					NETWORK.NETWORK_PREVENT_SCRIPT_HOST_MIGRATION()
				end
				ScriptStatus = NETWORK.NETWORK_GET_SCRIPT_STATUS()
			end)
			if IsHost and ScriptStatus == 2 then
				local NetIDsFound = 0
				if TriesCount < 100 then
					if not STREAMING.HAS_MODEL_LOADED(EnemyModel) then
						STREAMING.REQUEST_MODEL(EnemyModel)
					end
					if STREAMING.HAS_MODEL_LOADED(EnemyModel) then
						for i = 0, 3 do
							for k = 0, 3 do
								local OldNetID = memory.read_int(memory.script_local("gb_headhunter", EnemyAddrs[k+1] + 26 * i))
								if OldNetID ~= 0 then
									NetIDsFound = NetIDsFound + 1
								end
							end
						end
						if NetIDsFound >= 10 then
							for i = 0, 3 do
								for k = 0, 3 do
									local OldNetID = memory.read_int(memory.script_local("gb_headhunter", EnemyAddrs[k+1] + 26 * i))
									if OldNetID ~= 0 then
										util.spoof_script("gb_headhunter", function()
											local OldPed = NETWORK.NET_TO_PED(OldNetID)
											local Ped = PED.CREATE_PED(28, EnemyModel, EnemyPos[PositionNum].x, EnemyPos[PositionNum].y, EnemyPos[PositionNum].z, EnemyPos[PositionNum].heading, true, true)
											ENTITY.SET_ENTITY_AS_MISSION_ENTITY(Ped, false, true)
											local NetID = NETWORK.PED_TO_NET(Ped)
											if NetID ~= 0 then
												memory.write_int(memory.script_local("gb_headhunter", EnemyAddrs[k+1] + 26 * i), NetID)
												RequestControlOfEntity(OldPed)
												entities.delete_by_handle(OldPed)
												SetPedCombatAbilities(Ped)
												PED.SET_PED_RELATIONSHIP_GROUP_HASH(Ped, joaat("relHeadHunterAi"))
												SetPedHealth(Ped, 10000)
												PED.SET_PED_SUFFERS_CRITICAL_HITS(Ped, false)
												PED.SET_RAGDOLL_BLOCKING_FLAGS(Ped, 1)
												WEAPON.GIVE_WEAPON_TO_PED(Ped, joaat("weapon_minigun"), 99999, false, true)
												HUD.SET_PED_HAS_AI_BLIP_WITH_COLOUR(Ped, true, 1)
												HUD.SET_PED_AI_BLIP_HAS_CONE(Ped, false)
												HUD.SET_PED_AI_BLIP_FORCED_ON(Ped, true)
												PositionNum = PositionNum + 1
												CreatedEverything = true
											end
										end)
									end
								end
							end
						end
					end
				else
					CreatedEverything = true
				end
			end
			Wait()
		end
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(EnemyModel)
		CalledTimes = 0
	else
		memory.write_int(memory.script_global(WhichMissionStartGlobal + 609 * PlayerID), 166)
	end
end)

menu.action(MissionMenu, "Fortified Tampa3", {}, "Instead of a Boxville, will be another vehicle.", function(toggle)
	if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("gb_fortified")) > 0 then
		local Model = "cargobob2"
		local BoxvilleNetID = SplitGlobals("Local_1085.f_13[bParam0]")
		local NetID = memory.read_int(memory.script_local("gb_fortified", BoxvilleNetID))
		if NetID ~= 0 then
			local VehHandle = 0
			util.spoof_script("gb_fortified", function()
				VehHandle = NETWORK.NET_TO_VEH(NetID)
			end)
			if VehHandle ~= 0 then
				STREAMING.REQUEST_MODEL(joaat(Model))
				while not STREAMING.HAS_MODEL_LOADED(joaat(Model)) do
					Wait()
				end
				local OldPos = ENTITY.GET_ENTITY_COORDS(VehHandle)
				local Heading = ENTITY.GET_ENTITY_HEADING(VehHandle)
				local NewVeh = 0
				local NewNetID = 0
				util.spoof_script("gb_fortified", function()
					NewVeh = VEHICLE.CREATE_VEHICLE(joaat(Model), OldPos.x, OldPos.y, OldPos.z, Heading, true, true, false)
					ENTITY.SET_ENTITY_AS_MISSION_ENTITY(NewVeh, false, true)
					NewNetID = NETWORK.VEH_TO_NET(NewVeh)
				end)
				if NewNetID ~= 0 then
					NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(NewNetID, true)
    				NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NewNetID, PLAYER.PLAYER_ID(), true)
					memory.write_int(memory.script_local("gb_fortified", BoxvilleNetID), NewNetID)
					VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(NewVeh, 5000)
					VEHICLE.SET_VEHICLE_BODY_HEALTH(NewVeh, 5000)
					VEHICLE.SET_VEHICLE_ENGINE_HEALTH(NewVeh, 5000)
					VEHICLE.SET_VEHICLE_COLOURS(NewVeh, 17, 12)
					VEHICLE.SET_VEHICLE_EXTRA_COLOURS(NewVeh, 1, 156)
					VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(NewVeh, false)
					VEHICLE.SET_VEHICLE_AUTOMATICALLY_ATTACHES(NewVeh, false, 0)
					VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(NewVeh, true)
					VEHICLE.SET_DONT_ALLOW_PLAYER_TO_ENTER_VEHICLE_IF_LOCKED_FOR_PLAYER(NewVeh, true)
					VEHICLE.SET_VEHICLE_CAN_BE_USED_BY_FLEEING_PEDS(NewVeh, false)
					VEHICLE.SET_VEHICLE_EXPLODES_ON_HIGH_EXPLOSION_DAMAGE(NewVeh, false)
					VEHICLE.SET_VEHICLE_USES_MP_PLAYER_DAMAGE_MULTIPLIER(NewVeh, 0)
					VEHICLE.SET_VEHICLE_STRONG(NewVeh, true)
					VEHICLE.SET_VEHICLE_DAMAGE_SCALE(NewVeh, 0.1)
					VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON_SYNCED(NewVeh, false, false)
					VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(NewVeh, 2000)
					VEHICLE.SET_VEHICLE_BODY_HEALTH(NewVeh, 2000)
					VEHICLE.SET_VEHICLE_ENGINE_HEALTH(NewVeh, 2000)
					VEHICLE.SET_DISABLE_VEHICLE_ENGINE_FIRES(NewVeh, true)
					VEHICLE.VEHICLE_SET_RAMP_AND_RAMMING_CARS_TAKE_DAMAGE(NewVeh, false)
					ENTITY.SET_ENTITY_PROOFS(NewVeh, false, true, false, false, true, false, false, false)
					VEHICLE.SET_VEHICLE_MOD_KIT(NewVeh, 1)
					VEHICLE.SET_VEHICLE_WHEEL_TYPE(NewVeh, math.random(0, 12))
					util.create_thread(function()
						while ENTITY.DOES_ENTITY_EXIST(NewVeh) do
							VEHICLE.SET_VEHICLE_DOOR_CONTROL(NewVeh, 5, 360, 360.0)
							VEHICLE.SET_TRAILER_ATTACHMENT_ENABLED(NewVeh, true)
							Wait()
						end
					end)
					for k = 0, 47 do
						local NumMods = entities.get_upgrade_max_value(NewVeh, k)
						entities.set_upgrade_value(NewVeh, k, NumMods, false)
					end
					NETWORK.NETWORK_SET_ENTITY_CAN_BLEND(NewVeh, true)
					NETWORK.NETWORK_ENABLE_EXTRA_VEHICLE_ORIENTATION_BLEND_CHECKS(NewNetID, true)
					entities.delete_by_handle(VehHandle)
				else
					entities.delete_by_handle(NewVeh)
				end
				STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(joaat(Model))
			else
				STREAMING.REQUEST_MODEL(joaat(Model))
				while not STREAMING.HAS_MODEL_LOADED(joaat(Model)) do
					Wait()
				end
				local PlayerPed = PLAYER.PLAYER_PED_ID()
				local OldPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
				local Heading = ENTITY.GET_ENTITY_HEADING(PlayerPed)
				local NewVeh = 0
				local NewNetID = 0
				util.spoof_script("gb_fortified", function()
					NewVeh = VEHICLE.CREATE_VEHICLE(joaat(Model), OldPos.x, OldPos.y, OldPos.z, Heading, true, true, false)
					ENTITY.SET_ENTITY_AS_MISSION_ENTITY(NewVeh, false, true)
					NewNetID = NETWORK.VEH_TO_NET(NewVeh)
				end)
				if NewNetID ~= 0 then
					NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(NewNetID, true)
    				NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NewNetID, PLAYER.PLAYER_ID(), true)
					memory.write_int(memory.script_local("gb_fortified", BoxvilleNetID), NewNetID)
					VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(NewVeh, 5000)
					VEHICLE.SET_VEHICLE_BODY_HEALTH(NewVeh, 5000)
					VEHICLE.SET_VEHICLE_ENGINE_HEALTH(NewVeh, 5000)
					VEHICLE.SET_VEHICLE_COLOURS(NewVeh, 17, 12)
					VEHICLE.SET_VEHICLE_EXTRA_COLOURS(NewVeh, 1, 156)
					VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(NewVeh, false)
					VEHICLE.SET_VEHICLE_AUTOMATICALLY_ATTACHES(NewVeh, false, 0)
					VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(NewVeh, true)
					VEHICLE.SET_DONT_ALLOW_PLAYER_TO_ENTER_VEHICLE_IF_LOCKED_FOR_PLAYER(NewVeh, true)
					VEHICLE.SET_VEHICLE_CAN_BE_USED_BY_FLEEING_PEDS(NewVeh, false)
					VEHICLE.SET_VEHICLE_EXPLODES_ON_HIGH_EXPLOSION_DAMAGE(NewVeh, false)
					VEHICLE.SET_VEHICLE_USES_MP_PLAYER_DAMAGE_MULTIPLIER(NewVeh, 0)
					VEHICLE.SET_VEHICLE_STRONG(NewVeh, true)
					VEHICLE.SET_VEHICLE_DAMAGE_SCALE(NewVeh, 0.1)
					VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON_SYNCED(NewVeh, false, false)
					VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(NewVeh, 2000)
					VEHICLE.SET_VEHICLE_BODY_HEALTH(NewVeh, 2000)
					VEHICLE.SET_VEHICLE_ENGINE_HEALTH(NewVeh, 2000)
					VEHICLE.SET_DISABLE_VEHICLE_ENGINE_FIRES(NewVeh, true)
					VEHICLE.VEHICLE_SET_RAMP_AND_RAMMING_CARS_TAKE_DAMAGE(NewVeh, false)
					ENTITY.SET_ENTITY_PROOFS(NewVeh, false, true, false, false, true, false, false, false)
					VEHICLE.SET_VEHICLE_MOD_KIT(NewVeh, 0)
					VEHICLE.SET_VEHICLE_WHEEL_TYPE(NewVeh, math.random(0, 12))
					for k = 0, 47 do
						local NumMods = entities.get_upgrade_max_value(NewVeh, k)
						entities.set_upgrade_value(NewVeh, k, NumMods, false)
					end
					util.create_thread(function()
						while ENTITY.DOES_ENTITY_EXIST(NewVeh) do
							VEHICLE.SET_VEHICLE_DOOR_CONTROL(NewVeh, 5, 360, 360.0)
							VEHICLE.SET_TRAILER_ATTACHMENT_ENABLED(NewVeh, true)
							Wait()
						end
					end)
					NETWORK.NETWORK_SET_ENTITY_CAN_BLEND(NewVeh, true)
					NETWORK.NETWORK_ENABLE_EXTRA_VEHICLE_ORIENTATION_BLEND_CHECKS(NewNetID, true)
				else
					entities.delete_by_handle(NewVeh)
				end
				STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(joaat(Model))
			end
		end
	end
end)

local BB_Locals = {
	SPD = SplitGlobals("Local_217.f_1298.f_4"),
	RSPD = SplitGlobals("Local_217.f_1298.f_5"),
	GoTo = {
		Pos = SplitGlobals("Local_217.f_1306.f_1[iVar4 /*11*/]"),
		Radius = SplitGlobals("Local_217.f_1306.f_1[iVar4 /*11*/].f_3")
	},
	Objects = {
		NextObject = 13,
		Model = SplitGlobals("Local_217.f_19.f_5[iVar4 /*13*/].f_2"),
		Pos = SplitGlobals("Local_217.f_19.f_5[iVar4 /*13*/].f_3"),
		Head = SplitGlobals("Local_217.f_19.f_5[iVar4 /*13*/].f_6"),
		Rot = SplitGlobals("Local_217.f_19.f_5[iVar4 /*13*/].f_7")
	},
	Peds = {
		NextPed = 21,
		Bits = SplitGlobals("Local_217.f_129.f_1[iVar4 /*21*/][iVar5]"),
		Model = SplitGlobals("Local_217.f_129.f_1[iVar4 /*21*/].f_2"),
		SpawnPos = SplitGlobals("Local_217.f_129.f_1[iVar4 /*21*/].f_3"),
		Head = SplitGlobals("Local_217.f_129.f_1[iVar4 /*21*/].f_6"),
		WeaponHash = SplitGlobals("Local_217.f_129.f_1[iVar4 /*21*/].f_7"),
		DefenseSphere = SplitGlobals("Local_217.f_129.f_1[iVar4 /*21*/].f_20")
	}
}
local LifeInvaderBattle = false
menu.toggle(MissionMenu, "LifeInvader B Battle", {}, "Inside LifeInvader business battle.", function(toggle)
	LifeInvaderBattle = toggle
	if LifeInvaderBattle then
		local HasSetValues = 0
		local WeaponHash = joaat("weapon_assaultrifle_mk2")
		local PedsModel = joaat("s_m_y_valet_01")
		local ObjsModel = joaat("prop_large_gold")
		local ObjectivePos = {x = -1080.8048095703, y = -261.60684204102, z = 37.799789428711}
		local ObjectiveRadius = 50.0
		local PedsPos = {
			{x = -1087.6712646484, y = -256.28527832031, z = 37.763282775879, heading = 317.04412841797},
			{x = -1085.9385986328, y = -254.39859008789, z = 37.763282775879, heading = 137.29330444336},
			{x = -1075.9951171875, y = -252.33447265625, z = 37.763282775879, heading = 91.073524475098},
			{x = -1077.7125244141, y = -245.17630004883, z = 37.763282775879, heading = 194.17456054688},
			{x = -1081.5103759766, y = -244.91067504883, z = 37.763282775879, heading = 219.81864929199},
			{x = -1066.537109375, y = -243.16424560547, z = 39.73314666748, heading = 189.76692199707},
			{x = -1065.4976806641, y = -245.53004455566, z = 39.73314666748, heading = 21.478647232056},
			{x = -1072.6848144531, y = -241.59085083008, z = 42.271343231201, heading = 313.80578613281},
			{x = -1077.9658203125, y = -243.78364562988, z = 44.021301269531, heading = 193.70272827148},
			{x = -1080.2751464844, y = -253.29470825195, z = 44.021152496338, heading = 353.45077514648},
			{x = -1072.3813476562, y = -250.5845489502, z = 44.021144866943, heading = 43.232421875},
			{x = -1067.2326660156, y = -246.84761047363, z = 44.021144866943, heading = 163.3111114502},
			{x = -1059.3846435547, y = -239.62316894531, z = 44.021137237549, heading = 142.5703125},
			{x = -1048.9936523438, y = -241.72116088867, z = 44.021068572998, heading = 114.12253570557},
			{x = -1057.2109375, y = -246.17663574219, z = 44.021068572998, heading = 79.579582214355},
			{x = -1056.1311035156, y = -238.80665588379, z = 39.733184814453, heading = 80.411964416504},
			{x = -1052.5837402344, y = -234.63899230957, z = 39.733177185059, heading = 222.48593139648},
			{x = -1046.2181396484, y = -238.91163635254, z = 37.964950561523, heading = 298.96002197266},
			{x = -1043.1195068359, y = -236.90420532227, z = 37.964950561523, heading = 124.09884643555},
			{x = -1048.3940429688, y = -230.18333435059, z = 39.01439666748, heading = 245.88464355469},
			{x = -1046.9338378906, y = -232.75114440918, z = 39.013687133789, heading = 64.511749267578},
			{x = -1068.4056396484, y = -241.455078125, z = 39.733180999756, heading = 247.36938476562},
			{x = -1088.3804931641, y = -252.01094055176, z = 37.763282775879, heading = 260.53143310547},
			{x = -1088.1639404297, y = -249.92352294922, z = 37.763282775879, heading = 216.87854003906},
			{x = -1079.8618164062, y = -250.39491271973, z = 44.021152496338, heading = 290.35891723633},
			{x = -1053.9376220703, y = -230.67840576172, z = 44.020931243896, heading = 144.04750061035},
			{x = -1052.9289550781, y = -232.97819519043, z = 44.020961761475, heading = 101.76502990723},
			{x = -1048.2755126953, y = -238.07299804688, z = 44.021068572998, heading = 160.03353881836},
			{x = -1067.9248046875, y = -243.18556213379, z = 44.021152496338, heading = 282.78820800781},
			{x = -1063.9366455078, y = -250.69804382324, z = 44.27201461792, heading = 14.506971359253}
		}
		local ObjsPos = {
			{x = -1053.1213378906, y = -233.37078857422, z = 44.020977020264, heading = 109.95386505127},
			{x = -1055.0378417969, y = -231.60066223145, z = 44.021026611328, heading = 217.24800109863},
			{x = -1057.1375732422, y = -239.30308532715, z = 44.021148681641, heading = 126.23188781738},
			{x = -1056.8336181641, y = -245.90200805664, z = 44.021072387695, heading = 7.0497169494629},
			{x = -1059.4187011719, y = -246.88134765625, z = 44.021064758301, heading = 123.00937652588},
			{x = -1052.2106933594, y = -236.50311279297, z = 44.021133422852, heading = 310.19027709961},
			{x = -1049.0280761719, y = -238.1633605957, z = 44.021064758301, heading = 168.87643432617},
			{x = -1048.44140625, y = -241.09480285645, z = 44.021064758301, heading = 118.88693237305}
		}
		while LifeInvaderBattle do
			local PlayerID = PLAYER.PLAYER_ID()
			local Bits = memory.read_int(memory.script_global((InteriorsGlobal + 1) + 609 * PlayerID))
			if not is_bit_set(Bits, 28) then
				memory.write_int(memory.script_global((InteriorsGlobal + 1) + 609 * PlayerID), set_bit(Bits, 28))
			end
			if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_content_business_battles")) > 0 then
				util.spoof_script("fm_content_business_battles", function()
					NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
				end)
				if HasSetValues < 100 then
					HasSetValues = HasSetValues + 1
					for i = 1, 30 do
						local ModelAddrLocal = memory.script_local("fm_content_business_battles", BB_Locals.Peds.Model + BB_Locals.Peds.NextPed * (i - 1))
						memory.write_int(ModelAddrLocal, PedsModel)
						local BitsAddrLocal = memory.script_local("fm_content_business_battles", BB_Locals.Peds.Bits + BB_Locals.Peds.NextPed * (i - 1))
						memory.write_int(BitsAddrLocal, 1024)
						local PosAddrLocal = memory.script_local("fm_content_business_battles", BB_Locals.Peds.SpawnPos + BB_Locals.Peds.NextPed * (i - 1))
						memory.write_float(PosAddrLocal, PedsPos[i].x)
						memory.write_float(PosAddrLocal + 0x8, PedsPos[i].y)
						memory.write_float(PosAddrLocal + 0x10, PedsPos[i].z)
						local HeadAddrLocal = memory.script_local("fm_content_business_battles", BB_Locals.Peds.Head + BB_Locals.Peds.NextPed * (i - 1))
						memory.write_float(HeadAddrLocal, PedsPos[i].heading)
						local WeaponAddrLocal = memory.script_local("fm_content_business_battles", BB_Locals.Peds.WeaponHash + BB_Locals.Peds.NextPed * (i - 1))
						memory.write_int(WeaponAddrLocal, WeaponHash)
						local DefenseSphereAddrLocal = memory.script_local("fm_content_business_battles", BB_Locals.Peds.DefenseSphere + BB_Locals.Peds.NextPed * (i - 1))
						memory.write_float(DefenseSphereAddrLocal, -1.0)
					end
					for i = 1, 8 do
						local ModelAddrLocal = memory.script_local("fm_content_business_battles", BB_Locals.Objects.Model + BB_Locals.Objects.NextObject * (i - 1))
						memory.write_int(ModelAddrLocal, ObjsModel)
						local PosAddrLocal = memory.script_local("fm_content_business_battles", BB_Locals.Objects.Pos + BB_Locals.Objects.NextObject * (i - 1))
						memory.write_float(PosAddrLocal, ObjsPos[i].x)
						memory.write_float(PosAddrLocal + 0x8, ObjsPos[i].y)
						memory.write_float(PosAddrLocal + 0x10, ObjsPos[i].z)
						local HeadAddrLocal = memory.script_local("fm_content_business_battles", BB_Locals.Objects.Head + BB_Locals.Objects.NextObject * (i - 1))
						memory.write_float(HeadAddrLocal, ObjsPos[i].heading)
					end
					local GoToPosAddrLocal = memory.script_local("fm_content_business_battles", BB_Locals.GoTo.Pos)
					memory.write_float(GoToPosAddrLocal, ObjectivePos.x)
					memory.write_float(GoToPosAddrLocal + 0x8, ObjectivePos.y)
					memory.write_float(GoToPosAddrLocal + 0x10, ObjectivePos.z)
					local RSPDAddrLocal = memory.script_local("fm_content_business_battles", BB_Locals.RSPD)
					memory.write_int(RSPDAddrLocal, 0)
					local SPDAddrLocal = memory.script_local("fm_content_business_battles", BB_Locals.SPD)
					memory.write_int(SPDAddrLocal, 0)
				end
			else
				HasSetValues = 0
			end
			Wait()
		end
	end
end)

local WeaponizedVehiclesMenu = menu.list(menu.my_root(), "Weaponized Vehicles", {}, "")

local HomingShootsAtPlayers = true
menu.toggle(WeaponizedVehiclesMenu, "Homing Shoot At Players", {}, "Will focus players too.", function(toggle)
	HomingShootsAtPlayers = toggle
end, HomingShootsAtPlayers)
local AvoidFocusingFriends = true
menu.toggle(WeaponizedVehiclesMenu, "Homing Shoot Avoid Friends", {}, "Will not focus friend players.", function(toggle)
	AvoidFocusingFriends = toggle
end, AvoidFocusingFriends)
local HomingShootsAtPeds = true
menu.toggle(WeaponizedVehiclesMenu, "Homing Shoot At Peds", {}, "Will focus peds too.", function(toggle)
	HomingShootsAtPeds = toggle
end, HomingShootsAtPeds)

local SetTurretPropInvisible = false
menu.toggle(WeaponizedVehiclesMenu, "Set Turret Prop Invisible", {}, "To hide your powers!", function(toggle)
	SetTurretPropInvisible = toggle
end, SetTurretPropInvisible)

local VehRemoteGuns = false
menu.toggle(WeaponizedVehiclesMenu, "Weaponize Vehicle", {}, "With a turret prop with homing shoots button, press horn button to enable homing, press switch radio button to switch target, and fire button to attack.", function(toggle)
	VehRemoteGuns = toggle
	if not VehRemoteGuns then
		local PlayerID = PLAYER.PLAYER_ID()
		for index, objs in pairs(entities.get_all_objects_as_handles()) do
			local DecorInt = DECORATOR.DECOR_GET_INT(objs, "Casino_Game_Info_Decorator")
			if DecorInt == 31 or DecorInt == 32 then
				local CanDelete = false
				local EntOwner = get_entity_owner(objs)
				if NETWORK.NETWORK_IS_PLAYER_CONNECTED(EntOwner) then
					if EntOwner == PlayerID then
						CanDelete = true
					end
				else
					CanDelete = true
				end
				if CanDelete then
					util.create_thread(function ()
						local Tick = 0
						while not RequestControlOfEntity(objs) and Tick < 1000 do
							Tick = Tick + 1
							Wait()
						end
						local NetID = NETWORK.OBJ_TO_NET(objs)
						if NetID ~= 0 then
							NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PLAYER.PLAYER_ID(), false)
						end
						entities.delete_by_handle(objs)
					end)
				end
			end
		end
		GRAPHICS.SET_STREAMED_TEXTURE_DICT_AS_NO_LONGER_NEEDED("helicopterhud")
	end
	if VehRemoteGuns then
		local TurretModel = joaat("p_rcss_folded")
		local VehsWithTurret = {}
		local Shooted = 0
		local IsAircraft = false
		local Weaps = {joaat("weapon_navyrevolver"), joaat("weapon_rpg")}
		local Targets = {}
		local SelectedTarget = 1
		local TargetsState = 0
		local TargetDied = false
		local ScanPeds = false
		local LastVeh = 0
		local PTFXAsset = "weap_ch_vehicle_weapons"
		local PTFXName = "bullet_tracer_ch_tank_laser"
		while VehRemoteGuns do
			if not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(PTFXAsset) then
				STREAMING.REQUEST_NAMED_PTFX_ASSET(PTFXAsset)
				while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(PTFXAsset) do
					Wait()
				end
			end
			local PlayerPed = PLAYER.PLAYER_PED_ID()
			local Veh = PED.GET_VEHICLE_PED_IS_IN(PlayerPed, false)
			PAD.DISABLE_CONTROL_ACTION(0, 85, true)
			if not GRAPHICS.HAS_STREAMED_TEXTURE_DICT_LOADED("helicopterhud") then
				GRAPHICS.REQUEST_STREAMED_TEXTURE_DICT("helicopterhud", false)
			end
			if PAD.IS_CONTROL_JUST_PRESSED(0, 46) or PAD.IS_CONTROL_JUST_PRESSED(0, 113) or ScanPeds then
				if TargetsState == 0 then
					local PedsT = entities.get_all_peds_as_handles()
					local PlayerPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
					for index, peds in pairs(PedsT) do
						if peds ~= PlayerPed then
							if not ENTITY.IS_ENTITY_DEAD(peds) then
								if not PED.IS_PED_DEAD_OR_DYING(peds, true) then
									if ENTITY.IS_ENTITY_ON_SCREEN(peds) then
										if not DECORATOR.DECOR_EXIST_ON(peds, "Casino_Game_Info_Decorator") then
											if not PED.IS_PED_IN_VEHICLE(peds, Veh, true) then
												if HomingShootsAtPeds then
													if not PED.IS_PED_A_PLAYER(peds) then
														local TargetRelHash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(peds)
														if PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PlayerPed) ~= 1 then
															local PedCoords = ENTITY.GET_ENTITY_COORDS(peds)
															local Distance = MISC.GET_DISTANCE_BETWEEN_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z, PedCoords.x, PedCoords.y, PedCoords.z, true)
															Targets[#Targets+1] = {Handle = peds, Distance = Distance}
														end
													end
												end
												if HomingShootsAtPlayers then
													if PED.IS_PED_A_PLAYER(peds) then
														local CanInsert = true
														if AvoidFocusingFriends then
															local Player = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(peds)
															local Handle = memory.alloc(13*8)
															NETWORK.NETWORK_HANDLE_FROM_PLAYER(Player, Handle, 13)
															CanInsert = not NETWORK.NETWORK_IS_FRIEND(Handle)
														end
														if CanInsert then
															local PedCoords = ENTITY.GET_ENTITY_COORDS(peds)
															local Distance = MISC.GET_DISTANCE_BETWEEN_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z, PedCoords.x, PedCoords.y, PedCoords.z, true)
															Targets[#Targets+1] = {Handle = peds, Distance = Distance}
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
					local ClosestDist = 10000.0
					local ClosestHandle = 0
					for i = 1, #Targets do
						if Targets[i].Distance < ClosestDist then
							ClosestDist = Targets[i].Distance
							ClosestHandle = Targets[i].Handle
							SelectedTarget = i
						end
					end
					TargetsState = 1
					ScanPeds = false
				else
					for i = 1, #Targets do
						table.remove(Targets, #Targets)
					end
					TargetsState = 0
				end
			end
			local IsInVeh = PED.IS_PED_IN_ANY_VEHICLE(PlayerPed, true)
			for i = 1, #Targets do
				if Targets[i] ~= nil then
					local PedCoords = ENTITY.GET_ENTITY_COORDS(Targets[i].Handle)
					local ScreenX, ScreenY = memory.alloc(8), memory.alloc(8)
					if GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(PedCoords.x, PedCoords.y, PedCoords.z, ScreenX, ScreenY) then
						local R, G, B = 255, 255, 255
						local XSize = 0.05
						local YSize = 0.1
						local TXTName = "hud_lock"
						if i == SelectedTarget then
							R = 255
							G = 255
							B = 255
							XSize = 0.025
							YSize = 0.05
							TXTName = "hud_target"
						end
						if IsInVeh then
							if GRAPHICS.HAS_STREAMED_TEXTURE_DICT_LOADED("helicopterhud") then
								GRAPHICS.DRAW_SPRITE("helicopterhud", TXTName, memory.read_float(ScreenX), memory.read_float(ScreenY), XSize, YSize, 0.0, R, G, B, 200, false, false)
							end
						end
					end
					if ENTITY.IS_ENTITY_DEAD(Targets[i].Handle) then
						table.remove(Targets, i)
						TargetDied = true
					end
				end
			end
			if #Targets > 0 then
				if Targets[SelectedTarget] ~= nil then
					if ENTITY.IS_ENTITY_DEAD(Targets[SelectedTarget].Handle) or not ENTITY.DOES_ENTITY_EXIST(Targets[SelectedTarget].Handle) then
						table.remove(Targets, SelectedTarget)
						TargetDied = true
					end
				end
				if Targets[SelectedTarget] ~= nil then
					if not ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(PlayerPed, Targets[SelectedTarget].Handle, 17)
					or not ENTITY.IS_ENTITY_ON_SCREEN(Targets[SelectedTarget].Handle) and PED.IS_PED_IN_VEHICLE(Targets[SelectedTarget].Handle, Veh, true) then
						TargetDied = true
					end
				end
			else
				if TargetsState == 1 then
					TargetsState = 0
					ScanPeds = true
				end
			end
			if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 85) then
				SelectedTarget = SelectedTarget + 1
				if SelectedTarget > #Targets then
					SelectedTarget = 1
				end
			end
			if TargetDied then
				local ClosestDist = 10000.0
				local ClosestHandle = 0
				local PlayerPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
				for i = 1, #Targets do
					local PedCoords = ENTITY.GET_ENTITY_COORDS(Targets[i].Handle)
					local Distance = MISC.GET_DISTANCE_BETWEEN_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z, PedCoords.x, PedCoords.y, PedCoords.z, true)
					Targets[i].Distance = Distance
					if Targets[i].Distance < ClosestDist then
						ClosestDist = Targets[i].Distance
						ClosestHandle = Targets[i].Handle
						SelectedTarget = i
					end
				end
				TargetDied = false
			end
			if Veh ~= 0 then
				if VehsWithTurret[Veh] == nil then
					if PED.IS_PED_IN_VEHICLE(PlayerPed, Veh, false) then
						LastVeh = Veh
						if not STREAMING.HAS_MODEL_LOADED(TurretModel) then
							STREAMING.REQUEST_MODEL(TurretModel)
						end
						if STREAMING.HAS_MODEL_LOADED(TurretModel) then
							local VehModel = ENTITY.GET_ENTITY_MODEL(Veh)
							local Min, Max = v3.new(), v3.new()
							MISC.GET_MODEL_DIMENSIONS(VehModel, Min, Max)
							local VPos = ENTITY.GET_ENTITY_COORDS(Veh)
							local Turret = OBJECT.CREATE_OBJECT(TurretModel, VPos.x, VPos.y, VPos.z + Max.z, true, true, true)
							DECORATOR.DECOR_SET_INT(Turret, "Casino_Game_Info_Decorator", 31)
							ENTITY.SET_ENTITY_AS_MISSION_ENTITY(Turret, false, true)
							local NetID = NETWORK.OBJ_TO_NET(Turret)
							if NetID ~= 0 then
								NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PLAYER.PLAYER_ID(), true)
							end
							ENTITY.SET_ENTITY_HAS_GRAVITY(Turret, false)
							if SetTurretPropInvisible then
								ENTITY.SET_ENTITY_ALPHA(Turret, 0, false)
							end
							local OffsetY = 0.0
							local OffsetZ = Max.z - 0.5
							local IsPlane = VEHICLE.IS_THIS_MODEL_A_PLANE(VehModel)
							local IsHeli = VEHICLE.IS_THIS_MODEL_A_HELI(VehModel)
							if IsHeli then
								OffsetZ = 0.0
								OffsetY = Max.y - 3.0
							end
							if VEHICLE.IS_THIS_MODEL_A_BICYCLE(VehModel) or VEHICLE.IS_THIS_MODEL_A_BIKE(VehModel) then
								OffsetZ = 0.0
								OffsetY = Max.y
							end
							if IsPlane then
								OffsetZ = -0.5
								OffsetY = Max.y - 0.5
							end
							IsAircraft = IsPlane or IsHeli
							--ENTITY.ATTACH_ENTITY_TO_ENTITY_PHYSICALLY(Turret, Veh, 0, 0, 0.0, OffsetY * 2, OffsetZ * 2, 0.0, 0.0, 0.0, 0.0, 0.0, 180.0, -1.0, false, true, false, true, 2)
							ENTITY.ATTACH_ENTITY_TO_ENTITY(Turret, Veh, 0, 0.0, OffsetY, OffsetZ, 0.0, 0.0, 180.0, true, false, true, false, 2, true, true)
							STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(TurretModel)
							VehsWithTurret[Veh] = {Turret = Turret, OffsetY = OffsetY, OffsetZ = OffsetZ}
						end
					end
				end
				if VehsWithTurret[Veh] ~= nil then
					if SetTurretPropInvisible then
						ENTITY.SET_ENTITY_ALPHA(VehsWithTurret[Veh].Turret, 0, false)
					end
					local CamRot = CAM.GET_GAMEPLAY_CAM_ROT(2)
					local FVect, RVect, UpVect, Vect = v3.new(), v3.new(), v3.new(), v3.new()
					ENTITY.GET_ENTITY_MATRIX(VehsWithTurret[Veh].Turret, FVect, RVect, UpVect, Vect)
					local EntSpeed = ENTITY.GET_ENTITY_SPEED_VECTOR(Veh, false)
					local AdjustedX = Vect.x - ((FVect.x * 0.6) - (UpVect.x * 0.561) + (RVect.x * 0.0002)) + EntSpeed.x * 0.035
					local AdjustedY = Vect.y - ((FVect.y * 0.6) - (UpVect.y * 0.561) + (RVect.y * 0.0002)) + EntSpeed.y * 0.035
					local AdjustedZ = Vect.z - ((FVect.z * 0.6) - (UpVect.z * 0.561) + (RVect.z * 0.0002)) + EntSpeed.z * 0.035
					local Pos = v3.new(AdjustedX, AdjustedY, AdjustedZ)
					local RotToDir = v3.toDir(CamRot)
					local AdjustedVect = {x = Pos.x + RotToDir.x * 1000.0, y = Pos.y + RotToDir.y * 1000.0, z = Pos.z + RotToDir.z * 1000.0}
					if #Targets == 0 then
						local ScreenEndCoords = ShapeTestNav(Veh, Pos, AdjustedVect)
						local ScreenX, ScreenY = memory.alloc(8), memory.alloc(8)
						if GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(ScreenEndCoords.x, ScreenEndCoords.y, ScreenEndCoords.z, ScreenX, ScreenY) then
							if GRAPHICS.HAS_STREAMED_TEXTURE_DICT_LOADED("helicopterhud") then
								GRAPHICS.DRAW_SPRITE("helicopterhud", "hud_target", memory.read_float(ScreenX), memory.read_float(ScreenY), 0.025, 0.050, 0.0, 255, 255, 255, 200, false, false)
							end
						end
						GRAPHICS.DRAW_LIGHT_WITH_RANGE(ScreenEndCoords.x, ScreenEndCoords.y, ScreenEndCoords.z, 255, 0, 0, 0.5, 555.0)
						local EntRot = ENTITY.GET_ENTITY_ROTATION(Veh, 0)
						local AdjustedZRot = (CamRot.z + 180.0) - EntRot.z
						ENTITY.ATTACH_ENTITY_TO_ENTITY(VehsWithTurret[Veh].Turret, Veh, 0, 0.0, VehsWithTurret[Veh].OffsetY, VehsWithTurret[Veh].OffsetZ, 0.0, 0.0, AdjustedZRot, true, false, true, false, 2, true, true)
					else
						if Targets[SelectedTarget] ~= nil then
							local PedCoords = ENTITY.GET_ENTITY_COORDS(Targets[SelectedTarget].Handle)
							local ScreenEndCoords = ShapeTestNav(Veh, Pos, PedCoords)
							GRAPHICS.DRAW_LIGHT_WITH_RANGE(ScreenEndCoords.x, ScreenEndCoords.y, ScreenEndCoords.z, 255, 0, 0, 0.5, 555.0)
							local EntRot = ENTITY.GET_ENTITY_ROTATION(Veh, 0)
							local NewVect = v3.new(Pos)
							local NewVect2 = v3.new(ScreenEndCoords)
							local NewSub = v3.sub(NewVect, NewVect2)
							local ToRot = v3.toRot(NewSub)
							local AdjustedZRot = (ToRot.z) - EntRot.z
							ENTITY.ATTACH_ENTITY_TO_ENTITY(VehsWithTurret[Veh].Turret, Veh, 0, 0.0, VehsWithTurret[Veh].OffsetY, VehsWithTurret[Veh].OffsetZ, 0.0, 0.0, AdjustedZRot, true, false, true, false, 2, true, true)
						end
					end
					local Pressed = false
					if not IsAircraft then
						Pressed = PAD.IS_CONTROL_PRESSED(0, 76) or PAD.IS_CONTROL_PRESSED(0, 69)
					else
						Pressed = PAD.IS_CONTROL_PRESSED(0, 70)
					end
					if Shooted <= 0 then
						if PED.IS_PED_IN_VEHICLE(PlayerPed, Veh, false) and ENTITY.DOES_ENTITY_EXIST(LastVeh) and not ENTITY.IS_ENTITY_DEAD(Veh) then
							if Pressed then
								local EndCoords = nil
								if #Targets > 0 then
									if Targets[SelectedTarget] ~= nil then
										local BoneCount = ENTITY.GET_ENTITY_BONE_COUNT(Targets[SelectedTarget].Handle)
										EndCoords = ENTITY.GET_ENTITY_BONE_POSTION(Targets[SelectedTarget].Handle, math.random(0, BoneCount-1))--ENTITY.GET_ENTITY_COORDS(Targets[SelectedTarget].Handle)
									else
										EndCoords, DidHit = ShapeTestNav(Veh, Pos, AdjustedVect)
									end
								else
									EndCoords, DidHit = ShapeTestNav(Veh, Pos, AdjustedVect)
								end
								local NewPos = v3.new(EndCoords)
								local Sub = v3.sub(NewPos, Pos)
								local Rot = v3.toRot(Sub)
								GRAPHICS.USE_PARTICLE_FX_ASSET(PTFXAsset)
								GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(PTFXName, Pos.x, Pos.y, Pos.z, Rot.x - 90.0, Rot.y, Rot.z, 1.0, false, false, false, true)
								--local EntRot = ENTITY.GET_ENTITY_ROTATION(VehsWithTurret, 2)
								GRAPHICS.USE_PARTICLE_FX_ASSET("core")
								GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("muz_assault_rifle", Pos.x, Pos.y, Pos.z, Rot.x, Rot.y, Rot.z - 90.0, 1.0, false, false, false, false)
								MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(Pos.x, Pos.y, Pos.z, EndCoords.x, EndCoords.y, EndCoords.z, 200, false, joaat("weapon_navyrevolver"), PlayerPed, false--[[VFX]], true, -1.0, Veh, 0)
								--MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(Pos.x, Pos.y, Pos.z, EndCoords.x, EndCoords.y, EndCoords.z, 200, false, joaat("weapon_raycarbine"), PlayerPed, true--[[VFX]], true, -1.0, Veh, 0)
								--GRAPHICS.USE_PARTICLE_FX_ASSET("core")
								--GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("bullet_tracer_railgun", Pos.x, Pos.y, Pos.z, Rot.x - 90.0, Rot.y, Rot.z, 1.0, false, false, false, false)
								--GRAPHICS.USE_PARTICLE_FX_ASSET("weap_xs_weapons")
								--GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("bullet_tracer_xs_sr", Pos.x, Pos.y, Pos.z, Rot.x - 90.0, Rot.y, Rot.z, 1.0, false, false, false, true)
								--GRAPHICS.USE_PARTICLE_FX_ASSET("core")
								--GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("bullet_tracer_jet", Pos.x, Pos.y, Pos.z, Rot.x - 90.0, Rot.y, Rot.z, 1.0, false, false, false, false)
								Shooted = 4
							end
						else
							if RequestControlOfEntity(VehsWithTurret[Veh].Turret) then
								local NetID = NETWORK.OBJ_TO_NET(VehsWithTurret[Veh].Turret)
								if NetID ~= 0 then
									NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PLAYER.PLAYER_ID(), false)
								end
								entities.delete_by_handle(VehsWithTurret[Veh].Turret)
								VehsWithTurret[Veh] = nil
							end
						end
					else
						Shooted = Shooted - 1
					end
				end
			else
				if VehsWithTurret[LastVeh] ~= nil then
					if RequestControlOfEntity(VehsWithTurret[LastVeh]) then
						local NetID = NETWORK.OBJ_TO_NET(VehsWithTurret[LastVeh])
						if NetID ~= 0 then
							NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PLAYER.PLAYER_ID(), false)
						end
						entities.delete_by_handle(VehsWithTurret[LastVeh])
						VehsWithTurret[LastVeh] = nil
						LastVeh = 0
					end
				end
			end
			Wait()
		end
	end
end)

local BulletTracer = false
menu.toggle(MiscMenu, "Bullet Tracer", {}, "", function(toggle)
	BulletTracer = toggle
	if BulletTracer then
		local PTFXAsset = "weap_gr_weapons"
		local PTFXName = "bullet_tracer_gr_tintable"
		STREAMING.REQUEST_NAMED_PTFX_ASSET(PTFXAsset)
		while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(PTFXAsset) do
			Wait()
		end
		while BulletTracer do
			while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(PTFXAsset) do
				STREAMING.REQUEST_NAMED_PTFX_ASSET(PTFXAsset)
				Wait()
			end
			for index, peds in pairs(entities.get_all_peds_as_handles()) do
				if PED.IS_PED_SHOOTING(peds) then
					local Weap = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(peds, 0)
					if Weap ~= 0 then
						local PPos = ENTITY.GET_ENTITY_COORDS(peds)
						STREAMING.REQUEST_COLLISION_AT_COORD(PPos.x, PPos.y, PPos.z)
						local BoneID = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(Weap, "gun_muzzle")
						if BoneID ~= 0 then
							local HitV3 = v3.new()
							local Bool = WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(peds, HitV3)
							if Bool then
								local Pos = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(Weap, BoneID)
								local Rot = v3.lookAt(Pos, HitV3)
								util.create_thread(function()
									for i = 1, 1 do
										GRAPHICS.USE_PARTICLE_FX_ASSET(PTFXAsset)
										GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(PTFXName, Pos.x, Pos.y, Pos.z, Rot.y, Rot.x - 90.0, Rot.z - 90.0, 1.0, false, false, false, false)
									end
								end)
							end
						end
					end
				end
			end
			Wait()
		end
	end
end)

local BulletTracer2 = false
menu.toggle(MiscMenu, "Bullet Tracer Laser", {}, "", function(toggle)
	BulletTracer2 = toggle
	local PTFXAsset = "weap_ch_vehicle_weapons"
	local PTFXName = "bullet_tracer_ch_tank_laser"
	if BulletTracer2 then
		STREAMING.REQUEST_NAMED_PTFX_ASSET(PTFXAsset)
		while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(PTFXAsset) do
			Wait()
		end
		while BulletTracer2 do
			for index, peds in pairs(entities.get_all_peds_as_handles()) do
				if PED.IS_PED_SHOOTING(peds) then
					local Weap = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(peds, 0)
					if Weap ~= 0 then
						local PPos = ENTITY.GET_ENTITY_COORDS(peds)
						STREAMING.REQUEST_COLLISION_AT_COORD(PPos.x, PPos.y, PPos.z)
						local BoneID = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(Weap, "gun_muzzle")
						if BoneID ~= 0 then
							local HitV3 = v3.new()
							local Bool = WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(peds, HitV3)
							if Bool then
								local Pos = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(Weap, BoneID)
								local Rot = v3.lookAt(Pos, HitV3)
								util.create_thread(function()
									for i = 0, 0 do
										GRAPHICS.USE_PARTICLE_FX_ASSET(PTFXAsset)
										GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(PTFXName, Pos.x, Pos.y, Pos.z, Rot.y, Rot.x - 90.0, Rot.z - 90.0, 1.0, false, false, false, false)
									end
								end)
							end
						end
					end
				end
			end
			Wait()
		end
	end
end)

local BulletTracerOverride = false
menu.toggle(MiscMenu, "Bullet Tracer Override", {}, "Railgun tracer.", function(toggle)
	BulletTracerOverride = toggle
	local OldAssetNames = {"bullet_tracer", "bullet_tracer_jet", "bullet_tracer_mg", "bullet_shotgun_tracer"}
	local NewAssetName = "bullet_tracer_gr_tintable"
	if not BulletTracerOverride then
		for i = 1, #OldAssetNames do
			GRAPHICS.RESET_PARTICLE_FX_OVERRIDE(OldAssetNames[i])
		end
	end
	local PTFXAsset = "weap_gr_weapons"
    local PTFXName = "bullet_tracer_gr_tintable"
    STREAMING.REQUEST_NAMED_PTFX_ASSET(PTFXAsset)
    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(PTFXAsset) do
        Wait()
    end
	while BulletTracerOverride do
		for i = 1, #OldAssetNames do
			GRAPHICS.SET_PARTICLE_FX_OVERRIDE(OldAssetNames[i], NewAssetName)
		end
		Wait(10000)
	end
end, BulletTracerOverride)

local BulletTracerLaserOverride = false
menu.toggle(MiscMenu, "Bullet Tracer Laser Override", {}, "Railgun tracer.", function(toggle)
	BulletTracerLaserOverride = toggle
	local OldAssetNames = {"bullet_tracer", "bullet_tracer_jet", "bullet_tracer_mg", "bullet_shotgun_tracer"}
	local NewAssetName = "bullet_tracer_ch_tank_laser"
	local PTFXAsset = "weap_ch_vehicle_weapons"
	if not BulletTracerLaserOverride then
		for i = 1, #OldAssetNames do
			GRAPHICS.RESET_PARTICLE_FX_OVERRIDE(OldAssetNames[i])
		end
	end
	while BulletTracerLaserOverride do
		if not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(PTFXAsset) then
			STREAMING.REQUEST_NAMED_PTFX_ASSET(PTFXAsset)
			while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(PTFXAsset) do
				Wait()
			end
		end
		for i = 1, #OldAssetNames do
			GRAPHICS.SET_PARTICLE_FX_OVERRIDE(OldAssetNames[i], NewAssetName)
		end
		Wait(10000)
	end
end, BulletTracerLaserOverride)

menu.toggle(MiscMenu, "Armored Vehicle 1", {}, "", function(toggle)
	ArmoredVehicle = toggle
	if not ArmoredVehicle then
		for i = 1, #ArmoredVehsT do
			entities.delete_by_handle(ArmoredVehsT[#ArmoredVehsT].Handle)
			table.remove(ArmoredVehsT, #ArmoredVehsT)
		end
	end
	if ArmoredVehicle then
		local HasPlaced = false
		local ArmoredModel = joaat("technical")
		local OffsetZ = 0.0
		while ArmoredVehicle do
			local PlayerPed = PLAYER.PLAYER_PED_ID()
			local Div = 0
			local Ent = PlayerPed
			if PED.IS_PED_IN_ANY_VEHICLE(PlayerPed, true) then
				local Veh = PED.GET_VEHICLE_PED_IS_IN(PlayerPed, true)
				if Veh ~= 0 then
					Ent = Veh
					OffsetZ = 0.0
					Div = 2
				end
			else
				OffsetZ = -1.5
				Div = 4
			end
			if not HasPlaced then
				if not STREAMING.HAS_MODEL_LOADED(ArmoredModel) then
					STREAMING.REQUEST_MODEL(ArmoredModel)
				end
				if STREAMING.HAS_MODEL_LOADED(ArmoredModel) then
					local Pos = ENTITY.GET_ENTITY_COORDS(Ent)
					local NewVeh = VEHICLE.CREATE_VEHICLE(ArmoredModel, Pos.x, Pos.y, Pos.z + 10.0, ENTITY.GET_ENTITY_HEADING(Ent), true, true, false)
					local NewVeh2 = VEHICLE.CREATE_VEHICLE(ArmoredModel, Pos.x, Pos.y, Pos.z + 10.0, ENTITY.GET_ENTITY_HEADING(Ent), true, true, false)
					local NewVeh3 = VEHICLE.CREATE_VEHICLE(ArmoredModel, Pos.x, Pos.y, Pos.z + 10.0, ENTITY.GET_ENTITY_HEADING(Ent), true, true, false)
					local NewVeh4 = VEHICLE.CREATE_VEHICLE(ArmoredModel, Pos.x, Pos.y, Pos.z + 10.0, ENTITY.GET_ENTITY_HEADING(Ent), true, true, false)
					local NewVeh5 = VEHICLE.CREATE_VEHICLE(ArmoredModel, Pos.x, Pos.y, Pos.z + 10.0, ENTITY.GET_ENTITY_HEADING(Ent), true, true, false)
					local NewVeh6 = VEHICLE.CREATE_VEHICLE(ArmoredModel, Pos.x, Pos.y, Pos.z + 10.0, ENTITY.GET_ENTITY_HEADING(Ent), true, true, false)
					local NewVeh7 = VEHICLE.CREATE_VEHICLE(ArmoredModel, Pos.x, Pos.y, Pos.z + 10.0, ENTITY.GET_ENTITY_HEADING(Ent), true, true, false)
					ArmoredVehsT[#ArmoredVehsT+1] = {Handle = NewVeh, OffsetX = -3.0}
					ArmoredVehsT[#ArmoredVehsT+1] = {Handle = NewVeh2, OffsetX = -2.0}
					ArmoredVehsT[#ArmoredVehsT+1] = {Handle = NewVeh3, OffsetX = -1.0}
					ArmoredVehsT[#ArmoredVehsT+1] = {Handle = NewVeh4, OffsetX = 0.0}
					ArmoredVehsT[#ArmoredVehsT+1] = {Handle = NewVeh5, OffsetX = 1.0}
					ArmoredVehsT[#ArmoredVehsT+1] = {Handle = NewVeh6, OffsetX = 2.0}
					ArmoredVehsT[#ArmoredVehsT+1] = {Handle = NewVeh7, OffsetX = 3.0}
					HasPlaced = true
					STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ArmoredModel)
				end
			end
			
			for i = 1, #ArmoredVehsT do
				if RequestControlOfEntity(ArmoredVehsT[i].Handle) then
					entities.set_can_migrate(ArmoredVehsT[i].Handle, false)
					ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION(ArmoredVehsT[i].Handle, false, false)
					ENTITY.SET_ENTITY_HAS_GRAVITY(ArmoredVehsT[i].Handle, false)
					ENTITY.SET_ENTITY_INVINCIBLE(ArmoredVehsT[i].Handle, true)
					local Pos = ENTITY.GET_ENTITY_COORDS(ArmoredVehsT[i].Handle)
					local FVect, RVect, UpVect, Vect = v3.new(), v3.new(), v3.new(), v3.new()
					ENTITY.GET_ENTITY_MATRIX(Ent, FVect, RVect, UpVect, Vect)
					local VehRot = ENTITY.GET_ENTITY_ROTATION(Ent, 2)
					local AdjustedVect = {
						x = ((Vect.x + ((FVect.x * 0.0) + (RVect.x * ArmoredVehsT[i].OffsetX / Div) + (UpVect.x * OffsetZ))) - Pos.x) * 10.0,
						y = ((Vect.y + ((FVect.y * 0.0) + (RVect.y * ArmoredVehsT[i].OffsetX / Div) + (UpVect.y * OffsetZ))) - Pos.y) * 10.0,
						z = ((Vect.z + ((FVect.z * 0.0) + (RVect.z * ArmoredVehsT[i].OffsetX / Div) + (UpVect.z * OffsetZ))) - Pos.z) * 10.0
					}
					ENTITY.SET_ENTITY_ROTATION(ArmoredVehsT[i].Handle, VehRot.x, VehRot.y, VehRot.z, 2)
					ENTITY.SET_ENTITY_VELOCITY(ArmoredVehsT[i].Handle, AdjustedVect.x, AdjustedVect.y, AdjustedVect.z)

				end
			end
			Wait()
		end
	end
end)

menu.toggle_loop(MiscMenu, "Set Can Damage Every Ped", {}, "", function(toggle)
	for index, peds in pairs(entities.get_all_peds_as_handles()) do
		if not PED.IS_PED_A_PLAYER(peds) then
			if peds ~= PLAYER.PLAYER_PED_ID() then
				if RequestControlOfEntity(peds) then
					ENTITY.SET_ENTITY_ONLY_DAMAGED_BY_PLAYER(peds, false)
					ENTITY.SET_ENTITY_CAN_ONLY_BE_DAMAGED_BY_SCRIPT_PARTICIPANTS(peds, false)
					ENTITY.SET_ENTITY_INVINCIBLE(peds, false)
					ENTITY.SET_ENTITY_CAN_BE_DAMAGED(peds, true)
					ENTITY.SET_ENTITY_PROOFS(peds, false, false, false, false, false, false, false, false)
					ENTITY.FREEZE_ENTITY_POSITION(peds, false)
					PED.SET_RAGDOLL_BLOCKING_FLAGS(peds, 0)
					PED.SET_PED_CAN_RAGDOLL(peds, true)
					PED.SET_PED_CONFIG_FLAG(peds, 318, true)
					--PED.SET_PED_CAN_RAGDOLL_FROM_PLAYER_IMPACT(peds, true)
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
					--PED.SET_PED_COMBAT_ATTRIBUTES(peds, 5, true)
					--PED.SET_PED_COMBAT_ATTRIBUTES(peds, 46, true)
				end
			end
		end
	end
end)

menu.toggle_loop(MiscMenu, "Desconceal All Ents", {}, "", function(toggle)
	for index, peds in pairs(entities.get_all_peds_as_handles()) do
		if not PED.IS_PED_A_PLAYER(peds) then
			if peds ~= PLAYER.PLAYER_PED_ID() then
				if not PED.IS_PED_A_PLAYER(peds) then
					if RequestControlOfEntity(peds) then
						NETWORK.NETWORK_CONCEAL_ENTITY(peds, false)
						NETWORK.NETWORK_SET_ENTITY_ONLY_EXISTS_FOR_PARTICIPANTS(peds, false)
					end
				end
			end
		end
	end
	for index, vehs in pairs(entities.get_all_vehicles_as_handles()) do
		--if RequestControlOfEntity(peds) then
			NETWORK.NETWORK_CONCEAL_ENTITY(vehs, false)
			NETWORK.NETWORK_SET_ENTITY_ONLY_EXISTS_FOR_PARTICIPANTS(vehs, false)
		--end
	end
	for index, objs in pairs(entities.get_all_objects_as_handles()) do
		--if RequestControlOfEntity(peds) then
			NETWORK.NETWORK_CONCEAL_ENTITY(objs, false)
			NETWORK.NETWORK_SET_ENTITY_ONLY_EXISTS_FOR_PARTICIPANTS(objs, false)
		--end
	end
	for index, pickups in pairs(entities.get_all_pickups_as_handles()) do
		--if RequestControlOfEntity(peds) then
			NETWORK.NETWORK_CONCEAL_ENTITY(pickups, false)
			NETWORK.NETWORK_SET_ENTITY_ONLY_EXISTS_FOR_PARTICIPANTS(pickups, false)
		--end
	end
	NETWORK.NETWORK_END_TUTORIAL_SESSION()
end)

menu.toggle_loop(MiscMenu, "Freedom", {}, "", function(toggle)
	local PlayerPed = PLAYER.PLAYER_PED_ID()
	local PlayerID = PLAYER.PLAYER_ID()
	PED.SET_PED_CONFIG_FLAG(PlayerPed, 101, false)
	PED.SET_PED_CONFIG_FLAG(PlayerPed, 122, false)
	PLAYER.SET_DISABLE_AMBIENT_MELEE_MOVE(PlayerID, false)
end)

local AlertMode_Num = SplitGlobals("Local_21434")
local AlertMode2_Num = SplitGlobals("Local_50527")
local AlertMode3_Num = SplitGlobals("Local_35078")
local AlertMode4_Nums = {
	SplitGlobals("Local_32915"),
	SplitGlobals("Local_33347"),
	SplitGlobals("Local_33351"),
	SplitGlobals("Local_35122"),
	SplitGlobals("Local_35160"),
	SplitGlobals("Local_35164"),
	SplitGlobals("Local_35180"),
	SplitGlobals("Local_35196"),
	SplitGlobals("Local_35204"),
	SplitGlobals("Local_35216"),
	SplitGlobals("Local_50524"),
	SplitGlobals("Local_50528"),
	SplitGlobals("Local_50556"),
	SplitGlobals("Local_50879")
}
menu.toggle_loop(MiscMenu, "Set Maintain Stealth", {}, "", function(toggle)
	for index, peds in pairs(entities.get_all_peds_as_handles()) do
		if not PED.IS_PED_A_PLAYER(peds) then
			if peds ~= PLAYER.PLAYER_PED_ID() then
				if RequestControlOfEntity(peds) then
					entities.set_can_migrate(peds, false)
					TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, true)
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, true)
					PED.SET_PED_ALERTNESS(peds, 0)
					TASK.CLEAR_PED_TASKS(peds)
					PED.SET_PED_RESET_FLAG(peds, 180, true)
				end
			end
		end
	end
	local Addr = memory.script_local("fm_mission_controller", AlertMode_Num)
	if Addr ~= 0 then
		if PLAYER.IS_PLAYER_CONTROL_ON(PLAYER.PLAYER_ID()) then
			util.spoof_script("fm_mission_controller", function()
				NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
				if NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
					NETWORK.NETWORK_PREVENT_SCRIPT_HOST_MIGRATION()
				end
			end)
		end
		memory.write_int(Addr, 0)
	end
	local Addr2 = memory.script_local("fm_mission_controller_2020", AlertMode2_Num)
	if Addr2 ~= 0 then
		if PLAYER.IS_PLAYER_CONTROL_ON(PLAYER.PLAYER_ID()) then
			util.spoof_script("fm_mission_controller_2020", function()
				NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
				if NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
					NETWORK.NETWORK_PREVENT_SCRIPT_HOST_MIGRATION()
				end
			end)
		end
		memory.write_int(Addr2, 0)
		memory.write_int(Addr2+8, 0)
		memory.write_int(Addr2+16, 0)
		for i = 0, 79 do
			local Addr3 = memory.script_local("fm_mission_controller_2020", AlertMode3_Num+i)
			memory.write_int(Addr3, 0)
		end
		for i = 1, #AlertMode4_Nums do
			local Addr4 = memory.script_local("fm_mission_controller_2020", AlertMode4_Nums[i])
			memory.write_int(Addr4, 0)
		end
	end
end)

local CargoPlane = 0
local CargoPlaneBlend = false
menu.toggle(MiscMenu, "Veh Blend", {}, "", function(toggle)
	CargoPlaneBlend = toggle
	if not CargoPlaneBlend then
		while not RequestControlOfEntity(CargoPlane) do
			Wait()
		end
		entities.delete_by_handle(CargoPlane)
	end
	if CargoPlaneBlend then
		local ModelName = joaat("cargoplane")
		STREAMING.REQUEST_MODEL(ModelName)
		while not STREAMING.HAS_MODEL_LOADED(ModelName) do
			Wait()
		end
		local Pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
		CargoPlane =  VEHICLE.CREATE_VEHICLE(ModelName, Pos.x, Pos.y, Pos.z, ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID()), true, true, false)
		PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), CargoPlane, -1)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ModelName)
		ENTITY.SET_ENTITY_AS_MISSION_ENTITY(CargoPlane, false, true)
		NETWORK.NETWORK_SET_ENTITY_CAN_BLEND(CargoPlane, true)
		ENTITY.SET_ENTITY_INVINCIBLE(CargoPlane, true)
		VEHICLE.SET_DOOR_ALLOWED_TO_BE_BROKEN_OFF(CargoPlane, 2, false)
		NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NETWORK.VEH_TO_NET(CargoPlane), true, PLAYER.PLAYER_ID())
		entities.set_can_migrate(CargoPlane, false)
		NETWORK.NETWORK_ENABLE_EXTRA_VEHICLE_ORIENTATION_BLEND_CHECKS(NETWORK.VEH_TO_NET(CargoPlane), true)
		while CargoPlaneBlend do
			VEHICLE.SET_VEHICLE_DOOR_CONTROL(CargoPlane, 2, 360, 180.0)
			--NETWORK.NETWORK_USE_LOGARITHMIC_BLENDING_THIS_FRAME(CargoPlane)
			Wait()
		end
	end
end)

function SetMissionEntitiesCanTakeDamage()
	local PedsGlobal = SplitGlobals("Global_4980736.f_121122[bVar3 /*1198*/].f_555")
	local PedsGlobal2 = SplitGlobals("Global_4980736.f_121122[bVar3 /*1198*/].f_564")
	for i = 0, 79 do
		local Address = memory.script_global(PedsGlobal + 1180 * i)
		if is_bit_set(memory.read_int(Address), 30) then
			memory.write_int(Address, clear_bit(memory.read_int(Address), 30))
		end
		local Address2 = memory.script_global(PedsGlobal2 + 1180 * i)
		if is_bit_set(memory.read_int(Address2), 21) then
			memory.write_int(Address2, clear_bit(memory.read_int(Address), 21))
		end
	end
end

util.create_tick_handler(function()
	return true
end)

local MoreCopsOnly = false
menu.toggle(menu.my_root(), "More Cops Only", {}, "Only.", function(toggle)
	MoreCopsOnly = toggle
	if MoreCopsOnly then
		local TrackedPeds = {}
		local TrackedVehs = {}
		local VehsT = {}
		while MoreCopsOnly do
			for index, peds in pairs(entities.get_all_peds_as_handles()) do
				if not PED.IS_PED_A_PLAYER(peds) then
					if IsWithCopRel(peds) then
						if not ENTITY.IS_ENTITY_A_MISSION_ENTITY(peds) then
							ENTITY.SET_ENTITY_AS_MISSION_ENTITY(peds, false, true)
							local NetID = NETWORK.PED_TO_NET(peds)
							if NetID ~= 0 then
								NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PLAYER.PLAYER_ID(), false)
							end
							TrackedPeds[#TrackedPeds+1] = peds
							local VehHandle = PED.GET_VEHICLE_PED_IS_IN(peds, false)
							if VehHandle ~= 0 then
								if VehsT[VehHandle] == nil then
									VehsT[VehHandle] = 0
									TrackedVehs[#TrackedVehs+1] = VehHandle
								end
							end
						end
					end
				end
			end
			for i = 1, #TrackedPeds do
				if TrackedPeds[i] ~= nil then
					if ENTITY.DOES_ENTITY_EXIST(TrackedPeds[i]) then
						if ENTITY.IS_ENTITY_DEAD(TrackedPeds[i]) then
							if RequestControlOfEntity(TrackedPeds[i]) then
								set_entity_as_no_longer_needed(TrackedPeds[i])
								table.remove(TrackedPeds, i)
								break
							end
						end
					else
						table.remove(TrackedPeds, i)
						break
					end
				end
			end
			Wait()
		end
		for i = 1, #TrackedPeds do
			entities.delete_by_handle(TrackedPeds[i])
		end
	end
end)

---@param ped Ped
---@param maxPeds? integer
---@param ignore? integer
---@return Entity[]
function get_ped_nearby_peds(ped, maxPeds, ignore)
	maxPeds = maxPeds or 16
	local pEntityList = memory.alloc((maxPeds + 1) * 8)
	memory.write_int(pEntityList, maxPeds)
	local pedsList = {}
	for i = 1, PED.GET_PED_NEARBY_PEDS(ped, pEntityList, ignore or -1), 1 do
		pedsList[i] = memory.read_int(pEntityList + i*8)
	end
	return pedsList
end

function GetPedNearestTarget(Ped, IgnoreInVeh)
	local PedPos = ENTITY.GET_ENTITY_COORDS(Ped)
	local Dist = 1000.0
	local PedRel = PED.GET_PED_RELATIONSHIP_GROUP_HASH(Ped)
	local Peds = get_ped_nearby_peds(Ped, 80, -1)
	local ClosestPed = 0
	local CheckInVeh = false
	if IgnoreInVeh ~= nil then
		CheckInVeh = IgnoreInVeh
	end
	for index, peds in pairs(Peds) do
		if not ENTITY.IS_ENTITY_DEAD(peds) then
			if not PED.IS_PED_DEAD_OR_DYING(peds, true) then
				if not DECORATOR.DECOR_EXIST_ON(peds, "Casino_Game_Info_Decorator") then
					local TargetRelHash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(peds)
					if PED.GET_RELATIONSHIP_BETWEEN_GROUPS(PedRel, TargetRelHash) ~= 1 then
						local PedCoords = ENTITY.GET_ENTITY_COORDS(peds)
						local Distance = DistanceBetween(PedPos.x, PedPos.y, PedPos.z, PedCoords.x, PedCoords.y, PedCoords.z)
						if Distance < Dist then
							if not CheckInVeh then
								ClosestPed = peds
								Dist = Distance
							else
								if not PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
									ClosestPed = peds
									Dist = Distance
								end
							end
						end
					end
				end
			end
		end
	end
	return ClosestPed
end

function GetAllPedNearestTarget(Ped, IgnoreInVeh, IncludePlayers, PlayersOnly, IncludeFriends, Relationships)
	local PedPos = ENTITY.GET_ENTITY_COORDS(Ped)
	local Dist = 1000.0
	local PedRel = PED.GET_PED_RELATIONSHIP_GROUP_HASH(Ped)
	local Peds = entities.get_all_peds_as_handles()
	local ClosestPed = 0
	local CheckInVeh = false
	if IgnoreInVeh ~= nil then
		CheckInVeh = IgnoreInVeh
	end
	local CheckIsInScreen = true
	for index, peds in pairs(Peds) do
		if peds ~= Ped then
			if not ENTITY.IS_ENTITY_DEAD(peds) then
				if not PED.IS_PED_DEAD_OR_DYING(peds, true) then
					local CanPass2 = true
					local IsAPlayer = PED.IS_PED_A_PLAYER(peds)
					if PlayersOnly then
						CanPass2 = IsAPlayer
					end
					if CanPass2 then
						if not DECORATOR.DECOR_EXIST_ON(peds, "Casino_Game_Info_Decorator") then
							local TargetRelHash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(peds)
							local RelType = PED.GET_RELATIONSHIP_BETWEEN_GROUPS(PedRel, TargetRelHash)
							local CanPass = true
							for i = 1, #Relationships do
								if RelType == Relationships[i] then
									CanPass = false
									break
								end
							end
							if CanPass then
								local PedCoords = ENTITY.GET_ENTITY_COORDS(peds)
								local Distance = DistanceBetween(PedPos.x, PedPos.y, PedPos.z, PedCoords.x, PedCoords.y, PedCoords.z)
								local CanInsert = true
								if Distance < Dist then
									if not CheckInVeh then
										if CheckIsInScreen then
											if ENTITY.IS_ENTITY_ON_SCREEN(peds) then
												if not IncludePlayers then
													if IsAPlayer then
														CanInsert = false
													end
												else
													if IsAPlayer then
														if not IncludeFriends then
															local Player = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(peds)
															local Handle = memory.alloc(13*8)
															NETWORK.NETWORK_HANDLE_FROM_PLAYER(Player, Handle, 13)
															CanInsert = not NETWORK.NETWORK_IS_FRIEND(Handle)
														end
													end
												end
												if CanInsert then
													ClosestPed = peds
													Dist = Distance
												end
											end
										else
											if not IncludePlayers then
												if IsAPlayer then
													CanInsert = false
												end
											else
												if IsAPlayer then
													if not IncludeFriends then
														local Player = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(peds)
														local Handle = memory.alloc(13*8)
														NETWORK.NETWORK_HANDLE_FROM_PLAYER(Player, Handle, 13)
														CanInsert = not NETWORK.NETWORK_IS_FRIEND(Handle)
													end
												end
											end
											if CanInsert then
												ClosestPed = peds
												Dist = Distance
											end
										end
									else
										if not PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
											if CheckIsInScreen then
												if ENTITY.IS_ENTITY_ON_SCREEN(peds) then
													if not IncludePlayers then
														if IsAPlayer then
															CanInsert = false
														end
													else
														if IsAPlayer then
															if not IncludeFriends then
																local Player = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(peds)
																local Handle = memory.alloc(13*8)
																NETWORK.NETWORK_HANDLE_FROM_PLAYER(Player, Handle, 13)
																CanInsert = not NETWORK.NETWORK_IS_FRIEND(Handle)
															end
														end
													end
													if CanInsert then
														ClosestPed = peds
														Dist = Distance
													end
												end
											else
												if not IncludePlayers then
													if IsAPlayer then
														CanInsert = false
													end
												else
													if IsAPlayer then
														if not IncludeFriends then
															local Player = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(peds)
															local Handle = memory.alloc(13*8)
															NETWORK.NETWORK_HANDLE_FROM_PLAYER(Player, Handle, 13)
															CanInsert = not NETWORK.NETWORK_IS_FRIEND(Handle)
														end
													end
												end
												if CanInsert then
													ClosestPed = peds
													Dist = Distance
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	return ClosestPed
end

function DistanceBetween(x1, y1, z1, x2, y2, z2)
	local dx = x1 - x2
	local dy = y1 - y2
	local dz = z1 - z2
	return math.sqrt ( dx * dx + dy * dy + dz * dz)
end

function CopyPlayerOutfit(Ped, PlayerPed)
	local Model = ENTITY.GET_ENTITY_MODEL(Ped)
	if Model == joaat("mp_m_freemode_01") or Model == joaat("mp_f_freemode_01") then
		for i = 0, 11 do
			--if i ~= 0 and i ~= 2 and i ~= 7 then
				local Drawable = PED.GET_PED_DRAWABLE_VARIATION(PlayerPed, i)
				local Texture = PED.GET_PED_TEXTURE_VARIATION(PlayerPed, i)
				if Drawable ~= 255 and Texture ~= 255 then
					if PED.IS_PED_COMPONENT_VARIATION_VALID(PlayerPed, i, Drawable, Texture) then
						PED.SET_PED_COMPONENT_VARIATION(Ped, i, Drawable, Texture, 0)
					end
				end
			--end
		end
		for i = 0, 8 do
			--local Prop = PED.GET_PED_PROP_INDEX(PlayerPed, i)
			--local Texture = PED.GET_PED_PROP_TEXTURE_INDEX(PlayerPed, i)
			--if Prop ~= 255 and Texture ~= 255 then
			--	PED.SET_PED_PROP_INDEX(Ped, i, Prop, Texture, true, 0)
			--end
		end
	end
end

--[[

local NewVehicles = menu.list(menu.my_root(), "Custom Vehicles", {}, "")

local WasteBob = false
menu.toggle(NewVehicles, "Wastebob", {}, "", function(toggle)
	WasteBob = toggle
	if WasteBob then
		local Attachments = {}
		local Bob = joaat("buzzard")
		local Waste = joaat("prop_fncsec_03b")
		STREAMING.REQUEST_MODEL(Bob)
		STREAMING.REQUEST_MODEL(Waste)		
		while not STREAMING.HAS_MODEL_LOADED(Bob) or not STREAMING.HAS_MODEL_LOADED(Waste) do
			Wait()
		end
		local PlayerPed = PLAYER.PLAYER_PED_ID()
		local Pos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
		local Head = ENTITY.GET_ENTITY_HEADING(PlayerPed)

		local BobHandle = VEHICLE.CREATE_VEHICLE(Bob, Pos.x, Pos.y, Pos.z, Head, true, true, false)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(Bob)
		for i = 1, 3 do
			local Obj = OBJECT.CREATE_OBJECT(Waste, Pos.x, Pos.y, Pos.z, true, true, true)
			ENTITY.SET_ENTITY_AS_MISSION_ENTITY(Obj, false, true)
			entities.set_can_migrate(BobHandle, false)
			Attachments[#Attachments+1] = Obj
			ENTITY.ATTACH_ENTITY_TO_ENTITY_PHYSICALLY(Obj, BobHandle, 0, 0, 0.0 + 3.0 * i, 0.0, -1.0, 0.0, 0.0, 0.0, 90.0, 0.0, 90.0, -1.0, true, true, false, true, 2)
			ENTITY.SET_ENTITY_HAS_GRAVITY(Obj, false)
		end

		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(Waste)
		ENTITY.SET_ENTITY_AS_MISSION_ENTITY(BobHandle, false, true)
		ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(BobHandle, false)
		entities.set_can_migrate(BobHandle, false)
		ENTITY.SET_ENTITY_INVINCIBLE(BobHandle, true)
		
		NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(NETWORK.VEH_TO_NET(BobHandle), true)
		NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NETWORK.VEH_TO_NET(BobHandle), players.user(), true)

		ENTITY.SET_ENTITY_HAS_GRAVITY(BobHandle, false)
		PED.SET_PED_INTO_VEHICLE(PlayerPed, BobHandle, -1)
		
		NETWORK.NETWORK_SET_ENTITY_CAN_BLEND(BobHandle)
		
		while WasteBob do
			Wait()
		end
		entities.delete_by_handle(BobHandle)
		for i = 1, #Attachments do
			entities.delete_by_handle(Attachments[i])
		end
	end
end)
]]


local NewWeapons = menu.list(menu.my_root(), "Misc 2", {}, "")

local AK47 = false
menu.toggle(NewWeapons, "Pro Movements", {}, "", function(toggle)
	AK47 = toggle
	if AK47 then
		local Scope = joaat("w_at_scope_small")
		local SScope = joaat("w_at_scope_max_luxe")
		local Silencer = joaat("w_at_ar_supp")
		local Body = joaat("w_ar_assaultrifle")
		local Mag = joaat("w_ar_assaultriflemk2_mag_tr")
		local Flashlight = joaat("w_me_flashlight_flash")
		local PropsT = {}
		local HasPlaced = false
		local AttachsT = {
			--{Created = false, Func = function(WIndex) return CreateAttachment(Scope, PropsT, {x = 0.0, y = 0.0, z = 0.08}, WIndex) end},
			--{Created = false, Func = function(WIndex) return CreateAttachment(SScope, PropsT, {x = 0.0, y = 0.0, z = 0.08}, WIndex, 0, nil, {x = 0.0, y = 0.0, z = 0.0}) end},
			--{Created = false, Func = function(WIndex) return CreateAttachment(Silencer, PropsT, {x = 0.5, y = 0.0, z = 0.05}, WIndex, 0, nil, {x = 0.0, y = 0.0, z = 0.0}) end},
			--{Created = false, Func = function(WIndex) return CreateAttachment(Body, PropsT, {x = 0.0, y = 0.0, z = 0.0}, WIndex, 0, nil, {x = 0.0, y = 0.0, z = 0.0}) end},
			--{Created = false, Func = function(WIndex) return CreateAttachment(Mag, PropsT, {x = 0.11, y = 0.0, z = 0.01}, WIndex, 5, "gun_magazine") end}
			--{Created = false, Func = function(WIndex) return CreateAttachment(Flashlight, PropsT, {x = 0.0, y = 0.1, z = 0.0}, WIndex, 0, nil, {x = 90.0, y = 0.0, z = 90.0}) end}
		}
		while AK47 do
			local PlayerPed = PLAYER.PLAYER_PED_ID()
			local PlayerID = PLAYER.PLAYER_ID()
			if not ENTITY.IS_ENTITY_DEAD(PlayerPed) and PLAYER.IS_PLAYER_CONTROL_ON(PlayerID) then
				--CAM.DISABLE_ON_FOOT_FIRST_PERSON_VIEW_THIS_UPDATE()
				--local CurWeap = memory.alloc(8)
				local HasWeap = false --WEAPON.GET_CURRENT_PED_WEAPON(PlayerPed, CurWeap, false)
				PED.SET_PED_RESET_FLAG(PlayerPed, 71, true)
				PED.SET_PED_RESET_FLAG(PlayerPed, 91, true)
				if not PED.IS_PED_IN_ANY_VEHICLE(PlayerPed, true) then
					PED.SET_PED_RESET_FLAG(PlayerPed, 156, true)
				end
				PED.SET_PED_RESET_FLAG(PlayerPed, 401, true)
				PED.SET_PED_RESET_FLAG(PlayerPed, 237, true)
				--PED.SET_PED_RESET_FLAG(PlayerPed, 309, true)
				PED.SET_PED_RESET_FLAG(PlayerPed, 442, true)
				PED.SET_PED_CONFIG_FLAG(PlayerPed, 95, true)
				PED.SET_PED_CONFIG_FLAG(PlayerPed, 427, true)
				--PLAYER.SET_PLAYER_FORCE_SKIP_AIM_INTRO(PlayerID, true)
				--PLAYER.SET_PLAYER_SIMULATE_AIMING(PlayerID, true)
				if PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(PlayerPed) ~= 0 or PAD.IS_CONTROL_PRESSED(1, 75) then
					PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(PlayerPed, false, false)
				else
					--PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), true, -1)
				end
				--PAD.ENABLE_ALL_CONTROL_ACTIONS(0)
				--PAD.ENABLE_ALL_CONTROL_ACTIONS(1)
				if not PLAYER.IS_PLAYER_FREE_AIMING(PlayerID) then
					if not TASK.IS_PED_SPRINTING(PlayerPed) then
						if PAD.IS_CONTROL_JUST_PRESSED(0, 21) then
							if not PED.IS_PED_SWIMMING(PlayerPed) and not PED.IS_PED_SWIMMING_UNDER_WATER(PlayerPed) then
								if not PED.IS_PED_IN_ANY_VEHICLE(PlayerPed, true) then
									local Cam = CAM.GET_GAMEPLAY_CAM_ROT(2)
									local X = PAD.GET_CONTROL_NORMAL(0, 30)
									local Y = -PAD.GET_CONTROL_NORMAL(0, 31)
									if X ~= 0.0 or Y ~= 0.0 then
										local V3 = v3.new(X, Y, 0.0)
										local Rot = V3:toRot()
										ENTITY.SET_ENTITY_HEADING(PlayerPed, Cam.z + Rot.z)
									end
								end
								PED.FORCE_PED_MOTION_STATE(PlayerPed, -1115154469, false, 1, false)
							end
						end
					else
						if not PED.IS_PED_SWIMMING(PlayerPed) and not PED.IS_PED_SWIMMING_UNDER_WATER(PlayerPed) then
							if not PED.IS_PED_IN_ANY_VEHICLE(PlayerPed, true) then
								local Cam = CAM.GET_GAMEPLAY_CAM_ROT(2)
								local X = PAD.GET_CONTROL_NORMAL(0, 30)
								local Y = -PAD.GET_CONTROL_NORMAL(0, 31)
								if X ~= 0.0 or Y ~= 0.0 then
									local V3 = v3.new(X, Y, 0.0)
									local Rot = V3:toRot()
									ENTITY.SET_ENTITY_HEADING(PlayerPed, Cam.z + Rot.z)
								end
							end
						end
					end
					--if PED.IS_PED_IN_ANY_VEHICLE(PlayerPed, false) then
					--	if PAD.IS_CONTROL_PRESSED(0, 68) or PAD.IS_CONTROL_PRESSED(0, 69) then-- or PAD.IS_CONTROL_PRESSED(1, 257) then
					--		local EndV = RaycastFromCamera(PlayerPed, 1000.0, -1)
					--		PED.SET_PED_SHOOTS_AT_COORD(PlayerPed, EndV.x, EndV.y, EndV.z, false)
					--	end
					--end
				end
				if PED.IS_PED_SWITCHING_WEAPON(PlayerPed) then
					if not PED.IS_PED_SWIMMING(PlayerPed) and not PED.IS_PED_SWIMMING_UNDER_WATER(PlayerPed) then
						PED.FORCE_PED_MOTION_STATE(PlayerPed, 1063765679, false, 1, false)
					end
				end
				if HasWeap then
					--if memory.read_int(CurWeap) == joaat("weapon_assaultrifle") then
						local WIndex = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(PlayerPed, false)
						for i = 1, #AttachsT do
							if not AttachsT[i].Created then
								AttachsT[i].Created = AttachsT[i].Func(WIndex)
							end
						end
						--if PED.IS_PED_SHOOTING(PlayerPed) then
							--local Coords = RaycastFromCamera(PlayerPed, 1000.0, -1)
						--	PED. SET_PED_SHOOTS_AT_COORD(PlayerPed, Coords.x, Coords.y, Coords.z, false)
						--	Print("S")
							--MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(VECTOR VecStartCoors, VECTOR VecEndCoors, INT DamageCaused, BOOL bPerfectAccuracy = FALSE, WEAPON_TYPE Weapon = WEAPONTYPE_ASSAULTRIFLE, PED_INDEX PedIndex = NULL, BOOL bCreateTraceVfx = TRUE, BOOL bAllowRumble = TRUE, FLOAT InitialVelocity = -1.0)
						--end
						--STREAMING.REQUEST_MODEL(Scope)
						--if STREAMING.HAS_MODEL_LOADED(Scope) then
						--	local WIndex = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(PlayerPed, false)
						--	local Pos = ENTITY.GET_ENTITY_COORDS(WIndex)
						--	local Obj = OBJECT.CREATE_OBJECT(Scope, Pos.x, Pos.y, Pos.z, true, true, true)
						--	ENTITY.ATTACH_ENTITY_TO_ENTITY(Obj, WIndex, 0, 0.0, 0.0, 0.08, 0.0, 0.0, 0.0, true, false, true, false, 2, true, true)
						--	STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(Scope)
						--	HasPlaced = true
						--	PropsT[#PropsT+1] = Obj
						--end
					--end
				else
					for i = 1, #AttachsT do
						AttachsT[i].Created = false
					end
				end
			end
			Wait()
		end
		for i = 1, #PropsT do
			if ENTITY.DOES_ENTITY_EXIST(PropsT[i]) then
				entities.delete_by_handle(PropsT[i])
			end
		end
	end
end)

menu.toggle_loop(NewWeapons, "Car Speed Increased", {}, "", function(toggle)
	local Veh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID())
	if Veh ~= 0 then
		VEHICLE.MODIFY_VEHICLE_TOP_SPEED(Veh, 1000.0)
		VEHICLE.SET_VEHICLE_BRAKE(Veh, 1000.0)
		VEHICLE.SET_VEHICLE_MOD_KIT(Veh, 0)
		VEHICLE.SET_VEHICLE_ACT_AS_IF_HIGH_SPEED_FOR_FRAG_SMASHING(Veh, true)
		--PHYSICS.SET_USE_KINEMATIC_PHYSICS(Veh, true)
		--entities.set_upgrade_value(Veh, 0, entities.get_upgrade_max_value(Veh, 0), true)
		entities.set_upgrade_value(Veh, 11, entities.get_upgrade_max_value(Veh, 11), true)
		entities.set_upgrade_value(Veh, 12, entities.get_upgrade_max_value(Veh, 12), true)
		entities.set_upgrade_value(Veh, 13, entities.get_upgrade_max_value(Veh, 13), true)
		entities.set_upgrade_value(Veh, 15, entities.get_upgrade_max_value(Veh, 15), true)
		entities.set_upgrade_value(Veh, 16, entities.get_upgrade_max_value(Veh, 16), true)
		entities.set_upgrade_value(Veh, 17, entities.get_upgrade_max_value(Veh, 17), true)
		entities.set_upgrade_value(Veh, 18, entities.get_upgrade_max_value(Veh, 18), true)
		entities.set_upgrade_value(Veh, 21, entities.get_upgrade_max_value(Veh, 21), true)
		entities.set_upgrade_value(Veh, 22, entities.get_upgrade_max_value(Veh, 22), true)
		--entities.set_upgrade_value(Veh, 23, entities.get_upgrade_max_value(Veh, 23), true)
		entities.set_upgrade_value(Veh, 24, entities.get_upgrade_max_value(Veh, 24), true)
	end
end)

local PushVehs = false
local ExtraRamPower = false
menu.toggle(NewWeapons, "Vehicle Powerful Ram", {}, "", function(toggle)
	ExtraRamPower = toggle
	if ExtraRamPower then
		local HasApplied = false
		local LastVel = v3.new()
		while ExtraRamPower do	
			local Veh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
			if Veh ~= 0 then
				local VehsTouchT = {}
				local Vel = ENTITY.GET_ENTITY_VELOCITY(Veh)
				local Bool = false--ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(Veh)
				--local Ent = ENTITY._GET_LAST_ENTITY_HIT_BY_ENTITY(Veh)
				--if ENTITY.IS_ENTITY_A_VEHICLE(Ent) then
				--	Bool = ENTITY.IS_ENTITY_TOUCHING_ENTITY(Ent, Veh)
				--end
				--local Min, Max = v3.new(), v3.new()
				--local FVect, RVect, UpVect, Vect = v3.new(), v3.new(), v3.new(), v3.new()
				--ENTITY.GET_ENTITY_MATRIX(Veh, FVect, RVect, UpVect, Vect)
				--MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(Veh), Min, Max)
				for index, vehs in pairs(entities.get_all_vehicles_as_handles()) do
					if vehs ~= Veh then
						if PushVehs then
							local AdV = {
								x = Vect.x + ((FVect.x * (Max.y)) + (UpVect.x * -Max.z)),
								y = Vect.y + ((FVect.y * (Max.y)) + (UpVect.x * -Max.z)),
								z = Vect.z + ((FVect.z * (Max.y)) + (UpVect.x * -Max.z))
							}
							local AdV2 = {
								x = Vect.x + ((FVect.x * (Max.y * 3.5 + (ENTITY.GET_ENTITY_SPEED(Veh) * 0.3))) + (UpVect.x * Max.z)),
								y = Vect.y + ((FVect.y * (Max.y * 3.5 + (ENTITY.GET_ENTITY_SPEED(Veh) * 0.3))) + (UpVect.y * Max.z)),
								z = Vect.z + ((FVect.z * (Max.y * 3.5 + (ENTITY.GET_ENTITY_SPEED(Veh) * 0.3))) + (UpVect.z * Max.z))
							}
							--GRAPHICS.DRAW_LINE(AdV.x, AdV.y, AdV.z, AdV2.x, AdV2.y, AdV2.z, 255, 255, 255, 255)
							if ENTITY.IS_ENTITY_IN_ANGLED_AREA(vehs, AdV.x, AdV.y, AdV.z, AdV2.x, AdV2.y, AdV2.z, Max.x * 10, false, true, 0) then
								Bool = true
								VehsTouchT[#VehsTouchT+1] = vehs
								--Print("True")
							end
						end
						if ENTITY.IS_ENTITY_TOUCHING_ENTITY(vehs, Veh) then
							Bool = true
							VehsTouchT[#VehsTouchT+1] = vehs
						end 
					end
				end
				if Bool and ENTITY.GET_ENTITY_SPEED(Veh) > 1.0 then
					if not HasApplied then
						LastVel = Vel
						HasApplied = true
						PHYSICS.SET_USE_KINEMATIC_PHYSICS(Veh, true)
					end
					ENTITY.SET_ENTITY_VELOCITY(Veh, LastVel.x, LastVel.y, LastVel.z)
					PHYSICS.SET_USE_KINEMATIC_PHYSICS(Veh, true)
					--ENTITY.SET_ENTITY_ANGULAR_VELOCITY(Veh, 0.0, 0.0, 0.0)
					ENTITY.SET_ENTITY_VELOCITY(Veh, LastVel.x, LastVel.y, LastVel.z)
					for i = 1, #VehsTouchT do
						ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehsTouchT[i], 1, Vel.x, Vel.y, Vel.z, 0, false, true, true)
					end
				else
					if HasApplied then
						PHYSICS.SET_USE_KINEMATIC_PHYSICS(Veh, false)
						ENTITY.SET_ENTITY_VELOCITY(Veh, LastVel.x, LastVel.y, LastVel.z)
						--ENTITY.SET_ENTITY_ANGULAR_VELOCITY(Veh, 0.0, 0.0, 0.0)
					end
					HasApplied = false
				end
			end
			Wait()
		end
	end
end)

--menu.toggle(NewWeapons, "Push Vehicles In Your Way", {}, "", function(toggle)
--	PushVehs = toggle
--end, PushVehs)

local CutsceneMesser = false
menu.toggle(NewWeapons, "Cutscene Messer", {}, "", function(toggle)
	CutsceneMesser = toggle
	if CutsceneMesser then
		local PropsT = {}
		local ModelsToRequestT = {
			joaat("prop_table_03"),
			joaat("prop_table_para_comb_05"),
			joaat("prop_table_para_comb_04"),
			joaat("prop_table_para_comb_01"),
			joaat("prop_table_03b"),
			joaat("prop_table_para_comb_01"),
			joaat("prop_picnictable_01"),
			joaat("prop_table_para_comb_02"),
			joaat("prop_table_01_chr_b"),
			joaat("prop_table_03_chr"),
			joaat("prop_table_01_chr_a"),
			joaat("prop_table_03b_chr"),
			joaat("prop_table_02_chr")
			--joaat("prop_till_01")
		}
		local CreatePropsPressed = false
		local PropsState = 0
		local DeletePropsPressed = false
		local RagdollPeds = false
		local KeyPressed1 = false
		local KeyPressed2 = false
		local KeyPressed3 = false
		while CutsceneMesser do
			if util.is_key_down(0x31) then
				if not KeyPressed1 then
					KeyPressed1 = true
					CreatePropsPressed = true
				end
			else
				KeyPressed1 = false
			end
			if util.is_key_down(0x32) then
				if not KeyPressed2 then
					KeyPressed2 = true
					DeletePropsPressed = true
				end
			else
				KeyPressed2 = false
			end
			if util.is_key_down(0x33) then
				if not KeyPressed3 then
					KeyPressed3 = true
					RagdollPeds = true
				end
			else
				KeyPressed3 = false
			end
			if CreatePropsPressed then
				if #PropsT == 0 then
					local ModelsLoaded = 0
					for i = 1, #ModelsToRequestT do
						STREAMING.REQUEST_MODEL(ModelsToRequestT[i])
						if STREAMING.HAS_MODEL_LOADED(ModelsToRequestT[i]) then
							ModelsLoaded = ModelsLoaded + 1
						end
					end
					if ModelsLoaded >= #ModelsToRequestT then
						local Pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
						for i = 0, 5 do
							for k = 0, 5 do
								local Obj = OBJECT.CREATE_OBJECT(ModelsToRequestT[math.random(#ModelsToRequestT)],
								(Pos.x - 3.0) + 2.0 * i, (Pos.y - 3.0) + 2.0 * k, Pos.z,
								true, true, true)
								PropsT[#PropsT+1] = Obj
								ENTITY.SET_ENTITY_AS_MISSION_ENTITY(Obj, false, true)
								ENTITY.FREEZE_ENTITY_POSITION(Obj, false)
								set_entity_as_no_longer_needed(Obj)
								PHYSICS.ACTIVATE_PHYSICS(Obj)
							end
						end
						for i = 1, #ModelsToRequestT do
							STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ModelsToRequestT[i])
						end
						CreatePropsPressed = false
					end
				else
					for i = 1, #PropsT do
						if ENTITY.DOES_ENTITY_EXIST(PropsT[i]) then
							local Pos = ENTITY.GET_ENTITY_COORDS(PropsT[i])
							FIRE.ADD_EXPLOSION(Pos.x, Pos.y, Pos.z, 96, 1.0, true, false, 1.0, false)
							PHYSICS.ACTIVATE_PHYSICS(Obj)
							local PPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
							local NewV = {
								x = PPos.x - Pos.x,
								y = PPos.y - Pos.y,
								z = PPos.z - Pos.z
							}
							ENTITY.SET_ENTITY_VELOCITY(PropsT[i], NewV.x * 25.0, NewV.y * 25.0, NewV.z * 25.0)
							MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(Pos.x, Pos.y, Pos.z + 1.5, Pos.x, Pos.y, Pos.z, 0, true, joaat("weapon_rpg"), 0, true, true, 5.0)
						end
					end
					CreatePropsPressed = false
				end
			end
			if DeletePropsPressed then
				for i = 1, #PropsT do
					if ENTITY.DOES_ENTITY_EXIST(PropsT[i]) then
						entities.delete_by_handle(PropsT[i])
					end
				end
				for i = 1, #PropsT do
					table.remove(PropsT, #PropsT)
				end
				DeletePropsPressed = false
			end
			if RagdollPeds then
				for index, peds in pairs(entities.get_all_peds_as_handles()) do
					PED.SET_RAGDOLL_BLOCKING_FLAGS(peds, 0)
					--ENTITY.SET_ENTITY_CAN_BE_DAMAGED(peds, true)
					--ENTITY.SET_ENTITY_INVINCIBLE(peds, false)
					PED.SET_PED_TO_RAGDOLL(peds, 1000, 1000, 3, true, false, false)
					local FV = ENTITY.GET_ENTITY_FORWARD_VECTOR(peds)
					ENTITY.SET_ENTITY_VELOCITY(peds, FV.x * 2.0, FV.y * 2.0, FV.z * 2.0)
					--local Pos = ENTITY.GET_ENTITY_COORDS(peds)
					--MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(Pos.x, Pos.y, Pos.z + 1.5, Pos.x, Pos.y, Pos.z, 0, true, joaat("weapon_rpg"), 0, true, true, 5.0)
				end
				RagdollPeds = false
			end
			Wait()
		end
	end
end)

local FM_2020_SceneID = SplitGlobals("Local_28883.f_9")
local FastGrab = false
menu.toggle(NewWeapons, "Fast Synchronised Scene", {}, "", function(toggle)
	FastGrab = toggle
	if FastGrab then
		local Tick = 0
		local ScenesT = {}
		local EstimatedValue = 0
		local MinValueS = 1
		local MaxValueS = 1000
		local State = 0
		local AnimsT = {
			{"anim@heists@ornate_bank@grab_cash", "grab"},
			{"anim@heists@ornate_bank@grab_cash_heels", "grab"}
		}
		local FM_SceneID_Local = SplitGlobals("Local_10255.f_9")
		local FM_SceneRate_Local = SplitGlobals("Local_10255.f_14")
		local FM_SceneRate2_Local = SplitGlobals("Local_31621[bParam0 /*292*/].f_139")
		local PhaseToSet = 0.0
		local AvoidSceneID = 0
		while FastGrab do
			local PlayerPed = PLAYER.PLAYER_PED_ID()
			for i = 1, #AnimsT do
				if ENTITY.IS_ENTITY_PLAYING_ANIM(PlayerPed, AnimsT[i][1], AnimsT[i][2], 3) then
					ENTITY.SET_ENTITY_ANIM_SPEED(PlayerPed, AnimsT[i][1], AnimsT[i][2], 5.0)
				end
			end
			--local ObjsT = entities.get_all_objects_as_handles()
			--for k = 1, #ObjsT do
			--	if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ObjsT[k]) then
			--		if ENTITY.IS_ENTITY_PLAYING_ANIM(ObjsT[k], "anim@heists@ornate_bank@grab_cash", "cart_cash_dissapear", 3) then
			--			RequestControlOfEntity(ObjsT[k])
			--			ENTITY.SET_ENTITY_ANIM_CURRENT_TIME(ObjsT[k], "anim@heists@ornate_bank@grab_cash", "cart_cash_dissapear", 0.0)
			--		end
			--	end
			--end
			--TASK.SET_ANIM_RATE(PlayerPed, 5.0, 3, false)
			--if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller_2020")) > 0 then
			--	local AddrValue = memory.read_int(memory.script_local("fm_mission_controller_2020", FM_2020_SceneID))
			--	if AddrValue ~= 0 then
			--		local SceneID = NETWORK.NETWORK_GET_LOCAL_SCENE_FROM_NETWORK_ID(AddrValue)
			--		if SceneID ~= 0 then
			--			EstimatedValue = SceneID
			--			if PED.GET_SYNCHRONIZED_SCENE_RATE(SceneID) ~= 0.0 then
			--				PED.SET_SYNCHRONIZED_SCENE_RATE(SceneID, 5.0)
			--			end
			--		end
			--	end
			--end
			if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller")) > 0 then
				local AddrValue = memory.read_int(memory.script_local("fm_mission_controller", FM_SceneID_Local))
				if AddrValue ~= 0 then
					util.spoof_script("fm_mission_controller", function()
						local SceneID = NETWORK.NETWORK_GET_LOCAL_SCENE_FROM_NETWORK_ID(AddrValue)
						if SceneID ~= 0 then
							--EstimatedValue = SceneID
							--if PED.GET_SYNCHRONIZED_SCENE_RATE(SceneID) ~= 0.0 then
								PED.SET_SYNCHRONIZED_SCENE_RATE(SceneID, 5.0)
								AvoidSceneID = SceneID
								--PED.SET_SYNCHRONIZED_SCENE_PHASE(SceneID, PhaseToSet)
								--PED.SET_SYNCHRONIZED_SCENE_LOOPED(SceneID, true)
								--PED.TAKE_OWNERSHIP_OF_SYNCHRONIZED_SCENE(SceneID)
								--Print("SceneID "..SceneID)
							--end
							--NETWORK.NETWORK_START_SYNCHRONISED_SCENE(AddrValue)
						end
						--PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(PlayerPed, false, false)
					end)
				end
				memory.write_float(memory.script_local("fm_mission_controller", FM_SceneRate_Local), 5.0)
				for k = 0, 31 do
					local AddrValue2 = memory.read_int(memory.script_local("fm_mission_controller", FM_SceneRate2_Local + 292 * k))
					if AddrValue2 ~= 0 then
						util.spoof_script("fm_mission_controller", function()
							local SceneID = NETWORK.NETWORK_GET_LOCAL_SCENE_FROM_NETWORK_ID(AddrValue2)
							if SceneID ~= 0 then
								--EstimatedValue = SceneID
								--if PED.GET_SYNCHRONIZED_SCENE_RATE(SceneID) ~= 0.0 then
									PED.SET_SYNCHRONIZED_SCENE_RATE(SceneID, 5.0)
									
									--Print("SceneID2 "..SceneID)
									--PED.SET_SYNCHRONIZED_SCENE_PHASE(SceneID, PhaseToSet)
									--PED.SET_SYNCHRONIZED_SCENE_LOOPED(SceneID, true)
									--PED.TAKE_OWNERSHIP_OF_SYNCHRONIZED_SCENE(SceneID)
								--end
								--NETWORK.NETWORK_START_SYNCHRONISED_SCENE(AddrValue)
							end
							--PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(PlayerPed, false, false)
						end)
					end
				end
				memory.write_float(memory.script_local("fm_mission_controller", 10255 + 13), PhaseToSet)
			end
			util.spoof_script("fm_mission_controller", function()
				if EstimatedValue == 0 then
					if Tick <= 0 then
						for i = MinValueS, MaxValueS do
							if PED.IS_SYNCHRONIZED_SCENE_RUNNING(i) then
								--ScenesT[i] = i
								EstimatedValue = i
								--Print("Scene Running Search ID "..i.. " Estimated Value "..EstimatedValue)
							end
						end
						if State < 7 then
							State = State + 1
							MinValueS = MinValueS + 1000
							MaxValueS = MaxValueS + 1000
						else
							State = 0
							MinValueS = 1
							MaxValueS = 1000
						end
						Tick = 0
					else
						Tick = Tick - 1
					end
				end
				if EstimatedValue ~= 0 then
					local Running = false
					for i = EstimatedValue-1000, EstimatedValue+1000 do
						if PED.IS_SYNCHRONIZED_SCENE_RUNNING(i) then-- or PAD.IS_CONTROL_PRESSED(0, 21) then
							--local SceneID = NETWORK.NETWORK_GET_LOCAL_SCENE_FROM_NETWORK_ID(i)
							--if SceneID ~= 0 then
							--	PED.SET_SYNCHRONIZED_SCENE_RATE(SceneID, 5.0)
							--	--PED.SET_SYNCHRONIZED_SCENE_PHASE(SceneID, PhaseToSet)
							--	--PED.SET_SYNCHRONIZED_SCENE_LOOPED(SceneID, true)
							--	--PED.TAKE_OWNERSHIP_OF_SYNCHRONIZED_SCENE(SceneID)
							--end
							PED.SET_SYNCHRONIZED_SCENE_RATE(i, 5.0)
							if i ~= AvoidSceneID then
								--PED.TAKE_OWNERSHIP_OF_SYNCHRONIZED_SCENE(i)
								--PED.SET_SYNCHRONIZED_SCENE_PHASE(i, PhaseToSet)
							end
							--PED.SET_SYNCHRONIZED_SCENE_PHASE(i, PhaseToSet)
							--PED.SET_SYNCHRONIZED_SCENE_LOOPED(i, true)
							--Print("Scene Running Search ID "..i)
							--PED.TAKE_OWNERSHIP_OF_SYNCHRONIZED_SCENE(i)
							Running = true
						end
					end
					if not Running then
						EstimatedValue = 0
						State = 0
						MinValueS = 1
						MaxValueS = 1000
					end
				end
			end)
			--for index, scenes in pairs(ScenesT) do
			--	if PED.GET_SYNCHRONIZED_SCENE_RATE(scenes) ~= 0.0 then
			--		PED.SET_SYNCHRONIZED_SCENE_RATE(scenes, 3.0)
			--	end
			--end
			Wait()
		end
	end
end)

menu.toggle_loop(NewWeapons, "Set Control On", {}, "", function(toggle)
	PAD.ENABLE_ALL_CONTROL_ACTIONS(0)
	PAD.ENABLE_ALL_CONTROL_ACTIONS(1)
	PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), true, -1)
end)

menu.toggle_loop(NewWeapons, "Door Control", {}, "", function(toggle)
	local Veh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID())
	if Veh ~= 0 then
		VEHICLE.SET_DOOR_ALLOWED_TO_BE_BROKEN_OFF(Veh, 2, false)
		--VEHICLE.SET_VEHICLE_DOOR_CONTROL(Veh, 2, 360, 180.0)
		VEHICLE.SET_VEHICLE_DOOR_CONTROL(Veh, 5, 360, 180.0)
	end
end)

menu.toggle_loop(NewWeapons, "First Person Aim", {}, "", function(toggle)
	WEAPON.SET_WEAPON_ANIMATION_OVERRIDE(PLAYER.PLAYER_PED_ID(), joaat("FirstPersonFranklinAiming"))
end)

--local Relationships = {
--	"CIVMALE",
--	"CIVFEMALE",
--	"COP",
--	"SECURITY_GUARD",
--	"PRIVATE_SECURITY",
--	"FIREMAN",
--	"GANG_1",
--	"GANG_2",
--	"GANG_9",
--	"GANG_10",
--	"AMBIENT_GANG_LOST",
--	"AMBIENT_GANG_MEXICAN",
--	"AMBIENT_GANG_FAMILY",
--	"AMBIENT_GANG_BALLAS",
--	"AMBIENT_GANG_MARABUNTE",
--	"AMBIENT_GANG_CULT",
--	"AMBIENT_GANG_SALVA",
--	"AMBIENT_GANG_WEICHENG",
--	"AMBIENT_GANG_HILLBILLY",
--	"DEALER",
--	"HATES_PLAYER",
--	"HEN",
--	"WILD_ANIMAL",
--	"SHARK",
--	"COUGAR",
--	"NO_RELATIONSHIP",
--	"SPECIAL",
--	"MISSION2",
--	"MISSION3",
--	"MISSION4",
--	"MISSION5",
--	"MISSION6",
--	"MISSION7",
--	"MISSION8",
--	"ARMY",
--	"GUARD_DOG",
--	"AGGRESSIVE_INVESTIGATE",
--	"MEDIC",
--	"CAT"
--}
--
--menu.action(MiscMenu, "Set All Relationships Hate", {}, "The ambient ones.", function(toggle)
--	for i = 1, #Relationships do
--		for k = 1, #Relationships do
--			PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, joaat(Relationships[i]), joaat(Relationships[k]))
--			PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, joaat(Relationships[k]), joaat(Relationships[i]))
--		end
--	end
--end)

--menu.toggle_loop(NewWeapons, "Vehicle Speed Direction", {}, "", function(toggle)
--	local Veh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID())
--	if Veh ~= 0 then
--		local CurSpeed = ENTITY.GET_ENTITY_SPEED(Veh)
--		local VRot = ENTITY.GET_ENTITY_ROTATION(Veh, 2)
--		local Cam = CAM.GET_GAMEPLAY_CAM_ROT(2)
--		local X = PAD.GET_CONTROL_NORMAL(0, 30)
--		local Y = -PAD.GET_CONTROL_NORMAL(0, 31)
--		--VRot.z = VRot.z + 90.0
--		--local NV3 = VRot:toDir()
--		local V3 = v3.new(X, Y, 0.0)
--		local V3_2 = v3.toRot(V3)
--		local V3_3 = v3.new()
--		if X ~= 0.0 or Y ~= 0.0 then
--			local Vel = ENTITY.GET_ENTITY_VELOCITY(Veh)
--			--ENTITY.SET_ENTITY_VELOCITY(Veh, X * CurSpeed, Y * CurSpeed, Vel.z)
--			ENTITY.SET_ENTITY_VELOCITY(Veh, NV3.x * CurSpeed, NV3.y * CurSpeed, Vel.z)
--			--directx.draw_text(0.7, 0.7, "X  "..X, ALIGN_CENTRE, 1.0, {r = 0.0, g = 1.0 , b = 1.0, a = 1.0}, false)
--			--directx.draw_text(0.7, 0.75, "Y  "..Y, ALIGN_CENTRE, 1.0, {r = 0.0, g = 1.0 , b = 1.0, a = 1.0}, false)
--		end
--	end
--end)

menu.action(DevMenu, "Handling Addr", {}, "", function(toggle)
	local Veh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
	if Veh ~= 0 then
		local ToPTR = entities.handle_to_pointer(Veh)
		local Addr = entities.vehicle_get_handling(ToPTR)
		local FStr = string.format("%X", Addr)
		Print(FStr)
		util.copy_to_clipboard(FStr)
	end
end)

local TeamGlobal = SplitGlobals("Global_1845263[bLocal_3225 /*877*/].f_96.f_28")
local TeamLocal = SplitGlobals("Local_31603[bLocal_3229 /*292*/].f_1")
menu.action(DevMenu, "Set Team 1", {}, "", function(toggle)
	--memory.write_int(memory.script_global(TeamGlobal + 877 * PLAYER.PLAYER_ID()), 0)
	local Address = memory.script_local("fm_mission_controller", TeamLocal + 292 * PLAYER.PLAYER_ID())
	if Address ~= 0 then
		memory.write_int(Address, 0)
	end
end)

menu.action(DevMenu, "Set Team 2", {}, "", function(toggle)
	--memory.write_int(memory.script_global(TeamGlobal + 877 * PLAYER.PLAYER_ID()), 1)
	local Address = memory.script_local("fm_mission_controller", TeamLocal + 292 * PLAYER.PLAYER_ID())
	if Address ~= 0 then
		memory.write_int(Address, 1)
	end
end)

menu.action(DevMenu, "Set Team 3", {}, "", function(toggle)
	--memory.write_int(memory.script_global(TeamGlobal + 877 * PLAYER.PLAYER_ID()), 2)
	local Address = memory.script_local("fm_mission_controller", TeamLocal + 292 * PLAYER.PLAYER_ID())
	if Address ~= 0 then
		memory.write_int(Address, 2)
	end
end)

menu.action(DevMenu, "Set Team 4", {}, "", function(toggle)
	--memory.write_int(memory.script_global(TeamGlobal + 877 * PLAYER.PLAYER_ID()), 3)
	local Address = memory.script_local("fm_mission_controller", TeamLocal + 292 * PLAYER.PLAYER_ID())
	if Address ~= 0 then
		memory.write_int(Address, 3)
	end
end)

menu.action(DevMenu, "Is Host of BBattle 2", {}, "", function(toggle)
	util.spoof_script("fm_content_business_battles", function()
		Print("1 "..NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT())
		util.request_script_host("fm_content_business_battles")
		Print("2 "..NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT())
	end)
end)

menu.action(DevMenu, "Delete Incident", {}, "", function(toggle)
	for i = 1, 20000 do
		if MISC.IS_INCIDENT_VALID(i) then
			MISC.DELETE_INCIDENT(i)
			--Print("Deleted ".. i)
		end
	end
end)

menu.action(DevMenu, "Unstuck Vehicle", {}, "", function(toggle)
	local Veh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
	local NetID = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(Veh)
	if NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(NetID) then
		NETWORK.SET_NETWORK_ID_CAN_MIGRATE(NetID, true)
		NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(Veh)
	end
end)

local PatchStromberg = false
menu.toggle(DevMenu, "gb_fortified Patch Stromberg", {}, "", function(toggle)
	PatchStromberg = toggle
	if PatchStromberg then
		local Patched = false
		while PatchStromberg do
			if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("gb_fortified")) > 0 then
				if not Patched then
					local Addr = memory.scan_script("gb_fortified", "2D 00 02 00 00 25 ? 66 2C ? ? ?")
					if Addr ~= 0 then
						Addr = Addr + 5
						local HexesT = {0x28}--, 0x61, 0xA6, 0xDB, 0x34, 0x2E, 0x00, 0x01}
						for i = 1, #HexesT do
							memory.write_byte(Addr + (i-1), HexesT[i])
						end
						memory.write_int(Addr + 1, joaat("stromberg"))
						Patched = true
						util.copy_to_clipboard(string.format("%X", Addr))
						Print("Patched")
					end
				end
			else
				Patched = false
			end
			Wait()
		end
	end
end)

function CreateAttachment(Model, PropsT, Offset, WIndex, TexV, BID, Rot)
	STREAMING.REQUEST_MODEL(Model)
	if STREAMING.HAS_MODEL_LOADED(Model) then
		local Pos = ENTITY.GET_ENTITY_COORDS(WIndex)
		local Obj = OBJECT.CREATE_OBJECT(Model, Pos.x, Pos.y, Pos.z, true, true, true)
		local BoneIndex = 0
		if BID ~= nil then
			BoneIndex = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(WIndex, BID)
		end
		ENTITY.ATTACH_ENTITY_TO_ENTITY(Obj, WIndex, BoneIndex, Offset.x, Offset.y, Offset.z, Rot.x, Rot.y, Rot.z, true, false, true, false, 2, true, true)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(Model)
		PropsT[#PropsT+1] = Obj
		if TexV ~= nil then
			OBJECT.SET_OBJECT_TINT_INDEX(Obj, TexV)
		end
		return true
	end
	return false
end

local MissionFinisherMenu = menu.list(menu.my_root(), "Mission Finisher", {}, "")
local MissionFinisher = false
menu.toggle(MissionFinisherMenu, "Mission Finisher", {}, "", function(toggle)
	MissionFinisher = toggle
	if MissionFinisher then
		local nrl_Addrs = {}
		for i = 0, 3 do
			local Addr = memory.script_global(SplitGlobals("Global_4718592.f_3318[i /*25763*/].f_60") + 25763 * i)
			nrl_Addrs[i+1] = Addr
		end
		local goto_sz_Addrs = {}
		local drpr_addrs = {}
		local jtop_Addrs = {}
		local wtm_Addrs = {}
		for k = 0, 3 do
			jtop_Addrs[k+1] = {}
			jtop_Addrs[k+1].TeamAddrs = {}
			wtm_Addrs[k+1] = {}
			wtm_Addrs[k+1].TeamAddrs = {}
			for i = 0, 19 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_5[num /*333*/].f_139[j]") + ((k) + (333 * i))) --goto
				jtop_Addrs[k+1].TeamAddrs[#jtop_Addrs[k+1].TeamAddrs+1] = Addr
				if k == 0 then
					local Addr2 = memory.script_global(SplitGlobals("Global_4980736.f_5[bVar0 /*333*/].f_14[0]") + 333 * i) --goto
					goto_sz_Addrs[#goto_sz_Addrs+1] = Addr2
				end
			end
			for i = 0, 19 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_5[bVar0 /*333*/].f_129[iVar1]") + ((k) + (333 * i))) --goto
				wtm_Addrs[k+1].TeamAddrs[#wtm_Addrs[k+1].TeamAddrs+1] = Addr
			end
			for i = 0, 31 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_97409[bVar0 /*586*/].f_225[iVar1]") + ((k) + (586 * i))) --veh
				jtop_Addrs[k+1].TeamAddrs[#jtop_Addrs[k+1].TeamAddrs+1] = Addr
			end
			for i = 0, 31 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_7002[bVar0 /*591*/].f_209[iVar2]") + ((k) + (591 * i))) --obj
				jtop_Addrs[k+1].TeamAddrs[#jtop_Addrs[k+1].TeamAddrs+1] = Addr
			end	
			for i = 0, 79 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_117913[bVar3 /*1162*/].f_648[iVar2]") + ((k) + (1162 * i))) --ene
				jtop_Addrs[k+1].TeamAddrs[#jtop_Addrs[k+1].TeamAddrs+1] = Addr
			end
			for i = 0, 16 do
				local Addr = memory.script_global(SplitGlobals("Global_4718592.f_3318[bVar0 /*25763*/].f_7241[bVar1]") + ((25763 * k) + (i)))
				drpr_addrs[#drpr_addrs+1] = Addr
			end
		end
		local HasSetValues = false
		while MissionFinisher do
			if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller")) > 0
			or SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller_2020")) > 0 then
				util.spoof_script("fm_mission_controller", function()
					if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
						NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
						util.request_script_host("fm_mission_controller")
					end
					if NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
						NETWORK.NETWORK_PREVENT_SCRIPT_HOST_MIGRATION()
					end
				end)
				util.spoof_script("fm_mission_controller_2020", function()
					if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
						NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
						util.request_script_host("fm_mission_controller_2020")
					end
					if NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
						NETWORK.NETWORK_PREVENT_SCRIPT_HOST_MIGRATION()
					end
				end)
				if not HasSetValues then
					local nrl_Values = {}
					for i = 1, 4 do
						local nrl_Value = memory.read_int(nrl_Addrs[i])
						if nrl_Value > 0 then
							nrl_Value = nrl_Value - 1
						end
						for k = 1, #jtop_Addrs[i].TeamAddrs do
							memory.write_int(jtop_Addrs[i].TeamAddrs[k], nrl_Value)
						end
						for k = 1, 20 do
							memory.write_int(wtm_Addrs[i].TeamAddrs[k], 0)
						end
					end
					for i = 1, 20 do
						memory.write_float(goto_sz_Addrs[i], 30000.0)
					end
					for i = 1, 17 do
						memory.write_float(drpr_addrs[i], 30000.0)
					end
					HasSetValues = true
				end
			else
				HasSetValues = false
			end
			Wait()
		end
	end
end)

local MissionFinisher2 = false
menu.toggle(MissionFinisherMenu, "Mission Finisher 2", {}, "", function(toggle)
	MissionFinisher2 = toggle
	if MissionFinisher2 then
		local nrl_Addrs = {}
		for i = 0, 3 do
			local Addr = memory.script_global(SplitGlobals("Global_4718592.f_3318[i /*25763*/].f_60") + 25763 * i)
			nrl_Addrs[i+1] = Addr
		end
		local goto_sz_Addrs = {}
		local drpr_addrs = {}
		local jtop_Addrs = {}
		local wtm_Addrs = {}
		for k = 0, 3 do
			jtop_Addrs[k+1] = {}
			jtop_Addrs[k+1].TeamAddrs = {}
			wtm_Addrs[k+1] = {}
			wtm_Addrs[k+1].TeamAddrs = {}
			for i = 0, 19 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_5[num /*333*/].f_139[j]") + ((k) + (333 * i))) --goto
				jtop_Addrs[k+1].TeamAddrs[#jtop_Addrs[k+1].TeamAddrs+1] = Addr
				if k == 0 then
					local Addr2 = memory.script_global(SplitGlobals("Global_4980736.f_5[bVar0 /*333*/].f_14[0]") + 333 * i) --goto
					goto_sz_Addrs[#goto_sz_Addrs+1] = Addr2
				end
			end
			for i = 0, 19 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_5[bVar0 /*333*/].f_129[iVar1]") + ((k) + (333 * i))) --goto
				wtm_Addrs[k+1].TeamAddrs[#wtm_Addrs[k+1].TeamAddrs+1] = Addr
			end
			for i = 0, 31 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_97409[bVar0 /*586*/].f_225[iVar1]") + ((k) + (586 * i))) --veh
				jtop_Addrs[k+1].TeamAddrs[#jtop_Addrs[k+1].TeamAddrs+1] = Addr
			end
			for i = 0, 31 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_7002[bVar0 /*591*/].f_209[iVar2]") + ((k) + (591 * i))) --obj
				jtop_Addrs[k+1].TeamAddrs[#jtop_Addrs[k+1].TeamAddrs+1] = Addr
			end	
			for i = 0, 79 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_117913[bVar3 /*1162*/].f_648[iVar2]") + ((k) + (1162 * i))) --ene
				jtop_Addrs[k+1].TeamAddrs[#jtop_Addrs[k+1].TeamAddrs+1] = Addr
			end
			for i = 0, 16 do
				local Addr = memory.script_global(SplitGlobals("Global_4718592.f_3318[bVar0 /*25763*/].f_7241[bVar1]") + ((25763 * k) + (i)))
				drpr_addrs[#drpr_addrs+1] = Addr
			end
		end
		local HasSetValues = false
		while MissionFinisher2 do
			if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller")) > 0
			or SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller_2020")) > 0 then
				util.spoof_script("fm_mission_controller", function()
					if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
						NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
						util.request_script_host("fm_mission_controller")
					end
					if NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
						NETWORK.NETWORK_PREVENT_SCRIPT_HOST_MIGRATION()
					end
				end)
				util.spoof_script("fm_mission_controller_2020", function()
					if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
						NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
						util.request_script_host("fm_mission_controller_2020")
					end
					if NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
						NETWORK.NETWORK_PREVENT_SCRIPT_HOST_MIGRATION()
					end
				end)
				if not HasSetValues then
					local nrl_Values = {}
					for i = 1, 4 do
						local nrl_Value = memory.read_int(nrl_Addrs[i])
						if nrl_Value > 0 then
							nrl_Value = nrl_Value
						end
						for k = 1, #jtop_Addrs[i].TeamAddrs do
							memory.write_int(jtop_Addrs[i].TeamAddrs[k], nrl_Value)
						end
						for k = 1, 20 do
							memory.write_int(wtm_Addrs[i].TeamAddrs[k], 0)
						end
					end
					for i = 1, 20 do
						memory.write_float(goto_sz_Addrs[i], 30000.0)
					end
					for i = 1, 17 do
						memory.write_float(drpr_addrs[i], 30000.0)
					end
					HasSetValues = true
				end
			else
				HasSetValues = false
			end
			Wait()
		end
	end
end)

local CasinoFinisher = false
menu.toggle(MissionFinisherMenu, "Casino Finisher", {}, "", function(toggle)
	CasinoFinisher = toggle
	if CasinoFinisher then
		local nrl_Addrs = {}
		for i = 0, 3 do
			local Addr = memory.script_global(SplitGlobals("Global_4718592.f_3318[i /*25763*/].f_60") + 25763 * i)
			nrl_Addrs[i+1] = Addr
		end
		local goto_sz_Addrs = {}
		local drpr_addrs = {}
		local jtop_Addrs = {}
		local wtm_Addrs = {}
		for k = 0, 3 do
			jtop_Addrs[k+1] = {}
			jtop_Addrs[k+1].TeamAddrs = {}
			wtm_Addrs[k+1] = {}
			wtm_Addrs[k+1].TeamAddrs = {}
			for i = 0, 19 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_5[num /*333*/].f_139[j]") + ((k) + (333 * i))) --goto
				jtop_Addrs[k+1].TeamAddrs[#jtop_Addrs[k+1].TeamAddrs+1] = Addr
				if k == 0 then
					local Addr2 = memory.script_global(SplitGlobals("Global_4980736.f_5[bVar0 /*333*/].f_14[0]") + 333 * i) --goto
					goto_sz_Addrs[#goto_sz_Addrs+1] = Addr2
				end
			end
			for i = 0, 19 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_5[bVar0 /*333*/].f_129[iVar1]") + ((k) + (333 * i))) --goto
				wtm_Addrs[k+1].TeamAddrs[#wtm_Addrs[k+1].TeamAddrs+1] = Addr
			end
			for i = 0, 31 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_97409[bVar0 /*586*/].f_225[iVar1]") + ((k) + (586 * i))) --veh
				jtop_Addrs[k+1].TeamAddrs[#jtop_Addrs[k+1].TeamAddrs+1] = Addr
			end
			for i = 0, 31 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_7002[bVar0 /*591*/].f_209[iVar2]") + ((k) + (591 * i))) --obj
				jtop_Addrs[k+1].TeamAddrs[#jtop_Addrs[k+1].TeamAddrs+1] = Addr
			end	
			for i = 0, 79 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_117913[bVar3 /*1162*/].f_648[iVar2]") + ((k) + (1162 * i))) --ene
				jtop_Addrs[k+1].TeamAddrs[#jtop_Addrs[k+1].TeamAddrs+1] = Addr
			end
			for i = 0, 16 do
				local Addr = memory.script_global(SplitGlobals("Global_4718592.f_3318[bVar0 /*25763*/].f_7241[bVar1]") + ((25763 * k) + (i)))
				drpr_addrs[#drpr_addrs+1] = Addr
			end
		end
		local HasSetValues = false
		while CasinoFinisher do
			if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller")) > 0
			or SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller_2020")) > 0 then
				util.spoof_script("fm_mission_controller", function()
					if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
						NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
						util.request_script_host("fm_mission_controller")
					end
					if NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
						NETWORK.NETWORK_PREVENT_SCRIPT_HOST_MIGRATION()
					end
				end)
				util.spoof_script("fm_mission_controller_2020", function()
					if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
						NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
						util.request_script_host("fm_mission_controller_2020")
					end
					if NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
						NETWORK.NETWORK_PREVENT_SCRIPT_HOST_MIGRATION()
					end
				end)
				if not HasSetValues then
					local nrl_Values = {}
					for i = 1, 4 do
						local nrl_Value = memory.read_int(nrl_Addrs[i])
						if nrl_Value > 0 then
							nrl_Value = nrl_Value
						end
						for k = 1, #jtop_Addrs[i].TeamAddrs do
							--memory.write_int(jtop_Addrs[i].TeamAddrs[k], nrl_Value)
						end
						for k = 1, 20 do
							memory.write_int(wtm_Addrs[i].TeamAddrs[k], 0)
						end
					end
					for i = 1, 20 do
						memory.write_float(goto_sz_Addrs[i], 30000.0)
					end
					for i = 1, 17 do
						--memory.write_float(drpr_addrs[i], 30000.0)
					end
					HasSetValues = true
				end
			else
				HasSetValues = false
			end
			Wait()
		end
	end
end)

menu.toggle_loop(NewWeapons, "Car Rapid Fire", {}, "", function(toggle)
	local Veh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID())
	if Veh ~= 0 then
		VEHICLE.SET_VEHICLE_FIXED(Veh)
	end
end)

local ShootHomingAtomizer = false
menu.toggle(NewWeapons, "Shoot Homing Atomizer", {}, "", function(toggle)
	ShootHomingAtomizer = toggle
	if ShootHomingAtomizer then
		--local MemAddr = memory.alloc(8)
		--WEAPON.GET_CURRENT_PED_VEHICLE_WEAPON(PLAYER.PLAYER_PED_ID(), MemAddr)
		--util.copy_to_clipboard(memory.read_int(MemAddr))
		local AtomHash = -441560099--joaat("VEHICLE_WEAPON_MONSTER3_GLKIN")
		local ModelHash = joaat("w_ex_vehiclegrenade")
		WEAPON.REQUEST_WEAPON_ASSET(AtomHash, 31, 0)
		while not WEAPON.HAS_WEAPON_ASSET_LOADED(AtomHash) do
			Wait()
		end
		WEAPON.GIVE_WEAPON_TO_PED(PLAYER.PLAYER_PED_ID(), AtomHash, 120, false, false)
		local PropsHandlesT = {}
		local PropsT = {}
		while ShootHomingAtomizer do
			local peds = PLAYER.PLAYER_PED_ID()
			local PPos = ENTITY.GET_ENTITY_COORDS(peds)
			if PED.IS_PED_SHOOTING(peds) then
				local Weap = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(peds, 0)
				if Weap ~= 0 then
					local BoneID = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(Weap, "gun_muzzle")
					if BoneID ~= 0 then
						local Pos = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(Weap, BoneID)
						local HitV3 = RaycastFromCamera(peds, 1000.0, -1)
						MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(Pos.x, Pos.y, Pos.z, HitV3.x, HitV3.y, HitV3.z, 30, false, AtomHash, peds, true, true, -1.0)
					end
				end
			end
			local Obj = OBJECT.GET_CLOSEST_OBJECT_OF_TYPE(PPos.x, PPos.y, PPos.z, 10.0, ModelHash, false, false, false)
			if PropsT[Obj] == nil then
				PropsT[Obj] = 0
				PropsHandlesT[#PropsHandlesT+1] = {Handle = Obj, Target = 0}
			end
			for i = 1, #PropsHandlesT do
				if PropsHandlesT[i] ~= nil then
					if ENTITY.DOES_ENTITY_EXIST(PropsHandlesT[i].Handle) then
						ENTITY.SET_ENTITY_HAS_GRAVITY(PropsHandlesT[i].Handle, false)
						if PropsHandlesT[i].Target == 0 then
							PropsHandlesT[i].Target = GetAllPedNearestTarget(peds, false, true, false, false, {0})
						end
						if PropsHandlesT[i].Target ~= 0 then
							if ENTITY.DOES_ENTITY_EXIST(PropsHandlesT[i].Target) and not ENTITY.IS_ENTITY_DEAD(PropsHandlesT[i].Target) then
								if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(PropsHandlesT[i].Handle, PropsHandlesT[i].Target, 17) then
									local TPos = ENTITY.GET_ENTITY_COORDS(PropsHandlesT[i].Target)
									local OPos = ENTITY.GET_ENTITY_COORDS(PropsHandlesT[i].Handle)
									local NewV3 = {
										x = (TPos.x - OPos.x) * 1.0,
										y = (TPos.y - OPos.y) * 1.0,
										z = (TPos.z - OPos.z) * 1.0
									}
									local V3Ins = v3.new(NewV3.x, NewV3.y, NewV3.z)
									local NewV3_2 = v3.normalise(V3Ins)
									NewV3_2:mul(30.0 + ENTITY.GET_ENTITY_SPEED(PropsHandlesT[i].Target))
									--ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(PropsHandlesT[i].Handle, 1, NewV3_2.x, NewV3_2.y, NewV3_2.z, 0, false, true, false)
									ENTITY.SET_ENTITY_VELOCITY(PropsHandlesT[i].Handle, NewV3_2.x, NewV3_2.y, NewV3_2.z)
								end
							else
								PropsHandlesT[i].Target = 0
							end
						end
					else
						PropsT[PropsHandlesT[i].Handle] = nil
						PropsHandlesT[i] = nil
					end
				end
			end
			Wait()
		end
	end
end)

local YachtDefend = false
menu.toggle(MissionMenu, "Yacht Defend", {}, "", function(toggle)
	YachtDefend = toggle
	if YachtDefend then
		local YachtBlip = SplitGlobals("Local_227.f_13")
		local StartArea = SplitGlobals("Local_227.f_19")
		local EndArea = SplitGlobals("Local_227.f_22")
		local AreaRadius = SplitGlobals("Local_227.f_25")
		local PlayerPed = PLAYER.PLAYER_PED_ID()
		local Pos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
		local StartPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PlayerPed, 0.0, 10.0, -5)
		local EndPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PlayerPed, 0.0, -10.0, 5)
		if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("gb_yacht_rob")) == 0 then
			memory.write_int(memory.script_global(WhichMissionStartGlobal + 609 * PLAYER.PLAYER_ID()), -1)
			Wait(1000)
			memory.write_int(memory.script_global(WhichMissionStartGlobal + 609 * PLAYER.PLAYER_ID()), 152)
		end
		local HasSetCoords = false
		while YachtDefend do
			local Delay = 0
			if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("gb_yacht_rob")) > 0 then
				local IsHost = false
				util.spoof_script("gb_yacht_rob", function()
					IsHost = NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT()
				end)
				if IsHost then
					if not HasSetCoords then
						memory.write_vector3(memory.script_local("gb_yacht_rob", YachtBlip), Pos)
						memory.write_vector3(memory.script_local("gb_yacht_rob", StartArea), StartPos)
						memory.write_vector3(memory.script_local("gb_yacht_rob", EndArea), EndPos)
						--HasSetCoords = true
					end
				else
					util.request_script_host("gb_yacht_rob")
					Delay = 5
				end
			else
				HasSetCoords = false
			end
			Wait(Delay)
		end
	end
end)

menu.action(MissionFinisherMenu, "Set 9999 Lives", {}, "", function(toggle)
	if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller")) > 0 then
		local LivesLocalAddr = SplitGlobals("Local_19728.f_1730[bVar0]")
		for i = 1, 100 do
			local IsHost = false
			util.spoof_script("fm_mission_controller", function()
				IsHost = NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT()
				--NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
			end)
			if IsHost then
				for k = 0, 3 do
					memory.write_int(memory.script_local("fm_mission_controller", LivesLocalAddr + k), -9999)
				end
				break
			else
				util.request_script_host("fm_mission_controller")
			end
			Wait(1000)
		end
	end
end)

menu.action(MissionFinisherMenu, "Set 0 Lives", {}, "", function(toggle)
	if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller")) > 0 then
		local LivesLocalAddr = SplitGlobals("Local_19728.f_1730[bVar0]")
		for i = 1, 100 do
			local IsHost = false
			util.spoof_script("fm_mission_controller", function()
				IsHost = NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT()
				--NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
			end)
			if IsHost then
				for k = 0, 3 do
					memory.write_int(memory.script_local("fm_mission_controller", LivesLocalAddr + k), 0)
				end
				break
			else
				util.request_script_host("fm_mission_controller")
			end
			Wait(1000)
		end
	end
end)

local RotateHost = false
menu.toggle(MissionFinisherMenu, "Rotate Script Host", {}, "To fix infinite loading.", function(toggle)
    RotateHost = toggle
    if RotateHost then
        local CurrentIndex = 1
        local PlayersT = {}
        local FoundPlayersT = {}
        while RotateHost do
            local Delay = 0
            for i = 0, 29 do
                if FoundPlayersT[i+1] == nil then
                    if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) then
                        FoundPlayersT[i+1] = i+1
                        PlayersT[#PlayersT+1] = {ID = i, HasGaveScriptHost = false}
                    end
                end
            end
            if PlayersT[CurrentIndex] ~= nil then
                if NETWORK.NETWORK_IS_PLAYER_CONNECTED(PlayersT[CurrentIndex].ID) then
                    local IsHost = false
                    util.spoof_script("fm_mission_controller", function()
                        local HostID = NETWORK.NETWORK_GET_HOST_OF_THIS_SCRIPT()
                        IsHost = HostID == PlayersT[CurrentIndex].ID
                        Print(HostID)
                    end)
                    if not IsHost then
                        util.request_script_host("fm_mission_controller")
                        Wait(1000)
                        util.give_script_host("fm_mission_controller", PlayersT[CurrentIndex].ID)
                        Delay = 1000
                    else
                        Delay = 1000
                        CurrentIndex = CurrentIndex + 1
                    end
                else
                    FoundPlayersT[PlayersT[CurrentIndex].ID+1] = nil
                    table.remove(PlayersT, CurrentIndex)
                    --PlayersT[CurrentIndex] = nil
                    CurrentIndex = CurrentIndex + 1
                end
            else
                --table.remove(PlayersT, CurrentIndex)
                --PlayersT[CurrentIndex] = nil
                CurrentIndex = CurrentIndex + 1
            end
            if CurrentIndex > #PlayersT then
                CurrentIndex = 1
            end
            Wait(Delay)
        end
    end
end)

local RotateHost2020 = false
menu.toggle(MissionFinisherMenu, "Rotate Script Host 2020", {}, "To fix infinite loading.", function(toggle)
    RotateHost2020 = toggle
    if RotateHost2020 then
        local CurrentIndex = 1
        local PlayersT = {}
        local FoundPlayersT = {}
        while RotateHost2020 do
            local Delay = 0
            for i = 0, 29 do
                if FoundPlayersT[i+1] == nil then
                    if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) then
                        FoundPlayersT[i+1] = i+1
                        PlayersT[#PlayersT+1] = {ID = i, HasGaveScriptHost = false}
                    end
                end
            end
            if PlayersT[CurrentIndex] ~= nil then
                if NETWORK.NETWORK_IS_PLAYER_CONNECTED(PlayersT[CurrentIndex].ID) then
                    local IsHost = false
                    util.spoof_script("fm_mission_controller_2020", function()
                        local HostID = NETWORK.NETWORK_GET_HOST_OF_THIS_SCRIPT()
                        IsHost = HostID == PlayersT[CurrentIndex].ID
                        Print(HostID)
                    end)
                    if not IsHost then
                        util.request_script_host("fm_mission_controller_2020")
                        Wait(1000)
                        util.give_script_host("fm_mission_controller_2020", PlayersT[CurrentIndex].ID)
                        Delay = 1000
                    else
                        Delay = 1000
                        CurrentIndex = CurrentIndex + 1
                    end
                else
                    FoundPlayersT[PlayersT[CurrentIndex].ID+1] = nil
                    table.remove(PlayersT, CurrentIndex)
                    --PlayersT[CurrentIndex] = nil
                    CurrentIndex = CurrentIndex + 1
                end
            else
                --table.remove(PlayersT, CurrentIndex)
                --PlayersT[CurrentIndex] = nil
                CurrentIndex = CurrentIndex + 1
            end
            if CurrentIndex > #PlayersT then
                CurrentIndex = 1
            end
            Wait(Delay)
        end
    end
end)

function CallDispatchFunc()
	local IncidentAddr = memory.alloc(8)
	local Entity = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID())
	local Pos = ENTITY.GET_ENTITY_COORDS(Entity)
	local DispatchID = SelectedDispatch
	local RelHash = 0 --joaat(AiLikeRel)
	local Sucess = MISC.CREATE_INCIDENT_WITH_ENTITY(DispatchID, Entity, DispatchUnits, 0.0, IncidentAddr, RelHash, 1)
	if Sucess then
		local IncidentID = memory.read_int(IncidentAddr)
		IncidentIndex = IncidentID
	end
	return Sucess
end

function DeleteDispatchFunc()
	if IncidentIndex ~= 0 then
		if MISC.IS_INCIDENT_VALID(IncidentIndex) then
			MISC.DELETE_INCIDENT(IncidentIndex)
		end
		IncidentIndex = 0
	end
end

local VehGuns = false
menu.toggle(WeaponizedVehiclesMenu, "Vehicle Guns", {}, "", function(toggle)
	VehGuns = toggle
	if VehGuns then
		local PTFXAsset = "weap_ch_vehicle_weapons"
		local PTFXName = "bullet_tracer_ch_tank_laser"
		--WEAPON.REQUEST_WEAPON_ASSET(WEAPON_TYPE weaponType, INT iWeaponResourceFlags = WRF_REQUEST_ALL_ANIMS, EXTRA_WEAPON_COMPONENT_RESOURCE_FLAGS ExtraWeaponComponentFlags = WEAPON_COMPONENT_NONE)
		while VehGuns do
			if not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(PTFXAsset) then
				STREAMING.REQUEST_NAMED_PTFX_ASSET(PTFXAsset)
				while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(PTFXAsset) do
					Wait()
				end
			end
			if PAD.IS_CONTROL_PRESSED(0, 69) then
				local PlayerPed = PLAYER.PLAYER_PED_ID()
				local Veh = PED.GET_VEHICLE_PED_IS_IN(PlayerPed, false)
				local CamRot = CAM.GET_GAMEPLAY_CAM_ROT(0)
				if Veh ~= 0 then
					if PED.IS_PED_IN_VEHICLE(PlayerPed, Veh, false) then
						local EndCoords, DidHit = RaycastFromCamera(Veh, 1000.0)
						local BoneIndex = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(Veh, "headlight_l")
						local BoneIndex2 = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(Veh, "headlight_r")
						if BoneIndex ~= 0 then
							local Pos = ENTITY.GET_ENTITY_BONE_POSTION(Veh, BoneIndex)
							local NewPos = v3.new(EndCoords)
							local Sub = v3.sub(NewPos, Pos)
							local Rot = v3.toRot(Sub)
							MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(Pos.x, Pos.y, Pos.z, EndCoords.x, EndCoords.y, EndCoords.z, 30, false, joaat("weapon_raycarbine"), PlayerPed, false--[[VFX]], true, -1.0, Veh, 0)
							GRAPHICS.USE_PARTICLE_FX_ASSET(PTFXAsset)
							--GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("bullet_tracer_xs_sr", Pos.x, Pos.y, Pos.z, CamRot.y, -CamRot.x + 90.0, CamRot.z + 90.0, 1.0, false, false, false, true)
							GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(PTFXName, Pos.x, Pos.y, Pos.z, Rot.x - 90.0, Rot.y, Rot.z, 1.0, false, false, false, true)
						end
						if BoneIndex2 ~= 0 then
							local Pos = ENTITY.GET_ENTITY_BONE_POSTION(Veh, BoneIndex2)
							local NewPos = v3.new(EndCoords)
							local Sub = v3.sub(NewPos, Pos)
							local Rot = v3.toRot(Sub)
							MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(Pos.x, Pos.y, Pos.z, EndCoords.x, EndCoords.y, EndCoords.z, 30, false, joaat("weapon_raycarbine"), PlayerPed, false--[[VFX]], true, -1.0, Veh, 0)
							GRAPHICS.USE_PARTICLE_FX_ASSET(PTFXAsset)
							--GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("bullet_tracer_xs_sr", Pos.x, Pos.y, Pos.z, CamRot.y, -CamRot.x + 90.0, CamRot.z + 90.0, 1.0, false, false, false, true)
							GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(PTFXName, Pos.x, Pos.y, Pos.z, Rot.x - 90.0, Rot.y, Rot.z, 1.0, false, false, false, true)
						end
						Wait(49)
					end
				end
			end
			Wait()
		end
	end
end)

local AvoidFriendlyPeds = false
menu.toggle(WeaponizedVehiclesMenu, "Homing Shoot Avoid Friendly Peds", {}, "", function(toggle)
	AvoidFriendlyPeds = toggle
end, AvoidFriendlyPeds)

local VehHomingKinect = false
menu.toggle(WeaponizedVehiclesMenu, "Vehicle Homing Kinect", {}, "", function(toggle)
	VehHomingKinect = toggle
	if VehHomingKinect then
		local AtomHash = -441560099--joaat("VEHICLE_WEAPON_MONSTER3_GLKIN")
		local ModelHash = joaat("w_ex_vehiclegrenade")
		WEAPON.REQUEST_WEAPON_ASSET(AtomHash, 31, 0)
		while not WEAPON.HAS_WEAPON_ASSET_LOADED(AtomHash) do
			Wait()
		end
		WEAPON.GIVE_WEAPON_TO_PED(PLAYER.PLAYER_PED_ID(), AtomHash, 120, false, false)
		local PropsHandlesT = {}
		local PropsT = {}
		local WhichSideShoot = 0
		local TimerT = {
			Timer = util.current_time_millis(),
			TimerCount = 1,
			HasReseted = false
		}
		local Spd = 0.00
		local ForbiddenRels = {0}
		if AvoidFriendlyPeds then
			ForbiddenRels[#ForbiddenRels+1] = 1
		end
		while VehHomingKinect do
			local peds = PLAYER.PLAYER_PED_ID()
			local PPos = ENTITY.GET_ENTITY_COORDS(peds)
			local Veh = PED.GET_VEHICLE_PED_IS_IN(peds, true)
			local CamRot = CAM.GET_GAMEPLAY_CAM_ROT(0)
			if Veh ~= 0 then
				if TimerT.TimerCount >= 1 then
					TimerT.HasReseted = false
					if PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
						if PED.IS_PED_SHOOTING(peds) or PAD.IS_CONTROL_PRESSED(0, 70) then
							local Shooted = false
							local BoneIndex = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(Veh, "headlight_l")
							local BoneIndex2 = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(Veh, "headlight_r")
							if WhichSideShoot == 0 then
								if BoneIndex ~= 0 then
									local Pos = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(Veh, BoneIndex)
									if not IsZeroVector(Pos) then
										local FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(Veh)
										local FPos = {x = Pos.x + FVect.x * 10.0, y = Pos.y + FVect.y * 10.0, z = Pos.z + FVect.z * 10.0}
										MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(Pos.x, Pos.y, Pos.z, FPos.x, FPos.y, FPos.z, 30, false, AtomHash, peds, true, true, -1.0)
										Shooted = true
										TimerT.TimerCount = 0
										WhichSideShoot = 1
									end
								end
							end
							if not Shooted then
								if WhichSideShoot == 1 then
									if BoneIndex2 ~= 0 then
										local Pos = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(Veh, BoneIndex2)
										if not IsZeroVector(Pos) then
											local FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(Veh)
											local FPos = {x = Pos.x + FVect.x * 10.0, y = Pos.y + FVect.y * 10.0, z = Pos.z + FVect.z * 10.0}
											MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(Pos.x, Pos.y, Pos.z, FPos.x, FPos.y, FPos.z, 30, false, AtomHash, peds, true, true, -1.0)
											Shooted = true
											TimerT.TimerCount = 0
											WhichSideShoot = 0
										end
									end
								end
							end
							if not Shooted then
								local Pos = ENTITY.GET_ENTITY_COORDS(Veh)
								local FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(Veh)
								local Min, Max = v3.new(), v3.new()
								MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(Veh), Min, Max)
								local FPos = {
									x = Pos.x + Max.y * FVect.x,
									y = Pos.y + Max.y * FVect.y,
									z = Pos.z + Max.y * FVect.z
								}
								MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(Pos.x, Pos.y, Pos.z, FPos.x, FPos.y, FPos.z, 30, false, AtomHash, peds, true, true, -1.0)
								Shooted = true
								TimerT.TimerCount = 0
								WhichSideShoot = 0
							end
						end
					end
				else
					if not TimerT.HasReseted then
						TimerT.Timer = util.current_time_millis()
						TimerT.HasReseted = true
					end
					TimerCount(TimerT)
				end
			end
			local Obj = OBJECT.GET_CLOSEST_OBJECT_OF_TYPE(PPos.x, PPos.y, PPos.z, 10.0, ModelHash, false, false, false)
			if PropsT[Obj] == nil then
				PropsT[Obj] = 0
				PropsHandlesT[#PropsHandlesT+1] = {Handle = Obj, Target = 0}
			end
			for i = 1, #PropsHandlesT do
				if PropsHandlesT[i] ~= nil then
					if ENTITY.DOES_ENTITY_EXIST(PropsHandlesT[i].Handle) then
						ENTITY.SET_ENTITY_HAS_GRAVITY(PropsHandlesT[i].Handle, false)
						if PropsHandlesT[i].Target == 0 then
							PropsHandlesT[i].Target = GetAllPedNearestTarget(peds, false, HomingShootsAtPlayers, not HomingShootsAtPeds, not AvoidFocusingFriends, ForbiddenRels)
						end
						if PropsHandlesT[i].Target ~= 0 then
							if ENTITY.DOES_ENTITY_EXIST(PropsHandlesT[i].Target) and not ENTITY.IS_ENTITY_DEAD(PropsHandlesT[i].Target) then
								--if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(PropsHandlesT[i].Handle, PropsHandlesT[i].Target, 17) then
									local TPos = ENTITY.GET_ENTITY_COORDS(PropsHandlesT[i].Target)
									local OPos = ENTITY.GET_ENTITY_COORDS(PropsHandlesT[i].Handle)
									local Rot = v3.lookAt(OPos, TPos)
									local Dir = v3.toDir(Rot)
									local Vel = ENTITY.GET_ENTITY_VELOCITY(PropsHandlesT[i].Handle)
									ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(PropsHandlesT[i].Handle, 1, Dir.x - (Vel.x * Spd), Dir.y - (Vel.y * Spd), Dir.z - (Vel.z * Spd), 0, false, true, false)
								--end
							else
								PropsHandlesT[i].Target = 0
							end
						end
					else
						PropsT[PropsHandlesT[i].Handle] = nil
						PropsHandlesT[i] = nil
					end
				end
			end
			Wait()
		end
	end
end)


--local MyRelTeam = PED.GET_PED_RELATIONSHIP_GROUP_HASH(PlayerPed)
--SelectedTeam = joaat(AiHateRel)
--for i = 1, 30 do
--	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i-1) then
--		if is_bit_set(AvoidPlayerBits, i) then
--			local TargetRel = PED.GET_PED_RELATIONSHIP_GROUP_HASH(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(i-1))
--			PED.SET_RELATIONSHIP_BETWEEN_GROUPS(1, SelectedTeam, TargetRel)
--			PED.SET_RELATIONSHIP_BETWEEN_GROUPS(1, TargetRel, SelectedTeam)
--		else
--			local TargetRel = PED.GET_PED_RELATIONSHIP_GROUP_HASH(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(i-1))
--			PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, SelectedTeam, TargetRel)
--			PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, TargetRel, SelectedTeam)
--		end
--	end
--end
--PED.SET_RELATIONSHIP_BETWEEN_GROUPS(1, SelectedTeam, MyRelTeam)
--PED.SET_RELATIONSHIP_BETWEEN_GROUPS(1, MyRelTeam, SelectedTeam)
--menu.toggle_loop(DevMenu, "Matrix Test", {}, "", function(toggle)

menu.toggle_loop(DevMenu, "Matrix Test", {}, "", function(toggle)
	local PlayerPed = PLAYER.PLAYER_PED_ID()
	local Vel = ENTITY.GET_ENTITY_VELOCITY(PlayerPed)
	local EntRot = ENTITY.GET_ENTITY_ROTATION(PlayerPed, 2)
	local Rot = {x = 0.0, y = 180.0, z = 0.0}
	--local FVect, RVect, UpVect, Vect = v3.new(), v3.new(), v3.new(), v3.new()
	--ENTITY.GET_ENTITY_MATRIX(PlayerPed, FVect, RVect, UpVect, Vect)
	local AdjustedX = Rot.x - EntRot.x
	AdjustedX = (AdjustedX + 180) % 360 - 180
	local AdjustedY = Rot.y - EntRot.y
	AdjustedY = (AdjustedY + 180) % 360 - 180
	local AdjustedZ = Rot.z - EntRot.z
	AdjustedZ = (AdjustedZ + 180) % 360 - 180
	local NewV3_2 = v3.new(AdjustedX, AdjustedY, AdjustedZ)
	local Dir = NewV3_2--:normalise()
	--local Matrix = GetEntityMatrix(EntRot)
	--local x, y, z = RotateVector(1.0, 1.0, 0.0, 0.0, EntRot.x, EntRot.y, EntRot.z)
	--local x, y, z = RotateVector(1.0, 1.0, 0.0, 0.0, Vel.x, Vel.y, Vel.z)
	--local VelDir = Vel.x * RVect.x + Vel.y * RVect.y + Vel.z * RVect.z
	--local VelDirRot = z
	--local VelDir = Vel.x * Matrix[2][1]
	--local SpdDir = ENTITY.GET_ENTITY_SPEED_VECTOR(PlayerPed, true)
	local Txt1 = string.format("%.3f", Dir.x)
	local Txt2 = string.format("%.3f", Dir.y)
	local Txt3 = string.format("%.3f", Dir.z)
	local Txt4 = string.format("%.3f", EntRot.x)
	local Txt5 = string.format("%.3f", EntRot.y)
	local Txt6 = string.format("%.3f", EntRot.z)
	directx.draw_text(0.7, 0.7, "Dir.x: "..Txt1.." Dir.y "..Txt2.." Dir.z: "..Txt3, ALIGN_CENTRE, 1.0, {r = 0.0, g = 1.0 , b = 1.0, a = 1.0}, false)
	directx.draw_text(0.7, 0.75, "EntRot.x: "..Txt4.." EntRot.y "..Txt5.." EntRot.z: "..Txt6, ALIGN_CENTRE, 1.0, {r = 0.0, g = 1.0 , b = 1.0, a = 1.0}, false)
end)


function TimerCount(TimerT)
	local TimeMillis = util.current_time_millis()
	if TimeMillis > TimerT.Timer+100 then
		TimerT.TimerCount = TimerT.TimerCount + 1
		TimerT.Timer = TimeMillis
	end
end

function IsZeroVector(Pos)
	return Pos.x ~= 0 and Pos.y ~= 0 and Pos.z ~= 0
end

function GetEntityMatrix(rot)
    --local rot = GetEntityRotation(element) -- ZXY
    local rx, ry, rz = rot.x, rot.y, rot.z
    rx, ry, rz = math.rad(rx), math.rad(ry), math.rad(rz)
    local matrix = {}
    matrix[1] = {}
    matrix[1][1] = math.cos(rz)*math.cos(ry) - math.sin(rz)*math.sin(rx)*math.sin(ry)
    matrix[1][2] = math.cos(ry)*math.sin(rz) + math.cos(rz)*math.sin(rx)*math.sin(ry)
    matrix[1][3] = -math.cos(rx)*math.sin(ry)
    matrix[1][4] = 1
    
    matrix[2] = {}
    matrix[2][1] = -math.cos(rx)*math.sin(rz)
    matrix[2][2] = math.cos(rz)*math.cos(rx)
    matrix[2][3] = math.sin(rx)
    matrix[2][4] = 1
	
    matrix[3] = {}
    matrix[3][1] = math.cos(rz)*math.sin(ry) + math.cos(ry)*math.sin(rz)*math.sin(rx)
    matrix[3][2] = math.sin(rz)*math.sin(ry) - math.cos(rz)*math.cos(ry)*math.sin(rx)
    matrix[3][3] = math.cos(rx)*math.cos(ry)
    matrix[3][4] = 1
	
    --matrix[4] = {}
    --local Pos = GetEntityCoords(element)
    --matrix[4][1], matrix[4][2], matrix[4][3] = pos.x, pos.y, pos.z - 1.0
    --matrix[4][4] = 1
	
    return matrix
end

function GetOffsetFromEntityInWorldCoords(entity, offX, offY, offZ)
    local m = getEntityMatrix(entity)
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return vector3(x, y, z)
end

-- Função para converter ângulos de Euler para matriz de rotação (ordem XYZ)
function EulerToRotationMatrix(pitch, yaw, roll)
    local cx = math.cos(pitch)
    local sx = math.sin(pitch)
    local cy = math.cos(yaw)
    local sy = math.sin(yaw)
    local cz = math.cos(roll)
    local sz = math.sin(roll)

    return {
        {cy * cz, -cy * sz, sy},
        {sx * sy * cz + cx * sz, -sx * sy * sz + cx * cz, -sx * cy},
        {-cx * sy * cz + sx * sz, cx * sy * sz + sx * cz, cx * cy}
    }
end

-- Função para multiplicar duas matrizes 3x3
function MatrixMultiply(m1, m2)
    local result = {}
    for i = 1, 3 do
        result[i] = {}
        for j = 1, 3 do
            result[i][j] = m1[i][1] * m2[1][j] + m1[i][2] * m2[2][j] + m1[i][3] * m2[3][j]
        end
    end
    return result
end

-- Função para calcular a matriz de rotação inversa
function MatrixInverse(m)
    local determinant = m[1][1] * (m[2][2] * m[3][3] - m[2][3] * m[3][2]) -
                        m[1][2] * (m[2][1] * m[3][3] - m[2][3] * m[3][1]) +
                        m[1][3] * (m[2][1] * m[3][2] - m[2][2] * m[3][1])
    local invDet = 1 / determinant

    return {
        {
            invDet * (m[2][2] * m[3][3] - m[2][3] * m[3][2]),
            invDet * (m[1][3] * m[3][2] - m[1][2] * m[3][3]),
            invDet * (m[1][2] * m[2][3] - m[1][3] * m[2][2])
        },
        {
            invDet * (m[2][3] * m[3][1] - m[2][1] * m[3][3]),
            invDet * (m[1][1] * m[3][3] - m[1][3] * m[3][1]),
            invDet * (m[1][3] * m[2][1] - m[1][1] * m[2][3])
        },
        {
            invDet * (m[2][1] * m[3][2] - m[2][2] * m[3][1]),
            invDet * (m[1][2] * m[3][1] - m[1][1] * m[3][2]),
            invDet * (m[1][1] * m[2][2] - m[1][2] * m[2][1])
        }
    }
end

-- Função para obter a matriz de rotação da entidade
function GetEntityRotationMatrix(entity)
    local rot = ENTITY.GET_ENTITY_ROTATION(entity, 5)
    return EulerToRotationMatrix(math.rad(rot.x), math.rad(rot.y), math.rad(rot.z))
end

-- Função para converter uma matriz de rotação para quaternion
function RotationMatrixToQuaternion(m)
    local w = math.sqrt(1 + m[1][1] + m[2][2] + m[3][3]) / 2
    local x = (m[3][2] - m[2][3]) / (4 * w)
    local y = (m[1][3] - m[3][1]) / (4 * w)
    local z = (m[2][1] - m[1][2]) / (4 * w)
    return {w = w, x = x, y = y, z = z}
end

-- Função para calcular a velocidade angular a partir da diferença de quaternions
function QuaternionToAngularVelocity(q)
    local theta = 2 * math.acos(q.w)
    local sinTheta = math.sqrt(1 - q.w * q.w)
    if sinTheta < 0.001 then
        return {x = q.x * theta, y = q.y * theta, z = q.z * theta}
    else
        return {x = q.x / sinTheta * theta, y = q.y / sinTheta * theta, z = q.z / sinTheta * theta}
    end
end

-- Função principal para girar a entidade até a rotação desejada usando matrizes de rotação
function RotateEntityToTargetRotation(entity, targetRotation, interpolationFactor, normalise)
    interpolationFactor = interpolationFactor or 0.1 -- Fator de interpolação para suavizar a rotação

    -- Obtenha a matriz de rotação atual da entidade
    local currentRotationMatrix = GetEntityRotationMatrix(entity)

    -- Calcule a matriz de rotação alvo a partir dos ângulos de Euler desejados
    local targetRotationMatrix = EulerToRotationMatrix(math.rad(targetRotation.x), math.rad(targetRotation.y), math.rad(targetRotation.z))

    -- Calcule a matriz de rotação delta
    local deltaRotationMatrix = MatrixMultiply(targetRotationMatrix, MatrixInverse(currentRotationMatrix))
    -- Converta a matriz de rotação delta para quaternion
    local deltaQuaternion = RotationMatrixToQuaternion(deltaRotationMatrix)

    -- Converta a diferença de quaternion em velocidade angular
    local angularVelocity = QuaternionToAngularVelocity(deltaQuaternion)

    -- Interpole a velocidade angular para suavizar a rotação
    angularVelocity.x = angularVelocity.x * interpolationFactor
    angularVelocity.y = angularVelocity.y * interpolationFactor
    angularVelocity.z = angularVelocity.z * interpolationFactor
	
	if normalise then
		angularVelocity = v3.new(angularVelocity.x, angularVelocity.y, angularVelocity.z)
		angularVelocity:normalise()
		angularVelocity:mul(interpolationFactor)
	end

    -- Aplique a velocidade angular à entidade
    ENTITY.SET_ENTITY_ANGULAR_VELOCITY(entity, angularVelocity.x, angularVelocity.y, angularVelocity.z)
end

-- Função para calcular a nova rotação X e Y baseada na rotação Z e inclinação desejada
function calculateTiltRotationFromUserInput(rotX, rotY, rotZ, tiltDegrees)
    -- Converter a rotação Z para radianos
    local radZ = math.rad(rotZ)

    -- Calcular a inclinação (tilt) desejada
    local tiltX = tiltDegrees * math.cos(radZ)
    local tiltY = tiltDegrees * math.sin(radZ)

    -- Calcular a nova rotação X e Y
    local newRotX = rotX + tiltX
    local newRotY = rotY + tiltY

    -- Retornar a nova rotação X, Y e Z
    return {x = newRotX, y = newRotY, z = rotZ}
end

function angleDifference(target, current)
    local diff = target - current
    if diff > 180 then
        diff = diff - 360
    elseif diff < -180 then
        diff = diff + 360
    end
    return diff
end

-- Função para converter graus para radianos
function deg2rad(deg)
    return deg * math.pi / 180.0
end

-- Função para converter radianos para graus
function rad2deg(rad)
    return rad * 180.0 / math.pi
end

-- Função para limitar o ângulo no intervalo de -180 a 180 graus
function wrap180(deg)
    while deg <= -180.0 do deg = deg + 360.0 end
    while deg > 180.0 do deg = deg - 360.0 end
    return deg
end

-- Função para converter rotação XYZ para ZYX
function convertRotationXYZtoZYX(rotX, rotY, rotZ)
    -- Converter para radianos
    local x = deg2rad(rotX)
    local y = deg2rad(rotY)
    local z = deg2rad(rotZ)

    -- Matriz de rotação para XYZ
    local cosX = math.cos(x)
    local sinX = math.sin(x)
    local cosY = math.cos(y)
    local sinY = math.sin(y)
    local cosZ = math.cos(z)
    local sinZ = math.sin(z)

    local Rxyz = {
        {cosY * cosZ, -cosY * sinZ, sinY},
        {sinX * sinY * cosZ + cosX * sinZ, -sinX * sinY * sinZ + cosX * cosZ, -sinX * cosY},
        {-cosX * sinY * cosZ + sinX * sinZ, cosX * sinY * sinZ + sinX * cosZ, cosX * cosY}
    }

    -- Extrair ângulos ZYX da matriz de rotação
    local rotZ2 = math.atan2(Rxyz[2][1], Rxyz[1][1])
    local rotY2 = math.asin(-Rxyz[3][1])
    local rotX2 = math.atan2(Rxyz[3][2], Rxyz[3][3])

    -- Converter de volta para graus
    rotX2 = rad2deg(rotX2)
    rotY2 = rad2deg(rotY2)
    rotZ2 = rad2deg(rotZ2)

    -- Ajustar ângulos para o intervalo de -180 a 180 graus
    rotX2 = wrap180(rotX2)
    rotY2 = wrap180(rotY2)
    rotZ2 = wrap180(rotZ2)

    return {x = rotX2, y = -rotY2, z = rotZ2}
end

-- Função para adicionar duas rotações e retornar a rotação normalizada
function addRotation(rot1, rot2)
    local result = rot1 + rot2
    return wrap180(result)
end

-- Função para subtrair duas rotações e retornar a rotação normalizada
function subtractRotation(rot1, rot2)
    local result = rot1 - rot2
    return wrap180(result)
end

function SetEntitySpeedToCoord(Entity, CoordTarget, Mul, IgnoreX, IgnoreY, IgnoreZ, AddX, AddY, AddZ, Normalise, Relative)
    local OPos = ENTITY.GET_ENTITY_COORDS(Entity)
	local NewV3 = {
        x = (CoordTarget.x - OPos.x) * Mul,
        y = (CoordTarget.y - OPos.y) * Mul,
        z = (CoordTarget.z - OPos.z) * Mul
    }
	local Vel = ENTITY.GET_ENTITY_VELOCITY(Entity)
    if IgnoreX then
        NewV3.x = Vel.x
    end
    if IgnoreY then
        NewV3.y = Vel.y
    end
    if IgnoreZ then
        NewV3.z = Vel.z
    end
    if Normalise then
        NewV3 = v3.new(NewV3.x, NewV3.y, NewV3.z)
		if DistanceBetween(OPos.x, OPos.y, OPos.z, CoordTarget.x, CoordTarget.y, CoordTarget.z) * 0.5 > 1.0 then
			NewV3:normalise()
			NewV3:mul(Mul)
		end
    end
    local MoreX, MoreY, MoreZ = AddX, AddY, AddZ
    if Relative then
        local FVect, RVect, UpVect, Vect = v3.new(), v3.new(), v3.new(), v3.new()
        ENTITY.GET_ENTITY_MATRIX(Entity, FVect, RVect, UpVect, Vect)
        MoreX = (FVect.x * AddY) + (RVect.x * AddX) + (UpVect.x + AddZ)
        MoreY = (FVect.y * AddY) + (RVect.y * AddX) + (UpVect.y + AddZ)
        MoreZ = (FVect.z * AddY) + (RVect.z * AddX) + (UpVect.z + AddZ)
    end
    ENTITY.SET_ENTITY_VELOCITY(Entity, (NewV3.x) + MoreX, (NewV3.y) + MoreY, (NewV3.z) + MoreZ)
end

function SnakeClearLosCheck(Veh, Veh2, Offset)
	local Bool = false
	local Pos = ENTITY.GET_ENTITY_COORDS(Veh)
	local Vel = ENTITY.GET_ENTITY_VELOCITY(Veh)
	local Spd = ENTITY.GET_ENTITY_SPEED(Veh)
	--Pos.x = Pos.x + Vel.x
	--Pos.y = Pos.y + Vel.y
	--Pos.z = Pos.z + Vel.z
	local HitCoords, DidHit = ShapeTestNav(Veh, Pos, Offset, -1)
	if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(Veh, Veh2, 17)
	and not DidHit 
	--and not MISC.IS_POSITION_OCCUPIED(Pos.x, Pos.y, Pos.z, Spd, false, true, Spd > 10.0, true, false, Veh, true)
	--and not ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(Veh) then
	then
		Bool = true
	end
	return Bool
end

function GetPositionCircle(Center, Radius, Angle)
	local NewPoint = {
		x = Center.x + Radius * math.cos(math.rad(Angle)),
		y = Center.y + Radius * math.sin(math.rad(Angle)),
		z = Center.z
	}
	return NewPoint
end

function RequestModelFunc(Model)
    STREAMING.REQUEST_MODEL(Model)
    return STREAMING.HAS_MODEL_LOADED(Model)
end

function math.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function InterpolateRotWithLimit(CurRot, TargetRot, DeltaTime, Limit)
    local RotDifference = {
        x = TargetRot.x - CurRot.x,
        y = TargetRot.y - CurRot.y,
        z = TargetRot.z - CurRot.z,
    }
    
    RotDifference.x = (RotDifference.x + 180) % 360 - 180
    RotDifference.y = (RotDifference.y + 180) % 360 - 180
    RotDifference.z = (RotDifference.z + 180) % 360 - 180

    local LimitedRotation = {
        x = math.clamp(RotDifference.x, -Limit, Limit),
        y = math.clamp(RotDifference.y, -Limit, Limit),
        z = math.clamp(RotDifference.z, -Limit, Limit)
    }
    local NewV = {
        x = wrap180(CurRot.x + (LimitedRotation.x * DeltaTime)),
        y = wrap180(CurRot.y + (LimitedRotation.y * DeltaTime)),
        z = wrap180(CurRot.z + (LimitedRotation.z * DeltaTime))
    }
    return NewV
end

vect = {}
vect.new = function(x,y,z)
    return {['x'] = x, ['y'] = y, ['z'] = z or 0}
end

vect.subtract = function(a,b)
	return vect.new(a.x - b.x, a.y - b.y, a.z - b.z)
end

vect.add = function(a,b)
	return vect.new(a.x + b.x, a.y + b.y, a.z + b.z)
end

vect.mag = function(a)
	return math.sqrt(a.x^2 + a.y^2 + a.z^2)
end

vect.norm = function(a)
    local mag = vect.mag(a)
    return vect.mult(a, 1/mag)
end

vect.mult = function(a,b)
	return vect.new(a.x*b, a.y*b, a.z*b)
end

-- returns the dot product of two vectors
vect.dot = function (a,b)
	return (a.x * b.x + a.y * b.y + a.z * b.z)
end

--returns the angle between two vectors
vect.angle = function (a,b)
	return math.acos(vect.dot(a,b) / ( vect.mag(a) * vect.mag(b) ))
end

-- returns the distance between two coords
vect.dist = function(a,b)
    return vect.mag(vect.subtract(a, b))
end

vect.tostring = function(a)
    return "{" .. a.x .. ", " .. a.y .. ", " .. a.z .. "}"
end

function atan2(y, x)
	if x > 0 then
		return ( math.atan(y / x) )
	end
	if x < 0 and y >= 0 then
		return ( math.atan(y / x) + math.pi )
	end
	if x < 0 and y < 0 then
		return ( math.atan(y / x) - math.pi )
	end
	if x == 0 and y > 0 then
		return ( math.pi / 2 )
	end
	if x == 0 and y < 0 then
		return ( - math.pi / 2 )
	end
	if x == 0 and y == 0 then
		return 0 -- actually 'tan' is not defined in this case
	end
end

function GET_ROTATION_FROM_DIRECTION(v)
	local mag = vect.mag(v)
	local rotation = {
		x = math.asin(v.z / mag) * (180 / math.pi),
		y =   0.0,
		z = - atan2(v.x, v.y) * (180 / math.pi)
	}
	return rotation
end

function V3_LookAt(Start, Target)
	local ab = vect.subtract(Target, Start)
	local rot = GET_ROTATION_FROM_DIRECTION(ab)
    return rot
end
