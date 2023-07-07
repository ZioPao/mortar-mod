local MortarInstance = require("Mortar_Instance")

local MODULE = 'Mortar-Data'


-- Server only, client only, common
MortarDataHandler = {}
MortarDataHandler.table = {}

---Sync client global mod data with the server
---@param coords table
function MortarDataHandler.InitializeInstance(coords)
    print("Initialize instance")
    local id = MortarCommonFunctions.GetAssembledID(coords)

    local newData = {operatorID = -1, spotterID = -1, coords = coords}
    MortarDataHandler.table[id] = MortarInstance:new(newData)
    if isClient() then
        sendClientCommand(getPlayer(), MODULE, "UpdateInstances",
            { data = MortarDataHandler.table[id], id = id })
    end
end

function MortarDataHandler.SyncData(id)
    ModData.request(MortarCommonVars.MOD_ID)
    local syncedTable = ModData.get(MortarCommonVars.MOD_ID)
    syncedTable[id] = MortarDataHandler.table[id]
    if isClient() then
        sendClientCommand(getPlayer(), MODULE, "UpdateInstances",
            { data = MortarDataHandler.table[id], id = id })
    end
end

-- Gets the updated table from the server
function MortarDataHandler.ForceSync()
    ModData.request(MortarCommonVars.MOD_ID)
    MortarDataHandler.table = ModData.get(MortarCommonVars.MOD_ID)
end

---If it returns nil, it means that we need to wait a bit in the UI before showing everything.
---@param coords any
---@return table?
function MortarDataHandler.GetOrCreateInstance(coords)
    -- Fetch from global mod data
    local id = tostring(coords.x) .. tostring(coords.y) .. tostring(coords.z)
    if MortarDataHandler.table[id] then
        -- We need to wrap it with MortarInstance
        return MortarInstance.WrapData(MortarDataHandler.table[id])

        --return MortarDataHandler.table[id]
    else
        MortarDataHandler.InitializeInstance(coords)
        return nil
    end
end

function MortarDataHandler.GetInstance(id)
    if MortarDataHandler.table[id] then
        return MortarInstance:new(MortarDataHandler.table[id])
    end

    return nil
end

function MortarDataHandler.DestroyInstance(id)
    ModData.request(MortarCommonVars.MOD_ID)
    local syncedTable = ModData.get(MortarCommonVars.MOD_ID)
    syncedTable[id] = nil
    if isClient() then
        sendClientCommand(getPlayer(), MODULE, "UpdateInstances",
            { data = MortarDataHandler.table[id], id = id })
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
    print("Received global mod data")
    if key == MortarCommonVars.MOD_ID then
        --Creating a deep copy of recieved data and storing it in local store CLIENT_GLOBALMODDATA table
        CopyTable(MortarDataHandler.table, data)
    end

    --Update global mod data with local table (from global_mod_data.bin)
    ModData.add(MortarCommonVars.MOD_ID, MortarDataHandler.table)
end

Events.OnReceiveGlobalModData.Add(ReceiveGlobalModData)


return MortarDataHandler
