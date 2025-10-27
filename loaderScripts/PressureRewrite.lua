-- Place ID: 12552538292

-- //Dependancies

--Offsets
http.get("https://raw.githubusercontent.com/SimpSupreme/custom-assembly-scripts/refs/heads/main/NOT%20MY%20SCRIPTS/AssemblyOffsetsNoPrint.lua", function(v)
    loadstring(v)()
end)
--Colors
http.get("https://raw.githubusercontent.com/SimpSupreme/custom-assembly-scripts/refs/heads/main/scripts/Colors.lua", function(v)
    loadstring(v)()
end)

-- //Constants
local DATAMODEL = globals.data_model()
local PLAYERS = datamodel:FindChild("Players")
local WORKSPACE = globals.workspace()
local SCREEN_SIZE = render.screen_size()
local GAMEPLAY_FOLDER = workspace:FindChild("GameplayFolder")
local ROOMS_FOLDER = gameplayFolder:FindChild("Rooms")
local ANGLER_FONT = render.create_font("C:\\Windows\\Fonts\\Verdana.ttf", 33, "ab")
local MAJOR_FILE_NAMES = {"AbstractDocument", "LunarDockDocument", "ThePainterDocument", "StanDocument", "MindscapeDocument", "AnalogChristmasDocument", "LetVandZoneDocument", "DiVineDocument", "RidgeDocument"} -- currently unused, still finding them
local FAKE_DOOR_NAMES = {"ServerTrickster", "TricksterRoom", "OutskirtsTrickster"}
local ITEM_NAMES = {"RoomsBattery", "DefaultBattery1", "DefaultBattery2", "DefaultBattery3", "AltBattery1", "AltBattery2", "AltBattery3", "FlashLight", "Flashlight", "WindupLight", "Blacklight", "Gummylight", "Lantern", "SmallLantern", "BigFlashBeacon", "FlashBeacon", "Book", "Medkit", "CrateMedkit", "HealthBoost", "CrateHealthBoost", "Defib", "CrateDefib", "SPRINT", "DoubleSprint", "CodeBreacher", "CrateCodeBreacher", "ToyRemote", "BlueToyRemote"}
local ITEM_NAMES_NO_LIGHTS = {"RoomsBattery", "DefaultBattery1", "DefaultBattery2", "DefaultBattery3", "AltBattery1", "AltBattery2", "AltBattery3", "Medkit", "CrateMedkit", "HealthBoost", "CrateHealthBoost", "Defib", "CrateDefib", "SPRINT", "DoubleSprint", "CodeBreacher", "CrateCodeBreacher", "ToyRemote", "BlueToyRemote"}
local KEYCARD_NAMES = {"NormalKeyCard", "PasswordPaper", "InnerKeyCard", "RidgeKeyCard"}
local ANGLER_VARIANTS = {"Angler", "Blitz", "Froger", "Pinkie", "Chainsmoker", "Pandemonium", "RidgeAngler", "RidgeFroger", "RidgeBlitz", "RidgePinkie", "RidgeChainsmoker", "A60", "Mirage"}
local CURERNCY_NAMES = {"Blueprint", "Relic", "HypnoCoin"}

-- //Colors
local COLOR_WHITE = {255, 255, 255}
local COLOR_BLACK = {0, 0, 0,}
local COLOR_RED = {255, 0, 0}
local COLOR_LIGHT_RED = {255, 90, 90}
local COLOR_GREEN = {0, 255, 0}
local COLOR_LIGHT_GREEN = {90, 255, 90}
local COLOR_BLUE = {0, 0, 255}
local COLOR_LIGHT_BLUE = {90, 90, 255}
local COLOR_YELLOW = {255, 255, 0}
local COLOR_LIGHT_YELLOW = {255, 255, 90}
local COLOR_PURPLE = {255, 0, 255}
local COLOR_LIGHT_PURPLE = {255, 90, 255}
local COLOR_TEAL = {0, 255, 255}
local COLOR_LIGHT_TEAL = {90, 255, 255}


-- //Generic Methods
local function playerPosition()
    local localPlayer = entity.localplayer()
    if not localPlayer then return end
    local humanoidRootPart = localPlayer:GetBone("HRP")
    if not humanoidRootPart then return end
    local humanoidRootPartPrimative = humanoidRootPart:Primitive()
    if not humanoidRootPartPrimative then return end
    local playerPosition = humanoidRootPartPrimative:GetPartPosition()
    if not playerPosition then return end

    return playerPosition
end

local function currentRoom()
    local rooms = roomsFolder:Children()
    local currentRoom = rooms[#rooms - 1]
    return currentRoom
end

local function Distance(positionOne, positionTwo)
    if not positionOne or not positionTwo then return nil end
    if not positionOne.z or not positionTwo.z then return nil end

    
    local distanceX = positionOne.x - positionTwo.x
    local distanceY = positionOne.y - positionTwo.y
    local distanceZ = positionOne.z - positionTwo.z
    local distance = math.sqrt(distanceX * distanceX + distanceY * distanceY + distanceZ * distanceZ)
    return distance
end

local function toggleDependant(dependant, indepenant)
    if indepenant:get() then
        dependant:set_visible(true)
    else
        dependant:set_visible(false)
    end
end

ui.label("Warnings")
local anglerWarnToggle = ui.new_checkbox("Angler Warning")
local anglerDistanceToggle = ui.new_checkbox("Angler Distance")
local wallDwellerWarnToggle = ui.new_checkbox("Wall Dweller Warning")
local wallDwellerDistanceToggle = ui.new_checkbox("Wall Dweller Distance")
local fakeDoorWarnToggle = ui.new_checkbox("Fake Door Warning")
local voidLockerWarnToggle = ui.new_checkbox("Void Locker Warning")

ui.label("")

ui.label("ESP/Highlights")
local curRoomOnlyToggle = ui.new_checkbox("Current Room Only")
local renderDistanceSlider = ui.slider_int("Render Distance (0 for inf range)", 0000, 0, 1000, "%d")
local moneyESPToggle = ui.new_checkbox("Money ESP")
local itemESPToggle = ui.new_checkbox("Item ESP")
local keycardESPToggle = ui.new_checkbox("Keycard/Password ESP")
local generatorESPToggle = ui.new_checkbox("Searchlight GE Generator ESP")
local generatorESPToggle2 = ui.new_checkbox("Ending Searchlight Generator ESP")

ui.label("")

ui.label("Challenge Helpers")
local WDITDToggle = ui.new_checkbox("We Die In The Dark")
local CarefulToggle = ui.new_checkbox("Extra Careful")

-- //Caches
local currencyCache = {}
local itemPosCache = {}
local itemNameCache = {}
local keycardCache = {}
local monsterLockerCache = {}
local fakeDoorCache = {}
local generatorCache = {}
local generatorCache2 = {}
local updateInterval = 1

local function highliht(cache, name, color)
    if not globals.is_focused() then return end


end