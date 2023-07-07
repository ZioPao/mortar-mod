local MortarInstance = require("Mortar_Instance")

local MortarClientData = {}
MortarClientData.table = {}

---Sync client global mod data with the server
---@param id string
function MortarClientData.InitializeInstance(coords)
    print("Initialize instance")
    local id = tostring(coords.x) .. tostring(coords.y) .. tostring(coords.z)
    MortarClientData.table[id] = MortarInstance:new(-1, -1, coords)
    if isClient() then
        sendClientCommand(getPlayer(), MortarCommonVars.MOD_ID, "UpdateInstances ",
            { data = MortarClientData.table[id], id = id })
    end
end

function MortarClientData.SyncData(id)
    ModData.request(MortarCommonVars.MOD_ID)
    local syncedTable = ModData.get(MortarCommonVars.MOD_ID)
    syncedTable[id] = MortarClientData.table[id]
    if isClient() then
        sendClientCommand(getPlayer(), MortarCommonVars.MOD_ID, "UpdateInstances ",
            { data = MortarClientData.table[id], id = id })
    end
end

---If it returns nil, it means that we need to wait a bit in the UI before showing everything.
---@param coords any
---@return table?
function MortarClientData.GetOrCreateInstance(coords)
    -- Fetch from global mod data
    local id = tostring(coords.x) .. tostring(coords.y) .. tostring(coords.z)
    if MortarClientData.table[id] then
        return MortarClientData.table[id]
    else
        MortarClientData.InitializeInstance(coords)
        return nil
    end
end

function MortarClientData.GetInstance(id)
    if MortarClientData.table[id] then
        return MortarClientData.table[id]
    end

    return nil
end

function MortarClientData.DestroyInstance(id)
    ModData.request(MortarCommonVars.MOD_ID)
    local syncedTable = ModData.get(MortarCommonVars.MOD_ID)
    syncedTable[id] = nil
    if isClient() then
        sendClientCommand(getPlayer(), MortarCommonVars.MOD_ID, "UpdateInstances ",
            { data = MortarClientData.table[id], id = id })
    end
end

---------------------
local function CopyTable(tableA, tableB)
    if not tableA or not tableB then
        return
    end
    for key, value in pairs(tableB) do
        tableA[key] = value
    end
    for key, _ in pairs(tableA) do
        if not tableB[key] then
            tableA[key] = nil
        end
    end
end

local function ReceiveGlobalModData(key, data)
    --print("Received global mod data")
    if key == MortarCommonVars.MOD_ID then
        --Creating a deep copy of recieved data and storing it in local store CLIENT_GLOBALMODDATA table
        CopyTable(MortarClientData.table, data)
    end

    --Update global mod data with local table (from global_mod_data.bin)
    ModData.add(MortarCommonVars.MOD_ID, MortarClientData.table)
end

Events.OnReceiveGlobalModData.Add(ReceiveGlobalModData)


return MortarClientData
