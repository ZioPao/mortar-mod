--[[ -- for testing
function SpawnMortar()
	-- FIXME currently broken
	local pl = getPlayer()
	pl:getInventory():AddItems("Mortar.round", 5); --scriptnames has been change fyi
	local weapon = "Mortar.weapon"; if not pl:getInventory():contains(weapon) then pl:getInventory():AddItem(weapon); end
	local prop1 = "Base.WalkieTalkie5"; if not pl:getInventory():contains(prop1) then pl:getInventory():AddItem(prop1); end
	local prop2 = "Mortar.binoculars"; if not pl:getInventory():contains(prop2) then pl:getInventory():AddItem(prop2); end
end


 ]]

--TODO use this --    print(MortarRotation.tileobj[tostring(getPlayer():getDir())])
