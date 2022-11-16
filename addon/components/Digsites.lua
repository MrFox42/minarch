local ADDON, MinArch = ...

MinArchScrollDS = {}
MinArchDigsitesDB = {} -- old dig site info per character
MinArchDigsitesGlobalDB = {} -- global dig site information
MinArchMapFrames = {}

MinArchDigsitesGlobalDB["continent"] = {
	[1] = {		--Kalimdor
		--["name"] = {
		--	["raceid"] = #,
		--	["x"] = #,
		--	["y"] = #
	},
	[2] = {		--Eastern Kingdoms
	},
	[3] = {		--Outlands
	},
	[4] = {		--Northrend
	},
	[5] = {		-- The Maelstrom (no dig sites)
	},
	[6] = {		-- Pandaria
	},
	[7] = {		-- Draenor
	},
	[8] = {		-- Broken Isles
	},
	[9] = {		-- Zandalar
	},
	[10] = {	-- Kul Tiras
	},
}

MinArchDigsitesDB["continent"] = {
	[1] = {		--Kalimdor
		--["name"] = {
		--	["status"] = true/false;
	},
	[2] = {		--Eastern Kingdoms
	},
	[3] = {		--Outlands
	},
	[4] = {		--Northrend
	},
	[5] = {		-- The Maelstrom (no dig sites)
	},
	[6] = {		-- Pandaria
	},
	[7] = {		-- Draenor
	},
	[8] = {		-- Broken Isles
	},
	[9] = {		-- Zandalar
	},
	[10] = {	-- Kul Tiras
	},
}

function MinArch:InitDigsites(self)
	local continents = C_Map.GetMapChildrenInfo(947, 2);
	for k, v in pairs(continents) do
		MinArch.MapContinents[v.mapID] = v.name;
	end
	local continents = C_Map.GetMapChildrenInfo(946, 2);
	for k, v in pairs(continents) do
		MinArch.MapContinents[v.mapID] = v.name;
    end

    local continentButtons = {"Kalimdor", "Eastern", "Outland", "Northrend", "Maelstrom", "Pandaria", "Draenor", "BrokenIsles", "Kultiras", "Zandalar"}
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

        if continentTextures[i] then
            button:SetNormalTexture(continentTextures[i]);
            button:SetPushedTexture(continentTextures[i]);
            button:SetHighlightTexture(continentTextures[i], "ADD");
        end

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

-- don't spam about unknown digsites, only once each
local SpamBlock = {}

function MinArch:UpdateActiveDigSites()
	MinArch.RelevantRaces = {};
	-- can't do anything until all races are known
	if GetNumArchaeologyRaces() < ARCHAEOLOGY_NUM_RACES then
		return
	end
	-- also digsite list must be initialized
	if not MinArchDigsiteList then
		return
	end

	local playerContID = MinArch:GetInternalContId();

	for i = 1, ARCHAEOLOGY_NUM_CONTINENTS do

		if MinArchDigsitesDB["continent"][i] == nil then
			MinArchDigsitesDB["continent"][i] = {}
		end
		if MinArchDigsitesGlobalDB["continent"][i] == nil then
			MinArchDigsitesGlobalDB["continent"][i] = {}
		end

		for name,digsite in pairs(MinArchDigsitesDB["continent"][i]) do
			digsite["status"] = false;
		end

        local zoneUiMapID = MinArch:GetUiMapIdByContId(i);

        local zones = C_Map.GetMapChildrenInfo(zoneUiMapID, 3);
        -- Workaround for the phased version of Vale of Eternal Blossoms
        if (i == 6) then
            table.insert(zones, {mapID = 390});
        end

		for mapkey, zone in pairs(zones) do
            local uiMapID = zone.mapID;
			for key, digsite in pairs(C_ResearchInfo.GetDigSitesForMap(uiMapID)) do
				local name = tostring(digsite.name)
				local x = digsite.position.x;
				local y = digsite.position.y;

				MinArchDigsitesGlobalDB["continent"][i][name] = MinArchDigsitesGlobalDB["continent"][i][name] or {};
				MinArchDigsitesDB      ["continent"][i][name] = MinArchDigsitesDB["continent"][i][name] or {};

				-- if we don't have this in the DB yet, try to use the race from the digsite list
				-- if not MinArchDigsitesGlobalDB["continent"][i][name]["race"] or MinArchDigsitesGlobalDB["continent"][i][name]["race"] == "Unknown" then
					if MinArchDigsiteList[name] then
						local race = GetArchaeologyRaceInfo(MinArchDigsiteList[name].race)
                        MinArchDigsitesGlobalDB["continent"][i][name]["race"] = race
                        MinArchDigsitesGlobalDB["continent"][i][name]["raceId"] = MinArchDigsiteList[name].race
					elseif not SpamBlock[name] then
						MinArch:DisplayStatusMessage("Minimal Archaeology: Unknown digsite " .. name, MINARCH_MSG_STATUS)
						SpamBlock[name] = 1
					end
				--end

				-- TODO: remove digsites assigned to the wrong continent in old/buggy releases

                local digsiteZone = C_Map.GetMapInfoAtPosition(uiMapID, x, y);
                -- Workaround for the phased version of Vale of Eternal Blossoms
                if uiMapID == 390 then
                    digsiteZone = C_Map.GetMapInfo(uiMapID);
                end
                local currentZoneUiMapID = MinArch:GetNearestZoneId(digsiteZone.mapID);
				if (currentZoneUiMapID ~= nil and (currentZoneUiMapID == uiMapID or currentZoneUiMapID == digsiteZone.parentMapID)) then
					if (playerContID == i and MinArchDigsiteList[name]) then
						MinArch.RelevantRaces[MinArchDigsiteList[name].race] = true;
					end
					MinArchDigsitesDB      ["continent"][i][name]["status"] = true;
					MinArchDigsitesGlobalDB["continent"][i][name]["uiMapID"] = currentZoneUiMapID;
					MinArchDigsitesGlobalDB["continent"][i][name]["x"] = tostring(x*100);
					MinArchDigsitesGlobalDB["continent"][i][name]["y"] = tostring(y*100);
					MinArchDigsitesGlobalDB["continent"][i][name]["zone"] = digsiteZone.name or "";
					MinArchDigsitesGlobalDB["continent"][i][name]["subzone"] = MinArchDigsitesGlobalDB["continent"][i][name]["subzone"] or "";
				end
			end
		end
	end

	MinArch:ShowRaceIconsOnMap();
end

function MinArch:CreateDigSitesList(ContID)
	if (ContID < 1 or ContID > ARCHAEOLOGY_NUM_CONTINENTS ) then
		ContID = MinArch:GetInternalContId();

		if (ContID == nil or ContID < 1 or ContID > ARCHAEOLOGY_NUM_CONTINENTS ) then
			ContID = 1;
		end
	end

    MinArch:DimADIButtons();
    MinArch.DigsiteButtons[ContID]:SetAlpha(1.0);

	local scrollf = MinArchDSScrollFrame or CreateFrame("ScrollFrame", "MinArchDSScrollFrame", MinArchDigsites);
	scrollf:SetClipsChildren(true)

	for i = 1, ARCHAEOLOGY_NUM_CONTINENTS do
		if (MinArchScrollDS[i]) then
			MinArchScrollDS[i]:Hide();
		end
	end

	MinArchScrollDS[ContID] = MinArchScrollDS[ContID] or CreateFrame("Frame", "MinArchScrollDS");
	local scrollc = MinArchScrollDS[ContID];

	MinArchScrollDS[ContID]:Show();

	local scrollb = MinArchScrollDSBar or CreateFrame("Slider", "MinArchScrollDSBar", MinArchDigsites);

	if (not scrollb.bg) then
		scrollb.bg = scrollb:CreateTexture(nil, "BACKGROUND");
		scrollb.bg:SetAllPoints(true);
		scrollb.bg:SetTexture(0, 0, 0, 0.80);
	end

	if (not scrollf.bg) then
		scrollf.bg = scrollf:CreateTexture(nil, "BACKGROUND");
		scrollf.bg:SetAllPoints(true);
		scrollf.bg:SetTexture(0, 0, 0, 0.60);
	end

	if (not scrollb.thumb) then
		scrollb.thumb = scrollb:CreateTexture(nil, "OVERLAY");
		scrollb.thumb:SetTexture("Interface\\Buttons\\UI-ScrollBar-Knob");
		scrollb.thumb:SetSize(25, 25);
		scrollb:SetThumbTexture(scrollb.thumb);
	end

	scrollc.digsites = scrollc.digsites or {};
	scrollc.mouseover = scrollc.mouseover or {};

	local PADDING = 5;

	local height = 0;
	local width = 301;

	local count = 1;

	for i=0,1 do
		for name,digsite in pairs(MinArchDigsitesGlobalDB["continent"][ContID]) do
			local status=false
			if MinArchDigsitesDB["continent"][ContID][name] then
				status = MinArchDigsitesDB["continent"][ContID][name]["status"]
			end
			if ((status and i == 0) or (status == false and i == 1)) then
				if not scrollc.digsites[count] then
					scrollc.digsites[count] = scrollc:CreateFontString("Digsite" .. count, "OVERLAY")
				end

				local currentDigSite = scrollc.digsites[count];
				currentDigSite:SetFontObject("ChatFontSmall");
				currentDigSite:SetWordWrap(true);
				currentDigSite:SetText(" "..name);
				if (status == true) then
					currentDigSite:SetTextColor(1.0, 1.0, 1.0, 1.0);
				else
					currentDigSite:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1);
				end

				local cwidth = currentDigSite:GetStringWidth()
				local cheight = currentDigSite:GetStringHeight()
				currentDigSite:SetSize(cwidth+5, cheight)

				if count == 1 then
					currentDigSite:SetPoint("TOPLEFT",scrollc, "TOPLEFT", 0, 0)
					height = height + cheight
				else
					currentDigSite:SetPoint("TOPLEFT", scrollc.digsites[count - 2], "BOTTOMLEFT", 0, - PADDING)
					height = height + cheight + PADDING
				end

				count = count+1;

				-- RACE

				if not scrollc.digsites[count] then
					scrollc.digsites[count] = scrollc:CreateFontString("Digsite" .. count, "OVERLAY")
				end

				currentDigSite = scrollc.digsites[count];
				currentDigSite:SetFontObject("ChatFontSmall");
				currentDigSite:SetWordWrap(true);

				currentDigSite:SetText(digsite["zone"]);

				if (status == true) then
					currentDigSite:SetTextColor(1.0, 1.0, 1.0, 1.0);
				else
					currentDigSite:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1);
				end

				cwidth = currentDigSite:GetStringWidth()
				cheight = currentDigSite:GetStringHeight()
				currentDigSite:SetSize(cwidth+5, cheight)

				if count == 2 then
				  currentDigSite:SetPoint("TOPRIGHT",scrollc, "TOPRIGHT", 0, 0)
				else
				  currentDigSite:SetPoint("TOPRIGHT", scrollc.digsites[count - 2], "BOTTOMRIGHT", 0, - PADDING);
				end

				-- Mouseover Frames Go Here

				if not scrollc.mouseover[count] then
					scrollc.mouseover[count] = CreateFrame("Frame", "MouseFrame");
				end

				local currentMO = scrollc.mouseover[count];
				currentMO:SetSize(width, cheight);
				currentMO:SetParent(scrollc);
				currentMO:SetPoint("BOTTOMRIGHT", currentDigSite, "BOTTOMRIGHT", 0, 0);

				currentMO:SetScript("OnMouseUp", function(self, button)
					if (button == "LeftButton") then
						MinArch:SetWayToDigsiteOnClick(name, digsite);
					end
				end)
				currentMO:SetScript("OnEnter", function(self)
					MinArch:DigsiteHistoryTooltip(self, name, digsite);
				end)
				currentMO:SetScript("OnLeave", function()
					MinArchTooltipIcon:Hide();
					GameTooltip:Hide()
				end)

				count = count+1
			end
		end
	end

	-- Set the size of the scroll child
	scrollc:SetSize(width, height-2)

	-- Size and place the parent frame, and set the scrollchild to be the
	-- frame of font strings we've created
	scrollf:SetSize(width, 241)
	scrollf:SetPoint("BOTTOMLEFT", MinArchDigsites, "BOTTOMLEFT", 12, 10)
	scrollf:SetScrollChild(scrollc)
	scrollf:Show()

	scrollc:SetSize(width, height-2)

	-- Set up the scrollbar to work properly
	local scrollMax = 0
	if height > 241 then
		scrollMax = height - 241
	end

	if (scrollMax == 0) then
		scrollb.thumb:Hide();
	else
		scrollb.thumb:Show();
	end

	scrollb:SetOrientation("VERTICAL");
	scrollb:SetSize(16, 241)
	scrollb:SetPoint("TOPLEFT", scrollf, "TOPRIGHT", 0, 0)
	scrollb:SetMinMaxValues(0, scrollMax)
	scrollb:SetValue(0)
	scrollb:SetScript("OnValueChanged", function(self)
		  scrollf:SetVerticalScroll(self:GetValue())
	end)

	-- Enable mousewheel scrolling
	scrollf:EnableMouseWheel(true)
	scrollf:SetScript("OnMouseWheel", function(self, delta)
		  local current = scrollb:GetValue()

		  if IsShiftKeyDown() and (delta > 0) then
			 scrollb:SetValue(0)
		  elseif IsShiftKeyDown() and (delta < 0) then
			 scrollb:SetValue(scrollMax)
		  elseif (delta < 0) and (current < scrollMax) then
			 scrollb:SetValue(current + 20)
		  elseif (delta > 0) and (current > 1) then
			 scrollb:SetValue(current - 20)
		  end
	end)

