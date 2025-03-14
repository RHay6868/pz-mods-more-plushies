require 'Items/ProceduralDistributions'

MorePlushies = MorePlushies or {};

--Dristribution Function
function MorePlushies:addDistributions(itemsAndChances, locations)
	for item, chance in pairs(itemsAndChances)
	do
		for i, location in ipairs(locations)
		do
			if ProceduralDistributions.list[location] and ProceduralDistributions.list[location].items
			then
				table.insert(ProceduralDistributions.list[location].items, item);
				table.insert(ProceduralDistributions.list[location].items, chance);
			end
		end
	end
end

--Spawnrates attached to the available options
local sBVars = SandboxVars.MorePlushies
local SpawnRateLow = sBVars.SpawnRate * sBVars.Loot * 0.0001;
local SpawnRateMid = sBVars.SpawnRate * sBVars.Loot * 0.0003;
local SpawnRateHigh = sBVars.SpawnRate * sBVars.Loot * 0.0005;

local plushies = {
    "Base.PigPlushie",
    "Base.AxolotlPlushie",
    "Base.RoyalePlushie",
    "Base.BioPlushie",
    "Base.BatmanPlushie",
    "Base.StitchesPlushie",
    "Base.ChocobiPlushie",
    "Base.GrebdiozPlushie",
    "Base.DeathBeePlushie",
    "Base.GroguPlushie",
    "Base.MiniMoosePlushie",
    "Base.CactuarPlushie",
    "Base.MogPlushie",
    "Base.ReiPlushie",
    "Base.PochitaPlushie",
    "Base.DaveMinionPlushie",
    "Base.UddersPlushie",
    "Base.GnomeAmericanPlushie",
    "Base.ShredderPlushie",
    "Base.SplinterPlushie",
    "Base.LeonardoPlushie",
    "Base.RaphaelPlushie",
    "Base.DonatelloPlushie",
    "Base.MichelangeloPlushie",
    "Base.PinkKittenPlushie",
    "Base.FloppyPlushie",
    "Base.GoatPlushie",
    "Base.UnicornPlushie",
    "Base.TurtlePlushie",
    "Base.OtterPlushie",
    "Base.Porg1Plushie",
    "Base.Porg2Plushie",
    "Base.Ewok1Plushie",
    "Base.Ewok2Plushie",
    "Base.MikeWazowskiPlushie",
    "Base.SullyPlushie",
    "Base.StitchPlushie",
    "Base.HexDollPlushie",
    "Base.MurderMonkeyPlushie",
    "Base.PuarPlushie",
    "Base.PiranhaPlushie"
}

local function addPlushiesWithLowSpawnRate(plushies, SpawnRateLow)
    local plushiesAndChances = {}
    for _, plushie in ipairs(plushies) do
        plushiesAndChances[plushie] = SpawnRateLow
    end
    MorePlushies:addDistributions(plushiesAndChances, {
        "KitchenRandom",
    });
end


local function addPlushiesWithMidSpawnRate(plushies, SpawnRateMid)
    local plushiesAndChances = {}
    for _, plushie in ipairs(plushies) do
        plushiesAndChances[plushie] = SpawnRateMid
    end
    MorePlushies:addDistributions(plushiesAndChances, {
        "ClassroomMisc",
        "CrateRandomJunk",
        "DaycareCounter",
        "DaycareShelves",
        "GigamartSchool",
    });
end

local function addPlushiesWithHighSpawnRate(plushies, SpawnRateHigh)
    local plushiesAndChances = {}
    for _, plushie in ipairs(plushies) do
        plushiesAndChances[plushie] = SpawnRateHigh
    end
    MorePlushies:addDistributions(plushiesAndChances, {
        "CrateToys",
        "GigamartToys",
        "PrisonCellRandom",
        "WardrobeChild",
    });
end

addPlushiesWithLowSpawnRate(plushies, SpawnRateLow)
addPlushiesWithMidSpawnRate(plushies, SpawnRateMid)
addPlushiesWithHighSpawnRate(plushies, SpawnRateHigh)