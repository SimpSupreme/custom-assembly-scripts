http.get("https://raw.githubusercontent.com/SimpSupreme/custom-assembly-scripts/refs/heads/main/NOT%20MY%20SCRIPTS/AssemblyOffsetsNoPrint.lua", function(v)
    loadstring(v)()
end)

local possibleLootAssets = {"Dresser", "Table", "Rolltop_Desk", "DrawerContainer", "SmoothieSpawner", "Toolshed_Small"}
local itemNames = {"Candle", "Bandage", "Lighter", "Battery", "Flashlight", "Smoothie", "SkeletonKey", "Vitamins", "Crucifix", "Shears"}
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
local eyesWarningToggle = ui.new_checkbox("Eyes Warning")
local sallyWarnToggle = ui.new_checkbox("Sally Warning")
local screechWarnToggle = ui.new_checkbox("Screech Warning")
local snareWarningToggle = ui.new_checkbox("Snare Warning/Highlight")
local nextRoomToggle = ui.new_checkbox("Display Next Room")
local fakeDoorWarnToggle = ui.new_checkbox("Dupe Door Warning")

local spacer2 = ui.label("")

local highlightLabel = ui.label("Highlights")
local gateLeverHighlightToggle = ui.new_checkbox("Gate Lever Highlight")
local keyHighlightToggle = ui.new_checkbox("Key Highlight")
local goldHighlightToggle = ui.new_checkbox("Gold Highlight")
local itemHighlightToggle = ui.new_checkbox("Item Highlight")
local libraryPaperHighlightToggle = ui.new_checkbox("Highlight Library Hint Paper")
local libraryBooksHighlightToggle = ui.new_checkbox("Highlight Library Books")
local doorHundredBreakerToggle = ui.new_checkbox("Door 100 Breaker Highlight")
local doorHundredKeyToggle = ui.new_checkbox("Door 100 Key Highlight")

local updateInterval = 1
local nextRoomCache = 0
local fakeDoorCache = {}
local gateLeverPosCache = Vector3(0, 0, 0)
local libraryPaperPos = 0
local libraryBooksCache = {}
local keyCache = {}
local goldCache = {}
local itemPosCache = {}
local itemNameCache = {}
local snareCache = {}
local breakerCache = {}
local electricalKeyCache = {}
local libraryPaperPos = 0
local nextRoomUpdate = 0
local fakeDoorUpdate = 0
local gateLeverUpdate = 0
local keyUpdate = 0
local libraryPaperUpdate = 0
local libraryBooksUpdate = 0
local goldUpdate = 0
local itemUpdate = 0
local snareUpdate = 0
local breakerUpdate = 0
local electricalKeyUpdate = 0


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
    gateLeverPosCache = Vector3(0, 0, 0)

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