end

function MinArch:DimADIButtons()
    for i=1,ARCHAEOLOGY_NUM_CONTINENTS do
        MinArch.DigsiteButtons[i]:SetAlpha(0.5)
    end
end

function MinArch:ADIButtonTooltip(ContID)
	local uiMapID = MinArch:GetUiMapIdByContId(ContID);
	if (uiMapID ~= nil) then
		GameTooltip:SetOwner(MinArchDigsites, "ANCHOR_TOPLEFT");

		GameTooltip:AddLine(MinArch.MapContinents[uiMapID], 1.0, 1.0, 1.0, 1.0);
		GameTooltip:Show();
	end
end

function MinArch:UpdateActiveDigSitesRace(Race)
	local ax = 0;
	local ay = 0;
	local ContID = MinArch:GetInternalContId();

	local uiMapID = C_Map.GetBestMapForUnit("player");
	uiMapID = MinArch:GetNearestZoneId(uiMapID);
	if (ContID == nil or uiMapID == nil) then
		return false;
	end

	local playerPos = C_Map.GetPlayerMapPosition(uiMapID, "player");

	ax = playerPos.x * 100;
	ay = playerPos.y * 100;

	local nearestDistance = nil;
	local nearestDigSite = nil;

	for name,digsite in pairs(MinArchDigsitesGlobalDB["continent"][ContID]) do
		if (ax == nil or digsite["x"] == nil or ay == nil or digsite["y"] == nil) then
			MinArch:DisplayStatusMessage('MinArch: location error in ' .. GetZoneText() .. " " .. GetSubZoneText());
		else
			local xd = math.abs(ax - tonumber(digsite["x"]));
			local yd = math.abs(ay - tonumber(digsite["y"]));
			local d = math.sqrt((xd*xd)+(yd*yd));

			if (MinArchDigsitesDB["continent"][ContID][name] and MinArchDigsitesDB["continent"][ContID][name]["status"] == true) then
				if (nearestDigSite == nil) then
					nearestDigSite = name;
					nearestDistance = d;

				elseif (d < nearestDistance) then
					nearestDigSite = name;
					nearestDistance = d;

				end
			end
		end
	end

	if (nearestDistance ~= nil and CanScanResearchSite()) then
		MinArchDigsitesGlobalDB["continent"][tonumber(ContID)][nearestDigSite]["race"] = Race;
		MinArchDigsitesGlobalDB["continent"][tonumber(ContID)][nearestDigSite]["zone"] = GetZoneText();
		local subZone = GetSubZoneText();
		if (subZone ~= "") then
			MinArchDigsitesGlobalDB["continent"][tonumber(ContID)][nearestDigSite]["subzone"] = subZone;
		end
	end

	MinArch:ShowRaceIconsOnMap();
