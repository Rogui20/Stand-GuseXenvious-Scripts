util.require_natives(1676318796)

Wait = util.yield
joaat = util.joaat
Print = util.toast
json = require "json"

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
		if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
			if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
				TASK.TASK_ACHIEVE_HEADING(peds, TaskArgs.OperationHeading, 10000)
				OperationT[peds].TaskStatus = 2
			end
		end
	end
end
TaskStatusFunctionsT[2+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 2 then
		if not PED.IS_PED_RAGDOLL(peds) then
			if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
			if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
				PED.SET_PED_USING_ACTION_MODE(peds, false, -1, "DEFAULT_ACTION")
				PED.SET_PED_MOVEMENT_CLIPSET(peds, "move_ped_crouched", 0.55)
				PED.SET_PED_STRAFE_CLIPSET(peds, "move_ped_crouched_strafing")
			end
		end
		if TaskArgs.ShootsT[peds] == nil then
			if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
		if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
		if OperationT[peds].Target == nil then
			if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
				local PlayerPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
				TASK.TASK_COMBAT_HATED_TARGETS_IN_AREA(peds, PlayerPos.x, PlayerPos.y, PlayerPos.z, 1000.0, 16)
				OperationT[peds].TaskStatus = 13
			end
		else
			if not ENTITY.DOES_ENTITY_EXIST(OperationT[peds].Target) and not ENTITY.IS_ENTITY_DEAD(OperationT[peds].Target) then
				if not ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, OperationT[peds].Target, 17) then
					OperationT[peds].TaskStatus = 13
				end
			else
				OperationT[peds].Target = nil
			end
		end
	end
end
TaskStatusFunctionsT[13+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 13 then
		local Target = PED.GET_PED_TARGET_FROM_COMBAT_PED(peds, 0)
		if Target ~= 0 then
			OperationT[peds].Target = Target
			if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
			if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
						if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
									if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
							if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
			if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
					if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
			if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
			if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
								if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
			OperationT[peds].Target = Target
			if not ENTITY.IS_ENTITY_DEAD(Target) and not PED.IS_PED_DEAD_OR_DYING(Target) and ENTITY.DOES_ENTITY_EXIST(Target) then
				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
					local VehHandle = OperationT[peds].VehHandle
					if not PED.IS_PED_IN_ANY_VEHICLE(peds, false) then
						if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, Target, 17) then
							local BonePos = PED.GET_PED_BONE_COORDS(Target, 0x322C --[[head]], 0.0, 0.0, 0.0)
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
				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
					OperationT[peds].Target = nil
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
					TASK.CLEAR_PED_TASKS(peds)
				end
			end
		else
			if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
				OperationT[peds].Target = nil
				PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
			end
		end
	end
end
TaskStatusFunctionsT[26+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 26 then
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
				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
			if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
			if not ENTITY.IS_ENTITY_DEAD(Target) and not PED.IS_PED_DEAD_OR_DYING(Target) and ENTITY.DOES_ENTITY_EXIST(Target) then
				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
						if ENTITY.DOES_ENTITY_EXIST(VehHandle) and VehHandle ~= PlayerVeh then
							local VehClass = VEHICLE.GET_VEHICLE_CLASS(VehHandle)
							if VehClass ~= 15 and VehClass ~= 16 then
								local VehPos = ENTITY.GET_ENTITY_COORDS(VehHandle)
								local TargetPos = ENTITY.GET_ENTITY_COORDS(Target)
								local Distance = MISC.GET_DISTANCE_BETWEEN_COORDS(TargetPos.x, TargetPos.y, TargetPos.z, VehPos.x, VehPos.y, VehPos.z, true)
								if TaskArgs.CopsRushWithTP then
									if Distance > 300.0 then
										if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(VehHandle) then
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
									if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(VehHandle) then
										if EntSpeed.y > 3.0 and EntSpeed.y < 50.0 then
											ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, NormZ * 0.005 * EntSpeed.y, (1.0 - NormZAbs) * 0.01 * EntSpeed.y, 0.0, 0, true, true, false)
										end
										local ForceZ = 0.0
										EntSpeed = ENTITY.GET_ENTITY_SPEED_VECTOR(VehHandle, true)
										if ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(VehHandle) > 1.1 then --or EntSpeed.x > 1.0 or EntSpeed.x < -1.0 then
											ForceZ = -1.50
										end
										ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, 0.0, ForceZ, ForceZ, 0, false, true, false)
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
					OperationT[peds].Target = Target
				end
			else
				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
					OperationT[peds].Target = nil
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
					TASK.CLEAR_PED_TASKS(peds)
				end
			end
		else
			if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
				OperationT[peds].Target = nil
				PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
			end
		end
	end
