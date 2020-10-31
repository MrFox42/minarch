local ADDON, MinArch = ...

MinArchScroll = {}

MinArch.HistoryListLoaded = {}
MinArch.HasPristine = {}
MinArch.DigsiteButtons = {}

local qLineQuests = {};
local currentQuestArtifact = nil;
local currentQuestArtifactRace = nil;
local isOnArtifactQuestLine = false;
local qLineRaces = {ARCHAEOLOGY_RACE_DEMONIC, ARCHAEOLOGY_RACE_HIGHMOUNTAIN_TAUREN, ARCHAEOLOGY_RACE_HIGHBORNE};

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

function MinArch:InitHist(self)
	InitQuestIndicator(self);
    InitRaceButtons(self);

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

function MinArch:GetHistory(RaceID, caller)
	local i = 1
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

		-- pass 1: match both name and icon (because "Insect in Amber" and "Ancient Amber" have the same icon)
		-- pass 2: match only the icon if no matches in pass 1 were found (because some artifact names are different than the items they give)
		for pass = 1,2,1 do
			for itemid, details in pairs(MinArchHistDB[RaceID]) do
				if ((pass == 2 or details.name == name) and details.icon == icon) then
					details.artifactname = name
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
			if foundCount > 0 then
				break
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

function MinArch:CreateHistoryList(RaceID, caller)
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
	scrollf:SetSize(width, 230)

	local scrollc = MinArchScroll[RaceID]
	if not scrollc then
		scrollc = CreateFrame("Frame", "MinArchScroll" .. RaceID)
		MinArchScroll[RaceID] = scrollc
	end
	scrollc:SetSize(width, 230)

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

	-- Calculate all font strings twice, because measurements are wrong if they are done only once.
	-- To test this: set scale to 30%. Click a race button. The text should not have ellipse.
	-- If only one pass is used, click a race button, and see text has ellipse at 30%. click button again and it draws properly.
	for pass = 1, 2, 1 do
		local height = 0;
		local count = 0;
		local currentArtifact, currentFontString, cwidth, cheight, mouseframe, tmpText

		for group, gparams in ipairs(groups) do
			--print ("Group:", group, "rarity:", gparams.rarity, "min:", gparams.goldmin, "max:", gparams.goldmax)
			for itemid, details in pairs(MinArchHistDB[RaceID]) do
				if details.rarity == gparams.rarity
						and ((not gparams.goldmin) or details.sellprice >= gparams.goldmin)
						and ((not gparams.goldmax) or details.sellprice < gparams.goldmax) then
					count = count + 1

					currentArtifact = scrollc.artifacts[count]
					if not currentArtifact then
						currentArtifact = {
							description = scrollc:CreateFontString("Artifact" .. RaceID .. "_" .. count .. "Description", "OVERLAY"),
							status = scrollc:CreateFontString("Artifact" .. RaceID .. "_" .. count .. "Status", "OVERLAY"),
							mouseframe = CreateFrame("Frame", "Artifact" .. RaceID .. "_" .. count .. "MouseOver", scrollc)
						}
						if MinArch.HasPristine[RaceID] == true then
							currentArtifact.pristine = scrollc:CreateFontString("Artifact" .. RaceID .. "_" .. count .. "Pristine", "OVERLAY")
						end
						scrollc.artifacts[count] = currentArtifact
					end

					-- Description
					currentFontString = currentArtifact.description
					currentFontString:SetSize(width, 100)
					currentFontString:SetFontObject("ChatFontSmall")
					currentFontString:SetWordWrap(true)
					currentFontString:SetJustifyH("LEFT")
					currentFontString:SetJustifyV("CENTER")
					local displayName = details.name;
					if (strlen(details.name) > 31) then
						displayName = strsub(details.name, 0, 28) .. '...';
					end
					currentFontString:SetText(" |T" .. strsub(details.icon, 0, -5) .. ":16:16:0:0|t " .. displayName)
					currentFontString:SetTextColor(ITEM_QUALITY_COLORS[details.rarity].r, ITEM_QUALITY_COLORS[details.rarity].g, ITEM_QUALITY_COLORS[details.rarity].b, 1.0)

					cwidth = currentFontString:GetStringWidth()
					cheight = currentFontString:GetStringHeight()
					currentFontString:SetSize(cwidth + 18, cheight)

					if count == 1 then
						currentFontString:SetPoint("TOPLEFT", scrollc, "TOPLEFT", 0, 0)
					else
						currentFontString:SetPoint("LEFT", scrollc, "LEFT", 0, 0)
						currentFontString:SetPoint("TOP", scrollc.artifacts[count - 1].description, "TOP", 0, - PADDING - cheight)
						height = height + PADDING
					end

					-- Status
					currentFontString = currentArtifact.status
					currentFontString:SetSize(width, 100)
					currentFontString:SetFontObject("ChatFontSmall")
					currentFontString:SetWordWrap(false)
					currentFontString:SetJustifyH("RIGHT")
					currentFontString:SetJustifyV("TOP")

					if not details.firstcomplete then
						currentFontString:SetText("Incomplete")
						currentFontString:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1)
					elseif MinArch.artifacts[RaceID].project == details.artifactname then
						if not details.totalcomplete or details.totalcomplete == 0 then
							currentFontString:SetText("In Progress")
						else
							currentFontString:SetText("#" .. (details.totalcomplete + 1) .. " In Progress")
						end
						currentFontString:SetTextColor(1.0, 0.8, 0.0, 1.0)
					else
						currentFontString:SetText(details.totalcomplete .. " Completed")
						currentFontString:SetTextColor(0.0, 1.0, 0.0, 1.0)
					end

					-- Legion quests
					if (currentQuestArtifact == itemid) then
						tmpText = "";
						if (details.totalcomplete and details.totalcomplete > 0) then
							tmpText = "#" .. (details.totalcomplete + 1) .. " ";
						end

						if (isOnArtifactQuestLine) then
							currentFontString:SetText(tmpText .. "On quest");
							currentFontString:SetTextColor(1.0, 0.5, 0.0, 1.0)
						else
							currentFontString:SetText(tmpText .. "Quest available");
							currentFontString:SetTextColor(1.0, 0.5, 0.0, 1.0)
						end
					end


					cwidth = currentFontString:GetStringWidth()
					currentFontString:SetSize(cwidth + 5, cheight)

					local statusoffset = MinArch.HasPristine[RaceID] == true and -12 or 0

					if count == 1 then
						currentFontString:SetPoint("TOPRIGHT", scrollc, "TOPRIGHT", statusoffset, 0)
					else
						currentFontString:SetPoint("RIGHT", scrollc, "RIGHT", statusoffset, 0)
						currentFontString:SetPoint("TOP", scrollc.artifacts[count - 1].status, "TOP", 0, - PADDING - cheight)
					end

					-- Pristine
					if MinArch.HasPristine[RaceID] == true then
						currentFontString = currentArtifact.pristine
						currentFontString:SetSize(width, 100)
						currentFontString:SetFontObject("ChatFontSmall")
						currentFontString:SetWordWrap(false)
						currentFontString:SetJustifyH("RIGHT")
						currentFontString:SetJustifyV("TOP")

						if not details.pqid then
							currentFontString:SetText("-")
							currentFontString:SetTextColor(0.0, 1.0, 0.0, 1.0)
						elseif C_QuestLog.IsQuestFlaggedCompleted(details.pqid) == true then
							currentFontString:SetText("+")
							currentFontString:SetTextColor(0.0, 1.0, 0.0, 1.0)
						else
							currentFontString:SetText("x")
							currentFontString:SetTextColor(1.0, 0.0, 0.0, 1.0)
						end

						cwidth = currentFontString:GetStringWidth()
						currentFontString:SetSize(cwidth + 5, cheight)

						if count == 1 then
							currentFontString:SetPoint("TOPRIGHT", scrollc, "TOPRIGHT", 0, 0)
						else
							currentFontString:SetPoint("RIGHT", scrollc, "RIGHT", 0, 0)
							currentFontString:SetPoint("TOP", scrollc.artifacts[count - 1].pristine, "TOP", 0, - PADDING - cheight)
						end
					end

					-- height calc
					height = height + cheight
					--print("height", height, "cheight", cheight)

					-- Tooltip
					mouseframe = currentArtifact.mouseframe
					mouseframe:SetSize(width, cheight)
					mouseframe:SetPoint("BOTTOMRIGHT", currentFontString, "BOTTOMRIGHT", 0, 0)

					mouseframe:SetScript("OnEnter", function(self)
												MinArch:HistoryTooltip(self, RaceID, itemid)
											end)
					mouseframe:SetScript("OnLeave", function()
												MinArchTooltipIcon:Hide();
												GameTooltip:Hide()
											end)
				end
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
		if height > 230 then
			scrollMax = height - 220
		end

		if (scrollMax == 0) then
			scrollb.thumb:Hide();
		else
			scrollb.thumb:Show();
		end

		scrollb:SetOrientation("VERTICAL")
		scrollb:SetSize(16, 230)
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
	end

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

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");

	MinArchTooltipIcon.icon:SetTexture(artifact.icon)
	if (artifact.rarity == 4) then
		GameTooltip:AddLine(artifact.name, 0.65, 0.2, 0.93, 1.0)
	elseif (artifact.rarity == 3) then
		GameTooltip:AddLine(artifact.name, 0.0, 0.4, 0.8, 1.0)
	else
		GameTooltip:AddLine(artifact.name, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1)
	end

	GameTooltip:AddLine(artifact.description, 1.0, 1.0, 1.0, 1.0)
	GameTooltip:AddLine(artifact.spelldescription, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)

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
