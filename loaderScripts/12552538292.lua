http.get("https://raw.githubusercontent.com/SimpSupreme/custom-assembly-scripts/refs/heads/main/scripts/AssemblyOffsetsNoPrint.lua", function(v)
    loadstring(v)()
end)

local datamodel = globals.data_model()
local players = datamodel:FindChild("Players")
local workspace = globals.workspace()
local screenSize = render.screen_size()
local gameplayFolder = workspace:FindChild("GameplayFolder")
local roomsFolder = gameplayFolder:FindChild("Rooms")
local anglerFont = render.create_font("C:\\Windows\\Fonts\\Verdana.ttf", 33, "ab")
local majorFileNames = {"AbstractDocument", "LunarDockDocument", "ThePainterDocument", "StanDocument", "MindscapeDocument", "AnalogChristmasDocument", "LetVandZoneDocument", "DiVineDocument", "RidgeDocument"} -- currently unused, still finding them
local fakeDoorNames = {"ServerTrickster", "TricksterRoom", "OutskirtsTrickster"}
local itemNames = {"RoomsBattery", "DefaultBattery1", "DefaultBattery2", "DefaultBattery3", "AltBattery1", "AltBattery2", "AltBattery3", "FlashLight", "Flashlight", "WindupLight", "Blacklight", "Gummylight", "Lantern", "SmallLantern", "BigFlashBeacon", "FlashBeacon", "Book", "Medkit", "CrateMedkit", "HealthBoost", "CrateHealthBoost", "Defib", "CrateDefib", "SPRINT", "DoubleSprint", "CodeBreacher", "CrateCodeBreacher", "ToyRemote", "BlueToyRemote"}
local itemNamesNoLights = {"RoomsBattery", "DefaultBattery1", "DefaultBattery2", "DefaultBattery3", "AltBattery1", "AltBattery2", "AltBattery3", "Medkit", "CrateMedkit", "HealthBoost", "CrateHealthBoost", "Defib", "CrateDefib", "SPRINT", "DoubleSprint", "CodeBreacher", "CrateCodeBreacher", "ToyRemote", "BlueToyRemote"}
local keycardNames = {"NormalKeyCard", "PasswordPaper", "InnerKeyCard", "RidgeKeyCard"}
local anglerVariants = {"Angler", "Blitz", "Froger", "Pinkie", "Chainsmoker", "Pandemonium", "RidgeAngler", "RidgeFroger", "RidgeBlitz", "RidgePinkie", "RidgeChainsmoker", "A60", "Mirage"}
local currencyNames = {"Blueprint", "Relic"}

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

local warningsLabel = ui.label("Warnings")
local anglerWarnToggle = ui.new_checkbox("Angler Warning")
local anglerDistanceToggle = ui.new_checkbox("Angler Distance")
local wallDwellerWarnToggle = ui.new_checkbox("Wall Dweller Warning")
local wallDwellerDistanceToggle = ui.new_checkbox("Wall Dweller Distance")
local fakeDoorWarnToggle = ui.new_checkbox("Fake Door Warning")
local voidLockerWarnToggle = ui.new_checkbox("Void Locker Warning")

local spacer = ui.label("")

local highlightsLabel = ui.label("ESP/Highlights")
local renderDistanceSlider = ui.slider_int("Render Distance (0 for inf range)", 0000, 0, 1000, "%d")
local moneyESPToggle = ui.new_checkbox("Money ESP")
local itemESPToggle = ui.new_checkbox("Item ESP")
local keycardESPToggle = ui.new_checkbox("Keycard/Password ESP")
local generatorESPToggle = ui.new_checkbox("Searchlight GE Generator ESP")
local generatorESPToggle2 = ui.new_checkbox("Ending Searchlight Generator ESP")

local spacer2 = ui.label("")

local helpersLabel = ui.label("Challenge Helpers")
local WDITDToggle = ui.new_checkbox("We Die In The Dark")
local CarefulToggle = ui.new_checkbox("Extra Careful")

-- has to have multiple update timers, only money updates if it's all one. womp womp.
local lastCurrencyUpdate = 0
local lastItemUpdate = 0
local lastKeycardUpdate = 0
local monsterLockerUpdate = 0
local fakeDoorUpdate = 0
local generatorUpdate = 0
local generatorUpdate2 = 0
local currencyCache = {}
local itemPosCache = {}
local itemNameCache = {}
local keycardCache = {}
local monsterLockerCache = {}
local fakeDoorCache = {}
local generatorCache = {}
local generatorCache2 = {}
local updateInterval = 1

