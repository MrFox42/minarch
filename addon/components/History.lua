local ADDON, MinArch = ...

MinArchScroll = {}

MinArch.HistoryListLoaded = {}
MinArch.HasPristine = {}
MinArch.DigsiteButtons = {}
MinArchHist.firstRun = true;

local qLineQuests = {};
local currentQuestArtifact = nil;
local currentQuestArtifactRace = nil;
local isOnArtifactQuestLine = false;
local qLineRaces = {ARCHAEOLOGY_RACE_DEMONIC, ARCHAEOLOGY_RACE_HIGHMOUNTAIN_TAUREN, ARCHAEOLOGY_RACE_HIGHBORNE};
local dalaranChecked = false;
local unknownArtifactInfoIndex = {}
local histEventTimer = nil;
local historyUpdateTimout = 0.3;

local function InitQuestIndicator(self)
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

local function InitRaceButtons(self)
	local baseX = 17;
	local baseY = -19;
	local currX = baseX;
	local currY = baseY;
	local sizeX = 25;
	local sizeY = 25;
    local lineBreak = 10;
    local padding = 2;

	for i=1, ARCHAEOLOGY_NUM_RACES do
		if (MinArchRaceConfig[i] ~= nil) then
			local raceButton = CreateFrame("Button", "MinArchRaceButton" .. i, self);
			raceButton:SetPoint("TOPLEFT", self, "TOPLEFT", currX, currY);
			currX = currX + sizeX + padding;

			if (i == 10) then
				currX = baseX;
				currY = currY - sizeY - padding;
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

function SetToggleButtonTexture()
	local button = MinArchHistToggleButton;
	if (MinArch.db.profile.history.autoResize) then
        button:SetNormalTexture([[Interface\Buttons\UI-Panel-CollapseButton-Up]]);
		button:SetPushedTexture([[Interface\Buttons\UI-Panel-CollapseButton-Down]]);
	else
        button:SetNormalTexture([[Interface\Buttons\UI-Panel-ExpandButton-Up]]);
		button:SetPushedTexture([[Interface\Buttons\UI-Panel-ExpandButton-Down]]);
	end

	button:SetBackdrop({
		bgFile = [[Interface\GLUES\COMMON\Glue-RightArrow-Button-Up]],
		edgeFile = nil, tile = false, tileSize = 0, edgeSize = 0,
		insets = { left = 0.5, right = 1, top = 2.4, bottom = 1.4 }
	});
	button:SetHighlightTexture([[Interface\Addons\MinimalArchaeology\Textures\CloseButtonHighlight]]);
	button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", 10, -10);
end

local function CreateHeightToggle(parent, x, y)
	local button = CreateFrame("Button", "$parentToggleButton", parent, BackdropTemplateMixin and "BackdropTemplate");
	button:SetSize(23.5, 23.5);
	button:SetPoint("TOPLEFT", x, y);
	SetToggleButtonTexture();

	button:SetScript("OnClick", function(self, button)
		if (button == "LeftButton") then
			MinArch.db.profile.history.autoResize = (not MinArch.db.profile.history.autoResize);
			SetToggleButtonTexture();
			MinArch:CreateHistoryList(MinArchOptions['CurrentHistPage'], "MATBOpenHist");
		end
	end);
    button:SetScript("OnEnter", function()
        if MinArch.db.profile.history.autoResize then
            MinArch:ShowWindowButtonTooltip(button, "Click to set the height of the History window to a fixed size|r");
        else
            MinArch:ShowWindowButtonTooltip(button, "Click to enable automatic resizing for the History window");
        end
    end)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end)
end

function MinArch:InitHist(self)
	InitQuestIndicator(self);
    InitRaceButtons(self);
    CreateHeightToggle(self, 10, 4);

    for i=1, ARCHAEOLOGY_NUM_RACES do
        unknownArtifactInfoIndex[i] = 1;
    end

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

    -- Achievement checks
    self:RegisterEvent("CRITERIA_COMPLETE");
    self:RegisterEvent("CRITERIA_EARNED");
    self:RegisterEvent("CRITERIA_UPDATE");

    self:RegisterEvent("UNIT_INVENTORY_CHANGED");

    MinArch:CommonFrameLoad(self);

	MinArch:DisplayStatusMessage("Minimal Archaeology History Initialized!");
end

function MinArch:IsItemDetailsLoaded(RaceID)
	return MinArch.HistoryListLoaded[RaceID] or false
end

