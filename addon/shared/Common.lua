local ADDON, _ = ...

---Reusable functions and components not unique to one specific module
---@class MinArchCommon
local Common = MinArch:LoadModule("MinArchCommon")

---@type MinArchMain
local Main = MinArch:LoadModule("MinArchMain")
---@type MinArchDigsites
local Digsites = MinArch:LoadModule("MinArchDigsites")
---@type MinArchCompanion
local Companion = MinArch:LoadModule("MinArchCompanion")
---@type MinArchOptions
local Options = MinArch:LoadModule("MinArchOptions")
---@type MinArchNavigation
local Navigation = MinArch:LoadModule("MinArchNavigation")
---@type MinArchHistory
local History = MinArch:LoadModule("MinArchHistory")
---@type MinArchLDB
local MinArchLDB = MinArch:LoadModule("MinArchLDB")

local L = LibStub("AceLocale-3.0"):GetLocale("MinArch")

-- Local variables
local nextCratable = nil

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

---@param frame table|BackdropTemplate|Frame
---@param handle? table|BackdropTemplate|Frame
function Common:FrameLoad(frame, handle)
	handle = handle or frame
	frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileEdge = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 11, top = 11, bottom = 11 },
    });

    frame:RegisterForDrag("LeftButton");
    frame:SetScript("OnDragStart", function(self, button)
		Common:FrameDragStart(handle, button);
    end)
    frame:SetScript("OnDragStop", function(self)
		Common:FrameDragStop(handle);
    end)
end

---@param frame table|BackdropTemplate|Frame
---@param button mouseButton
function Common:FrameDragStart(frame, button)
	if(button == "LeftButton") then
		frame:StartMoving();
	end
end

---@param frame table|BackdropTemplate|Frame
function Common:FrameDragStop(frame)
	frame:StopMovingOrSizing();
end

---@param scale integer|string
function Common:FrameScale(scale)
	scale = tonumber(scale)/100;
	Main.frame:SetScale(scale);
	History.frame:SetScale(scale);
	Digsites.frame:SetScale(scale);
end

---@param parent table|BackdropTemplate|Frame
---@param x integer
---@param y integer
---@return Button
function Common:CreateAutoWaypointButton(parent, x, y)
	local button = CreateFrame("Button", "$parentAutoWayButton", parent, nil);
	button:SetParentKey("autoWaypointButton")
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
            Navigation:SetWayToNearestDigsite()
        elseif (button == "RightButton") then
            Common:OpenSettings(Options.TomTomSettings);
        end
	end)

	button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
        GameTooltip:AddLine(L["TOOLTIP_WP_BUTTON_LEFTCLICK"], 1.0, 1.0, 1.0, 1.0)
        GameTooltip:AddLine(" ");
        GameTooltip:AddLine(L["TOOLTIP_WP_BUTTON_RIGHTCLICK"]);
        GameTooltip:Show();
	end)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide();
    end)

    return button;
end

function Common:SetCrateButtonTooltip(button)
    button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
		if (nextCratable ~= nil) then
			GameTooltip:SetItemByID(nextCratable.itemID);
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(L["TOOLTIP_CRATE_BUTTON_LEFTCLICK"]);
		else
			GameTooltip:AddLine(L["TOOLTIP_CRATE_BUTTON_RIGHTCLICK"]);
		end

		GameTooltip:Show();
	end)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end)
end

function Common:RefreshCrateButtonGlow()
    Main.frame.crateButton.glow:Hide();
    Companion:hideCrateButton()
    nextCratable = nil;

	for i = 1, ARCHAEOLOGY_RACE_MANTID do
		for artifactID, data in pairs(MinArchHistDB[i]) do
			if (data.pqid) then
				-- iterate containers
				for bagID = 0, 4 do
					local numSlots = C_Container.GetContainerNumSlots(bagID);
					for slot = 0, numSlots do
						local itemID = C_Container.GetContainerItemID(bagID, slot);
						if (itemID == artifactID) then
							nextCratable = {
								itemID = itemID,
								bagID = bagID,
								slot = slot
							}

                            Main.frame.crateButton:SetAttribute("item", "item:" .. itemID);
                            Main.frame.crateButton.glow:Show();
                            Companion:showCrateButton(itemID);

							return;
						end
					end
				end
			end
		end
	end
end

