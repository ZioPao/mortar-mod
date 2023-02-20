require "MortarTileRotation"

MortarUse = {}

function MortarUse.setBomber(player)
--TODO for the animation and the movement prevent thing
--player:setIgnoreMovement(true) 
--probably a timed action would be better 
--player:getInventory():Remove("Mortar.round")
end



function MortarUse.context(player, context, worldobjects, test)
	local sq = nil
    for i,v in ipairs(worldobjects) do
        local square = v:getSquare();
        if square and sq == nil then
            sq = square
        end
        --instanceof(v, "IsoObject") and
        if player:getInventory():contains("Mortar.round") then
			if v:getSprite() and MortarRotation.isMortar(v:getSprite():getName()) then
				context:addOption("Interact: Mortar"..v:getSprite():getName(), v, function() MortarUse.setBomber(player) end)
				break
			end
		end
    end
end
Events.OnFillWorldObjectContextMenu.Remove(MortarUse.context);
Events.OnFillWorldObjectContextMenu.Add(MortarUse.context);


    