function MinArch:LoadItemDetails(RaceID, caller)
	if MinArch:IsItemDetailsLoaded(RaceID) then
		return true
	end

	local newItemCount = 0

	local allGood = true
	for itemid, details in pairs(MinArchHistDB[RaceID]) do
		if not details.name then
			newItemCount = newItemCount + 1

			local name, _, rarity, _, _, _, _, _, _, icon, sellPrice = GetItemInfo(itemid);

			if name ~= nil and icon ~= nil then
				details.name = name
				details.rarity = rarity
				details.icon = "interface\\icons\\"..LibIconPath_getName(icon)..".blp"
				details.sellprice = sellPrice
				if details.pqid then
					MinArch.HasPristine[RaceID] = true
				end
			else
				-- item info not available yet, need to retry later
				allGood = false
			end
		end
	end

	MinArch.HistoryListLoaded[RaceID] = allGood
	if allGood then
		MinArch:DisplayStatusMessage("Minimal Archaeology - All " .. (MinArch.artifacts[RaceID].race or ("Race" .. RaceID)) .. " items are loaded now.", MINARCH_MSG_DEBUG)
		MinArch:DisplayStatusMessage("Minimal Archaeology - All " .. (MinArch.artifacts[RaceID].race or ("Race" .. RaceID)) .. " items are loaded now (" .. caller .. ").", MINARCH_MSG_DEBUG)
	else
		MinArch:DisplayStatusMessage("Minimal Archaeology - Some " .. (MinArch.artifacts[RaceID].race or ("Race" .. RaceID)) .. " items are not loaded yet (" .. caller .. ").", MINARCH_MSG_DEBUG)
	end

	return allGood
end

local function BuildHistory(RaceID, caller)
    MinArch:DisplayStatusMessage("BuildHistory " .. caller, MINARCH_MSG_DEBUG)

    local i = unknownArtifactInfoIndex[RaceID];
    MinArch:DisplayStatusMessage("Bulding history for race " .. RaceID .. " from index: " .. i, MINARCH_MSG_DEBUG)
	while true do
		local name, desc, rarity, icon, spelldesc, itemrare, _, spellId, firstcomplete, totalcomplete = GetArtifactInfoByRace(RaceID, i)

		if not name then
			break
		end

		-- icon = icon:lower()
		icon = "interface\\icons\\"..LibIconPath_getName(icon) or icon
		if MinArchIconDB[RaceID] and MinArchIconDB[RaceID][icon] then
			icon = MinArchIconDB[RaceID][icon]
		end
		icon = icon..".blp"

		local foundCount = 0
        for itemid, details in pairs(MinArchHistDB[RaceID]) do
			if (details.name == name and details.icon ~= icon) then
				MinArchIconDB[RaceID] = MinArchIconDB[RaceID] or {}
				MinArchIconDB[RaceID][icon] = details.icon
				MinArch:DisplayStatusMessage("Minimal Archaeology - icon discrepancy detected", MINARCH_MSG_DEBUG)
				MinArch:DisplayStatusMessage("Race " .. RaceID .. ": " .. (MinArch.artifacts[RaceID].race or ("Race" .. RaceID)), MINARCH_MSG_DEBUG)
				MinArch:DisplayStatusMessage("Item " .. itemid .. ": " .. details.name, MINARCH_MSG_DEBUG)
				MinArch:DisplayStatusMessage("Item icon '" .. details.icon .. "'", MINARCH_MSG_DEBUG)
				MinArch:DisplayStatusMessage("Artifact icon '" .. icon .. "'", MINARCH_MSG_DEBUG)
				icon = details.icon
			end
		end

        for itemid, details in pairs(MinArchHistDB[RaceID]) do
            if ((details.name == name and details.icon == icon) or (foundCount == 0 and details.icon == icon)) then
                foundCount = foundCount + 1
                if foundCount > 1 then
                    MinArch:DisplayStatusMessage("Minimal Archaeology - found duplicate #" .. foundCount, MINARCH_MSG_DEBUG)
                    MinArch:DisplayStatusMessage("Race " .. RaceID .. ": " .. (MinArch.artifacts[RaceID].race or ("Race" .. RaceID)), MINARCH_MSG_DEBUG)
                    MinArch:DisplayStatusMessage("Item " .. itemid .. ": " .. details.name, MINARCH_MSG_DEBUG)
                    MinArch:DisplayStatusMessage("Artifact: " .. name, MINARCH_MSG_DEBUG)
                    MinArch:DisplayStatusMessage("Item icon '" .. details.icon .. "'", MINARCH_MSG_DEBUG)
                    MinArch:DisplayStatusMessage("Artifact icon '" .. icon .. "'", MINARCH_MSG_DEBUG)
                end

                --TODO: In the tooltip, display icon/name/info for artifact and all associated item icons
                -- Change MinArchHistDB to include the alternate item IDs (for example, Orb of Sciallax can give 6 different relics items)
                -- Gather the name and icon info here.
                --[[if (details.name ~= name) then
                    MinArch:DisplayStatusMessage("Minimal Archaeology - item and artifact names differ", MINARCH_MSG_DEBUG)
                    MinArch:DisplayStatusMessage("Race " .. RaceID .. ": " .. (MinArch.artifacts[RaceID].race or ("Race" .. RaceID)), MINARCH_MSG_DEBUG)
                    MinArch:DisplayStatusMessage("Item " .. itemid .. ": " .. details.name, MINARCH_MSG_DEBUG)
                    MinArch:DisplayStatusMessage("Artifact: " .. name, MINARCH_MSG_DEBUG)
                    MinArch:DisplayStatusMessage("Item icon '" .. details.icon .. "'", MINARCH_MSG_DEBUG)
                    MinArch:DisplayStatusMessage("Artifact icon '" .. icon .. "'", MINARCH_MSG_DEBUG)
                end]]--

                details.artifactname = name
                details.firstcomplete = firstcomplete
                details.totalcomplete = totalcomplete
                details.description = desc
                details.spelldescription = spelldesc
                details.apiIndex = i;
                unknownArtifactInfoIndex[RaceID] = i + 1;

                if (MinArch.artifacts[RaceID].project == name) then
                    MinArch.artifacts[RaceID].firstcomplete = firstcomplete
                    MinArch.artifacts[RaceID].totalcomplete = totalcomplete
                    MinArch.artifacts[RaceID].sellprice = details.sellprice
                end
            end
        end

		if foundCount == 0 and MinArch:IsItemDetailsLoaded(RaceID) then
			MinArch:DisplayStatusMessage("Minimal Archaeology - found unknown artifact", MINARCH_MSG_DEBUG)
			MinArch:DisplayStatusMessage("Race " .. RaceID .. ": " .. (MinArch.artifacts[RaceID].race or ("Race" .. RaceID)), MINARCH_MSG_DEBUG)
			MinArch:DisplayStatusMessage("Artifact: " .. name, MINARCH_MSG_DEBUG)
			MinArch:DisplayStatusMessage("Artifact icon '" .. icon .. "'", MINARCH_MSG_DEBUG)
		end

		i=i+1;
    end
