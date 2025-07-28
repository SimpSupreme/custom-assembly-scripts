local placeID = globals.place_id()
if not placeID then return end
if placeID ~= 12411473842 then
    http.get("https://raw.githubusercontent.com/SimpSupreme/custom-assembly-scripts/refs/heads/main/loaderScripts/"..placeID..".lua", function(v)
        local success,results = loadstring(v)()
        if success then
            results()
        end
    end)
elseif placeID == 12411473842 then
    print("Please load the pressure script when in-game <3")
end
print("Made by @SINpathy in the discord :3")
print("all scripts are open source, find them at https://github.com/SimpSupreme/custom-assembly-scripts")
