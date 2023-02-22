


function MortarisCanShoot(cx,cy) 
	if NonPvpZone.getNonPvpZone(cx,cy) then return false end
	--if isBomberHasAmmo() then return false end
	--TODO check ammo return 
end


function MortarFloorTest(cx,cy)
	local cz = 8
	for i = 0, 8-1  do
		cz=cz-1
		local check = getCell():getGridSquare(cx, cy, cz )

		if check and check:isSolidFloor() then
			print(cz); print(check:isSolidFloor())	
			else
			print(cz); print(check)
		end
	end
end
--[[ 
--to test
MortarFloorTest(getPlayer():getX(), getPlayer():getY())
 ]]
 ------------------------               ---------------------------

function MortarGetHighestZ(cx,cy)
	local cz = 8
	for i = 0, 8-1  do
		cz=cz-1
		local check = getCell():getGridSquare(cx, cy, cz )

		if check and check:isSolidFloor() then
			print(cz); print(check:isSolidFloor())	
			return cz
		end
	end
end

--[[ 
--to test
MortarGetHighestZ(getPlayer():getX(), getPlayer():getY())
 ]]
 