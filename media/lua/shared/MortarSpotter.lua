
--- Check if the found player is acceptable as a spotter
---@param spotter IsoPlayer
Mortar.CheckPlayerForWalkieTalkie = function(player)

    local accepted_item = "Radio.WalkieTalkie"

    -- TODO Should check even the belt?
    local primary_hand_item = player:getPrimaryHandItem()
    local secondary_hand_item = player:getSecondaryHandItem()


    if primary_hand_item then
        local primary_item_type = primary_hand_item:getFullType()

        if string.find(primary_item_type,accepted_item) then
            return true
        end

    elseif secondary_hand_item then
        local secondary_item_type = secondary_hand_item:getFullType()

        if string.find(secondary_item_type, accepted_item) then
            return true
        end
    end

    return false


end


