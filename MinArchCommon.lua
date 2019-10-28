-- Local variables

-- uiMapIDs for continents [uiMapID] = internalContID
local MinArchContIDMap = {
	[12] = 1, -- Kalimdor
	[13] = 2, -- EK
	[101] = 3, -- Outland
	[113] = 4, -- Northrend
	[948] = 5, -- Maelstrom
	[424] = 6, -- Pandaria
	[572] = 7, -- Draenor
	[619] = 8, -- Broken Isles
	[876] = 9, -- Kul Tiras
	[875] = 10, -- Zandalar
};

local MinArchContinentRaces = {
	[1] = {ARCHAEOLOGY_RACE_TOLVIR, ARCHAEOLOGY_RACE_TROLL, ARCHAEOLOGY_RACE_NIGHTELF, ARCHAEOLOGY_RACE_FOSSIL, ARCHAEOLOGY_RACE_DWARF}, -- Kalimdor
	[2] = {ARCHAEOLOGY_RACE_TOLVIR, ARCHAEOLOGY_RACE_TROLL, ARCHAEOLOGY_RACE_NIGHTELF, ARCHAEOLOGY_RACE_FOSSIL, ARCHAEOLOGY_RACE_DWARF}, -- EK
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

function MinArch:CommonFrameLoad(self)
	self:RegisterForDrag("LeftButton");
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
		ChatFrame1:AddMessage(message);
	end
end

function MinArch:GetRaceNameByBranchId(branchID)
	if (MinArch.ResearchBranchMap[branchID] ~= nil) then
		local raceId = MinArch.ResearchBranchMap[branchID];
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

	if (MinArch['artifacts'][raceID]['canSolve'] and MinArch.db.profile.relevancy.solvable) then
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

	return false;
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
	for k, v in pairs(MinArch.DigsiteLocales.enGB) do
		if (MinArchDigsiteList[k] == nil) then
			print("Missing race for: " .. k);
		end
	end

	for k, v in pairs(MinArchDigsiteList) do
		if (MinArch.DigsiteLocales.enGB[k] == nil) then
			print("Missing translation for: " .. k);
		end
	end
end

local function round(x)
    return math.floor(x + 0.5);
end

function MinArch:CalculateDistance(ax, ay, bx, by)
    local xd = math.abs(ax - bx);
    local yd = math.abs(ay - by);

    return round(((ax - bx) ^ 2 + (ay - by) ^ 2) ^ 0.5)
end
