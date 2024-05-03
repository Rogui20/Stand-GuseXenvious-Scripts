util.require_natives(1676318796)

Print = util.toast
Wait = util.yield
joaat = util.joaat

json = require "json"

local FlagBitNames = {
	Jump = 1,
	UsePoint = 2,
	JumpTo = 3
}

local FlagsBits = 0

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

local Polys1 = {}

local Contents = LoadJSONFile(filesystem.scripts_dir().."\\navs\\LastNav.json")
if Contents ~= nil then
	for k = 1, #Contents do
		Polys1[#Polys1+1] = {
			{x = Contents[k].Poly1.x, y = Contents[k].Poly1.y, z = Contents[k].Poly1.z},
			{x = Contents[k].Poly2.x, y = Contents[k].Poly2.y, z = Contents[k].Poly2.z},
			{x = Contents[k].Poly3.x, y = Contents[k].Poly3.y, z = Contents[k].Poly3.z},
			--Center = {x = Contents[k].Center.x, y = Contents[k].Center.y,  z = Contents[k].Center.z},
			--Neighboors = Contents[k].Neighboors
			LinkedIDs = Contents[k].LinkedIDs,
			Flags = Contents[k].Flags,
			Point = Contents[k].Point,
			JumpTo = Contents[k].JumpTo or nil,
			JumpedFrom = Contents[k].JumpedFrom or nil
		}
	end
end

function ComputePoly2D(Polygon)
    local PolyX = 0.0
    local PolyY = 0.0
    local signedArea = 0.0
    local x0 = 0.0
    local y0 = 0.0
    local x1 = 0.0
    local y1 = 0.0
    local a = 0.0

    local Iteration = 1
    for i = 1, #Polygon-1 do
        x0 = Polygon[i].x
        y0 = Polygon[i].y
        x1 = Polygon[i+1].x
        y1 = Polygon[i+1].y
        a = x0*y1 - x1*y0
        signedArea = signedArea + a
        PolyX = PolyX + (x0 + x1)*a
        PolyY = PolyY + (y0 + y1)*a
        Iteration = i
    end

    x0 = Polygon[Iteration+1].x
    y0 = Polygon[Iteration+1].y
    x1 = Polygon[1].x
    y1 = Polygon[1].y
    a = x0*y1 - x1*y0
    signedArea = signedArea + a
    PolyX = PolyX + (x0 + x1)*a
    PolyY = PolyY + (y0 + y1)*a

    signedArea = signedArea * 0.5
    PolyX = PolyX / (6.0*signedArea)
    PolyY = PolyY / (6.0*signedArea)
    local PolyCentroid = {x = PolyX, y = PolyY}
    return PolyCentroid
end

function ComputePoly3D(Polygon, X, Y)
    local PolyX = 0.0
    local PolyY = 0.0
    local signedArea = 0.0
    local x0 = 0.0
    local y0 = 0.0
    local x1 = 0.0
    local y1 = 0.0
    local a = 0.0

    local Iteration = 1
    for i = 1, #Polygon-1 do
        x0 = Polygon[i][X]
        y0 = Polygon[i][Y]
        x1 = Polygon[i+1][X]
        y1 = Polygon[i+1][Y]
        a = x0*y1 - x1*y0
        signedArea = signedArea + a
        PolyX = PolyX + (x0 + x1)*a
        PolyY = PolyY + (y0 + y1)*a
        Iteration = i
    end

    x0 = Polygon[Iteration+1][X]
    y0 = Polygon[Iteration+1][Y]
    x1 = Polygon[1][X]
    y1 = Polygon[1][Y]
    a = x0*y1 - x1*y0
    signedArea = signedArea + a
    PolyX = PolyX + (x0 + x1)*a
    PolyY = PolyY + (y0 + y1)*a

    signedArea = signedArea * 0.5
    PolyX = PolyX / (6.0*signedArea)
    PolyY = PolyY / (6.0*signedArea)
    local PolyCentroid = {x = PolyX, y = PolyY}
    return PolyCentroid
end

function GetPolygonCenter(polygon)
    local CenterXY = ComputePoly3D(polygon, "x", "y")
    --local CenterYZ = ComputePoly3D(polygon, "y", "z")
    local CenterZ = 0.0
    local j = #polygon
    for i = 1, #polygon do
        if math.abs(polygon[i].z - polygon[j].z) > 0.1 then
            local CenterZX = ComputePoly3D(polygon, "z", "x")
            CenterZ = CenterZX.x
            break
        else
            CenterZ = polygon[1].z
        end
        j = #polygon
    end
    local Center = {x = CenterXY.x, y = CenterXY.y, z = CenterZ}
    return Center
end

for i = 1, #Polys1 do
	Polys1[i].Center = GetPolygonCenter(Polys1[i])
end

