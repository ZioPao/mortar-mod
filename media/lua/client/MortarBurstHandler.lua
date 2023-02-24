
--getPlayer():playEmote("_MortarIdle") 
--getPlayer():playEmote("_MortarClick") 


MortartBurstTiles = {
"mortarburst_0",
"mortarburst_1",
"mortarburst_2",
"mortarburst_3",
"mortarburst_4",
"mortarburst_5",
"mortarburst_6",
"mortarburst_7",
"mortarburst_8",
"mortarburst_9",
"mortarburst_10",
"mortarburst_11",
"mortarburst_12",
"mortarburst_13",
"mortarburst_14"
}
--[[ for i = 1, #MortartBurstTiles do 
    print(MortartBurstTiles[i])
end ]]

local function destroyTile(obj)
	if isClient() then
		sledgeDestroy(obj)
	else
		obj:getSquare():transmitRemoveItemFromSquare(obj)
	end
end

function BurstTicker(mortar, count ,ticks, square)


	-- TODO We can't pass this through OnTick right now, we'd need some global tables to address sq and mortar and count


	ticks = ticks - 1
	if ticks <= 0 then 
	ticks = 12 
	count = count + 1
	end

	if ticks % 3 then
		if count == 14 then
			destroyTile(mortar)
			   -- the tile starts at 0 and ends 64 -8 (8  mortar tiles)
			local dug = IsoObject.new(square, "mortar_" .. ZombRand(63)-8, "", false) 	-- TODO This is already implemented in the generateShot func
			square:AddTileObject(dug)
			if isClient() then
				dug:transmitCompleteItemToServer()
			end
			ISInventoryPage.dirtyUI()
			Events.OnTick.Remove(BurstTicker) 
		end


		local newtile = MortartBurstTiles[tostring(count)]
		mortar:setSprite(newtile)
		mortar:getSprite():setName(newtile)

		mortar:transmitUpdatedSpriteToServer()
		mortar:transmitUpdatedSpriteToClients()
		--mortar:transmitCompleteItemToServer()
		getPlayerLoot(0):refreshBackpacks()
		ISInventoryPage.dirtyUI()

		count = count + 1
		getPlayer():setHaloNote(tostring(ticks),100,100,200,100) --debug only delete later
	end
end


--[[ 

Events.OnTick.Remove(BurstTicker)
Events.OnTick.Add(BurstTicker)
]]
