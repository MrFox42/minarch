local AceAddon = LibStub("AceAddon-3.0");
MinArch = LibStub("AceAddon-3.0"):NewAddon('Minimal Archaeology');
-- MinArch.db.profile.
MinArch.defaults = {
	profile = {
		settingsVersion = 0,
		hideMinimapButton = false,
		disableSound = false;
		
		-- dynamic options
		raceOptions = {
			hide = {
	
			},
			cap = {
	
			},
			keystone = {
				
			}
		}
	},	
}

-- MinArch = {};
MinArch['artifacts'] = {};
MinArch['artifactbars'] = {};
MinArch['barlinks'] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20}; -- TODO
MinArch['frame'] = {};
MinArchOptions = {};
MinArchOptions['ABOptions'] = {};
MinArch['activeUiMapID'] = 12;
MinArch['ArchaeologyRaces'] = {};
MinArch['MapContinents'] = {};
MinArch['RacesLoaded'] = false;
MinArch['ContIDMap'] = {
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

	-- alternate ids
	[1014] = 9, -- Kul Tiras
	[1011] = 10, -- Zandalar
};
MinArch['ResearchBranchMap'] = {
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

MinArchHideNext = false;
MinArchIsReady = false;

SLASH_MINARCH1 = "/minarch"
SlashCmdList["MINARCH"] = function(msg, editBox)
	if (msg == "hide") then
		MinArch:HideMain();
	elseif (msg == "show") then
		MinArch:ShowMain();
	elseif (msg == "toggle") then
		MinArch:ToggleMain();
	elseif (msg == "version") then
		ChatFrame1:AddMessage("Minimal Archaeology "..tostring(GetAddOnMetadata("MinimalArchaeology", "Version")));
	else
		ChatFrame1:AddMessage("Minimal Archaeology Commands");
		ChatFrame1:AddMessage(" Usage: /minarch [cmd]");
		ChatFrame1:AddMessage(" Commands:");
		ChatFrame1:AddMessage("  hide - Hide the main Minimal Archaeology Frame");
		ChatFrame1:AddMessage("  show - Show the main Minimal Archaeology Frame");
		ChatFrame1:AddMessage("  toggle - Toggle the main Minimal Archaeology Frame");
		ChatFrame1:AddMessage("  version - Display the running version of Minimal Archaeology");
	end
end

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

function MinArch:DisplayStatusMessage(message)
	if (MinArchOptions['ShowStatusMessages'] == true) then
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