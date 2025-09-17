http.get("https://raw.githubusercontent.com/SimpSupreme/custom-assembly-scripts/refs/heads/main/NOT%20MY%20SCRIPTS/AssemblyOffsetsNoPrint.lua", function(v)
    loadstring(v)()
end)

local screenSize = render.screen_size()
local workspace = globals.data_model():FindChild("Workspace")
local nationFolder = workspace:FindChild("nation_team")
local empireFolder = workspace:FindChild("empire_team")
local serverStuffFolder = workspace:FindChild("serverStuff")
local gameSetupModel = serverStuffFolder:FindChild("game_setup")
local dreadFont = render.create_font("C:\\Windows\\Fonts\\cour.ttf", 25, "ab")
local dreadIcon = render.texture("https://trello.com/1/cards/67b12d8854164d3a85b604d2/attachments/67bde75cbd257edd1b2ce07e/download/%E2%80%94Pngtree%E2%80%94skull_icon_logo_vector_illuatration_7964583.png")
local shockIcon = render.texture("https://trello.com/1/cards/6795987f726f5d13f2bb9da0/attachments/67a289b4d77a064c9ff1ff6f/download/shock_troopers_icon.png")
local stormIcon = render.texture("https://trello.com/1/cards/6795764e3557abdace1e5a33/attachments/67a288edc16e7ac7d922c61d/download/shock_trooper_class_icon.png")
local amrIcon = render.texture("https://trello.com/1/cards/67bde4a22db7cdc2c9685050/attachments/67c350e8fb98c0fc69bd809c/download/antimaterial.png")
local flamerIcon = render.texture("https://trello.com/1/cards/67962afd5805fbd7bfede65d/attachments/67a288f9eab80bb923e56d3c/download/flame_trooper_class_icon.png")
local radioIcon = render.texture("https://trello.com/1/cards/67a61f889a8da348432e8b94/attachments/67b4870b3ae01f11cd592678/download/Screenshot_2025-02-08_124824.png")
local geistIcon = render.texture("https://trello.com/1/cards/67d5b0c3ca8a93fa5f28e620/attachments/68c48ae15695d05b9c24f854/download/geist_trooper_icon.png")
local trenchIcon = render.texture("https://trello.com/1/cards/67cc95d5d7c3e18683b56950/attachments/6825f834657f013737c868a5/download/trench_icon.png")
--[[ Unused Icons
local bulwarkIcon = render.texture("https://trello.com/1/cards/67d596a1a564f47a73c78910/attachments/67d5f448a29f2245710f3259/download/Untitled.png")
local mantrapIcon = render.texture("https://raw.githubusercontent.com/SimpSupreme/custom-assembly-scripts/refs/heads/main/loaderScripts/Images/GraveDigger/BearTrap.png")
local tinBombIcon = render.texture("https://raw.githubusercontent.com/SimpSupreme/custom-assembly-scripts/refs/heads/main/loaderScripts/Images/GraveDigger/TinBomb.png")
local gasTrapIcon = render.texture("https://raw.githubusercontent.com/SimpSupreme/custom-assembly-scripts/refs/heads/main/loaderScripts/Images/GraveDigger/GasTrap.png")
local dynaIcon = render.texture("https://raw.githubusercontent.com/SimpSupreme/custom-assembly-scripts/refs/heads/main/loaderScripts/Images/GraveDigger/Dyna.png")
local shellTrapIcon = render.texture("https://raw.githubusercontent.com/SimpSupreme/custom-assembly-scripts/refs/heads/main/loaderScripts/Images/GraveDigger/ShotgunTrap.png")
local lightLureIcon = render.texture("https://raw.githubusercontent.com/SimpSupreme/custom-assembly-scripts/refs/heads/main/loaderScripts/Images/GraveDigger/LanternLure.png")
]]

local dreadHighlightToggle = ui.new_checkbox("Highlight Dreadnaught")
local DreadRelativeColors = ui.new_checkbox("Dread Highlight Team Colors")
local dreadBossbarToggle = ui.new_checkbox("Dreadnough Boss Bar")
local HighlightShocks = ui.new_checkbox("Highlight Shock Troopers")
-- local jaegerTrapHighlightToggle = ui.new_checkbox("Highlight Jaeger Traps") Unused Toggle
local shockKitHighlightToggle = ui.new_checkbox("Highlight Shock Kits")
local tpToShockKit1 = ui.button("Teleport to Control Kit 1")
local tpToShockKit2 = ui.button("Teleport to Control Kit 2")
local pointSelectDropdown = ui.new_combo("Select Point to TP to", {"Point Able", "Point Baker", "Point Charlie", "Point Duff", "Point Edward"})
pointSelectDropdown:set_visible(true) -- idk why I need this but it doesn't show up otherwise
local tpToPoint = ui.button("Teleport to Selected Point")

