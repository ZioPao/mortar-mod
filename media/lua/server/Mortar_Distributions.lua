require "Items/Distributions"
require "SuburbsDistributions"


local locations = {
  "ArmyHangarOutfit",
  "ArmyHangarTools",
  "ArmyStorageAmmunition",
  "ArmyStorageElectronics",
  "ArmyStorageGuns",
  "ArmyStorageOutfit",
  "ArmySurplusBackpacks",
  "ArmySurplusFootwear",
  "ArmySurplusHeadwear",
  "ArmySurplusMisc",
  "ArmySurplusOutfit",
  "ArmySurplusTools"
}
--print(type(locations[1]))
for i = 1, #locations do
	table.insert(ProceduralDistributions.list[locations[i]].items, "MortarRound")
	table.insert(ProceduralDistributions.list[locations[i]].items,  0.4)
	-- table.insert(ProceduralDistributions.list[locations[i]].items, "MortarBinoculars")
	-- table.insert(ProceduralDistributions.list[locations[i]].items,  0.1)
	table.insert(ProceduralDistributions.list[locations[i]].items, "MortarWeapon")
	table.insert(ProceduralDistributions.list[locations[i]].items,  0.08)
end

