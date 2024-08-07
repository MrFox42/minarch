local ADDON, MinArch = ...

-- Local variables
local ResearchBranchMap = {
	[1] = ARCHAEOLOGY_RACE_DWARF, -- Dwarf
	[2] = ARCHAEOLOGY_RACE_DRAENEI, -- Draenei
	[3] = ARCHAEOLOGY_RACE_FOSSIL, -- Fossil
	[4] = ARCHAEOLOGY_RACE_NIGHTELF, -- Night Elf
	[5] = ARCHAEOLOGY_RACE_NERUBIAN, -- Nerubian
	[6] = ARCHAEOLOGY_RACE_ORC, -- Orc
	[7] = ARCHAEOLOGY_RACE_TOLVIR, -- Tol\'vir
	[8] = ARCHAEOLOGY_RACE_TROLL, -- Troll
	[27] = ARCHAEOLOGY_RACE_VRYKUL, -- Vrykul
	[29] = ARCHAEOLOGY_RACE_MANTID, -- Mantid
	[229] = ARCHAEOLOGY_RACE_PANDAREN, -- Pandaren
	[231] = ARCHAEOLOGY_RACE_MOGU, -- Mogu
	[315] = ARCHAEOLOGY_RACE_ARAKKOA, -- Arakkoa
	[350] = ARCHAEOLOGY_RACE_DRAENOR, -- Draenor Clans
	[382] = ARCHAEOLOGY_RACE_OGRE, -- Ogre
	[404] = ARCHAEOLOGY_RACE_HIGHBORNE, -- Highborne
	[406] = ARCHAEOLOGY_RACE_HIGHMOUNTAIN_TAUREN, -- Highmountain Tauren
	[408] = ARCHAEOLOGY_RACE_DEMONIC, -- Demonic
	[423] = ARCHAEOLOGY_RACE_ZANDALARI, -- Zandalari
	[424] = ARCHAEOLOGY_RACE_DRUSTVARI, -- Drust
};

local MinArchContinentRaces = {
	[1] = {ARCHAEOLOGY_RACE_TOLVIR, ARCHAEOLOGY_RACE_TROLL, ARCHAEOLOGY_RACE_NIGHTELF, ARCHAEOLOGY_RACE_FOSSIL, ARCHAEOLOGY_RACE_DWARF}, -- Kalimdor
	[2] = {ARCHAEOLOGY_RACE_TOLVIR, ARCHAEOLOGY_RACE_TROLL, ARCHAEOLOGY_RACE_NIGHTELF, ARCHAEOLOGY_RACE_FOSSIL, ARCHAEOLOGY_RACE_DWARF, ARCHAEOLOGY_RACE_NERUBIAN}, -- EK
	[3] = {ARCHAEOLOGY_RACE_ORC, ARCHAEOLOGY_RACE_DRAENEI}, -- Outland
	[4] = {ARCHAEOLOGY_RACE_VRYKUL, ARCHAEOLOGY_RACE_NERUBIAN, ARCHAEOLOGY_RACE_NIGHTELF, ARCHAEOLOGY_RACE_TROLL}, -- Northrend
	[5] = {}, -- Maelstrom
	[6] = {ARCHAEOLOGY_RACE_MOGU, ARCHAEOLOGY_RACE_PANDAREN, ARCHAEOLOGY_RACE_MANTID}, -- Pandaria
	[7] = {ARCHAEOLOGY_RACE_OGRE, ARCHAEOLOGY_RACE_DRAENOR, ARCHAEOLOGY_RACE_ARAKKOA}, -- Draenor
	[8] = {ARCHAEOLOGY_RACE_DEMONIC, ARCHAEOLOGY_RACE_HIGHMOUNTAIN_TAUREN, ARCHAEOLOGY_RACE_HIGHBORNE}, -- Broken Isles
	[9] = {ARCHAEOLOGY_RACE_DRUSTVARI, ARCHAEOLOGY_RACE_ZANDALARI}, -- Kul Tiras
	[10] = {ARCHAEOLOGY_RACE_ZANDALARI, ARCHAEOLOGY_RACE_DRUSTVARI}, -- Zandalar
};

-- Alternate uiMapIDs (flight maps) for continents ([uiMapID] = internalContID)
local MinArchAlternateContIDMap = {
	[993] = 8, -- Broken Isles Flight map
	[1014] = 9, -- Kul Tiras Flight map
	[1011] = 10, -- Zandalar Flight map
}