end

function MinArch:GetHistory(RaceID, caller)
    for _, details in pairs(MinArchHistDB[RaceID]) do
        if not details.apiIndex then
            BuildHistory(RaceID, 'GetHistory');
        else
            local previousCompleted = details.totalcomplete;
            local name, desc, _, _, spelldesc, _, _, _, firstcomplete, totalcomplete = GetArtifactInfoByRace(RaceID, details.apiIndex)
            if (previousCompleted and previousCompleted > 0 and previousCompleted > totalcomplete) then
                -- Don't update stored data if the response is bogus
                MinArch:DisplayStatusMessage("Bogus data from API, refreshing ...", MINARCH_MSG_DEBUG)
                MinArch:DelayedHistoryUpdate();
                return;
            end

            details.artifactname = name
            details.firstcomplete = firstcomplete
            details.totalcomplete = totalcomplete
            details.description = desc
            details.spelldescription = spelldesc

            if (MinArch.artifacts[RaceID].project == name) then
                MinArch.artifacts[RaceID].firstcomplete = firstcomplete
                MinArch.artifacts[RaceID].totalcomplete = totalcomplete
                MinArch.artifacts[RaceID].sellprice = details.sellprice
            end
        end
    end
end

function MinArch:GetCurrentQuestArtifact()
	for i=1, #qLineRaces do
		local RaceID = qLineRaces[i];

		for itemid, details in pairs(MinArchHistDB[RaceID]) do
			local isQuestAvailable, isOnQuest = MinArch:IsQuestAvailableForArtifact(RaceID, itemid);

			if (isQuestAvailable) then
				currentQuestArtifact = itemid;
				isOnArtifactQuestLine = isOnQuest;
				currentQuestArtifactRace = RaceID;
				MinArchHistQuestIndicator:SetPoint("BOTTOMRIGHT", MinArch.raceButtons[RaceID], "BOTTOMRIGHT", 2, 2);
				MinArchHistQuestIndicator:Show();

				return;
			end
		end
	end

	currentQuestArtifact = nil;
	currentQuestArtifactRace = nil;
	isOnArtifactQuestLine = false;
	MinArchHistQuestIndicator:Hide();
end