end
TaskStatusFunctionsT[29+1] = function(OperationT, TaskArgs, peds, PlayerPed, PlayerVeh)
	if OperationT[peds].TaskStatus == 29 then
		if OperationT[peds].Target ~= 0 then
			if not ENTITY.IS_ENTITY_DEAD(OperationT[peds].Target) and not PED.IS_PED_DEAD_OR_DYING(OperationT[peds].Target) and ENTITY.DOES_ENTITY_EXIST(OperationT[peds].Target) then
				if PED.IS_PED_SHOOTING(peds) then
					OperationT[peds].TaskStatus = 28
				end
			else
				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
		if OperationT[peds].Target ~= 0 and OperationT[peds].TaskAttempts < 10 then
			if not ENTITY.IS_ENTITY_DEAD(OperationT[peds].Target) and not PED.IS_PED_DEAD_OR_DYING(OperationT[peds].Target) and ENTITY.DOES_ENTITY_EXIST(OperationT[peds].Target) then
				if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, OperationT[peds].Target, 17) then
					if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
						OperationT[peds].TaskStatus = 28
						PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
						TASK.CLEAR_PED_TASKS(peds)
					end
				end
			else
				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
					OperationT[peds].TaskStatus = 28
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
					TASK.CLEAR_PED_TASKS(peds)
					OperationT[peds].Target = nil
					OperationT[peds].TaskAttempts = nil
				end
			end
		else
			if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
		if OperationT[peds].Target ~= 0 then
			if not ENTITY.IS_ENTITY_DEAD(OperationT[peds].Target) and not PED.IS_PED_DEAD_OR_DYING(OperationT[peds].Target) and ENTITY.DOES_ENTITY_EXIST(OperationT[peds].Target) then
				if CopsAimAtHead then
					PED.SET_PED_RESET_FLAG(OperationT[peds].Target, 108, true)
				end
				if not ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, OperationT[peds].Target, 17) or
				ENTITY.IS_ENTITY_AT_ENTITY(peds, OperationT[peds].Target, MinRadius, MinRadius, MinRadius, false, true, false) then
					if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
						OperationT[peds].TaskStatus = 28
						PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
						TASK.CLEAR_PED_TASKS(peds)
					end
				end
			else
				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
				if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
					OperationT[peds].TaskStatus = 25
					TASK.CLEAR_PED_TASKS(peds)
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(peds, false)
				end
			end
		end
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

local CayoCopsGlobalAddr = 2657704+1+442 --463

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
local CanSetModels = false
local RelPlayersBitsAddr = SplitGlobals("Global_2657704[PLAYER::PLAYER_ID() /*463*/].f_253")
local RelAddrs = {}
if NETWORK.GET_ONLINE_VERSION() == "1.67" then
	--Addr = 0x7FF66E4E63F0
	for i = 0, 29 do
		RelAddrs[i+1] = memory.script_global(RelPlayersBitsAddr + 463 * i)
	end
	Addr = memory.scan("C0 C0 00 00 0C C2 00 00 0C 42 00 00 F0 41 00 00 B4 41 00 00 0C 42")
	--Print(string.format("%X", Addr))
	--util.copy_to_clipboard(string.format("%X", Addr))
	if Addr ~= 0 then
		Addr = Addr+38
		Addr2 = memory.read_long(Addr)
		Addr3 = memory.read_long(Addr2+0x08)
		police3_FirstAddr = memory.read_long(Addr3+0xB0)
		local AddressToScan = police3_FirstAddr - 8 * 1000
		local MaxFoundAddrs = 7
		for i = 0, 2000 do
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
	"tug"
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
	"hc_gunman"
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
	"Space Rangers"
}

local CopSettingsMenu = menu.list(menu.my_root(), "Cop Settings", {}, "Which settings apply to cops.")
local CopModelSettings = nil
local RandomModels = false
local HasAppliedRandomModels = false
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
	menu.list_action(CopModelSettings, "Model Presets", {"copmodelpresets"}, "Set all models at once with defined presets.", ModelPresetsT, function(OnChange)
		if OnChange == 1 then
			SetCopModels("dune3", "mp_m_bogdangoon", "caracara", "savage", "csb_bogdan", "mp_m_bogdangoon", "dune3", "technical3")
		end
		if OnChange == 2 then
			SetCopModels("police2", "s_m_y_cop_01", "fbi", "buzzard", "s_m_y_swat_01", "s_m_y_cop_01", "police2", "fbi")
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
	end)
end
local AllyCopSettingsMenu = menu.list(CopSettingsMenu, "Ally Cop Settings", {}, "Which settings apply to ally cops.")
local HostileCopSettingsMenu = menu.list(CopSettingsMenu, "Hostile Cop Settings", {}, "Which settings apply to hostile cops.")
local CopWeaponsMenu = menu.list(CopSettingsMenu, "Cop Weapon Loadout", {}, "Weapons settings for cops.")
local AdvancedSettingsMenu = menu.list(CopSettingsMenu, "Advanced Settings", {}, "")

