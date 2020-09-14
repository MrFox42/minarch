function MinArch:SetRelevancyToggleButtonTexture()
	local button = MinArchMainRelevancyButton;
	if (MinArch.db.profile.relevancy.relevantOnly) then
		button:SetNormalTexture([[Interface\Buttons\UI-Panel-ExpandButton-Up]]);
		button:SetPushedTexture([[Interface\Buttons\UI-Panel-ExpandButton-Down]]);
	else
		button:SetNormalTexture([[Interface\Buttons\UI-Panel-CollapseButton-Up]]);
		button:SetPushedTexture([[Interface\Buttons\UI-Panel-CollapseButton-Down]]);
	end

	button:SetBackdrop( {
		bgFile = [[Interface\GLUES\COMMON\Glue-RightArrow-Button-Up]],
		edgeFile = nil, tile = false, tileSize = 0, edgeSize = 0,
		insets = { left = 0.5, right = 1, top = 2.4, bottom = 1.4 }
	});
	button:SetHighlightTexture([[Interface\Addons\MinimalArchaeology\Textures\CloseButtonHighlight]]);
	button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", 10, -10);
end

local function ShowRelevancyButtonTooltip()
	local button = MinArchMainRelevancyButton;
	if (MinArch.db.profile.relevancy.relevantOnly) then
		MinArch:ShowWindowButtonTooltip(button, "Show all races. \n\n|cFF00FF00Right click to open settings and customize relevancy options.|r");
	else
		MinArch:ShowWindowButtonTooltip(button, "Only show relevant races. \n\n|cFF00FF00Right click to open settings and customize relevancy options.|r");
	end
end

local function CreateRelevancyToggleButton(parent, x, y)
	local button = CreateFrame("Button", "$parentRelevancyButton", parent, BackdropTemplateMixin and "BackdropTemplate");
	button:SetSize(23.5, 23.5);
	button:SetPoint("TOPLEFT", x, y);
	MinArch:SetRelevancyToggleButtonTexture();

	button:SetScript("OnClick", function(self, button)
		if (button == "LeftButton") then
			MinArch.db.profile.relevancy.relevantOnly = (not MinArch.db.profile.relevancy.relevantOnly);
			MinArch:SetRelevancyToggleButtonTexture();
			MinArch:UpdateMain();
			ShowRelevancyButtonTooltip();
		end
	end);
	button:SetScript("OnMouseUp", function(self, button)
		if (button == "RightButton") then
			InterfaceOptionsFrame_OpenToCategory(MinArch.Options.raceSettings);
			InterfaceOptionsFrame_OpenToCategory(MinArch.Options.raceSettings);
		end
	end);
	button:SetScript("OnEnter", ShowRelevancyButtonTooltip)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end)
end

local function CreateCrateButton(parent, x, y)
	local button = CreateFrame("Button", "$parentCrateButton", parent, "InsecureActionButtonTemplate");
	button:SetAttribute("type", "item");
	button:SetSize(25, 25);
	button:SetPoint("TOPLEFT", x, y);

	button:SetNormalTexture([[Interface\AddOns\MinimalArchaeology\Textures\CrateButtonUp]]);
	button:SetPushedTexture([[Interface\AddOns\MinimalArchaeology\Textures\CrateButtonDown]]);
	button:SetHighlightTexture([[Interface\Addons\MinimalArchaeology\Textures\CloseButtonHighlight]]);

	local overlay = CreateFrame("Frame", "$parentGlow", button);
	overlay:SetSize(28, 28);
	overlay:SetPoint("TOPLEFT", button, "TOPLEFT", -5, 5);
	overlay.texture = overlay:CreateTexture(nil, "OVERLAY");
	overlay.texture:SetAllPoints(overlay);
	overlay.texture:SetTexture([[Interface\Buttons\CheckButtonGlow]]);
	overlay:Hide();

	MinArch:SetCrateButtonTooltip(button);
end

function MinArch:SetCrateButtonTooltip(button)
    button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
		if (MinArch.nextCratable ~= nil) then
			GameTooltip:SetItemByID(MinArch.nextCratable.itemID);
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine("Click to crate this artifact");
		else
			GameTooltip:AddLine("You don't have anything to crate.");
		end

		GameTooltip:Show();
	end)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end)
end

MinArch.nextCratable = nil;
function MinArch:RefreshCrateButtonGlow()
	for i = 1, ARCHAEOLOGY_RACE_MANTID do
		for artifactID, data in pairs(MinArchHistDB[i]) do
			if (data.pqid) then
				-- iterate containers
				for bagID = 0, 4 do
					local numSlots = GetContainerNumSlots(bagID);
					for slot = 0, numSlots do
						local itemID = GetContainerItemID(bagID, slot);
						if (itemID == artifactID) then
							MinArch.nextCratable = {
								itemID = itemID,
								bagID = bagID,
								slot = slot
							}

                            MinArchMainCrateButton:SetAttribute("item", "item:" .. itemID);
                            MinArchMainCrateButtonGlow:Show();

                            MinArch.Companion.crateButton:SetAttribute("item", "item:" .. itemID);
                            MinArch.Companion:showCrateButton();
							return;
						end
					end
				end
			end
		end
	end

    MinArchMainCrateButtonGlow:Hide();
    MinArch.Companion:hideCrateButton()
	MinArch.nextCratable = nil;
end

