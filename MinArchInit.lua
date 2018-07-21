function MinArch:InitMain(self)
	-- Update Artifacts
	self:RegisterEvent("RESEARCH_ARTIFACT_COMPLETE");
	self:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE");
	self:RegisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("PLAYER_ALIVE");
	self:RegisterEvent("LOOT_CLOSED");
	self:RegisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
	
	-- Apply SavedVariables
	self:RegisterEvent("ADDON_LOADED");
	
	-- Values that don't need to be saved
	MinArch['frame']['defaultHeight'] = MinArchMain:GetHeight();
	MinArch['frame']['height'] = MinArchMain:GetHeight();
	
	for i=1,ARCHAEOLOGY_NUM_RACES do
		-- Create the artifact bars for the main window
		artifactBar = CreateFrame("StatusBar", "MinArchArtifactBar" .. i, MinArchMain, "MATArtifactBar", i);
		artifactBar.parentKey = "artifactBar" .. i;
		if (i == 1) then
			artifactBar:SetPoint("TOP", MinArchMain, "TOP", -25, -50);
		else 
			artifactBar:SetPoint("TOP", MinArch['artifactbars'][i-1], "TOP", 0, -25);
		end

		MinArch['artifacts'][i] = {}; 
		MinArch['artifacts'][i]['appliedKeystones'] = 0;
		MinArch['artifactbars'][i] = artifactBar;
		MinArchOptions['ABOptions'][i] = {};
		MinArchOptions['ABOptions'][i]['AlwaysUseKeystone'] = false;
		MinArchOptions['ABOptions'][i]['Hide'] = false;
	end
	
	MinArch:DisplayStatusMessage("Minimal Archaeology Initialized!");
end

function MinArch:InitHist(self)
	self:RegisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
	self:RegisterEvent("RESEARCH_ARTIFACT_UPDATE");
	RequestArtifactCompletionHistory();
	MinArch:DisplayStatusMessage("Minimal Archaeology History Initialized!");
end

function MinArch:InitDigsites(self)
	self:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE");
	self:RegisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	-- self:RegisterEvent("WORLD_MAP_UPDATE"); -- TODO
	self:RegisterEvent("UNIT_SPELLCAST_SENT");
	self:RegisterEvent("PLAYER_ALIVE");
	-- hooksecurefunc(WorldMapTrackingOptionsButtonMixin, "OnSelection", MinArch_TrackingChanged); -- TODO

	MinArch:DisplayStatusMessage("Minimal Archaeology Digsites Initialized!");
end

function MinArch_TrackingChanged(self)
	MinArch:TrackingChanged(self);
end 
