local placeID = globals.place_id()
if not placeID then return end
local supportedPlaceIDs = {12552538292, 18259975825}

local gameSet = {}
for _, name in pairs(supportedPlaceIDs) do
    gameSet[name] = true
end

if gameSet[placeID] then
    http.get("https://raw.githubusercontent.com/SimpSupreme/custom-assembly-scripts/refs/heads/main/loaderScripts/"..placeID..".lua", function(v)
        local success,results = loadstring(v)()
        if success then
            results()
        end
    end)
elseif placeID == 12411473842 then
    print("Please load the pressure script when in-game <3")
elseif placeID == 0 then
    print("Please unload the script and load it again when in a game <3")
else
    print("this game isn't supported :(")
end
print("Made by @SINpathy in the discord :3")
print("all scripts are open source, find them at https://github.com/SimpSupreme/custom-assembly-scripts")
