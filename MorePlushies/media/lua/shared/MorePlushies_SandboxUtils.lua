--============================================================--
--               MorePlushies_SandboxUtils.lua               --
--============================================================--
-- Purpose:
--   Normalize and safely access MorePlushies SandboxVars.
--   Ensures consistent settings even if values are missing,
--   invalid, or misconfigured.
--
-- Responsibilities:
--   Clamp enums to valid ranges.
--   Normalize booleans and integers with explicit defaults.
--   Return a fully structured settings table for other systems.
--   Register OnInitGlobalModData hook for early availability.
--
-- Dependencies:
--   None. Reads SandboxVars directly.
--
--============================================================--

MorePlushies           = MorePlushies or {}
MorePlushies.SandboxUtils = MorePlushies.SandboxUtils or {}

function MorePlushies.SandboxUtils.getSafeSandboxVars()
    local function clampEnum(val, def, min, max)
        val = tonumber(val)
        if not val or val < min or val > max then return def end
        return val
    end

    local sv = SandboxVars.MorePlushies

    local result = {
        Loot = clampEnum(sv.Loot, 3, 1, 6),

        CommonPlushies      = sv.CommonPlushies ~= false,
        CommonPlushiesRates = tonumber(sv.CommonPlushiesRates) or 50,

        UncommonPlushies      = sv.UncommonPlushies ~= false,
        UncommonPlushiesRates = tonumber(sv.UncommonPlushiesRates) or 40,

        RarePlushies      = sv.RarePlushies ~= false,
        RarePlushiesRates = tonumber(sv.RarePlushiesRates) or 30,

        VeryRarePlushies      = sv.VeryRarePlushies == true,
        VeryRarePlushiesRates = tonumber(sv.VeryRarePlushiesRates) or 15,

        LocationsToy        = sv.LocationsToy ~= false,
        LocationsGeneral    = sv.LocationsGeneral ~= false,
        LocationsIncidental = sv.LocationsIncidental ~= false,
    }

    return result
end

function MorePlushies.SandboxUtils.get()
    return MorePlushies.SandboxUtils.getSafeSandboxVars()
end

function MorePlushies.SandboxUtils.loadSafeSandbox()
    MorePlushies.sv = MorePlushies.SandboxUtils.getSafeSandboxVars()
end

Events.OnInitGlobalModData.Add(MorePlushies.SandboxUtils.loadSafeSandbox)