local function ValueCheck(toGet) 
    local memAddress = toGet:Address()
    if toGet:ClassName() == "StringValue" then
        return utils.read_memory("string", memAddress + Value)
    end
end

local dreadObject = nil
local dreadPlayer = nil
local dreadTeam = nil
local dreadTorso = nil
local shockNamesCache = {}
local shockTeamsCache = {}
local shockClassCache = {}
local shockTorsoCache = {}
local dreadUpdate = 0
local shockUpdate = 0
local updateInterval = 1

local function dreadnoughtCacher()
    dreadObject = nil
    dreadPlayer = nil
    dreadTeam = nil
    dreadTorso = nil

    local players = entity.get_players()
    for _, player in ipairs(players) do
        if player:MaxHealth() >= 500 then
            dreadObject = player
            dreadPlayer = player:Name()
            dreadTeam = player:TeamName()
            break
        end
    end

    if dreadPlayer then
        local teamFolder = nil
        if dreadTeam == "Royal Nation" then
            teamFolder = nationFolder
        elseif dreadTeam == "Golden Empire" then
            teamFolder = empireFolder
        end
        if not teamFolder then return end
        local dreadModel = teamFolder:FindChild(dreadPlayer)
        if not dreadModel then return end
        local torso = dreadModel:FindChild("Torso")
        if not torso then return end
        dreadTorso = torso
    end
end

local function shockCacher()
    shockNamesCache = {}
    shockClassCache = {}
    shockTeamsCache = {}
    shockTorsoCache = {}

    local players = entity.get_players()
    for _, player in ipairs(players) do
        if player:MaxHealth() == 300 then
            table.insert(shockNamesCache, player:Name())
            table.insert(shockTeamsCache, player:TeamName())
        end
    end
    for i = 1, #shockNamesCache do
        local teamFolder = nil
        if shockTeamsCache[i] == "Royal Nation" then
            teamFolder = nationFolder
        elseif shockTeamsCache[i] == "Golden Empire" then
            teamFolder = empireFolder
        end
        if not teamFolder then return end

        local shockModel = teamFolder:FindChild(shockNamesCache[i])
        if not shockModel then return end

        local shockValue = shockModel:FindChild("elitekit")
        if not shockValue then return end
        local shockClass = ValueCheck(shockValue)
        if not shockClass then return end
        table.insert(shockClassCache, shockClass)

        local shockTorso = shockModel:FindChild("Torso")
        if not shockTorso then return end
        table.insert(shockTorsoCache, shockTorso)
    end
end

local function highlightDreadnought()
    local now = globals.curtime()
    if now - dreadUpdate >= updateInterval then
        dreadnoughtCacher()
        dreadUpdate = now
    end

    if not globals.is_focused() then return end
    if not dreadTorso then return end
    local dreadTorsoPrim = dreadTorso:Primitive()
    if not dreadTorsoPrim then return end
    local dreadPos = dreadTorsoPrim:GetPartPosition()
    if not dreadPos then return end
    local dreadScreenPos = utils.world_to_screen(dreadPos)
    if not dreadScreenPos then return end
    if dreadScreenPos.x <= 0 then return end
    if not DreadRelativeColors:get() then
        render.rect((dreadScreenPos.x - 15), (dreadScreenPos.y - 15), 30, 30, 255, 0, 0, 255, 0)
    elseif DreadRelativeColors:get() then
        if dreadTeam == "Royal Nation" then
            render.rect((dreadScreenPos.x - 15), (dreadScreenPos.y - 15), 30, 30, 185, 41, 240, 255, 0)
        elseif dreadTeam == "Golden Empire" then
            render.rect((dreadScreenPos.x - 15), (dreadScreenPos.y - 15), 30, 30, 241, 212, 41, 200, 0)
        end
    end
    render.image(dreadIcon, (dreadScreenPos.x - 15), (dreadScreenPos.y - 15), (dreadScreenPos.x + 15), (dreadScreenPos.y + 15))
end

local function dreadnoughtBossBar()
    if not globals.is_focused() then return end
    if not dreadObject then return end
    local dreadCurHealth = dreadObject:Health()
    render.rect(40, 95, (screenSize.x - 80), 20, 0, 0, 0, 255, 0)
    render.rect_outline(40, 95, (screenSize.x - 80), 20, 93, 0, 0, 255, 0)

    local maxBarWidth = screenSize.x - 80
    local healthRatio = (dreadCurHealth / 11000)
    local healthBarWidth = (healthRatio * (screenSize.x - 10))
    local healthBarOffset = (maxBarWidth - healthBarWidth) / 2

    local healthBarX = 40 + healthBarOffset
    render.rect(healthBarX, 95, healthBarWidth, 20, 200, 0, 0, 255, 0)

    render.rect_outline(40, 95, (screenSize.x - 80), 20, 93, 93, 93, 255, 0, 3)

    render.text(((screenSize.x / 2) - 75), 120, "Dreadnought", 255, 255, 255, 255, "", dreadFont)