local CopsAttackEveryone = false
menu.toggle(HostileCopSettingsMenu, "Cops Attack Everyone", {}, "If cops see a player, will start attacking.", function(toggle)
	CopsAttackEveryone = toggle
end, CopsAttackEveryone)

local MakeCopsAttackEveryone = false
menu.toggle(HostileCopSettingsMenu, "Make Cops Attack Everyone", {}, "Cops will attack the nearest player, no need to see the player to start the attack.", function(toggle)
	MakeCopsAttackEveryone = toggle
end, MakeCopsAttackEveryone)

local ZombieMode = false
menu.toggle(HostileCopSettingsMenu, "Zombie Mode", {}, "", function(toggle)
	ZombieMode = toggle
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
local SetDefaultColours = true
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
local MiscCopSettings = menu.list(CopSettingsMenu, "Misc Settings", {}, "")
local BulletTracerOverride = false
menu.toggle(MiscCopSettings, "Bullet Tracer Override", {}, "Railgun tracer.", function(toggle)
	BulletTracerOverride = toggle
	local OldAssetNames = {"bullet_tracer", "bullet_tracer_jet", "bullet_tracer_mg", "bullet_shotgun_tracer"}
	local NewAssetName = "bullet_tracer_railgun"
	if not BulletTracerOverride then
		for i = 1, #OldAssetNames do
			GRAPHICS.RESET_PARTICLE_FX_OVERRIDE(OldAssetNames[i])
		end
	end
	while BulletTracerOverride do
		for i = 1, #OldAssetNames do
			GRAPHICS.SET_PARTICLE_FX_OVERRIDE(OldAssetNames[i], NewAssetName)
		end
		Wait(10000)
	end
end, BulletTracerOverride)

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
end, CopsCanAttackPlayers)

local AvoidAttackingFriends = true
menu.toggle(AllyCopSettingsMenu, "Avoid Attacking Friends", {}, "Automatically will avoid attacking people of your CEO or Biker Club.", function(toggle)
	AvoidAttackingFriends = toggle
end, AvoidAttackingFriends)

local AvoidAttackSpeficPlayers = false
menu.toggle(AllyCopSettingsMenu, "Avoid Attacking Specific Players", {}, "Works with avoiding attack friends toggled.", function(toggle)
	AvoidAttackSpeficPlayers = toggle
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
local CopsRushWithTP = false
menu.toggle(AllyCopSettingsMenu, "Cops Rush With Teleport", {}, "Works with custom tasks keys. Will teleport if far from target.", function(toggle)
	CopsRushWithTP = toggle
end, CopsRushWithTP)
menu.toggle(AllyCopSettingsMenu, "Set Cops Aim At Head", {}, "One hit kill.", function(toggle)
	CopsAimAtHead = toggle
end, CopsAimAtHead)
local MiscCustomTasksMenu = menu.list(AllyCopSettingsMenu, "Misc Custom Behaviour", {}, "")
local CopsShootWhereYouShoot = false
menu.toggle(MiscCustomTasksMenu, "Cops Shoot Where You Shoot", {}, "", function(toggle)
	CopsShootWhereYouShoot = toggle
end, CopsShootWhereYouShoot)
local CopsShootWhereYouAim = false
menu.toggle(MiscCustomTasksMenu, "Cops Shoot Where You Aim", {}, "", function(toggle)
	CopsShootWhereYouAim = toggle
end, CopsShootWhereYouAim)
local CopsRushedFollow = true
menu.toggle(MiscCustomTasksMenu, "Cops Rushed Follow", {}, "", function(toggle)
	CopsRushedFollow = toggle
end, CopsRushedFollow)
--menu.list_select(AllyCopSettingsMenu, "Cop Relationship Type", {"allycoprelationship"}, "Set if cops will be able to attack players or only npcs.", table<int, table> options, 1, function on_change)

local RenderCopCount = true
menu.toggle(menu.my_root(), "Show Cop Count HUD", {}, "", function(toggle)
	RenderCopCount = toggle
end, RenderCopCount)

local CopsAreAllies = true
menu.toggle(menu.my_root(), "Make Cops As Allies", {}, "", function(toggle)
	CopsAreAllies = toggle
end, CopsAreAllies)

local CopCustomRelMenu = menu.list(CopSettingsMenu, "Custom Relationship Settings", {}, "For DEVs.")

local KnownCustomRelationships = {
	"relRescueContactPlayer",
	"relHeadHunterPlayer"
}

local CustomRelText = "relRescueContactPlayer"

menu.list_select(CopCustomRelMenu, "Known Custom Rels", {"setknowncustomrel"}, "Known custom relationships list.", KnownCustomRelationships, 1, function(on_change)
	CustomRelText = joaat(KnownCustomRelationships[on_change])
end)

local CopsCustomRelationship = false
menu.toggle(CopCustomRelMenu, "Set Cops Custom Relationship", {}, "", function(toggle)
	CopsCustomRelationship = toggle
end, CopsCustomRelationship)

menu.text_input(CopCustomRelMenu, "Custom Relationship Name", {"copcustomrelationship"}, "Write a missing custom relationship name to set.", function(on_change)
	CustomRelText = on_change
end)
local SelectedTaskTXT = {
	{TXT = "Everyone crouch near", ColourG = 255, Task = 1},
	{TXT = "Make half go to pointed area", ColourG = 255, Task = 5},
	{TXT = "TP all cops to me", ColourG = 255, Task = 10},
	{TXT = "Call to enter my vehicle", ColourG = 255, Task = 3},
	{TXT = "Call to exit my vehicle", ColourG = 255, Task = 4},
	{TXT = "Closer cops exit vehicle", ColourG = 255, Task = 6},
	{TXT = "Call to stay above veh", ColourG = 255, Task = 8},
	{TXT = "Attack nearest ped in screen", ColourG = 255, Task = 7},
	{TXT = "Rush to enemies", ColourG = 255, Task = 2},
	{TXT = "Rushed combat mode", ColourG = 255, Task = 9},
	{TXT = "Super rushed combat mode", ColourG = 255, Task = 11}
}
local AvailableTasks = {
	1, 5, 10, 3, 4, 6, 8, 7, 2, 9, 11
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
	end
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
					TaskStatus = 32, VehHandle = Veh, FVect = FVect, RVect = RVect, UpVect = UpVect,
					Vect = Vect, IsPilot = IsPilot
				}
			end
		end
	end
}