function MinArch:CommonFrameLoad(self, movable)
	movable = movable or self
	self:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileEdge = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 11, top = 11, bottom = 11 },
    });

    self:RegisterForDrag("LeftButton");
    self:SetScript("OnDragStart", function(self, button)
		MinArch:CommonFrameDragStart(movable, button);
    end)
    self:SetScript("OnDragStop", function(self)
		MinArch:CommonFrameDragStop(movable);
    end)
end

function MinArch:CommonFrameDragStart(self, button)
	if(button == "LeftButton") then
		self:StartMoving();
	end
end

function MinArch:CommonFrameDragStop(self)
	self:StopMovingOrSizing();
end

function MinArch:CommonFrameScale(scale)
	scale = tonumber(scale)/100;
	MinArchMain:SetScale(scale);
	MinArchHist:SetScale(scale);
	MinArchDigsites:SetScale(scale);
end

function MinArch:CreateAutoWaypointButton(parent, x, y)
	local button = CreateFrame("Button", "$parentAutoWayButton", parent);
	button:SetSize(21, 21);
	button:SetPoint("TOPLEFT", x, y);

	button:SetNormalTexture([[Interface\GLUES\COMMON\Glue-RightArrow-Button-Up]]);
	button:GetNormalTexture():SetRotation(1.570796);
	button:SetPushedTexture([[Interface\GLUES\COMMON\Glue-RightArrow-Button-Down]]);
	button:GetPushedTexture():SetRotation(1.570796);
	button:SetHighlightTexture([[Interface\Addons\MinimalArchaeology\Textures\CloseButtonHighlight]]);
	button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", 10, -10);

    button:SetScript("OnMouseUp", function(self, button)
        if (button == "LeftButton") then
            MinArch:SetWayToNearestDigsite()
        elseif (button == "RightButton") then
            MinArch:OpenSettings(MinArch.Options.menu);
        end
	end)

	button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
        GameTooltip:AddLine("Left click to create waypoint to the closest available digsite", 1.0, 1.0, 1.0, 1.0)
        GameTooltip:AddLine(" ");
        GameTooltip:AddLine("Right Click to open waypoint settings");
        GameTooltip:Show();
	end)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide();
    end)

    return button;
end

function MinArch:GetInternalContId(uiMapID)
	uiMapID = uiMapID or C_Map.GetBestMapForUnit("player");
	if not uiMapID then
		return nil;
	end
	local mapInfo = C_Map.GetMapInfo(uiMapID);
	if (mapInfo == nil) then
		return nil;
	end
	local nearestContinentID = MinArch:GetNearestContinentId(uiMapID);
	local ContID = MinArchContIDMap[nearestContinentID];

	-- check for alternate IDs
	if (ContID == nil) then
		ContID = MinArchAlternateContIDMap[nearestContinentID];
	end

	return ContID;
end

-- Return uiMapID by internal MinArch ContID index
function MinArch:GetUiMapIdByContId(ContID)
	for k, v in pairs(MinArchContIDMap) do
		if (v == ContID) then
			return k;
		end
	end

	return nil;
end

function MinArch:GetNearestContinentId(uiMapID)
	local mapInfo = C_Map.GetMapInfo(uiMapID);
	if (mapInfo == nil or mapInfo.mapType < 2) then
		return 12; -- Return Kalimdor by default
	end

	if (mapInfo.mapType == 2) then
		return uiMapID;
	end

	if (mapInfo.mapType > 2) then
		return MinArch:GetNearestContinentId(mapInfo.parentMapID);
	end
end

function MinArch:GetNearestZoneId(uiMapID)
	local mapInfo = C_Map.GetMapInfo(uiMapID);
	if (mapInfo == nil or mapInfo.mapType < 3) then
		return nil
	end

	if (mapInfo.mapType == 3) then
		local parentInfo = C_Map.GetMapInfo(mapInfo.parentMapID);
		if (parentInfo ~= nil and parentInfo.mapType == 3) then
			-- For zones like Stranglethorn where the parent and child are both type 3
			uiMapID = MinArch:GetNearestZoneId(mapInfo.parentMapID);
		end
		return uiMapID;
	end

	if (mapInfo.mapType > 3) then
		return MinArch:GetNearestZoneId(mapInfo.parentMapID);
	end
