function MinArch:InitMain(self)
	-- Init frame scripts
	MinArchMain:SetScript('OnShow', function ()
		MinArch:UpdateMain();
	end)

	-- Create the artifact bars for the main window
	for i=1,ARCHAEOLOGY_NUM_RACES do
		artifactBar = CreateFrame("StatusBar", "MinArchArtifactBar" .. i, MinArchMain, "MATArtifactBar", i);
		artifactBar.parentKey = "artifactBar" .. i;
		if (i == 1) then
			artifactBar:SetPoint("TOP", MinArchMain, "TOP", -25, -50);
		else 
			artifactBar:SetPoint("TOP", MinArch['artifactbars'][i-1], "TOP", 0, -25);
		end

		local barTexture = [[Interface\Archeology\Arch-Progress-Fill]];
		artifactBar:SetStatusBarTexture(barTexture);


		MinArch['artifacts'][i] = {}; 
		MinArch['artifacts'][i]['appliedKeystones'] = 0;
		MinArch['artifactbars'][i] = artifactBar;
	end

	local skillBarTexture = [[Interface\PaperDollInfoFrame\UI-Character-Skills-Bar]];
	MinArchMain.skillBar:SetStatusBarTexture(skillBarTexture);
	MinArchMain.skillBar:SetStatusBarColor(0.03125, 0.85, 0);

	-- Update Artifacts
	self:RegisterEvent("RESEARCH_ARTIFACT_COMPLETE");
	self:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE");
	self:RegisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("PLAYER_ALIVE");
	self:RegisterEvent("LOOT_CLOSED");
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
	self:RegisterEvent("ARCHAEOLOGY_FIND_COMPLETE");
	self:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST");
	self:RegisterEvent("QUEST_TURNED_IN");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("PLAYER_STOPPED_MOVING");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_INDOORS");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("CVAR_UPDATE"); -- Tracking

	-- Apply SavedVariables
	self:RegisterEvent("ADDON_LOADED");

	-- Values that don't need to be saved
	MinArch['frame']['defaultHeight'] = MinArchMain:GetHeight();
	MinArch['frame']['height'] = MinArchMain:GetHeight();

	MinArch:DisplayStatusMessage("Minimal Archaeology Initialized!");
end

function MinArch:OnInitialize ()
	for i=1, ARCHAEOLOGY_NUM_RACES do
		MinArch.barlinks[i] = {};
	end

	-- Initialize Settings Database
	MinArch:SetDynamicDefaults();
	MinArch:InitDatabase();
	MinArch:MainEventAddonLoaded();

	MinArch:InitMain(MinArchMain);
	MinArch:InitHist(MinArchHist);
	MinArch:InitDigsites(MinArchDigsites);

	MinArch:InitLDB();

	MinArchTooltipIcon:SetScript("OnShow", function (self)
		self:ClearAllPoints();
		local tooltip = self:GetParent();
		local tooltipWidth = tooltip:GetWidth();
		local cursorPosX = GetCursorPosition();
		
		if (tooltipWidth/2 > cursorPosX) then
			MinArchTooltipIcon:SetPoint("TOPRIGHT", tooltip, "TOPRIGHT", 65, 0);
		else
			MinArchTooltipIcon:SetPoint("TOPLEFT", tooltip, "TOPLEFT", -65, 0);
		end
	end)

	-- TODO Add to UISpecialFrames so windows close when the escape button is pressed
	--[[C_Timer.After(0.5, function()
		tinsert(UISpecialFrames, "MinArchMain");
		-- TODO: close one by one
		tinsert(UISpecialFrames, "MinArchHist");
		tinsert(UISpecialFrames, "MinArchDigsites");
	end)]]--
	
end

function MinArch:SetDynamicDefaults ()
	for i=1, ARCHAEOLOGY_NUM_RACES do
		MinArch.defaults.profile.raceOptions.hide[i] = false;
		MinArch.defaults.profile.raceOptions.cap[i] = false;
		MinArch.defaults.profile.raceOptions.keystone[i] = false;
	end
end

function MinArch:RefreshConfig()
	MinArch:DisplayStatusMessage("RefreshConfig called", MINARCH_MSG_DEBUG);
	
	MinArch:RefreshMinimapButton();
	MinArch:ShowRaceIconsOnMap(MinArch['activeUiMapID']);
	MinArch:CommonFrameScale(MinArch.db.profile.frameScale);
	MinArchShowOnSurvey = true;
	MinArchShowInDigsite = true;
	MinArch:UpdateMain();
