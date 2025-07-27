local dreadHighlightToggle = ui.new_checkbox("Highlight Dreadnaught")
local DreadRelativeColors = ui.new_checkbox("Dread Highlight Team Colors")
local HighlightShocks = ui.new_checkbox("Highlight Shock Troopers")
local shockKitHighlightToggle = ui.new_checkbox("Highlight Control Kits")
local tpToShockKit1 = ui.button("Teleport to Control Kit 1")
local tpToShockKit2 = ui.button("Teleport to Control Kit 2")
local pointSelectDropdown = ui.new_combo("Select Point to TP to", {"Point Able", "Point Baker", "Point Charlie", "Point Duff", "Point Edward"})
local tpToPoint = ui.button("Teleport to Selected Point")
local workspace = globals.data_model():FindChild("Workspace")
local dreadIcon = render.texture("https://trello.com/1/cards/67b12d8854164d3a85b604d2/attachments/67bde75cbd257edd1b2ce07e/download/%E2%80%94Pngtree%E2%80%94skull_icon_logo_vector_illuatration_7964583.png")
local shockIcon = render.texture("https://trello.com/1/cards/6795987f726f5d13f2bb9da0/attachments/67a289b4d77a064c9ff1ff6f/download/shock_troopers_icon.png")
local stormIcon = render.texture("https://trello.com/1/cards/6795764e3557abdace1e5a33/attachments/67a288edc16e7ac7d922c61d/download/shock_trooper_class_icon.png")
local amrIcon = render.texture("https://trello.com/1/cards/67bde4a22db7cdc2c9685050/attachments/67c350e8fb98c0fc69bd809c/download/antimaterial.png")
local flamerIcon = render.texture("https://trello.com/1/cards/67962afd5805fbd7bfede65d/attachments/67a288f9eab80bb923e56d3c/download/flame_trooper_class_icon.png")
local radioIcon = render.texture("https://trello.com/1/cards/67a61f889a8da348432e8b94/attachments/67b4870b3ae01f11cd592678/download/Screenshot_2025-02-08_124824.png")
local geistIcon = render.texture("https://spaces-cdn.clipsafari.com/jcjgtlbjllekc2flgva3n29wmcpj")
local trenchIcon = render.texture("https://trello.com/1/cards/67cc95d5d7c3e18683b56950/attachments/6825f834657f013737c868a5/download/trench_icon.png")
local bulwarkIcon = render.texture("https://trello.com/1/cards/67d596a1a564f47a73c78910/attachments/67d5f448a29f2245710f3259/download/Untitled.png")


local function findDreadnaught()
    local players = entity.get_players()
    for _, player in ipairs(players) do
        local maxHealth = player:MaxHealth()
        if maxHealth and maxHealth > 500 then
            return player
        end
    end
end


local function getTorsoWorldPosition(player)

    local teamFolder = nil
    if player:TeamName() == "Golden Empire" then
        teamFolder = globals.workspace():FindChild("empire_team")
    elseif player:TeamName() == "Royal Nation" then
        teamFolder = globals.workspace():FindChild("nation_team")
    end

    if not teamFolder then return end

    local model = teamFolder:FindChild(player:Name())
    if not model then return end

    local torso = model:FindChild("Torso")
    if not torso then return end

    local prim = torso:Primitive()
    if not prim then return end

    return prim:GetPartPosition()
end

