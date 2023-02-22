
 
function mortarReloader()  -- TODO checks if bomber
    local inv = getPlayer():getInventory()      
    --if item:getFullType() == "Mortar.MortarRound" then 
    local item = inv:getItemCountRecurse('Mortar.MortarRound');
   if item and inv then
        getPlayer():playEmote("_mortarReload")       
        inv:DoRemoveItem(item);
        return true
    else
        getPlayer():Say(tostring('I have no ammo')) 
        return true
    end
end 

