local eventTimer = nil;

function MinArch:EventMain(event, ...)
	if (event == "CURRENCY_DISPLAY_UPDATE" and MinArchHideNext == true) then
		MinArch:MaineEventHideAfterDigsite();
	elseif (event == "SKILL_LINES_CHANGED") then
		MinArch:UpdateArchaeologySkillBar();
	elseif ((event == "RESEARCH_ARTIFACT_DIG_SITE_UPDATED" or event == "ARTIFACT_DIGSITE_COMPLETE") and MinArch.db.profile.hideAfterDigsite == true) then
		MinArchHideNext = true;
	elseif (event == "RESEARCH_ARTIFACT_COMPLETE" and MinArchHideNext == true and MinArch.db.profile.waitForSolve == true) then
		MinArch:HideMain();
		MinArchHideNext = false;
		
		MinArchHist:RegisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
		RequestArtifactCompletionHistory();
	elseif (event == "PLAYER_ALIVE" or event == "RESEARCH_ARTIFACT_COMPLETE") then
		MinArchHist:RegisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
		RequestArtifactCompletionHistory();
	elseif (event == "ADDON_LOADED" and MinArch ~= nil and MinArchIsReady ~= true) then
		-- MinArch:MainEventAddonLoaded(); -- TODO remove this if everything checks out
	elseif (event == "ADDON_LOADED") then
		local addonname = ...;
		
		if (addonname == "Blizzard_ArchaeologyUI") then
			MinArchMain:UnregisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
		end
		
	elseif (event == "ARCHAEOLOGY_CLOSED") then
		MinArchMain:RegisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
	elseif (event == "PLAYER_ENTERING_WORLD") then
		if (MinArch.RacesLoaded == false) then
			MinArch:LoadRaceInfo();
		end
		MinArch:RefreshLDBButton(event);
	end

	if (event == "ARCHAEOLOGY_SURVEY_CAST" and MinArchShowOnSurvey == true) then
		if (MinArch.db.profile.autoShowOnSurvey) then
			MinArch:ShowMain();
			MinArchShowOnSurvey = false;
		end
	end
	if ((event == "PLAYER_STOPPED_MOVING" or event == "PLAYER_ENTERING_WORLD") and MinArchShowInDigsite == true) then
		if (MinArch.db.profile.autoShowInDigsites and MinArch:IsNearDigSite(5)) then
			MinArch:ShowMain();
			MinArchShowInDigsite = false;
		end
		return
	end

	if (event == "ARTIFACT_DIGSITE_COMPLETE") then
		MinArchShowOnSurvey = true;
		MinArchShowInDigsite = true;
	end

	if (event == "QUEST_LOG_UPDATE") then
		MinArch:ShowRaceIconsOnMap(MinArch['activeUiMapID']);
	end

	if (event == "CVAR_UPDATE") then
		local changedCVAR = ...;
		if (changedCVAR == "SHOW_DIG_SITES") then
			MinArch:ShowRaceIconsOnMap(MinArch['activeUiMapID']);
		end
	end

	if (event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA") then
		MinArch:RefreshLDBButton(event);
		return
	end

	if (MinArchIsReady == true) then
		if (eventTimer ~= nil) then
			eventTimer:Cancel();
		end

		eventTimer = C_Timer.NewTimer(0.5, function()
			MinArch:UpdateMain();
			MinArch:RefreshLDBButton();
			eventTimer = nil;
		end)
	end
end

function MinArch:EventHist(event, ...)
	if (event == "RESEARCH_ARTIFACT_HISTORY_READY") or (event == "GET_ITEM_INFO_RECEIVED") then
		if (IsArtifactCompletionHistoryAvailable()) then
			local allGood = true
			for i = 1, ARCHAEOLOGY_NUM_RACES do
				allGood = MinArch:LoadItemDetails(i, event .. " {i=" .. i .. "}") and allGood
			end

			if allGood then
				-- all item info available, unregister this event
				MinArch:DisplayStatusMessage("Minimal Archaeology - All items are loaded now (" .. event .. ").", MINARCH_MSG_DEBUG)
				MinArchHist:UnregisterEvent(event)
			else
				-- not all item info available, try again when more details have been received
				MinArch:DisplayStatusMessage("Minimal Archaeology - Some items are not loaded yet (" .. event .. ").", MINARCH_MSG_DEBUG)
				MinArchHist:UnregisterEvent("RESEARCH_ARTIFACT_HISTORY_READY")
				MinArchHist:RegisterEvent("GET_ITEM_INFO_RECEIVED")
				return
			end

			for i = 1, ARCHAEOLOGY_NUM_RACES do
				MinArch:GetHistory(i, event .. " {i=" .. i .. "}");
			end
			MinArch:CreateHistoryList(MinArchOptions['CurrentHistPage'], event);
			
			if (MinArchIsReady == true) then
				C_Timer.After(0.5, function()
					MinArch:UpdateMain();
				end)
			end
		else
			MinArch:DisplayStatusMessage("Minimal Archaeology - Artifact completion history is not available yet (" .. event .. ").", MINARCH_MSG_DEBUG)
		end
	elseif (event == "RESEARCH_ARTIFACT_UPDATE") then
		MinArch:CreateHistoryList(MinArchOptions['CurrentHistPage'], event)
	elseif (event == "QUEST_ACCEPTED" or event == "QUEST_TURNED_IN" or event == "QUEST_REMOVED" or event == "QUESTLINE_UPDATE") then
		MinArch:CreateHistoryList(MinArchOptions['CurrentHistPage'], event)
	end
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
	elseif (event == "WORLD_MAP_UPDATE" and MinArchIsReady == true) then
		MinArch:ShowRaceIconsOnMap(MinArch['activeUiMapID']);
	else
		MinArch:UpdateActiveDigSites();
		
		local ContID = MinArch:GetInternalContId();

		if (ContID ~= nil) then
			MinArch:CreateDigSitesList(ContID);
			MinArch:CreateDigSitesList(ContID);
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
			MinArchHideNext = false;
		end
	else
		MinArch:HideMain();
		MinArchHideNext = false;
	end
end

function MinArch:MainEventAddonLoaded()
	-- Apply Settins/SavedVariables
	
	if (MinArchOptions['CurrentHistPage'] == nil) then
		MinArchOptions['CurrentHistPage'] = 1;
	end

	if (MinArch.db.profile.startHidden == true) then
		MinArch:HideMain();
	end
	
	if (MinArch.db.profile.hideMain == true) then
		MinArch:HideMain();
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
	
	MinArch:CommonFrameScale(MinArch.db.profile.frameScale);
	MinArchIsReady = true;
	
	MinArch:ShowRaceIconsOnMap(MinArch['activeUiMapID']);

	MinArch:DisplayStatusMessage("Minimal Archaeology Loaded!");
end

function MinArch:TrackingChanged(self)
	-- update the map if digsites tracking is changed
	if (self.value == "digsites") then
		MinArch:ShowRaceIconsOnMap(MinArch['activeUiMapID'])
	end
end

function MinArch:MapLayerChanged(self)
	-- update the map if digsites tracking is changed
	if (self.mapID ~= nil) then
		MinArch['activeUiMapID'] = self.mapID;
		MinArch:ShowRaceIconsOnMap(self.mapID);
	end
end