local function renderShocks()
    for _, player in ipairs(entity.get_players()) do
        if player:MaxHealth() == 300 then
            if globals.is_focused() then
                local screenPos = utils.world_to_screen(getTorsoWorldPosition(player))
                if not screenPos then return end

                local teamFolder = nil
                if player:TeamName() == "Royal Nation" then
                    teamFolder = workspace:FindChild("nation_team")
                elseif player:TeamName() == "Golden Empire" then
                    teamFolder = workspace:FindChild("empire_team")
                end
                if not teamFolder then return end

                local model = teamFolder:FindChild(player:Name())
                if not model then return end
                                        
                if screenPos.x > 0 and screenPos.y > 0 then
                    if player:TeamName() == "Royal Nation" then
                        render.rect((screenPos.x - 10), (screenPos.y - 10), 20, 20, 185, 41, 240, 255, 0)
                        if model:FindChild("soldat_elitetorso") then
                            render.image(stormIcon, (screenPos.x - 10), (screenPos.y - 10), (screenPos.x + 10), (screenPos.y + 10))
                        elseif model:FindChild("rook_elitetorso") then
                            render.image(amrIcon, (screenPos.x - 10), (screenPos.y - 10), (screenPos.x + 10), (screenPos.y + 10))
                        elseif model:FindChild("mortician_elitetorso") then
                            render.image(flamerIcon, (screenPos.x - 10), (screenPos.y - 10), (screenPos.x + 10), (screenPos.y + 10))
                        elseif model:FindChild("officer_elitetorso") then
                            render.image(radioIcon, (screenPos.x - 10), (screenPos.y - 10), (screenPos.x + 10), (screenPos.y + 10))
                        elseif model:FindChild("jaeger_elitetorso") then
                            render.image(geistIcon, (screenPos.x - 10), (screenPos.y - 10), (screenPos.x + 10), (screenPos.y + 10))
                        elseif model:FindChild("lancer_elitetorso") then
                            render.image(trenchIcon, (screenPos.x - 10), (screenPos.y - 10), (screenPos.x + 10), (screenPos.y + 10))
                        elseif model:FindChild("vanguard_elitetorso") then
                            render.image(bulwarkIcon, (screenPos.x - 10), (screenPos.y - 10), (screenPos.x + 10), (screenPos.y + 10))
                        end
                    elseif player:TeamName() == "Golden Empire" then
                        render.rect((screenPos.x - 10), (screenPos.y - 10), 20, 20, 241, 212, 41, 200, 0)
                        if model:FindChild("soldat_elitetorso") then
                            render.image(stormIcon, (screenPos.x - 10), (screenPos.y - 10), (screenPos.x + 10), (screenPos.y + 10))
                        elseif model:FindChild("rook_elitetorso") then
                            render.image(amrIcon, (screenPos.x - 10), (screenPos.y - 10), (screenPos.x + 10), (screenPos.y + 10))
                        elseif model:FindChild("mortician_elitetorso") then
                            render.image(flamerIcon, (screenPos.x - 10), (screenPos.y - 10), (screenPos.x + 10), (screenPos.y + 10))
                        elseif model:FindChild("officer_elitetorso") then
                            render.image(radioIcon, (screenPos.x - 10), (screenPos.y - 10), (screenPos.x + 10), (screenPos.y + 10))
                        elseif model:FindChild("jaeger_elitetorso") then
                            render.image(geistIcon, (screenPos.x - 10), (screenPos.y - 10), (screenPos.x + 10), (screenPos.y + 10))
                        elseif model:FindChild("lancer_elitetorso") then
                            render.image(trenchIcon, (screenPos.x - 10), (screenPos.y - 10), (screenPos.x + 10), (screenPos.y + 10))
                        elseif model:FindChild("vanguard_elitetorso") then
                            render.image(bulwarkIcon, (screenPos.x - 10), (screenPos.y - 10), (screenPos.x + 10), (screenPos.y + 10))
                        end
                    end
                end
            end
        end
    end
end

local function HighlightStaticKits(kitName)
    if globals.is_focused() then
        local serverstuff = workspace:FindChild("serverStuff")
        if not serverstuff then return end

        local gameSetup = serverstuff:FindChild("game_setup")
        if not gameSetup then return end

        local kit = gameSetup:FindChild(kitName)
        if kit and not kit:FindChild("used") then
            local lid = kit:FindChild("lid")
            if not lid then return end

            local insignia = lid:FindChild("insignia")
            if not insignia then return end

            local prim = insignia:Primitive()
            if not prim then return end

            local pos = prim:GetPartPosition()
            if not pos then return end

            local screenPos = utils.world_to_screen(pos)
            if not screenPos then return end

            if screenPos.x > 0 and screenPos.y > 0 then
                if kitName == "elite_kit1" then
                    render.image(shockIcon, (screenPos.x - 10), (screenPos.y - 10), (screenPos.x + 10), (screenPos.y + 10))
                    render.text((screenPos.x - 2), (screenPos.y + 15), "1", 255, 255, 255, 255, "", 0)
                elseif kitName == "elite_kit2" then
                    render.image(shockIcon, (screenPos.x - 10), (screenPos.y - 10), (screenPos.x + 10), (screenPos.y + 10))
                    render.text((screenPos.x - 2), (screenPos.y + 15), "2", 255, 255, 255, 255, "", 0)
                end
            end
        end
    end
end