end

function MinArch:DisplayStatusMessage(message, msgtype)
	if (msgtype == MINARCH_MSG_STATUS and MinArch.db.profile.showStatusMessages == true) then
		ChatFrame1:AddMessage(message);
	end

	if (msgtype == MINARCH_MSG_DEBUG and MinArch.db.profile.showDebugMessages == true) then
		ChatFrame1:AddMessage('MinArch DEBUG: ' .. message);
	end
end

function MinArch:GetRaceNameByBranchId(branchID)
	if (ResearchBranchMap[branchID] ~= nil) then
		local raceId = ResearchBranchMap[branchID];
		for name,id in pairs(MinArch.ArchaeologyRaces) do
			if (id == raceId) then
				return name;
			end
		end
	end

	return nil;
end

function MinArch:IsRaceRelevant(raceID)
	if (not MinArch.db.profile.relevancy.relevantOnly) then
		return true;
    end

	if (MinArch.RelevantRaces[raceID] and MinArch.db.profile.relevancy.nearby) then
		return true;
    end

	if (MinArch.db.profile.relevancy.continentSpecific) then
		local contID = MinArch:GetInternalContId();
		if (MinArchContinentRaces[contID]) then
			for i=1, #MinArchContinentRaces[contID] do
				if (MinArchContinentRaces[contID][i] == raceID) then
					return true;
				end
			end
		end
    end

    if (MinArch['artifacts'][raceID]['canSolve'] and MinArch.db.profile.relevancy.solvable) then
        if not (MinArch.db.profile.relevancy.hideCapped and MinArch.db.profile.raceOptions.cap[raceID]) then
            return true;
        end
	end

	return false;
end

function MinArch:CanCast()
    -- Prevent casting in combat
    if (InCombatLockdown()) then
        MinArch:DisplayStatusMessage('Can\'t cast: combat lockdown', MINARCH_MSG_DEBUG)
        return false;
    end

    -- Check general conditions
    if InCombatLockdown() or not CanScanResearchSite() or GetSpellCooldown(SURVEY_SPELL_ID) ~= 0 then
        MinArch:DisplayStatusMessage('Can\'t cast: not in research site or spell on cooldown', MINARCH_MSG_DEBUG)
        return false;
    end

    -- Check custom conditions (mounted, flying)
    if IsMounted() and MinArch.db.profile.dblClick.disableMounted then
        MinArch:DisplayStatusMessage('Can\'t cast: disabled in settings - mounted', MINARCH_MSG_DEBUG)
        return false;
    end
    if IsFlying() and MinArch.db.profile.dblClick.disableInFlight then
        MinArch:DisplayStatusMessage('Can\'t cast: disabled in settings - flying', MINARCH_MSG_DEBUG)
        return false;
    end
	if GetNumLootItems() ~= 0 then
		MinArch:DisplayStatusMessage('Can\'t cast while looting', MINARCH_MSG_DEBUG)
		return false
	end

    return true;
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

function MinArch:GetRaceIdByName(name)
	if (MinArch.RacesLoaded == false) then
		MinArch:LoadRaceInfo();
	end

	return MinArch.ArchaeologyRaces[name];
end

function MinArch:ShowWindowButtonTooltip(button, text)
	GameTooltip:SetOwner(button, "ANCHOR_BOTTOMRIGHT");
	GameTooltip:AddLine(text, 1.0, 1.0, 1.0, 1.0)
	GameTooltip:Show();
end

function MinArch:TestForMissingDigsites()
	-- temporarily disabled
	if true then
		return;
	end

	for k, v in pairs(MinArch.DigsiteLocales.enUS) do
		if (MinArchDigsiteList[k] == nil) then
			print("Missing race for: " .. k);
		end
	end

	for k, v in pairs(MinArchDigsiteList) do
		if (MinArch.DigsiteLocales.enUS[k] == nil) then
			print("Missing translation for: " .. k);
		end
	end
end

function MinArch:OpenSettings(category)
	if Settings and Settings.OpenToCategory then
		Settings.OpenToCategory(category.name);
	else
		InterfaceOptionsFrame_OpenToCategory(category)
	end
end

function MinArch:Round(x)
    return math.floor(x + 0.5);
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
		-- MinArchHist:UnregisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
	end
end
