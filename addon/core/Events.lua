local ADDON, MinArch = ...

local eventTimer = nil;
local histEventTimer = nil;

function MinArch:EventHelper(event, ...)
	if (event == "PLAYER_REGEN_DISABLED" and MinArch.db.profile.hideInCombat) then
		if (MinArchMain:IsVisible()) then
			MinArch:HideMain();
			MinArchMain.showAfterCombat = true;
		end
		if (MinArchHist:IsVisible()) then
			MinArch:HideHistory();
			MinArchHist.showAfterCombat = true;
		end
		if (MinArchDigsites:IsVisible()) then
			MinArch:HideDigsites();
			MinArchDigsites.showAfterCombat = true;
        end
        if (MinArch.Companion:IsVisible()) then
            MinArch.Companion:HideFrame();
            MinArch.Companion.showAfterCombat = true;
		end
	elseif (event == "PLAYER_REGEN_ENABLED") then
		if (MinArchMain.showAfterCombat) then
			MinArch:ShowMain();
			MinArchMain.showAfterCombat = false;
		end
		if (MinArchHist.showAfterCombat) then
			MinArch:ShowHistory();
			MinArchHist.showAfterCombat = false;
		end
		if (MinArchDigsites.showAfterCombat) then
			MinArch:ShowDigsites();
			MinArchDigsites.showAfterCombat = false;
        end
        if (MinArch.Companion.showAfterCombat) then
			MinArch.Companion:ShowFrame();
			MinArch.Companion.showAfterCombat = false;
		end
    end
end

local function RepositionDigsiteProgressBar()
    if ArcheologyDigsiteProgressBar and MinArch.db.profile.ProgressBar.attachToCompanion then
        -- UIPARENT_MANAGED_FRAME_POSITIONS["ArcheologyDigsiteProgressBar"] = nil;
        ArcheologyDigsiteProgressBar:ClearAllPoints();
        ArcheologyDigsiteProgressBar:SetPoint("BOTTOM", MinArchCompanion, "BOTTOM", 0, -35)
    end
end

