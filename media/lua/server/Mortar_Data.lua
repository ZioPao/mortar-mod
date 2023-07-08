-- The server will contain a table containing the currently instanced mortars
local MODULE = 'Mortar-Data'
local MortarServerData = {}

function MortarServerData.GetModData()
    return MortarServerData.modData
end

function MortarServerData.SyncTable()
    ModData.transmit(MRT_COMMON.MOD_ID)
end

local OnUpdateGlobalModData = function(module, command, playerObj, args)
    --print("Mortar: Received command " .. command)
    if module ~= MODULE then return end

    if command == 'UpdateInstances' then
        --print("Running update instances")
        if MortarServerData == nil then return end
        if MortarServerData.GetModData() == nil then return end
        MortarServerData.GetModData()[args.id] = args.data
        ModData.add(MRT_COMMON.MOD_ID, MortarServerData.GetModData())
        ModData.transmit(MRT_COMMON.MOD_ID)
    end
end


Events.OnClientCommand.Add(OnUpdateGlobalModData)








-----------------------------

local function OnInitGlobalModData()
    MortarServerData.modData = ModData.getOrCreate(MRT_COMMON.MOD_ID)
    if MortarServerData.modData then
        for key, v in pairs(MortarServerData.modData) do
            print("MortarInfo: loading " .. tostring(key))
            print(v.tileX)
            print(v.tileY)
            print(v.tileZ)
            print(v.isRoundInChamber)
        end
    else
        MortarServerData.modData = {}
    end
end

Events.OnInitGlobalModData.Add(OnInitGlobalModData)

return MortarServerData
