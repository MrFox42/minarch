local ADDON, _ = ...

---@type MinArchMain
local Main = MinArch:LoadModule("MinArchMain")
---@type MinArchDigsites
local Digsites = MinArch:LoadModule("MinArchDigsites")
---@type MinArchHistory
local History = MinArch:LoadModule("MinArchHistory")
---@type MinArchCompanion
local Companion = MinArch:LoadModule("MinArchCompanion")
---@type MinArchCommon
local Common = MinArch:LoadModule("MinArchCommon")
---@type MinArchLDB
local MinArchLDB = MinArch:LoadModule("MinArchLDB")
---@type MinArchNavigation
local Navigation = MinArch:LoadModule("MinArchNavigation")

local eventTimer = nil
local researchEventTimer = nil
local historyUpdateTimout = 0.3

function MinArch:EventHelper(event, ...)
	if event == "PLAYER_REGEN_DISABLED" then
		if MinArch.db.profile.hideInCombat then
			if (Main.frame:IsVisible()) then
				Main:HideWindow();
				Main.showAfterCombat = true;
			end
			if (History.frame:IsVisible()) then
				History:HideWindow();
				History.showAfterCombat = true;
			end
			if (Digsites.frame:IsVisible()) then
				Digsites:HideWindow();
				Digsites.showAfterCombat = true;
			end
		end
		if (event == "PLAYER_REGEN_DISABLED" and MinArch.db.profile.companion.hideInCombat) then
			if (Companion.frame:IsVisible()) then
				Companion:HideFrame();
				Companion.showAfterCombat = true;
			end
		end
	elseif (event == "PLAYER_REGEN_ENABLED") then
		if (Main.showAfterCombat) then
			Main:ShowWindow();
			Main.showAfterCombat = false;
		end
		if (History.showAfterCombat) then
			History:ShowWindow();
			History.showAfterCombat = false;
		end
		if (Digsites.showAfterCombat) then
			Digsites:ShowWindow();
			Digsites.showAfterCombat = false;
        end
        if (Companion.showAfterCombat) then
			Companion:ShowFrame();
			Companion.showAfterCombat = false;
		end
	elseif (event == "GLOBAL_MOUSE_DOWN") then
		MinArch:DblClick(...)
    end
end

local function RepositionDigsiteProgressBar()
    if ArcheologyDigsiteProgressBar and MinArch.db.profile.ProgressBar.attachToCompanion then
        -- UIPARENT_MANAGED_FRAME_POSITIONS["ArcheologyDigsiteProgressBar"] = nil;
        ArcheologyDigsiteProgressBar:ClearAllPoints();
        ArcheologyDigsiteProgressBar:SetPoint("BOTTOM", Companion.frame, "BOTTOM", 0, -35)
    end
end