end

function MinArch:Shutdown()
	MinArch:DisplayStatusMessage("ShutDown called", MINARCH_MSG_DEBUG);
end

function MinArch:InitDatabase()
	self.db = LibStub("AceDB-3.0"):New("MinArchDB", self.defaults, true);
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig");
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig");
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig");
	self.db.RegisterCallback(self, "OnDatabaseShutdown", "Shutdown");
	
	MinArch:UpgradeSettings()
end

function MinArch:UpgradeSettings()
	if (MinArch.db.profile.settingsVersion == 0) then
		for i=1, ARCHAEOLOGY_NUM_RACES do
			if (MinArchOptions['ABOptions'][i] ~= nil) then
				if (MinArchOptions['ABOptions'][i]['Cap'] ~= nil) then
					MinArch.db.profile.raceOptions.cap[i] = MinArchOptions['ABOptions'][i]['Cap'];
				end

				if (MinArchOptions['ABOptions'][i]['Hide'] ~= nil) then
					MinArch.db.profile.raceOptions.hide[i] = MinArchOptions['ABOptions'][i]['Hide'];
				end

				if (MinArchOptions['ABOptions'][i]['AlwaysUseKeystone'] ~= nil) then
					MinArch.db.profile.raceOptions.keystone[i] = MinArchOptions['ABOptions'][i]['AlwaysUseKeystone'];
				end
			end
		end

		if (MinArchOptions['HideMinimap'] ~= nil) then
			MinArch.db.profile.hideMinimapButton = MinArchOptions['HideMinimap'];
		end

		if (MinArchOptions['DisableSound'] ~= nil) then
			MinArch.db.profile.disableSound = MinArchOptions['DisableSound'];
		end

		if (MinArchOptions['StartHidden'] ~= nil) then
			MinArch.db.profile.startHidden = MinArchOptions['StartHidden'];
		end

		if (MinArchOptions['FrameScale'] ~= nil) then
			MinArch.db.profile.frameScale = MinArchOptions['FrameScale'];
		end

		if (MinArchOptions['ShowStatusMessages'] ~= nil) then
			MinArch.db.profile.showStatusMessages = MinArchOptions['ShowStatusMessages'];
		end

		if (MinArchOptions['ShowWorldMapOverlay'] ~= nil) then
			MinArch.db.profile.showWorldMapOverlay = MinArchOptions['ShowWorldMapOverlay'];
		end

		if (MinArchOptions['HideAfterDigsite'] ~= nil) then
			MinArch.db.profile.hideAfterDigsite = MinArchOptions['HideAfterDigsite'];
		end

		if (MinArchOptions['WaitForSolve'] ~= nil) then
			MinArch.db.profile.waitForSolve = MinArchOptions['WaitForSolve'];
		end

		if (MinArchOptions['MinimapPos'] ~= nil) then
			MinArch.db.profile.minimapPos = MinArchOptions['MinimapPos'];
		end

		MinArch.db.profile.settingsVersion = 1;
	end

	if (MinArch.db.profile.settingsVersion == 1) then
		MinArch.db.profile.minimap.hide = MinArch.db.profile.hideMinimapButton;

		MinArch.db.profile.settingsVersion = 2;
	end
end

function MinArch:InitHist(self)
	self:RegisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
	self:RegisterEvent("RESEARCH_ARTIFACT_UPDATE");
	self:RegisterEvent("QUEST_ACCEPTED");
	self:RegisterEvent("QUEST_TURNED_IN");
	self:RegisterEvent("QUEST_REMOVED");	
	self:RegisterEvent("QUESTLINE_UPDATE");
	RequestArtifactCompletionHistory();

	MinArch:InitRaceButtons(self);

	self:SetScript("OnShow", function ()
		MinArch:DimHistoryButtons();
		MinArch.raceButtons[MinArchOptions['CurrentHistPage']]:SetAlpha(1.0);
		MinArch:CreateHistoryList(MinArchOptions['CurrentHistPage'], "MATBOpenHist");
	end)

	MinArch:DisplayStatusMessage("Minimal Archaeology History Initialized!");
end