function MinArch:EventMain(event, ...)
    MinArch:DisplayStatusMessage("EventMain: " .. event, MINARCH_MSG_DEBUG)
    -- RepositionDigsiteProgressBar()

	if (event == "CURRENCY_DISPLAY_UPDATE" and MinArch.HideNext == true) then
		MinArch:MaineEventHideAfterDigsite();
		return;
	elseif (event == "SKILL_LINES_CHANGED") then
		MinArch:UpdateArchaeologySkillBar();
	elseif ((event == "RESEARCH_ARTIFACT_DIG_SITE_UPDATED" or event == "ARTIFACT_DIGSITE_COMPLETE") and MinArch.db.profile.hideAfterDigsite == true) then
		MinArch.HideNext = true;
	elseif (event == "RESEARCH_ARTIFACT_COMPLETE" and MinArch.HideNext == true and MinArch.db.profile.waitForSolve == true) then
		MinArch:HideMain();
		MinArch.HideNext = false;

		--MinArchHist:RegisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
		--RequestArtifactCompletionHistory();
	elseif (event == "PLAYER_ALIVE" or event == "RESEARCH_ARTIFACT_COMPLETE") then
		--MinArchHist:RegisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
		--RequestArtifactCompletionHistory();
	elseif (event == "ADDON_LOADED" and MinArch ~= nil and MinArch.IsReady ~= true) then
		-- MinArch:MainEventAddonLoaded(); -- TODO remove this if everything checks out
	elseif (event == "ADDON_LOADED") then
		local addonname = ...;

		if (addonname == "Blizzard_ArchaeologyUI") then
			MinArchHist:UnregisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
		end
	elseif (event == "ARCHAEOLOGY_CLOSED") then
		MinArchHist:RegisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
	elseif (event == "PLAYER_ENTERING_WORLD") then
		if (MinArch.RacesLoaded == false) then
			MinArch:LoadRaceInfo();
		end
        MinArch:RefreshLDBButton(event);
        MinArch.Companion:AutoToggle()
	end

    if (event == "ARCHAEOLOGY_SURVEY_CAST" and MinArch.ShowOnSurvey == true) then
        if (_G.TomTom and MinArch.autoWaypoint) then
            _G.TomTom:RemoveWaypoint(MinArch.autoWaypoint);
        end
        MinArch:ClearUiWaypoint();

		if (MinArch.db.profile.autoShowOnSurvey) then
			MinArch:ShowMain();
			MinArch.ShowOnSurvey = false;
		end
	end
	if ((event == "PLAYER_STOPPED_MOVING" or event == "PLAYER_ENTERING_WORLD")) then
		if (MinArch.db.profile.autoShowInDigsites and MinArch:IsNearDigSite() and MinArch.ShowInDigsite == true) then
			MinArch:ShowMain();
			MinArch.ShowInDigsite = false;
        end

		return
	end

	if (event == "ARTIFACT_DIGSITE_COMPLETE") then
		MinArch.ShowOnSurvey = true;
        MinArch.ShowInDigsite = true;
        MinArch.CompanionShowInDigsite = true;
        MinArch.Companion:Hide();
	end

	if (event == "QUEST_LOG_UPDATE") then
		MinArch:ShowRaceIconsOnMap();
		return;
	end

	if (event == "CVAR_UPDATE") then
		local changedCVAR = ...;
		if (changedCVAR == "SHOW_DIG_SITES") then
			MinArch:ShowRaceIconsOnMap();
		end
	end

    if (event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA") then
        MinArch.Companion:AutoToggle()
		MinArch:RefreshLDBButton(event);
		return
	end

	if (event == "PLAYER_REGEN_ENABLED") then
		MinArchMain:UnregisterEvent("PLAYER_REGEN_ENABLED");
		MinArch:DisplayStatusMessage("Main update after combat", MINARCH_MSG_DEBUG);
	end

	if (MinArch.IsReady == true) then
		if (eventTimer ~= nil) then
			eventTimer:Cancel();
		end

        eventTimer = C_Timer.NewTimer(0.5, function()
			MinArch:UpdateMain();
            RequestArtifactCompletionHistory();
			eventTimer = nil;
		end)
    end
end

function MinArch:EventHist(event, ...)
    MinArch:DisplayStatusMessage("EventHist: " .. event, MINARCH_MSG_DEBUG)

	if (event == "RESEARCH_ARTIFACT_HISTORY_READY") or (event == "GET_ITEM_INFO_RECEIVED") then
		if (IsArtifactCompletionHistoryAvailable()) then
			local allGood = true
			for i = 1, ARCHAEOLOGY_NUM_RACES do
				allGood = MinArch:LoadItemDetails(i, event .. " {i=" .. i .. "}") and allGood
			end

			if allGood then
				-- all item info available, unregister this event
				MinArch:DisplayStatusMessage("Minimal Archaeology - All items are loaded now (" .. event .. ").", MINARCH_MSG_DEBUG)
				-- MinArchHist:UnregisterEvent(event)
				MinArchHist:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
			else
				-- not all item info available, try again when more details have been received
				MinArch:DisplayStatusMessage("Minimal Archaeology - Some items are not loaded yet (" .. event .. ").", MINARCH_MSG_DEBUG)
				-- MinArchHist:UnregisterEvent("RESEARCH_ARTIFACT_HISTORY_READY")
				MinArchHist:RegisterEvent("GET_ITEM_INFO_RECEIVED")
				return
			end

			for i = 1, ARCHAEOLOGY_NUM_RACES do
				MinArch:GetHistory(i, event .. " {i=" .. i .. "}");
			end
		else
            MinArch:DisplayStatusMessage("Minimal Archaeology - Artifact completion history is not available yet (" .. event .. ").", MINARCH_MSG_DEBUG)
            return;
		end
    end

    MinArch:DelayedHistoryUpdate()
end

function MinArch:EventDigsites(event, ...)
	if (event == "ARCHAEOLOGY_SURVEY_CAST") then
		local _, _, branchID = ...;
		local race = MinArch:GetRaceNameByBranchId(branchID);
		if (race ~= nil) then
			MinArch:UpdateActiveDigSitesRace(race);
			MinArch:CreateDigSitesList(MinArch:GetInternalContId());
			MinArch:CreateDigSitesList(MinArch:GetInternalContId());
		end
		return;
	elseif (event == "WORLD_MAP_UPDATE" and MinArch.IsReady == true) then
		MinArch:ShowRaceIconsOnMap();
		return;
	end

	-- TODO: internal events for updates
	MinArch:UpdateActiveDigSites();
	local ContID = MinArch:GetInternalContId();

	if (ContID ~= nil) then
		MinArch:CreateDigSitesList(ContID);
		MinArch:CreateDigSitesList(ContID);
	end

	if (event == "PLAYER_ENTERING_WORLD") then
		MinArch:RefreshDigsiteWaypoints();
	end

	if (--[[event == "ARTIFACT_DIGSITE_COMPLETE" or]] event == "RESEARCH_ARTIFACT_DIG_SITE_UPDATED") then
		if (MinArch.db.profile.TomTom.autoWayOnComplete) then
			MinArch:SetWayToNearestDigsite();
		end
	end

	if (event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA") then
		if (MinArch.db.profile.TomTom.autoWayOnMove) then
			MinArch:SetWayToNearestDigsite();
		end
	end
end

function MinArch:MaineEventHideAfterDigsite()
	-- TODO: fix hiding when multiple artifacts can be solved after each other
	if (MinArch.db.profile.waitForSolve == true) then
		local wait = false;
		for i=1,ARCHAEOLOGY_NUM_RACES do
			MinArch:UpdateArtifact(i);
			if (MinArch['artifacts'][i]['canSolve'] and MinArch.db.profile.raceOptions.hide[i] == false) then
				wait = true;
			end
		end

		if (wait == false) then
			MinArch:HideMain();
			MinArch.HideNext = false;
		end
	else
		MinArch:HideMain();
		MinArch.HideNext = false;
	end
end

function MinArch:MainEventAddonLoaded()
	-- Apply Settins/SavedVariables

	if (MinArchOptions['CurrentHistPage'] == nil) then
		MinArchOptions['CurrentHistPage'] = 1;
	end

	if (MinArch.db.profile.startHidden == true and not MinArch.overrideStartHidden) then
		MinArch:HideMain();
	end

	if (MinArch.db.char.WindowStates.main == false) then
		MinArch:HideMain();
	end

	if (MinArch.db.char.WindowStates.history == false or MinArch.db.profile.startHidden) then
		MinArch:HideHistory();
	end

	if (MinArch.db.char.WindowStates.digsites == false or MinArch.db.profile.startHidden) then
		MinArch:HideDigsites();
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
		MinArch:ShowRaceIconsOnMap()
	end
end

function MinArch:MapLayerChanged(self)
	-- update the map when map layer has changed
	if (self.mapID ~= nil) then
		if (WorldMapFrame.isMaximized) then
			C_Timer.After(0.11, function ()
				MinArch:ShowRaceIconsOnMap();
			end)
		else
			MinArch:ShowRaceIconsOnMap();
		end
	end
end
