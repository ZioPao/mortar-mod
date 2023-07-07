local MortarData = {}

function MortarData.GetModData()
    return MortarData.modData
end

function MortarData.SyncTable()
    ModData.transmit(MortarCommonVars.MOD_ID)
end



-----------------------------

local function OnInitGlobalModData()
	MortarData.modData = ModData.getOrCreate(MortarCommonVars.MOD_ID)
    if MortarData.modData then
        for key, v in pairs(MortarData.modData) do
            print("MortarInfo: loading " .. tostring(key))
            print(v.tileX)
            print(v.tileY)
            print(v.tileZ)
            print(v.isRoundInChamber)
        end
    else
        MortarData.modData = {}
    end
end

Events.OnInitGlobalModData.Add(OnInitGlobalModData)

return MortarData