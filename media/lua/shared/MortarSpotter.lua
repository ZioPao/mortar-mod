
--- Check if the found player is acceptable as a spotter
---@param spotter IsoPlayer
Mortar.CheckPlayerForWalkieTalkie = function(player)
    -- TODO let's clean it up later

    return true


    --local accepted_item = "Radio.WalkieTalkie" --we should check for tags to get all the radio items not just one thing. we can you type radio
    --
    ---- TODO Should check even the belt? -
    --------------------------               ---------------------------
    --local function isEquippedOrAttached(player, item)
	--return playerObj:isEquipped(item) or playerObj:isAttachedItem(item)
    --end
    --
    ---- TODO right hand should walkie and left hand should be binoculars
    ---- i think this will work  might not need to check if equipped ive done this before, but i didnt need to equip the items that time
    ---- isActivated
    --
    --
    --
    --
    --
    --
    --
    --local inv = player:getInventory()
    ----if inv:contains('Mortar.binoculars') then
    --
    ----if item:canBeActivated() then
    ----getPlayer():setPrimaryHandItem()
    ----item:setActivated(true) --turns it on
    --
    ---- Pao: you can't use getPlayer here, we're in shared, no man lands
    --
    ---- TODO Rework this
    --return true --this is a cher and should probably be outside this function
    --
    ----if item:isEquipped() and item:isActivated() and getPlayer():getPrimaryHandItem() == item then
    --end
    --
    --------------------------               ---------------------------
    ---- TODO if it doesnt find the inventory radio consider ham radio too -
    --    local radio = nil;
	--	for i=0,sq:getObjects():size() - 1 do
	--		local item = sq:getObjects():get(i);
	--		if instanceof(item, "IsoRadio") then
	--			radio = item;
	--			break;
	--		end
	--	end
	--	radio:getDeviceData():setIsTurnedOn(true);
    --------------------------               ---------------------------
    --local primary_hand_item = player:getPrimaryHandItem()
    --local secondary_hand_item = player:getSecondaryHandItem()
    --
    --
    --if primary_hand_item then
    --    local primary_item_type = primary_hand_item:getFullType()
    --
    --    if string.find(primary_item_type,accepted_item) then
    --        return true
    --    end
    --
    --elseif secondary_hand_item then
    --    local secondary_item_type = secondary_hand_item:getFullType()
    --
    --    if string.find(secondary_item_type, accepted_item) then
    --        return true
    --    end
    --end
    --
    --return false
    --

end


