require "Items/Distributions"
require "Items/table.insert(ProceduralDistributions"
require"SuburbsDistributions"


local locations = {
  "ArmyHangarOutfit",
  "ArmyHangarTools",
  "ArmyStorageAmmunition",
  "ArmyStorageElectronics",
  "ArmyStorageGuns",
  --"ArmyStorageMedical",
  "ArmyStorageOutfit",
  "ArmySurplusBackpacks",
  "ArmySurplusFootwear",
  "ArmySurplusHeadwear",
  "ArmySurplusMisc",
  "ArmySurplusOutfit",
  "ArmySurplusTools"
}
print(type(locations[1]))
for i = 1, #locations do
	table.insert(ProceduralDistributions.list[locations[i]].items, "Mortar.round")
	table.insert(ProceduralDistributions.list[locations[i]].items,  0.4)
	table.insert(ProceduralDistributions.list[locations[i]].items, "Mortar.binoculars")
	table.insert(ProceduralDistributions.list[locations[i]].items,  0.1)
	table.insert(ProceduralDistributions.list[locations[i]].items, "Mortar.weapon")
	table.insert(ProceduralDistributions.list[locations[i]].items,  0.08)
end

