local Value = 0xD8
local function fullpath(path)
    return "workspace\\" .. path
end

local function ValueCheck(toGet) 
    local memAddress = toGet:Address()
    if toGet:ClassName() == "StringValue" then
        return utils.read_memory("string", memAddress + Value)
    elseif toGet:ClassName() == "IntValue" then
        return utils.read_memory("int", memAddress + Value)
    elseif toGet:ClassName() == "BoolValue" then
        return utils.read_memory("bool", memAddress + Value)
    elseif toGet:ClassName() == "NumberValue" then
        return utils.read_memory("float", memAddress + Value)
    end
end

-- Ensure the output directory exists
os.execute("mkdir " .. fullpath(""))

-- File utility
local function writefile(path, content)
    local f = io.open(fullpath(path), "w")
    if f then f:write(content) f:close() end
end

-- Recursive dump function
local function dump_instance(instance, indent)
    local output = string.rep("  ", indent) .. instance:Name() .. " [" .. instance:ClassName() .. "]"

    -- Append value if it's a supported value type
    local className = instance:ClassName()
    if className == "StringValue" or className == "IntValue" or className == "BoolValue" or className == "NumberValue" then
        local val = ValueCheck(instance)
        if val ~= nil then
            output = output .. " = " .. tostring(val)
        end
    end

    output = output .. "\n"

    -- Dump children
    local children = instance:Children()
    for _, child in ipairs(children) do
        output = output .. dump_instance(child, indent + 1)
    end

    return output
end


-- Get the root of the hierarchy (workspace)
local root = globals.workspace()
local result = dump_instance(root, 0)

-- Write the result to a file
writefile("hierarchy_dump.txt", result)