local currencyNameSet = {}
for _, name in pairs(currencyNames) do
    currencyNameSet[name] = true
end

local function updateCurrencyCache()
    currencyCache = {}

    for _, room in pairs(roomsFolder:Children()) do
        for _, model in pairs(room:Children()) do
            if model:ClassName() == "Model" then
                local spawnLocationsFolder = model:FindChild("SpawnLocations")
                if spawnLocationsFolder then
                    for _, spawn in pairs(spawnLocationsFolder:Children()) do
                        for _, spawned in pairs(spawn:Children()) do
                            if string.find(spawned:Name(), "^Currency") or currencyNameSet[spawned:Name()] then
                                local prim = spawn:Primitive()
                                if prim then
                                    local worldPos = prim:GetPartPosition()
                                    if worldPos then
                                        table.insert(currencyCache, worldPos)
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

local keycardNameSet = {}
for _, name in pairs(keycardNames) do
    keycardNameSet[name] = true
end

local function updateKeycardCache()
    keycardCache = {}

    for _, room in pairs(roomsFolder:Children()) do
        for _, model in pairs(room:Children()) do
            if model:ClassName() == "Model" then
                local spawnLocationsFolder = model:FindChild("SpawnLocations")
                if spawnLocationsFolder then
                    for _, spawn in pairs(spawnLocationsFolder:Children()) do
                        local spawned = spawn:FindChildByClass("Model")
                        if spawned then
                            if keycardNameSet[spawned:Name()] then
                                local prim = spawn:Primitive()
                                if prim then
                                    local worldPos = prim:GetPartPosition()
                                    if worldPos then
                                        table.insert(keycardCache, worldPos)
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

local itemNameSet = {}
for _, name in pairs(itemNames) do
    itemNameSet[name] = true
end

local noLightsNameSet = {}
for _, name in pairs(itemNamesNoLights) do
    noLightsNameSet[name] = true
end

local itemDisplayNames = {
    -- Batteries
    ["RoomsBattery"] = "Battery",
    ["DefaultBattery1"] = "Battery",
    ["DefaultBattery2"] = "Battery",
    ["DefaultBattery3"] = "Battery",
    ["AltBattery1"] = "Battery",
    ["AltBattery2"] = "Battery",
    ["AltBattery3"] = "Battery",
    ["SmallLantern"] = "Lantern",
    ["BigFlashBeacon"] = "Flash Beacon",
    ["FlashBeacon"] = "Flash Beacon",
    ["CrateMedkit"] = "Medkit",
    ["HealthBoost"] = "Cocktail 'Perithesene'",
    ["CrateHealthBoost"] = "Cocktail 'Perithesene'",
    ["Defib"] = "Defibrillator",
    ["CrateDefib"] = "Defibrillator",
    ["DoubleSprint"] = "SPRINT x2",
    ["CrateCodeBreacher"] = "Code Breacher",
    ["CodeBreacher"] = "Code Breacher"
}

local function updateItemCache()
    itemNameCache = {}
    itemPosCache = {}

    for _, room in pairs(roomsFolder:Children()) do
        for _, model in pairs(room:Children()) do
            if model:ClassName() == "Model" then
                local spawnLocationsFolder = model:FindChild("SpawnLocations")
                if spawnLocationsFolder then
                    for _, spawn in pairs(spawnLocationsFolder:Children()) do
                        local spawnModel = spawn:FindChildByClass("Model")
                        if spawnModel then
                            if WDITDToggle:get() then
                                if noLightsNameSet[spawnModel:Name()] then
                                    local prim = spawn:Primitive()
                                    if prim then
                                        local worldPos = prim:GetPartPosition()
                                        if worldPos then
                                            table.insert(itemPosCache, worldPos)
                                            local rawName = spawnModel:Name()
                                            local displayName = itemDisplayNames[rawName] or rawName
                                            table.insert(itemNameCache, displayName)
                                        end
                                    end
                                end
                            elseif not WDITDToggle:get() then
                                if itemNameSet[spawnModel:Name()] then
                                    local prim = spawn:Primitive()
                                    if prim then
                                        local worldPos = prim:GetPartPosition()
                                        if worldPos then
                                            table.insert(itemPosCache, worldPos)
                                            local rawName = spawnModel:Name()
                                            local displayName = itemDisplayNames[rawName] or rawName
                                            table.insert(itemNameCache, displayName)
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

