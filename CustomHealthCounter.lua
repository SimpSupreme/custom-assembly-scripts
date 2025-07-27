local screenSize = render.screen_size()
local curHealthFont = render.create_font("C:\\Windows\\Fonts\\Verdana.ttf", 33, "a")
local maxHealthFont = render.create_font("C:\\Windows\\Fonts\\Verdana.ttf", 20, "ab")

local toggleCheckbox = ui.new_checkbox("Toggle Health HUD")
local indicatorStylePicker = ui.new_combo("Indicator Style", {"Box", "Bar"})
local customPositionToggle = ui.new_checkbox("Toggle Custom Position")
local positionSliderX = ui.slider_int("Position X", screenSize.x, 0, screenSize.x, "%d")
local positionSliderY = ui.slider_int("Position Y", screenSize.y, 0, screenSize.y, "%d")
local barStylePicker = ui.new_combo("Bar Style", {"Color Fade", "Half Health"})
local borderLabel = ui.label("Border Color")
local borderColorPicker = ui.colorpicker("Border Color", 1.0, 1.0, 1.0, 1.0)
local bodyLabel = ui.label("Main Color")
local bodyColorPicker = ui.colorpicker("Main Color", 1.0, 0.0, 0.0, 1.0)
local textLabel = ui.label("Text Color")
local textColorPicker = ui.colorpicker("Text Color", 1.0, 1.0, 1.0, 1.0)
local barRoundingSlider = ui.slider_int("Health Bar Corner Rounding", 8, 0, 25, "%d")
local barColor1Label = ui.label("Bar Color 1")
local barColor1Picker = ui.colorpicker("Bar Color 1", 0.0, 1.0, 0.0, 1.0)
local barColor2Label = ui.label("Bar Color 2")
local barColor2Picker = ui.colorpicker("Bar Color 2", 1.0, 0.0, 0.0, 1.0)
local barBackgroundLabel = ui.label("Background Color")
local barBackgroundPicker = ui.colorpicker("Background Color", 0.0, 0.0, 0., 1.0)

local positionParts = {positionSliderX, positionSliderY}
local barParts = {barStylePicker, barRoundingSlider, barColor1Label, barColor1Picker, barColor2Label, barColor2Picker, barBackgroundLabel, barBackgroundPicker}
local boxParts = {borderLabel, borderColorPicker, bodyLabel, bodyColorPicker, textLabel, textColorPicker}

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function setVisible(toToggle, visible)
    for _, i in pairs(toToggle) do
        i:set_visible(visible)
    end
end

local function deadCheck(health)
    if health > 0 then
        return false
    elseif health <=0 then
        return true
    end
end

