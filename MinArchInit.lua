function MinArch:InitMain(self)
	-- Update Artifacts
	self:RegisterEvent("ARTIFACT_COMPLETE");
	self:RegisterEvent("ARTIFACT_DIG_SITE_UPDATED");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("PLAYER_ALIVE");
	self:RegisterEvent("LOOT_CLOSED");
	self:RegisterEvent("ARTIFACT_HISTORY_READY");
	
	-- Apply SavedVariables
	self:RegisterEvent("ADDON_LOADED");
	
	-- Values that don't need to be saved
	MinArch['frame']['defaultHeight'] = MinArchMain:GetHeight();
	MinArch['frame']['height'] = MinArchMain:GetHeight();
	
	for i=1,18 do
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
	self:RegisterEvent("ARTIFACT_HISTORY_READY");
	RequestArtifactCompletionHistory();
	ChatFrame1:AddMessage("Minimal Archaeology History Initialized!");
end

function MinArch:InitDigsites(self)
	self:RegisterEvent("ARTIFACT_DIG_SITE_UPDATED");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("WORLD_MAP_UPDATE");
	self:RegisterEvent("UNIT_SPELLCAST_SENT");
	self:RegisterEvent("PLAYER_ALIVE");
	hooksecurefunc("WorldMapTrackingOptionsDropDown_OnClick", MinArch_TrackingChanged);

	ChatFrame1:AddMessage("Minimal Archaeology Digsites Initialized!");
end

function MinArch_TrackingChanged(self)
	MinArch:TrackingChanged(self);
end 