function MinArch:InitRaceButtons(self)
	local baseX = 15;
	local baseY = -15;
	local currX = baseX;
	local currY = baseY;
	local sizeX = 25;
	local sizeY = 25;
	local lineBreak = 10;

	for i=1, ARCHAEOLOGY_NUM_RACES do
		if (MinArchRaceConfig[i] ~= nil) then
			local raceButton = CreateFrame("Button", "MinArchRaceButton" .. i, self);
			raceButton:SetPoint("TOPLEFT", self, "TOPLEFT", currX, currY);
			currX = currX + sizeX;
			
			if (i == 10) then
				currX = baseX;
				currY = currY - sizeY;
			end
			raceButton:SetSize(sizeX, sizeY);
			raceButton:SetNormalTexture(MinArchRaceConfig[i].texture);
			raceButton:GetNormalTexture():SetTexCoord(0.0234375, 0.5625, 0.078125, 0.625);
			raceButton:GetNormalTexture():SetSize(sizeX, sizeY);
			
			raceButton:SetPushedTexture(MinArchRaceConfig[i].texture);
			raceButton:GetPushedTexture():SetTexCoord(0.0234375, 0.5625, 0.078125, 0.625);
			raceButton:GetPushedTexture():SetSize(sizeX, sizeY);
			
			raceButton:SetHighlightTexture(MinArchRaceConfig[i].texture);
			raceButton:GetHighlightTexture():SetTexCoord(0.0234375, 0.5625, 0.078125, 0.625);
			raceButton:GetHighlightTexture():SetSize(sizeX, sizeY);
			raceButton:GetHighlightTexture().alphaMode = "ADD";

			raceButton:SetScript("OnClick", function (self) 
				MinArch:DimHistoryButtons();
				self:SetAlpha(1.0);
				MinArchOptions['CurrentHistPage'] = i;
				MinArch:CreateHistoryList(i);
			end)

			raceButton:SetScript("OnEnter", function () 
				MinArch:HistoryButtonTooltip(i)
			end)

			raceButton:SetScript("OnLeave", function () 
				GameTooltip:Hide();
			end)

			MinArch.raceButtons[i] = raceButton;
		end
	end
end

function MinArch:RefreshRaceButtons()

end

function MinArch:InitDigsites(self)
	local continents = C_Map.GetMapChildrenInfo(947, 2);
	for k, v in pairs(continents) do
		MinArch.MapContinents[v.mapID] = v.name;
	end
	local continents = C_Map.GetMapChildrenInfo(946, 2);
	for k, v in pairs(continents) do
		MinArch.MapContinents[v.mapID] = v.name;
	end

	self:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE");
	self:RegisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST");
	self:RegisterEvent("PLAYER_ALIVE");
	self:RegisterEvent("TAXIMAP_OPENED");
	hooksecurefunc(MapCanvasDetailLayerMixin, "SetMapAndLayer", MinArch_MapLayerChanged);
	hooksecurefunc("ToggleWorldMap", MinArch_WorldMapToggled);
	hooksecurefunc(MapCanvasScrollControllerMixin, "ZoomIn", MinArch_FlightMapZoomIn);
	hooksecurefunc(MapCanvasScrollControllerMixin, "ZoomOut", MinArch_FlightMapZoomOut);

	MinArch:DisplayStatusMessage("Minimal Archaeology Digsites Initialized!");
end

function MinArch:LoadRaceInfo()
	for i = 1, ARCHAEOLOGY_NUM_RACES do
		local name, t = GetArchaeologyRaceInfo(i);
		if (t == nil) then
			return;
		end
		MinArch.ArchaeologyRaces[name] = i;
	end
	MinArch.RacesLoaded = true;
end


function MinArch_TrackingChanged(self)
	MinArch:TrackingChanged(self);
end 


function MinArch_MapLayerChanged(self)
	MinArch:MapLayerChanged(self);
end

function MinArch_WorldMapToggled()
	if (WorldMapFrame.mapID ~= nil and WorldMapFrame:IsVisible()) then
		MinArch['activeUiMapID'] = WorldMapFrame.mapID;
		MinArch:ShowRaceIconsOnMap(WorldMapFrame.mapID);
	end
end

function MinArch_FlightMapZoomIn()
	MinArch:ShowRaceIconsOnMap(FlightMapFrame.mapID);
end
function MinArch_FlightMapZoomOut()
	MinArch:ShowRaceIconsOnMap(FlightMapFrame.mapID);
end