function Common:KeystoneTooltip(self, raceID)
	local artifact = MinArch['artifacts'][raceID];
	local name = C_Item.GetItemInfo(artifact['raceitemid']);

	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");

	local plural = L["TOOLTIP_KEYSTONES_YOUHAVE_INYOURBAGS_PLURAL"];
	if (artifact['heldKeystones'] == 1) then
		plural = "";
	end

	GameTooltip:SetItemByID(artifact['raceitemid']);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(L["TOOLTIP_KEYSTONES_YOUHAVE"] .. " "..artifact['heldKeystones'].." "..tostring(name)..plural .. " " .. L["TOOLTIP_KEYSTONES_YOUHAVE_INYOURBAGS"], GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(L["TOOLTIP_KEYSTONES_LEFTCLICK"]);
	GameTooltip:AddLine(L["TOOLTIP_KEYSTONES_RIGHTCLICK"]);
	GameTooltip:Show();
end

function Common:KeystoneClick(self, raceID, button, down)
	local numofappliedkeystones = MinArch['artifacts'][raceID]['appliedKeystones'];
	local numoftotalkeystones = MinArch['artifacts'][raceID]['numKeystones'];

	if (button == "LeftButton") then
		if (numofappliedkeystones < numoftotalkeystones) then
			 MinArch['artifacts'][raceID]['appliedKeystones'] = numofappliedkeystones + 1;
		end
	elseif (button == "RightButton") then
		if (numofappliedkeystones > 0) then
			 MinArch['artifacts'][raceID]['appliedKeystones'] = numofappliedkeystones - 1;
		end
	end

	History:UpdateArtifact(raceID);
	Main:UpdateArtifactBar(raceID);
	MinArchLDB:RefreshLDBButton();
	Companion:Update()
end

function Common:UpdateKeystones(keystoneFrame, RaceIndex)
	local artifact = MinArch['artifacts'][RaceIndex];
	if not artifact or not artifact['raceitemid'] then
		return
	end

	local runeName, _, _, _, _, _, _, _, _, runeStoneIconPath = C_Item.GetItemInfo(artifact['raceitemid']);

	keystoneFrame.icon:SetTexture(runeStoneIconPath);

	if (artifact['appliedKeystones'] == 0 or artifact['numKeystones'] == 0) then
		keystoneFrame.icon:SetAlpha(0.1);
	else
		keystoneFrame.icon:SetAlpha((artifact['appliedKeystones']/artifact['numKeystones']));
	end

	if (artifact['numKeystones'] > 0 and artifact['total'] > 0) then
		keystoneFrame.text:SetText(artifact['appliedKeystones'].."/"..artifact['numKeystones']);
		keystoneFrame:Show();
		keystoneFrame.icon:Show();
	else
		keystoneFrame:Hide();
	end
end

---Converts uiMapID to internal MinArch continent ID
---@param uiMapID? integer @Defaults to player's current map if not provided
---@return integer|nil
function Common:GetInternalContId(uiMapID)
	uiMapID = uiMapID or C_Map.GetBestMapForUnit("player");
	if not uiMapID then
		return nil;
	end
	local mapInfo = C_Map.GetMapInfo(uiMapID);
	if (mapInfo == nil) then
		return nil;
	end
	local nearestContinentID = Common:GetNearestContinentId(uiMapID);
	local ContID = MinArchContIDMap[nearestContinentID];

	-- check for alternate IDs
	if (ContID == nil) then
		ContID = MinArchAlternateContIDMap[nearestContinentID];
	end

	return ContID;
end

---Converts internal MinArch continent ID to uiMapID
---@return integer|nil
function Common:GetUiMapIdByContId(ContID)
	for k, v in pairs(MinArchContIDMap) do
		if (v == ContID) then
			return k;
		end
	end

	return nil;
end

---Returns the nearest continent ID for a given uiMapID
---@param uiMapID integer
---@return integer @Defaults to Kalimdor
function Common:GetNearestContinentId(uiMapID)
	local mapInfo = C_Map.GetMapInfo(uiMapID);
	if (mapInfo == nil or mapInfo.mapType < 2) then
		return 12
	end

	if (mapInfo.mapType == 2) then
		return uiMapID;
	end

	if (mapInfo.mapType > 2) then
		return Common:GetNearestContinentId(mapInfo.parentMapID);
	end

	return 12
end

---Returns the nearest zone ID for a given uiMapID
---@return integer|nil
function Common:GetNearestZoneId(uiMapID)
	local mapInfo = C_Map.GetMapInfo(uiMapID);
	if (mapInfo == nil or mapInfo.mapType < 3) then
		return nil
	end

	if (mapInfo.mapType == 3) then
		local parentInfo = C_Map.GetMapInfo(mapInfo.parentMapID);
		if (parentInfo ~= nil and parentInfo.mapType == 3) then
			-- For zones like Stranglethorn where the parent and child are both type 3
			uiMapID = Common:GetNearestZoneId(mapInfo.parentMapID);
		end
		return uiMapID;
	end

	if (mapInfo.mapType > 3) then
		return Common:GetNearestZoneId(mapInfo.parentMapID);
	end
end

---@param message string
---@param msgtype integer|nil @MINARCH_MSG_STATUS|MINARCH_MSG_DEBUG - status message by default
function Common:DisplayStatusMessage(message, msgtype)
	if (msgtype == MINARCH_MSG_STATUS and MinArch.db.profile.showStatusMessages == true) then
		ChatFrame1:AddMessage(message);
	end

	if (msgtype == MINARCH_MSG_DEBUG and MinArch.db.profile.showDebugMessages == true) then
		ChatFrame1:AddMessage('MinArch DEBUG: ' .. message);
	end
end

---@param branchID integer
---@return string|nil
function Common:GetRaceNameByBranchId(branchID)
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

---Returns true if the race is considered "relevant" based on the current settings
---@param raceID integer
---@return boolean
function Common:IsRaceRelevant(raceID)
	if (not MinArch.db.profile.relevancy.relevantOnly) then
		return true;
    end

	if (MinArch.RelevantRaces[raceID] and MinArch.db.profile.relevancy.nearby) then
		return true;
    end

	if (MinArch.db.profile.relevancy.continentSpecific) then
		local contID = Common:GetInternalContId();
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

---Returns true if survey can be casted based on player conditions and MinArch configuration
---@return boolean
function Common:CanCast()
    -- Prevent casting in combat
    if (InCombatLockdown()) then
        Common:DisplayStatusMessage('Can\'t cast: combat lockdown', MINARCH_MSG_DEBUG)
        return false;
    end

    -- Check general conditions
    if InCombatLockdown() or not CanScanResearchSite() or Common:GetSpellCooldown(SURVEY_SPELL_ID) ~= 0 then
        Common:DisplayStatusMessage('Can\'t cast: not in research site or spell on cooldown', MINARCH_MSG_DEBUG)
        return false;
    end

    -- Check custom conditions (mounted, flying)
    if IsMounted() and MinArch.db.profile.dblClick.disableMounted then
        Common:DisplayStatusMessage('Can\'t cast: disabled in settings - mounted', MINARCH_MSG_DEBUG)
        return false;
    end
    if IsFlying() and MinArch.db.profile.dblClick.disableInFlight then
        Common:DisplayStatusMessage('Can\'t cast: disabled in settings - flying', MINARCH_MSG_DEBUG)
        return false;
    end
	if GetNumLootItems() ~= 0 then
		Common:DisplayStatusMessage('Can\'t cast while looting', MINARCH_MSG_DEBUG)
		return false
	end

    return true;
end

function Common:LoadRaceInfo()
	for i = 1, ARCHAEOLOGY_NUM_RACES do
		local name, t = GetArchaeologyRaceInfo(i);
		if (t == nil) then
			return;
		end
		MinArch.ArchaeologyRaces[name] = i;
	end

	MinArch.RacesLoaded = true;
end

---@return integer
function Common:GetRaceIdByName(name)
	if (MinArch.RacesLoaded == false) then
		Common:LoadRaceInfo();
	end

	return MinArch.ArchaeologyRaces[name];
end

---@param button Button|Frame|BackdropTemplate
---@param text string
function Common:ShowWindowButtonTooltip(button, text)
	GameTooltip:SetOwner(button, "ANCHOR_BOTTOMRIGHT");
	GameTooltip:AddLine(text, 1.0, 1.0, 1.0, 1.0)
	GameTooltip:Show();
end

function Common:TestForMissingDigsites()
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

---Uses C_Spell when available, otherwise uses GetSpellCooldown (there is no C_SPELL in Cata yet)
function Common:GetSpellCooldown(spellID)
    if C_Spell and C_Spell.GetSpellCooldown then
        return C_Spell.GetSpellCooldown(spellID).startTime
    else
        return GetSpellCooldown(spellID)
    end
end

---Opens the settings window to a specific category
function Common:OpenSettings(category)
	if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(Options.menu.name);
		Settings.OpenToCategory(category.name);
	else
		InterfaceOptionsFrame_OpenToCategory(Options.menu)
		InterfaceOptionsFrame_OpenToCategory(category)
	end
end

---Rounds a number to the nearest integer
---@param x number
---@return integer
function Common:Round(x)
    return math.floor(x + 0.5);
end

---Global functions

function MinArch_TrackingChanged(self)
	MinArch:TrackingChanged(self);
end

function MinArch_MapLayerChanged(self)
	MinArch:MapLayerChanged(self);
end

function MinArch_WorldMapToggled()
	if (WorldMapFrame.mapID ~= nil and WorldMapFrame:IsVisible()) then
		Digsites:ShowRaceIconsOnMap();
	end
end

function MinArch_ShowUIPanel(...)
	local panel = ...;
	if (panel and panel:GetName() == "ArchaeologyFrame") then
		-- History.frame:UnregisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
	end
end