function MinArch:EventMain(event, ...)
    Common:DisplayStatusMessage("EventMain: " .. event, MINARCH_MSG_DEBUG)
    -- RepositionDigsiteProgressBar()

	if (event == "CURRENCY_DISPLAY_UPDATE" and MinArch.HideNext == true) then
		MinArch:MaineEventHideAfterDigsite();
		return;
	elseif (event == "SKILL_LINES_CHANGED") then
		Main:UpdateArchaeologySkillBar();
	elseif ((event == "RESEARCH_ARTIFACT_DIG_SITE_UPDATED" or event == "ARTIFACT_DIGSITE_COMPLETE") and MinArch.db.profile.hideAfterDigsite == true) then
		MinArch.HideNext = true;
	elseif (event == "RESEARCH_ARTIFACT_COMPLETE" and MinArch.HideNext == true and MinArch.db.profile.waitForSolve == true) then
		Main:HideWindow();
		MinArch.HideNext = false;

		--History.frame:RegisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
		--RequestArtifactCompletionHistory();
	elseif (event == "PLAYER_ALIVE" or event == "RESEARCH_ARTIFACT_COMPLETE") then
		--History.frame:RegisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
		--RequestArtifactCompletionHistory();
	elseif (event == "ADDON_LOADED" and MinArch ~= nil and MinArch.IsReady ~= true) then
		-- MinArch:MainEventAddonLoaded(); -- TODO remove this if everything checks out
	elseif (event == "ADDON_LOADED") then
		local addonname = ...;

		if (addonname == "Blizzard_ArchaeologyUI") then
			--History.frame:UnregisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
		end
		if (addonname == "TomTom") then
			Navigation:SetTomTom()
		end
	elseif (event == "ARCHAEOLOGY_CLOSED") then
		--History.frame:RegisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
	elseif (event == "PLAYER_ENTERING_WORLD") then
		if (MinArch.RacesLoaded == false) then
			Common:LoadRaceInfo();
		end
        MinArchLDB:RefreshLDBButton();
        Companion:AutoToggle()
	end

	if (event == "PLAYER_REGEN_ENABLED") then
		C_Timer.NewTimer(0.3, function()
			if (not InCombatLockdown()) then
				ClearOverrideBindings(MinArch.hiddenButton);
			end
		end)
	end

    if (event == "ARCHAEOLOGY_SURVEY_CAST") then
        if MinArch.autoWaypoint then
			Navigation:RemoveTomTomWaypoint(MinArch.autoWaypoint)
        end
        Navigation:ClearUiWaypoint();

		if (MinArch.ShowOnSurvey == true and MinArch.db.profile.autoShowOnSurvey) then
			Main:ShowWindow();
			MinArch.ShowOnSurvey = false;
		end
	end
	if ((event == "PLAYER_STOPPED_MOVING" or event == "PLAYER_ENTERING_WORLD")) then
		if (MinArch.db.profile.autoShowInDigsites and Digsites:IsPlayerNearDigSite() and MinArch.ShowInDigsite == true) then
			Main:ShowWindow();
			MinArch.ShowInDigsite = false;
        end

		return
	end

	if (event == "ARTIFACT_DIGSITE_COMPLETE") then
		MinArch.ShowOnSurvey = true;
        MinArch.ShowInDigsite = true;
        Companion.showInDigsite = true;
		if not MinArch.db.profile.companion.alwaysShow then
        	Companion.frame:Hide();
		end
	end

	if (event == "QUEST_LOG_UPDATE") then
		Digsites:ShowRaceIconsOnMap();
		return;
	end

	if (event == "CVAR_UPDATE") then
		local changedCVAR = ...;
		if (changedCVAR == "SHOW_DIG_SITES") then
			Digsites:ShowRaceIconsOnMap();
		end

		return
	end

    if (event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA") then
        Companion:AutoToggle()
		MinArchLDB:RefreshLDBButton();
		return
	end

	if (event == "PLAYER_REGEN_ENABLED") then
		Main.frame:UnregisterEvent("PLAYER_REGEN_ENABLED");
		Common:DisplayStatusMessage("Main update after combat", MINARCH_MSG_DEBUG);
	end

	if (MinArch.IsReady == true) then
		if (eventTimer ~= nil) then
			eventTimer:Cancel();
		end

        eventTimer = C_Timer.NewTimer(0.5, function()
			Main:Update();
            -- RequestArtifactCompletionHistory();
			eventTimer = nil;
		end)
    end
end

function MinArch:EventHist(event, ...)
    Common:DisplayStatusMessage("EventHist: " .. event, MINARCH_MSG_DEBUG)

	if (event == "RESEARCH_ARTIFACT_HISTORY_READY") or (event == "GET_ITEM_INFO_RECEIVED") then
		if (IsArtifactCompletionHistoryAvailable()) then
			local allGood = true
			for i = 1, ARCHAEOLOGY_NUM_RACES do
				allGood = History:LoadItemDetails(i, event .. " {i=" .. i .. "}") and allGood
			end

			if allGood then
				-- all item info available, unregister this event
				Common:DisplayStatusMessage("Minimal Archaeology - All items are loaded now (" .. event .. ").", MINARCH_MSG_DEBUG)
				-- History.frame:UnregisterEvent(event)
				History.frame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
			else
				-- not all item info available, try again when more details have been received
				Common:DisplayStatusMessage("Minimal Archaeology - Some items are not loaded yet (" .. event .. ").", MINARCH_MSG_DEBUG)
				-- History.frame:UnregisterEvent("RESEARCH_ARTIFACT_HISTORY_READY")
				History.frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
				return
			end

			for i = 1, ARCHAEOLOGY_NUM_RACES do
				History:GetHistory(i, event .. " {i=" .. i .. "}");
			end
		else
            Common:DisplayStatusMessage("Minimal Archaeology - Artifact completion history is not available yet (" .. event .. ").", MINARCH_MSG_DEBUG)
            return;
		end

		History:DelayedUpdate()
    end

	if (event == "RESEARCH_ARTIFACT_COMPLETE") then
		local artifactName = ...;
		if (researchEventTimer ~= nil) then
			Common:DisplayStatusMessage("RESEARCH_ARTIFACT_COMPLETE called too frequent, delaying by " .. historyUpdateTimout .. " seconds", MINARCH_MSG_DEBUG)
			researchEventTimer:Cancel();
		end
		researchEventTimer = C_Timer.NewTimer(historyUpdateTimout, function()
			for RaceID, _ in pairs(MinArchHistDB) do
				for _, details in pairs(MinArchHistDB[RaceID]) do
					if (details.artifactname == artifactName) then
						if not MinArch.db.profile.raceOptions.keystone[RaceID] then
							MinArch.artifacts[RaceID].appliedKeystones = 0;
						end

						details.totalcomplete = details.totalcomplete + 1

						if (MinArch.artifacts[RaceID].project == artifactName) then
							MinArch.artifacts[RaceID].totalcomplete = details.totalcomplete
						end

    					return History:DelayedUpdate()
					end
				end
			end
		end)
	end
end

function MinArch:EventDigsites(event, ...)
	if (event == "ARCHAEOLOGY_SURVEY_CAST") then
		local _, _, branchID = ...;
		local race = Common:GetRaceNameByBranchId(branchID);
		if (race ~= nil) then
			Digsites:UpdateActiveDigSitesRace(race);
			Digsites:CreateDigSitesList(Common:GetInternalContId());
			Digsites:CreateDigSitesList(Common:GetInternalContId());
		end
		return;
	elseif (event == "WORLD_MAP_UPDATE" and MinArch.IsReady == true) then
		Digsites:ShowRaceIconsOnMap();
		return;
	end

	-- TODO: internal events for updates
	Digsites:UpdateActiveDigSites();
	local ContID = Common:GetInternalContId();

	if (ContID ~= nil) then
		Digsites:CreateDigSitesList(ContID);
		Digsites:CreateDigSitesList(ContID);
	end

	if (event == "PLAYER_ENTERING_WORLD") then
		Navigation:RefreshDigsiteWaypoints();
	end

	if (--[[event == "ARTIFACT_DIGSITE_COMPLETE" or]] event == "RESEARCH_ARTIFACT_DIG_SITE_UPDATED") then
		if (MinArch.db.profile.TomTom.autoWayOnComplete) then
			Navigation:SetWayToNearestDigsite();
		end
	end

	if (event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA") then
		if (MinArch.db.profile.TomTom.autoWayOnMove) then
			Navigation:SetWayToNearestDigsite();
		end
	end

	if (event == "TAXIMAP_OPENED") then
		Digsites:UpdateFlightMap()
	end

	if event == "PLAYER_CONTROL_GAINED" and Navigation.waypointOnLanding then
		Navigation.waypointOnLanding = false
		Navigation:SetWayToNearestDigsite(true)
	end
end

function MinArch:MaineEventHideAfterDigsite()
	-- TODO: fix hiding when multiple artifacts can be solved after each other
	if (MinArch.db.profile.waitForSolve == true) then
		local wait = false;
		for i=1,ARCHAEOLOGY_NUM_RACES do
			History:UpdateArtifact(i);
			if (MinArch['artifacts'][i]['canSolve'] and MinArch.db.profile.raceOptions.hide[i] == false) then
				wait = true;
			end
		end

		if (wait == false) then
			Main:HideWindow();
			MinArch.HideNext = false;
		end
	else
		Main:HideWindow();
		MinArch.HideNext = false;
	end
end

function MinArch:MainEventAddonLoaded()
	-- Apply Settins/SavedVariables

	if (MinArchOptions['CurrentHistPage'] == nil) then
		MinArchOptions['CurrentHistPage'] = ARCHAEOLOGY_RACE_OTHER + 1;
	end

	if (MinArch.db.profile.startHidden == true and not MinArch.overrideStartHidden) then
		Main:HideWindow();
	end

	if (MinArch.db.char.WindowStates.main == false) then
		Main:HideWindow();
	end

	if (MinArch.db.char.WindowStates.history == false or MinArch.db.profile.startHidden) then
		History:HideWindow();
	end

	if (MinArch.db.char.WindowStates.digsites == false or MinArch.db.profile.startHidden) then
		Digsites:HideWindow();
	end

	-- discard old unknown digsites
	local name
	if MinArchDigsitesGlobalDB then
	    for i=1,ARCHAEOLOGY_NUM_CONTINENTS do

		-- populate missing continents immediately
		if MinArchDigsitesGlobalDB["continent"][i] == nil then
			MinArchDigsitesGlobalDB["continent"][i] = {}
		end

		for name,_ in pairs(MinArchDigsitesGlobalDB['continent'][i]) do
			if (MinArchDigsitesGlobalDB['continent'][i][name]['zone'] == 'Unknown' or MinArchDigsitesGlobalDB['continent'][i][name]['zone'] == 'See Map') then
				MinArchDigsitesGlobalDB['continent'][i][name] = nil
			end
		end
	    end
	end
end

function MinArch:TrackingChanged(self)
	-- update the map if digsites tracking has changed
	if (self.value == "digsites") then
		Digsites:ShowRaceIconsOnMap()
	end
end

function MinArch:MapLayerChanged(self)
	-- update the map when map layer has changed
	-- print(self.mapID)
	if (self.mapID ~= nil) then
		C_Timer.After(0.11, function ()
			Digsites:ShowRaceIconsOnMap()
		end)
	end
end
