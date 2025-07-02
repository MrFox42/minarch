local ADDON, _ = ...

---@class MinArchDigsites
local Digsites = MinArch:LoadModule("MinArchDigsites")
Digsites.frame = _G["MinArchDigsites"]

---@type MinArchCommon
local Common = MinArch:LoadModule("MinArchCommon")
---@type MinArchNavigation
local Navigation = MinArch:LoadModule("MinArchNavigation")
---@type HereBeDragons-2.0
local HBD = LibStub("HereBeDragons-2.0")

local L = LibStub("AceLocale-3.0"):GetLocale("MinArch")

local MinArchTooltipIcon = _G["MinArchTooltipIcon"]
local TaxiToggleFrame = nil -- created later
local DigsitesScrollbar = nil -- created later
local DigsitesScrollFrame = nil -- created later

MinArchScrollDS = {}
MinArchDigsitesDB = {} -- old dig site info per character
MinArchDigsitesGlobalDB = {} -- global dig site information
MinArchMapFrames = {}
MinArchTaxiMapFrames = {}

MinArchDigsitesGlobalDB["continent"] = {
	[1]  = {}, --Kalimdor
	[2]  = {}, --Eastern Kingdoms
	[3]  = {}, --Outlands
	[4]  = {}, --Northrend
	[5]  = {}, -- The Maelstrom (no dig sites)
	[6]  = {}, -- Pandaria
	[7]  = {}, -- Draenor
	[8]  = {}, -- Broken Isles
	[9]  = {}, -- Zandalar
	[10] = {}, -- Kul Tiras
}

MinArchDigsitesDB["continent"] = {
	[1]  = {}, --Kalimdor
	[2]  = {}, --Eastern Kingdoms
	[3]  = {}, --Outlands
	[4]  = {}, --Northrend
	[5]  = {}, -- The Maelstrom (no dig sites)
	[6]  = {}, -- Pandaria
	[7]  = {}, -- Draenor
	[8]  = {}, -- Broken Isles
	[9]  = {}, -- Zandalar
	[10] = {}, -- Kul Tiras
}

local function DimADIButtons()
    for i=1,ARCHAEOLOGY_NUM_CONTINENTS do
        MinArch.DigsiteButtons[i]:SetAlpha(0.5)
    end
end

---@param ContID integer
local function ADIButtonTooltip(ContID)
	local uiMapID = Common:GetUiMapIdByContId(ContID);
	if (uiMapID ~= nil) then
		GameTooltip:SetOwner(Digsites.frame, "ANCHOR_TOPLEFT");

		GameTooltip:AddLine(MinArch.MapContinents[uiMapID], 1.0, 1.0, 1.0, 1.0);
		GameTooltip:Show();
	end
end

local function DigSiteSort(a, b)
	if (a.prio ~= b.prio) then
		return a.prio < b.prio
	end

	if MinArch.db.profile.TomTom.optimizePath and a.pathDistance and b.pathDistance and a.pathDistance ~= b.pathDistance then -- path mode
		return a.pathDistance < b.pathDistance
	else
		return a.distance < b.distance
	end
end

local function CalculateDigSitePathDistance(ax, ay, sites, pathDistance)
	local pathDistance = pathDistance or 0

	local name, distance, details = Digsites:GetNearestDigsite(ax, ay, sites, true)

	for key, site in pairs(sites) do
		if site.name == name then
			-- print("    " .. site.name, distance)
			table.remove(sites, key)
		end
	end

	pathDistance = (pathDistance + distance) * MinArch.db.profile.TomTom.optimizationModifier

	if #sites > 0 and details then
		return CalculateDigSitePathDistance(details.ax, details.ay, sites, pathDistance)
	else
		-- print(unpack(path))
		return pathDistance
	end
end

