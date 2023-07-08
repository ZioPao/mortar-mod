local MortarInstance = require("Mortar_Instance")

local MODULE = 'Mortar-Data'


-- Server only, client only, common
MortarDataHandler = {}

MORTAR_DATA_TABLE = {}


---Sync client global mod data with the server
---@param coords table
---@return MortarInstance
function MortarDataHandler.InitializeInstance(coords)
    print("Initialize instance")
    local id = MortarCommon.GetAssembledID(coords)

    local newData = {operatorID = -1, spotterID = -1, position = {x=coords.x, y=coords.y, z=coords.z}}
    MORTAR_DATA_TABLE[id] = newData
    local instance MortarInstance:new(MORTAR_DATA_TABLE[id])
    if isClient() then
        sendClientCommand(getPlayer(), MODULE, "UpdateInstances",
            { data = MORTAR_DATA_TABLE[id], id = id })
    end

    return instance
end
---Sync data with client and server. Modification from the client will be sent to the server
---@param id any
function MortarDataHandler.SyncData(id)
    print("Syncing Data for instance " .. tostring(id))
    ModData.request(MortarCommonVars.MOD_ID)
    local syncedTable = ModData.get(MortarCommonVars.MOD_ID)
    syncedTable[id] = MORTAR_DATA_TABLE[id]
    if isClient() then
        sendClientCommand(getPlayer(), MODULE, "UpdateInstances",
            { data = syncedTable[id], id = id })
    end
end

-- Gets the updated table from the server
function MortarDataHandler.ForceSync()
    ModData.request(MortarCommonVars.MOD_ID)
    MORTAR_DATA_TABLE = ModData.get(MortarCommonVars.MOD_ID)
end

---If it returns nil, it means that we need to wait a bit in the UI before showing everything.
---@param coords any
---@return table?
function MortarDataHandler.GetOrCreateInstance(coords)
    -- Fetch from global mod data
    local id = MortarCommon.GetAssembledID(coords)

    local modDataRef = MORTAR_DATA_TABLE
    local instance
    if modDataRef[id] then
        local dataTable = modDataRef[id]
        print("Found instance from Global Mod Data")
        -- We need to wrap it with MortarInstance
        instance = MortarInstance:new(dataTable)
    else
        print("Initializing new instance")
        instance = MortarDataHandler.InitializeInstance(coords)
    end

    return instance
end

function MortarDataHandler.GetInstance(id)
    if MORTAR_DATA_TABLE[id] then
        return MortarInstance:new(MORTAR_DATA_TABLE[id])
    end

    return nil
end

function MortarDataHandler.DestroyInstance(id)
    ModData.request(MortarCommonVars.MOD_ID)
    local syncedTable = ModData.get(MortarCommonVars.MOD_ID)
    syncedTable[id] = nil
    if isClient() then
        sendClientCommand(getPlayer(), MODULE, "UpdateInstances",
            { data = MORTAR_DATA_TABLE[id], id = id })
    end
end

Events.OnGameStart.Add(MortarDataHandler.ForceSync)

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
        CopyTable(MORTAR_DATA_TABLE, data)
    end

    --Update global mod data with local table (from global_mod_data.bin)
    ModData.add(MortarCommonVars.MOD_ID, MORTAR_DATA_TABLE)
end

Events.OnReceiveGlobalModData.Add(ReceiveGlobalModData)


return MortarDataHandler