function MinArch:IsQuestAvailableForArtifact(RaceID, artifactID)
	local qLineId = MinArchHistDB[RaceID][artifactID]['qline'];
	if (qLineId == nil) then
		return false;
	end

    if not dalaranChecked and WorldMapFrame then
        local currentMapId = WorldMapFrame:GetMapID();
        WorldMapFrame:SetMapID(627);
        WorldMapFrame:SetMapID(currentMapId);
        dalaranChecked = true;
    end
    local availableQuestLines = C_QuestLine.GetAvailableQuestLines(627); -- 619 ? TODO

	qLineQuests[qLineId] = qLineQuests[qLineId] or C_QuestLine.GetQuestLineQuests(qLineId);
	for i=1, #qLineQuests[qLineId] do
		if (C_QuestLog.IsOnQuest(qLineQuests[qLineId][i])) then
			return true, true;
		end


		for k, quest in pairs(availableQuestLines) do
			if (quest.questID == qLineQuests[qLineId][i]) then
				return true
			end
		end
	end

	return false
end

local function SetProgressTooltip(frame, progressState, achievementState, totalComplete)
    local stateStrings = {
        [MINARCH_PROGRESS_UNKNOWN]        = "You haven't found this artifact yet",
        [MINARCH_PROGRESS_KNOWN]          = "Completed |cFFDDDDDD",
        [MINARCH_PROGRESS_CURRENT]        = "Currently available for this race",
        [MINARCH_ACHIPROGRESS_INCOMPLETE] = "Collector achievement in progress: ";
        [MINARCH_ACHIPROGRESS_COMPLETE]   = "Collector achievement completed";
    }

    if totalComplete == 1 then
        stateStrings[MINARCH_PROGRESS_KNOWN] = stateStrings[MINARCH_PROGRESS_KNOWN] .. totalComplete .. "|r time"
    elseif totalComplete and totalComplete > 1 then
        stateStrings[MINARCH_PROGRESS_KNOWN] = stateStrings[MINARCH_PROGRESS_KNOWN] .. totalComplete .. "|r times";
    end
    if totalComplete and totalComplete > 0 and achievementState == MINARCH_ACHIPROGRESS_INCOMPLETE then
        stateStrings[MINARCH_ACHIPROGRESS_INCOMPLETE] = stateStrings[MINARCH_ACHIPROGRESS_INCOMPLETE]
            .. "|cFFDDDDDD" .. totalComplete .. '/20|r';
    end

    frame:SetScript("OnEnter", function (self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
        GameTooltip:AddLine("Artifact Progress Information");
        GameTooltip:AddLine(" ");
        if progressState == MINARCH_PROGRESS_CURRENT then
            GameTooltip:AddLine(stateStrings[MINARCH_PROGRESS_KNOWN]);
        end
        if achievementState ~= MINARCH_ACHIPROGRESS_NONE then
            GameTooltip:AddLine(stateStrings[achievementState])
        end
        GameTooltip:AddLine(stateStrings[progressState]);
        GameTooltip:Show();
    end);

    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function SetQuestTooltip(frame, questState)
    local stateStrings = {
        [MINARCH_QSTATE_LEGION_AVAILABLE]    = "Currently available from the bi-weekly Legion quest",
        [MINARCH_QSTATE_PRISTINE_INCOMPLETE] = "Pristine version not found yet",
        [MINARCH_QSTATE_PRISTINE_ONQUEST]    = "Pristine version found, but not yet handed in",
        [MINARCH_QSTATE_PRISTINE_COMPLETE]   = "Pristine version already found"
    }

    frame:SetScript("OnEnter", function (self)
        if questState == MINARCH_QSTATE_NIL then
            return;
        end

        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
        GameTooltip:AddLine(stateStrings[questState])
        GameTooltip:Show();
    end);

    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function ResizeHistoryWindow(scrollc, scrollf, height)
    local point, relativeTo, relativePoint, xOfs, yOfs = MinArchHist:GetPoint()
	local _, size1 = MinArchHist:GetSize();

    if (MinArch.db.profile.history.autoResize) then
        MinArchHistHeight = height + 85;
        scrollc:SetSize(275, height)
        scrollf:SetSize(275, height)
    else
        MinArchHistHeight = 310;
    end

    MinArchHist:ClearAllPoints();
    if (MinArchHist.firstRun == false and relativeTo == nil) then
        MinArchHist:SetPoint(point, UIParent, relativePoint, xOfs, yOfs);
    end

    if (MinArch.firstRun == false) then
        MinArchHist:ClearAllPoints();
        if (point ~= "TOPLEFT" and point ~= "TOP" and point ~= "TOPRIGHT") then
            MinArchHist:SetPoint(point, UIParent, relativePoint, xOfs, (yOfs + ( (size1 - MinArchHistHeight) / 2 )));
        else
            MinArchHist:SetPoint(point, UIParent, relativePoint, xOfs, yOfs);
        end
    else
        MinArchHist:SetPoint(point, "UIParent", relativePoint, xOfs, yOfs);
        MinArchHist.firstRun = false;
    end
    MinArchHist:SetHeight(MinArchHistHeight);

    for i,frame in pairs(scrollc.ArtifactFrames) do
        frame:SetWidth(frame:GetParent():GetWidth() - 15);
    end
end

local function GetArtifactFrame(scrollc, index)
    if (scrollc.ArtifactFrames[index]) then
        return scrollc.ArtifactFrames[index];
    end

    local parentWidth = scrollc:GetWidth();
    local padding = 5;

    local frame = CreateFrame("Frame", "$parentArtifact" .. index, scrollc);
    frame:SetSize(parentWidth, 20);
    frame:SetWidth(parentWidth - padding * 2);
    frame:SetPoint("TOPLEFT", scrollc, "TOPLEFT", padding, -20 * (index - 1) - padding * (index - 1));

    -- Artifact icon, and texture
    local icon = CreateFrame("Frame", "$parentIcon", frame);
    icon:SetSize(20, 20);
    icon:SetPoint("TOPLEFT", 0, 0)
    local iconTex = icon:CreateTexture("$parentIconTexture", "BACKGROUND")
    iconTex:SetAllPoints(true)
    iconTex:SetWidth(20)
    iconTex:SetHeight(20)
    iconTex:SetBlendMode("DISABLE")
    icon.texture = iconTex;
    frame.icon = icon;

    -- Artifact name
    local name = CreateFrame("Frame", "$parentName", frame);
    name:SetPoint("TOPLEFT", frame, "TOPLEFT", 20 + padding, 0)
    name:SetSize(parentWidth - 100, 20);
    local text = name:CreateFontString("$parentText", "OVERLAY");
    text:SetPoint("TOPLEFT", name, "TOPLEFT", 0, 0);
    text:SetSize(parentWidth, 20)
    text:SetFontObject("ChatFontSmall")
    text:SetWordWrap(true)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("CENTER")
    text:SetText("...");
    name.text = text;
    frame.name = name;

    -- Quest indicator
    local quest = CreateFrame("Frame", "$parentQuest", frame);
    quest:SetSize(16, 16);
    quest:SetPoint("CENTER", frame, "RIGHT", 0, 0);
    local qTex2 = quest:CreateTexture("$parentIconTexture", "BACKGROUND");
    qTex2:SetAllPoints(true)
    qTex2:SetPoint("CENTER", quest, "RIGHT", 0, 0);
    qTex2:SetSize(16, 16);
    qTex2:SetBlendMode("ADD");
    qTex2:SetTexture([[Interface\MINIMAP\OBJECTICONS]]);
    qTex2:SetTexCoord(0.125, 0.25, 0.125, 0.25);
    qTex2:SetAlpha(0.3)
    qTex2:Hide();
    local qTex = quest:CreateTexture("$parentIconTexture", "BACKGROUND");
    qTex:SetAllPoints(true)
    qTex:SetPoint("CENTER", quest, "RIGHT", 0, 0);
    qTex:SetSize(16, 16);
    qTex:SetBlendMode("ADD");
    quest.texture = qTex;
    quest.texture2 = qTex2;
    frame.quest = quest;

    -- Progress
    local progress = CreateFrame("Frame", "$parentProgress", frame);
    progress:SetSize(50, 20);
    progress:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -18, 0)
    local progressIcon = CreateFrame("Frame", "$parentIcon", progress);
    progressIcon:SetSize(16, 16);
    progressIcon:SetPoint("CENTER", progress, "RIGHT", 0, 0);
    local pTex = progressIcon:CreateTexture("$parentIconTexture", "BACKGROUND");
    pTex:SetAllPoints(true)
    pTex:SetPoint("CENTER", progressIcon, "CENTER", 0, 0);
    pTex:SetSize(16, 16);
    pTex:SetBlendMode("ADD");
    pTex:SetTexture([[Interface\ARCHEOLOGY\Arch-Icon-Marker]])
    local progressText = progress:CreateFontString("$parentText", "OVERLAY");
    progressText:SetPoint("TOPLEFT", progress, "TOPLEFT", 0, -1);
    progressText:SetSize(40, 20);
    progressText:SetFontObject("ChatFontSmall");
    progressText:SetWordWrap(true);
    progressText:SetJustifyH("RIGHT");
    progressText:SetJustifyV("CENTER");
    progressText:SetText("...");
    progressIcon.texture = pTex;
    progress.icon = progressIcon;
    progress.text = progressText;
    frame.progress = progress;

    scrollc.ArtifactFrames[index] = frame;

    return frame;
