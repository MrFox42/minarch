-- Minimal Archaeology

local ADDON, _ = ...

local modules = {};

---@class MinArch : AceAddon, AceTimer-3.0
MinArch = LibStub("AceAddon-3.0"):NewAddon(ADDON, "AceTimer-3.0");

MinArch.HideNext = false;
MinArch.IsReady = false;
MinArch.ShowOnSurvey = true;
MinArch.ShowInDigsite = true;

MinArch.firstRun = true;
MinArch.artifacts = {};
MinArch.artifactbars = {};
MinArch.raceButtons = {};
MinArch.frame = {};
MinArch.ArchaeologyRaces = {};
MinArch.MapContinents = {};
MinArch.RacesLoaded = false;
MinArch.RelevantRaces = {};

-- Legacy compatibility
MinArchOptions = {};
MinArchOptions.ABOptions = {};

---@generic T
---@param name `T` @Module name
---@return T @Module reference
function MinArch:LoadModule(name)
    if (not modules[name]) then
        modules[name] = {};
        return modules[name]
    else
        return modules[name]
    end
end