local function updateMonsterLockerCache()
    monsterLockerCache = {} 

    for _, room in pairs(roomsFolder:Children()) do
        for _, models in pairs(room:Children()) do
            if models:Name() == "MonsterLocker" then
                local collisionBox = models:FindChild("LockerCollision")
                if collisionBox then
                    local prim = collisionBox:Primitive()
                    if prim then
                        local worldPos = prim:GetPartPosition()
                        if worldPos then
                            table.insert(monsterLockerCache, worldPos)
                        end
                    end
                end
            end
        end
    end
end

local fakeDoorNameSet = {}
for _, name in pairs(fakeDoorNames) do
    fakeDoorNameSet[name] = true
end

local function updateFakeDoorCache()
    fakeDoorCache = {} -- Clear previous data

    for _, room in pairs(roomsFolder:Children()) do
        for _, models in pairs(room:Children()) do
            if fakeDoorNameSet[models:Name()] then
                local doorInteractables = models:FindChild("Interactables")
                if doorInteractables then
                    local tricksterModel = doorInteractables:FindChild("Trickster")
                    if tricksterModel then
                        local doorModel = tricksterModel:FindChild("TricksterDoor")
                        if doorModel then
                            local doorRoot = doorModel:FindChild("Root")
                            if doorRoot then
                                local doorRootPrim = doorRoot:Primitive()
                                if doorRootPrim then
                                    local doorRootPos = doorRootPrim:GetPartPosition()
                                    if doorRootPos then
                                        table.insert(fakeDoorCache, doorRootPos)
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

local function generatorBrokenCheck(generatorModel)
    local generatorFixedValue = generatorModel:FindChild("Fixed")
    if not generatorFixedValue then return end
    
    local fixedValueAddress = generatorFixedValue:Address()
    if not fixedValueAddress then return end
    
    local fixedIntValue = utils.read_memory("int", fixedValueAddress + Value)

    if fixedIntValue < 100 then
        return true
    elseif fixedIntValue >= 100 then
        return false
    end
end

local function updateMidGeneratorCache()
    generatorCache = {} -- Clear previous data

    local encounterRoom = roomsFolder:FindChild("SearchlightsEncounter")
    if encounterRoom then
        local encounterInteractables = encounterRoom:FindChild("Interactables")
        if encounterInteractables then
            for _, models in pairs(encounterInteractables:Children()) do
                local modelName = models:Name()
                if modelName == "Generator" and generatorBrokenCheck(models) then
                    local proxyPart = models:FindChild("ProxyPart")
                    if proxyPart then
                        local proxyPrim = proxyPart:Primitive()
                        if proxyPrim then
                            local proxyPos = proxyPrim:GetPartPosition()
                            if proxyPos then
                                table.insert(generatorCache, proxyPos)
                            end
                        end    
                    end
                end    
            end
        end
    end
end

local function updateEndGeneratorCache()
    generatorCache2 = {} -- Clear previous data

    local encounterRoom = roomsFolder:FindChild("SearchlightsEnding")
    if encounterRoom then
        local encounterInteractables = encounterRoom:FindChild("Interactables")
        if encounterInteractables then
            for _, models in pairs(encounterInteractables:Children()) do
                local modelName = models:Name()
                if modelName == "PresetGenerator" and generatorBrokenCheck(models) then
                    local proxyPart = models:FindChild("ProxyPart")
                    if proxyPart then
                        local proxyPrim = proxyPart:Primitive()
                        if proxyPrim then
                            local proxyPos = proxyPrim:GetPartPosition()
                            if proxyPos then
                                table.insert(generatorCache2, proxyPos)
                            end
                        end    
                    end
                end    
            end
        end
    end
end

local function highlightCurrency()
    local now = globals.curtime()

    if now - lastCurrencyUpdate >= updateInterval then
        updateCurrencyCache()
        lastCurrencyUpdate = now
    end

    if not globals.is_focused() then return end

    for _, worldPos in pairs(currencyCache) do
        local screenPos = utils.world_to_screen(worldPos)
        if screenPos.x > 0 then
            if renderDistanceSlider:get() == 0 then
                render.text(screenPos.x, screenPos.y, "Currency", 255, 255, 255, 255, "", 0)
            elseif renderDistanceSlider:get() > 0 then               
                if Distance(playerPosition(), worldPos) <= renderDistanceSlider:get() then
                    render.text(screenPos.x, screenPos.y, "Currency", 255, 255, 255, 255, "", 0)
                end
            end
        end
    end