end

function MinArch:CreateHistoryList(RaceID, caller)
    if not MinArchHist:IsVisible() then
        return
    end

    MinArch:DisplayStatusMessage("createhistorylist", MINARCH_MSG_DEBUG)

	if (RaceID ~= MinArchOptions.CurrentHistPage) then
		MinArchOptions.CurrentHistPage = RaceID;
		MinArch:DimHistoryButtons();
		MinArch.raceButtons[RaceID]:SetAlpha(1.0);
	end

	MinArch:GetCurrentQuestArtifact();
	MinArchHistQuestIndicator:SetAlpha((RaceID == currentQuestArtifactRace) and 0.9 or 0.6);

	caller = (caller or "race button")
	local nextcaller = (caller or "race button") .. " -> CreateHistoryList(" .. ((MinArch.artifacts[RaceID].race or ("Race" .. RaceID)) or ("Race" .. RaceID)) .. ")"

	if (not MinArch:IsItemDetailsLoaded(RaceID)) then
		local allGood = true
		for i = 1, ARCHAEOLOGY_NUM_RACES do
			allGood = MinArch:LoadItemDetails(i, nextcaller .. "{i=" .. i .. "}") and allGood
		end

		if allGood then
			MinArch:DisplayStatusMessage("Minimal Archaeology - All items are loaded now.", MINARCH_MSG_DEBUG)
		else
			return
		end
    end

	MinArch:GetHistory(RaceID, nextcaller)

    local PADDING = 5;
	local width = 260; -- fixme get parent width
    local height = 0;

	for i=1, ARCHAEOLOGY_NUM_RACES do
		if (MinArchScroll[i]) then
			MinArchScroll[i]:Hide();
		end
	end

	local scrollf = MinArchScrollFrame
	if not scrollf then
		scrollf = CreateFrame("ScrollFrame", "MinArchScrollFrame", MinArchHist)
		scrollf:SetClipsChildren(true)
		scrollf:SetPoint("BOTTOMLEFT", MinArchHist, "BOTTOMLEFT", 12, 10)
	end
	scrollf:SetSize(width, 225)

	local scrollc = MinArchScroll[RaceID]
	if not scrollc then
        scrollc = CreateFrame("Frame", "MinArchScroll" .. RaceID)
        scrollc.ArtifactFrames = {};
		MinArchScroll[RaceID] = scrollc
	end
	scrollc:SetSize(width, 225)

	local scrollb = MinArchScrollBar or CreateFrame("Slider", "MinArchScrollBar", MinArchHist)
    local scrollPos = scrollb:GetValue() or 0;

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

	scrollc.artifacts = scrollc.artifacts or {};

	local groups = {
		[1]={rarity=7},
		[2]={rarity=4},
		[3]={rarity=3},
		[4]={rarity=2},
		[5]={rarity=0,goldmin=500000}, -- put the Crown Jewels of Suramar higher up in the list
		[6]={rarity=1},
		[7]={rarity=0,goldmax=500000},
	}

    MinArch:UpdateArtifact(RaceID);

    local count = 0;

    for _, gparams in ipairs(groups) do
        for itemid, details in pairs(MinArchHistDB[RaceID]) do
            if details.rarity == gparams.rarity
                and ((not gparams.goldmin) or details.sellprice >= gparams.goldmin)
                and ((not gparams.goldmax) or details.sellprice < gparams.goldmax)
            then
                count = count + 1;
                local frame = GetArtifactFrame(scrollc, count);

                -- Set icon
                frame.icon.texture:SetTexture(details.icon);
                frame.icon:SetScript("OnEnter", function (self)
                    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
                    GameTooltip:SetItemByID(itemid);
                    GameTooltip:Show();
                end);
                frame.icon:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)

                -- Set text
                local displayName = details.name;
                if (strlen(details.name) > 36) then
                    displayName = strsub(details.name, 0, 33) .. '...';
                end
                frame.name.text:SetText(displayName)
                frame.name.text:SetTextColor(ITEM_QUALITY_COLORS[details.rarity].r, ITEM_QUALITY_COLORS[details.rarity].g, ITEM_QUALITY_COLORS[details.rarity].b, 1.0)

                frame.name:SetScript("OnEnter", function (self)
                    MinArch:HistoryTooltip(self, RaceID, itemid)
                end);
                frame.name:SetScript("OnLeave", function()
                    MinArchTooltipIcon:Hide();
                    GameTooltip:Hide()
                end)

                -- Set pristine indicator
                local questState = MINARCH_QSTATE_NIL;
                if currentQuestArtifact == itemid then
                    frame.quest.texture:SetTexture([[Interface\QuestTypeIcons]]);
                    frame.quest.texture:SetTexCoord(0, 0.140625, 0.28125, 0.5625);
                    questState = MINARCH_QSTATE_LEGION_AVAILABLE;
                elseif MinArch.HasPristine[RaceID] == true then
                    if not details.pqid then
                        -- hide?
                    elseif C_QuestLog.IsQuestFlaggedCompleted(details.pqid) == true then
                        frame.quest.texture:SetTexture([[Interface\ACHIEVEMENTFRAME\UI-Achievement-Criteria-Check]]);
                        frame.quest.texture:SetTexCoord(0.125, 0.5625, 0, 0.6875);
                        frame.quest.texture2:Show();
                        questState = MINARCH_QSTATE_PRISTINE_COMPLETE
                    else
                        if C_QuestLog.IsOnQuest(details.pqid) then
                            frame.quest.texture:SetTexture([[Interface\GossipFrame\ActiveQuestIcon]]);
                            frame.quest.texture:SetTexCoord(0, 1, 0, 1);
                            questState = MINARCH_QSTATE_PRISTINE_ONQUEST
                        else
                            frame.quest.texture:SetTexture([[Interface\GossipFrame\IncompleteQuestIcon]]);
                            frame.quest.texture:SetTexCoord(0, 1, 0, 1);
                            questState = MINARCH_QSTATE_PRISTINE_INCOMPLETE
                        end
                        frame.quest.texture2:Hide();
                    end
                end
                SetQuestTooltip(frame.quest, questState);

                -- Set Progress
                local progressState = MINARCH_PROGRESS_UNKNOWN;
                local achievementState = MINARCH_ACHIPROGRESS_NONE;
                if not details.firstcomplete then
                    frame.progress.text:SetText("0");
                    frame.progress.text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1)
                elseif MinArch.artifacts[RaceID].project == details.artifactname then
                    if not details.totalcomplete or details.totalcomplete == 0 then
                        frame.progress.text:SetText("#1")
                    else
                        frame.progress.text:SetText("#" .. (details.totalcomplete + 1))
                    end
                    frame.progress.text:SetTextColor(1.0, 0.8, 0.0, 1.0)
                    progressState = MINARCH_PROGRESS_CURRENT;
                else
                    frame.progress.text:SetText("x" .. details.totalcomplete)
                    frame.progress.text:SetTextColor(0.0, 1.0, 0.0, 1.0)
                    progressState = MINARCH_PROGRESS_KNOWN;
                end

                local achiInProgress = false;
                if details.achievement then
                    local _, _, _, _, _, _, _, _, _, _, _, _, wasEarnedByMe, earnedBy = GetAchievementInfo(details.achievement)
                    achiInProgress = not wasEarnedByMe;
                    if wasEarnedByMe then
                        achievementState = MINARCH_ACHIPROGRESS_COMPLETE;
                    end
                end

                if achiInProgress then
                    frame.progress.icon.texture:SetTexture([[Interface\ACHIEVEMENTFRAME\UI-Achievement-Progressive-Shield-NoPoints]])
                    frame.progress.icon.texture:SetTexCoord(0.125, 0.53125, 0.125, 0.625);
                    frame.progress.icon:SetSize(14, 18);
                    frame.progress.icon.texture:SetSize(14, 18);
                    frame.progress.text:SetText(frame.progress.text:GetText() .. " /" .. 20)
                    achievementState = MINARCH_ACHIPROGRESS_INCOMPLETE;
                else
                    frame.progress.icon:SetSize(16, 16);
                    frame.progress.icon.texture:SetSize(16, 16);
                    if (MinArch.artifacts[RaceID].project and MinArch.artifacts[RaceID].project == details.artifactname) then
                        frame.progress.icon.texture:SetTexture([[Interface\MINIMAP\TRACKING\ArchBlob.PNG]])
                        frame.progress.icon.texture:SetTexCoord(0, 1, 0, 1);
                    else
                        frame.progress.icon.texture:SetTexture([[Interface\ARCHEOLOGY\Arch-Icon-Marker]])
                        frame.progress.icon.texture:SetTexCoord(0, 1, 0, 1);
                    end
                end

                SetProgressTooltip(frame.progress, progressState, achievementState, details.totalcomplete)
            end
            height = count * (20 + PADDING);
        end
    end

    -- Set the size of the scroll child
    if height > 2 then
        scrollc:SetHeight(height-2)
    end

    -- Set the scrollchild to be the frame of font strings we've created
    scrollf:SetScrollChild(scrollc)

    -- Set up the scrollbar to work properly
    local scrollMax = 0
    if not MinArch.db.profile.history.autoResize and height > 225 then
        scrollMax = height - 220
    end

    if (scrollMax == 0) then
        scrollb.thumb:Hide();
    else
        scrollb.thumb:Show();
    end

    scrollb:SetOrientation("VERTICAL")
    scrollb:SetSize(16, 225)
    scrollb:SetPoint("TOPLEFT", scrollf, "TOPRIGHT", 0, 0)
    scrollb:SetMinMaxValues(0, scrollMax)
    scrollb:SetValue(scrollPos)
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

    ResizeHistoryWindow(scrollc, scrollf, height);
    scrollc:Show()