function SetAllPolysNeighboors()
	for i = 1, #Polys1 do
		Polys1[i].Neighboors = {}
		local Sub = {
			x = Polys1[i][1].x - ((Polys1[i][1].x - Polys1[i][3].x) / 2),
			y = Polys1[i][1].y - ((Polys1[i][1].y - Polys1[i][3].y) / 2),
			z = Polys1[i][1].z - ((Polys1[i][1].z - Polys1[i][3].z) / 2)
		}
		local Sub2 = {
			x = Polys1[i][2].x - ((Polys1[i][2].x - Polys1[i][3].x) / 2),
			y = Polys1[i][2].y - ((Polys1[i][2].y - Polys1[i][3].y) / 2),
			z = Polys1[i][2].z - ((Polys1[i][2].z - Polys1[i][3].z) / 2)
		}
		local Sub3 = {
			x = Polys1[i][1].x - ((Polys1[i][1].x - Polys1[i][2].x) / 2),
			y = Polys1[i][1].y - ((Polys1[i][1].y - Polys1[i][2].y) / 2),
			z = Polys1[i][1].z - ((Polys1[i][1].z - Polys1[i][2].z) / 2)
		}
		
		Polys1[i].Edge = Sub
		Polys1[i].Edge2 = Sub2
		Polys1[i].Edge3 = Sub3
		Polys1[i].ID = i
		Polys1[i].Closed = false
		Polys1[i].Parent = i
		Polys1[i].LocalPoints = {}
		for k = 1, 19 do --Old is 9
			local Div = 0.0 + 0.05 * k
			local NewSub = {
				x = Polys1[i][1].x - ((Polys1[i][1].x - Polys1[i][3].x) * Div),
				y = Polys1[i][1].y - ((Polys1[i][1].y - Polys1[i][3].y) * Div),
				z = Polys1[i][1].z - ((Polys1[i][1].z - Polys1[i][3].z) * Div)}
			local NewSub2 = {
				x = Polys1[i][2].x - ((Polys1[i][2].x - Polys1[i][3].x) * Div),
				y = Polys1[i][2].y - ((Polys1[i][2].y - Polys1[i][3].y) * Div),
				z = Polys1[i][2].z - ((Polys1[i][2].z - Polys1[i][3].z) * Div)}
			local NewSub3 = {
				x = Polys1[i][1].x - ((Polys1[i][1].x - Polys1[i][2].x) * Div),
				y = Polys1[i][1].y - ((Polys1[i][1].y - Polys1[i][2].y) * Div),
				z = Polys1[i][1].z - ((Polys1[i][1].z - Polys1[i][2].z) * Div)
			}
			local NewSub4 = {
				x = Polys1[i].Edge.x - ((Polys1[i].Edge.x - Polys1[i].Edge2.x) * Div),
				y = Polys1[i].Edge.y - ((Polys1[i].Edge.y - Polys1[i].Edge2.y) * Div),
				z = Polys1[i].Edge.z - ((Polys1[i].Edge.z - Polys1[i].Edge2.z) * Div)
			}
			local NewSub5 = {
				x = Polys1[i].Edge2.x - ((Polys1[i].Edge2.x - Polys1[i].Edge3.x) * Div),
				y = Polys1[i].Edge2.y - ((Polys1[i].Edge2.y - Polys1[i].Edge3.y) * Div),
				z = Polys1[i].Edge2.z - ((Polys1[i].Edge2.z - Polys1[i].Edge3.z) * Div)
			}
			local NewSub6 = {
				x = Polys1[i].Edge.x - ((Polys1[i].Edge.x - Polys1[i].Edge3.x) * Div),
				y = Polys1[i].Edge.y - ((Polys1[i].Edge.y - Polys1[i].Edge3.y) * Div),
				z = Polys1[i].Edge.z - ((Polys1[i].Edge.z - Polys1[i].Edge3.z) * Div)
			}
			local NewSub7 = {
				x = Polys1[i].Edge.x - ((Polys1[i].Edge.x - Polys1[i].Center.x) * Div),
				y = Polys1[i].Edge.y - ((Polys1[i].Edge.y - Polys1[i].Center.y) * Div),
				z = Polys1[i].Edge.z - ((Polys1[i].Edge.z - Polys1[i].Center.z) * Div)
			}
			local NewSub8 = {
				x = Polys1[i].Edge2.x - ((Polys1[i].Edge2.x - Polys1[i].Center.x) * Div),
				y = Polys1[i].Edge2.y - ((Polys1[i].Edge2.y - Polys1[i].Center.y) * Div),
				z = Polys1[i].Edge2.z - ((Polys1[i].Edge2.z - Polys1[i].Center.z) * Div)
			}
			local NewSub9 = {
				x = Polys1[i].Edge3.x - ((Polys1[i].Edge3.x - Polys1[i].Center.x) * Div),
				y = Polys1[i].Edge3.y - ((Polys1[i].Edge3.y - Polys1[i].Center.y) * Div),
				z = Polys1[i].Edge3.z - ((Polys1[i].Edge3.z - Polys1[i].Center.z) * Div)
			}
			Polys1[i].LocalPoints[#Polys1[i].LocalPoints+1] = NewSub
			Polys1[i].LocalPoints[#Polys1[i].LocalPoints+1] = NewSub2
			Polys1[i].LocalPoints[#Polys1[i].LocalPoints+1] = NewSub3
			Polys1[i].LocalPoints[#Polys1[i].LocalPoints+1] = NewSub4
			Polys1[i].LocalPoints[#Polys1[i].LocalPoints+1] = NewSub5
			Polys1[i].LocalPoints[#Polys1[i].LocalPoints+1] = NewSub6
			Polys1[i].LocalPoints[#Polys1[i].LocalPoints+1] = NewSub7
			Polys1[i].LocalPoints[#Polys1[i].LocalPoints+1] = NewSub8
			Polys1[i].LocalPoints[#Polys1[i].LocalPoints+1] = NewSub9
		end
		for k = 1, #Polys1 do
			if k ~= i then
				local Sub_1 = {
					x = Polys1[k][1].x - ((Polys1[k][1].x - Polys1[k][3].x) / 2),
					y = Polys1[k][1].y - ((Polys1[k][1].y - Polys1[k][3].y) / 2),
					z = Polys1[k][1].z - ((Polys1[k][1].z - Polys1[k][3].z) / 2)
				}
				local Sub2_1 = {
					x = Polys1[k][2].x - ((Polys1[k][2].x - Polys1[k][3].x) / 2),
					y = Polys1[k][2].y - ((Polys1[k][2].y - Polys1[k][3].y) / 2),
					z = Polys1[k][2].z - ((Polys1[k][2].z - Polys1[k][3].z) / 2)
				}
				local Sub3_1 = {
					x = Polys1[k][1].x - ((Polys1[k][1].x - Polys1[k][2].x) / 2),
					y = Polys1[k][1].y - ((Polys1[k][1].y - Polys1[k][2].y) / 2),
					z = Polys1[k][1].z - ((Polys1[k][1].z - Polys1[k][2].z) / 2)
				}
				if
				Sub.x == Sub_1.x and Sub.y == Sub_1.y and Sub.z == Sub_1.z or
				Sub.x == Sub2_1.x and Sub.y == Sub2_1.y and Sub.z == Sub2_1.z or
				Sub.x == Sub3_1.x and Sub.y == Sub3_1.y and Sub.z == Sub3_1.z or
				Sub2.x == Sub2_1.x and Sub2.y == Sub2_1.y and Sub2.z == Sub2_1.z or
				Sub2.x == Sub_1.x and Sub2.y == Sub_1.y and Sub2.z == Sub_1.z or
				Sub2.x == Sub3_1.x and Sub2.y == Sub3_1.y and Sub2.z == Sub3_1.z or
				Sub3.x == Sub3_1.x and Sub3.y == Sub3_1.y and Sub3.z == Sub3_1.z or
				Sub3.x == Sub2_1.x and Sub3.y == Sub2_1.y and Sub3.z == Sub2_1.z or
				Sub3.x == Sub_1.x and Sub3.y == Sub_1.y and Sub3.z == Sub_1.z
				--Polys1[i][1].x == Polys1[k][1].x and Polys1[i][1].y == Polys1[k][1].y and Polys1[i][1].z == Polys1[k][1].z or
				--Polys1[i][1].x == Polys1[k][2].x and Polys1[i][1].y == Polys1[k][2].y and Polys1[i][1].z == Polys1[k][2].z or
				--Polys1[i][1].x == Polys1[k][3].x and Polys1[i][1].y == Polys1[k][3].y and Polys1[i][1].z == Polys1[k][3].z or
				--Polys1[i][2].x == Polys1[k][1].x and Polys1[i][2].y == Polys1[k][1].y and Polys1[i][2].z == Polys1[k][1].z or
				--Polys1[i][2].x == Polys1[k][2].x and Polys1[i][2].y == Polys1[k][2].y and Polys1[i][2].z == Polys1[k][2].z or
				--Polys1[i][2].x == Polys1[k][3].x and Polys1[i][2].y == Polys1[k][3].y and Polys1[i][2].z == Polys1[k][3].z or
				--Polys1[i][3].x == Polys1[k][1].x and Polys1[i][3].y == Polys1[k][1].y and Polys1[i][3].z == Polys1[k][1].z or
				--Polys1[i][3].x == Polys1[k][2].x and Polys1[i][3].y == Polys1[k][2].y and Polys1[i][3].z == Polys1[k][2].z or
				--Polys1[i][3].x == Polys1[k][3].x and Polys1[i][3].y == Polys1[k][3].y and Polys1[i][3].z == Polys1[k][3].z
				then
					Polys1[i].Neighboors[#Polys1[i].Neighboors+1] = k
				end
			end
		end
		if Polys1[i].JumpTo == nil then
			Polys1[i].JumpTo = {}
		end
		if Polys1[i].JumpedFrom == nil then
			Polys1[i].JumpedFrom = {}
		end
		if Polys1[i].LinkedIDs ~= nil then
			for k = 1, #Polys1[i].LinkedIDs do
				local CanInsert = true
				for j = 1, #Polys1[i].Neighboors do
					if Polys1[i].LinkedIDs[k] == Polys1[i].Neighboors[j] then
						CanInsert = false
						break
					end
				end
				if CanInsert then
					Polys1[i].Neighboors[#Polys1[i].Neighboors+1] = Polys1[i].LinkedIDs[k]
				end
			end
		else
			Polys1[i].LinkedIDs = {}
		end
		if Polys1[i].Flags == nil then
			Polys1[i].Flags = 0
		end
	end
end

function SetPolyEdges(PolyID)
	local Sub = {
		x = Polys1[PolyID][1].x - ((Polys1[PolyID][1].x - Polys1[PolyID][3].x) / 2),
		y = Polys1[PolyID][1].y - ((Polys1[PolyID][1].y - Polys1[PolyID][3].y) / 2),
		z = Polys1[PolyID][1].z - ((Polys1[PolyID][1].z - Polys1[PolyID][3].z) / 2)
	}
	local Sub2 = {
		x = Polys1[PolyID][2].x - ((Polys1[PolyID][2].x - Polys1[PolyID][3].x) / 2),
		y = Polys1[PolyID][2].y - ((Polys1[PolyID][2].y - Polys1[PolyID][3].y) / 2),
		z = Polys1[PolyID][2].z - ((Polys1[PolyID][2].z - Polys1[PolyID][3].z) / 2)
	}
	local Sub3 = {
		x = Polys1[PolyID][1].x - ((Polys1[PolyID][1].x - Polys1[PolyID][2].x) / 2),
		y = Polys1[PolyID][1].y - ((Polys1[PolyID][1].y - Polys1[PolyID][2].y) / 2),
		z = Polys1[PolyID][1].z - ((Polys1[PolyID][1].z - Polys1[PolyID][2].z) / 2)
	}
	Polys1[PolyID].Edge = Sub
	Polys1[PolyID].Edge2 = Sub2
	Polys1[PolyID].Edge3 = Sub3
end

SetAllPolysNeighboors()
local NavmeshingMenu = menu.list(menu.my_root(), "Navmeshing", {}, "")
--local VehicleWaypointsMenu = menu.list(menu.my_root(), "Vehicle Waypoints", {}, "")
local DrawFunctionsMenu = menu.list(NavmeshingMenu, "Draw Functions", {}, "To see where polygons are.")

local ShowNavPoints = false
menu.toggle(DrawFunctionsMenu, "Draw Polys", {}, "", function(Toggle)
	ShowNavPoints = Toggle
	if ShowNavPoints then
		while ShowNavPoints do
			GRAPHICS.SET_BACKFACECULLING(false)
			local Pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
			for i = 1, #Polys1 do
				local R, G, B = 255, 255, 255
				--if Inside3DPolygon(Polys1[i], Pos) then
				if GetPolygonDirectIndex(Pos) == i then
					R = 0
					G = 0
					Print("Index is "..i)
				
				end
				if Polys1[i].LinkedIDs ~= nil then
					for k = 1, #Polys1[i].LinkedIDs do
						if Polys1[Polys1[i].LinkedIDs[k]] ~= nil then
							GRAPHICS.DRAW_LINE(Polys1[i].Center.x, Polys1[i].Center.y, Polys1[i].Center.z,
							Polys1[Polys1[i].LinkedIDs[k]].Center.x, Polys1[Polys1[i].LinkedIDs[k]].Center.y, Polys1[Polys1[i].LinkedIDs[k]].Center.z, 255, 255, 255, 150)
						end
					end
				end
				if Polys1[i].Flags ~= nil then
					if is_bit_set(Polys1[i].Flags, FlagBitNames.Jump) then
						R = 100
						G = 100
					end
				end
				--Print(Polys[i].Neighboors[1])
				GRAPHICS.DRAW_POLY(Polys1[i][1].x, Polys1[i][1].y, Polys1[i][1].z,
				Polys1[i][2].x, Polys1[i][2].y, Polys1[i][2].z,
				Polys1[i][3].x, Polys1[i][3].y, Polys1[i][3].z,
				R, G, B, 100)
				GRAPHICS.DRAW_LINE(Polys1[i][1].x, Polys1[i][1].y, Polys1[i][1].z,
				Polys1[i][2].x, Polys1[i][2].y, Polys1[i][2].z, 0, 0, 255, 150)
				GRAPHICS.DRAW_LINE(Polys1[i][2].x, Polys1[i][2].y, Polys1[i][2].z,
				Polys1[i][3].x, Polys1[i][3].y, Polys1[i][3].z, 0, 0, 255, 150)
				GRAPHICS.DRAW_LINE(Polys1[i][3].x, Polys1[i][3].y, Polys1[i][3].z,
				Polys1[i][1].x, Polys1[i][1].y, Polys1[i][1].z, 0, 0, 255, 150)
				if Polys1[i].Point ~= nil then
					GRAPHICS.DRAW_MARKER(28, Polys1[i].Point.x,
					Polys1[i].Point.y, Polys1[i].Point.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 150, 0, 0, 100, 0, false, 2, false, 0, 0, false)
				end
				--GRAPHICS.DRAW_MARKER(28, Polys1[i].Center.x,
				--Polys1[i].Center.y, Polys1[i].Center.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 150, 0, 0, 100, 0, false, 2, false, 0, 0, false)
			end
			Wait()
		end
		GRAPHICS.SET_BACKFACECULLING(true)
	end
end)

local ShowNavPoints2 = false
menu.toggle(DrawFunctionsMenu, "Draw Polys Neighboors", {}, "", function(Toggle)
	ShowNavPoints2 = Toggle
	if ShowNavPoints2 then
		while ShowNavPoints2 do
			GRAPHICS.SET_BACKFACECULLING(false)
			local Pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
			for i = 1, #Polys1 do
				local R, G, B = 0, 255, 255
				if Inside3DPolygon(Polys1[i], Pos) then
					GRAPHICS.DRAW_POLY(Polys1[i][1].x, Polys1[i][1].y, Polys1[i][1].z,
					Polys1[i][2].x, Polys1[i][2].y, Polys1[i][2].z,
					Polys1[i][3].x, Polys1[i][3].y, Polys1[i][3].z,
					R, G, B, 100)
					GRAPHICS.DRAW_LINE(Polys1[i][1].x, Polys1[i][1].y, Polys1[i][1].z,
					Polys1[i][2].x, Polys1[i][2].y, Polys1[i][2].z, 255, 0, 0, 150)
					GRAPHICS.DRAW_LINE(Polys1[i][2].x, Polys1[i][2].y, Polys1[i][2].z,
					Polys1[i][3].x, Polys1[i][3].y, Polys1[i][3].z, 0, 255, 0, 150)
					GRAPHICS.DRAW_LINE(Polys1[i][3].x, Polys1[i][3].y, Polys1[i][3].z,
					Polys1[i][1].x, Polys1[i][1].y, Polys1[i][1].z, 0, 0, 255, 150)
					for k = 1, #Polys1[i].Neighboors do
						GRAPHICS.DRAW_POLY(Polys1[Polys1[i].Neighboors[k]][1].x, Polys1[Polys1[i].Neighboors[k]][1].y, Polys1[Polys1[i].Neighboors[k]][1].z,
						Polys1[Polys1[i].Neighboors[k]][2].x, Polys1[Polys1[i].Neighboors[k]][2].y, Polys1[Polys1[i].Neighboors[k]][2].z,
						Polys1[Polys1[i].Neighboors[k]][3].x, Polys1[Polys1[i].Neighboors[k]][3].y, Polys1[Polys1[i].Neighboors[k]][3].z,
						R, G, B, 100)
						GRAPHICS.DRAW_LINE(Polys1[Polys1[i].Neighboors[k]][1].x, Polys1[Polys1[i].Neighboors[k]][1].y, Polys1[Polys1[i].Neighboors[k]][1].z,
						Polys1[Polys1[i].Neighboors[k]][2].x, Polys1[Polys1[i].Neighboors[k]][2].y, Polys1[Polys1[i].Neighboors[k]][2].z, 255, 0, 255, 150)
						GRAPHICS.DRAW_LINE(Polys1[Polys1[i].Neighboors[k]][2].x, Polys1[Polys1[i].Neighboors[k]][2].y, Polys1[Polys1[i].Neighboors[k]][2].z,
						Polys1[Polys1[i].Neighboors[k]][3].x, Polys1[Polys1[i].Neighboors[k]][3].y, Polys1[Polys1[i].Neighboors[k]][3].z, 0, 255, 0, 150)
						GRAPHICS.DRAW_LINE(Polys1[Polys1[i].Neighboors[k]][3].x, Polys1[Polys1[i].Neighboors[k]][3].y, Polys1[Polys1[i].Neighboors[k]][3].z,
						Polys1[Polys1[i].Neighboors[k]][1].x, Polys1[Polys1[i].Neighboors[k]][1].y, Polys1[Polys1[i].Neighboors[k]][1].z, 0, 0, 255, 150)
					end
				end
			end
			Wait()
		end
		GRAPHICS.SET_BACKFACECULLING(true)
	end
end)

local DrawPolysNeighbors = false
menu.toggle(DrawFunctionsMenu, "Draw Polys Neighbors Extended", {}, "", function(Toggle)
	DrawPolysNeighbors = Toggle
	if DrawPolysNeighbors then
		while DrawPolysNeighbors do
			local Indexes = {}
			GRAPHICS.SET_BACKFACECULLING(false)
			local Pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
			for i = 1, #Polys1 do
				local R, G, B = 0, 255, 255
				if Inside3DPolygon(Polys1[i], Pos) then
					Indexes[#Indexes+1] = i
					for k = 1, #Polys1[i].Neighboors do
						local CanInsert = true
						for j = 1, #Indexes do
							if Polys1[i].Neighboors[k] == Indexes[j] then
								CanInsert = false
								break
							end
						end
						if CanInsert then
							Indexes[#Indexes+1] = Polys1[i].Neighboors[k]
						end
					end
					--if #Indexes < 20 then
						for r = 1, 10 do
							--if #Indexes < 20 then
								for k = 1, #Indexes do
									for j = 1, #Polys1[Indexes[k]].Neighboors do
										local CanInsert = true
										for a = 1, #Indexes do
											if Polys1[Indexes[k]].Neighboors[j] == Indexes[a] then
												CanInsert = false
												break
											end
										end
										if CanInsert then
											Indexes[#Indexes+1] = Polys1[Indexes[k]].Neighboors[j]
										end
									end
								end
							--else
								--break
							--end
						end
					--end
				end
			end
			for i = 1, #Indexes do
				GRAPHICS.DRAW_POLY(Polys1[Indexes[i]][1].x, Polys1[Indexes[i]][1].y, Polys1[Indexes[i]][1].z,
				Polys1[Indexes[i]][2].x, Polys1[Indexes[i]][2].y, Polys1[Indexes[i]][2].z,
				Polys1[Indexes[i]][3].x, Polys1[Indexes[i]][3].y, Polys1[Indexes[i]][3].z,
				R, G, B, 100)
				GRAPHICS.DRAW_LINE(Polys1[Indexes[i]][1].x, Polys1[Indexes[i]][1].y, Polys1[Indexes[i]][1].z,
				Polys1[Indexes[i]][2].x, Polys1[Indexes[i]][2].y, Polys1[Indexes[i]][2].z, 255, 0, 0, 150)
				GRAPHICS.DRAW_LINE(Polys1[Indexes[i]][2].x, Polys1[Indexes[i]][2].y, Polys1[Indexes[i]][2].z,
				Polys1[Indexes[i]][3].x, Polys1[Indexes[i]][3].y, Polys1[Indexes[i]][3].z, 0, 255, 0, 150)
				GRAPHICS.DRAW_LINE(Polys1[Indexes[i]][3].x, Polys1[Indexes[i]][3].y, Polys1[Indexes[i]][3].z,
				Polys1[Indexes[i]][1].x, Polys1[Indexes[i]][1].y, Polys1[Indexes[i]][1].z, 0, 0, 255, 150)
			end
			Print(#Indexes)
			Wait()
		end
		GRAPHICS.SET_BACKFACECULLING(true)
	end
end)

local ShowNavPoints3 = false
menu.toggle(DrawFunctionsMenu, "Draw Polys Edge Center", {}, "", function(Toggle)
	ShowNavPoints3 = Toggle
	if ShowNavPoints3 then
		while ShowNavPoints3 do
			GRAPHICS.SET_BACKFACECULLING(false)
			local Pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
			for i = 1, #Polys1 do
				local R, G, B = 0, 255, 255
				if Inside3DPolygon(Polys1[i], Pos) then
					GRAPHICS.DRAW_POLY(Polys1[i][1].x, Polys1[i][1].y, Polys1[i][1].z,
					Polys1[i][2].x, Polys1[i][2].y, Polys1[i][2].z,
					Polys1[i][3].x, Polys1[i][3].y, Polys1[i][3].z,
					R, G, B, 10)
					GRAPHICS.DRAW_LINE(Polys1[i][1].x, Polys1[i][1].y, Polys1[i][1].z,
					Polys1[i][2].x, Polys1[i][2].y, Polys1[i][2].z, 255, 0, 0, 150)
					GRAPHICS.DRAW_LINE(Polys1[i][2].x, Polys1[i][2].y, Polys1[i][2].z,
					Polys1[i][3].x, Polys1[i][3].y, Polys1[i][3].z, 0, 255, 0, 150)
					GRAPHICS.DRAW_LINE(Polys1[i][3].x, Polys1[i][3].y, Polys1[i][3].z,
					Polys1[i][1].x, Polys1[i][1].y, Polys1[i][1].z, 0, 0, 255, 150)
					local Sub = {
						x = Polys1[i][1].x - ((Polys1[i][1].x - Polys1[i][3].x) / 2),
						y = Polys1[i][1].y - ((Polys1[i][1].y - Polys1[i][3].y) / 2),
						z = Polys1[i][1].z - ((Polys1[i][1].z - Polys1[i][3].z) / 2)
					}
					local Sub2 = {
						x = Polys1[i][2].x - ((Polys1[i][2].x - Polys1[i][3].x) / 2),
						y = Polys1[i][2].y - ((Polys1[i][2].y - Polys1[i][3].y) / 2),
						z = Polys1[i][2].z - ((Polys1[i][2].z - Polys1[i][3].z) / 2)
					}
					local Sub3 = {
						x = Polys1[i][1].x - ((Polys1[i][1].x - Polys1[i][2].x) / 2),
						y = Polys1[i][1].y - ((Polys1[i][1].y - Polys1[i][2].y) / 2),
						z = Polys1[i][1].z - ((Polys1[i][1].z - Polys1[i][2].z) / 2)
					}
					GRAPHICS.DRAW_MARKER(28, Sub.x,
					Sub.y, Sub.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 150, 0, 0, 100, 0, false, 2, false, 0, 0, false)
					GRAPHICS.DRAW_MARKER(28, Sub2.x,
					Sub2.y, Sub2.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 150, 150, 0, 100, 0, false, 2, false, 0, 0, false)
					GRAPHICS.DRAW_MARKER(28, Sub3.x,
					Sub3.y, Sub3.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 150, 150, 150, 100, 0, false, 2, false, 0, 0, false)
					directx.draw_text(0.7, 0.7, "x: "..string.format("%.7f", Sub3.x).." y: "..string.format("%.7f", Sub3.y).." z: "..string.format("%.7f", Sub3.z) , ALIGN_CENTRE, 1.0, {r = 1.0, g = 1.0 , b = 1.0, a = 1.0}, false)
				end
			end
			Wait()
		end
		GRAPHICS.SET_BACKFACECULLING(true)
	end
end)

local ShowPoints = false
menu.toggle(DrawFunctionsMenu, "Draw Polys Points", {}, "", function(Toggle)
	ShowPoints = Toggle
	if ShowPoints then
		while ShowPoints do
			GRAPHICS.SET_BACKFACECULLING(false)
			local Pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
			for i = 1, #Polys1 do
				local R, G, B = 0, 255, 255
				if Inside3DPolygon(Polys1[i], Pos) then
					GRAPHICS.DRAW_POLY(Polys1[i][1].x, Polys1[i][1].y, Polys1[i][1].z,
					Polys1[i][2].x, Polys1[i][2].y, Polys1[i][2].z,
					Polys1[i][3].x, Polys1[i][3].y, Polys1[i][3].z,
					R, G, B, 10)
					GRAPHICS.DRAW_LINE(Polys1[i][1].x, Polys1[i][1].y, Polys1[i][1].z,
					Polys1[i][2].x, Polys1[i][2].y, Polys1[i][2].z, 255, 0, 0, 150)
					GRAPHICS.DRAW_LINE(Polys1[i][2].x, Polys1[i][2].y, Polys1[i][2].z,
					Polys1[i][3].x, Polys1[i][3].y, Polys1[i][3].z, 0, 255, 0, 150)
					GRAPHICS.DRAW_LINE(Polys1[i][3].x, Polys1[i][3].y, Polys1[i][3].z,
					Polys1[i][1].x, Polys1[i][1].y, Polys1[i][1].z, 0, 0, 255, 150)
					for k = 1, #Polys1[i].LocalPoints do
						--GRAPHICS.DRAW_MARKER(28, Polys1[i].LocalPoints[k].x,
						--Polys1[i].LocalPoints[k].y, Polys1[i].LocalPoints[k].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.1, 150, 150, 150, 100, 0, false, 2, false, 0, 0, false)
						GRAPHICS.DRAW_LINE(Polys1[i].LocalPoints[k].x,
						Polys1[i].LocalPoints[k].y, Polys1[i].LocalPoints[k].z,
						Pos.x, Pos.y, Pos.z, 255, 0, 0, 150)
					end
					
				end
			end
			Wait()
		end
		GRAPHICS.SET_BACKFACECULLING(true)
	end
end)

local DrawGrid = false
menu.toggle(DrawFunctionsMenu, "Draw Grid", {}, "", function(Toggle)
	DrawGrid = Toggle
	if DrawGrid then
		while DrawGrid do
			local PlayerPed = PLAYER.PLAYER_PED_ID()
			local LinesT = {}
			for i = -1, 1 do
				local DrawsT = {}
				for k = 2, 5 do
					local Pos = GetOffsetFromEntityInWorldCoords(PlayerPed, -0.5 + 1.0 * i, 0.5 + 1.0 * k, 1.0)
					DrawsT[#DrawsT+1] = {Pos, 255, 0, 0}
					local Pos = GetOffsetFromEntityInWorldCoords(PlayerPed, -0.5 + 1.0 * i, -0.5 + 1.0 * k, 1.0)
					DrawsT[#DrawsT+1] = {Pos, 0, 255, 0}
					local Pos = GetOffsetFromEntityInWorldCoords(PlayerPed, 0.5 + 1.0 * i, -0.5 + 1.0 * k, 1.0)
					DrawsT[#DrawsT+1] = {Pos, 0, 0, 255}
					local Pos = GetOffsetFromEntityInWorldCoords(PlayerPed, 0.5 + 1.0 * i, 0.5 + 1.0 * k, 1.0)
					DrawsT[#DrawsT+1] = {Pos, 255, 255, 0}
					local Pos = GetOffsetFromEntityInWorldCoords(PlayerPed, -0.5 + 1.0 * i, 0.5 + 1.0 * k, 1.0)
					DrawsT[#DrawsT+1] = {Pos, 0, 255, 255}
				end
				LinesT[#LinesT+1] = DrawsT
			end
			for i = 1, #LinesT do
				for k = 1, #LinesT[i]-1 do
					GRAPHICS.DRAW_LINE(LinesT[i][k][1].x, LinesT[i][k][1].y, LinesT[i][k][1].z,
					LinesT[i][k+1][1].x, LinesT[i][k+1][1].y, LinesT[i][k+1][1].z, LinesT[i][k+1][2], LinesT[i][k+1][3], LinesT[i][k+1][4], 150)
				end
			end
			Wait()
		end
	end
end)

local DrawPolyGrid = false
menu.toggle(DrawFunctionsMenu, "Draw Poly Grid", {}, "", function(Toggle)
	DrawPolyGrid = Toggle
	if DrawPolyGrid then
		while DrawPolyGrid do
			GRAPHICS.SET_BACKFACECULLING(false)
			local PlayerPed = PLAYER.PLAYER_PED_ID()
			local LinesT = {}
			for i = -1, 1 do
				local DrawsT = {}
				for k = 2, 5 do
					local Pos = GetOffsetFromEntityInWorldCoords(PlayerPed, -0.5 + 1.0 * i, 0.5 + 1.0 * k, 1.0)
					DrawsT[#DrawsT+1] = {Pos, 255, 0, 0}
					local Pos = GetOffsetFromEntityInWorldCoords(PlayerPed, -0.5 + 1.0 * i, -0.5 + 1.0 * k, 1.0)
					DrawsT[#DrawsT+1] = {Pos, 0, 255, 0}
					local Pos = GetOffsetFromEntityInWorldCoords(PlayerPed, 0.5 + 1.0 * i, -0.5 + 1.0 * k, 1.0)
					DrawsT[#DrawsT+1] = {Pos, 0, 0, 255}
					local Pos = GetOffsetFromEntityInWorldCoords(PlayerPed, 0.5 + 1.0 * i, 0.5 + 1.0 * k, 1.0)
					DrawsT[#DrawsT+1] = {Pos, 255, 255, 0}
					local Pos = GetOffsetFromEntityInWorldCoords(PlayerPed, -0.5 + 1.0 * i, 0.5 + 1.0 * k, 1.0)
					DrawsT[#DrawsT+1] = {Pos, 0, 255, 255}
				end
				LinesT[#LinesT+1] = DrawsT
			end
			for i = 1, #LinesT do
				local kIt = 1
				while kIt <= #LinesT[i]-4 do
					GRAPHICS.DRAW_POLY(LinesT[i][kIt][1].x, LinesT[i][kIt][1].y, LinesT[i][kIt][1].z,
					LinesT[i][kIt+1][1].x, LinesT[i][kIt+1][1].y, LinesT[i][kIt+1][1].z,
					LinesT[i][kIt+2][1].x, LinesT[i][kIt+2][1].y, LinesT[i][kIt+2][1].z,
					LinesT[i][kIt+3][2], LinesT[i][kIt+3][3], LinesT[i][kIt+3][4], 100)
					GRAPHICS.DRAW_POLY(LinesT[i][kIt+3][1].x, LinesT[i][kIt+3][1].y, LinesT[i][kIt+3][1].z,
					LinesT[i][kIt+4][1].x, LinesT[i][kIt+4][1].y, LinesT[i][kIt+4][1].z,
					LinesT[i][kIt+2][1].x, LinesT[i][kIt+2][1].y, LinesT[i][kIt+2][1].z,
					LinesT[i][kIt+3][2], LinesT[i][kIt+3][3], LinesT[i][kIt+3][4], 100)
					kIt = kIt + 5
				end
			end
			Wait()
		end
	else
		GRAPHICS.SET_BACKFACECULLING(true)
	end
end)

menu.action(menu.my_root(), "Copy Coords", {}, "", function(Toggle)
	local Pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
	util.copy_to_clipboard("x = "..Pos.x..", y = "..Pos.y..", z = "..Pos.z)
end)

local AddPolysMenu = menu.list(NavmeshingMenu, "Add Polygons Tools", {}, "Start building here.")
local PolyFlagsMenu = menu.list(AddPolysMenu, "Flags", {}, "Attach navigation behaviour to polygons.")

local JumpToNode = false
menu.toggle(PolyFlagsMenu, "Jump", {}, "", function(Toggle)
	JumpToNode = Toggle
	if JumpToNode then
		if not is_bit_set(FlagsBits, FlagBitNames.Jump) then
			FlagsBits = set_bit(FlagsBits, FlagBitNames.Jump)
		end
	else
		if is_bit_set(FlagsBits, FlagBitNames.Jump) then
			FlagsBits = clear_bit(FlagsBits, FlagBitNames.Jump)
		end
	end
end)

local NodeUsesPoint = false
menu.toggle(PolyFlagsMenu, "Use Point", {}, "", function(Toggle)
	NodeUsesPoint = Toggle
	if NodeUsesPoint then
		if not is_bit_set(FlagsBits, FlagBitNames.UsePoint) then
			FlagsBits = set_bit(FlagsBits, FlagBitNames.UsePoint)
		end
	else
		if is_bit_set(FlagsBits, FlagBitNames.UsePoint) then
			FlagsBits = clear_bit(FlagsBits, FlagBitNames.UsePoint)
		end
	end
end)

local JumpToNode2 = false
menu.toggle(PolyFlagsMenu, "Jump To", {}, "", function(Toggle)
	JumpToNode2 = Toggle
	if JumpToNode2 then
		if not is_bit_set(FlagsBits, FlagBitNames.JumpTo) then
			FlagsBits = set_bit(FlagsBits, FlagBitNames.JumpTo)
		end
	else
		if is_bit_set(FlagsBits, FlagBitNames.JumpTo) then
			FlagsBits = clear_bit(FlagsBits, FlagBitNames.JumpTo)
		end
	end
end)

menu.action(PolyFlagsMenu, "Apply Flag To Selected Poly", {}, "", function(Toggle)
	local PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
	if #Polys1 > 0 then
		local PolyIdx = 0
		for k = 1, #Polys1 do
			if Inside3DPolygon(Polys1[k], PlayerPos) then
				PolyIdx = k
				break
			end
		end
		if PolyIdx ~= 0 then
			Polys1[PolyIdx].Flags = FlagsBits
			Print("Applied flag bits "..FlagsBits.." to polygon index "..PolyIdx..".")
		end
	end
end)

local LinkJumpState = 0
local LinkJumpID2 = 0
local ToLinkJumpID2 = 0
menu.action(AddPolysMenu, "Apply Jump To Polygon", {}, "Select the first polygon, and press again to apply the jump to the other selected polygon.", function(Toggle)
	local PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
	local PolyIdx = 0
	if LinkJumpState == 0 then
		for k = 1, #Polys1 do
			if Inside3DPolygon(Polys1[k], PlayerPos) then
				PolyIdx = k
				break
			end
		end
		if PolyIdx ~= 0 then
			LinkJumpState = 1
			LinkJumpID2 = PolyIdx
			Print("Index is "..LinkJumpID2.." and now waiting for user input the next ID.")
		end
	end
	if LinkJumpState == 1 then
		for k = 1, #Polys1 do
			if Inside3DPolygon(Polys1[k], PlayerPos) then
				PolyIdx = k
				break
			end
		end
		if PolyIdx ~= 0 then
			if PolyIdx ~= LinkJumpID2 then
				ToLinkJumpID2 = PolyIdx
				local CanInsertToID = true
				if Polys1[LinkJumpID2].JumpTo ~= nil then
					for k = 1, #Polys1[LinkJumpID2].JumpTo do
						if Polys1[LinkJumpID2].JumpTo[k] == ToLinkJumpID2 then
							CanInsertToID = false
							break
						end
					end
				end
				if CanInsertToID then
					if Polys1[LinkJumpID2].JumpTo == nil then
						Polys1[LinkJumpID2].JumpTo = {}
					end
					Polys1[LinkJumpID2].JumpTo[#Polys1[LinkJumpID2].JumpTo+1] = ToLinkJumpID2
					Print("Index ".. LinkJumpID2.." and index "..ToLinkJumpID2.." are jump to set.")
					CanInsertToID = true
					if Polys1[ToLinkJumpID2].JumpedFrom ~= nil then
						for k = 1, #Polys1[ToLinkJumpID2].JumpedFrom do
							if Polys1[ToLinkJumpID2].JumpedFrom[k] == LinkJumpID2 then
								CanInsertToID = false
								break
							end
						end
					end
					if CanInsertToID then
						Polys1[ToLinkJumpID2].JumpedFrom[#Polys1[ToLinkJumpID2].JumpedFrom+1] = LinkJumpID2
					end
				end
				ToLinkJumpID2 = 0
				LinkJumpID2 = 0
				LinkJumpState = 0
			end
		end
	end
end)

local Coords1 = {x = 0.0, y = 0.0, z = 0.0}
local Coords2 = {x = 0.0, y = 0.0, z = 0.0}
local Coords3 = {x = 0.0, y = 0.0, z = 0.0}
local SnapCoords = {x = 0.0, y = 0.0, z = 0.0}
local InsideOfPolygonAdd = false

local PolyStart = 1
local AddState3 = 0
menu.action(AddPolysMenu, "Add Poly From Selected", {}, "", function(Toggle)
	AddState3 = AddState3 + 1
	local PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
	if #Polys1 > 0 then
		if AddState3 == 1 then
			for k = 1, #Polys1 do
				if Inside3DPolygon(Polys1[k], PlayerPos) then
					PolyStart = k
					break
				end
			end
		end
		if Polys1[PolyStart] ~= nil then
			while AddState3 == 1 do
				PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
				local PolyIdx = 0
				for k = 1, #Polys1 do
					if Inside3DPolygon(Polys1[k], PlayerPos) then
						PolyIdx = k
						InsideOfPolygonAdd = true
						break
					end
				end
				if PolyIdx ~= 0 then
					local Dist = 10000.0
					local PolysVertex = {
						{x = Polys1[PolyIdx][1].x, y = Polys1[PolyIdx][1].y, z = Polys1[PolyIdx][1].z},
						{x = Polys1[PolyIdx][2].x, y = Polys1[PolyIdx][2].y, z = Polys1[PolyIdx][2].z},
						{x = Polys1[PolyIdx][3].x, y = Polys1[PolyIdx][3].y, z = Polys1[PolyIdx][3].z}
					}
					for k = 1, #PolysVertex do
						local Distance = MISC.GET_DISTANCE_BETWEEN_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z, PolysVertex[k].x, PolysVertex[k].y, PolysVertex[k].z, true)
						if Distance < Dist then
							Dist = Distance
							SnapCoords.x = PolysVertex[k].x
							SnapCoords.y = PolysVertex[k].y
							SnapCoords.z = PolysVertex[k].z
						end
					end
				end
				if PolyIdx == 0 then
					GRAPHICS.DRAW_POLY(PlayerPos.x, PlayerPos.y, PlayerPos.z,
					Polys1[PolyStart][1].x, Polys1[PolyStart][1].y, Polys1[PolyStart][1].z,
					Polys1[PolyStart][3].x, Polys1[PolyStart][3].y, Polys1[PolyStart][3].z,
					255, 255, 255, 100)
					InsideOfPolygonAdd = false
				else
					GRAPHICS.DRAW_POLY(SnapCoords.x, SnapCoords.y, SnapCoords.z,
					Polys1[PolyStart][1].x, Polys1[PolyStart][1].y, Polys1[PolyStart][1].z,
					Polys1[PolyStart][3].x, Polys1[PolyStart][3].y, Polys1[PolyStart][3].z,
					255, 255, 255, 100)
				end
				Wait()
			end
			if AddState3 == 2 then
				AddState3 = 0
				if InsideOfPolygonAdd then
					Polys1[#Polys1+1] = {
						{x = SnapCoords.x, y = SnapCoords.y, z = SnapCoords.z},
						Polys1[PolyStart][1],
						Polys1[PolyStart][3]
					}
					Polys1[#Polys1].Center = GetPolygonCenter(Polys1[#Polys1])
					--SetAllPolysNeighboors()
					SetPolyEdges(#Polys1)
				else
					Polys1[#Polys1+1] = {
						{x = PlayerPos.x, y = PlayerPos.y, z = PlayerPos.z},
						Polys1[PolyStart][1],
						Polys1[PolyStart][3]
					}
					Polys1[#Polys1].Center = GetPolygonCenter(Polys1[#Polys1])
					--SetAllPolysNeighboors()
					SetPolyEdges(#Polys1)
				end
				PolyStart = #Polys1
				SnapCoords.x = 0.0
				SnapCoords.y = 0.0
				SnapCoords.z = 0.0
			end
		else
			AddState3 = 0
		end
	else
		if AddState3 == 1 then
			Coords1.x = PlayerPos.x
			Coords1.y = PlayerPos.y
			Coords1.z = PlayerPos.z
			Print("No polygons created, defined vertex 1 coords.")
		end
		if AddState3 == 2 then
			Coords2.x = PlayerPos.x
			Coords2.y = PlayerPos.y
			Coords2.z = PlayerPos.z
			Print("Defined vertex 2 coords.")
		end
		if AddState3 == 3 then
			AddState3 = 0
			Coords3.x = PlayerPos.x
			Coords3.y = PlayerPos.y
			Coords3.z = PlayerPos.z
			Polys1[#Polys1+1] = {
				{x = Coords1.x, y = Coords1.y, z = Coords1.z},
				{x = Coords2.x, y = Coords2.y, z = Coords2.z},
				{x = Coords3.x, y = Coords3.y, z = Coords3.z}
			}
			Polys1[#Polys1].Center = GetPolygonCenter(Polys1[#Polys1])
			--SetAllPolysNeighboors()
			SetPolyEdges(#Polys1)
			Print("Defined vertex 3 coords and added polygon.")
		end
	end
end)

local AddState4 = 0
menu.action(AddPolysMenu, "Add Poly 2 From Selected", {}, "", function(Toggle)
	AddState4 = AddState4 + 1
	local PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
	if #Polys1 > 0 then
		if AddState4 == 1 then
			for k = 1, #Polys1 do
				if Inside3DPolygon(Polys1[k], PlayerPos) then
					PolyStart = k
					break
				end
			end
		end
		if Polys1[PolyStart] ~= nil then
			while AddState4 == 1 do
				PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
				local PolyIdx = 0
				for k = 1, #Polys1 do
					if Inside3DPolygon(Polys1[k], PlayerPos) then
						PolyIdx = k
						InsideOfPolygonAdd = true
						break
					end
				end
				if PolyIdx ~= 0 then
					local Dist = 10000.0
					local PolysVertex = {
						{x = Polys1[PolyIdx][1].x, y = Polys1[PolyIdx][1].y, z = Polys1[PolyIdx][1].z},
						{x = Polys1[PolyIdx][2].x, y = Polys1[PolyIdx][2].y, z = Polys1[PolyIdx][2].z},
						{x = Polys1[PolyIdx][3].x, y = Polys1[PolyIdx][3].y, z = Polys1[PolyIdx][3].z}
					}
					for k = 1, #PolysVertex do
						local Distance = MISC.GET_DISTANCE_BETWEEN_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z, PolysVertex[k].x, PolysVertex[k].y, PolysVertex[k].z, true)
						if Distance < Dist then
							Dist = Distance
							SnapCoords.x = PolysVertex[k].x
							SnapCoords.y = PolysVertex[k].y
							SnapCoords.z = PolysVertex[k].z
						end
					end
				end
				if PolyIdx == 0 then
					GRAPHICS.DRAW_POLY(PlayerPos.x, PlayerPos.y, PlayerPos.z,
					Polys1[PolyStart][2].x, Polys1[PolyStart][2].y, Polys1[PolyStart][2].z,
					Polys1[PolyStart][1].x, Polys1[PolyStart][1].y, Polys1[PolyStart][1].z,
					255, 255, 255, 100)
					InsideOfPolygonAdd = false
				else
					GRAPHICS.DRAW_POLY(SnapCoords.x, SnapCoords.y, SnapCoords.z,
					Polys1[PolyStart][2].x, Polys1[PolyStart][2].y, Polys1[PolyStart][2].z,
					Polys1[PolyStart][1].x, Polys1[PolyStart][1].y, Polys1[PolyStart][1].z,
					255, 255, 255, 100)
				end
				Wait()
			end
			if AddState4 == 2 then
				AddState4 = 0
				if InsideOfPolygonAdd then
					Polys1[#Polys1+1] = {
						{x = SnapCoords.x, y = SnapCoords.y, z = SnapCoords.z},
						Polys1[PolyStart][2],
						Polys1[PolyStart][1]
					}
					Polys1[#Polys1].Center = GetPolygonCenter(Polys1[#Polys1])
					--SetAllPolysNeighboors()
					SetPolyEdges(#Polys1)
				else
					Polys1[#Polys1+1] = {
						{x = PlayerPos.x, y = PlayerPos.y, z = PlayerPos.z},
						Polys1[PolyStart][2],
						Polys1[PolyStart][1]
					}
					Polys1[#Polys1].Center = GetPolygonCenter(Polys1[#Polys1])
					--SetAllPolysNeighboors()
					SetPolyEdges(#Polys1)
				end
				PolyStart = #Polys1
				SnapCoords.x = 0.0
				SnapCoords.y = 0.0
				SnapCoords.z = 0.0
			end
		else
			AddState4 = 0
		end
	else
		if AddState3 == 1 then
			Coords1.x = PlayerPos.x
			Coords1.y = PlayerPos.y
			Coords1.z = PlayerPos.z
			Print("No polygons created, defined vertex 1 coords.")
		end
		if AddState3 == 2 then
			Coords2.x = PlayerPos.x
			Coords2.y = PlayerPos.y
			Coords2.z = PlayerPos.z
			Print("Defined vertex 2 coords.")
		end
		if AddState3 == 3 then
			AddState3 = 0
			Coords3.x = PlayerPos.x
			Coords3.y = PlayerPos.y
			Coords3.z = PlayerPos.z
			Polys1[#Polys1+1] = {
				{x = Coords1.x, y = Coords1.y, z = Coords1.z},
				{x = Coords2.x, y = Coords2.y, z = Coords2.z},
				{x = Coords3.x, y = Coords3.y, z = Coords3.z}
			}
			Polys1[#Polys1].Center = GetPolygonCenter(Polys1[#Polys1])
			--SetAllPolysNeighboors()
			SetPolyEdges(#Polys1)
			Print("Defined vertex 3 coords and added polygon.")
		end
	end
end)

local MoveState = 0
menu.action(AddPolysMenu, "Move All Polygon Vertexes", {}, "", function(Toggle)
	local PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
	local PolyIdx = 0
	if MoveState == 0 then
		for k = 1, #Polys1 do
			if Inside3DPolygon(Polys1[k], PlayerPos) then
				PolyIdx = k
				InsideOfPolygonAdd = true
				break
			end
		end
		if PolyIdx ~= 0 then
			local Dist = 10000.0
			local ClosestVertex = {x = 0.0, y = 0.0, z = 0.0}
			local PolysVertex = {
				{x = Polys1[PolyIdx][1].x, y = Polys1[PolyIdx][1].y, z = Polys1[PolyIdx][1].z},
				{x = Polys1[PolyIdx][2].x, y = Polys1[PolyIdx][2].y, z = Polys1[PolyIdx][2].z},
				{x = Polys1[PolyIdx][3].x, y = Polys1[PolyIdx][3].y, z = Polys1[PolyIdx][3].z}
			}
			for k = 1, #PolysVertex do
				local Distance = MISC.GET_DISTANCE_BETWEEN_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z, PolysVertex[k].x, PolysVertex[k].y, PolysVertex[k].z, true)
				if Distance < Dist then
					Dist = Distance
					ClosestVertex.x = PolysVertex[k].x
					ClosestVertex.y = PolysVertex[k].y
					ClosestVertex.z = PolysVertex[k].z
				end
			end
			local PolysIdxs = {}
			for k = 1, #Polys1 do
				if Polys1[k][1].x == ClosestVertex.x and Polys1[k][1].y == ClosestVertex.y and Polys1[k][1].z == ClosestVertex.z then
					PolysIdxs[#PolysIdxs+1] = {PolyID = k, VertexID = 1}
				end
				if Polys1[k][2].x == ClosestVertex.x and Polys1[k][2].y == ClosestVertex.y and Polys1[k][2].z == ClosestVertex.z then
					PolysIdxs[#PolysIdxs+1] = {PolyID = k, VertexID = 2}
				end
				if Polys1[k][3].x == ClosestVertex.x and Polys1[k][3].y == ClosestVertex.y and Polys1[k][3].z == ClosestVertex.z then
					PolysIdxs[#PolysIdxs+1] = {PolyID = k, VertexID = 3}
				end
			end
			MoveState = 1
			while MoveState == 1 do
				PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
				for k = 1, #PolysIdxs do
					Polys1[PolysIdxs[k].PolyID][PolysIdxs[k].VertexID].x = PlayerPos.x
					Polys1[PolysIdxs[k].PolyID][PolysIdxs[k].VertexID].y = PlayerPos.y
					Polys1[PolysIdxs[k].PolyID][PolysIdxs[k].VertexID].z = PlayerPos.z
				end
				Wait()
			end
		end
	else
		MoveState = 0
	end
end)

menu.action(AddPolysMenu, "Delete Last Poly", {}, "", function(Toggle)
	table.remove(Polys1, #Polys1)
	PolyStart = #Polys1
end)

menu.action(AddPolysMenu, "Delete Selected Poly", {}, "", function(Toggle)
	local PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
	for k = 1, #Polys1 do
		if Inside3DPolygon(Polys1[k], PlayerPos) then
			table.remove(Polys1, k)
			break
		end
	end
end)

local Coords1_1 = {x = 0.0, y = 0.0, z = 0.0}
local Coords2_1 = {x = 0.0, y = 0.0, z = 0.0}
local Coords3_1 = {x = 0.0, y = 0.0, z = 0.0}
local AddState5 = 0
menu.action(AddPolysMenu, "Add New Poly", {}, "", function(Toggle)
	AddState5 = AddState5 + 1
	local PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
	if AddState5 == 1 then
		Coords1_1.x = PlayerPos.x
		Coords1_1.y = PlayerPos.y
		Coords1_1.z = PlayerPos.z
		Print("Defined vertex 1 coords.")
	end
	if AddState5 == 2 then
		Coords2_1.x = PlayerPos.x
		Coords2_1.y = PlayerPos.y
		Coords2_1.z = PlayerPos.z
		Print("Defined vertex 2 coords.")
	end
	if AddState5 == 3 then
		AddState5 = 0
		Coords3_1.x = PlayerPos.x
		Coords3_1.y = PlayerPos.y
		Coords3_1.z = PlayerPos.z
		Polys1[#Polys1+1] = {
			{x = Coords1_1.x, y = Coords1_1.y, z = Coords1_1.z},
			{x = Coords2_1.x, y = Coords2_1.y, z = Coords2_1.z},
			{x = Coords3_1.x, y = Coords3_1.y, z = Coords3_1.z}
		}
		Polys1[#Polys1].Center = GetPolygonCenter(Polys1[#Polys1])
		--SetAllPolysNeighboors()
		SetPolyEdges(#Polys1)
		Print("Defined vertex 3 coords and added polygon.")
	end
end)

local Coords1_2 = {x = 0.0, y = 0.0, z = 0.0}
local Coords2_2 = {x = 0.0, y = 0.0, z = 0.0}
local GridSizeX = 1
local GridSizeY = 1
local GridOffset = 0.5
menu.slider(AddPolysMenu, "Grid Size X", {"gridsizex"}, "", 0, 10, GridSizeX, 1, function(on_change)
	GridSizeX = on_change
end)
menu.slider(AddPolysMenu, "Grid Size Y", {"gridsizex"}, "", 0, 10, GridSizeY, 1, function(on_change)
	GridSizeY = on_change
end)
menu.slider_float(AddPolysMenu, "Grid Size Offset", {"gridoffset"}, "", 50, 500, 50, 50, function(on_change)
	GridOffset = on_change / 100
end)
local GridRotationX = 0.0
local GridRotationY = 0.0
local GridRotationZ = 0.0
menu.slider_float(AddPolysMenu, "Grid Rotation X", {"gridrotationx"}, "", 0, 36000, 0, 1000, function(on_change)
	GridRotationX = on_change / 100
end)
menu.slider_float(AddPolysMenu, "Grid Rotation Y", {"gridrotationy"}, "", 0, 36000, 0, 1000, function(on_change)
	GridRotationY = on_change / 100
end)
menu.slider_float(AddPolysMenu, "Grid Rotation Z", {"gridrotationz"}, "", 0, 36000, 0, 1000, function(on_change)
	GridRotationZ = on_change / 100
end)

local AddState6 = 0
menu.action(AddPolysMenu, "Add Poly Grid", {}, "", function(Toggle)
	AddState6 = AddState6 + 1
	if AddState6 == 1 then
		Print("Press again to confirm.")
		local NewLinesT = {}
		while AddState6 == 1 do
			local PlayerPed = PLAYER.PLAYER_PED_ID()
			local Rot = ENTITY.GET_ENTITY_ROTATION(PlayerPed, 2)
			local Pos2 = ENTITY.GET_ENTITY_COORDS(PlayerPed)
			Rot.x = Rot.x + GridRotationX
			Rot.y = Rot.y + GridRotationY
			Rot.z = Rot.z + GridRotationZ
			local LinesT = {}
			for i = -GridSizeX, GridSizeX do
				local DrawsT = {}
				for k = -GridSizeY, GridSizeY do
					local Pos = GetOffsetFromRotationInWorldCoords(Rot, Pos2, -GridOffset + (GridOffset * 2) * i, GridOffset + (GridOffset * 2) * k, 1.0)
					DrawsT[#DrawsT+1] = {Pos, 255, 0, 0}
					local Pos = GetOffsetFromRotationInWorldCoords(Rot, Pos2, -GridOffset + (GridOffset * 2) * i, -GridOffset + (GridOffset * 2) * k, 1.0)
					DrawsT[#DrawsT+1] = {Pos, 0, 255, 0}
					local Pos = GetOffsetFromRotationInWorldCoords(Rot, Pos2, GridOffset + (GridOffset * 2) * i, -GridOffset + (GridOffset * 2) * k, 1.0)
					DrawsT[#DrawsT+1] = {Pos, 0, 0, 255}
					local Pos = GetOffsetFromRotationInWorldCoords(Rot, Pos2, GridOffset + (GridOffset * 2) * i, GridOffset + (GridOffset * 2) * k, 1.0)
					DrawsT[#DrawsT+1] = {Pos, 255, 255, 0}
					local Pos = GetOffsetFromRotationInWorldCoords(Rot, Pos2, -GridOffset + (GridOffset * 2) * i, GridOffset + (GridOffset * 2) * k, 1.0)
					DrawsT[#DrawsT+1] = {Pos, 0, 255, 255}
				end
				LinesT[#LinesT+1] = DrawsT
			end
			for i = 1, #LinesT do
				local kIt = 1
				while kIt <= #LinesT[i]-4 do
					GRAPHICS.DRAW_POLY(LinesT[i][kIt][1].x, LinesT[i][kIt][1].y, LinesT[i][kIt][1].z,
					LinesT[i][kIt+1][1].x, LinesT[i][kIt+1][1].y, LinesT[i][kIt+1][1].z,
					LinesT[i][kIt+2][1].x, LinesT[i][kIt+2][1].y, LinesT[i][kIt+2][1].z,
					LinesT[i][kIt+3][2], LinesT[i][kIt+3][3], LinesT[i][kIt+3][4], 100)
					GRAPHICS.DRAW_POLY(LinesT[i][kIt+3][1].x, LinesT[i][kIt+3][1].y, LinesT[i][kIt+3][1].z,
					LinesT[i][kIt+4][1].x, LinesT[i][kIt+4][1].y, LinesT[i][kIt+4][1].z,
					LinesT[i][kIt+2][1].x, LinesT[i][kIt+2][1].y, LinesT[i][kIt+2][1].z,
					LinesT[i][kIt+3][2], LinesT[i][kIt+3][3], LinesT[i][kIt+3][4], 100)
					kIt = kIt + 5
				end
			end
			for i = 1, #LinesT do
				for k = 1, #LinesT[i]-1 do
					GRAPHICS.DRAW_LINE(LinesT[i][k][1].x, LinesT[i][k][1].y, LinesT[i][k][1].z,
					LinesT[i][k+1][1].x, LinesT[i][k+1][1].y, LinesT[i][k+1][1].z, LinesT[i][k+1][2], LinesT[i][k+1][3], LinesT[i][k+1][4], 150)
				end
			end
			NewLinesT = LinesT
			Wait()
		end
		if AddState6 == 2 then
			for i = 1, #NewLinesT do
				local kIt = 1
				while kIt <= #NewLinesT[i]-4 do
					Print(#NewLinesT[i])
					Polys1[#Polys1+1] = {
						{x = NewLinesT[i][kIt][1].x, y = NewLinesT[i][kIt][1].y, z = NewLinesT[i][kIt][1].z},
						{x = NewLinesT[i][kIt+1][1].x, y = NewLinesT[i][kIt+1][1].y, z = NewLinesT[i][kIt+1][1].z},
						{x = NewLinesT[i][kIt+2][1].x, y = NewLinesT[i][kIt+2][1].y, z = NewLinesT[i][kIt+2][1].z}
					}
					Polys1[#Polys1].Center = GetPolygonCenter(Polys1[#Polys1])
					SetPolyEdges(#Polys1)
					Polys1[#Polys1+1] = {
						{x = NewLinesT[i][kIt+3][1].x, y = NewLinesT[i][kIt+3][1].y, z = NewLinesT[i][kIt+3][1].z},
						{x = NewLinesT[i][kIt+4][1].x, y = NewLinesT[i][kIt+4][1].y, z = NewLinesT[i][kIt+4][1].z},
						{x = NewLinesT[i][kIt+2][1].x, y = NewLinesT[i][kIt+2][1].y, z = NewLinesT[i][kIt+2][1].z}
					}
					Polys1[#Polys1].Center = GetPolygonCenter(Polys1[#Polys1])
					SetPolyEdges(#Polys1)
					kIt = kIt + 5
				end
			end
		end
		
		--SetAllPolysNeighboors()
	end
	if AddState6 == 2 then
		Wait()
		AddState6 = 0
	end
end)

local AddState7 = 0
menu.action(AddPolysMenu, "Add Poly Grid Raycast Manual", {}, "Use NUMPAD to move.", function(Toggle)
	AddState7 = AddState7 + 1 
	if AddState7 == 1 then
		Print("Press again to confirm.")
		local NewLinesT = {}
		local PlayerPed = PLAYER.PLAYER_PED_ID()
		local Pos2 = RaycastFromCamera(PlayerPed, 1000.0, -1)
		while AddState7 == 1 do
			local Rot = {}
			Rot.x = GridRotationX
			Rot.y = GridRotationY
			Rot.z = GridRotationZ
			if not menu.is_open() and not menu.command_box_is_open() then
				local ButtonLeftPressed = util.is_key_down(0x64)
				local ButtonRightPressed = util.is_key_down(0x66)
				local ButtonDownPressed = util.is_key_down(0x62)
				local ButtonUpPressed = util.is_key_down(0x68)
				local RotateLeftPressed = util.is_key_down(0x67)
				local RotateRightPressed = util.is_key_down(0x69)
				if ButtonDownPressed then
					Pos2.y = Pos2.y - 0.1
				end
				if ButtonUpPressed then
					Pos2.y = Pos2.y + 0.1
				end
				if ButtonLeftPressed then
					Pos2.x = Pos2.x - 0.1
				end
				if ButtonRightPressed then
					Pos2.x = Pos2.x + 0.1
				end
				if RotateLeftPressed then
					Pos2.z = Pos2.z - 0.1
				end
				if RotateRightPressed then
					Pos2.z = Pos2.z + 0.1
				end
			end
			local LinesT = {}
			for i = -GridSizeX, GridSizeX do
				local DrawsT = {}
				for k = -GridSizeY, GridSizeY do
					local Pos = GetOffsetFromRotationInWorldCoords(Rot, Pos2, -GridOffset + (GridOffset * 2) * i, GridOffset + (GridOffset * 2) * k, 2.0)
					DrawsT[#DrawsT+1] = {Pos, 255, 0, 0}
					local Pos = GetOffsetFromRotationInWorldCoords(Rot, Pos2, -GridOffset + (GridOffset * 2) * i, -GridOffset + (GridOffset * 2) * k, 2.0)
					DrawsT[#DrawsT+1] = {Pos, 0, 255, 0}
					local Pos = GetOffsetFromRotationInWorldCoords(Rot, Pos2, GridOffset + (GridOffset * 2) * i, -GridOffset + (GridOffset * 2) * k, 2.0)
					DrawsT[#DrawsT+1] = {Pos, 0, 0, 255}
					local Pos = GetOffsetFromRotationInWorldCoords(Rot, Pos2, GridOffset + (GridOffset * 2) * i, GridOffset + (GridOffset * 2) * k, 2.0)
					DrawsT[#DrawsT+1] = {Pos, 255, 255, 0}
					local Pos = GetOffsetFromRotationInWorldCoords(Rot, Pos2, -GridOffset + (GridOffset * 2) * i, GridOffset + (GridOffset * 2) * k, 2.0)
					DrawsT[#DrawsT+1] = {Pos, 0, 255, 255}
				end
				LinesT[#LinesT+1] = DrawsT
			end
			for i = 1, #LinesT do
				local kIt = 1
				while kIt <= #LinesT[i]-4 do
					GRAPHICS.DRAW_POLY(LinesT[i][kIt][1].x, LinesT[i][kIt][1].y, LinesT[i][kIt][1].z,
					LinesT[i][kIt+1][1].x, LinesT[i][kIt+1][1].y, LinesT[i][kIt+1][1].z,
					LinesT[i][kIt+2][1].x, LinesT[i][kIt+2][1].y, LinesT[i][kIt+2][1].z,
					LinesT[i][kIt+3][2], LinesT[i][kIt+3][3], LinesT[i][kIt+3][4], 100)
					GRAPHICS.DRAW_POLY(LinesT[i][kIt+3][1].x, LinesT[i][kIt+3][1].y, LinesT[i][kIt+3][1].z,
					LinesT[i][kIt+4][1].x, LinesT[i][kIt+4][1].y, LinesT[i][kIt+4][1].z,
					LinesT[i][kIt+2][1].x, LinesT[i][kIt+2][1].y, LinesT[i][kIt+2][1].z,
					LinesT[i][kIt+3][2], LinesT[i][kIt+3][3], LinesT[i][kIt+3][4], 100)
					kIt = kIt + 5
				end
			end
			for i = 1, #LinesT do
				for k = 1, #LinesT[i]-1 do
					GRAPHICS.DRAW_LINE(LinesT[i][k][1].x, LinesT[i][k][1].y, LinesT[i][k][1].z,
					LinesT[i][k+1][1].x, LinesT[i][k+1][1].y, LinesT[i][k+1][1].z, LinesT[i][k+1][2], LinesT[i][k+1][3], LinesT[i][k+1][4], 150)
				end
			end
			NewLinesT = LinesT
			Wait()
		end
		if AddState7 == 2 then
			for i = 1, #NewLinesT do
				local kIt = 1
				while kIt <= #NewLinesT[i]-4 do
					Print(#NewLinesT[i])
					Polys1[#Polys1+1] = {
						{x = NewLinesT[i][kIt][1].x, y = NewLinesT[i][kIt][1].y, z = NewLinesT[i][kIt][1].z},
						{x = NewLinesT[i][kIt+1][1].x, y = NewLinesT[i][kIt+1][1].y, z = NewLinesT[i][kIt+1][1].z},
						{x = NewLinesT[i][kIt+2][1].x, y = NewLinesT[i][kIt+2][1].y, z = NewLinesT[i][kIt+2][1].z}
					}
					Polys1[#Polys1].Center = GetPolygonCenter(Polys1[#Polys1])
					SetPolyEdges(#Polys1)
					Polys1[#Polys1+1] = {
						{x = NewLinesT[i][kIt+3][1].x, y = NewLinesT[i][kIt+3][1].y, z = NewLinesT[i][kIt+3][1].z},
						{x = NewLinesT[i][kIt+4][1].x, y = NewLinesT[i][kIt+4][1].y, z = NewLinesT[i][kIt+4][1].z},
						{x = NewLinesT[i][kIt+2][1].x, y = NewLinesT[i][kIt+2][1].y, z = NewLinesT[i][kIt+2][1].z}
					}
					Polys1[#Polys1].Center = GetPolygonCenter(Polys1[#Polys1])
					SetPolyEdges(#Polys1)
					kIt = kIt + 5
				end
			end
		end
		--SetAllPolysNeighboors()
	end
	if AddState7 == 2 then
		Wait()
		AddState7 = 0
	end
end)

menu.action(AddPolysMenu, "Cancel Add Poly Grid", {}, "", function(Toggle)
	AddState6 = 0
	AddState7 = 0
end)

local LinkState = 0
local LinkID = 0
local ToLinkID = 0
menu.action(AddPolysMenu, "Link Polygon To Polygon", {}, "", function(Toggle)
	local PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
	local PolyIdx = 0
	if LinkState == 0 then
		for k = 1, #Polys1 do
			if Inside3DPolygon(Polys1[k], PlayerPos) then
				PolyIdx = k
				break
			end
		end
		if PolyIdx ~= 0 then
			LinkState = 1
			LinkID = PolyIdx
			Print("Index is "..LinkID.." and now waiting for user input the next ID.")
		end
	end
	if LinkState == 1 then
		for k = 1, #Polys1 do
			if Inside3DPolygon(Polys1[k], PlayerPos) then
				PolyIdx = k
				break
			end
		end
		if PolyIdx ~= 0 then
			if PolyIdx ~= LinkID then
				ToLinkID = PolyIdx
				local CanInsert = true
				local CanInsertToID = true
				if Polys1[LinkID].LinkedIDs ~= nil then
					for k = 1, #Polys1[LinkID].LinkedIDs do
						if Polys1[LinkID].LinkedIDs[k] == ToLinkID then
							CanInsert = false
							break
						end
					end
				end
				if Polys1[ToLinkID].LinkedIDs ~= nil then
					for k = 1, #Polys1[ToLinkID].LinkedIDs do
						if Polys1[ToLinkID].LinkedIDs[k] == LinkID then
							CanInsertToID = false
							break
						end
					end
				end
				if CanInsert then
					if Polys1[LinkID].LinkedIDs == nil then
						Polys1[LinkID].LinkedIDs = {}
					end
					Polys1[LinkID].LinkedIDs[#Polys1[LinkID].LinkedIDs+1] = ToLinkID
				end
				if CanInsertToID then
					if Polys1[ToLinkID].LinkedIDs == nil then
						Polys1[ToLinkID].LinkedIDs = {}
					end
					Polys1[ToLinkID].LinkedIDs[#Polys1[ToLinkID].LinkedIDs+1] = LinkID
					Print("Index ".. LinkID.." and index "..ToLinkID.." are linked.")
				end
				ToLinkID = 0
				LinkID = 0
				LinkState = 0
			end
		end
	end
end)

local LinkState2 = 0
local LinkID2 = 0
local ToLinkID2 = 0
menu.action(AddPolysMenu, "Link Polygon To Polygon 2", {}, "Only the previous polygon will have the next polygon as neighbor id.", function(Toggle)
	local PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
	local PolyIdx = 0
	if LinkState2 == 0 then
		for k = 1, #Polys1 do
			if Inside3DPolygon(Polys1[k], PlayerPos) then
				PolyIdx = k
				break
			end
		end
		if PolyIdx ~= 0 then
			LinkState2 = 1
			LinkID2 = PolyIdx
			Print("Index is "..LinkID2.." and now waiting for user input the next ID.")
		end
	end
	if LinkState2 == 1 then
		for k = 1, #Polys1 do
			if Inside3DPolygon(Polys1[k], PlayerPos) then
				PolyIdx = k
				break
			end
		end
		if PolyIdx ~= 0 then
			if PolyIdx ~= LinkID2 then
				ToLinkID2 = PolyIdx
				local CanInsertToID = true
				if Polys1[LinkID2].LinkedIDs ~= nil then
					for k = 1, #Polys1[LinkID2].LinkedIDs do
						if Polys1[LinkID2].LinkedIDs[k] == ToLinkID2 then
							CanInsertToID = false
							break
						end
					end
				end
				if CanInsertToID then
					if Polys1[LinkID2].LinkedIDs == nil then
						Polys1[LinkID2].LinkedIDs = {}
					end
					Polys1[LinkID2].LinkedIDs[#Polys1[LinkID2].LinkedIDs+1] = ToLinkID2
					Print("Index ".. LinkID2.." and index "..ToLinkID2.." are linked.")
				end
				
				ToLinkID2 = 0
				LinkID2 = 0
				LinkState2 = 0
			end
		end
	end
end)

menu.action(AddPolysMenu, "Clear Linked Polygons To Selected", {}, "", function(Toggle)
	local PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
	local PolyIdx = 0
	for k = 1, #Polys1 do
		if Inside3DPolygon(Polys1[k], PlayerPos) then
			PolyIdx = k
			break
		end
	end
	if PolyIdx ~= 0 then
		for k = 1, #Polys1[PolyIdx].LinkedIDs do
			table.remove(Polys1[PolyIdx].LinkedIDs, #Polys1[PolyIdx].LinkedIDs)
		end
		--Polys1[PolyIdx].LinkedIDs = nil
	end
end)

menu.action(AddPolysMenu, "Clear All Linked Polygons", {}, "", function(Toggle)
	local PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
	local PolyIdx = 0
	for k = 1, #Polys1 do
		for i = 1, #Polys1[k].LinkedIDs do
			table.remove(Polys1[k].LinkedIDs, #Polys1[k].LinkedIDs)
		end
	end
end)

local PointToPolyIndex = 0
menu.action(AddPolysMenu, "Add Point To Polygon", {}, "", function(Toggle)
	local PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
	if PointToPolyIndex == 0 then
		local PolyIdx = 0
		for k = 1, #Polys1 do
			if Inside3DPolygon(Polys1[k], PlayerPos) then
				PolyIdx = k
				break
			end
		end
		if PolyIdx ~= 0 then
			PointToPolyIndex = PolyIdx
			Print("Now place the point to the desired coords.")
		end
	else
		if PointToPolyIndex ~= 0 then
			Polys1[PointToPolyIndex].Point = {
				x = PlayerPos.x,
				y = PlayerPos.y,
				z = PlayerPos.z,
				Heading = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
			}
			Print("Point added to polygon index "..PointToPolyIndex..".")
			PointToPolyIndex = 0
		end
	end
end)

menu.action(AddPolysMenu, "Delete Selected Poly Point", {}, "", function(Toggle)
	local PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
	local PolyIdx = 0
	for k = 1, #Polys1 do
		if Inside3DPolygon(Polys1[k], PlayerPos) then
			PolyIdx = k
			break
		end
	end
	if PolyIdx ~= 0 then
		Polys1[PolyIdx].Point = nil
	end
end)

menu.action(AddPolysMenu, "Calculate All Polygon Neighbors", {}, "", function(Toggle)
	SetAllPolysNeighboors()
end)

local PolygonLoadOrSaveMenu = menu.list(NavmeshingMenu, "Save Load Polygons", {}, "")
menu.action(PolygonLoadOrSaveMenu, "Save Polys", {}, "", function(Toggle)
	local ToJSON = {}
	for k = 1, #Polys1 do
		ToJSON[#ToJSON+1] = {
			Poly1 = Polys1[k][1],
			Poly2 = Polys1[k][2],
			Poly3 = Polys1[k][3],
			Center = Polys1[k].Center,
			Neighboors = Polys1[k].Neighboors,
			LinkedIDs = Polys1[k].LinkedIDs,
			Flags = Polys1[k].Flags,
			Point = Polys1[k].Point,
			JumpTo = Polys1[k].JumpTo or nil,
			JumpedFrom = Polys1[k].JumpedFrom or nil
		}
	end
	SaveJSONFile(filesystem.scripts_dir().."\\navs\\LastNav.json", ToJSON)
end)

menu.action(PolygonLoadOrSaveMenu, "Load Polys", {}, "", function(Toggle)
	local Contents = LoadJSONFile(filesystem.scripts_dir().."\\navs\\LastNav.json")
	for k = 1, #Contents do
		Polys1[#Polys1+1] = {
			{x = Contents[k].Poly1.x, y = Contents[k].Poly1.y, z = Contents[k].Poly1.z},
			{x = Contents[k].Poly2.x, y = Contents[k].Poly2.y, z = Contents[k].Poly2.z},
			{x = Contents[k].Poly3.x, y = Contents[k].Poly3.y, z = Contents[k].Poly3.z},
			Center = {x = Contents[k].Center.x, y = Contents[k].Center.y,  z = Contents[k].Center.z},
			--Neighboors = Contents[k].Neighboors
		}
	end
end)

local TestMenu = menu.list(NavmeshingMenu, "Test Navigation", {}, "")
local StartPath = {x = 113.82311248779, y = -697.71612548828, z = 342.03619384766}

local NavNetID = 0
local NavHandle = 0
local PedNav = false
menu.toggle(TestMenu, "Create Ped For Nav", {}, "", function(Toggle)
	PedNav = Toggle
	if not PedNav then
		if NavNetID ~= 0 then
			NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NavNetID, PLAYER.PLAYER_ID(), false)
		end
		entities.delete_by_handle(NavHandle)
	end
	if PedNav then
		local StartPos = {x = StartPath.x, y = StartPath.y, z = StartPath.z}
		local GoToCoords = {x = -955.48394775391, y = 166.00401306152, z = 373.17413330078}
		STREAMING.REQUEST_MODEL(joaat("mp_m_bogdangoon"))
		while not STREAMING.HAS_MODEL_LOADED(joaat("mp_m_bogdangoon")) do
			Wait()
		end
		--local Pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
		NavHandle = PED.CREATE_PED(28, joaat("mp_m_bogdangoon"), StartPos.x, StartPos.y, StartPos.z, 0.0, true, true)
		WEAPON.GIVE_WEAPON_TO_PED(NavHandle, joaat("weapon_pistol"), 99999, false, true)
		ENTITY.SET_ENTITY_AS_MISSION_ENTITY(NavHandle, false, true)
		NavNetID = NETWORK.PED_TO_NET(NavHandle)
		if NavNetID ~= 0 then
			--NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NavNetID, PLAYER.PLAYER_ID(), true)
			--NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(NavNetID, true)
			NETWORK.SET_NETWORK_ID_CAN_MIGRATE(NavNetID, false)
		end
		local FoundIndex = 0
		local TaskStatus = 0
		local TaskCoords = {x = 0.0, y = 0.0, z = 0.0}
		local FoundPaths = nil
		local PathIndex = 1
		local InPolyIndex = 1
		local TargetPolyIndex = 1
		local InsideStartPolygon = false
		local TargetInsideTargetPolygon = false
		local LastTargetPos = {x = 0.0, y = 0.0, z = 0.0}
		while PedNav do
			local Pos = ENTITY.GET_ENTITY_COORDS(NavHandle)
			local PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
			--PED.SET_PED_MIN_MOVE_BLEND_RATIO(NavHandle, 3.0)
			--PED.SET_PED_MAX_MOVE_BLEND_RATIO(NavHandle, 3.0)
			if FoundIndex == 0 then
				FoundPaths, InPolyIndex, TargetPolyIndex, InsideStartPolygon, TargetInsideTargetPolygon = AStarPathFind(Pos, PlayerPos, 3, nil, nil, nil, nil, nil, nil, false)
				if FoundPaths ~= nil then
					FoundIndex = 1
					LastTargetPos = PlayerPos
					--Print(#FoundPaths)
				end
			else
				if FoundPaths ~= nil then
					if TaskStatus == 0 then
						if PathIndex > #FoundPaths then
							PathIndex = 1
						end
						TaskCoords = FoundPaths[PathIndex]
						--Print(FoundPaths[PathIndex].NodeFlags)
						if not ENTITY.IS_ENTITY_AT_COORD(NavHandle, TaskCoords.x, TaskCoords.y, TaskCoords.z, 0.5, 0.5, 1.0, false, false, 0) then
							--local NewV3 = v3.new(TaskCoords.x, TaskCoords.y, TaskCoords.z)
							--local Sub = v3.sub(NewV3, Pos)
							--local Rot = Sub:toRot()
							--Dir = Rot:toDir()
							if RequestControlOfEntity(NavHandle) then
								
								TASK.TASK_GO_STRAIGHT_TO_COORD(NavHandle, TaskCoords.x, TaskCoords.y, TaskCoords.z, 3.0, -1, 40000.0, 0.0)
								--TASK.TASK_GO_TO_COORD_ANY_MEANS(NavHandle, TaskCoords.x, TaskCoords.y, TaskCoords.z, 2.0, 0, false, 1, -1.0)
								if TASK.GET_SCRIPT_TASK_STATUS(NavHandle, joaat("SCRIPT_TASK_GO_STRAIGHT_TO_COORD")) ~= 7 then
									--TASK.TASK_GO_TO_COORD_WHILE_AIMING_AT_ENTITY(NavHandle, TaskCoords.x, TaskCoords.y, TaskCoords.z, PLAYER.PLAYER_PED_ID(), 2.0, true, 0.1, 0.1, false, 0, true, joaat("FIRING_PATTERN_FULL_AUTO"), -1)
									TaskStatus = 1
								end
							end
						else
							TaskStatus = 1
						end
					end
					if TaskStatus == 1 then
						RequestControlOfEntity(NavHandle)
						if TASK.GET_SCRIPT_TASK_STATUS(NavHandle, joaat("SCRIPT_TASK_GO_STRAIGHT_TO_COORD")) == 7 then
							TaskStatus = 0
						end
						if ENTITY.IS_ENTITY_AT_COORD(NavHandle, TaskCoords.x, TaskCoords.y, TaskCoords.z, 0.5, 0.5, 1.0, false, false, 0) then
							if FoundPaths[PathIndex].Action ~= nil then
								--Print("Action isn't nil")
								--if is_bit_set(FoundPaths[PathIndex].Action, FlagBitNames.Jump) then
									TASK.TASK_CLIMB(NavHandle, false)
									--Print("Climb")
									Wait(1000)
								--end
							end
							TaskStatus = 0
							PathIndex = PathIndex + 1
							if PathIndex > #FoundPaths then
								FoundIndex = 0
								PathIndex = 1
							end
						end
					end
					GRAPHICS.DRAW_LINE(Pos.x, Pos.y, Pos.z,
					TaskCoords.x, TaskCoords.y, TaskCoords.z, 255, 255, 255, 255)
					--if not InsidePolygon(Polys1[InPolyIndex], Pos) then
						if TargetInsideTargetPolygon or DistanceBetween(PlayerPos.x, PlayerPos.y, PlayerPos.z, LastTargetPos.x, LastTargetPos.y ,LastTargetPos.z) > 2.0 then
							if not InsidePolygon(Polys1[TargetPolyIndex], PlayerPos) then
								FoundIndex = 0
								TaskStatus = 0

							end
						else
							if InsidePolygon(Polys1[TargetPolyIndex], PlayerPos) then
								FoundIndex = 0
								TaskStatus = 0
							end
						end
					--end
				end
			end
			Wait()
		end
	end
end)

local GetPathToPoly2 = false
menu.toggle(TestMenu, "Get Path To Poly", {}, "", function(Toggle)
	GetPathToPoly2 = Toggle
	if GetPathToPoly2 then
		--local Pos = {x = 1382.1535644531, y = -3301.1430664062, z = 3.5249807834625}
		--local Pos = {x = 1370.142578125, y = -3324.0402832031, z = 3.5249841213226}
		local Pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
		--local GoToCoords = {x = -955.48394775391, y = 166.00401306152, z = 373.17413330078}
		
		local FinalPaths = AStarPathFind(StartPath, Pos, 0, true, nil, nil, true, false, true)
		if FinalPaths ~= nil then
			Print(#FinalPaths)
			while GetPathToPoly2 do
				for i = 1, #FinalPaths-1 do
					GRAPHICS.DRAW_LINE(FinalPaths[i].x, FinalPaths[i].y, FinalPaths[i].z,
					FinalPaths[i+1].x, FinalPaths[i+1].y, FinalPaths[i+1].z, 255, 255, 255, 255)
					--GRAPHICS.DRAW_MARKER(28, FinalPaths[i+1].x,
					--FinalPaths[i+1].y, FinalPaths[i+1].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 10 + 30 * i, 100, 0, 100, 0, false, 2, false, 0, 0, false)
				end
				if #FinalPaths == 1 then
					--Print("Yeah")
					--GRAPHICS.DRAW_LINE(StartPath.x, StartPath.y, StartPath.z,
					--FinalPaths[1].x, FinalPaths[1].y, FinalPaths[1].z, 255, 255, 255, 255)
				end
				Wait()
			end
		end
	end
end)

local GetPathToPoly3 = false
menu.toggle(TestMenu, "Get Path To Poly Real Time", {}, "", function(Toggle)
	GetPathToPoly3 = Toggle
	if GetPathToPoly3 then
		local SearchState = 0
		local FoundPaths = nil
		local PathIndex = 1
		local StartPolyIndex = nil
		local TargetPolyIndex = nil
		local LastTargetPolyIndex = 0
		local InsideStartPolygon = false
		local TargetInsideTargetPolygon = false
		local StartPolysT = {}
		local TargetPolysT = {}
		local FinalPaths = nil
		while GetPathToPoly3 do
			local Pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
			if SearchState == 0 then
				FinalPaths, StartPolyIndex, TargetPolyIndex = AStarPathFind(StartPath, Pos, 1, true, StartPolyIndex, TargetPolyIndex, true, false, true)
				if FinalPaths ~= nil then
					TargetPolysT = GetNearPolygonNeighbors(TargetPolyIndex, 10)
					SearchState = 1
				end
			end
			if SearchState == 2 then
				FinalPaths, StartPolyIndex, TargetPolyIndex = AStarPathFind(StartPath, Pos, 1, true, StartPolyIndex, TargetPolyIndex, true, false, true)
				if FinalPaths ~= nil then
					SearchState = 1
				end
			end
			if TargetPolyIndex ~= nil then
				local IsInsidePolygon = false
				TargetPolyIndex, IsInsidePolygon = TrackPolygonIndex(TargetPolysT, TargetPolyIndex, Pos, 10)
				if not IsInsidePolygon then
					SearchState = 2
				end
			end
			if FinalPaths ~= nil then
				for i = 1, #FinalPaths-1 do
					GRAPHICS.DRAW_LINE(FinalPaths[i].x, FinalPaths[i].y, FinalPaths[i].z,
					FinalPaths[i+1].x, FinalPaths[i+1].y, FinalPaths[i+1].z, 255, 255, 255, 255)
				end
				if #FinalPaths == 1 then
					Print("Yeah")
					GRAPHICS.DRAW_LINE(StartPath.x, StartPath.y, StartPath.z,
					FinalPaths[1].x, FinalPaths[1].y, FinalPaths[1].z, 255, 255, 255, 255)
				end
			end
			Wait()
		end
	end
end)

local CarHandle = 0
local CarPathToPoly = false
menu.toggle(TestMenu, "Car Path To Poly", {}, "", function(Toggle)
	CarPathToPoly = Toggle
	if not CarPathToPoly then
		entities.delete_by_handle(CarHandle)
	end
	if CarPathToPoly then
		--local Pos = {x = 1382.1535644531, y = -3301.1430664062, z = 3.5249807834625}
		--local Pos = {x = 1370.142578125, y = -3324.0402832031, z = 3.5249841213226}
		local Pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
		--local GoToCoords = {x = -955.48394775391, y = 166.00401306152, z = 373.17413330078}
		local TaskState = 1
		local FinalPaths = AStarPathFind(StartPath, Pos, 1)
		local ActualPath = 1
		local TaskCoords = {x = 0.0, y = 0.0, z = 0.0}
		if FinalPaths ~= nil then
			local ModelName = "panto"
			STREAMING.REQUEST_MODEL(joaat(ModelName))
			while not STREAMING.HAS_MODEL_LOADED(joaat(ModelName)) do
				Wait()
			end
			CarHandle = VEHICLE.CREATE_VEHICLE(joaat(ModelName), StartPath.x, StartPath.y, StartPath.z, 0.0, true, true, false)
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(joaat(ModelName))
			while CarPathToPoly do
				local StartPos = ENTITY.GET_ENTITY_COORDS(CarHandle)
				if TaskState == 0 then
					Pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
					FinalPaths = AStarPathFind(StartPos, Pos, 1, nil, nil, nil, nil, nil, nil, true)
					if FinalPaths ~= nil then
						TaskState = 1
					end
				end
				if TaskState == 1 then
					if ActualPath > #FinalPaths then
						TaskState = 0
						ActualPath = 1
					end
					TaskCoords = FinalPaths[ActualPath]
					local Sub = {
						x = TaskCoords.x - StartPos.x,
						y = TaskCoords.y - StartPos.y,
						z = TaskCoords.z - StartPos.z
					}
					local NewV3 = v3.new(Sub.x, Sub.y, Sub.z)
					NewV3:normalise()
					if RequestControlOfEntity(CarHandle) then
						local ActualVel = ENTITY.GET_ENTITY_VELOCITY(CarHandle)
						if NewV3.x < 6.0 and NewV3.x > -6.0 then
							ENTITY.SET_ENTITY_VELOCITY(CarHandle, NewV3.x * 5.0, NewV3.y * 5.0, ActualVel.z)
						end
					end
					if ENTITY.IS_ENTITY_AT_COORD(CarHandle, TaskCoords.x, TaskCoords.y, TaskCoords.z, 0.5, 0.5, 1.5, false, true, 0) then
						ActualPath = ActualPath + 1
					end
				end
				Wait()
			end
		end
	end
end)

local NavNetID2 = 0
local NavHandle2 = 0
local CarHandle2 = 0
local PedNav2 = false
menu.toggle(TestMenu, "Create Ped In Car For Nav", {}, "", function(Toggle)
	PedNav2 = Toggle
	if not PedNav2 then
		if NavNetID2 ~= 0 then
			NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NavNetID2, PLAYER.PLAYER_ID(), false)
		end
		entities.delete_by_handle(NavHandle2)
		entities.delete_by_handle(CarHandle2)
	end
	if PedNav2 then
		local StartPos = {x = StartPath.x, y = StartPath.y, z = StartPath.z}
		local GoToCoords = {x = -955.48394775391, y = 166.00401306152, z = 373.17413330078}
		STREAMING.REQUEST_MODEL(joaat("mp_m_bogdangoon"))
		while not STREAMING.HAS_MODEL_LOADED(joaat("mp_m_bogdangoon")) do
			Wait()
		end
		NavHandle2 = PED.CREATE_PED(28, joaat("mp_m_bogdangoon"), StartPos.x, StartPos.y, StartPos.z, 0.0, true, true)
		WEAPON.GIVE_WEAPON_TO_PED(NavHandle2, joaat("weapon_pistol"), 99999, false, true)
		NavNetID2 = NETWORK.PED_TO_NET(NavHandle2)
		if NavNetID ~= 0 then
			NETWORK.SET_NETWORK_ID_CAN_MIGRATE(NavNetID2, false)
		end
		local ModelName = "bati"
		STREAMING.REQUEST_MODEL(joaat(ModelName))
		while not STREAMING.HAS_MODEL_LOADED(joaat(ModelName)) do
			Wait()
		end
		CarHandle2 = VEHICLE.CREATE_VEHICLE(joaat(ModelName), StartPath.x, StartPath.y, StartPath.z, ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID()), true, true, false)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(joaat(ModelName))
		PED.SET_PED_INTO_VEHICLE(NavHandle2, CarHandle2, -1)
		local FoundIndex = 0
		local TaskStatus = 0
		local TaskCoords = {x = 0.0, y = 0.0, z = 0.0}
		local FoundPaths = nil
		local PathIndex = 1
		local InPolyIndex = nil
		local TargetPolyIndex = nil
		local InsideStartPolygon = false
		local TargetInsideTargetPolygon = false
		local StartPolysT = {}
		local TargetPolysT = {}
		local LastDistance = 0.0
		local MinDist = 5.5
		local DistState = 1
		while PedNav2 do
			local Pos = ENTITY.GET_ENTITY_COORDS(NavHandle2)
			local PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
			if FoundIndex == 0 then
				FoundPaths, InPolyIndex, TargetPolyIndex, InsideStartPolygon, TargetInsideTargetPolygon = AStarPathFind(Pos, PlayerPos, 1, false, nil, nil, true, nil, nil, true, true)
				if FoundPaths ~= nil then
					FoundIndex = 2
					Print(#FoundPaths)
					--StartPolysT = GetNearPolygonNeighbors(InPolyIndex, 10)
					--TargetPolysT = GetNearPolygonNeighbors(TargetPolyIndex, 10)
					LastDistance = 1000.0
				end
			end
			if FoundIndex == 1 then
				FoundPaths, InPolyIndex, TargetPolyIndex, InsideStartPolygon, TargetInsideTargetPolygon = AStarPathFind(Pos, PlayerPos, 1, false, nil, nil, true, nil, nil, true, true)
				if FoundPaths ~= nil then
					FoundIndex = 2
					LastDistance = 1000.0
				end
			end
			if FoundPaths ~= nil then
				local Distance = DistanceBetween(Pos.x, Pos.y, Pos.z, PlayerPos.x, PlayerPos.y, PlayerPos.z)
				local IsInsidePolygon = true
				if InPolyIndex ~= nil then
					--InPolyIndex, IsInsidePolygon = TrackPolygonIndex(StartPolysT, InPolyIndex, Pos, 10)
				end
				local IsInsidePolygon2 = true
				if TargetPolyIndex ~= nil then
					--TargetPolyIndex, IsInsidePolygon2 = TrackPolygonIndex(TargetPolysT, TargetPolyIndex, PlayerPos, 10)
				end
				if Distance < 10.0 then
					if not IsInsidePolygon2 then
						FoundIndex = 1
					end
				end
				if TaskStatus == 0 then
					if PathIndex > #FoundPaths then
						PathIndex = 1
					end
					TaskCoords = FoundPaths[PathIndex]
					if not ENTITY.IS_ENTITY_AT_COORD(NavHandle2, TaskCoords.x, TaskCoords.y, TaskCoords.z, 1.0, 1.0, 1.0, false, true, 0) then
						if RequestControlOfEntity(NavHandle2) then
							TASK.TASK_VEHICLE_DRIVE_TO_COORD(NavHandle2, CarHandle2, TaskCoords.x, TaskCoords.y, TaskCoords.z, 350.0, 1, joaat(ModelName), 16777216, 0.01, 40000.0)
							TaskStatus = 1
							LastDistance = DistanceBetween(Pos.x, Pos.y, Pos.z, TaskCoords.x, TaskCoords.y, TaskCoords.z)
						end
					else
						TaskStatus = 1
					end
				end
				if TaskStatus == 1 then
					local Distance2 = DistanceBetween(Pos.x, Pos.y, Pos.z, TaskCoords.x, TaskCoords.y, TaskCoords.z)
					if DistState == 0 then
						if math.floor(Distance2) > math.floor(LastDistance) then
							LastDistance = Distance2
							DistState = 1
						end
					end
					if DistState == 1 then
						if math.floor(Distance2) < math.floor(LastDistance) then
							LastDistance = Distance2
						end
						if math.floor(Distance2) > math.floor(LastDistance) then
							TaskStatus = 0
							PathIndex = 1
							FoundIndex = 1
							Print("Called")
						end
					end
					if ENTITY.IS_ENTITY_AT_COORD(NavHandle2, TaskCoords.x, TaskCoords.y, TaskCoords.z, MinDist, MinDist, MinDist, false, true, 0) then
						TaskStatus = 0
						PathIndex = PathIndex + 1
						if PathIndex > #FoundPaths then
							FoundIndex = 0
							PathIndex = 1
						end
					end
				end
				GRAPHICS.DRAW_LINE(Pos.x, Pos.y, Pos.z,
				TaskCoords.x, TaskCoords.y, TaskCoords.z, 255, 255, 255, 255)
			end
			Wait()
		end
	end
end)

menu.action(TestMenu, "Set Start Path", {}, "", function(Toggle)
	StartPath = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
end)

menu.action(TestMenu, "Pathfind Test", {}, "", function(Toggle)
	local PlayerPed = PLAYER.PLAYER_PED_ID()
	local Pos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
	--local StartPolyID = GetClosestPolygon(Polys1, StartPath, false)
	--local TargetPolyID = GetClosestPolygon(Polys1, Pos, false)
	--[[
	for i = 1, 1000 do
		GRAPHICS.DRAW_LINE(Polys1[StartPolyID][1].x, Polys1[StartPolyID][1].y, Polys1[StartPolyID][1].z, Polys1[StartPolyID][2].x, Polys1[StartPolyID][2].y, Polys1[StartPolyID][2].z, 255, 255, 255, 255)
		GRAPHICS.DRAW_LINE(Polys1[StartPolyID][2].x, Polys1[StartPolyID][2].y, Polys1[StartPolyID][2].z, Polys1[StartPolyID][3].x, Polys1[StartPolyID][3].y, Polys1[StartPolyID][3].z, 255, 255, 255, 255)
		GRAPHICS.DRAW_LINE(Polys1[StartPolyID][1].x, Polys1[StartPolyID][1].y, Polys1[StartPolyID][1].z, Polys1[StartPolyID][3].x, Polys1[StartPolyID][3].y, Polys1[StartPolyID][3].z, 255, 255, 255, 255)
		Wait()
	end
	]]
	local Paths = AStarPathFind(StartPath, Pos, 1, nil, nil, nil, nil, nil)
	--for i = 1, 1000 do
	--	for k = 1, #Paths do
	--		GRAPHICS.DRAW_LINE(Polys1[Paths[k].PolyID][1].x, Polys1[Paths[k].PolyID][1].y, Polys1[Paths[k].PolyID][1].z, Polys1[Paths[k].PolyID][2].x, Polys1[Paths[k].PolyID][2].y, Polys1[Paths[k].PolyID][2].z, 255, 255, 255, 255)
	--		GRAPHICS.DRAW_LINE(Polys1[Paths[k].PolyID][2].x, Polys1[Paths[k].PolyID][2].y, Polys1[Paths[k].PolyID][2].z, Polys1[Paths[k].PolyID][3].x, Polys1[Paths[k].PolyID][3].y, Polys1[Paths[k].PolyID][3].z, 255, 255, 255, 255)
	--		GRAPHICS.DRAW_LINE(Polys1[Paths[k].PolyID][1].x, Polys1[Paths[k].PolyID][1].y, Polys1[Paths[k].PolyID][1].z, Polys1[Paths[k].PolyID][3].x, Polys1[Paths[k].PolyID][3].y, Polys1[Paths[k].PolyID][3].z, 255, 255, 255, 255)
	--	end
	--	Wait()
	--end
	local NewPaths = {}
	local Finished = false
	local Start = {x = Paths[1].x, y = Paths[1].y, z = Paths[1].z}
	local End = {x = Paths[#Paths].x, y = Paths[#Paths].y, z = Paths[#Paths].z}
	local Current = 1
	local CanReach = true
	local LastIndex = 1
	for i = 1, 1000 do
		if not Finished then
			local Reached = false
			for k = Current, #Paths do
				local Intersect1 = math.findIntersect(Polys1[Paths[k].PolyID][1].x, Polys1[Paths[k].PolyID][1].y, Polys1[Paths[k].PolyID][2].x, Polys1[Paths[k].PolyID][2].y, Start.x, Start.y, End.x, End.y, true, true)
				local Intersect2 = math.findIntersect(Polys1[Paths[k].PolyID][2].x, Polys1[Paths[k].PolyID][2].y, Polys1[Paths[k].PolyID][3].x, Polys1[Paths[k].PolyID][3].y, Start.x, Start.y, End.x, End.y, true, true)
				local Intersect3 = math.findIntersect(Polys1[Paths[k].PolyID][1].x, Polys1[Paths[k].PolyID][1].y, Polys1[Paths[k].PolyID][3].x, Polys1[Paths[k].PolyID][3].y, Start.x, Start.y, End.x, End.y, true, true)
				local Intersect = Intersect1 or Intersect2 or Intersect3
				LastIndex = k
				--Start = {x = Paths[k].x, y = Paths[k].y, z = Paths[k].z}
				if not Intersect then
					Current = k
					Start = {x = Paths[Current].x, y = Paths[Current].y, z = Paths[Current].z}
					--break
				else
					if k >= #Paths then
						--Current = k
						local Amount = #Paths - (Current)
						for j = 1, Amount do
							table.remove(Paths, #Paths)
						end
						Paths[#Paths+1] = {x = End.x, y = End.y, z = End.z}
						Finished = true
						break
					end
				end
			end
			if Current >= #Paths then
				Finished = true
			end
		end
		--if Finished then
			if CanReach then
				for k = 1, #Paths-1 do
					GRAPHICS.DRAW_LINE(Paths[k].x, Paths[k].y, Paths[k].z, Paths[k+1].x, Paths[k+1].y, Paths[k+1].z, 255, 255, 255, 255)
				end
				--GRAPHICS.DRAW_LINE(Start.x, Start.y, Start.z, End.x, End.y, End.z, 255, 255, 255, 255)
			end
		--end
		Wait()
	end
end)

local GameModesMenu = menu.list(menu.my_root(), "Game Modes", {}, "Start any game mode using AI.")
local Deathmatch = false
menu.toggle(GameModesMenu, "Deathmatch", {}, "", function(Toggle)
	Deathmatch = Toggle
	if not Deathmatch then
		for index, peds in pairs(entities.get_all_peds_as_handles()) do
			if DECORATOR.DECOR_EXIST_ON(peds, "Casino_Game_Info_Decorator") then
				RequestControlOfEntity(peds)
				local NetID = NETWORK.PED_TO_NET(peds)
				if NetID ~= 0 then
					NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PLAYER.PLAYER_ID(), false)
				end
				entities.delete_by_handle(peds)
			end
		end
	end
	if Deathmatch then
		local AiTeam1Hash = joaat("rgFM_AiPed20000")
		local Peds = {}
		local HandlesT = {}
		while Deathmatch do
			if #Peds < 80 then
				if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller")) > 0 then
					for i = 1, 80 do
						local NetID = memory.read_int(memory.script_local("fm_mission_controller", 22924+834+i))
						if NetID ~= 0 then
							local PedHandle = 0
							util.spoof_script("fm_mission_controller", function()
								PedHandle = NETWORK.NET_TO_PED(NetID)
							end)
							if PedHandle ~= 0 then
								if HandlesT[PedHandle] == nil then
									Peds[#Peds+1] = {}
									Peds[#Peds].Handle = PedHandle
									Peds[#Peds].TaskState = 0
									Peds[#Peds].Target = 0
									Peds[#Peds].TaskCoords = {x = 0.0, y = 0.0, z = 0.0}
									Peds[#Peds].TaskCoords2 = {x = 0.0, y = 0.0, z = 0.0}
									Peds[#Peds].Paths = nil
									Peds[#Peds].ActualPath = 1
									Peds[#Peds].SearchState = 0
									Peds[#Peds].SearchCalled = false
									Peds[#Peds].Start = nil
									Peds[#Peds].TargetPoly = nil
									Peds[#Peds].InsideStartPolygon = false
									Peds[#Peds].TargetInsideTargetPolygon = false
									Peds[#Peds].HasSetRel = false
									Peds[#Peds].TimeOut = 0
									Peds[#Peds].SearchLowLevel = 1
									Peds[#Peds].IsInVeh = false
									Peds[#Peds].VehHandle = 0
									Peds[#Peds].LastDistance = 0.0
									Peds[#Peds].SameDistanceTick = 0
									Peds[#Peds].StartPolysT = {}
									Peds[#Peds].TargetPolysT = {}
									Peds[#Peds].DrivingStyle = 0
									Peds[#Peds].NetID = NetID
									Peds[#Peds].IsZombie = false
									Peds[#Peds].JumpDelay = 0
									Peds[#Peds].StartIndexArg = nil
									Peds[#Peds].TargetIndexArg = nil
									Peds[#Peds].AddMode = false
									Peds[#Peds].HasChecked = false
									Peds[#Peds].LastPolyID = 0
									PED.SET_PED_TARGET_LOSS_RESPONSE(PedHandle, 1)
									PED.SET_COMBAT_FLOAT(PedHandle, 2, 4000.0)
									PED.SET_PED_COMBAT_RANGE(PedHandle, 3)
									PED.SET_PED_FIRING_PATTERN(PedHandle, joaat("FIRING_PATTERN_FULL_AUTO"))
									if PED.GET_PED_RELATIONSHIP_GROUP_HASH(PedHandle) == AiTeam1Hash then
										ENTITY.SET_ENTITY_CAN_BE_DAMAGED_BY_RELATIONSHIP_GROUP(PedHandle, false, AiTeam1Hash)
									end
									HandlesT[PedHandle] = 0
								end
							end
						end
					end
				else
					for k = 1, #Peds do
						HandlesT[Peds[#Peds].Handle] = nil
						table.remove(Peds, #Peds)
					end
				end
			end
			for k = 1, #Peds do
				if Peds[k] ~= nil then
					if not ENTITY.IS_ENTITY_DEAD(Peds[k].Handle) and ENTITY.DOES_ENTITY_EXIST(Peds[k].Handle) then
						if RequestControlOfEntity(Peds[k].Handle) then
							entities.set_can_migrate(Peds[k].Handle, false)
						end
						if WEAPON.IS_PED_ARMED(Peds[k].Handle, 1) then
							Peds[k].IsZombie = true
							PED.SET_COMBAT_FLOAT(Peds[k].Handle, 7, 3.0)
							PED.SET_PED_RESET_FLAG(Peds[k].Handle, 306, true)
							PED.SET_PED_CONFIG_FLAG(Peds[k].Handle, 435, true)
						end
						if Peds[k].IsZombie then
							--PED.SET_PED_MOVE_RATE_OVERRIDE(Peds[k].Handle, 1.5)
							PED.SET_AI_MELEE_WEAPON_DAMAGE_MODIFIER(100.0)
							PED.SET_PED_USING_ACTION_MODE(Peds[k].Handle, false, -1, 0)
							PED.SET_PED_MIN_MOVE_BLEND_RATIO(Peds[k].Handle, 3.0)
							PED.SET_PED_MAX_MOVE_BLEND_RATIO(Peds[k].Handle, 3.0)
						end
						local LastEnt = ENTITY._GET_LAST_ENTITY_HIT_BY_ENTITY(Peds[k].Handle)
						if LastEnt ~= 0 then
							if ENTITY.IS_ENTITY_A_PED(LastEnt) then
								if PED.GET_PED_RELATIONSHIP_GROUP_HASH(LastEnt) == PED.GET_PED_RELATIONSHIP_GROUP_HASH(Peds[k].Handle) then
									ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(Peds[k].Handle, LastEnt, false)
								end
							end
						end
						--ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(Peds[k].Handle, LastHandle, false)
						local Pos = ENTITY.GET_ENTITY_COORDS(Peds[k].Handle)
						if not Peds[k].HasSetRel then
							if PED.DOES_RELATIONSHIP_GROUP_EXIST(AiTeam1Hash) then
								if RequestControlOfEntity(Peds[k].Handle) then
									--PED.SET_PED_RELATIONSHIP_GROUP_HASH(Peds[k].Handle, AiTeam1Hash)
									Peds[k].HasSetRel = true
								end
							end
						end
						if Peds[k].TaskState == 6 then
							--TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(Peds[k].Handle, 1000.0, 16)
							local Target = PED.GET_PED_TARGET_FROM_COMBAT_PED(Peds[k].Handle, 0)
							if Target ~= 0 then
								Peds[k].Target = Target
								Peds[k].TaskState = 1
							end
						end
						if Peds[k].TaskState == 0 then
							--TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(Peds[k].Handle, 1000.0, 16)
							local Target = PED.GET_PED_TARGET_FROM_COMBAT_PED(Peds[k].Handle, 0)
							if Target ~= 0 then
								Peds[k].Target = Target
								Peds[k].TaskState = 1
							end
						end
						if Peds[k].SearchState == 0 then
							if Peds[k].Target ~= 0 then
								local Pos = ENTITY.GET_ENTITY_COORDS(Peds[k].Handle)
								local TargetPos = ENTITY.GET_ENTITY_COORDS(Peds[k].Target)
								Peds[k].SearchState = 1
								util.create_thread(function()
									local NewPaths = nil
									NewPaths, Peds[k].Start, Peds[k].TargetPoly, Peds[k].InsideStartPolygon, Peds[k].TargetInsideTargetPolygon = AStarPathFind(Pos, TargetPos, Peds[k].SearchLowLevel, false, Peds[k].StartIndexArg, Peds[k].TargetIndexArg, true, false, nil, true)
									if NewPaths ~= nil then
										if Peds[k] ~= nil then
											if not Peds[k].AddMode then
												Peds[k].Paths = NewPaths
											else
												for i = 1, #NewPaths do
													table.insert(Peds[k].Paths, NewPaths[i])
												end
											end
											--Peds[k].SearchLowLevel = 1
											--Print("Found path")
											Peds[k].ActualPath = 1
											Peds[k].TaskState = 1
											Peds[k].StartIndexArg = nil
											Peds[k].TargetIndexArg = nil
											Peds[k].AddMode = false
										end
										--PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
									end
									
									Wait(1000)
									if Peds[k] ~= nil then
										Peds[k].SearchState = 2
										--Print("Reset")
									end
								end)
							end
						end
						if Peds[k].Target ~= 0 then
							if Peds[k].Paths ~= nil then
								local TargetPos = ENTITY.GET_ENTITY_COORDS(Peds[k].Target)
								local DistanceFinal = DistanceBetween(TargetPos.x, TargetPos.y, TargetPos.z, Peds[k].Paths[#Peds[k].Paths].x, Peds[k].Paths[#Peds[k].Paths].y, Peds[k].Paths[#Peds[k].Paths].z)
								if DistanceFinal > 30.0 then
									if Peds[k].SearchState == 2 then
										Peds[k].SearchState = 0
										Peds[k].SearchLowLevel = 4
									end
								end
								--if not Peds[k].HasChecked then
								--	if not InsidePolygon(Polys1[Peds[k].Paths[#Peds[k].Paths].PolyID], TargetPos) then
								--		if Peds[k].SearchState == 2 then
								--			Peds[k].SearchState = 0
								--			Peds[k].SearchLowLevel = 4
								--			Peds[k].StartIndexArg = Peds[k].Paths[#Peds[k].Paths].PolyID
								--			Peds[k].AddMode = true
								--			Peds[k].HasChecked = true
								--		end
								--	end
								--else
								--	if InsidePolygon(Polys1[Peds[k].Paths[#Peds[k].Paths].PolyID], TargetPos) then
								--		Peds[k].HasChecked = false
								--	end
								--end
							end
						end
						if Peds[k].TaskState == 1 then
							if Peds[k].Paths ~= nil then
								--if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_CLIMB")) == 7 then
								if not Peds[k].IsZombie then
									if RequestControlOfEntity(Peds[k].Handle) then
										--PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
										--TASK.CLEAR_PED_TASKS(Peds[k].Handle)
										if Peds[k].ActualPath > #Peds[k].Paths then
											Peds[k].ActualPath = 1
											if Peds[k].SearchState == 2 then
												Peds[k].SearchState = 0
												Peds[k].SearchLowLevel = 1
											end
										end
										if Peds[k].Paths[Peds[k].ActualPath] ~= nil then
											Peds[k].TaskCoords.x = Peds[k].Paths[Peds[k].ActualPath].x
											Peds[k].TaskCoords.y = Peds[k].Paths[Peds[k].ActualPath].y
											Peds[k].TaskCoords.z = Peds[k].Paths[Peds[k].ActualPath].z
											TASK.TASK_GO_TO_COORD_WHILE_AIMING_AT_ENTITY(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, Peds[k].Target, 2.0, true, 0.1, 0.1, false, 0, true, joaat("FIRING_PATTERN_FULL_AUTO"), -1)
											PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
											if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_GO_TO_COORD_WHILE_AIMING_AT_ENTITY")) ~= 7 then
												Peds[k].TaskState = 2
											end
										end
									end
								else
									if not ENTITY.IS_ENTITY_AT_ENTITY(Peds[k].Handle, Peds[k].Target, 5.5, 5.5, 2.5, false, true, 0) then
										if RequestControlOfEntity(Peds[k].Handle) then
											
											--TASK.CLEAR_PED_TASKS(Peds[k].Handle)
											--PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
											if Peds[k].ActualPath > #Peds[k].Paths then
												Peds[k].ActualPath = 1
												if Peds[k].SearchState == 2 then
													Peds[k].SearchState = 0
													Peds[k].SearchLowLevel = 1
												end
											end
											if Peds[k].Paths[Peds[k].ActualPath] ~= nil then
												local Pos = ENTITY.GET_ENTITY_COORDS(Peds[k].Handle)
												if Peds[k].Paths[Peds[k].ActualPath].Action ~= nil then
													if InsidePolygon(Polys1[Peds[k].Paths[Peds[k].ActualPath].PolyID], Pos) then
														Peds[k].ActualPath = Peds[k].ActualPath + 1
													end
												end
												local NewV3 = v3.new(Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z)
												local Sub = v3.sub(NewV3, Pos)
												local Rot = Sub:toRot()
												ENTITY.SET_ENTITY_HEADING(Peds[k].Handle, Rot.z, 2)
												Dir = Rot:toDir()
												Peds[k].TaskCoords.x = Peds[k].Paths[Peds[k].ActualPath].x
												Peds[k].TaskCoords.y = Peds[k].Paths[Peds[k].ActualPath].y
												Peds[k].TaskCoords.z = Peds[k].Paths[Peds[k].ActualPath].z
												Peds[k].TaskCoords2.x = Peds[k].Paths[Peds[k].ActualPath].x + Dir.x * 2.0
												Peds[k].TaskCoords2.y = Peds[k].Paths[Peds[k].ActualPath].y + Dir.y * 2.0
												Peds[k].TaskCoords2.z = Peds[k].Paths[Peds[k].ActualPath].z + Dir.z * 2.0
												Peds[k].LastDistance = DistanceBetween(Pos.x, Pos.y, Pos.z, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z)
												--TASK.TASK_GO_TO_COORD_WHILE_AIMING_AT_ENTITY(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, Peds[k].Target, 2.0, true, 0.1, 0.1, false, 0, true, joaat("FIRING_PATTERN_FULL_AUTO"), -1)
												--TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
												if Peds[k].Paths[Peds[k].ActualPath].Action == nil then
													TASK.TASK_GO_STRAIGHT_TO_COORD(Peds[k].Handle, Peds[k].TaskCoords2.x, Peds[k].TaskCoords2.y, Peds[k].TaskCoords2.z, 3.0, -1, 40000.0, 0.1)
												else
													TASK.TASK_GO_STRAIGHT_TO_COORD(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, 2.0, -1, 40000.0, 0.1)
												end
												PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
												if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_GO_STRAIGHT_TO_COORD")) ~= 7 then
													Peds[k].TaskState = 3
													--Print("Straight")
												end
											end
										end
									else
										local HasSetTask = false
										local TargetPos = ENTITY.GET_ENTITY_COORDS(Peds[k].Target)
										local Distance3 = DistanceBetween(Pos.x, Pos.y, Pos.z, TargetPos.x, TargetPos.y, TargetPos.z)
										if Distance3 < 1.5 then
											if RequestControlOfEntity(Peds[k].Handle) then
												TASK.TASK_COMBAT_PED(Peds[k].Handle, Peds[k].Target, 201326592, 16)
												PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
												if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_COMBAT")) ~= 7 then
													--Print("Combat")
													Peds[k].TaskState = 4
												end
												HasSetTask = true
											end
										end
										if not HasSetTask then
											--if Distance3 < 5.5 then
												--if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(Peds[k].Handle, Peds[k].Target, 17) then
												if CanIntersectEntity(Pos, TargetPos, Peds[k].Paths, Peds[k].ActualPath) then
													if RequestControlOfEntity(Peds[k].Handle) then
														TASK.TASK_GO_STRAIGHT_TO_COORD_RELATIVE_TO_ENTITY(Peds[k].Handle, Peds[k].Target, 0.0, 0.0, 2.0, 3.0, -1)
														PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
														if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_GO_STRAIGHT_TO_COORD_RELATIVE_TO_ENTITY")) ~= 7 then
															--Print("Combat")
															Peds[k].TaskState = 6
														end
													end
												else
													if RequestControlOfEntity(Peds[k].Handle) then
														if Peds[k].ActualPath > #Peds[k].Paths then
															Peds[k].ActualPath = 1
															if Peds[k].SearchState == 2 then
																Peds[k].SearchState = 0
																Peds[k].SearchLowLevel = 1
															end
														end
														if Peds[k].Paths[Peds[k].ActualPath] ~= nil then
															local Pos = ENTITY.GET_ENTITY_COORDS(Peds[k].Handle)
															if Peds[k].Paths[Peds[k].ActualPath].Action ~= nil then
																if InsidePolygon(Polys1[Peds[k].Paths[Peds[k].ActualPath].PolyID], Pos) then
																	Peds[k].ActualPath = Peds[k].ActualPath + 1
																end
															end
															local NewV3 = v3.new(Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z)
															local Sub = v3.sub(NewV3, Pos)
															local Rot = Sub:toRot()
															Dir = Rot:toDir()
															Peds[k].TaskCoords.x = Peds[k].Paths[Peds[k].ActualPath].x
															Peds[k].TaskCoords.y = Peds[k].Paths[Peds[k].ActualPath].y
															Peds[k].TaskCoords.z = Peds[k].Paths[Peds[k].ActualPath].z
															Peds[k].TaskCoords2.x = Peds[k].Paths[Peds[k].ActualPath].x + Dir.x * 1.0
															Peds[k].TaskCoords2.y = Peds[k].Paths[Peds[k].ActualPath].y + Dir.y * 1.0
															Peds[k].TaskCoords2.z = Peds[k].Paths[Peds[k].ActualPath].z + Dir.z * 1.0
															Peds[k].LastDistance = DistanceBetween(Pos.x, Pos.y, Pos.z, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z)
															--TASK.TASK_GO_TO_COORD_WHILE_AIMING_AT_ENTITY(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, Peds[k].Target, 2.0, true, 0.1, 0.1, false, 0, true, joaat("FIRING_PATTERN_FULL_AUTO"), -1)
															--TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
															if Peds[k].Paths[Peds[k].ActualPath].Action == nil then
																TASK.TASK_GO_STRAIGHT_TO_COORD(Peds[k].Handle, Peds[k].TaskCoords2.x, Peds[k].TaskCoords2.y, Peds[k].TaskCoords2.z, 3.0, -1, 40000.0, 0.1)
															else
																TASK.TASK_GO_STRAIGHT_TO_COORD(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, 2.0, -1, 40000.0, 0.1)
															end
															PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
															if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_GO_STRAIGHT_TO_COORD")) ~= 7 then
																Peds[k].TaskState = 3
																--Print("Straight")
															end
														end
													end
												end
											--end
										end
									end
								end
							--end
							else
								if Peds[k].SearchState == 2 then
									Peds[k].SearchState = 0
									Peds[k].SearchLowLevel = 1
								end
							end
						end
						if Peds[k].TaskState == 2 then
							if not ENTITY.IS_ENTITY_DEAD(Peds[k].Target) and ENTITY.DOES_ENTITY_EXIST(Peds[k].Target) then
								if Peds[k].Paths ~= nil then
									if Peds[k].SearchState == 2 then
										if Peds[k].TargetPoly ~= nil then
											local TargetPos = ENTITY.GET_ENTITY_COORDS(Peds[k].Target)
											if Peds[k].TargetInsideTargetPolygon then
												if not InsidePolygon(Polys1[Peds[k].TargetPoly], TargetPos) then
													--Peds[k].TaskState = 1
													if Peds[k].SearchState == 2 then
														Peds[k].SearchState = 0
													end
												end
											else
												if InsidePolygon(Polys1[Peds[k].TargetPoly], TargetPos) then
													--Peds[k].TaskState = 1
													if Peds[k].SearchState == 2 then
														Peds[k].SearchState = 0
													end
												end
											end
										else
											Peds[k].SearchState = 0
										end
									end
									if ENTITY.IS_ENTITY_AT_COORD(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, 0.15, 0.15, 100.0, false, false, 0) then
										if Peds[k].SearchState == 2 then
											Peds[k].SearchState = 0
										end
									end
									if ENTITY.IS_ENTITY_AT_COORD(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, 0.5, 0.5, 1.0, false, false, 0) then
										if RequestControlOfEntity(Peds[k].Handle) then
											PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
											--TASK.CLEAR_PED_TASKS(Peds[k].Handle)
											Peds[k].ActualPath = Peds[k].ActualPath + 1
											if Peds[k].ActualPath > #Peds[k].Paths then
												Peds[k].ActualPath = 1
												Peds[k].SearchState = 0
												Peds[k].SearchLowLevel = 1
											end
											Peds[k].TaskState = 1
										end
									else
										Peds[k].TimeOut = Peds[k].TimeOut + 1
										if Peds[k].TimeOut > 1000 then
											if Peds[k].SearchState == 2 then
												if RequestControlOfEntity(Peds[k].Handle) then
													PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
													TASK.CLEAR_PED_TASKS(Peds[k].Handle)
													Peds[k].SearchState = 0
													Peds[k].TaskState = 1
												end
											end
										end
									end
									if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_GO_TO_COORD_WHILE_AIMING_AT_ENTITY")) == 7 then
										Peds[k].TaskState = 1
										--Print("No action")
									end
								else
									if Peds[k].SearchState == 2 then
										Peds[k].SearchState = 0
										Peds[k].SearchLowLevel = 1
									end
								end
							else
								if RequestControlOfEntity(Peds[k].Handle) then
									PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
									TASK.CLEAR_PED_TASKS(Peds[k].Handle)
									Peds[k].TaskState = 0
									Peds[k].Target = 0
									Peds[k].ActualPath = 1
									Peds[k].SearchLowLevel = 1
								end
							end
						end
						GRAPHICS.DRAW_LINE(Pos.x, Pos.y, Pos.z,
						Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, 255, 255, 255, 255)
						if Peds[k].Paths ~= nil then
							for i = Peds[k].ActualPath, #Peds[k].Paths-1 do
								GRAPHICS.DRAW_LINE(Peds[k].Paths[i].x, Peds[k].Paths[i].y, Peds[k].Paths[i].z,
								Peds[k].Paths[i+1].x, Peds[k].Paths[i+1].y, Peds[k].Paths[i+1].z, 255, 255, 255, 255)
							end
						end
						if Peds[k].TaskState == 3 then
							if Peds[k].Paths[Peds[k].ActualPath].Action ~= nil then
								if InsidePolygon(Polys1[Peds[k].Paths[Peds[k].ActualPath].PolyID], Pos) then
									Peds[k].ActualPath = Peds[k].ActualPath + 1
									Peds[k].TaskState = 1
								end
							end
							if not ENTITY.IS_ENTITY_DEAD(Peds[k].Target) and ENTITY.DOES_ENTITY_EXIST(Peds[k].Target) then
								local Distance2 = DistanceBetween(Pos.x, Pos.y, Pos.z, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z)
								Peds[k].SameDistanceTick = Peds[k].SameDistanceTick + 1
								local HasSet = false
								if Distance2 < Peds[k].LastDistance then
									Peds[k].LastDistance = Distance2
									Peds[k].SameDistanceTick = 0
								end
								--Distance2 > Peds[k].LastDistance then
								if Peds[k].SameDistanceTick > 50 or math.floor(Distance2) > math.floor(Peds[k].LastDistance) then
									--Peds[k].TaskState = 1
									--Peds[k].ActualPath = Peds[k].ActualPath + 1
									--if Peds[k].ActualPath > #Peds[k].Paths then
									--	Peds[k].ActualPath = 1
									--	if Peds[k].SearchState == 2 then
									--		Peds[k].SearchState = 0
									--	end
									--end
									if Peds[k].SearchState == 2 then
										Peds[k].SearchState = 0
										Peds[k].SearchLowLevel = 1
									end
								end
								if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_GO_STRAIGHT_TO_COORD")) == 7 then
									if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_CLIMB")) == 7 then
										if RequestControlOfEntity(Peds[k].Handle) then
											Peds[k].TaskState = 1
											TASK.TASK_GO_STRAIGHT_TO_COORD(Peds[k].Handle, Peds[k].TaskCoords2.x, Peds[k].TaskCoords2.y, Peds[k].TaskCoords2.z, 3.0, -1, 40000.0, 0.1)
										end
									end
								end
								if not HasSet then
									if ENTITY.IS_ENTITY_AT_ENTITY(Peds[k].Handle, Peds[k].Target, 5.0, 5.0, 2.5, false, true, 0) then
										if RequestControlOfEntity(Peds[k].Handle) then
											--PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
											--TASK.CLEAR_PED_TASKS(Peds[k].Handle)
											Peds[k].TaskState = 1
											--HasSet = true
											Peds[k].SameDistanceTick = 0
										end
									end
								end
								local R = 1.0
								if Peds[k].Paths[Peds[k].ActualPath].Action ~= nil then
									R = 1.0
								end
								if not HasSet then
									if ENTITY.IS_ENTITY_AT_COORD(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, R, R, 1.0, false, false, 0) or
									ENTITY.IS_ENTITY_AT_COORD(Peds[k].Handle, Peds[k].TaskCoords2.x, Peds[k].TaskCoords2.y, Peds[k].TaskCoords2.z, 0.5, 0.5, 1.0, false, false, 0) then
										if Peds[k].Paths[Peds[k].ActualPath].Action ~= nil then
											if is_bit_set(Peds[k].Paths[Peds[k].ActualPath].Action, FlagBitNames.Jump) then
												--TASK.CLEAR_PED_TASKS(Peds[k].Handle)
												--TASK.CLEAR_PED_TASKS_IMMEDIATELY(Peds[k].Handle)
												ENTITY.SET_ENTITY_HEADING(Peds[k].Handle, Peds[k].Paths[Peds[k].ActualPath].Heading)
												--TASK.TASK_JUMP(Peds[k].Handle, false, false, false)
												TASK.TASK_CLIMB(Peds[k].Handle, false)
												--if PED.IS_PED_CLIMBING(Peds[k].Handle) or PED.IS_PED_JUMPING(Peds[k].Handle) then
												--if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_CLIMB")) ~= 7 then
													Peds[k].JumpDelay = 10
													Peds[k].TaskState = 5
												--end
												
											end
										else
											Peds[k].ActualPath = Peds[k].ActualPath + 1
											if Peds[k].ActualPath > #Peds[k].Paths then
												Peds[k].ActualPath = 1
												if Peds[k].SearchState == 2 then
													Peds[k].SearchState = 0
													Peds[k].SearchLowLevel = 1
												end
											end
											Peds[k].TaskState = 1
											Peds[k].SameDistanceTick = 0
										end
										
									end
								end
							else
								Peds[k].TaskState = 0
								Peds[k].Target = 0
							end
						end
						if Peds[k].TaskState == 4 then
							if not ENTITY.IS_ENTITY_DEAD(Peds[k].Target) and ENTITY.DOES_ENTITY_EXIST(Peds[k].Target) then
								if not ENTITY.IS_ENTITY_AT_ENTITY(Peds[k].Handle, Peds[k].Target, 2.5, 2.5, 2.5, false, true, 0) then
									if RequestControlOfEntity(Peds[k].Handle) then
										PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
										TASK.CLEAR_PED_TASKS(Peds[k].Handle)
										Peds[k].TaskState = 1
										if Peds[k].SearchState == 2 then
											Peds[k].SearchState = 0
											Peds[k].SearchLowLevel = 1
										end
									end
								end
							else
								if RequestControlOfEntity(Peds[k].Handle) then
									PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
									TASK.CLEAR_PED_TASKS(Peds[k].Handle)
									Peds[k].TaskState = 0
									Peds[k].Target = 0
								end
							end
						end
						if Peds[k].TaskState == 5 then
							if not PED.IS_PED_CLIMBING(Peds[k].Handle) and not PED.IS_PED_JUMPING(Peds[k].Handle) then
								Peds[k].JumpDelay = Peds[k].JumpDelay - 1
								if Peds[k].JumpDelay <= 0 then
								--if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_CLIMB")) == 7 then
									Peds[k].ActualPath = Peds[k].ActualPath + 1
									if Peds[k].ActualPath > #Peds[k].Paths then
										Peds[k].ActualPath = 1
										if Peds[k].SearchState == 2 then
											Peds[k].SearchState = 0
											Peds[k].SearchLowLevel = 1
										end
									end
									Peds[k].TaskState = 1
									Peds[k].SameDistanceTick = 0
								end
							end
						end
						if Peds[k].TaskState == 6 then
							if not ENTITY.IS_ENTITY_DEAD(Peds[k].Target) and ENTITY.DOES_ENTITY_EXIST(Peds[k].Target) then
								if ENTITY.IS_ENTITY_AT_ENTITY(Peds[k].Handle, Peds[k].Target, 1.0, 1.0, 2.5, false, true, 0) or not CanIntersectEntity(Pos, ENTITY.GET_ENTITY_COORDS(Peds[k].Target, Peds[k].Paths, Peds[k].ActualPath)) then
									if RequestControlOfEntity(Peds[k].Handle) then
										PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
										TASK.CLEAR_PED_TASKS(Peds[k].Handle)
										Peds[k].TaskState = 1
										if Peds[k].SearchState == 2 then
											Peds[k].SearchState = 0
											Peds[k].SearchLowLevel = 1
										end
									end
								end
							else
								if RequestControlOfEntity(Peds[k].Handle) then
									PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
									TASK.CLEAR_PED_TASKS(Peds[k].Handle)
									Peds[k].TaskState = 0
									Peds[k].Target = 0
								end
							end
						end
					else
						--if RequestControlOfEntity(Peds[k].Handle) then
							--set_entity_as_no_longer_needed(Peds[k].Handle)
							HandlesT[Peds[k].Handle] = nil
							table.remove(Peds, k)
						--end
					end
				end
			end
			Wait()
		end
	end
end)

local RPGVSInsurgents = false
menu.toggle(GameModesMenu, "RPG VS Insurgents", {}, "", function(Toggle)
	RPGVSInsurgents = Toggle
	if not RPGVSInsurgents then
		for index, peds in pairs(entities.get_all_peds_as_handles()) do
			if DECORATOR.DECOR_EXIST_ON(peds, "Casino_Game_Info_Decorator") then
				RequestControlOfEntity(peds)
				local NetID = NETWORK.PED_TO_NET(peds)
				if NetID ~= 0 then
					NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PLAYER.PLAYER_ID(), false)
				end
				entities.delete_by_handle(peds)
			end
		end
	end
	if RPGVSInsurgents then
		local MinOffset = -1.0
		local MaxOffset = 0.0
		local AiTeam1Hash = joaat("rgFM_AiPed20000")
		local AiTeam2Hash = joaat("rgFM_AiPed02000")
		local Peds = {}
		local HandlesT = {}
		local Team1Hash = joaat("rgFM_PlayerTeam0")
		while RPGVSInsurgents do
			if PED.DOES_RELATIONSHIP_GROUP_EXIST(AiTeam1Hash) and PED.DOES_RELATIONSHIP_GROUP_EXIST(AiTeam2Hash) then
				PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, AiTeam1Hash, AiTeam2Hash)
				PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, AiTeam2Hash, AiTeam1Hash)
			end
			if #Peds < 40 then
				--for index, peds in pairs(entities.get_all_peds_as_handles()) do
					--local EntScript = ENTITY.GET_ENTITY_SCRIPT(peds, 0)
					--if EntScript ~= nil then
						--if EntScript == "FM_Mission_Controller" then
				if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller")) > 0 then
					local ScriptStatus = 0
					util.spoof_script("fm_mission_controller", function()
						ScriptStatus = NETWORK.NETWORK_GET_SCRIPT_STATUS()
					end)
					if ScriptStatus == 2 then
						for i = 1, 80 do
							local NetID = memory.read_int(memory.script_local("fm_mission_controller", 22924+834+i))
							if NetID ~= 0 then
								local PedHandle = 0
								util.spoof_script("fm_mission_controller", function()
									if NETWORK.NETWORK_GET_SCRIPT_STATUS() == 2 then
										PedHandle = NETWORK.NET_TO_PED(NetID)
									end
								end)
								if PedHandle ~= 0 then
									if HandlesT[PedHandle] == nil then
										Peds[#Peds+1] = {}
										Peds[#Peds].Handle = PedHandle
										Peds[#Peds].TaskState = 0
										Peds[#Peds].Target = 0
										Peds[#Peds].TaskCoords = {x = 0.0, y = 0.0, z = 0.0}
										Peds[#Peds].TaskCoords2 = {x = 0.0, y = 0.0, z = 0.0}
										Peds[#Peds].Paths = nil
										Peds[#Peds].ActualPath = 1
										Peds[#Peds].SearchState = 0
										Peds[#Peds].SearchCalled = false
										Peds[#Peds].Start = 1
										Peds[#Peds].TargetPoly = 1
										Peds[#Peds].InsideStartPolygon = false
										Peds[#Peds].TargetInsideTargetPolygon = false
										Peds[#Peds].HasSetRel = false
										Peds[#Peds].TimeOut = 0
										Peds[#Peds].SearchLowLevel = 1
										Peds[#Peds].IsInVeh = false
										Peds[#Peds].VehHandle = 0
										Peds[#Peds].LastDistance = 0.0
										Peds[#Peds].SameDistanceTick = 0
										Peds[#Peds].StartPolysT = {}
										Peds[#Peds].TargetPolysT = {}
										Peds[#Peds].DrivingStyle = 0
										Peds[#Peds].NetID = NetID
										Peds[#Peds].TargetDelay = 0
										Peds[#Peds].LastYOffset = 0
										PED.SET_PED_COMBAT_ATTRIBUTES(PedHandle, 3, false)
										PED.SET_PED_TARGET_LOSS_RESPONSE(PedHandle, 1)
										--WEAPON.SET_PED_INFINITE_AMMO_CLIP(PedHandle, true)
										PED.SET_COMBAT_FLOAT(PedHandle, 2, 4000.0)
										PED.SET_PED_COMBAT_RANGE(PedHandle, 3)
										PED.SET_PED_FIRING_PATTERN(PedHandle, joaat("FIRING_PATTERN_FULL_AUTO"))
										if PED.GET_RELATIONSHIP_BETWEEN_GROUPS(PED.GET_PED_RELATIONSHIP_GROUP_HASH(PedHandle), Team1Hash) == 1 then
										--if PED.GET_PED_RELATIONSHIP_GROUP_HASH(PedHandle) == AiTeam1Hash then
											ENTITY.SET_ENTITY_CAN_BE_DAMAGED_BY_RELATIONSHIP_GROUP(PedHandle, false, AiTeam1Hash)
											ENTITY.SET_ENTITY_CAN_BE_DAMAGED_BY_RELATIONSHIP_GROUP(PedHandle, false, Team1Hash)
											ENTITY.SET_ENTITY_PROOFS(PedHandle, true, true, true, false, false, false, true, false)
											--ENTITY.SET_ENTITY_MAX_HEALTH(PedHandle, 1100)
											--PED.SET_PED_MAX_HEALTH(PedHandle, 1100)
											--ENTITY.SET_ENTITY_HEALTH(PedHandle, 1100)
											--ENTITY.SET_ENTITY_CAN_BE_DAMAGED(PedHandle, false)
										end
										HandlesT[PedHandle] = 0
									end
								end
							end
						end
					end
				else
					for k = 1, #Peds do
						HandlesT[Peds[#Peds].Handle] = nil
						table.remove(Peds, #Peds)
					end
				end
			end
			for k = 1, #Peds do
				if Peds[k] ~= nil then
					if not ENTITY.IS_ENTITY_DEAD(Peds[k].Handle) and ENTITY.DOES_ENTITY_EXIST(Peds[k].Handle) then
					--and SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller")) > 0 then
						--util.spoof_script("fm_mission_controller", function()
						--	if NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(Peds[k].NetID) then
						--		NETWORK.SET_NETWORK_ID_CAN_MIGRATE(Peds[k].NetID, true)
						--	end
						--end)
						if RequestControlOfEntity(Peds[k].Handle) then
							entities.set_can_migrate(Peds[k].Handle, false)
						--end
							if PED.GET_RELATIONSHIP_BETWEEN_GROUPS(PED.GET_PED_RELATIONSHIP_GROUP_HASH(Peds[k].Handle), Team1Hash) == 1 then
							--if PED.GET_PED_RELATIONSHIP_GROUP_HASH(Peds[k].Handle) == AiTeam1Hash then
								ENTITY.SET_ENTITY_CAN_BE_DAMAGED_BY_RELATIONSHIP_GROUP(Peds[k].Handle, false, AiTeam1Hash)
								ENTITY.SET_ENTITY_CAN_BE_DAMAGED_BY_RELATIONSHIP_GROUP(Peds[k].Handle, false, Team1Hash)
								--ENTITY.SET_ENTITY_PROOFS(Peds[k].Handle, true, true, true, false, true, true, true, true)
								ENTITY.SET_ENTITY_PROOFS(Peds[k].Handle, true, true, true, false, false, false, true, false)
								PED.SET_PED_COMBAT_ATTRIBUTES(Peds[k].Handle, 3, false)
								PED.SET_PED_TARGET_LOSS_RESPONSE(Peds[k].Handle, 1)
								WEAPON.SET_PED_INFINITE_AMMO_CLIP(Peds[k].Handle, true)
								PED.SET_COMBAT_FLOAT(Peds[k].Handle, 2, 4000.0)
								PED.SET_PED_COMBAT_RANGE(Peds[k].Handle, 3)
								PED.SET_PED_FIRING_PATTERN(Peds[k].Handle, joaat("FIRING_PATTERN_FULL_AUTO"))
								
								--ENTITY.SET_ENTITY_MAX_HEALTH(Peds[k].Handle, 1100)
								--PED.SET_PED_MAX_HEALTH(Peds[k].Handle, 1100)
								--ENTITY.SET_ENTITY_HEALTH(Peds[k].Handle, 1100)
								
								--ENTITY.SET_ENTITY_CAN_BE_DAMAGED(Peds[k].Handle, false)
							end
						end
						if PED.IS_PED_IN_ANY_VEHICLE(Peds[k].Handle, false) then
							Peds[k].IsInVeh = true
							Peds[k].VehHandle = PED.GET_VEHICLE_PED_IS_IN(Peds[k].Handle, false)
						else
							Peds[k].IsInVeh = false
							Peds[k].VehHandle = 0
						end
						if not Peds[k].HasSetRel then
							if PED.DOES_RELATIONSHIP_GROUP_EXIST(AiTeam1Hash) then
								if RequestControlOfEntity(Peds[k].Handle) then
									--PED.SET_PED_RELATIONSHIP_GROUP_HASH(Peds[k].Handle, AiTeam1Hash)
									Peds[k].HasSetRel = true
								end
							end
						end
						if not Peds[k].IsInVeh then
							if Peds[k].TaskState == 0 then
								--TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(Peds[k].Handle, 1000.0, 16)
								local Target = PED.GET_PED_TARGET_FROM_COMBAT_PED(Peds[k].Handle, 0)
								--Print(Target)
								if Target ~= 0 then
									Peds[k].Target = Target
									Peds[k].TaskState = 1
								end
							end
							if Peds[k].SearchState == 0 then
								if Peds[k].Target ~= 0 then
									--172.71616, -846.8681, 1005.89124
									if ENTITY.IS_ENTITY_AT_COORD(Peds[k].Handle, 172.71616, -846.8681, 1005.89124, 100.0, 100.0, 10.0, false, false, 0) then
										local Pos = ENTITY.GET_ENTITY_COORDS(Peds[k].Handle)
										local TargetPos = ENTITY.GET_ENTITY_COORDS(Peds[k].Target)
										local Distance = DistanceBetween(Pos.x, Pos.y, Pos.z, TargetPos.x, TargetPos.y, TargetPos.z)
										local NewV3 = v3.new(TargetPos.x, TargetPos.y, TargetPos.z)
										local Sub = v3.sub(NewV3, Pos)
										local Rot = Sub:toRot()
										Dir = Rot:toDir()
										if Distance > 15.0 then
											TargetPos.x = Pos.x + Dir.x * 5.0
											TargetPos.y = Pos.y + Dir.y * 5.0
											TargetPos.z = Pos.z
										else
											TargetPos.x = Pos.x - Dir.x * 5.0
											TargetPos.y = Pos.y - Dir.y * 5.0
											TargetPos.z = Pos.z
										end
										Peds[k].SearchState = 1
										util.create_thread(function()
											local NewPaths = nil
											NewPaths, Peds[k].Start, Peds[k].TargetPoly, Peds[k].InsideStartPolygon, Peds[k].TargetInsideTargetPolygon = AStarPathFind(Pos, TargetPos, Peds[k].SearchLowLevel, true, nil, nil, nil, nil, nil, true)
											if NewPaths ~= nil then
												if Peds[k] ~= nil then
													Peds[k].Paths = NewPaths
													Peds[k].SearchLowLevel = 1
													--Print("Found path")
													Peds[k].ActualPath = 1
													Peds[k].TaskState = 1
												end
												--PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
											end
											Wait(1000)
											if Peds[k] ~= nil then
												if not Peds[k].IsInVeh then
													Peds[k].SearchState = 3
												end
												--Print("Reset")
											end
										end)
									end
								end
							end
							if Peds[k].SearchState == 3 then
								local Pos = ENTITY.GET_ENTITY_COORDS(Peds[k].Handle)
								--local TargetPos = ENTITY.GET_ENTITY_COORDS(Peds[k].Target)
								--local Distance = DistanceBetween(Pos.x, Pos.y, Pos.z, )
								if not InsidePolygon(Polys1[Peds[k].Start], Pos) then
									Peds[k].SearchState = 2
								end
							end
							if Peds[k].TaskState == 1 then
								if Peds[k].Paths ~= nil then
									if RequestControlOfEntity(Peds[k].Handle) then
										--PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
										--TASK.CLEAR_PED_TASKS(Peds[k].Handle)
										if Peds[k].ActualPath > #Peds[k].Paths then
											Peds[k].ActualPath = 1
										end
										if Peds[k].Paths[Peds[k].ActualPath] ~= nil then
											Peds[k].TaskCoords.x = Peds[k].Paths[Peds[k].ActualPath].x
											Peds[k].TaskCoords.y = Peds[k].Paths[Peds[k].ActualPath].y
											Peds[k].TaskCoords.z = Peds[k].Paths[Peds[k].ActualPath].z
											TASK.TASK_GO_TO_COORD_WHILE_AIMING_AT_ENTITY(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, Peds[k].Target, 2.0, true, 0.1, 0.1, false, 0, false, joaat("FIRING_PATTERN_FULL_AUTO"), -1)
											PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
											if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_GO_TO_COORD_WHILE_AIMING_AT_ENTITY")) ~= 7 then
												Peds[k].TaskState = 2
											end
											if not Shoot then
												--WEAPON.MAKE_PED_RELOAD(Peds[k].Handle)
												--WEAPON.SET_AMMO_IN_CLIP(Peds[k].Handle, joaat("weapon_rpg"), 1)
												--WEAPON.REFILL_AMMO_INSTANTLY(Peds[k].Handle)
											end
										end
									end
								else
									if Peds[k].SearchState == 2 then
										Peds[k].SearchState = 0
									end
								end
							end
							if Peds[k].TaskState == 2 then
								if not ENTITY.IS_ENTITY_DEAD(Peds[k].Target) and ENTITY.DOES_ENTITY_EXIST(Peds[k].Target) then
									if Peds[k].Paths ~= nil then
										if Peds[k].SearchState == 2 then
											--if Peds[k].TargetPoly ~= nil then
											--	local TargetPos = ENTITY.GET_ENTITY_COORDS(Peds[k].Target)
											--	if Peds[k].TargetInsideTargetPolygon then
											--		if not InsidePolygon(Polys1[Peds[k].TargetPoly], TargetPos) then
											--			--Peds[k].TaskState = 1
											--			Peds[k].SearchState = 0
											--		end
											--	else
											--		if InsidePolygon(Polys1[Peds[k].TargetPoly], TargetPos) then
											--			--Peds[k].TaskState = 1
											--			Peds[k].SearchState = 0
											--		end
											--	end
											--else
											--	Peds[k].SearchState = 0
											--end
										end
										if not ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(Peds[k].Handle, Peds[k].Target, 17) then
											if RequestControlOfEntity(Peds[k].Handle) then
												Peds[k].TaskState = 0
												PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
												TASK.CLEAR_PED_TASKS(Peds[k].Handle)
											end
										end
										if ENTITY.IS_ENTITY_AT_COORD(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, 0.15, 0.15, 100.0, false, false, 0) then
											if Peds[k].SearchState == 2 then
												Peds[k].SearchState = 0
											end
										end
										if ENTITY.IS_ENTITY_AT_COORD(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, 0.5, 0.5, 1.0, false, true, 0) then
											if RequestControlOfEntity(Peds[k].Handle) then
												PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
												TASK.CLEAR_PED_TASKS(Peds[k].Handle)
												Peds[k].ActualPath = Peds[k].ActualPath + 1
												if Peds[k].ActualPath > #Peds[k].Paths then
													Peds[k].ActualPath = 1
													if Peds[k].SearchState == 2 then
														Peds[k].SearchState = 0
													end
												end
												Peds[k].TaskState = 1
											end
										else
											Peds[k].TimeOut = Peds[k].TimeOut + 1
											if Peds[k].TimeOut > 1000 then
												if Peds[k].SearchState == 2 then
													if RequestControlOfEntity(Peds[k].Handle) then
														PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
														TASK.CLEAR_PED_TASKS(Peds[k].Handle)
														Peds[k].SearchState = 0
														Peds[k].TaskState = 1
													end
												end
											end
										end
										if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_GO_TO_COORD_WHILE_AIMING_AT_ENTITY")) == 7 then
											Peds[k].TaskState = 1
											--Print("No action")
										end
									else
										if Peds[k].SearchState == 2 then
											Peds[k].SearchState = 0
										end
									end
								else
									if RequestControlOfEntity(Peds[k].Handle) then
										PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
										TASK.CLEAR_PED_TASKS(Peds[k].Handle)
										Peds[k].TaskState = 0
										Peds[k].Target = 0
										Peds[k].ActualPath = 1
										Peds[k].SearchLowLevel = 2
									end
								end
							end
						else
							if Peds[k].VehHandle ~= 0 then
								if RequestControlOfEntity(Peds[k].VehHandle) then
									entities.set_can_migrate(Peds[k].VehHandle, false)
								end
								local Rot = ENTITY.GET_ENTITY_ROTATION(Peds[k].VehHandle, 2)
								--VEHICLE.SET_DISABLE_VEHICLE_ENGINE_FIRES(Peds[k].VehHandle, true)
								if Rot.y > 150.0 or Rot.y < -150.0 then
									if RequestControlOfEntity(Peds[k].VehHandle) then
										ENTITY.SET_ENTITY_ROTATION(Peds[k].VehHandle, Rot.x, 0.0, Rot.z, 2)
									end
								end
								if Peds[k].TaskState == 6 then
									local Target = PED.GET_PED_TARGET_FROM_COMBAT_PED(Peds[k].Handle, 0)
									if Target ~= 0 then
										Peds[k].Target = Target
										Peds[k].TaskState = 1
									else
										Peds[k].TargetDelay = Peds[k].TargetDelay + 1
										if Peds[k].TargetDelay > 10 then
											Peds[k].TaskState = 0
											Peds[k].TargetDelay = 0
										end
									end
								end
								if Peds[k].TaskState == 0 then
									--TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(Peds[k].Handle, 1000.0, 16)
									TASK.TASK_COMBAT_HATED_TARGETS_IN_AREA(Peds[k].Handle, 172.53906, -847.31964, 1005.8912, 1000.0, 16)
									Peds[k].TaskState = 6
								end
								if Peds[k].SearchState == 0 then
									if Peds[k].Target ~= 0 then
										local Pos = ENTITY.GET_ENTITY_COORDS(Peds[k].Handle)
										local TargetPos = ENTITY.GET_ENTITY_COORDS(Peds[k].Target)
										Peds[k].SearchState = 1
										util.create_thread(function()
											local NewPaths = nil
											NewPaths, Peds[k].Start, Peds[k].TargetPoly, Peds[k].InsideStartPolygon, Peds[k].TargetInsideTargetPolygon = AStarPathFind(Pos, TargetPos, Peds[k].SearchLowLevel, false, nil, nil, false, nil, false, true, true)
											if NewPaths ~= nil then
												if Peds[k] ~= nil then
													Peds[k].Paths = NewPaths
													Peds[k].SearchLowLevel = 1
													--Print("Found path")
													Peds[k].ActualPath = 1
													Peds[k].TaskState = 1
													Peds[k].SameDistanceTick = 0
												end
												--PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
											end
											Wait(1000)
											if Peds[k] ~= nil then
												Peds[k].SearchState = 2
												--Print("Reset")
											end
										end)
									end
								end
								local Pos = ENTITY.GET_ENTITY_COORDS(Peds[k].Handle)
								if Peds[k].Target ~= 0 then
									if not ENTITY.IS_ENTITY_DEAD(Peds[k].Target) and ENTITY.DOES_ENTITY_EXIST(Peds[k].Target) then

									else
										if RequestControlOfEntity(Peds[k].Handle) then
											Peds[k].Target = 0
											Peds[k].TaskState = 0
											TASK.CLEAR_PED_TASKS(Peds[k].Handle)
											PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
										end
									end
								end
								if Peds[k].TaskState == 1 then
									if Peds[k].Paths ~= nil then
										if Peds[k].ActualPath > #Peds[k].Paths then
											Peds[k].ActualPath = 1
										end
										Peds[k].TaskCoords.x = Peds[k].Paths[Peds[k].ActualPath].x
										Peds[k].TaskCoords.y = Peds[k].Paths[Peds[k].ActualPath].y
										Peds[k].TaskCoords.z = Peds[k].Paths[Peds[k].ActualPath].z
										--Print("Called Go")
										if not ENTITY.IS_ENTITY_AT_COORD(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, 1.0, 1.0, 1.0, false, true, 0) then
											if RequestControlOfEntity(Peds[k].Handle) then
												local Offset = ENTITY.GET_OFFSET_FROM_ENTITY_GIVEN_WORLD_COORDS(Peds[k].VehHandle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z)
												local Bits = 16777216
												if Peds[k].LastYOffset == 0 then
													if Offset.y < MinOffset then
														Bits = 16777216 + 1024
														Peds[k].LastYOffset = 1
													else
														Peds[k].LastYOffset = 2
													end
												end
												if Peds[k].LastYOffset == 3 then
													Bits = 16777216 + 1024
												end
												TASK.TASK_VEHICLE_DRIVE_TO_COORD(Peds[k].Handle, Peds[k].VehHandle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, 350.0, 0, ENTITY.GET_ENTITY_MODEL(Peds[k].VehHandle), Bits, 0.0, 40000.0)
												PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
												if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_VEHICLE_DRIVE_TO_COORD")) ~= 7 then
													Peds[k].TaskState = 2
													Peds[k].LastDistance = DistanceBetween(Pos.x, Pos.y, Pos.z, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z)
												end
											end
										else
											Peds[k].TaskState = 2
										end
									else
										if Peds[k].SearchState == 2 then
											Peds[k].SearchState = 0
										end
										Peds[k].SearchLowLevel = 1
									end
								end
								--GRAPHICS.DRAW_LINE(Pos.x, Pos.y, Pos.z,
								--Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, 255, 255, 255, 255)
								if Peds[k].TaskState == 2 then
									local Distance2 = DistanceBetween(Pos.x, Pos.y, Pos.z, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z)
									if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_VEHICLE_DRIVE_TO_COORD")) == 7 then
										if RequestControlOfEntity(Peds[k].Handle) then
											Peds[k].TaskState = 1
											--Print("No action")
											TASK.CLEAR_PED_TASKS(Peds[k].Handle)
											PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
										end
									end
									local FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(Peds[k].VehHandle)
									local VPos = ENTITY.GET_ENTITY_COORDS(Peds[k].VehHandle)
									local AdjustedVect = {
										x = VPos.x + FVect.x * 5.0,
										y = VPos.y + FVect.y * 5.0,
										z = VPos.z + FVect.z * 5.0
									}
									local Offset = ENTITY.GET_OFFSET_FROM_ENTITY_GIVEN_WORLD_COORDS(Peds[k].VehHandle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z) 
									--Print(Peds[k].LastDistance)
									Peds[k].SameDistanceTick = Peds[k].SameDistanceTick + 1
									--if Distance2 < Peds[k].LastDistance then
									if math.floor(Distance2) < math.floor(Peds[k].LastDistance) then
										Peds[k].LastDistance = Distance2
										Peds[k].SameDistanceTick = 0
									end
									if Peds[k].LastOffsetDelay == nil then
										Peds[k].LastOffsetDelay = 0
									end
									--if Distance2 > Peds[k].LastDistance then
									--Print(Peds[k].SameDistanceTick)
									if Peds[k].LastOffsetDelay <= 0 then
										if Peds[k].LastYOffset ~= 0 then
											if Peds[k].LastYOffset == 1 then
												if Offset.y > MaxOffset then
													Peds[k].TaskState = 1
													Peds[k].LastYOffset = 0
													Peds[k].LastOffsetDelay = 500
												end
											end
											if Peds[k].LastYOffset == 2 then
												if Offset.y < MinOffset then
													Peds[k].TaskState = 1
													Peds[k].LastYOffset = 0
													Peds[k].LastOffsetDelay = 500
												end
											end
										end
									else
										Peds[k].LastOffsetDelay = Peds[k].LastOffsetDelay - 1
									end
									if Peds[k].SameDistanceTick > 50 then
									 	if Peds[k].LastYOffset == 2 then
											Peds[k].LastYOffset = 3
										else
											if Peds[k].LastYOffset == 3 then
												Peds[k].LastYOffset = 4
											else
												if Peds[k].LastYOffset == 4 then
													Peds[k].LastYOffset = 0
												end
											end
										end
										Peds[k].TaskState = 1
										--Peds[k].ActualPath = 1
										Peds[k].SearchCalled = true
										if Peds[k].SearchState == 2 then
											Peds[k].SearchState = 0
										end
										Peds[k].SearchLowLevel = 1
										Peds[k].SameDistanceTick = 0
									end
									if Peds[k].SameDistanceTick > 200 then
										--local Vel = ENTITY.GET_ENTITY_VELOCITY(Peds[k].VehHandle)
										--ENTITY.SET_ENTITY_VELOCITY(Peds[k].VehHandle, Vel.x - FVect.x * 35.0, Vel.y - FVect.y * 35.0, Vel.z)
										Peds[k].SameDistanceTick = 0
										Peds[k].TaskState = 1
										Peds[k].ActualPath = 1
										Peds[k].SearchCalled = true
										if Peds[k].SearchState == 2 then
											Peds[k].SearchState = 0
										end
										Peds[k].SearchLowLevel = 1
									end
									if Peds[k].SearchCalled then
										if Peds[k].SearchState == 2 then
											Peds[k].SearchState = 0
											Peds[k].SearchCalled = false
											--Peds[k].SameDistanceTick = 0
											--Print("Called")
										end
									end
									--if DidHit then
									--	local Vel = ENTITY.GET_ENTITY_VELOCITY(Peds[k].VehHandle)
									--	ENTITY.SET_ENTITY_VELOCITY(Peds[k].VehHandle, Vel.x - FVect.x * 5.0, Vel.y - FVect.y * 5.0, Vel.z)
									--end
									if ENTITY.IS_ENTITY_AT_COORD(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, 5.5, 5.5, 5.5, false, false, 0) then
										Peds[k].TaskState = 1
										Peds[k].ActualPath = Peds[k].ActualPath + 1
										Peds[k].DrivingStyle = 1
										Peds[k].SameDistanceTick = 0
										if Peds[k].ActualPath > #Peds[k].Paths then
											if Peds[k].SearchState == 2 then
												Peds[k].SearchState = 0
											end
											Peds[k].ActualPath = 1
											Peds[k].SearchLowLevel = 1
										end
									end
								end
							end
						end
					else
						--if RequestControlOfEntity(Peds[k].Handle) then
							--set_entity_as_no_longer_needed(Peds[k].Handle)
							HandlesT[Peds[k].Handle] = nil
							table.remove(Peds, k)
						--end
					end
				end
			end
			Wait()
		end
	end
end)

local CargobobRiders = false
local BobHandle = 0
menu.toggle(GameModesMenu, "Cargobob Riders", {}, "", function(Toggle)
	CargobobRiders = Toggle
	if not CargobobRiders then
		entities.delete_by_handle(BobHandle)
	end
	if CargobobRiders then
		local IsATest = false
		local Vehs = {}
		local HandlesT = {}
		local AddrNum = 22942+834+81
		local RotSpd = 0.0115
		local HSpeed = 5.0
		local Speed = 20.0
		local Max = 2
		if IsATest then
			if not STREAMING.HAS_MODEL_LOADED(joaat("cargobob2")) then
				STREAMING.REQUEST_MODEL(joaat("cargobob2"))
			end
			while not STREAMING.HAS_MODEL_LOADED(joaat("cargobob2")) do
				Wait()
			end
			local PlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
			BobHandle = VEHICLE.CREATE_VEHICLE(joaat("cargobob2"), PlayerPos.x, PlayerPos.y, PlayerPos.z, 0.0, true, true, false)
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(joaat("cargobob2"))
			Vehs[#Vehs+1] = {}
			Vehs[#Vehs].Handle = BobHandle
			Vehs[#Vehs].Paths = nil
			Vehs[#Vehs].TaskState = 0
			Vehs[#Vehs].SearchState = 0
			Vehs[#Vehs].ActualPath = 1
			Vehs[#Vehs].Radius = 4.0
			Vehs[#Vehs].Tick = 0
			Vehs[#Vehs].Acceleration = 0.0
			Vehs[#Vehs].AccelerationH = 0.0
			PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), BobHandle, -1)
			VEHICLE.SET_VEHICLE_DOOR_OPEN(BobHandle, 2, false, true)
			Wait(10000)
		end
		while CargobobRiders do
			if #Vehs < Max then
				if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller")) > 0 then
					for i = 1, Max do
						local NetID = memory.read_int(memory.script_local("fm_mission_controller", AddrNum+i))
						if NetID ~= 0 then
							local VehHandle = 0
							util.spoof_script("fm_mission_controller", function()
								VehHandle = NETWORK.NET_TO_PED(NetID)
							end)
							if VehHandle ~= 0 then
								if HandlesT[VehHandle] == nil then
									Vehs[#Vehs+1] = {}
									Vehs[#Vehs].Handle = VehHandle
									Vehs[#Vehs].Paths = nil
									Vehs[#Vehs].TaskState = 0
									Vehs[#Vehs].SearchState = 0
									Vehs[#Vehs].ActualPath = 1
									Vehs[#Vehs].Radius = 4.0
									Vehs[#Vehs].Tick = 0
									Vehs[#Vehs].Acceleration = 0.0
									Vehs[#Vehs].AccelerationH = 0.0
									Vehs[#Vehs].SpeedState = 0
									HandlesT[VehHandle] = 0
								end
							end
						end
					end
				else
					for k = 1, #Vehs do
						HandlesT[Vehs[#Vehs].Handle] = nil
						table.remove(Vehs, #Vehs)
					end
				end
			end
			local IsControlOn = PLAYER.IS_PLAYER_CONTROL_ON(PLAYER.PLAYER_ID())
			if IsControlOn then
				for i = 1, #Vehs do
					if Vehs[i] ~= nil then
						if ENTITY.DOES_ENTITY_EXIST(Vehs[i].Handle) then
							if RequestControlOfEntity(Vehs[i].Handle) then
								entities.set_can_migrate(Vehs[i].Handle, false)
								VEHICLE.SET_DOOR_ALLOWED_TO_BE_BROKEN_OFF(Vehs[i].Handle, 2, false)
								VEHICLE.SET_VEHICLE_DOOR_CONTROL(Vehs[i].Handle, 2, 360.0, 180.0)
							end
							if Vehs[i].TaskState == 0 then
								if Vehs[i].SearchState == 2 then
									Vehs[i].SearchState = 0
								end
							end
							if Vehs[i].SearchState == 0 then
								local Pos = ENTITY.GET_ENTITY_COORDS(Vehs[i].Handle)
								local TargetPos = ENTITY.GET_ENTITY_COORDS(Vehs[1].Handle)
								Vehs[i].SearchState = 1
								util.create_thread(function()
									local NewPaths = nil
									if i == 1 then
										NewPaths = AStarPathFind(Pos, TargetPos, 1, true, nil, math.random(#Polys1))
									end
									if i == 2 then
										NewPaths = AStarPathFind(Pos, TargetPos, 1, true, nil, nil)
									end
									if NewPaths ~= nil then
										if Vehs[i] ~= nil then
											Vehs[i].Paths = NewPaths
											Vehs[i].ActualPath = 1
											Vehs[i].TaskState = 1
										end
									end
									Wait(1000)
									if Vehs[i] ~= nil then
										Vehs[i].SearchState = 2
									end
								end)
							end
							if Vehs[i].TaskState == 1 then
								local Pos = ENTITY.GET_ENTITY_COORDS(Vehs[i].Handle)
								local VRot = ENTITY.GET_ENTITY_ROTATION(Vehs[i].Handle, 5)
								local TaskCoords = Vehs[i].Paths[Vehs[i].ActualPath]
								local Sub = {
									x = TaskCoords.x - Pos.x,
									y = TaskCoords.y - Pos.y,
									z = TaskCoords.z - Pos.z
								}
								local NewV3 = v3.new(Sub.x, Sub.y, Sub.z)
								NewV3:normalise()
								local NewV3_1 = v3.new(TaskCoords.x, TaskCoords.y, TaskCoords.z)
								local Rot = v3.lookAt(Pos, NewV3_1)
								local Dir = v3.new(Rot)
								local Normal = Dir:normalise()
								local AdjustedX = 0.0 - VRot.x
								AdjustedX = (AdjustedX + 180) % 360 - 180
								local AdjustedY = 0.0 - VRot.y
								AdjustedY = (AdjustedY + 180) % 360 - 180
								local AdjustedZ = Rot.z - VRot.z
								AdjustedZ = (AdjustedZ + 180) % 360 - 180
								if i == 2 then
									AdjustedX = 0.0 - VRot.x
									AdjustedX = (AdjustedX + 180) % 360 - 180
									AdjustedY = 0.0 - VRot.y
									AdjustedY = (AdjustedY + 180) % 360 - 180
									AdjustedZ = (Rot.z + 180) - VRot.z
									AdjustedZ = (AdjustedZ + 180) % 360 - 180
								end
								if Vehs[i].SpeedState == 1 then
									if Vehs[i].Acceleration > 1.0 then
										Vehs[i].Acceleration = Vehs[i].Acceleration - 0.1
									else
										Vehs[i].SpeedState = 0
									end
									if Vehs[i].AccelerationH > 1.0 then
										Vehs[i].AccelerationH = Vehs[i].AccelerationH - 0.1
									end
								end
								if Vehs[i].SpeedState == 0 then
									if Vehs[i].Acceleration < Speed then
										Vehs[i].Acceleration = Vehs[i].Acceleration + 0.1
									end
									if Vehs[i].AccelerationH < HSpeed then
										Vehs[i].AccelerationH = Vehs[i].AccelerationH + 0.1
									end
								end
								ENTITY.SET_ENTITY_VELOCITY(Vehs[i].Handle, NewV3.x * Vehs[i].Acceleration, NewV3.y * Vehs[i].Acceleration, NewV3.z * Vehs[i].AccelerationH)
								--ENTITY.SET_ENTITY_VELOCITY(Vehs[i].Handle, NewV3.x * Speed, NewV3.y * Speed, NewV3.z * HSpeed)
								ENTITY.SET_ENTITY_ANGULAR_VELOCITY(Vehs[i].Handle, AdjustedX * RotSpd, AdjustedY * RotSpd, AdjustedZ * RotSpd)
								--ENTITY.SET_ENTITY_ANGULAR_VELOCITY(Vehs[i].Handle, Normal.x * RotSpd, Normal.y * RotSpd, Normal.z * RotSpd)
								--if ShapeTestNav(Vehs[i].Handle, Pos, TaskCoords, 2) then
								if MISC.IS_POSITION_OCCUPIED(Pos.x, Pos.y, Pos.z, Vehs[i].Radius, false, true, false, false, false, Vehs[i].Handle, false) then
									--local FVect, RVect, UpVect, Vect = v3.new(), v3.new(), v3.new(), v3.new()
									--local FVect = ENTITY.GET_ENTITY_FORWARD_VECTOR(Vehs[i].Handle)
									--ENTITY.GET_ENTITY_MATRIX(Vehs[i].Handle, FVect, RVect, UpVect, Vect)
									ENTITY.SET_ENTITY_VELOCITY(Vehs[i].Handle, -NewV3.x * Vehs[i].Acceleration, -NewV3.y * Vehs[i].Acceleration, NewV3.z * Vehs[i].AccelerationH)
									--ENTITY.SET_ENTITY_VELOCITY(Vehs[i].Handle, -FVect.x * Speed, -FVect.y * Speed, FVect.z * HSpeed)
									Vehs[i].Radius = 12.0
									Vehs[i].Tick = Vehs[i].Tick + 1
									if Vehs[i].Tick > 100 then
										Vehs[i].Tick = 0
										Vehs[i].Radius = 2.0
										if Vehs[i].ActualPath > 1 then
											Vehs[i].ActualPath = Vehs[i].ActualPath - 1
										end
									end
								else
									Vehs[i].Radius = 4.0
									--Vehs[i].Tick = 0
								end
								if ENTITY.IS_ENTITY_AT_COORD(Vehs[i].Handle, TaskCoords.x, TaskCoords.y, TaskCoords.z, 0.5, 0.5, 5.0, false, true, 0) then
									Vehs[i].ActualPath = Vehs[i].ActualPath + 1
									if Vehs[i].ActualPath > #Vehs[i].Paths then
										Vehs[i].TaskState = 0
										if Vehs[i].SearchState == 2 then
											Vehs[i].SearchState = 0
										end
									end
									Vehs[i].SpeedState = 1
									--Vehs[i].Acceleration = 0.0
									--Vehs[i].AccelerationH = 0.0
								end
							end
						else
							HandlesT[Vehs[i].Handle] = nil
							table.remove(Vehs, i)
						end
					end
				end
			end
			Wait()
		end
	end
end)

function SetPedCombatAbilities(ped)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 1, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 3, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 13, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 21, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 38, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
	PED.SET_PED_COMBAT_ATTRIBUTES(ped, 443, true)
	PED.SET_PED_COMBAT_MOVEMENT(ped, 2)
	PED.SET_PED_COMBAT_ABILITY(ped, 2) 
	PED.SET_PED_COMBAT_RANGE(ped, 2)
	PED.SET_PED_SEEING_RANGE(ped, 900.0)
	PED.SET_PED_TARGET_LOSS_RESPONSE(ped, 1)
	PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
	PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, 400.0)
	PED.SET_COMBAT_FLOAT(ped, 10, 400.0)
end

function set_entity_as_no_longer_needed(entity)
	local pHandle = memory.alloc_int()
	memory.write_int(pHandle, entity)
	ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(pHandle)
end

function CopyPolygonsData(PolygonsT)
	local NewData = {}
	for k = 1, #PolygonsT do
		NewData[k] = {}
		NewData[k].ID = PolygonsT[k].ID
		NewData[k].Parent = PolygonsT[k].Parent
		NewData[k].Closed = false
		NewData[k].Center = PolygonsT[k].Center
		NewData[k].Neighboors = {}
		for i = 1, #PolygonsT[k].Neighboors do
			NewData[k].Neighboors[#NewData[k].Neighboors+1] = PolygonsT[k].Neighboors[i]
		end
	end
	return NewData
end

function AStarPathFind(Start, Target, LowPriorityLevel, PolygonsOnly, CachedStartIndex, CachedTargetIndex, IncludePoints, IncludeStartNode, IncludePoints2, Funnel, PreferCenter)
	local StartIndex = 0
	local TargetIndex = 0
	local FinalNode = false
	local Include = false
	local StartNode = true
	local IncludePointsNodes = false
	local CenterOnly = false
	if PreferCenter ~= nil then
		CenterOnly = PreferCenter
	end
	if IncludePoints ~= nil then
		Include = IncludePoints
	end
	if IncludeStartNode ~= nil then
		StartNode = IncludeStartNode
	end
	if PolygonsOnly ~= nil then
		FinalNode = PolygonsOnly
	end
	if IncludePoints2 ~= nil then
		IncludePointsNodes = IncludePoints2
	end
	if CachedStartIndex ~= nil then
		StartIndex = CachedStartIndex
	else
		StartIndex = GetPolygonDirectIndex(Start)
		if StartIndex == 0 then
			StartIndex = GetClosestPolygon(Polys1, Start, Include)
		end
	end
	if CachedTargetIndex ~= nil then
		TargetIndex = CachedTargetIndex
	else
		TargetIndex = GetPolygonDirectIndex(Target)
		if TargetIndex == 0 then
			TargetIndex = GetClosestPolygon(Polys1, Target, Include)
		end
	end
	if StartIndex == 0 or TargetIndex == 0 then
		return nil
	end
	local InsideStartPolygon = InsidePolygon(Polys1[StartIndex], Start)
	local TargetInsideTargetPolygon = InsidePolygon(Polys1[TargetIndex], Target)
	if StartIndex == TargetIndex then
		if not FinalNode then
			return {{x = Target.x, y = Target.y, z = Target.z, NodeFlags = 0, PolyID = TargetIndex}}, StartIndex, TargetIndex, InsideStartPolygon, TargetInsideTargetPolygon
		else
			local CoordsT = {}
			CoordsT[#CoordsT+1] = Polys1[TargetIndex][1]
			CoordsT[#CoordsT+1] = Polys1[TargetIndex][2]
			CoordsT[#CoordsT+1] = Polys1[TargetIndex][3]
			CoordsT[#CoordsT+1] = Polys1[TargetIndex].Center
			CoordsT[#CoordsT+1] = Polys1[TargetIndex].Edge
			CoordsT[#CoordsT+1] = Polys1[TargetIndex].Edge2
			CoordsT[#CoordsT+1] = Polys1[TargetIndex].Edge3
			if IncludePointsNodes then
				for j = 1, #Polys1[TargetIndex].LocalPoints do
					CoordsT[#CoordsT+1] = Polys1[TargetIndex].LocalPoints[j]
				end
			end
			local Dist = 10000.0
			local SelectedVector = CoordsT[4]
			for j = 1, #CoordsT do
				local Distance = DistanceBetween(CoordsT[j].x, CoordsT[j].y, CoordsT[j].z, Target.x, Target.y, Target.z)
				if Distance < Dist then
					Dist = Distance
					SelectedVector = CoordsT[j]
				end
			end
			return {{x = SelectedVector.x, y = SelectedVector.y, z = SelectedVector.z, NodeFlags = 0, PolyID = TargetIndex}}, StartIndex, TargetIndex, InsideStartPolygon, TargetInsideTargetPolygon
		end
	end
	local Bit1It = 0
	local Bit2It = 0
	local Bit3It = 0
	local HasReachedTargetIndex = false
	local PolysCopy = CopyPolygonsData(Polys1)
	local OpenList = {}
	OpenList[#OpenList+1] = PolysCopy[StartIndex]
	PolysCopy[StartIndex].Closed = true
	local Debug = false
	if Debug then
		util.create_thread(function()
			while not HasReachedTargetIndex do
				for i = 1, #OpenList-1 do
					GRAPHICS.DRAW_LINE(OpenList[i].Center.x, OpenList[i].Center.y, OpenList[i].Center.z,
					OpenList[i+1].Center.x, OpenList[i+1].Center.y, OpenList[i+1].Center.z, 255, 255, 255, 255)
				end
				Wait()
			end
		end)
	end
	for j = 1, #Polys1 do
		if not HasReachedTargetIndex then
			for i = 1, #OpenList do
				local ClosestIndex = 0
				local Dist2 = 10000.0
				for k = 1, #OpenList[i].Neighboors do
					if PolysCopy[OpenList[i].Neighboors[k]] ~= nil then
						if not PolysCopy[OpenList[i].Neighboors[k]].Closed then
							local NIndex = OpenList[i].Neighboors[k]
							local HavesInTable = false
							for r = 1, #OpenList do
								if NIndex == OpenList[r].ID then
									HavesInTable = true
									break
								end
							end
							if not HavesInTable then
								local CoordsT2 = {}
								CoordsT2[#CoordsT2+1] = Polys1[NIndex][1]
								CoordsT2[#CoordsT2+1] = Polys1[NIndex][2]
								CoordsT2[#CoordsT2+1] = Polys1[NIndex][3]
								CoordsT2[#CoordsT2+1] = Polys1[NIndex].Center
								CoordsT2[#CoordsT2+1] = Polys1[NIndex].Edge
								CoordsT2[#CoordsT2+1] = Polys1[NIndex].Edge2
								CoordsT2[#CoordsT2+1] = Polys1[NIndex].Edge3
								if IncludePointsNodes then
									for j = 1, #Polys1[NIndex].LocalPoints do
										CoordsT2[#CoordsT2+1] = Polys1[NIndex].LocalPoints[j]
									end
								end
								for a = 1, #CoordsT2 do
									local Distance = DistanceBetween(CoordsT2[a].x, CoordsT2[a].y, CoordsT2[a].z, Target.x, Target.y, Target.z)
									if Distance < Dist2 then
										Dist2 = Distance
										ClosestIndex = Polys1[NIndex].ID
									end
								end
							end
						end
					end
				end
				if ClosestIndex ~= 0 then
					local HavesInTable = false
					--for r = 1, #OpenList do
					--	if ClosestIndex == OpenList[r].ID then
					--		HavesInTable = true
					--		break
					--	end
					--end
					if not HavesInTable then
						PolysCopy[ClosestIndex].Closed = true
						OpenList[#OpenList+1] = PolysCopy[ClosestIndex]
						PolysCopy[ClosestIndex].Parent = OpenList[i].ID
						if ClosestIndex == TargetIndex then
							HasReachedTargetIndex = true
							break
						end
					else
						--Print("Nil")
					end
					if is_bit_set(LowPriorityLevel, 3) then
						Bit3It = Bit3It + 1
						if Bit3It >= 100 then
							Bit3It = 0
							Wait()
						end
					end
				end
				if is_bit_set(LowPriorityLevel, 2) then
					Bit2It = Bit2It + 1
					if Bit2It >= 100 then
						Bit2It = 0
						Wait()
					end
				end
			end
			if Debug then
				Wait(1000)
			end
		else
			break
		end
		if is_bit_set(LowPriorityLevel, 1) then
			Bit1It = Bit1It + 1
			if Bit1It >= 100 then
				Bit1It = 0
				Wait()
			end
		end
	end
	local Nodes = {}
	local ReverseList = #OpenList
	for k = 1, #OpenList do
		local PreviousIndex = {}
		local LastParent = PolysCopy[TargetIndex].Parent
		PreviousIndex[#PreviousIndex+1] = LastParent
		local NewNodesT = {}
		local ThisReachedIndex = false
		if not FinalNode then
			NewNodesT[#NewNodesT+1] = {
			x = Target.x,
			y = Target.y,
			z = Target.z,
			Heading = 0.0,
			ID = TargetIndex,
			Parent = PolysCopy[TargetIndex].Parent,
			NodeFlags = Polys1[TargetIndex].Flags,
			PolyID = Polys1[TargetIndex].ID
			}
		else
			local CoordsT2 = {}
			if not CenterOnly then
				CoordsT2[#CoordsT2+1] = Polys1[TargetIndex][1]
				CoordsT2[#CoordsT2+1] = Polys1[TargetIndex][2]
				CoordsT2[#CoordsT2+1] = Polys1[TargetIndex][3]
				CoordsT2[#CoordsT2+1] = Polys1[TargetIndex].Edge
				CoordsT2[#CoordsT2+1] = Polys1[TargetIndex].Edge2
				CoordsT2[#CoordsT2+1] = Polys1[TargetIndex].Edge3
			end
			CoordsT2[#CoordsT2+1] = Polys1[TargetIndex].Center
			if IncludePointsNodes then
				for j = 1, #Polys1[TargetIndex].LocalPoints do
					CoordsT2[#CoordsT2+1] = Polys1[TargetIndex].LocalPoints[j]
				end
			end
			local Dist2 = 10000.0
			local SelectedVector2 = CoordsT2[4]
			for j = 1, #CoordsT2 do
				local Distance = DistanceBetween(CoordsT2[j].x, CoordsT2[j].y, CoordsT2[j].z, Target.x, Target.y, Target.z)
				if Distance < Dist2 then
					Dist2 = Distance
					SelectedVector2 = CoordsT2[j]
				end
			end
			NewNodesT[#NewNodesT+1] = {
				x = SelectedVector2.x,
				y = SelectedVector2.y,
				z = SelectedVector2.z,
				Heading = 0.0,
				ID = PolysCopy[TargetIndex].ID,
				Parent = PolysCopy[TargetIndex].Parent,
				NodeFlags = Polys1[TargetIndex].Flags,
				PolyID = Polys1[TargetIndex].ID
			}
		end
		for i = 1, #Polys1 do
			local CoordsT = {}
			if not CenterOnly then
				CoordsT[#CoordsT+1] = Polys1[LastParent][1]
				CoordsT[#CoordsT+1] = Polys1[LastParent][2]
				CoordsT[#CoordsT+1] = Polys1[LastParent][3]
				CoordsT[#CoordsT+1] = Polys1[LastParent].Edge
				CoordsT[#CoordsT+1] = Polys1[LastParent].Edge2
				CoordsT[#CoordsT+1] = Polys1[LastParent].Edge3
			end
			CoordsT[#CoordsT+1] = Polys1[LastParent].Center
			if IncludePointsNodes then
				for j = 1, #Polys1[LastParent].LocalPoints do
					CoordsT[#CoordsT+1] = Polys1[LastParent].LocalPoints[j]
				end
			end
			local Dist = 10000.0
			local SelectedVector = CoordsT[4]
			for j = 1, #CoordsT do
				local Distance = MISC.GET_DISTANCE_BETWEEN_COORDS(CoordsT[j].x, CoordsT[j].y, CoordsT[j].z, NewNodesT[#NewNodesT].x, NewNodesT[#NewNodesT].y, NewNodesT[#NewNodesT].z, true)
				if Distance < Dist then
					Dist = Distance
					SelectedVector = CoordsT[j]
				end
			end
			
			NewNodesT[#NewNodesT+1] = {
				x = SelectedVector.x,
				y = SelectedVector.y,
				z = SelectedVector.z,
				Heading = 0.0,
				ID = PolysCopy[LastParent].ID,
				Parent = PolysCopy[LastParent].Parent,
				NodeFlags = Polys1[LastParent].Flags,
				PolyID = Polys1[LastParent].ID
			}
			
			if is_bit_set(Polys1[LastParent].Flags, FlagBitNames.UsePoint) then
				if Polys1[Polys1[LastParent].JumpedFrom[1]].ID == PolysCopy[LastParent].Parent then
					local BaseIndex = Polys1[LastParent].JumpTo[1]
					local AcessIndex = Polys1[LastParent].JumpedFrom[1]
					if Polys1[AcessIndex].Point ~= nil then
						NewNodesT[#NewNodesT+1] = {
							x = Polys1[AcessIndex].Point.x,
							y = Polys1[AcessIndex].Point.y,
							z = Polys1[AcessIndex].Point.z,
							Heading = Polys1[AcessIndex].Point.Heading,
							ID = PolysCopy[AcessIndex].ID,
							Parent = PolysCopy[AcessIndex].Parent,
							NodeFlags = Polys1[AcessIndex].Flags,
							Action = Polys1[BaseIndex].Flags,
							PolyID = Polys1[AcessIndex].ID
						}
					end
				end
			end
			--if PolysCopy[LastParent].ID ~= PolysCopy[LastParent].Parent then
				LastParent = PolysCopy[LastParent].Parent
				if PolysCopy[LastParent].ID == StartIndex then
					ThisReachedIndex = true
					if not FinalNode then
						if StartNode then
							NewNodesT[#NewNodesT+1] = {
								x = Start.x,
								y = Start.y,
								z = Start.z,
								Heading = 0.0,
								ID = PolysCopy[LastParent].ID,
								Parent = PolysCopy[LastParent].Parent,
								NodeFlags = Polys1[LastParent].Flags,
								PolyID = Polys1[LastParent].ID
							}
						end
					else
						local CoordsT2 = {}
						if not CenterOnly then
							CoordsT2[#CoordsT2+1] = Polys1[LastParent][1]
							CoordsT2[#CoordsT2+1] = Polys1[LastParent][2]
							CoordsT2[#CoordsT2+1] = Polys1[LastParent][3]
							CoordsT2[#CoordsT2+1] = Polys1[LastParent].Edge
							CoordsT2[#CoordsT2+1] = Polys1[LastParent].Edge2
							CoordsT2[#CoordsT2+1] = Polys1[LastParent].Edge3
						end
						CoordsT2[#CoordsT2+1] = Polys1[LastParent].Center
						if IncludePointsNodes then
							for j = 1, #Polys1[LastParent].LocalPoints do
								CoordsT2[#CoordsT2+1] = Polys1[LastParent].LocalPoints[j]
							end
						end
						local Dist2 = 10000.0
						local SelectedVector2 = CoordsT2[4]
						for j = 1, #CoordsT2 do
							local Distance = DistanceBetween(CoordsT2[j].x, CoordsT2[j].y, CoordsT2[j].z, Start.x, Start.y, Start.z)
							if Distance < Dist2 then
								Dist2 = Distance
								SelectedVector2 = CoordsT2[j]
							end
						end
						NewNodesT[#NewNodesT+1] = {
							x = SelectedVector2.x,
							y = SelectedVector2.y,
							z = SelectedVector2.z,
							Heading = 0.0,
							ID = PolysCopy[LastParent].ID,
							Parent = PolysCopy[LastParent].Parent,
							NodeFlags = Polys1[LastParent].Flags,
							PolyID = Polys1[LastParent].ID
						}
					end
					break
				end
			--end
			if LowPriorityLevel >= 3 then
				Wait()
			end
		end
		if ThisReachedIndex then
			Nodes[#Nodes+1] = NewNodesT
		end
		--Print(#NewNodesT)
		ReverseList = ReverseList - 1
		break
	end
	if #Nodes <= 0 then
		return nil
	end
	local Reverse = #Nodes[#Nodes]
	local NewPaths = {}
	for k = 1, #Nodes[#Nodes] do
		NewPaths[#NewPaths+1] = Nodes[#Nodes][Reverse]
		Reverse = Reverse - 1
	end
	if Funnel then
		local Start = {x = NewPaths[1].x, y = NewPaths[1].y, z = NewPaths[1].z}
		local End = {x = NewPaths[#NewPaths].x, y = NewPaths[#NewPaths].y, z = NewPaths[#NewPaths].z}
		local Current = 1
		local Finished = false
		for i = 1, 100 do
			if not Finished then
				for k = Current, #NewPaths do
					local Intersect1 = math.findIntersect(Polys1[NewPaths[k].PolyID][1].x, Polys1[NewPaths[k].PolyID][1].y, Polys1[NewPaths[k].PolyID][2].x, Polys1[NewPaths[k].PolyID][2].y, Start.x, Start.y, End.x, End.y, true, true)
					local Intersect2 = math.findIntersect(Polys1[NewPaths[k].PolyID][2].x, Polys1[NewPaths[k].PolyID][2].y, Polys1[NewPaths[k].PolyID][3].x, Polys1[NewPaths[k].PolyID][3].y, Start.x, Start.y, End.x, End.y, true, true)
					local Intersect3 = math.findIntersect(Polys1[NewPaths[k].PolyID][1].x, Polys1[NewPaths[k].PolyID][1].y, Polys1[NewPaths[k].PolyID][3].x, Polys1[NewPaths[k].PolyID][3].y, Start.x, Start.y, End.x, End.y, true, true)
					local Intersect = Intersect1 or Intersect2 or Intersect3
					if not Intersect then
						Current = k
						Start = {x = NewPaths[Current].x, y = NewPaths[Current].y, z = NewPaths[Current].z}
					else
						if k >= #NewPaths then
							local Amount = #NewPaths - (Current)
							for j = 1, Amount do
								if not is_bit_set(NewPaths[#NewPaths].NodeFlags, FlagBitNames.UsePoint) then
									table.remove(NewPaths, #NewPaths)
								end
							end
							NewPaths[#NewPaths+1] = {
								x = End.x,
								y = End.y,
								z = End.z,
								Heading = 0.0,
								ID = PolysCopy[TargetIndex].ID,
								Parent = PolysCopy[TargetIndex].Parent,
								NodeFlags = Polys1[TargetIndex].Flags,
								PolyID = Polys1[TargetIndex].ID
							}
							Finished = true
							break
						end
					end
					--Wait()
				end
				if Current >= #NewPaths then
					Finished = true
				end
			else
				break
			end
			--Wait()
		end
	end
	return NewPaths, StartIndex, TargetIndex, InsideStartPolygon, TargetInsideTargetPolygon
end

function InsidePolygon(polygon, point)
    local oddNodes = false
    local j = #polygon
    for i = 1, #polygon do
        if (polygon[i].y < point.y and polygon[j].y >= point.y or polygon[j].y < point.y and polygon[i].y >= point.y) then
            if (polygon[i].x + ( point.y - polygon[i].y ) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) < point.x) then
                --if (polygon[i].z < point.z+1.0 and polygon[j].z >= point.z-1.0 and polygon[j].z < point.z+1.0 and polygon[i].z >= point.z-1.0) then
                    oddNodes = not oddNodes;
               	--end
            end
        end
        j = i;
    end
    return oddNodes
end

function InsidePolygon2(polygon, point, X, Y)
    local oddNodes = false
    local j = #polygon
    for i = 1, #polygon do
		Print(polygon[i][X] + ( point[Y] - polygon[i][Y] ) / (polygon[j][Y] - polygon[i][Y]) * (polygon[j][X] - polygon[i][X]))
        if (polygon[i][Y] < point[Y] and polygon[j][Y] >= point[Y] or polygon[j][Y] < point[Y] and polygon[i][Y] >= point[Y]) then
            if (polygon[i][X] + ( point[Y] - polygon[i][Y] ) / (polygon[j][Y] - polygon[i][Y]) * (polygon[j][X] - polygon[i][X]) < point[X]) then
                --if (polygon[i].z < point.z+1.0 and polygon[j].z >= point.z-1.0 and polygon[j].z < point.z+1.0 and polygon[i].z >= point.z-1.0) then
                    oddNodes = not oddNodes;
					Print(oddNodes)
               	--end
            end
        end
        j = i;
    end
    return oddNodes
end

function IsPointInPolygon(polygon, point)
    local isInside = false
	local j = #polygon
    for i = 1, #polygon do
        if (((polygon[i].x > point.x) ~= (polygon[j].x > point.x)) and
        point.z <= (polygon[j].z - polygon[i].z) * (point.x - polygon[i].x) / (polygon[j].x - polygon[i].x) + polygon[i].z) then
            isInside = not isInside
		end
	end
    return isInside
end

function Inside3DPolygon(polygon, point)
	local oddNodes = InsidePolygon(polygon, point)
	local Intersect1 =   math.findIntersect(polygon[1].z, polygon[1].x, polygon[2].z, polygon[2].x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect2 =   math.findIntersect(polygon[2].z, polygon[2].x, polygon[3].z, polygon[3].x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect3 =   math.findIntersect(polygon[1].z, polygon[1].x, polygon[3].z, polygon[3].x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect4 =   math.findIntersect(polygon.Center.z, polygon.Center.x, polygon[1].z, polygon[1].x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect5 =   math.findIntersect(polygon.Center.z, polygon.Center.x, polygon[2].z, polygon[2].x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect6 =   math.findIntersect(polygon.Center.z, polygon.Center.x, polygon[3].z, polygon[3].x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect7 =   math.findIntersect(polygon.Center.z, polygon.Center.x, polygon.Edge.z, polygon.Edge.x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect8 =   math.findIntersect(polygon.Center.z, polygon.Center.x, polygon.Edge2.z, polygon.Edge2.x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect9 =   math.findIntersect(polygon.Center.z, polygon.Center.x, polygon.Edge3.z, polygon.Edge3.x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect10 =  math.findIntersect(polygon.Edge.z, polygon.Edge.x, polygon[1].z, polygon[1].x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect11 =  math.findIntersect(polygon.Edge.z, polygon.Edge.x, polygon[2].z, polygon[2].x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect12 =  math.findIntersect(polygon.Edge.z, polygon.Edge.x, polygon[3].z, polygon[3].x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect13 =  math.findIntersect(polygon.Edge2.z, polygon.Edge2.x, polygon[1].z, polygon[1].x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect14 =  math.findIntersect(polygon.Edge2.z, polygon.Edge2.x, polygon[2].z, polygon[2].x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect15 =  math.findIntersect(polygon.Edge2.z, polygon.Edge2.x, polygon[3].z, polygon[3].x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect16 =  math.findIntersect(polygon.Edge3.z, polygon.Edge3.x, polygon[1].z, polygon[1].x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect17 =  math.findIntersect(polygon.Edge3.z, polygon.Edge3.x, polygon[2].z, polygon[2].x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect18 =  math.findIntersect(polygon.Edge3.z, polygon.Edge3.x, polygon[3].z, polygon[3].x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect19 =  math.findIntersect(polygon.Edge.z, polygon.Edge.x, polygon.Edge2.z, polygon.Edge2.x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect20 =  math.findIntersect(polygon.Edge.z, polygon.Edge.x, polygon.Edge3.z, polygon.Edge3.x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Intersect21 =  math.findIntersect(polygon.Edge2.z, polygon.Edge2.x, polygon.Edge3.z, polygon.Edge3.x, point.z + 0.5, point.x, point.z - 0.5, point.x, true, true)
	local Bool = Intersect1 or Intersect2 or Intersect3 or Intersect4 or Intersect5 or Intersect6 or Intersect7 or Intersect8 or Intersect9
	local Bool2 = Intersect10 or Intersect11 or Intersect12 or Intersect13 or Intersect14 or Intersect15 or Intersect16 or Intersect17
	or Intersect18 or Intersect19 or Intersect20 or Intersect21
	local Bool3 = Bool or Bool2
	return oddNodes and Bool3
end

function GetClosestPolygon(PolygonsT, Point, IncludePoints)
	local Dist = 10000.0
	local Index = 0
	local Include = false
	if IncludePoints ~= nil then
		Include = IncludePoints
	end

	for k = 1, #PolygonsT do
		local CoordsT = {}
		CoordsT[#CoordsT+1] = {PolygonsT[k][1], PolygonsT[k].ID}
		CoordsT[#CoordsT+1] = {PolygonsT[k][2], PolygonsT[k].ID}
		CoordsT[#CoordsT+1] = {PolygonsT[k][3], PolygonsT[k].ID}
		CoordsT[#CoordsT+1] = {PolygonsT[k].Center, PolygonsT[k].ID}
		CoordsT[#CoordsT+1] = {PolygonsT[k].Edge, PolygonsT[k].ID}
		CoordsT[#CoordsT+1] = {PolygonsT[k].Edge2, PolygonsT[k].ID}
		CoordsT[#CoordsT+1] = {PolygonsT[k].Edge3, PolygonsT[k].ID}
		if Include then
			for j = 1, #PolygonsT[k].LocalPoints do
				CoordsT[#CoordsT+1] = {PolygonsT[k].LocalPoints[j], PolygonsT[k].ID}
			end
		end
		for i = 1, #CoordsT do
			local Distance = DistanceBetween(Point.x, Point.y, Point.z, CoordsT[i][1].x, CoordsT[i][1].y, CoordsT[i][1].z)
			if Distance < Dist then
				Dist = Distance
				Index = CoordsT[i][2]
			end
		end
	end
	return Index, Dist
end

function DistanceBetween(x1, y1, z1, x2, y2, z2)
	local dx = x1 - x2
	local dy = y1 - y2
	local dz = z1 - z2
	return math.sqrt ( dx * dx + dy * dy + dz * dz)
end

function GetNearPolygonNeighbors(StartIndex, Size)
	local Indexes = {}
	Indexes[#Indexes+1] = StartIndex
	local InsertedIndexes = {}
	InsertedIndexes[StartIndex] = 0
	for k = 1, #Polys1[StartIndex].Neighboors do
		local CanInsert = true
		for j = 1, #Indexes do
			if Polys1[StartIndex].Neighboors[k] == Indexes[j] then
				CanInsert = false
				break
			end
		end
		if CanInsert then
			Indexes[#Indexes+1] = Polys1[StartIndex].Neighboors[k]
		end
	end
	for r = 1, Size do
		for k = 1, #Indexes do
			if Polys1[Indexes[k]] ~= nil then
				for j = 1, #Polys1[Indexes[k]].Neighboors do
					local CanInsert = true
					--for a = 1, #Indexes do
					--	if Polys1[Indexes[k]].Neighboors[j] == Indexes[a] then
					--		CanInsert = false
					--		break
					--	end
					--end
					if InsertedIndexes[Polys1[Indexes[k]].Neighboors[j]] == nil then
						if CanInsert then
							Indexes[#Indexes+1] = Polys1[Indexes[k]].Neighboors[j]
							InsertedIndexes[Polys1[Indexes[k]].Neighboors[j]] = 0
						end
					end
				end
			end
		end
	end
	return Indexes
end

function TrackPolygonIndex(PolyIndexesT, StartIndex, Pos, Size)
	local FoundPoly = false
	local NewIndex = StartIndex
	local IsInsidePolygon = true
	if not InsidePolygon(Polys1[StartIndex], Pos) then
		IsInsidePolygon = false
		for k = 1, #PolyIndexesT do
			if InsidePolygon(Polys1[PolyIndexesT[k]], Pos) then
				NewIndex = PolyIndexesT[k]
				break
			end
		end
		if not FoundPoly then
			local Index = GetClosestPolygon(Polys1, Pos)
			PolyIndexesT = GetNearPolygonNeighbors(Index, Size)
			NewIndex = Index
		end
	end
	return NewIndex, IsInsidePolygon, FoundPoly
end

function TrackNewPolygonIndex(T, TargetIndex, Pos, PathsT)
	if not InsidePolygon(Polys1[TargetIndex], Pos) then
		if not T.HasSet then
			local NextPolygonID = 0
			for i = 1, #Polys1[TargetIndex].Neighboors do

			end
			if PathsT ~= nil then
				local CoordsT2 = {}
				CoordsT2[#CoordsT2+1] = Polys1[TargetIndex][1]
				CoordsT2[#CoordsT2+1] = Polys1[TargetIndex][2]
				CoordsT2[#CoordsT2+1] = Polys1[TargetIndex][3]
				CoordsT2[#CoordsT2+1] = Polys1[TargetIndex].Center
				CoordsT2[#CoordsT2+1] = Polys1[TargetIndex].Edge
				CoordsT2[#CoordsT2+1] = Polys1[TargetIndex].Edge2
				CoordsT2[#CoordsT2+1] = Polys1[TargetIndex].Edge3
				local Dist2 = 10000.0
				local SelectedVector2 = CoordsT2[4]
				for j = 1, #CoordsT2 do
					local Distance = DistanceBetween(CoordsT2[j].x, CoordsT2[j].y, CoordsT2[j].z, Pos.x, Pos.y, Pos.z)
					if Distance < Dist2 then
						Dist2 = Distance
						SelectedVector2 = CoordsT2[j]
					end
				end
				PathsT[#PathsT+1] = {
					x = SelectedVector2.x,
					y = SelectedVector2.y,
					z = SelectedVector2.z,
					Heading = 0.0,
					ID = Polys1[TargetIndex].ID,
					Parent = TargetIndex,
					NodeFlags = Polys1[TargetIndex].Flags,
					PolyID = Polys1[TargetIndex].ID
				}
			end
		end
	end
end


-- Checks if two lines intersect (or line segments if seg is true)
-- Lines are given as four numbers (two coordinates)
function math.findIntersect(l1p1x,l1p1y, l1p2x,l1p2y, l2p1x,l2p1y, l2p2x,l2p2y, seg1, seg2)
	local a1,b1,a2,b2 = l1p2y-l1p1y, l1p1x-l1p2x, l2p2y-l2p1y, l2p1x-l2p2x
	local c1,c2 = a1*l1p1x+b1*l1p1y, a2*l2p1x+b2*l2p1y
	local det,x,y = a1*b2 - a2*b1
	if det==0 then return false, 0.0, 0.0 end --"The lines are parallel."
	x,y = (b2*c1-b1*c2)/det, (a1*c2-a2*c1)/det
	if seg1 or seg2 then
	  local min,max = math.min, math.max
	  if seg1 and not (min(l1p1x,l1p2x) <= x and x <= max(l1p1x,l1p2x) and min(l1p1y,l1p2y) <= y and y <= max(l1p1y,l1p2y)) or
		 seg2 and not (min(l2p1x,l2p2x) <= x and x <= max(l2p1x,l2p2x) and min(l2p1y,l2p2y) <= y and y <= max(l2p1y,l2p2y)) then
		return false, 0.0, 0.0 -- "The lines don't intersect."
	  	end
	end
	return true, x, y
end

function SaveJSONFile(FileName, JSONContents)
    local File = io.open(FileName, "w+")
    if File then
        local Contents = json.encode(JSONContents)
        File:write(Contents)
        io.close(File)
    end
end

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
		FlagBits,
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
	return memory.read_byte(DidHit) ~= 0, HitCoords, memory.read_int(HitEntity), Normal
end

function RequestControlOfEntity(Entity)
	if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(Entity) then
		return true
	else
		return NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(Entity)
	end
end

function CanIntersectEntity(Pos, TargetPos, Paths, CurrentIndex)
	local CanIntersect = true
	if Paths ~= nil then
		for k = CurrentIndex, #Paths do
			if Paths[k] ~= nil then
				local Intersect1 = math.findIntersect(Polys1[Paths[k].PolyID][1].x, Polys1[Paths[k].PolyID][1].y, Polys1[Paths[k].PolyID][2].x, Polys1[Paths[k].PolyID][2].y, Pos.x, Pos.y, TargetPos.x, TargetPos.y, true, true)
				local Intersect2 = math.findIntersect(Polys1[Paths[k].PolyID][2].x, Polys1[Paths[k].PolyID][2].y, Polys1[Paths[k].PolyID][3].x, Polys1[Paths[k].PolyID][3].y, Pos.x, Pos.y, TargetPos.x, TargetPos.y, true, true)
				local Intersect3 = math.findIntersect(Polys1[Paths[k].PolyID][1].x, Polys1[Paths[k].PolyID][1].y, Polys1[Paths[k].PolyID][3].x, Polys1[Paths[k].PolyID][3].y, Pos.x, Pos.y, TargetPos.x, TargetPos.y, true, true)
				local Intersect = Intersect1 or Intersect2 or Intersect3
				if not Intersect then
					CanIntersect = false
					break
				end
			else
				CanIntersect = false
				break
			end
		end
	else
		CanIntersect = false
	end
	return CanIntersect 
end

function GetPositionCircle(Center, Radius, Angle)
	local NewPoint = {
		x = Center.x + Radius * math.cos(math.rad(Angle)),
		y = Center.y + Radius * math.sin(math.rad(Angle)),
		z = Center.z
	}
	return NewPoint
end

function ROTATION_TO_DIRECTION(rotation) 
	local adjusted_rotation = { 
		x = (math.pi / 180) * rotation.x, 
		y = (math.pi / 180) * rotation.y, 
		z = (math.pi / 180) * rotation.z 
	}
	local direction = {
		x = - math.sin(adjusted_rotation.z) * math.abs(math.cos(adjusted_rotation.x)), 
		y =   math.cos(adjusted_rotation.z) * math.abs(math.cos(adjusted_rotation.x)), 
		z =   math.sin(adjusted_rotation.x)
	}
	return direction
end

function GetEntityMatrix(element)
    local rot = ENTITY.GET_ENTITY_ROTATION(element, 2) -- ZXY
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
	
    matrix[4] = {}
    local Pos = ENTITY.GET_ENTITY_COORDS(element)
    matrix[4][1], matrix[4][2], matrix[4][3] = Pos.x, Pos.y, Pos.z - 1.0
    matrix[4][4] = 1
	
    return matrix
end

function GetOffsetFromEntityInWorldCoords(entity, offX, offY, offZ)
    local m = GetEntityMatrix(entity)
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return {x = x, y = y, z = z}
end

function GetRotationMatrix(rot)
    --local rot = ENTITY.GET_ENTITY_ROTATION(element, 2) -- ZXY
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
	
    return matrix
end

function GetOffsetFromRotationInWorldCoords(rot, Pos, offX, offY, offZ)
    local m = GetRotationMatrix(rot)
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + Pos.x
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + Pos.y
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + (Pos.z - 1.0)
    return {x = x, y = y, z = z}
end

local PolyIDs = {}

function SetPolyIDs()
	for i = 1, #Polys1 do
		local XID = math.floor(Polys1[i].Edge.x)
		local YID = math.floor(Polys1[i].Edge.y)
		local ZID = math.floor(Polys1[i].Edge.z)
		local XID2 = math.floor(Polys1[i].Edge2.x)
		local YID2 = math.floor(Polys1[i].Edge2.y)
		local ZID2 = math.floor(Polys1[i].Edge2.z)
		local XID3 = math.floor(Polys1[i].Edge3.x)
		local YID3 = math.floor(Polys1[i].Edge3.y)
		local ZID3 = math.floor(Polys1[i].Edge3.z)
		if PolyIDs[XID] == nil then
			PolyIDs[XID] = {}
		end
		if PolyIDs[XID][YID] == nil then
			PolyIDs[XID][YID] = {}
		end
		PolyIDs[XID][YID][ZID] = Polys1[i].ID
		if PolyIDs[XID2] == nil then
			PolyIDs[XID2] = {}
		end
		if PolyIDs[XID2][YID2] == nil then
			PolyIDs[XID2][YID2] = {}
		end
		PolyIDs[XID2][YID2][ZID2] = Polys1[i].ID
		if PolyIDs[XID3] == nil then
			PolyIDs[XID3] = {}
		end
		if PolyIDs[XID3][YID3] == nil then
			PolyIDs[XID3][YID3] = {}
		end
		PolyIDs[XID3][YID3][ZID3] = Polys1[i].ID
		for k = 1, #Polys1[i].LocalPoints do
			local Vector3 = Polys1[i].LocalPoints[k]
			local XID4 = math.floor(Vector3.x)
			local YID4 = math.floor(Vector3.y)
			local ZID4 = math.floor(Vector3.z)
			if PolyIDs[XID4] == nil then
				PolyIDs[XID4] = {}
			end
			if PolyIDs[XID4][YID4] == nil then
				PolyIDs[XID4][YID4] = {}
			end
			PolyIDs[XID4][YID4][ZID4] = Polys1[i].ID
		end
		local XID4 = math.floor(Polys1[i][1].x)
		local YID4 = math.floor(Polys1[i][1].y)
		local ZID4 = math.floor(Polys1[i][1].z)
		local XID5 = math.floor(Polys1[i][2].x)
		local YID5 = math.floor(Polys1[i][2].y)
		local ZID5 = math.floor(Polys1[i][2].z)
		local XID6 = math.floor(Polys1[i][3].x)
		local YID6 = math.floor(Polys1[i][3].y)
		local ZID6 = math.floor(Polys1[i][3].z)
		if PolyIDs[XID4] == nil then
			PolyIDs[XID4] = {}
		end
		if PolyIDs[XID4][YID4] == nil then
			PolyIDs[XID4][YID4] = {}
		end
		PolyIDs[XID4][YID4][ZID4] = Polys1[i].ID
		if PolyIDs[XID5] == nil then
			PolyIDs[XID5] = {}
		end
		if PolyIDs[XID5][YID5] == nil then
			PolyIDs[XID5][YID5] = {}
		end
		PolyIDs[XID5][YID5][ZID5] = Polys1[i].ID
		if PolyIDs[XID6] == nil then
			PolyIDs[XID6] = {}
		end
		if PolyIDs[XID6][YID6] == nil then
			PolyIDs[XID6][YID6] = {}
		end
		PolyIDs[XID6][YID6][ZID6] = Polys1[i].ID
		local XID7 = math.floor(Polys1[i].Center.x)
		local YID7 = math.floor(Polys1[i].Center.y)
		local ZID7 = math.floor(Polys1[i].Center.z)
		if PolyIDs[XID7] == nil then
			PolyIDs[XID7] = {}
		end
		if PolyIDs[XID7][YID7] == nil then
			PolyIDs[XID7][YID7] = {}
		end
		PolyIDs[XID7][YID7][ZID7] = Polys1[i].ID
	end
end
SetPolyIDs()

menu.action(TestMenu, "Get Poly Index", {}, "", function(Toggle)
	local PlayerPed = PLAYER.PLAYER_PED_ID()
	local Pos = ENTITY.GET_ENTITY_COORDS(PlayerPed)
	local XID = math.floor(Pos.x)
	local YID = math.floor(Pos.y)
	local ZID = math.floor(Pos.z)
	local Index = 1
	if PolyIDs[XID] ~= nil then
		if PolyIDs[XID][YID] ~= nil then
			if PolyIDs[XID][YID][ZID] ~= nil then
				Index = PolyIDs[XID][YID][ZID]
			end
		end
	end
	ENTITY.SET_ENTITY_COORDS(PlayerPed, Polys1[Index].Center.x, Polys1[Index].Center.y, Polys1[Index].Center.z - 1.0)
	local XID2 = math.floor(Polys1[Index].Center.x)
	local YID2 = math.floor(Polys1[Index].Center.y)
	local ZID2 = math.floor(Polys1[Index].Center.z)
	for i = 1, 200 do
		directx.draw_text(0.7, 0.7, "x: "..XID.." y: "..YID.." z: "..ZID , ALIGN_CENTRE, 1.0, {r = 1.0, g = 1.0 , b = 1.0, a = 1.0}, false)
		directx.draw_text(0.7, 0.75, "x: "..XID2.." y: "..YID2.." z: "..ZID2 , ALIGN_CENTRE, 1.0, {r = 1.0, g = 1.0 , b = 1.0, a = 1.0}, false)
		Wait()
	end
end)

function GetPolygonDirectIndex(Pos)
	local XID = math.floor(Pos.x)
	local YID = math.floor(Pos.y)
	local ZID = math.floor(Pos.z)
	local Index = 0
	if PolyIDs[XID] ~= nil then
		if PolyIDs[XID][YID] ~= nil then
			if PolyIDs[XID][YID][ZID] ~= nil then
				Index = PolyIDs[XID][YID][ZID]
			end
		end
	end
	return Index
end

local AiHateRel = "rgFM_AiHate"
local AiLikeRel = "rgFM_AiLike"
local AiLikeHateAiHateRel = "rgFM_AiLike_HateAiHate"
local AiHateAiHateRel = "rgFM_HateAiHate"
local AiHateEveryone = "rgFM_HateEveryOne"

local DMTest = false
menu.toggle(TestMenu, "Multiple Peds For Navs", {}, "", function(Toggle)
	DMTest = Toggle
	if not DMTest then
		for index, peds in pairs(entities.get_all_peds_as_handles()) do
			if DECORATOR.DECOR_EXIST_ON(peds, "Casino_Game_Info_Decorator") then
				RequestControlOfEntity(peds)
				local NetID = NETWORK.PED_TO_NET(peds)
				if NetID ~= 0 then
					NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PLAYER.PLAYER_ID(), false)
				end
				entities.delete_by_handle(peds)
			end
		end
	end
	if DMTest then
		local AiTeam1Hash = joaat("rgFM_AiPed20000")
		local Peds = {}
		local HandlesT = {}
		local PedModel = joaat("mp_m_bogdangoon")
		local StartPos = {x = StartPath.x, y = StartPath.y, z = StartPath.z}
		while DMTest do
			if #Peds < 10 then
				STREAMING.REQUEST_MODEL(PedModel)
				if STREAMING.HAS_MODEL_LOADED(PedModel) then
					local PedHandle = PED.CREATE_PED(28, joaat("mp_m_bogdangoon"), StartPos.x, StartPos.y, StartPos.z, 0.0, true, true)
					if PedHandle ~= 0 then
						ENTITY.SET_ENTITY_AS_MISSION_ENTITY(PedHandle, false, true)
						local NetID = NETWORK.PED_TO_NET(PedHandle)
						if NetID ~= 0 then
							NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NetID, PLAYER.PLAYER_ID(), true)
							NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(NetID, true)
							NETWORK.SET_NETWORK_ID_CAN_MIGRATE(NetID, false)
						end
						PED.SET_PED_RELATIONSHIP_GROUP_HASH(PedHandle, joaat(AiHateRel))
						WEAPON.GIVE_WEAPON_TO_PED(PedHandle, joaat("weapon_knife"), 99999, false, true)
						DECORATOR.DECOR_SET_INT(PedHandle, "Casino_Game_Info_Decorator", 1)
						if HandlesT[PedHandle] == nil then
							Peds[#Peds+1] = {}
							Peds[#Peds].Handle = PedHandle
							Peds[#Peds].TaskState = 0
							Peds[#Peds].Target = 0
							Peds[#Peds].TaskCoords = {x = 0.0, y = 0.0, z = 0.0}
							Peds[#Peds].TaskCoords2 = {x = 0.0, y = 0.0, z = 0.0}
							Peds[#Peds].Paths = nil
							Peds[#Peds].ActualPath = 1
							Peds[#Peds].SearchState = 0
							Peds[#Peds].SearchCalled = false
							Peds[#Peds].Start = nil
							Peds[#Peds].TargetPoly = nil
							Peds[#Peds].InsideStartPolygon = false
							Peds[#Peds].TargetInsideTargetPolygon = false
							Peds[#Peds].HasSetRel = false
							Peds[#Peds].TimeOut = 0
							Peds[#Peds].SearchLowLevel = 1
							Peds[#Peds].IsInVeh = false
							Peds[#Peds].VehHandle = 0
							Peds[#Peds].LastDistance = 0.0
							Peds[#Peds].SameDistanceTick = 0
							Peds[#Peds].StartPolysT = {}
							Peds[#Peds].TargetPolysT = {}
							Peds[#Peds].DrivingStyle = 0
							Peds[#Peds].NetID = NetID
							Peds[#Peds].IsZombie = false
							Peds[#Peds].JumpDelay = 0
							Peds[#Peds].StartIndexArg = nil
							Peds[#Peds].TargetIndexArg = nil
							Peds[#Peds].AddMode = false
							Peds[#Peds].HasChecked = false
							Peds[#Peds].LastPolyID = 0
							Peds[#Peds].LastTargetPos = {x = 0.0, y = 0.0, z = 0.0}
							PED.SET_PED_TARGET_LOSS_RESPONSE(PedHandle, 1)
							PED.SET_COMBAT_FLOAT(PedHandle, 2, 4000.0)
							PED.SET_PED_COMBAT_RANGE(PedHandle, 3)
							PED.SET_PED_FIRING_PATTERN(PedHandle, joaat("FIRING_PATTERN_FULL_AUTO"))
							PED.SET_PED_COMBAT_ATTRIBUTES(PedHandle, 5, true)
							PED.SET_PED_COMBAT_ATTRIBUTES(PedHandle, 46, true)
							HandlesT[PedHandle] = 0
						end
					end
				end
			else
				STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(PedModel)
			end
			for k = 1, #Peds do
				if Peds[k] ~= nil then
					if not ENTITY.IS_ENTITY_DEAD(Peds[k].Handle) and ENTITY.DOES_ENTITY_EXIST(Peds[k].Handle) then
						if RequestControlOfEntity(Peds[k].Handle) then
							entities.set_can_migrate(Peds[k].Handle, false)
						end
						if WEAPON.IS_PED_ARMED(Peds[k].Handle, 1) then
							Peds[k].IsZombie = true
							PED.SET_COMBAT_FLOAT(Peds[k].Handle, 7, 3.0)
							PED.SET_PED_RESET_FLAG(Peds[k].Handle, 306, true)
							PED.SET_PED_CONFIG_FLAG(Peds[k].Handle, 435, true)
						end
						if Peds[k].IsZombie then
							--PED.SET_PED_MOVE_RATE_OVERRIDE(Peds[k].Handle, 1.5)
							PED.SET_AI_MELEE_WEAPON_DAMAGE_MODIFIER(100.0)
							PED.SET_PED_USING_ACTION_MODE(Peds[k].Handle, false, -1, 0)
							PED.SET_PED_MIN_MOVE_BLEND_RATIO(Peds[k].Handle, 3.0)
							PED.SET_PED_MAX_MOVE_BLEND_RATIO(Peds[k].Handle, 3.0)
						end
						local LastEnt = ENTITY._GET_LAST_ENTITY_HIT_BY_ENTITY(Peds[k].Handle)
						if LastEnt ~= 0 then
							if ENTITY.IS_ENTITY_A_PED(LastEnt) then
								if PED.GET_PED_RELATIONSHIP_GROUP_HASH(LastEnt) == PED.GET_PED_RELATIONSHIP_GROUP_HASH(Peds[k].Handle) then
									ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(Peds[k].Handle, LastEnt, false)
								end
							end
						end
						--ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(Peds[k].Handle, LastHandle, false)
						local Pos = ENTITY.GET_ENTITY_COORDS(Peds[k].Handle)
						if not Peds[k].HasSetRel then
							if PED.DOES_RELATIONSHIP_GROUP_EXIST(joaat(AiHateRel)) then
								if RequestControlOfEntity(Peds[k].Handle) then
									--PED.SET_PED_RELATIONSHIP_GROUP_HASH(Peds[k].Handle, AiTeam1Hash)
									Peds[k].HasSetRel = true
								end
							end
						end
						if Peds[k].TaskState == 6 then
							--TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(Peds[k].Handle, 1000.0, 16)
							local Target = PED.GET_PED_TARGET_FROM_COMBAT_PED(Peds[k].Handle, 0)
							if Target ~= 0 then
								Peds[k].Target = Target
								Peds[k].TaskState = 1
							end
						end
						if Peds[k].TaskState == 0 then
							--TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(Peds[k].Handle, 1000.0, 16)
							local Target = PED.GET_PED_TARGET_FROM_COMBAT_PED(Peds[k].Handle, 0)
							if Target ~= 0 then
								Peds[k].Target = Target
								Peds[k].TaskState = 1
							end
						end
						if Peds[k].SearchState == 0 then
							if Peds[k].Target ~= 0 then
								local Pos = ENTITY.GET_ENTITY_COORDS(Peds[k].Handle)
								local TargetPos = ENTITY.GET_ENTITY_COORDS(Peds[k].Target)
								Peds[k].SearchState = 1
								util.create_thread(function()
									local NewPaths = nil
									NewPaths, Peds[k].Start, Peds[k].TargetPoly, Peds[k].InsideStartPolygon, Peds[k].TargetInsideTargetPolygon = AStarPathFind(Pos, TargetPos, Peds[k].SearchLowLevel, false, Peds[k].StartIndexArg, Peds[k].TargetIndexArg, false, false, nil, false)
									if NewPaths ~= nil then
										if Peds[k] ~= nil then
											if not Peds[k].AddMode then
												Peds[k].Paths = NewPaths
											else
												for i = 1, #NewPaths do
													table.insert(Peds[k].Paths, NewPaths[i])
												end
											end
											--Peds[k].SearchLowLevel = 1
											--Print("Found path")
											Peds[k].LastTargetPos.x = TargetPos.x
											Peds[k].LastTargetPos.y = TargetPos.y
											Peds[k].LastTargetPos.z = TargetPos.z
											Peds[k].ActualPath = 1
											Peds[k].TaskState = 1
											Peds[k].StartIndexArg = nil
											Peds[k].TargetIndexArg = nil
											Peds[k].AddMode = false
										end
										--PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
									end
									
									Wait(1000)
									if Peds[k] ~= nil then
										Peds[k].SearchState = 2
										--Print("Reset")
									end
								end)
							end
						end
						if Peds[k].Target ~= 0 then
							if Peds[k].Paths ~= nil then
								local TargetPos = ENTITY.GET_ENTITY_COORDS(Peds[k].Target)
								local DistanceFinal = DistanceBetween(TargetPos.x, TargetPos.y, TargetPos.z, Peds[k].Paths[#Peds[k].Paths].x, Peds[k].Paths[#Peds[k].Paths].y, Peds[k].Paths[#Peds[k].Paths].z)
								local DistanceLast = DistanceBetween(TargetPos.x, TargetPos.y, TargetPos.z, Peds[k].LastTargetPos.x, Peds[k].LastTargetPos.y, Peds[k].LastTargetPos.z)
								if DistanceFinal > 30.0 or DistanceLast > 2.0 then
									if Peds[k].SearchState == 2 then
										Peds[k].SearchState = 0
										Peds[k].SearchLowLevel = 7
									end
								end
								
							end
						end
						if Peds[k].TaskState == 1 then
							if Peds[k].Paths ~= nil then
								--if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_CLIMB")) == 7 then
								if not Peds[k].IsZombie then
									if RequestControlOfEntity(Peds[k].Handle) then
										--PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
										--TASK.CLEAR_PED_TASKS(Peds[k].Handle)
										if Peds[k].ActualPath > #Peds[k].Paths then
											Peds[k].ActualPath = 1
											if Peds[k].SearchState == 2 then
												Peds[k].SearchState = 0
												Peds[k].SearchLowLevel = 1
											end
										end
										if Peds[k].Paths[Peds[k].ActualPath] ~= nil then
											Peds[k].TaskCoords.x = Peds[k].Paths[Peds[k].ActualPath].x
											Peds[k].TaskCoords.y = Peds[k].Paths[Peds[k].ActualPath].y
											Peds[k].TaskCoords.z = Peds[k].Paths[Peds[k].ActualPath].z
											TASK.TASK_GO_TO_COORD_WHILE_AIMING_AT_ENTITY(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, Peds[k].Target, 2.0, true, 0.1, 0.1, false, 0, true, joaat("FIRING_PATTERN_FULL_AUTO"), -1)
											PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
											if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_GO_TO_COORD_WHILE_AIMING_AT_ENTITY")) ~= 7 then
												Peds[k].TaskState = 2
											end
										end
									end
								else
									if not ENTITY.IS_ENTITY_AT_ENTITY(Peds[k].Handle, Peds[k].Target, 5.5, 5.5, 2.5, false, true, 0) then
										if RequestControlOfEntity(Peds[k].Handle) then
											
											--TASK.CLEAR_PED_TASKS(Peds[k].Handle)
											--PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
											if Peds[k].ActualPath > #Peds[k].Paths then
												Peds[k].ActualPath = 1
												if Peds[k].SearchState == 2 then
													Peds[k].SearchState = 0
													Peds[k].SearchLowLevel = 1
												end
											end
											if Peds[k].Paths[Peds[k].ActualPath] ~= nil then
												local Pos = ENTITY.GET_ENTITY_COORDS(Peds[k].Handle)
												if Peds[k].Paths[Peds[k].ActualPath].Action ~= nil then
													if InsidePolygon(Polys1[Peds[k].Paths[Peds[k].ActualPath].PolyID], Pos) then
														Peds[k].ActualPath = Peds[k].ActualPath + 1
													end
												end
												local NewV3 = v3.new(Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z)
												local Sub = v3.sub(NewV3, Pos)
												local Rot = Sub:toRot()
												--ENTITY.SET_ENTITY_HEADING(Peds[k].Handle, Rot.z, 2)
												Dir = Rot:toDir()
												Peds[k].TaskCoords.x = Peds[k].Paths[Peds[k].ActualPath].x
												Peds[k].TaskCoords.y = Peds[k].Paths[Peds[k].ActualPath].y
												Peds[k].TaskCoords.z = Peds[k].Paths[Peds[k].ActualPath].z
												Peds[k].TaskCoords2.x = Peds[k].Paths[Peds[k].ActualPath].x + Dir.x * 2.0
												Peds[k].TaskCoords2.y = Peds[k].Paths[Peds[k].ActualPath].y + Dir.y * 2.0
												Peds[k].TaskCoords2.z = Peds[k].Paths[Peds[k].ActualPath].z + Dir.z * 2.0
												Peds[k].LastDistance = DistanceBetween(Pos.x, Pos.y, Pos.z, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z)
												--TASK.TASK_GO_TO_COORD_WHILE_AIMING_AT_ENTITY(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, Peds[k].Target, 2.0, true, 0.1, 0.1, false, 0, true, joaat("FIRING_PATTERN_FULL_AUTO"), -1)
												--TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
												if Peds[k].Paths[Peds[k].ActualPath].Action == nil then
													TASK.TASK_GO_STRAIGHT_TO_COORD(Peds[k].Handle, Peds[k].TaskCoords2.x, Peds[k].TaskCoords2.y, Peds[k].TaskCoords2.z, 3.0, -1, 40000.0, 0.1)
												else
													TASK.TASK_GO_STRAIGHT_TO_COORD(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, 2.0, -1, 40000.0, 0.1)
												end
												PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
												if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_GO_STRAIGHT_TO_COORD")) ~= 7 then
													Peds[k].TaskState = 3
													--Print("Straight")
												end
											end
										end
									else
										local HasSetTask = false
										local TargetPos = ENTITY.GET_ENTITY_COORDS(Peds[k].Target)
										local Distance3 = DistanceBetween(Pos.x, Pos.y, Pos.z, TargetPos.x, TargetPos.y, TargetPos.z)
										if Distance3 < 1.5 then
											if RequestControlOfEntity(Peds[k].Handle) then
												TASK.TASK_COMBAT_PED(Peds[k].Handle, Peds[k].Target, 201326592, 16)
												PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
												if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_COMBAT")) ~= 7 then
													--Print("Combat")
													Peds[k].TaskState = 4
												end
												HasSetTask = true
											end
										end
										if not HasSetTask then
											--if Distance3 < 5.5 then
												--if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(Peds[k].Handle, Peds[k].Target, 17) then
												if CanIntersectEntity(Pos, TargetPos, Peds[k].Paths, Peds[k].ActualPath) then
													if RequestControlOfEntity(Peds[k].Handle) then
														TASK.TASK_GO_STRAIGHT_TO_COORD_RELATIVE_TO_ENTITY(Peds[k].Handle, Peds[k].Target, 0.0, 0.0, 2.0, 3.0, -1)
														PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
														if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_GO_STRAIGHT_TO_COORD_RELATIVE_TO_ENTITY")) ~= 7 then
															--Print("Combat")
															Peds[k].TaskState = 6
														end
													end
												else
													if RequestControlOfEntity(Peds[k].Handle) then
														if Peds[k].ActualPath > #Peds[k].Paths then
															Peds[k].ActualPath = 1
															if Peds[k].SearchState == 2 then
																Peds[k].SearchState = 0
																Peds[k].SearchLowLevel = 1
															end
														end
														if Peds[k].Paths[Peds[k].ActualPath] ~= nil then
															local Pos = ENTITY.GET_ENTITY_COORDS(Peds[k].Handle)
															if Peds[k].Paths[Peds[k].ActualPath].Action ~= nil then
																if InsidePolygon(Polys1[Peds[k].Paths[Peds[k].ActualPath].PolyID], Pos) then
																	Peds[k].ActualPath = Peds[k].ActualPath + 1
																end
															end
															local NewV3 = v3.new(Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z)
															local Sub = v3.sub(NewV3, Pos)
															local Rot = Sub:toRot()
															Dir = Rot:toDir()
															Peds[k].TaskCoords.x = Peds[k].Paths[Peds[k].ActualPath].x
															Peds[k].TaskCoords.y = Peds[k].Paths[Peds[k].ActualPath].y
															Peds[k].TaskCoords.z = Peds[k].Paths[Peds[k].ActualPath].z
															Peds[k].TaskCoords2.x = Peds[k].Paths[Peds[k].ActualPath].x + Dir.x * 1.0
															Peds[k].TaskCoords2.y = Peds[k].Paths[Peds[k].ActualPath].y + Dir.y * 1.0
															Peds[k].TaskCoords2.z = Peds[k].Paths[Peds[k].ActualPath].z + Dir.z * 1.0
															Peds[k].LastDistance = DistanceBetween(Pos.x, Pos.y, Pos.z, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z)
															--TASK.TASK_GO_TO_COORD_WHILE_AIMING_AT_ENTITY(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, Peds[k].Target, 2.0, true, 0.1, 0.1, false, 0, true, joaat("FIRING_PATTERN_FULL_AUTO"), -1)
															--TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
															if Peds[k].Paths[Peds[k].ActualPath].Action == nil then
																TASK.TASK_GO_STRAIGHT_TO_COORD(Peds[k].Handle, Peds[k].TaskCoords2.x, Peds[k].TaskCoords2.y, Peds[k].TaskCoords2.z, 3.0, -1, 40000.0, 0.1)
															else
																TASK.TASK_GO_STRAIGHT_TO_COORD(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, 2.0, -1, 40000.0, 0.1)
															end
															PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, true)
															if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_GO_STRAIGHT_TO_COORD")) ~= 7 then
																Peds[k].TaskState = 3
																--Print("Straight")
															end
														end
													end
												end
											--end
										end
									end
								end
							--end
							else
								if Peds[k].SearchState == 2 then
									Peds[k].SearchState = 0
									Peds[k].SearchLowLevel = 1
								end
							end
						end
						if Peds[k].TaskState == 2 then
							if not ENTITY.IS_ENTITY_DEAD(Peds[k].Target) and ENTITY.DOES_ENTITY_EXIST(Peds[k].Target) then
								if Peds[k].Paths ~= nil then
									if Peds[k].SearchState == 2 then
										if Peds[k].TargetPoly ~= nil then
											local TargetPos = ENTITY.GET_ENTITY_COORDS(Peds[k].Target)
											if Peds[k].TargetInsideTargetPolygon then
												if not InsidePolygon(Polys1[Peds[k].TargetPoly], TargetPos) then
													--Peds[k].TaskState = 1
													if Peds[k].SearchState == 2 then
														Peds[k].SearchState = 0
													end
												end
											else
												if InsidePolygon(Polys1[Peds[k].TargetPoly], TargetPos) then
													--Peds[k].TaskState = 1
													if Peds[k].SearchState == 2 then
														Peds[k].SearchState = 0
													end
												end
											end
										else
											if Peds[k].SearchState == 2 then
												Peds[k].SearchState = 0
											end
										end
									end
									if ENTITY.IS_ENTITY_AT_COORD(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, 0.15, 0.15, 100.0, false, false, 0) then
										if Peds[k].SearchState == 2 then
											Peds[k].SearchState = 0
										end
									end
									if ENTITY.IS_ENTITY_AT_COORD(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, 0.5, 0.5, 1.0, false, false, 0) then
										if RequestControlOfEntity(Peds[k].Handle) then
											PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
											--TASK.CLEAR_PED_TASKS(Peds[k].Handle)
											Peds[k].ActualPath = Peds[k].ActualPath + 1
											if Peds[k].ActualPath > #Peds[k].Paths then
												Peds[k].ActualPath = 1
												if Peds[k].SearchState == 2 then
													Peds[k].SearchState = 0
												end
												Peds[k].SearchLowLevel = 1
											end
											Peds[k].TaskState = 1
										end
									else
										Peds[k].TimeOut = Peds[k].TimeOut + 1
										if Peds[k].TimeOut > 1000 then
											if Peds[k].SearchState == 2 then
												if RequestControlOfEntity(Peds[k].Handle) then
													PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
													TASK.CLEAR_PED_TASKS(Peds[k].Handle)
													Peds[k].SearchState = 0
													Peds[k].TaskState = 1
												end
											end
										end
									end
									if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_GO_TO_COORD_WHILE_AIMING_AT_ENTITY")) == 7 then
										Peds[k].TaskState = 1
										--Print("No action")
									end
								else
									if Peds[k].SearchState == 2 then
										Peds[k].SearchState = 0
										Peds[k].SearchLowLevel = 1
									end
								end
							else
								if RequestControlOfEntity(Peds[k].Handle) then
									PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
									TASK.CLEAR_PED_TASKS(Peds[k].Handle)
									Peds[k].TaskState = 0
									Peds[k].Target = 0
									Peds[k].ActualPath = 1
									Peds[k].SearchLowLevel = 1
								end
							end
						end
						GRAPHICS.DRAW_LINE(Pos.x, Pos.y, Pos.z,
						Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, 255, 255, 255, 255)
						if Peds[k].Paths ~= nil then
							for i = Peds[k].ActualPath, #Peds[k].Paths-1 do
								GRAPHICS.DRAW_LINE(Peds[k].Paths[i].x, Peds[k].Paths[i].y, Peds[k].Paths[i].z,
								Peds[k].Paths[i+1].x, Peds[k].Paths[i+1].y, Peds[k].Paths[i+1].z, 255, 255, 255, 255)
							end
						end
						if Peds[k].TaskState == 3 then
							if Peds[k].Paths[Peds[k].ActualPath].Action ~= nil then
								if InsidePolygon(Polys1[Peds[k].Paths[Peds[k].ActualPath].PolyID], Pos) then
									Peds[k].ActualPath = Peds[k].ActualPath + 1
									Peds[k].TaskState = 1
								end
							end
							if not ENTITY.IS_ENTITY_DEAD(Peds[k].Target) and ENTITY.DOES_ENTITY_EXIST(Peds[k].Target) then
								local Distance2 = DistanceBetween(Pos.x, Pos.y, Pos.z, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z)
								Peds[k].SameDistanceTick = Peds[k].SameDistanceTick + 1
								local HasSet = false
								if Distance2 < Peds[k].LastDistance then
									Peds[k].LastDistance = Distance2
									Peds[k].SameDistanceTick = 0
								end
								--Distance2 > Peds[k].LastDistance then
								if Peds[k].SameDistanceTick > 50 or math.floor(Distance2) > math.floor(Peds[k].LastDistance) then
									--Peds[k].TaskState = 1
									--Peds[k].ActualPath = Peds[k].ActualPath + 1
									--if Peds[k].ActualPath > #Peds[k].Paths then
									--	Peds[k].ActualPath = 1
									--	if Peds[k].SearchState == 2 then
									--		Peds[k].SearchState = 0
									--	end
									--end
									if Peds[k].SearchState == 2 then
										Peds[k].SearchState = 0
										Peds[k].SearchLowLevel = 1
									end
								end
								if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_GO_STRAIGHT_TO_COORD")) == 7 then
									if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_CLIMB")) == 7 then
										if RequestControlOfEntity(Peds[k].Handle) then
											Peds[k].TaskState = 1
											TASK.TASK_GO_STRAIGHT_TO_COORD(Peds[k].Handle, Peds[k].TaskCoords2.x, Peds[k].TaskCoords2.y, Peds[k].TaskCoords2.z, 3.0, -1, 40000.0, 0.1)
										end
									end
								end
								if not HasSet then
									if ENTITY.IS_ENTITY_AT_ENTITY(Peds[k].Handle, Peds[k].Target, 5.0, 5.0, 2.5, false, true, 0) then
										if RequestControlOfEntity(Peds[k].Handle) then
											--PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
											--TASK.CLEAR_PED_TASKS(Peds[k].Handle)
											Peds[k].TaskState = 1
											--HasSet = true
											Peds[k].SameDistanceTick = 0
										end
									end
								end
								local R = 1.0
								if Peds[k].Paths[Peds[k].ActualPath].Action ~= nil then
									R = 1.0
								end
								if not HasSet then
									if ENTITY.IS_ENTITY_AT_COORD(Peds[k].Handle, Peds[k].TaskCoords.x, Peds[k].TaskCoords.y, Peds[k].TaskCoords.z, R, R, 1.0, false, false, 0) or
									ENTITY.IS_ENTITY_AT_COORD(Peds[k].Handle, Peds[k].TaskCoords2.x, Peds[k].TaskCoords2.y, Peds[k].TaskCoords2.z, 0.5, 0.5, 1.0, false, false, 0) then
										if Peds[k].Paths[Peds[k].ActualPath].Action ~= nil then
											if is_bit_set(Peds[k].Paths[Peds[k].ActualPath].Action, FlagBitNames.Jump) then
												--TASK.CLEAR_PED_TASKS(Peds[k].Handle)
												--TASK.CLEAR_PED_TASKS_IMMEDIATELY(Peds[k].Handle)
												ENTITY.SET_ENTITY_HEADING(Peds[k].Handle, Peds[k].Paths[Peds[k].ActualPath].Heading)
												--TASK.TASK_JUMP(Peds[k].Handle, false, false, false)
												TASK.TASK_CLIMB(Peds[k].Handle, false)
												--if PED.IS_PED_CLIMBING(Peds[k].Handle) or PED.IS_PED_JUMPING(Peds[k].Handle) then
												--if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_CLIMB")) ~= 7 then
													Peds[k].JumpDelay = 10
													Peds[k].TaskState = 5
												--end
												
											end
										else
											Peds[k].ActualPath = Peds[k].ActualPath + 1
											if Peds[k].ActualPath > #Peds[k].Paths then
												Peds[k].ActualPath = 1
												if Peds[k].SearchState == 2 then
													Peds[k].SearchState = 0
													Peds[k].SearchLowLevel = 1
												end
											end
											Peds[k].TaskState = 1
											Peds[k].SameDistanceTick = 0
										end
										
									end
								end
							else
								Peds[k].TaskState = 0
								Peds[k].Target = 0
							end
						end
						if Peds[k].TaskState == 4 then
							if not ENTITY.IS_ENTITY_DEAD(Peds[k].Target) and ENTITY.DOES_ENTITY_EXIST(Peds[k].Target) then
								if not ENTITY.IS_ENTITY_AT_ENTITY(Peds[k].Handle, Peds[k].Target, 2.5, 2.5, 2.5, false, true, 0) then
									if RequestControlOfEntity(Peds[k].Handle) then
										PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
										TASK.CLEAR_PED_TASKS(Peds[k].Handle)
										Peds[k].TaskState = 1
										if Peds[k].SearchState == 2 then
											Peds[k].SearchState = 0
											Peds[k].SearchLowLevel = 1
										end
									end
								end
							else
								if RequestControlOfEntity(Peds[k].Handle) then
									PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
									TASK.CLEAR_PED_TASKS(Peds[k].Handle)
									Peds[k].TaskState = 0
									Peds[k].Target = 0
								end
							end
						end
						if Peds[k].TaskState == 5 then
							if not PED.IS_PED_CLIMBING(Peds[k].Handle) and not PED.IS_PED_JUMPING(Peds[k].Handle) then
								Peds[k].JumpDelay = Peds[k].JumpDelay - 1
								if Peds[k].JumpDelay <= 0 then
								--if TASK.GET_SCRIPT_TASK_STATUS(Peds[k].Handle, joaat("SCRIPT_TASK_CLIMB")) == 7 then
									Peds[k].ActualPath = Peds[k].ActualPath + 1
									if Peds[k].ActualPath > #Peds[k].Paths then
										Peds[k].ActualPath = 1
										if Peds[k].SearchState == 2 then
											Peds[k].SearchState = 0
											Peds[k].SearchLowLevel = 1
										end
									end
									Peds[k].TaskState = 1
									Peds[k].SameDistanceTick = 0
								end
							end
						end
						if Peds[k].TaskState == 6 then
							if not ENTITY.IS_ENTITY_DEAD(Peds[k].Target) and ENTITY.DOES_ENTITY_EXIST(Peds[k].Target) then
								if ENTITY.IS_ENTITY_AT_ENTITY(Peds[k].Handle, Peds[k].Target, 1.0, 1.0, 2.5, false, true, 0) or not CanIntersectEntity(Pos, ENTITY.GET_ENTITY_COORDS(Peds[k].Target, Peds[k].Paths, Peds[k].ActualPath)) then
									if RequestControlOfEntity(Peds[k].Handle) then
										PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
										TASK.CLEAR_PED_TASKS(Peds[k].Handle)
										Peds[k].TaskState = 1
										if Peds[k].SearchState == 2 then
											Peds[k].SearchState = 0
											Peds[k].SearchLowLevel = 1
										end
									end
								end
							else
								if RequestControlOfEntity(Peds[k].Handle) then
									PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(Peds[k].Handle, false)
									TASK.CLEAR_PED_TASKS(Peds[k].Handle)
									Peds[k].TaskState = 0
									Peds[k].Target = 0
								end
							end
						end
					else
						if ENTITY.DOES_ENTITY_EXIST(Peds[k].Handle) then
							if ENTITY.IS_ENTITY_DEAD(Peds[k].Handle) then
								if RequestControlOfEntity(Peds[k].Handle) then
									set_entity_as_no_longer_needed(Peds[k].Handle)
									HandlesT[Peds[k].Handle] = nil
									table.remove(Peds, k)
								end
							end
						else
							HandlesT[Peds[k].Handle] = nil
							table.remove(Peds, k)
						end
					end
				end
			end
			Wait()
		end
	end
end)

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