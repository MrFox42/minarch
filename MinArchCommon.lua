-- MinArch.db.profile.
MinArch.defaults = {
	profile = {
		settingsVersion = 0,
		disableSound = false,
		startHidden = false,
		hideMain = false,
		frameScale = 100,
		showStatusMessages = false,
		showDebugMessages = false,
		showWorldMapOverlay = true,
		hideAfterDigsite = false,
		waitForSolve = false,
		autoShowOnSurvey = false,
		autoShowOnSolve = false,
		autoShowInDigsites = false,
		minimap = {
			minimapPos = 45,
			hide = false
		},
		
		-- dynamic options
		raceOptions = {
			hide = {
	
			},
			cap = {
	
			},
			keystone = {
				
			}
		},

		-- deprecated, left for compatibility
		hideMinimapButton = false,
		minimapPos = 45,
	},	
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

function MinArch:GetInternalContId()
	local uiMapID = C_Map.GetBestMapForUnit("player");
	if not uiMapID then
		return nil;
	end
	local mapInfo = C_Map.GetMapInfo(uiMapID);
	if (mapInfo == nil) then
		return nil;
	end
	local ContID = MinArch.ContIDMap[MinArch:GetNearestContinentId(mapInfo.parentMapID)];

	return ContID;
end

-- Return uiMapID by internal MinArch ContID index
function MinArch:GetUiMapIdByContId(ContID)
	for k, v in pairs(MinArch.ContIDMap) do
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

function MinArch:GetRaceIdByName(name)
	if (MinArch.RacesLoaded == false) then
		MinArch:LoadRaceInfo();
	end
	
	return MinArch.ArchaeologyRaces[name];
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