local function teleportToStaticKit(kitName)
    local serverstuff = workspace:FindChild("serverStuff")
    if not serverstuff then return end

    local gameSetup =  serverstuff:FindChild("game_setup")
    if not gameSetup then return end
    
    local Shock1kit = gameSetup:FindChild(kitName)
    if not Shock1kit then return end

    local Shock1lid = Shock1kit:FindChild("lid")
    if not Shock1lid then return end

    local Shock1insignia = Shock1lid:FindChild("insignia")
    if not Shock1insignia then return end

    local Shock1prim = Shock1insignia:Primitive()
    if not Shock1prim then return end

    local Shock1pos = Shock1prim:GetPartPosition()
    if not Shock1pos then return end

    local localPlayer = entity.localplayer()
    if not localPlayer then return end

    local humanoidRootPart = localPlayer:GetBone("HRP")
    if not humanoidRootPart then return end

    local ShockTpPos = Vector3(Shock1pos.x, (Shock1pos.y + 5), Shock1pos.z)
    if not ShockTpPos then return end

    humanoidRootPart:Primitive():SetPartPosition(ShockTpPos)
end

local function teleportToPoint(selected)
    local serverstuff = workspace:FindChild("serverStuff")
    if not serverstuff then return end

    local objectives = serverstuff:FindChild("objectives")
    if not objectives then return end
    
    local localPlayer = entity.localplayer()
    if not localPlayer then return end

    local humanoidRootPart = localPlayer:GetBone("HRP")
    if not humanoidRootPart then return end

    if selected == 0 then
        local objectiveAble = objectives:FindChild("objectiveA")
        if not objectiveAble then return end
        
        local captureZone = objectiveAble:FindChild("capture")
        if not captureZone then return end
        
        humanoidRootPart:Primitive():SetPartPosition(captureZone:Primitive():GetPartPosition())

    elseif selected == 1 then
        local objectiveAble = objectives:FindChild("objectiveB")
        if not objectiveAble then return end
        
        local captureZone = objectiveAble:FindChild("capture")
        if not captureZone then return end
        
        humanoidRootPart:Primitive():SetPartPosition(captureZone:Primitive():GetPartPosition())

    elseif selected == 2 then
        local objectiveAble = objectives:FindChild("objectiveC")
        if not objectiveAble then return end
        
        local captureZone = objectiveAble:FindChild("capture")
        if not captureZone then return end
        
        humanoidRootPart:Primitive():SetPartPosition(captureZone:Primitive():GetPartPosition())

    elseif selected == 3 then
        local objectiveAble = objectives:FindChild("objectiveD")
        if not objectiveAble then return end
        
        local captureZone = objectiveAble:FindChild("capture")
        if not captureZone then return end
        
        humanoidRootPart:Primitive():SetPartPosition(captureZone:Primitive():GetPartPosition())

    elseif selected == 4 then
        local objectiveAble = objectives:FindChild("objectiveE")
        if not objectiveAble then return end
        
        local captureZone = objectiveAble:FindChild("capture")
        if not captureZone then return end
        
        humanoidRootPart:Primitive():SetPartPosition(captureZone:Primitive():GetPartPosition())
    end
end

cheat.set_callback("paint", function()
    if not dreadHighlightToggle:get() then
        DreadRelativeColors:set_visible(false)
    elseif dreadHighlightToggle:get() then
        DreadRelativeColors:set_visible(true)
        local dreadPlayer = findDreadnaught()
        if not dreadPlayer then return end

        local torsoWorldPos = getTorsoWorldPosition(dreadPlayer)
        if not torsoWorldPos then return end

        local screenPos = utils.world_to_screen(torsoWorldPos)
        if not screenPos then return end

        if globals.is_focused() then
            if screenPos.x > 0 and screenPos.y > 0 then
                if DreadRelativeColors:get() then
                    if dreadPlayer:TeamName() == "Royal Nation" then
                        render.rect((screenPos.x - 15), (screenPos.y - 15), 30, 30, 185, 41, 240, 255, 0)
                    elseif dreadPlayer:TeamName() == "Golden Empire" then
                        render.rect((screenPos.x - 15), (screenPos.y - 15), 30, 30, 241, 212, 41, 200, 0)
                    end
                else
                    render.rect((screenPos.x - 15), (screenPos.y - 15), 30, 30, 255, 0, 0, 255, 0)
                end
                render.image(dreadIcon, (screenPos.x - 15), (screenPos.y - 15), (screenPos.x + 15), (screenPos.y + 15))
            end
        end
    end

    if shockKitHighlightToggle:get() then
        HighlightStaticKits("elite_kit1")
        HighlightStaticKits("elite_kit2")
    end
    
    if HighlightShocks:get() then
        renderShocks()
    end

    if tpToShockKit1:get() then
        teleportToStaticKit("elite_kit1")
    end
    if tpToShockKit2:get() then
        teleportToStaticKit("elite_kit2")
    end

    if tpToPoint:get() then
        teleportToPoint(pointSelectDropdown:get())
    end

end)