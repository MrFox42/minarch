local ADDON, MinArch = ...

local clearBinding = false;

local function HookDoubleClick()
    local button = CreateFrame("Button", "MinArchHiddenSurveyButton", MinArch.HelperFrame, "InSecureActionButtonTemplate");
    button:SetAttribute("type", "spell");
    button:SetAttribute("spell", SURVEY_SPELL_ID);
    button:Hide();

    local threshold = 0.5;
    local prevTime;

    button:SetScript("PostClick", function(self)
        if clearBinding then
            ClearOverrideBindings(self)
        end
    end)

    WorldFrame:HookScript("OnMouseDown", function(_, button)
        if MinArch.db.profile.surveyOnDoubleClick and button == "RightButton" and not InCombatLockdown() and CanScanResearchSite() and GetSpellCooldown(SURVEY_SPELL_ID) == 0 then
            if prevTime then
                local diff = GetTime() - prevTime;

                if diff < threshold then
                    prevTime = nil;
                    SetOverrideBindingClick(MinArchHiddenSurveyButton, true, "BUTTON2", "MinArchHiddenSurveyButton");
                    clearBinding = true;
                end
            end

            prevTime = GetTime();
        end
    end)
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
    MinArchMainCrateButtonGlow:Hide();
    MinArch.Companion:hideCrateButton()
    MinArch.nextCratable = nil;

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
                            MinArch.Companion:showCrateButton(itemID);

							return;
						end
					end
				end
			end
		end
	end
end

function MinArch:InitHelperFrame()
    MinArch.HelperFrame = CreateFrame("Frame", "MinArchHelper");

	MinArch.HelperFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
	MinArch.HelperFrame:RegisterEvent("PLAYER_REGEN_ENABLED");

	MinArchMain.showAfterCombat = false;
	MinArchHist.showAfterCombat = false;
    MinArchDigsites.showAfterCombat = false;
    MinArch.Companion.showAfterCombat = false;

    MinArch.HelperFrame:Hide();

	MinArch.HelperFrame:SetScript("OnEvent", function(_, event, ...)
		MinArch:EventHelper(event, ...);
	end)
end

function MinArch.Ace:OnInitialize ()
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
	MinArch:InitHelperFrame();

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
    MinArch:ShowRaceIconsOnMap();
    HookDoubleClick();
	MinArch.IsReady = true;
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
	MinArch.ShowOnSurvey = true;
    MinArch.ShowInDigsite = true;
    MinArch.CompanionShowInDigsite = true;
	MinArch:UpdateMain();
end

function MinArch:Shutdown()
	MinArch:DisplayStatusMessage("ShutDown called", MINARCH_MSG_DEBUG);
end

function MinArch:InitDatabase()
	MinArch.db = LibStub("AceDB-3.0"):New("MinArchDB", MinArch.defaults, true);
	MinArch.db.RegisterCallback(MinArch, "OnProfileChanged", "RefreshConfig");
    MinArch.db.RegisterCallback(MinArch, "OnProfileCopied", "RefreshConfig");
    MinArch.db.RegisterCallback(MinArch, "OnProfileReset", "RefreshConfig");
	MinArch.db.RegisterCallback(MinArch, "OnDatabaseShutdown", "Shutdown");

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

    self:SetScript("OnEvent", function(_, event, ...)
		MinArch:EventHist(event, ...);
    end)

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

    MinArch:CommonFrameLoad(self);

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

    local continentButtons = {"Kalimdor", "Eastern", "Outland", "Northrend", "Maelstrom", "Pandaria", "Draenor", "BrokenIsles", "Kultiras", "Zaandalar"}
    local continentTextures = {
        [[Interface\Icons\Achievement_Zone_Kalimdor_01.blp]],
        [[Interface\Icons\Achievement_Zone_EasternKingdoms_01.blp]],
        [[Interface\Icons\Achievement_Zone_Outland_01.blp]],
        [[Interface\Icons\Achievement_Zone_Northrend_01.blp]],
        nil,
        [[Interface\Icons\expansionicon_mistsofpandaria.blp]],
        [[Interface\Icons\Achievement_Zone_Draenor_01.blp]],
        [[Interface\Icons\achievements_zone_brokenshore.blp]],
        [[Interface\Icons\inv_tiragardesound.blp]],
        [[Interface\Icons\inv_zuldazar.blp]],
    }

    local counter = 1;
    for i=1,ARCHAEOLOGY_NUM_CONTINENTS do
        local button = CreateFrame("Button", "$parent" .. continentButtons[i] .. "Button", self, nil, i)
        button.parentKey = continentButtons[i] .. "Button";

        button:SetPoint("TOPLEFT", self, "TOPLEFT", 15 + (counter - 1) * 35, -20);
        button:SetWidth(32)
        button:SetHeight(32);

        button:SetNormalTexture(continentTextures[i]);
        button:SetPushedTexture(continentTextures[i]);
        button:SetHighlightTexture(continentTextures[i], "ADD");

        button:SetScript("OnClick", function ()
            MinArch:CreateDigSitesList(i);
            MinArch:CreateDigSitesList(i);
        end);
        button:SetScript("OnEnter", function ()
            MinArch:ADIButtonTooltip(i);
        end);
        button:SetScript("OnLeave", function ()
            GameTooltip:Hide();
        end);

        MinArch.DigsiteButtons[i] = button;
        if i ~= 5 then
            counter = counter + 1;
        else
            button:Hide()
        end
	end

	self:SetScript("OnEvent", function(_, event, ...)
		MinArch:EventDigsites(event, ...);
    end)

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

    MinArch:CommonFrameLoad(self);

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
