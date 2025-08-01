--[[
    workspace
        CurrentRooms
            #
                Assets
                    Table
                        GoldPile
                            #
                                GoldVisualHolder
                                    Part

]]

local moneyNames = {"GoldPile"}
local itemNames = {"Candle", "Bandage", "Lighter", "Battery"}
local keyNames = {"KeyObtain"}
local fakeDoorNames = {"DupeDoor"}
local nodeMonsters = {"RushMoving"}
local workspace = globals.workspace()
if not workspace then return end
local roomsFolder = workspace:FindChild("CurrentRooms")
if not roomsFolder then return end
local screenSize = render.screen_size()
local rushFont = render.create_font("C:\\Windows\\Fonts\\Verdana.ttf", 33, "ab")

local warningsLabel = ui.label("Warnings")
local rushWarnToggle = ui.new_checkbox("Rush Warning")
local nextRoomToggle = ui.new_checkbox("Display Next Room")
local fakeDoorWarnToggle = ui.new_checkbox("Dupe Door Warning")

local spacer = ui.label("")

local highlightLabel = ui.label("Highlights")
local gateLeverHighlightToggle = ui.new_checkbox("Gate Lever Highlight")

local function nextRoom()
    if not globals.is_focused() then return end
    local rooms = roomsFolder:Children()
    if not rooms then return end
    local nextRoom = rooms[#rooms]
    if not nextRoom then return end
    local nextRoomName = nextRoom:Name()
    if not nextRoomName then return end

    render.text(40, 40, "Next Room: "..nextRoomName, 255, 255, 255, 255, "", 0)
end

local function fakeDoorCheck()
    if not globals.is_focused() then return end
    local rooms = roomsFolder:Children()
    if not rooms then return end
    local curRoom = rooms[#rooms - 1]
    if not curRoom then return end
    local curRoomChildren = curRoom:Children()
    for _, child in ipairs(curRoomChildren) do
        if child:ClassName() == "MeshPart" and child:Name() == "dupeDoor" then
            local dupePrim = child:Primitive()
            if not dupePrim then return end
            local dupePos = dupePrim:GetPartPosition()
            if not dupePos then return end
            local dupeScreenPos = utils.world_to_screen(dupePos)
            if not dupeScreenPos then return end
            if dupeScreenPos.x ~= 0 then
                render.text(dupeScreenPos.x, dupeScreenPos.y, "Dupe Door", 255, 0, 0, 255, "", 0)
            end
        end
    end
end

local function GateLeverHighlight()
    if not globals.is_focused() then return end
    local rooms = roomsFolder:Children()
    if not rooms then return end
    local curRoom = rooms[#rooms - 1]
    if not curRoom then return end
    local assetsFolder = curRoom:FindChild("Assets")
    if not assetsFolder then return end
    local switchModel = assetsFolder:FindChild("LeverForGate")
    if not switchModel then return end
    local switchMain = switchModel:FindChild("Main")
    if not switchMain then return end
    local mainPrim = switchMain:Primitive()
    if not mainPrim then return end
    local mainPos = mainPrim:GetPartPosition()
    if not mainPos then return end
    local mainScreenPos = utils.world_to_screen(mainPos)
    if not mainScreenPos then return end
    
    if mainScreenPos.x > 0 then
        render.text(mainScreenPos.x, mainScreenPos.y, "Door Lever", 255, 255, 255, 255, "", 0)
    end
end

local function rushWarn()
    if not globals.is_focused() then return end
    if workspace:FindChild("RushMoving") then
        render.text((screenSize.x/2 - 50), (screenSize.y - 175), "Rush", 255, 255, 0, 255, "", rushFont)
    end
end

cheat.set_callback("paint", function()
    if rushWarnToggle:get() then
        rushWarn()
    end

    if nextRoomToggle:get() then
        nextRoom()
    end

    if fakeDoorWarnToggle:get() then
        fakeDoorCheck()
    end

    if gateLeverHighlightToggle:get() then
        GateLeverHighlight()
    end
end)