end

function MinArch:GetNearestDigsite()
	if (IsInInstance()) then
		return false;
    end

    local prioRace = MinArch.db.profile.TomTom.prioRace;

	local nearestDistance = nil;
	local nearestDigSite = nil;
	local nearestDigSiteDetails = nil;
	local ax = 0;
	local ay = 0;
	local ContID = MinArch:GetInternalContId();

	local uiMapID = MinArch:GetUiMapIdByContId(ContID);
	if (ContID == nil or uiMapID == nil) then
		return false;
	end

	local playerPos = C_Map.GetPlayerMapPosition(uiMapID, "player");
	if (playerPos == nil) then
		return false;
	end

	local continentID, worldPos = C_Map.GetWorldPosFromMapPos(uiMapID, playerPos);

	ax = worldPos.x;
	ay = worldPos.y;

	for key, digsite in pairs(C_ResearchInfo.GetDigSitesForMap(uiMapID)) do
        local name = tostring(digsite.name)
        local _, digsiteWorldPos = C_Map.GetWorldPosFromMapPos(uiMapID, digsite.position)
		local digsitex = digsiteWorldPos.x;
        local digsitey = digsiteWorldPos.y;

        local xd = math.abs(ax - tonumber(digsitex));
		local yd = math.abs(ay - tonumber(digsitey));
		local d = math.sqrt((xd*xd)+(yd*yd));

        if (MinArchDigsitesDB["continent"][ContID][name] and MinArchDigsitesDB["continent"][ContID][name]["status"] == true) then
			if (MinArchDigsiteList[name]) then
                local currentRace = MinArchDigsiteList[name].race;
                if ( (prioRace == currentRace and (nearestDistance == nil or nearestDigSiteDetails.raceId ~= prioRace or (nearestDigSiteDetails.raceId == prioRace and d < nearestDistance) ) )
                    or nearestDigSite == nil
                    or (nearestDigSiteDetails.raceId ~= prioRace and d < nearestDistance))
                then
                    nearestDigSite = name;
                    nearestDistance = d;
                    nearestDigSiteDetails = MinArchDigsitesGlobalDB["continent"][ContID][nearestDigSite];
                end
            else
                MinArch:DisplayStatusMessage("Missing race info for digsite: " .. name, MINARCH_MSG_DEBUG);
            end
		end
	end

	-- print("GetNearestDigsite", nearestDigSite, nearestDistance);
	return nearestDigSite, nearestDistance, nearestDigSiteDetails;