local function doorFiftyHintCacher()
    libraryPaperPos = 0
    local rooms = roomsFolder:Children()
    if not rooms then return end
    if rooms[#rooms - 1]:Name() ~= "50" then return end

    local encounterRoom = roomsFolder:FindChild("50")
    if not encounterRoom then return end
    local libraryPaperModel = encounterRoom:FindChild("LibraryHintPaper")
    if not libraryPaperModel then return end
    local libraryPaperHandle = libraryPaperModel:FindChild("Handle")
    if not libraryPaperHandle then return end
    local handlePrim = libraryPaperHandle:Primitive()
    if not handlePrim then return end
    local handlePos = handlePrim:GetPartPosition()
    if not handlePos then return end
    libraryPaperPos = handlePos
end

local function libraryBooksCacheUpdate()
    libraryBooksCache = {}
    local rooms = roomsFolder:Children()
    if not rooms then return end
    if rooms[#rooms - 1]:Name() ~= "50" then return end

    local encounterRoom = roomsFolder:FindChild("50")
    if not encounterRoom then return end
    local assetsFolder = encounterRoom:FindChild("Assets")
    if not assetsFolder then return end
    local bookshelvesFolder = assetsFolder:FindChild("Bookshelves1")
    if not bookshelvesFolder then return end
    for _, bookshelf in ipairs(bookshelvesFolder:Children()) do
        if bookshelf:FindChild("HintBook") then
            local book = bookshelf:FindChild("HintBook")
            if not book then return end
            local bookPrim = book:Primitive()
            if not bookPrim then return end
            local bookPos = bookPrim:GetPartPosition()
            if not bookPos then return end
            table.insert(libraryBooksCache, bookPos)
        end
    end
end

local function snareCacheUpdate()
    snareCache = {}

    local rooms = roomsFolder:Children()
    if not rooms then return end
    local curRoom = rooms[#rooms - 1]
    if not curRoom then return end
    local assetsFolder = curRoom:FindChild("Assets")
    if not assetsFolder then return end
    for _, snare in ipairs(assetsFolder:Children()) do
        if snare:Name() == "Snare" then
            local snareVoid = snare:FindChild("Void")
            if not snareVoid then return end
            local voidPrim = snareVoid:Primitive()
            if not voidPrim then return end
            local voidPos = voidPrim:GetPartPosition()
            if not voidPos then return end
            table.insert(snareCache, voidPos)
        end
    end
end

local function doorHundredCacheUpdate()
    breakerCache = {}

    local curRoom = roomsFolder:FindChild("100")
    if not curRoom then return end
    for _, breaker in ipairs(curRoom:Children()) do
        if breaker:Name() == "LiveBreakerPolePickup" then
            local breakerBase = breaker:FindChild("Base")
            if not breakerBase then return end
            local basePrim = breakerBase:Primitive()
            if not basePrim then return end
            local basePos = basePrim:GetPartPosition()
            if not basePos then return end
            table.insert(breakerCache, basePos)
        end
    end
end

local function doorHundredKeyCacher()
    local curRoom = roomsFolder:FindChild("100")
    if not curRoom then return end
    local assetsFolder = curRoom:FindChild("Assets")
    if not assetsFolder then return end
    for _, key in ipairs(assetsFolder:Children()) do
        if key:Name() == "ElectricalKeyObtain" then
            local hitbox1 = key:FindChild("Hitbox")
            if not hitbox1 then print("Hitbox 1 not found") return end
            local hitbox2 = hitbox1:FindChild("Key")
            if not hitbox2 then print("key hitbox not found") return end
            local hitbox2Prim = hitbox2:Primitive()
            if not hitbox2Prim then return end
            local hitbox2Pos = hitbox2Prim:GetPartPosition()
            if not hitbox2Pos then return end
            table.insert(electricalKeyCache, hitbox2Pos)
        end
    end
end

local lootLocationSet = {}
for _, name in pairs(possibleLootAssets) do
    lootLocationSet[name] = true
end

local function keyCacheUpdate()
    keyCache = {}

    local rooms = roomsFolder:Children()
    if not rooms then print("nothing in rooms folder") return end
    local curRoom = rooms[#rooms - 1]
    if not curRoom then print("current Room not found") return end
    local assetsFolder = curRoom:FindChild("Assets")
    if not assetsFolder then print("assets folder not found") return end
    local keyModel = nil
    if assetsFolder:FindChild("KeyObtain") then
        keyModel = assetsFolder:FindChild("KeyObtain")
    elseif not assetsFolder:FindChild("KeyObtain") then
        local assets = assetsFolder:Children()
        if not assets then print("nothing found in assets folder") return end
        for _, child in ipairs(assets) do
            if child:ClassName() == "Folder" and child:Name() == "Alternate" then
                local keysFolder = child:FindChild("Keys")
                if keysFolder then
                    local keysChildren = keysFolder:Children()
                    if keysChildren then
                        for _, folders in ipairs(keysChildren) do
                            if folders:FindChild("KeyObtain") then
                                keyModel = folders:FindChild("KeyObtain")
                            end
                        end
                    end
                end
            elseif lootLocationSet[child:Name()] then
                if child:FindChild("KeyObtain") then
                    if child:FindChild("KeyObtain") then
                        keyModel = child:FindChild("KeyObtain")
                    end
                elseif child:FindChild("DrawerContainer") then
                    for _, drawers in ipairs(child:Children()) do
                        if drawers:FindChild("KeyObtain") then
                            keyModel = drawers:FindChild("KeyObtain")
                        end
                    end
                end
            end
        end
    end
    if keyModel ~= nil then
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

local function goldCacheUpdate()
    goldCache = {}

    local rooms = roomsFolder:Children()
    if not rooms then return end
    local curRoom = rooms[#rooms - 1]
    if not curRoom then return end
    local assetsFolder = curRoom:FindChild("Assets")
    if not assetsFolder then return end
    local goldPileModel = nil
    for _, item in ipairs(assetsFolder:Children()) do
        if lootLocationSet[item:Name()] then
            if item:FindChild("GoldPile") then
                local goldPile = item:FindChild("GoldPile")
                if not goldPile then return end
                local goldHitbox = goldPile:FindChild("Hitbox")
                if not goldHitbox then return end
                local hitboxPrim = goldHitbox:Primitive()
                if not hitboxPrim then return end
                local hitboxPos = hitboxPrim:GetPartPosition()
                if not hitboxPos then return end
                table.insert(goldCache, hitboxPos)
            end
        end
    end
    for _, sideRoom in ipairs(curRoom:Children()) do
        if sideRoom:ClassName() == "Model" and sideRoom:Name() == "Sideroom" then
            local sideAssetsFolder = sideRoom:FindChild("Assets")
            if not sideAssetsFolder then return end
            for _, spawn in ipairs(sideAssetsFolder:Children()) do
                if lootLocationSet[spawn:Name()] then
                    if spawn:FindChild("GoldPile") then
                        local goldPile = spawn:FindChild("GoldPile")
                        if not goldPile then return end
                        local goldHitbox = goldPile:FindChild("Hitbox")
                        if not goldHitbox then return end
                        local hitboxPrim = goldHitbox:Primitive()
                        if not hitboxPrim then return end
                        local hitboxPos = hitboxPrim:GetPartPosition()
                        if not hitboxPos then return end
                        table.insert(goldCache, hitboxPos)
                    end
                end
            end
        end
    end
end

local itemNameSet = {}
for _, name in pairs(itemNames) do
    itemNameSet[name] = true
end

local function itemCacheUpdate()
    itemPosCache = {}
    itemNameCache = {}

    local rooms = roomsFolder:Children()
    if not rooms then return end
    local curRoom = rooms[#rooms - 1]
    if not curRoom then return end
    local assetsFolder = curRoom:FindChild("Assets")
    for _, item in ipairs(assetsFolder:Children()) do
        if lootLocationSet[item:Name()] then
            if item:FindChildByClass("Model") then
                local spawnedItem = item:FindChildByClass("Model")
                if not spawnedItem then return end
                if itemNameSet[spawnedItem:Name()] then
                    local itemMain = spawnedItem:FindChild("Main")
                    if not itemMain then return end
                    local mainPrim = itemMain:Primitive()
                    if not mainPrim then return end
                    local mainPos = mainPrim:GetPartPosition()
                    if not mainPos then return end
                    table.insert(itemPosCache, mainPos)
                    table.insert(itemNameCache, spawnedItem:Name())
                end
            end
        end
    end
    for _, sideRoom in ipairs(curRoom:Children()) do
        if sideRoom:ClassName() == "Model" and sideRoom:Name() == "Sideroom" then
            local sideAssetsFolder = sideRoom:FindChild("Assets")
            if not sideAssetsFolder then return end
            for _, spawn in ipairs(sideAssetsFolder:Children()) do
                if lootLocationSet[spawn:Name()] then
                    if spawn:FindChildByClass("Model") then
                        local spawnedItem = spawn:FindChildByClass("Model")
                        if not spawnedItem then return end
                        if itemNameSet[spawnedItem:Name()] then
                            local itemMain = spawnedItem:FindChild("Main")
                            if not itemMain then return end
                            local mainPrim = itemMain:Primitive()
                            if not mainPrim then return end
                            local mainPos = mainPrim:GetPartPosition()
                            if not mainPos then return end
                            table.insert(itemPosCache, mainPos)
                            table.insert(itemNameCache, spawnedItem:Name())
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

    render.text(40, (screenSize.y - 80), "Next Room: "..nextRoomCache, 255, 255, 255, 255, "", 0)
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
    if gateLeverPosCache.x > 0 or gateLeverPosCache.y > 0 or gateLeverPosCache.z > 0 then
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

local function goldHighlight()
    local now = globals.curtime()

    if now - goldUpdate >= updateInterval then
        goldCacheUpdate()
        goldUpdate = now
    end

    if not globals.is_focused() then return end

    for _, worldPos in pairs(goldCache) do
        local screenPos = utils.world_to_screen(worldPos)
        if screenPos.x > 0 then
            if renderDistanceSlider:get() == 0 then
                render.text(screenPos.x, screenPos.y, "Gold", 218, 165, 32, 255, "", 0)
            elseif renderDistanceSlider:get() > 0 then
                if Distance(playerPosition(), worldPos) <= renderDistanceSlider:get() then
                    render.text(screenPos.x, screenPos.y, "Gold", 218, 165, 32, 255, "", 0)
                end
            end
        end
    end
end

local function highlightItems()
    local now = globals.curtime()

    if now - itemUpdate >= updateInterval then
        itemCacheUpdate()
        itemUpdate = now
    end

    if not globals.is_focused() then return end

    for i = 1, #itemPosCache do
        local worldPos = itemPosCache[i]
        local screenPos = utils.world_to_screen(worldPos)
        if screenPos.x > 0 then
            local itemName = itemNameCache[i]
            if renderDistanceSlider:get() == 0 then
                render.text(screenPos.x, screenPos.y, itemName, 0, 255, 0, 255, "", 0)
            elseif renderDistanceSlider:get() > 0 then
                if Distance(playerPosition(), worldPos) <= renderDistanceSlider:get() then
                    render.text(screenPos.x, screenPos.y, itemName, 0, 255, 0, 255, "", 0)
                end
            end
        end
    end
end

local function breakerHighlight()
    local now = globals.curtime()

    if now - breakerUpdate >= updateInterval then
        doorHundredCacheUpdate()
        breakerUpdate = now
    end

    if not globals.is_focused() then return end

    for _, worldPos in pairs(breakerCache) do
        local screenPos = utils.world_to_screen(worldPos)
        if screenPos.x > 0 then
            if renderDistanceSlider:get() == 0 then
                render.text(screenPos.x, screenPos.y, "Breaker", 255, 255, 255, 255, "", 0)
            elseif renderDistanceSlider:get() > 0 then
                if Distance(playerPosition(), worldPos) <= renderDistanceSlider:get() then
                    render.text(screenPos.x, screenPos.y, "Breaker", 255, 255, 255, 255, "", 0)
                end
            end
        end
    end
end

local function electricalKeyHighlight()
    local now = globals.curtime()

    if now - electricalKeyUpdate >= updateInterval then
        doorHundredKeyCacher()
        electricalKeyUpdate = now
    end

    if not globals.is_focused() then return end

    for _, worldPos in pairs(electricalKeyCache) do
        local screenPos = utils.world_to_screen(worldPos)
        if screenPos.x > 0 then
            if renderDistanceSlider:get() == 0 then
                render.text(screenPos.x, screenPos.y, "Electrical Key", 0, 255, 255, 255, "", 0)
            elseif renderDistanceSlider:get() > 0 then
                if Distance(playerPosition(), worldPos) <= renderDistanceSlider:get() then
                    render.text(screenPos.x, screenPos.y, "Electrical Key", 0, 255, 255, 255, "", 0)
                end
            end
        end
    end
end

local function doorFiftyHintHighlight()
    local now = globals.curtime()

    if now - libraryPaperUpdate >= updateInterval then
        doorFiftyHintCacher()
        libraryPaperUpdate = now
    end

    if not globals.is_focused() then return end
    
    if libraryPaperPos then
        local screenPos = utils.world_to_screen(libraryPaperPos)
        if screenPos.x > 0 then
            if renderDistanceSlider:get() == 0 then
                render.text(screenPos.x, screenPos.y, "Hint Paper", 255, 255, 255, 255, "", 0)
            elseif renderDistanceSlider:get() > 0 then
                if Distance(playerPosition(), worldPos) <= renderDistanceSlider:get() then
                    render.text(screenPos.x, screenPos.y, "Hint Paper", 255, 255, 255, 255, "", 0)
                end
            end
        end
    end
end

local function doorFiftyBooksHighlight()
    local now = globals.curtime()

    if now - libraryBooksUpdate >= updateInterval then
        libraryBooksCacheUpdate()
        libraryBooksUpdate = now
    end

    if not globals.is_focused() then return end

    for _, worldPos in pairs(libraryBooksCache) do
        local screenPos = utils.world_to_screen(worldPos)
        if screenPos.x > 0 then
            if renderDistanceSlider:get() == 0 then
                render.text(screenPos.x, screenPos.y, "Book", 0, 255, 255, 255, "", 0)
            elseif renderDistanceSlider:get() > 0 then  
                if Distance(playerPosition(), worldPos) <= renderDistanceSlider:get() then
                    render.text(screenPos.x, screenPos.y, "Book", 0, 255, 255, 255, "", 0)
                end
            end
        end
    end
end

local function snareHighlight()
    local now = globals.curtime()

    if now - snareUpdate >= updateInterval then
        snareCacheUpdate()
        snareUpdate = now
    end

    if not globals.is_focused() then return end

    for _, worldPos in pairs(snareCache) do
        local screenPos = utils.world_to_screen(worldPos)
        if screenPos.x > 0 then
            if renderDistanceSlider:get() == 0 then
                render.text(screenPos.x, screenPos.y, "Snare", 255, 255, 255, 255, "", 0)
            elseif renderDistanceSlider:get() > 0 then
                if Distance(playerPosition(), worldPos) <= renderDistanceSlider:get() then
                    render.text(screenPos.x, screenPos.y, "Snare", 255, 255, 255, 255, "", 0)
                end
            end
        end
    end
end

local function rushWarn()
    if not globals.is_focused() then return end
    if workspace:FindChild("RushMoving") then
        render.text((screenSize.x/2 - 40), (screenSize.y - 185), "Rush", 255, 255, 0, 255, "", rushFont)
    elseif workspace:FindChild("AmbushMoving") then
        render.text((screenSize.x/2 - 40), (screenSize.y - 185), "Ambush", 255, 255, 0, 255, "", rushFont)
    end
end

local function eyesWarn()
    if not globals.is_focused() then return end
    if workspace:FindChild("Eyes") then
        render.text((screenSize.x/2 - 40), (screenSize.y - 220), "Eyes", 255, 255, 255, 255, "", rushFont)
    end
end

local function sallyWarn()
    if not globals.is_focused() then return end
    if workspace:FindChild("Sally") or workspace:FindChild("SallyWindow") then
        render.text((screenSize.x/2 - 40), (screenSize.y - 255), "Sally", 255, 0, 255, 255, "", rushFont)
    end
end

local function screechWarn()
    local camera = workspace:FindChild("Camera")
    if not camera then return end
    if camera:FindChild("Screech") then
        render.text((screenSize.x/2 - 40), (screenSize.y - 290), "Screech", 225, 90, 90, 255, "", rushFont)
    end
end

cheat.set_callback("paint", function()
    if rushWarnToggle:get() then
        rushWarn()
    end

    if eyesWarningToggle:get() then
        eyesWarn()
    end

    if sallyWarnToggle:get() then
        sallyWarn()
    end

    if screechWarnToggle:get() then
        screechWarn()
    end

    if snareWarningToggle:get() then
        snareHighlight()
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

    if goldHighlightToggle:get() then
        goldHighlight()
    end

    if itemHighlightToggle:get() then
        highlightItems()
    end

    if libraryPaperHighlightToggle:get() then
        doorFiftyHintHighlight()
    end

    if libraryBooksHighlightToggle:get() then
        doorFiftyBooksHighlight()
    end

    if doorHundredBreakerToggle:get() then
        breakerHighlight()
    end

    if doorHundredKeyToggle:get() then
        electricalKeyHighlight()
    end
end)