function MinArch:InitMain(self)
	-- Init frame scripts
	self:SetScript('OnShow', function ()
		MinArch:UpdateMain();
		if (MinArch:IsNavigationEnabled()) then
			MinArchMainAutoWayButton:Show();
		else
			MinArchMainAutoWayButton:Hide();
		end
	end)

	-- Create the artifact bars for the main window
	for i=1,ARCHAEOLOGY_NUM_RACES do
		local artifactBar = CreateFrame("StatusBar", "MinArchArtifactBar" .. i, MinArchMain, "MATArtifactBar", i);
        artifactBar.parentKey = "artifactBar" .. i;
        artifactBar.race = i;
		if (i == 1) then
			artifactBar:SetPoint("TOP", self, "TOP", -25, -50);
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
	self.skillBar:SetStatusBarTexture(skillBarTexture);
	self.skillBar:SetStatusBarColor(0.03125, 0.85, 0);

	MinArch:CreateAutoWaypointButton(self, 53, 3);
	CreateCrateButton(self, 32, 1);
	CreateRelevancyToggleButton(self, 10, 4);

	-- Update Artifacts
	self:RegisterEvent("RESEARCH_ARTIFACT_COMPLETE");
	self:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE");
	self:RegisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("PLAYER_ALIVE");
	self:RegisterEvent("LOOT_CLOSED");
	self:RegisterEvent("BAG_UPDATE");
	-- self:RegisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
	self:RegisterEvent("ARCHAEOLOGY_FIND_COMPLETE");
	self:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST");
	self:RegisterEvent("ARCHAEOLOGY_CLOSED");
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

function MinArch:InitHelperFrame(self)
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");

	MinArchMain.showAfterCombat = false;
	MinArchHist.showAfterCombat = false;
    MinArchDigsites.showAfterCombat = false;
    MinArch.Companion.showAfterCombat = false;

	self:SetScript("OnEvent", function(self, event, ...)
		MinArch:EventHelper(event, ...);
	end)
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
	MinArch:InitHelperFrame(MinArchHelper);

	MinArch.Companion:Init();

	MinArch:InitLDB();
	-- TODO Add to UISpecialFrames so windows close when the escape button is pressed
	--[[C_Timer.After(0.5, function()
		tinsert(UISpecialFrames, "MinArchMain");
		-- TODO: close one by one
		tinsert(UISpecialFrames, "MinArchHist");
		tinsert(UISpecialFrames, "MinArchDigsites");
	end)]]--

	MinArch:CommonFrameScale(MinArch.db.profile.frameScale);
	MinArchIsReady = true;
	MinArch:ShowRaceIconsOnMap();
	MinArch:DisplayStatusMessage("Minimal Archaeology Loaded!");
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
	MinArch:ShowRaceIconsOnMap();
	MinArch:CommonFrameScale(MinArch.db.profile.frameScale);
	MinArchShowOnSurvey = true;
    MinArchShowInDigsite = true;
    MinArchCompanionShowInDigsite = true;
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

	if (MinArch.db.profile.settingsVersion == 2) then
		if (MinArch.db.profile.startHidden == true) then
			MinArch.db.profile.rememberState = false;
		end

		MinArch.db.profile.settingsVersion = 3;
	end
end

function MinArch:InitHist(self)
	MinArch:InitQuestIndicator(self);
	MinArch:InitRaceButtons(self);

	self:SetScript("OnShow", function ()

		local digSite, distance, digSiteData = MinArch:GetNearestDigsite();
		if (digSite and distance <= 2) then
			MinArchOptions['CurrentHistPage'] = MinArch:GetRaceIdByName(digSiteData.race)
		end
		MinArch:DimHistoryButtons();

		MinArch.raceButtons[MinArchOptions['CurrentHistPage']]:SetAlpha(1.0);
		MinArch:CreateHistoryList(MinArchOptions['CurrentHistPage'], "MATBOpenHist");
	end)

	self:RegisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
	self:RegisterEvent("RESEARCH_ARTIFACT_UPDATE");
	self:RegisterEvent("QUEST_ACCEPTED");
	self:RegisterEvent("QUEST_TURNED_IN");
	self:RegisterEvent("QUEST_REMOVED");
	self:RegisterEvent("QUESTLINE_UPDATE");
	-- RequestArtifactCompletionHistory();

	MinArch:DisplayStatusMessage("Minimal Archaeology History Initialized!");
end

function MinArch:InitQuestIndicator(self)
	local qi = CreateFrame("Button", "MinArchHistQuestIndicator", self);
	qi:SetSize(16,16);

	qi.texture = qi:CreateTexture(nil, "OVERLAY");
	qi.texture:SetAllPoints(qi);
	--qi.texture:SetSize(20,20);
	qi.texture:SetTexture([[Interface\QuestTypeIcons]]);
	qi.texture:SetTexCoord(0, 0.140625, 0.28125, 0.5625);
	qi:EnableMouse(false);
	qi:SetAlpha(0.6);
	qi:Hide();
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
				MinArchOptions['CurrentHistPage'] = i;
				MinArch:DimHistoryButtons();
				self:SetAlpha(1.0);
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

	self:SetScript("OnShow", function()
		if (MinArch:IsNavigationEnabled()) then
			MinArchDigsitesAutoWayButton:Show();
		else
			MinArchDigsitesAutoWayButton:Hide();
		end
	end)

	MinArch:CreateAutoWaypointButton(self, 15, 3);

	self:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE");
	self:RegisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED");
	-- self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST");
	self:RegisterEvent("PLAYER_ALIVE");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_INDOORS");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	hooksecurefunc(MapCanvasDetailLayerMixin, "SetMapAndLayer", MinArch_MapLayerChanged);
	hooksecurefunc("ToggleWorldMap", MinArch_WorldMapToggled);
	hooksecurefunc("ShowUIPanel", MinArch_ShowUIPanel);

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
		MinArch:ShowRaceIconsOnMap();
	end
end

function MinArch_ShowUIPanel(...)
	local panel = ...;
	if (panel and panel:GetName() == "ArchaeologyFrame") then
		MinArchHist:UnregisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
	end
end