end

function MinArch:IsNearDigSite()
	return CanScanResearchSite(); -- Note to self: spend more time on WoWPedia
end

function MinArch:GetOrCreateMinArchMapFrame(i)
	if (MinArchMapFrames[i] == nil) then
		MinArchMapFrames[i] = CreateFrame("Frame", "MinArchMapFrame" .. i, WorldMapFrame.ScrollContainer.Child, "MATMapFrame");
	end

	return MinArchMapFrames[i];
end

function MinArch:ShowRaceIconsOnMap()
	for i=1, #MinArchMapFrames do
		MinArch:GetOrCreateMinArchMapFrame(i);
		MinArchMapFrames[i]:Hide();
	end

	local uiMapID = WorldMapFrame.mapID;
	if (WorldMapFrame:IsVisible() and uiMapID and GetCVarBool('digsites') and MinArch.db.profile.showWorldMapOverlay == true) then
		local count = 0;

		for key, digsite in pairs(C_ResearchInfo.GetDigSitesForMap(uiMapID)) do
			local pin = WorldMapFrame:AcquirePin("DigSitePinTemplate", digsite);
			local continentUiMapID = MinArch:GetNearestContinentId(uiMapID);
			local contID = MinArch:GetInternalContId(continentUiMapID);
			local name = digsite.name;
			local x = digsite.position.x;
			local y = digsite.position.y;

            count = count + 1;

			if not contID then
				if not SpamBlock[name] then
					MinArch:DisplayStatusMessage("Minimal Archaeology: Could not find continent for digsite "..name .. " " .. uiMapID)
					SpamBlock[name] = 1
				end
			else
				MinArch:GetOrCreateMinArchMapFrame(count);
				MinArch:SetIcon(MinArchMapFrames[count], x, y, tostring(name), MinArchDigsitesGlobalDB["continent"][contID][tostring(name)], pin)
			end
		end
	end
