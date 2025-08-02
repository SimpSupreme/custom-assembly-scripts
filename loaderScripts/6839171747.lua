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

local function playerPosition()
    local lp = entity.localplayer()
    if not lp then return end
    local hrp = lp:GetBone("HRP")
    if not hrp then return end
    local hrpp = hrp:Primitive()
    if not hrpp then return end
    local pos = hrpp:GetPartPosition()
    if not pos then return end

    return pos
end

local function Distance(player_pos, enemy_pos)
    if not player_pos or not enemy_pos then return nil end
    if not player_pos.z or not enemy_pos.z then return nil end

    
    local distanceX = player_pos.x - enemy_pos.x
    local distanceY = player_pos.y - enemy_pos.y
    local distanceZ = player_pos.z - enemy_pos.z
    local distance = math.sqrt(distanceX * distanceX + distanceY * distanceY + distanceZ * distanceZ)
    return distance
end

local renderDistanceSlider = ui.slider_int("Render Distance (0 for inf)", 0, 0, 1000, "%d")

local spacer = ui.label("")

local warningsLabel = ui.label("Warnings")
local rushWarnToggle = ui.new_checkbox("Rush Warning")
local nextRoomToggle = ui.new_checkbox("Display Next Room")
local fakeDoorWarnToggle = ui.new_checkbox("Dupe Door Warning")

local spacer2 = ui.label("")

local highlightLabel = ui.label("Highlights")
local gateLeverHighlightToggle = ui.new_checkbox("Gate Lever Highlight")
local keyHighlightToggle = ui.new_checkbox("Key Highlight")

local updateInterval = 1
local nextRoomCache = 0
local fakeDoorCache = {}
local gateLeverPosCache = 0
local keyCache = {}
local nextRoomUpdate = 0
local fakeDoorUpdate = 0
local gateLeverUpdate = 0
local keyUpdate = 0

local function nextRoomCacheUpdate()
    local rooms = roomsFolder:Children()
    if not rooms then return end
    local nextRoom = rooms[#rooms]
    if not nextRoom then return end
    nextRoomCache = nextRoom:Name()
end

local function fakeDoorCacheUpdate()
    fakeDoorCache = {}

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
            table.insert(fakeDoorCache, dupePos)
        end
    end
end

local function gateLeverCacheUpdate()
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
    gateLeverPosCache = mainPos
end

local function keyCacheUpdate()
    keyCache = {}

    local rooms = roomsFolder:Children()
    if not rooms then print("nothing in rooms folder") return end
    local curRoom = rooms[#rooms - 1]
    if not curRoom then print("current Room not found") return end
    local assetsFolder = curRoom:FindChild("Assets")
    if not assetsFolder then print("assets folder not found") return end
    if assetsFolder:FindChild("KeyObtain") then
        local keyModel = assetsFolder:FindChild("KeyObtain")
        if not keyModel then return end
        local hitbox1 = keyModel:FindChild("Hitbox")
        if not hitbox1 then print("Hitbox 1 not found") return end
        local hitbox2 = hitbox1:FindChild("KeyHitbox")
        if not hitbox2 then print("key hitbox not found") return end
        local hitbox2Prim = hitbox2:Primitive()
        if not hitbox2Prim then return end
        local hitbox2Pos = hitbox2Prim:GetPartPosition()
        if not hitbox2Pos then return end
        table.insert(keyCache, hitbox2Pos)
    elseif not assets:FindChild("KeyObtain") then
        local assets = assetsFolder:Children()
        if not assets then print("nothing found in assets folder") return end
        for _, child in ipairs(assets) do
            if child:ClassName() == "Folder" and child:Name() == "Alternate" then
                local keysFolder = child:FindChild("Keys")
                if keysFolder then
                    local keysChildren = keysFolder:Children()
                    if keysChildren then
                        for _, folders in ipairs(keysChildren) do
                            local keyModel = folders:FindChild("KeyObtain")
                            if keyModel then
                                local hitbox1 = keyModel:FindChild("Hitbox")
                                if not hitbox1 then print("Hitbox 1 not found") return end
                                local hitbox2 = hitbox1:FindChild("KeyHitbox")
                                if not hitbox2 then print("key hitbox not found") return end
                                local hitbox2Prim = hitbox2:Primitive()
                                if not hitbox2Prim then return end
                                local hitbox2Pos = hitbox2Prim:GetPartPosition()
                                if not hitbox2Pos then return end
                                table.insert(keyCache, hitbox2Pos)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function nextRoom()
    local now = globals.curtime()

    if now - nextRoomUpdate >= updateInterval then
        nextRoomCacheUpdate()
        nextRoomUpdate = now
    end

    if not globals.is_focused() then return end

    render.text(40, 40, "Next Room: "..nextRoomCache, 255, 255, 255, 255, "", 0)
end

local function fakeDoorCheck()
    local now = globals.curtime()

    if now - fakeDoorUpdate >= updateInterval then
        fakeDoorCacheUpdate()
        fakeDoorUpdate = now
    end

    if not globals.is_focused() then return end

    for _, worldPos in pairs(fakeDoorCache) do
        local screenPos = utils.world_to_screen(worldPos)
        if screenPos.x > 0 then
            if renderDistanceSlider:get() == 0 then
                render.text(screenPos.x, screenPos.y, "Dupe Door", 255, 0, 0, 255, "", 0)
            elseif renderDistanceSlider:get() > 0 then
                if Distance(playerPosition(), worldPos) <= renderDistanceSlider:get() then
                    render.text(screenPos.x, screenPos.y, "Dupe Door", 255, 0, 0, 255, "", 0)
                end
            end
        end
    end
end

local function GateLeverHighlight()
    local now = globals.curtime()

    if now - gateLeverUpdate >= updateInterval then
        gateLeverCacheUpdate()
        gateLeverUpdate = now
    end

    if not globals.is_focused() then return end

    local screenPos = utils.world_to_screen(gateLeverPosCache)
    if screenPos.x > 0 then
        if renderDistanceSlider:get() == 0 then
            render.text(screenPos.x, screenPos.y, "Gate Lever", 255, 255, 255, 255, "", 0)
        elseif renderDistanceSlider:get() > 0 then
            if Distance(playerPosition(), worldPos) <= renderDistanceSlider:get() then
                render.text(screenPos.x, screenPos.y, "Gate Lever", 255, 255, 255, 255, "", 0)
            end
        end
    end
end

local function keyHighlight()
    local now = globals.curtime()

    if now - keyUpdate >= updateInterval then
        keyCacheUpdate()
        keyUpdate = now
    end

    if not globals.is_focused() then return end

    for _, worldPos in pairs(keyCache) do
        local screenPos = utils.world_to_screen(worldPos)
        if screenPos.x > 0 then
            if renderDistanceSlider:get() == 0 then
                render.text(screenPos.x, screenPos.y, "Key", 0, 255, 255, 255, "", 0)
            elseif renderDistanceSlider:get() > 0 then
                if Distance(playerPosition(), worldPos) <= renderDistanceSlider:get() then
                    render.text(screenPos.x, screenPos.y, "Key", 0, 255, 255, 255, "", 0)
                end
            end
        end
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

    if keyHighlightToggle:get() then
        keyHighlight()
    end
end)
