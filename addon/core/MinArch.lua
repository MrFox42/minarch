-- Minimal Archaeology

local ADDON, _ = ...

local modules = {};

---@class MinArch : AceAddon, AceTimer-3.0
MinArch = LibStub("AceAddon-3.0"):NewAddon(ADDON, "AceTimer-3.0");

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

---@type MinArchMain
local Main = MinArch:LoadModule("MinArchMain")
---@type MinArchDigsites
local Digsites = MinArch:LoadModule("MinArchDigsites")
---@type MinArchHistory
local History = MinArch:LoadModule("MinArchHistory")
---@type MinArchCommon
local Common = MinArch:LoadModule("MinArchCommon")
---@type MinArchOptions
local Options = MinArch:LoadModule("MinArchOptions")

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
MinArch.hiddenButton = nil
MinArch.DigsiteLocales = {}
MinArch.defaults = {}

-- Legacy compatibility
MinArchOptions = {};
MinArchOptions.ABOptions = {};

function MinArch:OpenWindow(button)
	if (button == "LeftButton") then
		local shiftKeyIsDown = IsShiftKeyDown();
		local ctrlKeyIsDown = IsControlKeyDown();
		local altKeyDown = IsAltKeyDown();

		if shiftKeyIsDown then
			History:ToggleWindow();
		elseif ctrlKeyIsDown then
			Digsites:ToggleWindow();
		else
			if (Main.frame:IsVisible()) then
				Main:HideWindow();
				if (altKeyDown) then
					History:HideWindow();
					Digsites:HideWindow();
				end
			else
				Main:ShowWindow();
				MinArch.HideNext = false;
			end
		end

	elseif (button == "RightButton") then
		Common:OpenSettings(Options.menu);
	end
end