local NavTest = false
local NavZ = 0.0
local NavRightOffset = 5.0
local Crouch = false
local RelHashBackupAddr = SplitGlobals("Global_1837231.f_6")
local ApplyCopSettings = false
menu.toggle(menu.my_root(), "Apply Cop Settings", {}, "", function(toggle)
	ApplyCopSettings = toggle
	local CopAIMissionRelHash = -1235282855
	local EnemyAIMissionRelHash = 671184796
	local FriendlyAll = -607974925
	if not ApplyCopSettings then
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
								while not NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) and Tick < 1000 do
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
								while not NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehs) and Tick < 1000 do
									Tick = Tick + 1
									Wait()
								end
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
	if ApplyCopSettings then
		PlayerID = PLAYER.PLAYER_ID()
		local RelHashBackup = memory.read_int(memory.script_global(RelHashBackupAddr))
		local HasSetHate = false
		local FreemodeBackupHeliAddr = memory.script_local("freemode", 6916)
		local TriesTick = 0
		local TasksT = {}
		local OperationT = {}
		local TaskNum = 1
		local SelectedTask = SelectedTaskTXT[TaskNum].Task
		local OperationsTable = {}
		local NumCreatedTasks = 11
		local FoundCopVehs = {}
		local CopVehsT = {}
		local OwnedCopVehsT = {}
		local PedsT = {}
		local IterationsNumber = 0
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
			CopsRushWithTP = CopsRushWithTP
		}
		local NavsT = {}
		local HostileNum = 1
		while ApplyCopSettings do
			local PlayerPed = PLAYER.PLAYER_PED_ID()
			local IsInVeh = PED.IS_PED_IN_ANY_VEHICLE(PlayerPed, false)
			TaskArgs.IsPlayerShooting = PED.IS_PED_SHOOTING(PlayerPed)
			local PlayerVeh = PED.GET_VEHICLE_PED_IS_IN(PlayerPed, false)
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
				local SwitchReleased = PAD.IS_CONTROL_JUST_RELEASED(0, 47)
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
				TaskArgs.OperationButton = PAD.IS_CONTROL_JUST_PRESSED(0, 46)
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
				else
					BlipColorToGive = 1
					if CopsAttackEveryone or ZombieMode then
						if PED.DOES_RELATIONSHIP_GROUP_EXIST(joaat(AiHateRel)) then
							SelectedTeam = joaat(AiHateRel)
						else
							SelectedTeam = joaat("COP")
						end
					else
						SelectedTeam = joaat("COP")
					end
				end
			end
			TaskArgs.RelHash = SelectedTeam
			if not PED.DOES_RELATIONSHIP_GROUP_EXIST(FriendlyAll) then
				HasSetHate = false
			end
			if IterationsNumber == 0 then
				PedsT = entities.get_all_peds_as_handles()
			end
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
							if SelectedTask == 9 or SelectedTask == 11 then
								if not ENTITY.IS_ENTITY_DEAD(peds) and not PED.IS_PED_DEAD_OR_DYING(peds) then
									local RelType = PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PlayerPed)
									local CombatTarget = PED.GET_PED_TARGET_FROM_COMBAT_PED(peds, 0)
									if RelType == 5 or CombatTarget == PlayerPed then
										if ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 200.0, 200.0, 3000.0, false, true, false) then
											--if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PlayerPed, 17) then
												FoundHostiles[#FoundHostiles+1] = peds
											--end
										end
									end
								end
							end
						end
					end
				end
			end
			if RenderCopCount then
				directx.draw_text(0.7, 0.7, "Cops "..MissionCopCount, ALIGN_CENTRE, 1.0, {r = 0, g = 255 , b = 255, a = 200}, false)
			end
			for index, peds in pairs(PedsT) do
				if peds ~= PlayerPed then
					if ENTITY.DOES_ENTITY_EXIST(peds) then
						if EditedDamageEnts[peds] ~= nil then
							if ENTITY.IS_ENTITY_DEAD(peds) or PED.IS_PED_A_PLAYER(peds) or PED.IS_PED_DEAD_OR_DYING(peds) then
								EditedDamageEnts[peds] = nil
							end
						end
						if not PED.IS_PED_A_PLAYER(peds) then
							local EntScript = ENTITY.GET_ENTITY_SCRIPT(peds, 0)
							if EntScript == "GB_HEADHUNTER" or EntScript == "GB_BIKER_RESCUE_CONTACT" or "FM_Mission_Controller"
							or "FM_Mission_Controller_2020" then
								if EditedDamageEnts[peds] == nil then
									if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
											OperationT[peds].Target = FoundHostiles[HostileNum]
											HostileNum = HostileNum + 1
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
													if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
														if DECORATOR.DECOR_SET_INT(peds, "Casino_Game_Info_Decorator", 31) then
															ENTITY.SET_ENTITY_AS_MISSION_ENTITY(peds, false, true)
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
																	CopVehsT[#CopVehsT+1] = {Handle = Veh, HasSetToMissionEnt = false, Passengers = Peds}
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
															if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																DECORATOR.DECOR_SET_INT(peds, "Casino_Game_Info_Decorator", 31)
																DecorApplied = true
															end
														end
													end
												end
												if DecorApplied then
													MissionCopCount = MissionCopCount + 1
													NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds)
													PED.SET_PED_RELATIONSHIP_GROUP_HASH(peds, SelectedTeam)
													--PED.SET_PED_FLEE_ATTRIBUTES(peds, 512, true)
													if not ZombieMode then
														WEAPON.GIVE_WEAPON_TO_PED(peds, joaat("weapon_pistol"), 99999, false, false)
														if EnableWeaponSettsForCops then
															GiveCorrectWeaponsToPed(peds)
														end
														if RandomWeaponComponents then
															Set_Weapon_Components(peds)
														end
														if IsCopModel then
															SetPedCombatAbilities(peds)
															PED.SET_PED_FIRING_PATTERN(peds, joaat("FIRING_PATTERN_FULL_AUTO"))
														end
														if EliteCops then
															ENTITY.SET_ENTITY_MAX_HEALTH(peds, 300)
															PED.SET_PED_MAX_HEALTH(peds, 300)
															ENTITY.SET_ENTITY_HEALTH(peds, 300)
															PED.SET_PED_SUFFERS_CRITICAL_HITS(peds, false)
															PED.SET_RAGDOLL_BLOCKING_FLAGS(peds, 1)
														end
														if CopsShootWhereYouShoot or CopsShootWhereYouAim or UseCustomsTasksKeys then
															PED.SET_PED_FIRING_PATTERN(peds, joaat("FIRING_PATTERN_FULL_AUTO"))
															PED.SET_PED_CONFIG_FLAG(peds, 113, false)
															PED.SET_PED_CONFIG_FLAG(peds, 208, true)
															PED.SET_PED_COMBAT_ATTRIBUTES(peds, 2, true)
														end
													else
														ENTITY.SET_ENTITY_PROOFS(peds, false, false, false, false, true, false, false, false)
														WEAPON.REMOVE_ALL_PED_WEAPONS(peds, false)
														SetPedCombatAbilities(peds)
														PED.SET_PED_SUFFERS_CRITICAL_HITS(peds, false)
														PED.SET_RAGDOLL_BLOCKING_FLAGS(peds, 1)
														SetPedHealth(peds, 400)
														WEAPON.GIVE_WEAPON_TO_PED(peds, joaat("weapon_knife"), 99999, false, false)
													end
													local Veh = PED.GET_VEHICLE_PED_IS_IN(peds, false)
													if Veh ~= 0 then
														if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds then
															--if IsArmoredVehModel(Veh) then
																--PED.SET_PED_COMBAT_ATTRIBUTES(peds, 52, true)
																PED.SET_PED_COMBAT_ATTRIBUTES(peds, 53, true)
															--end
														end
													end
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
													local Veh = PED.GET_VEHICLE_PED_IS_IN(peds, false)
													if Veh ~= 0 then
														if Veh ~= PlayerVeh then
															if UpgradeCopCars then
																if DECORATOR.DECOR_GET_INT(Veh, "Casino_Game_Info_Decorator") ~= 31 then
																	NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(Veh)
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
																		DECORATOR.DECOR_SET_INT(Veh, "Casino_Game_Info_Decorator", 31)
																	end
																end
															end
															if SetCopPassengersIntoTurretSeat then
																local HasSetInTurretSeat = false
																if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) ~= peds then
																	for i = -1, 9 do
																		if not HasSetInTurretSeat then
																			if VEHICLE.IS_TURRET_SEAT(Veh, i) then
																				if VEHICLE.IS_VEHICLE_SEAT_FREE(Veh, i, true) then
																					HasSetInTurretSeat = true
																					NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds)
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
									if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
										NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds)
										PED.SET_PED_RELATIONSHIP_GROUP_HASH(peds, SelectedTeam)
									end
									if PutCopsIntoPlayerVeh then
										if PlayerVeh ~= 0 then
											for i = -1, 9 do
												if VEHICLE.IS_VEHICLE_SEAT_FREE(PlayerVeh, i, true) then
													if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
														PED.SET_PED_INTO_VEHICLE(peds, PlayerVeh, i)
													end
												end
											end
										end
									end
								end
								if ENTITY.IS_ENTITY_DEAD(peds) then
									if not IgnoreDeadCops then
										if DeadPeds[peds] == nil then
											util.create_thread(function()
												DeadPeds[peds] = {}
												Wait(10000)
												while not NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) and ENTITY.DOES_ENTITY_EXIST(peds) do
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
										if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
									if CanAddBlip then
										if not HUD.DOES_PED_HAVE_AI_BLIP(peds) then
											NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds)
											HUD.SET_PED_HAS_AI_BLIP_WITH_COLOUR(peds, true, BlipColorToGive)
											HUD.SET_PED_AI_BLIP_HAS_CONE(peds, false)
											HUD.SET_PED_AI_BLIP_FORCED_ON(peds, true)
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
										if OperationT[peds] == nil then
											if not ENTITY.IS_ENTITY_DEAD(peds) then
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
																		if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
												if CopsFollowInVehTask then
													if not PED.IS_PED_IN_COMBAT(peds, 0) then
														if Veh ~= 0 then
															if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_SHOOT_AT_COORD")) == 7 then
																if VEHICLE.GET_PED_IN_VEHICLE_SEAT(Veh, -1, false) == peds then
																	local VehModel = ENTITY.GET_ENTITY_MODEL(Veh)
																	local IsAPlane = VEHICLE.IS_THIS_MODEL_A_PLANE(VehModel)
																	local IsAHeli = VEHICLE.IS_THIS_MODEL_A_HELI(VehModel)
																	if not IsAPlane and not IsAHeli then
																		if not IsPedInGroup then
																			if not ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 100.0, 100.0, 100.0, false, true, false) then
																				if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_MISSION")) == 7 then
																					if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																						TASK.TASK_VEHICLE_MISSION_PED_TARGET(peds, Veh, PlayerPed, 4, 100.0, 64+512+2048+262144, 50.0, 10.0, true)
																					end
																				end
																			end
																		end
																	else
																		if not ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 150.0, 150.0, 200.0, false, true, false) then
																			if IsAHeli then
																				if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_MISSION")) == 7 then
																					if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																						TASK.TASK_HELI_MISSION(peds, Veh, 0, PlayerPed, 0.0, 0.0, 150.0, 4, 100.0, 120.0, 0, 100, 50, -1.0, 0)
																					end
																				end
																			end
																			if IsAPlane then
																				if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_VEHICLE_MISSION")) == 7 then
																					if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																						TASK.TASK_PLANE_MISSION(peds, Veh, 0, PlayerPed, 0, 0, 0, 4, 100.0, 50.0, 0.0, 50.0, 30.0, true)
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
													if Veh == 0 then
														if not IsPedInGroup then
															if OperationT[peds] == nil and NavsT[peds] == nil then
																if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_SHOOT_AT_COORD")) == 7 then
																	if ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 50.0, 50.0, 50.0, false, true, false) then
																		if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_FOLLOW_TO_OFFSET_OF_ENTITY")) == 7 then
																			if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																				TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(peds, PlayerPed, math.random(-10, 10), math.random(-10, 10), math.random(-10, 10), 100.0, -1, 5.0, true)
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
												if BringFarCopsCloser then
													local CanGo = true
													if BringIfOutsideOfVehicle then
														if IsInVeh then
															CanGo = false
														end
													end
													if CanGo then
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
																						if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
															if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
																if not RemoveCopsFromVeh then
																	if Veh ~= 0 then
																		local CheckRadius = 700.0
																		if TPIfImInAInterior then
																			if InteriorPlayerPed ~= 0 then
																				CheckRadius = 100.0
																			end
																		end
																		if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(Veh) then
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
										if UseCustomsTasksKeys then
											CustomTasksArgsFunctions[SelectedTask](TaskArgs, OperationsTable, OperationT, peds, Veh,
											FVect, RVect, UpVect, Vect)
											for k = 1, NumCreatedTasks do
												if OperationsTable[k] > 1 then
													if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
															if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
															if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
														if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
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
											if not ENTITY.IS_ENTITY_AT_ENTITY(peds, PlayerPed, 100.0, 100.0, 100.0, false, true, false) then
												if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
													local PPos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
													local OutPos, FoundCoords = find_right_spawn_normal(PPos.x, PPos.y, PPos.z, 40.0, 70.0)
													if FoundCoords then
														if not MISC.IS_POSITION_OCCUPIED(OutPos.x, OutPos.y, OutPos.z, 1.0, false, true, true, false, false, PlayerPed, true) then
															ENTITY.SET_ENTITY_COORDS(peds, OutPos.x, OutPos.y, OutPos.z)
															ENTITY.SET_ENTITY_HEADING(peds, math.random(0, 360))
														end
													end
												end
											end
											if TASK.GET_SCRIPT_TASK_STATUS(peds, joaat("SCRIPT_TASK_COMBAT_HATED_TARGETS_AROUND_PED")) == 7 then
												if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds) then
													TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(peds, 1000.0, 0)
												end
											end
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
			IterationsNumber = IterationsNumber + 1
			if IterationsNumber > 100 then
				IterationsNumber = 0
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
			for i = 1, #CopVehsT do
				if CopVehsT[i] ~= nil then
					if ENTITY.DOES_ENTITY_EXIST(CopVehsT[i].Handle) then
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
											if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(VehHandle) then
												if EntSpeed.y > 3.0 and EntSpeed.y < 50.0 then
													ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, NormZ * 0.005 * EntSpeed.y, (1.0 - NormZAbs) * 0.01 * EntSpeed.y, 0.0, 0, true, true, false)
												end
												local ForceZ = 0.0
												EntSpeed = ENTITY.GET_ENTITY_SPEED_VECTOR(VehHandle, true)
												if ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(VehHandle) > 1.1 then --or EntSpeed.x > 1.0 or EntSpeed.x < -1.0 then
													ForceZ = -1.50
												end
												ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, 0.0, ForceZ, ForceZ, 0, false, true, false)
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
							if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(CopVehsT[i].Handle) then
								ENTITY.SET_ENTITY_AS_MISSION_ENTITY(CopVehsT[i].Handle, false, true)
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
								end
							end
						end
						if DeadCount >= #Peds then --Count >= #Peds or ENTITY.IS_ENTITY_DEAD(CopVehsT[i].Handle) or DeadCount >= #Peds then
							if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(CopVehsT[i].Handle) then
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
			TaskArgs.MissionCopCount = MissionCopCount
			if ApplyCopSettings then
				if AutomaticGenCops then
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
			directx.draw_text(0.7, 0.7, "Cops "..MissionCopCount, ALIGN_CENTRE, 1.0, {r = 0, g = 255 , b = 255, a = 200}, false)
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
	for i = 1, #SelectedPedModels do
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
		local Entity = get_entity_player_is_aiming_at(PlayerId)
		if Entity ~= nil then
			NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(Entity)
			ENTITY.SET_ENTITY_INVINCIBLE(Entity, true)
		end
	end
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
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(crates)
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
				NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehs)
				ENTITY.SET_ENTITY_COORDS(vehs, PlCoords.x, PlCoords.y, PlCoords.z)
			end
		end
	end