cheat.set_callback("paint", function()
    local maxHealth = entity.localplayer():MaxHealth()
    local currentHealth = entity.localplayer():Health()

    if not globals.is_focused() then return end

    if not toggleCheckbox:get() then
        indicatorStylePicker:set_visible(false)
        customPositionToggle:set_visible(false)
        setVisible(positionParts, false)
        setVisible(barParts, false)
        setVisible(boxParts, false)
    elseif toggleCheckbox:get() then
        indicatorStylePicker:set_visible(true)
        customPositionToggle:set_visible(true)

        if not customPositionToggle:get() then
            setVisible(positionParts, false)
        elseif customPositionToggle:get() then
            setVisible(positionParts, true)
        end
        if indicatorStylePicker:get() == 0 then
            setVisible(barParts, false)
            setVisible(boxParts, true)

            local borderColor = borderColorPicker:get()
            local bodyColor = bodyColorPicker:get()
            local textColor = textColorPicker:get()
            if not customPositionToggle:get() then
                render.rect_outline((screenSize.x - 120), (screenSize.y - 120), 100, 100, (borderColor.r * 255), (borderColor.g * 255), (borderColor.b * 255), (borderColor.a * 255), 20, 4)
                render.rect((screenSize.x - 117), (screenSize.y - 117), 94, 94, (bodyColor.r * 255), (bodyColor.g * 255), (bodyColor.b * 255), (bodyColor.a * 255), 15)
                render.line((screenSize.x - 90), (screenSize.y - 40), (screenSize.x - 40), (screenSize.y - 90), 255, 255, 255, 255, 2)
                render.text((screenSize.x - 110), (screenSize.y - 107), math.floor(currentHealth), (textColor.r * 255), (textColor.g * 255), (textColor.b * 255), (textColor.a * 255), "",  curHealthFont)
                render.text((screenSize.x - 60), (screenSize.y - 60), maxHealth, (textColor.r * 255), (textColor.g * 255), (textColor.b * 255), (textColor.a * 255), "", maxHealthFont)
            elseif customPositionToggle:get() then
                render.rect_outline((screenSize.x - positionSliderX:get()), (screenSize.y - positionSliderY:get()), 100, 100, (borderColor.r * 255), (borderColor.g * 255), (borderColor.b * 255), (borderColor.a * 255), 20, 4)
                render.rect(((screenSize.x - positionSliderX:get()) + 3), ((screenSize.y - positionSliderY:get()) + 3), 94, 94, (bodyColor.r * 255), (bodyColor.g * 255), (bodyColor.b * 255), (bodyColor.a * 255), 15)
                render.line(((screenSize.x - positionSliderX:get()) + 30), ((screenSize.y - positionSliderY:get()) + 80), ((screenSize.x - positionSliderX:get()) + 80), ((screenSize.y - positionSliderY:get()) + 30), 255, 255, 255, 255, 2)
                render.text(((screenSize.x - positionSliderX:get()) + 10), ((screenSize.y - positionSliderY:get()) + 13), math.floor(currentHealth), (textColor.r * 255), (textColor.g * 255), (textColor.b * 255), (textColor.a * 255), "",  curHealthFont)
                render.text(((screenSize.x - positionSliderX:get()) + 60), ((screenSize.y - positionSliderY:get()) + 60), maxHealth, (textColor.r * 255), (textColor.g * 255), (textColor.b * 255), (textColor.a * 255), "", maxHealthFont)
            end
        elseif indicatorStylePicker:get() == 1 then
            setVisible(boxParts, false)
            setVisible(barParts, true)

            local barBackgroundColor = barBackgroundPicker:get()
            local barColor1 = barColor1Picker:get()
            local barColor2 = barColor2Picker:get()
            local healthRatio = (currentHealth / maxHealth)
            local healthBarWidth = (healthRatio * 280)

            if not customPositionToggle:get() then
                render.rect((screenSize.x - 300), (screenSize.y - 57), 280, 47, (barBackgroundColor.r * 255), (barBackgroundColor.g * 255), (barBackgroundColor.b * 255), (barBackgroundColor.a * 255), barRoundingSlider:get())
                
                if deadCheck(currentHealth) then return end
                
                if barStylePicker:get() == 1 then
                    if healthBarWidth >= 140 then
                        render.rect((screenSize.x - 300), (screenSize.y - 57), healthBarWidth, 47, (barColor1.r * 255), (barColor1.g * 255), (barColor1.b * 255), (barColor1.a * 255), barRoundingSlider:get())
                    elseif healthBarWidth < 140 then
                        render.rect((screenSize.x - 300), (screenSize.y - 57), healthBarWidth, 47, (barColor2.r * 255), (barColor2.g * 255), (barColor2.b * 255), (barColor2.a * 255), barRoundingSlider:get())
                    end
                elseif barStylePicker:get() == 0 then
                    render.rect((screenSize.x - 300), (screenSize.y - 57), healthBarWidth, 47, 
                        (lerp(barColor2.r, barColor1.r, healthRatio) * 255), 
                        (lerp(barColor2.g, barColor1.g, healthRatio) * 255), 
                        (lerp(barColor2.b, barColor1.b, healthRatio) * 255), 
                        (lerp(barColor2.a, barColor1.a, healthRatio) * 255), 
                    barRoundingSlider:get())
                end
            elseif customPositionToggle:get() then
                render.rect((screenSize.x - positionSliderX:get()), (screenSize.y - positionSliderY:get()), 280, 47, (barBackgroundColor.r * 255), (barBackgroundColor.g * 255), (barBackgroundColor.b * 255), (barBackgroundColor.a * 255), barRoundingSlider:get())
                
                if deadCheck(currentHealth) then return end

                if barStylePicker:get() == 1 then
                    if healthBarWidth >= 140 then
                        render.rect((screenSize.x - positionSliderX:get()), (screenSize.y - positionSliderY:get()), healthBarWidth, 47, (barColor1.r * 255), (barColor1.g * 255), (barColor1.b * 255), (barColor1.a * 255), barRoundingSlider:get())
                    elseif healthBarWidth < 140 then
                        render.rect((screenSize.x - positionSliderX:get()), (screenSize.y - positionSliderY:get()), healthBarWidth, 47, (barColor2.r * 255), (barColor2.g * 255), (barColor2.b * 255), (barColor2.a * 255), barRoundingSlider:get())
                    end
                elseif barStylePicker:get() == 0 then
                    render.rect((screenSize.x - positionSliderX:get()), (screenSize.y - positionSliderY:get()), healthBarWidth, 47, 
                        (lerp(barColor2.r, barColor1.r, healthRatio) * 255), 
                        (lerp(barColor2.g, barColor1.g, healthRatio) * 255), 
                        (lerp(barColor2.b, barColor1.b, healthRatio) * 255), 
                        (lerp(barColor2.a, barColor1.a, healthRatio) * 255), 
                    barRoundingSlider:get())
                 end
            end
        end
    end
end)

