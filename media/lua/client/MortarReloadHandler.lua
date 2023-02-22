
 
function mortarReloader(item)  -- TODO checks if bomber
    local inv = getPlayer():getInventory()      
    --if item:getFullType() == "Mortar.MortarRound" then 
   if inv:getItemCountRecurse('Mortar.MortarRound') then
        getPlayer():playEmote("_mortarReload")         
        inv:getItemCountRecurse('Mortar.MortarRound');
        inv:DoRemoveItem(item);
        return true
    else
        getPlayer():Say(tostring('I have no ammo')) 
        return true
    end
end 