end

local function highlightShockTroopers()
    local now = globals.curtime()
    if now - shockUpdate >= updateInterval then
        shockCacher()
        shockUpdate = now
    end
    if not globals.is_focused() then return end
    for i = 1, #shockNamesCache do
        local shockPrim = shockTorsoCache[i]:Primitive()
        if not shockPrim then return end
        local shockPos = shockPrim:GetPartPosition()
        if not shockPos then return end
        local shockScreenPos = utils.world_to_screen(shockPos)
        if not shockScreenPos then return end
        if shockScreenPos.x >= 0  then
            if shockTeamsCache[i] == "Royal Nation" then
                render.rect((shockScreenPos.x - 10), (shockScreenPos.y - 10), 20, 20, 185, 41, 240, 255, 0)
            elseif shockTeamsCache[i] == "Golden Empire" then
                render.rect((shockScreenPos.x - 10), (shockScreenPos.y - 10), 20, 20, 241, 212, 41, 200, 0)
            end

            if shockClassCache[i] == "soldat" then
                render.image(stormIcon, (shockScreenPos.x - 10), (shockScreenPos.y - 10), (shockScreenPos.x + 10), (shockScreenPos.y + 10))
            elseif shockClassCache[i] == "rook" then
                render.image(amrIcon, (shockScreenPos.x - 10), (shockScreenPos.y - 10), (shockScreenPos.x + 10), (shockScreenPos.y + 10))
            elseif shockClassCache[i] == "mortician" then
                render.image(flamerIcon, (shockScreenPos.x - 10), (shockScreenPos.y - 10), (shockScreenPos.x + 10), (shockScreenPos.y + 10))
            elseif shockClassCache[i] == "officer" then
                render.image(radioIcon, (shockScreenPos.x - 10), (shockScreenPos.y - 10), (shockScreenPos.x + 10), (shockScreenPos.y + 10))
            elseif shockClassCache[i] == "jaeger" then
                render.image(geistIcon, (shockScreenPos.x - 10), (shockScreenPos.y - 10), (shockScreenPos.x + 10), (shockScreenPos.y + 10))
            elseif shockClassCache[i] == "lancer" then
                render.image(trenchIcon, (shockScreenPos.x - 10), (shockScreenPos.y - 10), (shockScreenPos.x + 10), (shockScreenPos.y + 10))
            elseif shockClassCache[i] == "vanguard" then
                render.image(bulwarkIcon, (shockScreenPos.x - 10), (shockScreenPos.y - 10), (shockScreenPos.x + 10), (shockScreenPos.y + 10))
            end
        end
    end
end

local function highlightShockKits()
    if not globals.is_focused() then return end
    local valuesFolder = serverStuffFolder:FindChild("values")
    if not valuesFolder then return end
    local gamemodeValue = valuesFolder:FindChild("gamemode")
    if not gamemodeValue then return end
    local curGamemode = ValueCheck(gamemodeValue)
    if not curGamemode then return end
    if curGamemode == "control" then
        local kitOne = gameSetupModel:FindChild("elite_kit1")
        local kitTwo = gameSetupModel:FindChild("elite_kit2")
        if not kitOne and kitTwo then return end
        local clickOne = kitOne:FindChild("click")
        local clickTwo = kitTwo:FindChild("click")
        if not clickOne and clickTwo then return end
        local clickOnePrim = clickOne:Primitive()
        local clickTwoPrim = clickTwo:Primitive()
        if not clickOnePrim and clickTwoPrim then return end
        local clickOnePos = clickOnePrim:GetPartPosition()
        local clickTwoPos = clickTwoPrim:GetPartPosition()
        if not clickOnePos and clickTwoPos then return end
        local clickOneScreenPos = utils.world_to_screen(clickOnePos)
        local clickTwoScreenPos = utils.world_to_screen(clickTwoPos)
        if not clickOneScreenPos and clickTwoScreenPos then return end
        if not kitOne:FindChild("used") then
            if clickOneScreenPos.x >= 0 then
                render.image(shockIcon, (clickOneScreenPos.x - 10), (clickOneScreenPos.y - 10), (clickOneScreenPos.x + 10), (clickOneScreenPos.y + 10))
                render.text((clickOneScreenPos.x - 2), (clickOneScreenPos.y + 15), "1", 255, 255, 255, 255, "", 0)
            end
        end
        if not kitTwo:FindChild("used") then
            if clickTwoScreenPos.x >= 0 then
                render.image(shockIcon, (clickTwoScreenPos.x - 10), (clickTwoScreenPos.y - 10), (clickTwoScreenPos.x + 10), (clickTwoScreenPos.y + 10))
                render.text((clickTwoScreenPos.x - 2), (clickTwoScreenPos.y + 15), "2", 255, 255, 255, 255, "", 0)
            end
        end
    else
        for _, model in ipairs(gameSetupModel:Children()) do
            if model:ClassName() == "Model" and model:Name() == "elitecrate" then
                local crateClick = model:FindChild("click")
                if not crateClick then return end
                local clickPrim = crateClick:Primitive()
                if not clickPrim then return end
                local clickPos = clickPrim:GetPartPosition()
                if not clickPos then return end
                local clickScreenPos = utils.world_to_screen(clickPos)
                if not clickScreenPos then return end
                if not model:FindChild("used") then
                    if clickScreenPos.x >= 0 then
                        render.image(shockIcon, (clickScreenPos.x - 10), (clickScreenPos.y - 10), (clickScreenPos.x + 10), (clickScreenPos.y + 10))
                    end
                end
            end
        end
    end