end

function MinArch:SetIcon(FRAME, X, Y, NAME, DETAILS, parentFrame)
	FRAME:SetScript("OnMouseUp", function(self, button)
		if (button == "LeftButton") then
			MinArch:SetWayToDigsiteOnClick(NAME, DETAILS);
		end
	end)
	FRAME:SetScript("OnEnter", function()
			MinArch:DigsiteMapTooltip(FRAME, NAME, DETAILS);
		end);
	FRAME:SetScript("OnLeave", function()
			MinArchTooltipIcon:Hide();
			MinArchTooltipIcon:SetParent(GameTooltip);
			MinArchTooltipIcon:SetPoint("TOPRIGHT", GameTooltip, "TOPLEFT");
			GameTooltip:Hide();
			GameTooltip:Hide();
		end);

	local RACE = tostring(DETAILS["race"]);

	local raceID = MinArch:GetRaceIdByName(RACE);
	local frameSize = 32;
	local iconSize = 16;
	local offsetX = 7;
	local offsetY = -7;

	FRAME:SetSize(frameSize, frameSize);
	FRAME.icon:SetSize(iconSize, iconSize);

	FRAME:SetParent(parentFrame);
	FRAME:SetPoint("BOTTOMLEFT", offsetX, offsetY);
	FRAME.icon:SetTexture("Interface/Icons/INV_MISC_QUESTIONMARK");
	FRAME.icon:SetTexCoord(0, 1, 0, 1);

	if (MinArch['artifacts'][raceID] and RACE == MinArch['artifacts'][raceID]['race']) then
		FRAME.icon:SetTexture(MinArch['artifacts'][raceID]['raceicon']);
		FRAME.icon:SetTexCoord(0.0234375, 0.5625, 0.078125, 0.625);
	end

	FRAME:Show();
