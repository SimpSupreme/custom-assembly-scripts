local keybind = ui.keybind("fuck")
cheat.set_callback("paint", function()
    if keybind:get() then
        for i = 0, 20 do
            input.click()
        end
    end
end)