end

local function tpControlKit(kit)
    local kit1 = gameSetupModel:FindChild("elite_kit1")
    local kit2 = gameSetupModel:FindChild("elite_kit2")
    if not kit1 and kit2 then return end
    local kit1Click = kit1:FindChild("click")
    local kit2Click = kit2:FindChild("click")
    if not kit1Click and kit2Click then return end
    local click1Prim = kit1Click:Primitive()
    local click2Prim = kit2Click:Primitive()
    if not click1Prim and click2Prim then return end
    local click1Pos = click1Prim:GetPartPosition()
    local click2Pos = click2Prim:GetPartPosition()
    if not click1Pos and click2Pos then return end
    local tp1Pos = Vector3(click1Pos.x, click1Pos.y + 5, click1Pos.z)
    local tp2Pos = Vector3(click2Pos.x, click2Pos.y + 5, click2Pos.z)
    if not tp1Pos and tp2Pos then return end

    local player = entity.localplayer()
    if not player then return end
    local HRP = player:GetBone("HRP")
    if not HRP then return end
    local HRPPrim = HRP:Primitive()
    if not HRPPrim then return end

    if kit == 1 then
        HRPPrim:SetPartPosition(tp1Pos)
    elseif kit == 2 then
        HRPPrim:SetPartPosition(tp2Pos)
    end
end

local function tpControlPoint(point)
    local objectivesFolder = serverStuffFolder:FindChild("objectives")
    local pointToTeleport = nil
    if point == 0 then pointToTeleport = objectivesFolder:FindChild("objectiveA") end
    if point == 1 then pointToTeleport = objectivesFolder:FindChild("objectiveB") end
    if point == 2 then pointToTeleport = objectivesFolder:FindChild("objectiveC") end
    if point == 3 then pointToTeleport = objectivesFolder:FindChild("objectiveD") end
    if point == 4 then pointToTeleport = objectivesFolder:FindChild("objectiveE") end

    local objectiveCapture = pointToTeleport:FindChild("capture")
    if not objectiveCapture then return end
    local capturePrim = objectiveCapture:Primitive()
    if not capturePrim then return end
    local capturePos = capturePrim:GetPartPosition()
    if not capturePos then return end

    local player = entity.localplayer()
    if not player then return end
    local HRP = player:GetBone("HRP")
    if not HRP then return end
    local HRPPrim = HRP:Primitive()
    if not HRPPrim then return end

    HRPPrim:SetPartPosition(capturePos)
end

cheat.set_callback("paint", function()
    if dreadHighlightToggle:get() then
        highlightDreadnought()
        DreadRelativeColors:set_visible(true)
        dreadBossbarToggle:set_visible(true)
        if dreadBossbarToggle:get() then
            dreadnoughtBossBar()
        end
    elseif not dreadHighlightToggle:get() then
        DreadRelativeColors:set_visible(false)
        dreadBossbarToggle:set_visible(false)
    end

    if HighlightShocks:get() then
        highlightShockTroopers()
    end

    if shockKitHighlightToggle:get() then
        highlightShockKits()
    end

    if tpToShockKit1:get() then
        tpControlKit(1)
    end

    if tpToShockKit2:get() then
        tpControlKit(2)
    end

    if tpToPoint:get() then
        tpControlPoint(pointSelectDropdown:get())
    end
end)
