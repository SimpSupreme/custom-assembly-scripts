-- Made by @acr in the Assembly discord, show them some support!!

local base_dir = "workspace\\"
os.execute("mkdir " .. base_dir)

local function fullpath(path)
    return base_dir .. path
end

function makefolder(path)
    os.execute("mkdir " .. fullpath(path))
end

function writefile(path, content)
    local f = io.open(fullpath(path), "w")
    if f then f:write(content) f:close() end
end

function appendfile(path, content)
    local f = io.open(fullpath(path), "a")
    if f then f:write(content) f:close() end
end

function readfile(path)
    local f = io.open(fullpath(path), "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
end

function isfile(path)
    local f = io.open(fullpath(path), "r")
    if f then f:close() return true end
    return false
end

function isfolder(path)
    local ok = os.execute("cd " .. fullpath(path) .. " >nul 2>nul")
    return ok == true or ok == 0
end

function delfile(path)
    os.remove(fullpath(path))
end

function delfolder(path)
    os.execute("rmdir /s /q " .. fullpath(path))
end

function loadfile(path)
    local f = readfile(path)
    if not f then return nil end
    return utils.loadstring(f)
end

function listfiles(path)
    local p = io.popen('dir /b /a:-d "' .. fullpath(path) .. '"')
    if not p then return {} end
    local files = {}
    for file in p:lines() do
        table.insert(files, file)
    end
    p:close()
    return files
end

function listfolders(path)
    local p = io.popen('dir /b /a:d "' .. fullpath(path) .. '"')
    if not p then return {} end
    local folders = {}
    for folder in p:lines() do
        table.insert(folders, folder)
    end
    p:close()
    return folders
end
