-- Minimal Archaeology

local ADDON, MinArch = ...

MinArch.Ace = LibStub("AceAddon-3.0"):NewAddon(ADDON, "AceTimer-3.0");

MinArch.HideNext = false;
MinArch.IsReady = false;
MinArch.ShowOnSurvey = true;
MinArch.ShowInDigsite = true;
MinArch.CompanionShowInDigsite = true;

MinArch.firstRun = true;
MinArch.artifacts = {};
MinArch.artifactbars = {};
MinArch.barlinks = {};
MinArch.raceButtons = {};
MinArch.frame = {};
MinArch.ArchaeologyRaces = {};
MinArch.MapContinents = {};
MinArch.RacesLoaded = false;
MinArch.RelevantRaces = {};

-- Legacy compatibility
MinArchOptions = {};
MinArchOptions.ABOptions = {};
