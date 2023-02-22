
 
function mortarReloader(item)  -- TODO checks if bomber
    if item:getFullType() == "Mortar.MortarRound" then 
        getPlayer():playEmote("_mortarReload") 
        return true
    end
end 