end

function MinArch:DigsiteHistoryTooltip(self, name, digsite)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");

	MinArch:DigsiteTooltip(self, name, digsite, GameTooltip);
end

function MinArch:DigsiteMapTooltip(self, name, digsite)
	-- Use gametooltip if World Quest Tracker is installed to bypass the "slot machine"
	local tooltip = WorldQuestTrackerAddon and GameTooltip or GameTooltip;
	MinArchTooltipIcon:SetParent(tooltip);
	MinArchTooltipIcon:SetPoint("TOPRIGHT", tooltip, "TOPLEFT");
	tooltip:SetOwner(self, "ANCHOR_BOTTOM");

	MinArch:DigsiteTooltip(self, name, digsite, tooltip);
end

function MinArch:DigsiteTooltip(self, name, digsite, tooltip)
	local progress = 0;
	local project = "";
	local project_color = "ffffffff";
	local first_solve = "";
	local plural = "";

	local RACE = tostring(digsite["race"]);

	for i=1,ARCHAEOLOGY_NUM_RACES do
		if (RACE == MinArch['artifacts'][i]['race']) then
			MinArchTooltipIcon.icon:SetTexture(MinArch['artifacts'][i]['icon']);
			progress = MinArch['artifacts'][i]['progress'] .. "/" .. MinArch['artifacts'][i]['total'];
			project = MinArch['artifacts'][i]['project'];
			if (MinArch['artifacts'][i]['rarity'] == 1) then
				_,_,_,project_color = GetItemQualityColor(3);
			end
			if (tonumber(MinArch['artifacts'][i]['firstcomplete']) == 0) then
				first_solve = "New";
			end
		end
	end

	tooltip:AddLine(name, 1.0, 1.0, 1.0, 1.0);

	if (digsite['subzone'] == "") then
		digsite['subzone'] = " ";
	end

	local coords = ""
	if (digsite.x and digsite.y) then
		coords = " (" .. string.format("%.2f", digsite.x) .. ", " .. string.format("%.2f", digsite.y) .. ")";
	end

	tooltip:AddDoubleLine(digsite.subzone, digsite.zone, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	tooltip:AddDoubleLine(" ", coords, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);

	if (digsite['race'] ~= "Unknown" and digsite['race'] ~= nil) then
		if (project ~= nil) then
			tooltip:AddDoubleLine("Project: |c"..project_color..project, first_solve, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end
		tooltip:AddDoubleLine("Race: |cffffffff"..digsite['race'], "|cffffffff"..progress.." fragments", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		MinArchTooltipIcon:Show();
	end

	if (MinArch:IsNavigationEnabled()) then
		tooltip:AddLine("Hint: Left-Click to create waypoint here.", 0, 1, 0)
	end

	tooltip:Show();
end

function MinArch:HideDigsites()
	MinArchDigsites:Hide();
	MinArch.db.char.WindowStates.digsites = false;
end

function MinArch:ShowDigsites()
	--if (UnitAffectingCombat("player")) then
	--	MinArchDigsites.showAfterCombat = true;
	--else
		MinArchDigsites:Show();
		MinArch.db.char.WindowStates.digsites = true;
	--end
end

function MinArchDigsites:Toggle()
	if (MinArchDigsites:IsVisible()) then
		MinArch:HideDigsites();
	else
		MinArch:ShowDigsites();
	end
end