end


local function highlightItems()
    local now = globals.curtime()

    if now - lastItemUpdate >= updateInterval then
        updateItemCache()
        lastItemUpdate = now
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

local function highlightKeycards()
    local now = globals.curtime()

    if now - lastKeycardUpdate >= updateInterval then
        updateKeycardCache()
        lastKeycardUpdate = now
    end

    if not globals.is_focused() then return end

    for _, worldPos in pairs(keycardCache) do
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

local function highlightMonsterLockers()
    local now = globals.curtime()

    if now - monsterLockerUpdate >= updateInterval then
        updateMonsterLockerCache()
        monsterLockerUpdate = now
    end

    if not globals.is_focused() then return end

    for _, worldPos in pairs(monsterLockerCache) do
        local screenPos = utils.world_to_screen(worldPos)
        if screenPos.x > 0 then
            if renderDistanceSlider:get() == 0 then
                render.text(screenPos.x, screenPos.y, "Void Locker", 255, 0, 255, 255, "", 0)
            elseif renderDistanceSlider:get() > 0 then
                if Distance(playerPosition(), worldPos) <= renderDistanceSlider:get() then
                    render.text(screenPos.x, screenPos.y, "Void Locker", 255, 0, 255, 255, "", 0)
                end
            end
        end
    end
end

local function highlightFakeDoors()
    local now = globals.curtime()

    if now - fakeDoorUpdate >= updateInterval then
        updateFakeDoorCache()
        fakeDoorUpdate = now
    end

    if not globals.is_focused() then return end

    for _, worldPos in pairs(fakeDoorCache) do
        local screenPos = utils.world_to_screen(worldPos)
        if screenPos.x > 0 then
            if renderDistanceSlider:get() == 0 then
                render.text(screenPos.x, screenPos.y, "Fake Door", 255, 0, 0, 255, "", 0)
            elseif renderDistanceSlider:get() > 0 then
                if Distance(playerPosition(), worldPos) <= renderDistanceSlider:get() then
                    render.text(screenPos.x, screenPos.y, "Fake Door", 255, 0, 0, 255, "", 0)
                end
            end
        end
    end
end

local function highlightMidGenerators()
    local now = globals.curtime()

    if now - generatorUpdate >= updateInterval then
        updateMidGeneratorCache()
        generatorUpdate = now
    end

    if not globals.is_focused() then return end

    for _, worldPos in pairs(generatorCache) do
        local screenPos = utils.world_to_screen(worldPos)
        if screenPos.x > 0 then
            if renderDistanceSlider:get() == 0 then
                render.text(screenPos.x, screenPos.y, "Broken Generator", 225, 90, 90, 255, "", 0)
            elseif renderDistanceSlider:get() > 0 then
                if Distance(playerPosition(), worldPos) <= renderDistanceSlider:get() then
                    render.text(screenPos.x, screenPos.y, "Broken Generator", 225, 90, 90, 255, "", 0)
                end
            end
        end
    end
end

local function highlightEndGenerators()
    local now = globals.curtime()

    if now - generatorUpdate2 >= updateInterval then
        updateEndGeneratorCache()
        generatorUpdate2 = now
    end

    if not globals.is_focused() then return end

    for _, worldPos in pairs(generatorCache2) do
        local screenPos = utils.world_to_screen(worldPos)
        if screenPos.x > 0 then
            if renderDistanceSlider:get() == 0 then
                render.text(screenPos.x, screenPos.y, "Broken Generator", 225, 90, 90, 255, "", 0)
            elseif renderDistanceSlider:get() > 0 then
                if Distance(playerPosition(), worldPos) <= renderDistanceSlider:get() then
                    render.text(screenPos.x, screenPos.y, "Broken Generator", 225, 90, 90, 255, "", 0)
                end
            end
        end
    end
end

local function anglerWarn()
    if not globals.is_focused() then return end
    for _, i in pairs(anglerVariants) do
        -- doesn't work with an inverted if, fuck if I know why
        if workspace:FindChild(i) then
            if anglerDistanceToggle:get() then
                local anglerPart = workspace:FindChild(i)
                if not anglerPart then return end
                local anglerPrim = anglerPart:Primitive()
                if not anglerPrim then return end
                local anglerPos = anglerPrim:GetPartPosition()
                if not anglerPos then return end

                render.text((screenSize.x/2 - 50), (screenSize.y - 175), ""..i..": "..math.floor(Distance(playerPosition(), anglerPos)), 255, 255, 0, 255, "", anglerFont)
            elseif not anglerDistanceToggle:get() then
                render.text((screenSize.x/2 - 50), (screenSize.y - 175), i, 255, 255, 0, 255, "", anglerFont)
            end
        end
    end