end)

menu.toggle_loop(MiscMenu, "GB_FORTIFIED Spam Enemies", {}, "", function(toggle)
	if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("gb_fortified")) > 0 then
		memory.write_int(memory.script_local("gb_fortified", 1082+331-26), 3)
		memory.write_int(memory.script_local("gb_fortified", 1082+331-7), 1)
		util.spoof_script("gb_fortified", function()
			if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
				NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
			end
		end)
	end
end)

--util.copy_to_clipboard(string.format("%X", memory.script_global(SplitGlobals("Global_2635560.f_683"))))

menu.toggle_loop(MiscMenu, "Business Battles Chaos", {""}, "Enemies will rush and respawn.", function(toggle)
	if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_content_business_battles")) > 0 then
		util.spoof_script("fm_content_business_battles", function()
			if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
				NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
			end
		end)
		for i = 0, 29 do
			memory.write_int(memory.script_local("fm_content_business_battles", (215+129+1+2) + 21 * i), 1024)
			memory.write_float(memory.script_local("fm_content_business_battles", (215+129+1+21) + 21 * i), -1)
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

menu.action(DevMenu, "Get Addr", {}, "", function(toggle)
	local Addr = memory.scan("? 8b c4 ? 88 ? ? ? 89 ? ? ? 89 ? ? ? 89 ? ? 55 53")
	local FormatedString = string.format("%X", Addr)
	Print(FormatedString)
	util.copy_to_clipboard(FormatedString)
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
	local Addr = 0x7FF66E4E63F0
	local Addr2 = memory.read_long(Addr)
	local Addr3 = memory.read_long(Addr2+0x08)
	local Addr4 = memory.read_long(Addr3+0xB0)
	local FormatedString = string.format("%02X", Addr4)
	util.copy_to_clipboard(FormatedString)
	Print(FormatedString)
end)

menu.action(DevMenu, "Addr Get", {}, "", function(toggle)
	local Addr = memory.scan("? 89 5c ? ? ? 89 6c ? ? ? 89 74 ? ? 57")
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
    memory.write_int(memory.script_global(SplitGlobals("Global_2756336.f_183")), 1)
    memory.write_int(memory.script_global(SplitGlobals("Global_2756336.f_184")), 2)
end)

menu.action(DevMenu, "B Battle2 Args Solo", {}, "", function(Toggle)
    memory.write_int(memory.script_global(SplitGlobals("Global_2756336.f_183")), -1)
    memory.write_int(memory.script_global(SplitGlobals("Global_2756336.f_184")), 2)
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

local MissionFinisher = false
menu.toggle(MiscMenu, "Mission Finisher", {}, "", function(toggle)
	MissionFinisher = toggle
	if MissionFinisher then
		local nrl_Addrs = {}
		for i = 0, 3 do
			local Addr = memory.script_global(SplitGlobals("Global_4718592.f_1816[iVar0 /*24279*/].f_60") + 24279 * i)
			nrl_Addrs[i+1] = Addr
		end
		local goto_sz_Addrs = {}
		local drpr_addrs = {}
		local jtop_Addrs = {}
		for k = 0, 3 do
			jtop_Addrs[k+1] = {}
			jtop_Addrs[k+1].TeamAddrs = {}
			for i = 0, 19 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_5[bVar0 /*295*/].f_126[iVar1]") + ((k) + (295 * i)))
				jtop_Addrs[k+1].TeamAddrs[#jtop_Addrs[k+1].TeamAddrs+1] = Addr
				if k == 0 then
					local Addr2 = memory.script_global(SplitGlobals("Global_4980736.f_5[bVar0 /*295*/].f_14[0]") + 295 * i)
					goto_sz_Addrs[#goto_sz_Addrs+1] = Addr2
				end
			end
			for i = 0, 31 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_6204[bVar0 /*546*/].f_195[iVar2]") + ((k) + (546 * i)))
				jtop_Addrs[k+1].TeamAddrs[#jtop_Addrs[k+1].TeamAddrs+1] = Addr
			end
			for i = 0, 31 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_91874[bVar0 /*529*/].f_211[iVar1]") + ((k) + (529 * i)))
				jtop_Addrs[k+1].TeamAddrs[#jtop_Addrs[k+1].TeamAddrs+1] = Addr
			end
			for i = 0, 79 do
				local Addr = memory.script_global(SplitGlobals("Global_4980736.f_110349[bVar3 /*1098*/].f_636[iVar2]") + ((k) + (1098 * i)))
				jtop_Addrs[k+1].TeamAddrs[#jtop_Addrs[k+1].TeamAddrs+1] = Addr
			end
			for i = 0, 16 do
				local Addr = memory.script_global(SplitGlobals("Global_4718592.f_1816[bVar0 /*24279*/].f_6956[bVar1]") + ((24279 * k) + (i)))
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
					end
					if NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
						NETWORK.NETWORK_PREVENT_SCRIPT_HOST_MIGRATION()
					end
				end)
				util.spoof_script("fm_mission_controller_2020", function()
					if not NETWORK.NETWORK_IS_HOST_OF_THIS_SCRIPT() then
						NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
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
							ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(VehHandle, 1, 0.0, ForceZ, ForceZ, 0, false, true, false)
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
	local entity, pEntity = NULL, memory.alloc_int()
	if PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(player, pEntity) then
		entity = memory.read_int(pEntity)
	end
	if entity ~= NULL and ENTITY.IS_ENTITY_A_PED(entity) and PED.IS_PED_IN_ANY_VEHICLE(entity, false) then
		entity = PED.GET_VEHICLE_PED_IS_IN(entity, false)
	end
	return entity
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

function RaycastFromCamera(PlayerPed, Distance)
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
		-1,
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
	return HitCoords, memory.read_byte(DidHit) ~= 0
end

function ShapeTestNav(Entity, PPos, AdjustedVect)
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

function math.atan2(x, y)

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

local WhichMissionStartGlobal = SplitGlobals("Global_1895156[bParam0 /*609*/].f_10.f_32")
local InteriorsGlobal = SplitGlobals("Global_1895156[PLAYER::PLAYER_ID() /*609*/].f_536")
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
												NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(OldPed)
												entities.delete_by_handle(OldPed)
												SetPedCombatAbilities(Ped)
												PED.SET_PED_RELATIONSHIP_GROUP_HASH(Ped, joaat(AiHateRel))
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

util.create_tick_handler(function()
	return true
end)

--[[
									
]]