local function DigsiteTooltip(self, name, digsite, tooltip, taxiNode)
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
				_,_,_,project_color = C_Item.GetItemQualityColor(3);
			end
			if (tonumber(MinArch['artifacts'][i]['firstcomplete']) == 0) then
				first_solve = L["TOOLTIP_NEW"];
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
			tooltip:AddDoubleLine(L["TOOLTIP_PROJECT"] .. ": |c"..project_color..project, first_solve, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end
		tooltip:AddDoubleLine(L["TOOLTIP_RACE"] .. ": |cffffffff"..digsite['race'], "|cffffffff"..progress.." " .. L["TOOLTIP_FRAGMENTS"], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		MinArchTooltipIcon:Show();
	end

	if (Navigation:IsNavigationEnabled() and not taxiNode) then
		tooltip:AddLine(L["TOOLTIP_DIGSITE_WP"], 0, 1, 0)
	end

	if taxiNode then
		tooltip:AddLine(L["TOOLTIP_DIGSITE_TAXI_TRAVEL"], 0, 1, 0)
	end

	tooltip:Show();
end

local function DigsiteMapTooltip(self, name, digsite, taxiNode)
	-- Use gametooltip if World Quest Tracker is installed to bypass the "slot machine"
	local tooltip = _G["WorldQuestTrackerAddon"] and GameTooltip or GameTooltip;
	MinArchTooltipIcon:SetParent(tooltip);
	MinArchTooltipIcon:SetPoint("TOPRIGHT", tooltip, "TOPLEFT");
	tooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");

	DigsiteTooltip(self, name, digsite, tooltip, taxiNode);
end

local function GetOrCreateMinArchMapFrame(i)
	if (MinArchMapFrames[i] == nil) then
		MinArchMapFrames[i] = CreateFrame("Frame", "MinArchMapFrame" .. i, WorldMapFrame.ScrollContainer.Child, "MATMapFrame");
	end

	return MinArchMapFrames[i];
end

local function GetOrCreateMinArchTaxiMapFrame(i)
	if (MinArchTaxiMapFrames[i] == nil) then
		MinArchTaxiMapFrames[i] = CreateFrame("Frame", "MinArchTaxiMapFrame" .. i, MinArch.HelperFrame, "MATMapFrame");
	end

	return MinArchTaxiMapFrames[i];
end

local function AcquireTaxiMapPin(nodeName)
	for pin in FlightMapFrame:EnumeratePinsByTemplate("FlightMap_FlightPointPinTemplate") do
		if (pin.taxiNodeData) then
			local nodeType = TaxiNodeGetType(pin.taxiNodeData.slotIndex)
			-- print(pin.taxiNodeData.name, nodeName, pin.taxiNodeData.textureKit, nodeType)
			if (pin.taxiNodeData.name == nodeName and not pin.taxiNodeData.textureKit and (nodeType == "REACHABLE" or nodeType == "CURRENT")) then
				return pin
			end
		end
	end
end

local function AcquireMapPin(nodeName)
	for pin in WorldMapFrame:EnumeratePinsByTemplate("DigSitePinTemplate") do
		if pin.name == nodeName then
			return pin
		end
	end
end

local function SetRaceIcon(FRAME, X, Y, NAME, DETAILS, parentFrame, taxiNode)
	FRAME:SetScript("OnMouseUp", function(self, button)
		if (button == "LeftButton") then
			if (taxiNode) then
				TakeTaxiNode(taxiNode)
				Navigation.waypointOnLanding = true
				Navigation:ClearAllDigsiteWaypoints()
			else
				Navigation:SetWayToDigsiteOnClick(NAME, DETAILS)
			end
		end
	end)
	FRAME:SetScript("OnEnter", function()
		if taxiNode then
			if FlightMapFrame then
				parentFrame.owner:HighlightRouteToPin(parentFrame)
			else
				TaxiNodeOnButtonEnter(parentFrame)
			end
		end

		DigsiteMapTooltip(FRAME, NAME, DETAILS, taxiNode)
	end);
	FRAME:SetScript("OnLeave", function()
		MinArchTooltipIcon:Hide();
		MinArchTooltipIcon:SetParent(GameTooltip);
		MinArchTooltipIcon:SetPoint("TOPRIGHT", GameTooltip, "TOPLEFT")
		GameTooltip:Hide();
		GameTooltip:Hide();

		if taxiNode then
			if FlightMapFrame then
				parentFrame.owner:RemoveRouteToPin(parentFrame)
			else
				TaxiNodeOnButtonLeave(parentFrame)
			end
		end
	end);

	local RACE = tostring(DETAILS["race"]);

	local raceID = Common:GetRaceIdByName(RACE);
	local frameSize = 32;
	local iconSize = 16;
	local offsetX = 7;
	local offsetY = -7;

	if taxiNode then
		frameSize = 24
		iconSize = 18
		offsetX = 5
		offsetY = -10

		if FlightMapFrame then
			frameSize = 32
			iconSize = 28
		end
	end


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

function Digsites:Init()
	local continents = C_Map.GetMapChildrenInfo(947, 2);
	for k, v in pairs(continents) do
		MinArch.MapContinents[v.mapID] = v.name;
	end
	continents = C_Map.GetMapChildrenInfo(946, 2);
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
        local button = CreateFrame("Button", "$parent" .. continentButtons[i] .. "Button", Digsites.frame, nil, i)
        button.parentKey = continentButtons[i] .. "Button";

        button:SetPoint("TOPLEFT", Digsites.frame, "TOPLEFT", 15 + (counter - 1) * 35, -20);
        button:SetWidth(32)
        button:SetHeight(32);

        if continentTextures[i] then
            button:SetNormalTexture(continentTextures[i]);
            button:SetPushedTexture(continentTextures[i]);
            button:SetHighlightTexture(continentTextures[i], "ADD");
        end

        button:SetScript("OnClick", function ()
            Digsites:CreateDigSitesList(i);
            Digsites:CreateDigSitesList(i);
        end);
        button:SetScript("OnEnter", function ()
            ADIButtonTooltip(i);
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

	Digsites.frame:SetScript("OnEvent", function(_, event, ...)
		MinArch:EventDigsites(event, ...);
    end)

	Digsites.frame.closeButton:SetScript("OnClick", function()
		Digsites:HideWindow()
	end)

	Digsites.wpButton = Common:CreateAutoWaypointButton(Digsites.frame, 15, 3);
	Digsites.frame:SetScript("OnShow", function()
		if (Navigation:IsNavigationEnabled()) then
			Digsites.wpButton:Show();
		else
			Digsites.wpButton:Hide();
		end
    end)

	Digsites.frame:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE");
	Digsites.frame:RegisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED");
	-- Digsites.frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	Digsites.frame:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST");
	Digsites.frame:RegisterEvent("PLAYER_ALIVE");
	Digsites.frame:RegisterEvent("ZONE_CHANGED");
	Digsites.frame:RegisterEvent("ZONE_CHANGED_INDOORS");
	Digsites.frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	Digsites.frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	Digsites.frame:RegisterEvent("TAXIMAP_OPENED")
	Digsites.frame:RegisterEvent("PLAYER_CONTROL_GAINED")
	-- Digsites.frame:RegisterEvent("PLAYER_CONTROL_LOST")
	hooksecurefunc(MapCanvasDetailLayerMixin, "SetMapAndLayer", MinArch_MapLayerChanged);
	-- hooksecurefunc("ToggleWorldMap", MinArch_WorldMapToggled);
	WorldMapFrame:HookScript("OnShow", MinArch_WorldMapToggled);
    hooksecurefunc("ShowUIPanel", MinArch_ShowUIPanel);

    Common:FrameLoad(Digsites.frame);

	if not MinArch.db.profile.TomTom.taxi.enabled or not MinArch.db.profile.TomTom.taxi.autoDisableArchMode then
		MinArch.db.profile.TomTom.taxi.archMode = false
	end

	Common:DisplayStatusMessage("Minimal Archaeology Digsites Initialized!");
end

-- don't spam about unknown digsites, only once each
local SpamBlock = {}

function Digsites:UpdateActiveDigSites()
	MinArch.RelevantRaces = {};
	-- can't do anything until all races are known
	if GetNumArchaeologyRaces() < ARCHAEOLOGY_NUM_RACES then
		return
	end
	-- also digsite list must be initialized
	if not MinArchDigsiteList then
		return
	end

	local playerContID = Common:GetInternalContId();

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

        local zoneUiMapID = Common:GetUiMapIdByContId(i);
		if not zoneUiMapID then
			return
		end

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
				local digsiteZone = C_Map.GetMapInfoAtPosition(uiMapID, x, y);
                -- Workaround for the phased version of Vale of Eternal Blossoms
                if uiMapID == 390 then
                    digsiteZone = C_Map.GetMapInfo(uiMapID);
                end
				local continentUiMapID = Common:GetNearestContinentId(uiMapID);
				local contID = Common:GetInternalContId(continentUiMapID);

				MinArchDigsitesGlobalDB["continent"][i][name] = MinArchDigsitesGlobalDB["continent"][i][name] or {};
				MinArchDigsitesDB      ["continent"][i][name] = MinArchDigsitesDB["continent"][i][name] or {};

				-- if we don't have this in the DB yet, try to use the race from the digsite list
				-- if not MinArchDigsitesGlobalDB["continent"][i][name]["race"] or MinArchDigsitesGlobalDB["continent"][i][name]["race"] == "Unknown" then
					if MinArchDigsiteList[contID][name] then
						local race = GetArchaeologyRaceInfo(MinArchDigsiteList[contID][name].race)
                        MinArchDigsitesGlobalDB["continent"][i][name]["race"] = race
                        MinArchDigsitesGlobalDB["continent"][i][name]["raceId"] = MinArchDigsiteList[contID][name].race
					elseif not SpamBlock[name] then
						Common:DisplayStatusMessage("Minimal Archaeology: Unknown digsite " .. name, MINARCH_MSG_STATUS)
						SpamBlock[name] = 1
					end
				--end

				-- TODO: remove digsites assigned to the wrong continent in old/buggy releases
                local currentZoneUiMapID = Common:GetNearestZoneId(digsiteZone.mapID);
				if (currentZoneUiMapID ~= nil and (currentZoneUiMapID == uiMapID or currentZoneUiMapID == digsiteZone.parentMapID)) then
					if (playerContID == i and MinArchDigsiteList[contID][name]) then
						MinArch.RelevantRaces[MinArchDigsiteList[contID][name].race] = true;
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

	Digsites:ShowRaceIconsOnMap();
end

---@param ContID integer|nil
function Digsites:CreateDigSitesList(ContID)
	if (not ContID or ContID < 1 or ContID > ARCHAEOLOGY_NUM_CONTINENTS ) then
		ContID = Common:GetInternalContId();

		if (ContID == nil or ContID < 1 or ContID > ARCHAEOLOGY_NUM_CONTINENTS ) then
			ContID = 1;
		end
	end

    DimADIButtons();
    MinArch.DigsiteButtons[ContID]:SetAlpha(1.0);

	local scrollf = DigsitesScrollFrame or CreateFrame("ScrollFrame", "MinArchDSScrollFrame", Digsites.frame);
	scrollf:SetClipsChildren(true)

	for i = 1, ARCHAEOLOGY_NUM_CONTINENTS do
		if (MinArchScrollDS[i]) then
			MinArchScrollDS[i]:Hide();
		end
	end

	MinArchScrollDS[ContID] = MinArchScrollDS[ContID] or CreateFrame("Frame", "MinArchScrollDS");
	local scrollc = MinArchScrollDS[ContID];

	MinArchScrollDS[ContID]:Show();

	local scrollb = DigsitesScrollbar or CreateFrame("Slider", "MinArchScrollDSBar", Digsites.frame);

	if (not scrollb.bg) then
		scrollb.bg = scrollb:CreateTexture(nil, "BACKGROUND");
		scrollb.bg:SetAllPoints();
		-- scrollb.bg:SetColorTexture(0, 0, 0, 0.80);
	end

	if (not scrollf.bg) then
		scrollf.bg = scrollf:CreateTexture(nil, "BACKGROUND");
		scrollf.bg:SetAllPoints();
	end

	if (not scrollb.thumb) then
		scrollb.thumb = scrollb:CreateTexture(nil, "OVERLAY");
		scrollb.thumb:SetTexture("Interface\\Buttons\\UI-ScrollBar-Knob");
		scrollb.thumb:SetSize(25, 25);
		scrollb:SetThumbTexture(scrollb.thumb);
	end

	DigsitesScrollbar = scrollb
	DigsitesScrollFrame = scrollf

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
					scrollc.digsites[count] = scrollc:CreateFontString(L["DIGSITES_DIGSITE"] .. count, "OVERLAY")
				end

				local currentDigSite = scrollc.digsites[count];
				currentDigSite:SetFontObject("ChatFontSmall");
				currentDigSite:SetWordWrap(true);
				local text = " " .. name
				if digsite.race then
                    text = text .. " - " .. digsite.race
                end
				currentDigSite:SetText(text);
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
					scrollc.digsites[count] = scrollc:CreateFontString(L["DIGSITES_DIGSITE"] .. count, "OVERLAY")
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
						Navigation:SetWayToDigsiteOnClick(name, digsite);
					end
				end)
				currentMO:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
					DigsiteTooltip(self, name, digsite, GameTooltip);
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
	scrollf:SetPoint("BOTTOMLEFT", Digsites.frame, "BOTTOMLEFT", 12, 10)
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

---@param Race string
function Digsites:UpdateActiveDigSitesRace(Race)
	local ax = 0;
	local ay = 0;
	local ContID = Common:GetInternalContId();

	local uiMapID = C_Map.GetBestMapForUnit("player");
	uiMapID = Common:GetNearestZoneId(uiMapID);
	if (ContID == nil or uiMapID == nil) then
		return false;
	end

	local playerPos = C_Map.GetPlayerMapPosition(uiMapID, "player");
	if not playerPos then
		return false
	end

	ax = playerPos.x * 100;
	ay = playerPos.y * 100;

	local nearestDistance = nil;
	local nearestDigSite = nil;

	for name,digsite in pairs(MinArchDigsitesGlobalDB["continent"][ContID]) do
		if (ax == nil or digsite["x"] == nil or ay == nil or digsite["y"] == nil) then
			Common:DisplayStatusMessage('MinArch: location error in ' .. GetZoneText() .. " " .. GetSubZoneText());
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

	Digsites:ShowRaceIconsOnMap();
end

-- function MinArch:ConvertMapPosToWorldPosIfNeeded(contID, uiMapID, position, force)
--     if (contID ~= 1 and contID ~= 2) or force then
--         local _, worldPos = C_Map.GetWorldPosFromMapPos(uiMapID, position)
--         return worldPos.x, worldPos.y
--     end
--
--     return position.x, position.y
-- end

---@param ax? number @X coordinate, default: player X
---@param ay? number @Y coordinate, default: player Y
---@param sites? table @List of digsites, default: all digsites
---@param skipPathCalc? boolean @Skip path calculation, default: false
---@return string|nil name @Digsite name
---@return number|nil distance @Distance to digsite
---@return table|nil digsite @Digsite details
---@return number|nil priority @Digsite priority based on user settings
---@return number|nil pathDistance @Distance to digsite with path optimization
function Digsites:GetNearestDigsite(ax, ay, sites, skipPathCalc)
	if (IsInInstance()) then
		return nil;
    end

	local nDigsite, nDistance, nDetails, nPrio

    local contID = Common:GetInternalContId();

	local uiMapID = Common:GetUiMapIdByContId(contID);
	if (contID == nil or uiMapID == nil) then
		return nil;
	end

	local playerPos = C_Map.GetPlayerMapPosition(uiMapID, "player")
	if (playerPos == nil) then
		return nil;
	end
	local sites = sites or C_ResearchInfo.GetDigSitesForMap(uiMapID)

	local pX, pY, instance = HBD:GetPlayerWorldPosition()
	if not ax or not ay then
    	-- ax, ay = MinArch:ConvertMapPosToWorldPosIfNeeded(contID, uiMapID, playerPos)
		-- ax, ay = HBD:GetWorldCoordinatesFromZone(playerPos.x, playerPos.y, uiMapID)
		ax = pX
		ay = pY
	end

	local digsites = {}
	for key, digsite in pairs(sites) do
        local name = tostring(digsite.name)
		-- local digsitex, digsitey = MinArch:ConvertMapPosToWorldPosIfNeeded(contID, uiMapID, digsite.position)
		local dX, dY = HBD:GetWorldCoordinatesFromZone(digsite.position.x, digsite.position.y, uiMapID)

        -- local xd = math.abs(ax - tonumber(digsitex))
		-- local yd = math.abs(ay - tonumber(digsitey))
		-- local d = math.sqrt((xd*xd)+(yd*yd))
		local _, d = HBD:GetWorldVector(instance, ax, ay, dX, dY)
		-- d = math.floor(d)

        if (MinArchDigsitesDB["continent"][contID][name] and MinArchDigsitesDB["continent"][contID][name]["status"] == true) then
			if (not MinArchDigsiteList[contID][name]) then
				Common:DisplayStatusMessage("Missing race info for digsite: " .. name, MINARCH_MSG_DEBUG);
			end

			local currentRace = MinArchDigsiteList[contID][name] and MinArchDigsiteList[contID][name].race or nil;
			local details = MinArchDigsitesGlobalDB["continent"][contID][name]
			details.ax = dX
			details.ay = dY
			-- details.ax = digsitex
			-- details.ay = digsitey

			local prio = 99
			if currentRace then
				prio = MinArch.db.profile.raceOptions.priority[currentRace]
				if not prio or prio == 0 then
					prio = 99
				end
				if MinArch.db.profile.raceOptions.hide[currentRace] and MinArch.db.profile.TomTom.ignoreHidden then
					prio = 100
				end
			end

			digsites[key] = {
				name = name,
				distance = d,
				position = digsite.position,
				prio = prio,
				details = details
			}
		end
	end

	-- IF path mode is enabled
	if MinArch.db.profile.TomTom.optimizePath and not skipPathCalc then
		-- print("------")
		for key, digsite in pairs(digsites) do
			digsite.pathDistance = digsite.distance
			local tmp = {unpack(digsites)}
			table.remove(tmp, key)
			digsite.pathDistance = CalculateDigSitePathDistance(digsite.details.ax, digsite.details.ay, tmp, digsite.pathDistance)
			tmp = nil
			-- print(digsite.name, digsite.distance, digsite.pathDistance)
		end
	end

	if #digsites > 0 then
		table.sort(digsites, DigSiteSort)

	    -- print("GetNearestDigsite", digsites[1].name, digsites[1].distance, digsites[1].prio)
		return digsites[1].name, digsites[1].distance, digsites[1].details, digsites[1].prio, digsites[1].pathDistance
	end

	if MinArch.db.profile.TomTom.taxi.autoDisableArchMode then
		MinArch.db.profile.TomTom.taxi.archMode = false
	end

	return nDigsite, nDistance, nDetails, nPrio;
end

function Digsites:IsPlayerNearDigSite()
	return CanScanResearchSite(); -- Note to self: spend more time on WoWPedia
end

function Digsites:UpdateFlightMap()
	if (IsInInstance()) then
		return nil
    end

	if not TaxiToggleFrame then
		TaxiToggleFrame = CreateFrame("Button", "MinArchTaxiToggle", FlightMapFrame and FlightMapFrame.ScrollContainer or TaxiRouteMap);
		TaxiToggleFrame:RegisterForClicks("AnyUp", "AnyDown")
		TaxiToggleFrame:SetSize(32, 32)
		TaxiToggleFrame:SetPoint("TOPRIGHT", -5, -5)

		local bgTex = TaxiToggleFrame:CreateTexture("$parentBackground", "BACKGROUND")
		bgTex:SetPoint("TOPLEFT", TaxiToggleFrame, "TOPLEFT", 2, -4)
		bgTex:SetSize(25, 25)
		bgTex:SetTexture("Interface\\Minimap\\UI-Minimap-Background")

		local artTex = TaxiToggleFrame:CreateTexture("$parentArtwork", "ARTWORK")
		artTex:SetPoint("TOPLEFT", TaxiToggleFrame, "TOPLEFT", 6, -6)
		artTex:SetSize(20, 20)
		artTex:SetTexture("Interface\\Icons\\Trade_Archaeology_Dinosaurskeleton")

		local overlayTex = TaxiToggleFrame:CreateTexture("$parentOverlay", "OVERLAY")
		overlayTex:SetPoint("TOPLEFT", TaxiToggleFrame)
		overlayTex:SetSize(54, 54)
		overlayTex:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

		TaxiToggleFrame:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
		TaxiToggleFrame:SetPushedTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Down")

		TaxiToggleFrame:SetScript("OnMouseUp", function(self, button)
			if (button == "LeftButton") then
				MinArch.db.profile.TomTom.taxi.archMode = not MinArch.db.profile.TomTom.taxi.archMode
				Digsites:UpdateFlightMap()
			end
		end)

		TaxiToggleFrame:SetScript("OnEnter", function(self, button)
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
			GameTooltip:AddLine(L["TOOLTIP_TAXIFRAME_TOGGLE_DIGSITE"])

			GameTooltip:Show()
		end)

		TaxiToggleFrame:SetScript("OnLeave", function(self, button)
			GameTooltip:Hide()
		end)
	end

	local contID = Common:GetInternalContId();
	local uiMapID = Common:GetUiMapIdByContId(contID);
	if (contID == nil or uiMapID == nil) then
		return;
	end
	local zoneUiMapID = C_Map.GetBestMapForUnit("player")
	local _, _, instance = HBD:GetPlayerWorldPosition()
	local taxiNodes = C_TaxiMap.GetAllTaxiNodes(uiMapID)

	if not MinArch.db.profile.TomTom.taxi.archMode then
		for idx, taxiNode in ipairs(taxiNodes) do
			if FlightMapFrame then
				local pin = AcquireTaxiMapPin(taxiNode.name)
				if pin then
					pin:SetAlphaLimits(2.0, 1, 1)
					pin:SetAlpha(1)
				end
			else
				_G["TaxiButton" .. idx]:SetAlpha(1)
			end
		end

		for _, icon in pairs(MinArchTaxiMapFrames) do
			icon:Hide()
		end

		return
	end

	local playerPos = C_Map.GetPlayerMapPosition(uiMapID, "player")
	if (playerPos == nil) then
		return false;
	end
	local sites = C_ResearchInfo.GetDigSitesForMap(uiMapID)

	local taxiNodeIDs = {}
	local digsiteByNode = {}
	local node, nodeName, nodeID, distance
	for key, digsite in pairs(sites) do
		local name = tostring(digsite.name)
		-- local digsitex, digsitey = MinArch:ConvertMapPosToWorldPosIfNeeded(contID, uiMapID, digsite.position, true)
		local digsitex, digsitey = HBD:GetWorldCoordinatesFromZone(digsite.position.x, digsite.position.y, uiMapID)

		for idx, taxiNode in pairs(taxiNodes) do
			--local nodex, nodey = MinArch:ConvertMapPosToWorldPosIfNeeded(contID, zoneUiMapID, taxiNode.position, true)
			local nodex, nodey = HBD:GetWorldCoordinatesFromZone(taxiNode.position.x, taxiNode.position.y, uiMapID)
			--local xd = math.abs(nodex - tonumber(digsitex))
			--local yd = math.abs(nodey - tonumber(digsitey))
			--local d = math.sqrt((xd*xd)+(yd*yd))
			local _, d = HBD:GetWorldVector(instance, digsitex, digsitey, nodex, nodey)
			-- print(instance, digsitex, digsitey, nodex, nodey)

			local nodeType = TaxiNodeGetType(taxiNode.slotIndex or idx)
			if (nodeType == "REACHABLE" or nodeType == "CURRENT") and not taxiNode.textureKit and (not distance or d < distance) then
				node = taxiNode
				nodeName = taxiNode.name
				distance = d
				nodeID = taxiNode.slotIndex or idx
			end
		end
		digsiteByNode[nodeID] = digsite
		table.insert(taxiNodeIDs, {
			id = nodeID,
			name = nodeName
		})
		distance = nil
		-- print(name, nodeName, nodeID)
	end

	for idx,taxiNode in ipairs(taxiNodes) do
		if FlightMapFrame then
			local pin = AcquireTaxiMapPin(taxiNode.name)
			if pin then
				pin.OnAddAnim:Stop()
				pin:SetAlphaLimits(2.0, MinArch.db.profile.TomTom.taxi.alpha / 100, MinArch.db.profile.TomTom.taxi.alpha / 100)
				pin:SetAlpha(MinArch.db.profile.TomTom.taxi.alpha / 100)
			end
		else
			_G["TaxiButton" .. idx]:SetAlpha(MinArch.db.profile.TomTom.taxi.alpha / 100)
		end
	end

	local i = 1
	for _, node in pairs(taxiNodeIDs) do
		local idx = node.id
		local digsite = digsiteByNode[idx]
		local pin
		GetOrCreateMinArchTaxiMapFrame(i)
		if FlightMapFrame then
			pin = AcquireTaxiMapPin(node.name)
			pin:SetAlphaLimits(2.0, 1.0, 1.0)
			pin:SetAlpha(1.0)
		else
			pin = _G["TaxiButton" .. idx]
			pin:SetAlpha(1)
		end
		SetRaceIcon(MinArchTaxiMapFrames[i], digsite.position.x, digsite.position.y, tostring(digsite.name), MinArchDigsitesGlobalDB["continent"][contID][tostring(digsite.name)], pin, idx)
		i = i + 1
	end
end

function Digsites:ShowRaceIconsOnMap()
	for i=1, #MinArchMapFrames do
		GetOrCreateMinArchMapFrame(i);
		MinArchMapFrames[i]:Hide();
	end

	local uiMapID = WorldMapFrame.mapID;
	if (WorldMapFrame:IsVisible() and uiMapID and GetCVarBool('digsites') and MinArch.db.profile.showWorldMapOverlay == true) then
		local count = 0;

		for key, digsite in pairs(C_ResearchInfo.GetDigSitesForMap(uiMapID)) do
			local pin
			if MINARCH_EXPANSION == 'Cata' or MINARCH_EXPANSION == 'MoP' then
				pin = WorldMapFrame:AcquirePin("DigSitePinTemplate", digsite)
			else
				pin = AcquireMapPin(digsite.name)
			end
			if not pin then
				if not SpamBlock[digsite.name .. 'pin'] then
					Common:DisplayStatusMessage("Minimal Archaeology: Could not find pin for digsite "..digsite.name .. " " .. uiMapID)
					SpamBlock[digsite.name .. 'pin'] = 1
				end
				return
			end
			pin.startScale = MinArch.db.profile.mapPinScale / 100;
			local continentUiMapID = Common:GetNearestContinentId(uiMapID);
			local contID = Common:GetInternalContId(continentUiMapID);
			local name = digsite.name;
			local x = digsite.position.x;
			local y = digsite.position.y;

            count = count + 1;

			if not contID then
				if not SpamBlock[name] then
					Common:DisplayStatusMessage("Minimal Archaeology: Could not find continent for digsite "..name .. " " .. uiMapID)
					SpamBlock[name] = 1
				end
			else
				GetOrCreateMinArchMapFrame(count);
				SetRaceIcon(MinArchMapFrames[count], x, y, tostring(name), MinArchDigsitesGlobalDB["continent"][contID][tostring(name)], pin)
			end
		end
	end
end

function Digsites:HideWindow()
	Digsites.frame:Hide();
	MinArch.db.char.WindowStates.digsites = false;
end

function Digsites:ShowWindow()
	--if (UnitAffectingCombat("player")) then
	--	Digsites.showAfterCombat = true;
	--else
		Digsites.frame:Show();
		MinArch.db.char.WindowStates.digsites = MinArch.db.profile.rememberState;
	--end
end

function Digsites:ToggleWindow()
	if (Digsites.frame:IsVisible()) then
		Digsites:HideWindow();
	else
		Digsites:ShowWindow();
	end
end