end

local function wallDwellerWarn()
    if not globals.is_focused() then return end
    local monstersFolder = gameplayFolder:FindChild("Monsters")
    if not monstersFolder then return end
    if monstersFolder:FindChild("DiVineRoot") then
        if wallDwellerDistanceToggle:get() then
            local dwellerModel = monstersFolder:FindChild("DiVineRoot")
            if not dwellerModel then return end
            local dwellerHRP = dwellerModel:FindChild("HumanoidRootPart")
            if not dwellerHRP then return end
            local dwellerPrim = dwellerHRP:Primitive()
            if not dwellerPrim then return end
            local dwellerPos = dwellerPrim:GetPartPosition()
            if not dwellerPos then return end

            render.text((screenSize.x/2- 100), (screenSize.y - 210), "Wall Dweller: "..math.floor(Distance(playerPosition(), dwellerPos)), 255, 255, 255, 255, "", anglerFont)
        elseif not wallDwellerDistanceToggle:get() then
            render.text((screenSize.x/2- 100), (screenSize.y - 210), "Wall Dweller", 255, 255, 255, 255, "", anglerFont)
        end
    end
end

local function WDITDCheck()
    local player = players:FindChild(entity.localplayer():Name())
    if not player then return end

    local playerFolder = player:FindChild("PlayerFolder")
    if not playerFolder then return end
    
    local hadLightStore = playerFolder:FindChild("HadLightSource")
    if not hadLightStore then return end

    local hadLightAddress = hadLightStore:Address()
    if not hadLightAddress then return end

    local hadLightValue = utils.read_memory("bool", hadLightAddress + Value)

    if hadLightValue == 1 then
        return true
    elseif hadLightValue == 0 then
        return false
    end
end

local function WDITDHelp()
    if not globals.is_focused() then return end

    if WDITDCheck() then
        render.text(20, screenSize.y - 300, "WDITD Failed :(", 255, 0, 0, 255, "", anglerFont)
    elseif not WDITDCheck() then
        render.text(20, screenSize.y - 300, "WDITD Good :D", 0, 255, 0, 255, "", anglerFont)
    end
end

local extraCarefulFailed = false
local function CarefulHelp()
    if not globals.is_focused() then return end

    if not extraCarefulFailed then
        render.text(20, screenSize.y - 335, "Extra Careful Good :D", 0, 255, 0, 255, "", anglerFont)

        local player = players:FindChild(entity.localplayer():Name())
        if not player then return end

        local playerFolder = player:FindChild("PlayerFolder")
        if not playerFolder then return end

        local healthStore = playerFolder:FindChild("Health")
        if not healthStore then return end

        local healthAddress = healthStore:Address()
        if not healthAddress then return end

        local healthValue = utils.read_memory("int", healthAddress + Value)

        if healthValue < 100 then
            extraCarefulFailed = true
        end
    elseif extraCarefulFailed then
        render.text(20, screenSize.y - 335, "Extra Careful Failed :(", 255, 0, 0, 255, "", anglerFont)
    end
end

cheat.set_callback("paint", function()
    if anglerWarnToggle:get() then
        anglerWarn()
        anglerDistanceToggle:set_visible(true)
    elseif not anglerWarnToggle:get() then
        anglerDistanceToggle:set_visible(false)
    end

    if wallDwellerWarnToggle:get() then
        wallDwellerWarn()
        wallDwellerDistanceToggle:set_visible(true)
    elseif not wallDwellerWarnToggle:get() then
        wallDwellerDistanceToggle:set_visible(false)
    end

    if fakeDoorWarnToggle:get() then
        highlightFakeDoors()
    end

    if voidLockerWarnToggle:get() then
        highlightMonsterLockers()
    end

    if moneyESPToggle:get() then
        highlightCurrency()
    end

    if itemESPToggle:get() then
        highlightItems()
    end

    if keycardESPToggle:get() then
        highlightKeycards()
    end

    if generatorESPToggle:get() then
        highlightMidGenerators()
    end

    if generatorESPToggle2:get() then
        highlightEndGenerators()
    end

    if WDITDToggle:get() then
        WDITDHelp()
    end

    if CarefulToggle:get() then
        CarefulHelp()
    end
end)
