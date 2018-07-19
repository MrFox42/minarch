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
		MinArch['artifacts'][i] = {}; 
		MinArch['artifacts'][i]['appliedKeystones'] = 0;
		MinArch['artifactbars'][i] = MinArchMain["artifactBar"..i];
		MinArchOptions['ABOptions'][i] = {};
		MinArchOptions['ABOptions'][i]['AlwaysUseKeystone'] = false;
		MinArchOptions['ABOptions'][i]['Hide'] = false;
	end
	
	ChatFrame1:AddMessage("Minimal Archaeology Initialized!");
end

function MinArch:InitHist(self)
	self:RegisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
	self:RegisterEvent("RESEARCH_ARTIFACT_UPDATE");
	RequestArtifactCompletionHistory();
	ChatFrame1:AddMessage("Minimal Archaeology History Initialized!");
end

function MinArch:InitDigsites(self)
	self:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE");
	self:RegisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	-- self:RegisterEvent("WORLD_MAP_UPDATE"); -- TODO
	self:RegisterEvent("UNIT_SPELLCAST_SENT");
	self:RegisterEvent("PLAYER_ALIVE");
	-- hooksecurefunc("WorldMapTrackingOptionsDropDown_OnClick", MinArch_TrackingChanged); -- TODO

	ChatFrame1:AddMessage("Minimal Archaeology Digsites Initialized!");
end

function MinArch_TrackingChanged(self)
	MinArch:TrackingChanged(self);
end 