end

function MinArch:DimHistoryButtons()
	for i=1, ARCHAEOLOGY_NUM_RACES do
		if (MinArch.raceButtons[i] and i ~= MinArchOptions.CurrentHistPage) then
			MinArch.raceButtons[i]:SetAlpha(MinArch:IsRaceRelevant(i) and 0.5 or 0.3);
		end
	end
end

function MinArch:HistoryTooltip(self, RaceID, ItemID)
	local artifact = MinArchHistDB[RaceID][ItemID];
	local discovereddate = {};

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");

	MinArchTooltipIcon.icon:SetTexture(artifact.icon)
	if (artifact.rarity == 4) then
		GameTooltip:AddLine(artifact.name, 0.65, 0.2, 0.93, 1.0)
	elseif (artifact.rarity == 3) then
		GameTooltip:AddLine(artifact.name, 0.0, 0.4, 0.8, 1.0)
	else
		GameTooltip:AddLine(artifact.name, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1)
	end

    GameTooltip:AddLine(artifact.description, 1.0, 1.0, 1.0, 1.0)
    if (artifact.description ~= artifact.spelldescription) then
        GameTooltip:AddLine(artifact.spelldescription, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
    end

	if not artifact["firstcomplete"] then
		GameTooltip:AddLine("Incomplete", GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1);
	elseif artifact["firstcomplete"] == 0 then
		GameTooltip:AddLine(" ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		if (artifact["sellprice"] ~= nil) then
			if (tonumber(artifact["sellprice"]) > 0) then
				GameTooltip:AddLine("|cffffffff"..GetCoinTextureString(artifact["sellprice"]), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
			end
		end
		GameTooltip:AddLine("In Progress", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
	else
		GameTooltip:AddLine(" ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		if (artifact["sellprice"] ~= nil) then
			if (tonumber(artifact["sellprice"]) > 0) then
				GameTooltip:AddLine("|cffffffff"..GetCoinTextureString(artifact["sellprice"]), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
			end
		end
		discovereddate = date("*t", artifact["firstcomplete"]);
		if (discovereddate) then
			GameTooltip:AddDoubleLine("Discovered On: |cffffffff"..discovereddate["month"].."/"..discovereddate["day"].."/"..discovereddate["year"], "x"..artifact["totalcomplete"], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		end
	end

	MinArchTooltipIcon:Show();
	GameTooltip:Show();
end

function MinArch:DelayedHistoryUpdate()
    if (histEventTimer ~= nil) then
        MinArch:DisplayStatusMessage("CreateHistory called too frequent, delaying by " .. historyUpdateTimout .. " seconds", MINARCH_MSG_DEBUG)
        histEventTimer:Cancel();
    end
    histEventTimer = C_Timer.NewTimer(historyUpdateTimout, function()
        MinArch:CreateHistoryList(MinArchOptions['CurrentHistPage'], "GetHistory")
        histEventTimer = nil;
    end)
end

function MinArch:HistoryButtonTooltip(RaceID)
	GameTooltip:SetOwner(MinArch.raceButtons[RaceID], "ANCHOR_TOPLEFT");
	GameTooltip:AddLine((MinArch.artifacts[RaceID].race or ("Race" .. RaceID)), 1.0, 1.0, 1.0, 1.0)
	GameTooltip:Show();
end

function MinArch:HideHistory()
	MinArchHist:Hide();
	MinArch.db.char.WindowStates.history = false;
end

function MinArch:ShowHistory()
	--if (UnitAffectingCombat("player")) then
	--	MinArchHist.showAfterCombat = true;
	--else
		MinArchHist:Show();
		MinArch.db.char.WindowStates.history = true;
	--end
end

function MinArchHist:Toggle()
	if (MinArchHist:IsVisible()) then
		MinArch:HideHistory();
	else
		MinArch:ShowHistory();
	end
end
