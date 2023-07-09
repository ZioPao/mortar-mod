-- The server will contain a table containing the currently instanced mortars
local MortarServerData = {}

function MortarServerData.GetModData()
    return MortarServerData.modData
end

function MortarServerData.SyncTable()
    ModData.transmit(MRT_COMMON.GLOBAL_MOD_DATA)
end

local OnUpdateGlobalModData = function(module, command, _, args)
    if module ~= MRT_COMMON.GLOBAL_MOD_DATA then return end
    if command == 'UpdateInstances' then
        if MortarServerData == nil then return end
        if MortarServerData.GetModData() == nil then return end
        MortarServerData.GetModData()[args.id] = args.data
        ModData.add(MRT_COMMON.GLOBAL_MOD_DATA, MortarServerData.GetModData())
        ModData.transmit(MRT_COMMON.GLOBAL_MOD_DATA)
    end
end


Events.OnClientCommand.Add(OnUpdateGlobalModData)

-----------------------------

local function OnInitGlobalModData()
    MortarServerData.modData = ModData.getOrCreate(MRT_COMMON.GLOBAL_MOD_DATA)
    if MortarServerData.modData then
        for key, v in pairs(MortarServerData.modData) do
            print("MortarInfo: loading " .. tostring(key))
            --print(v.tileX)
            --print(v.tileY)
            --print(v.tileZ)
            --print(v.isRoundInChamber)
        end
    else
        MortarServerData.modData = {}
    end
end

Events.OnInitGlobalModData.Add(OnInitGlobalModData)

return MortarServerData
