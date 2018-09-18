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

-- don't spam about unknown digsites, only once each
local SpamBlock = {}

function MinArch:UpdateActiveDigSites()
	MinArch.RelevantRaces = {};
	-- can't do anything until all races are known
	if GetNumArchaeologyRaces()<ARCHAEOLOGY_NUM_RACES then
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

		for mapkey, zone in pairs(C_Map.GetMapChildrenInfo(zoneUiMapID, 3)) do
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
						local race = GetArchaeologyRaceInfo(MinArchDigsiteList[name])
						MinArchDigsitesGlobalDB["continent"][i][name]["race"] = race
					elseif not SpamBlock[name] then
						ChatFrame1:AddMessage("Minimal Archaeology: Unknown digsite "..name)
						SpamBlock[name] = 1
					end
				--end

				-- TODO: remove digsites assigned to the wrong continent in old/buggy releases
				
				local digsiteZone = C_Map.GetMapInfoAtPosition(uiMapID, x, y);
				local currentZoneUiMapID = MinArch:GetNearestZoneId(digsiteZone.mapID);
				if (currentZoneUiMapID ~= nil and (currentZoneUiMapID == uiMapID or currentZoneUiMapID == digsiteZone.parentMapID)) then
					if (playerContID == i and MinArchDigsiteList[name]) then
						MinArch.RelevantRaces[MinArchDigsiteList[name]] = true;
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
	
	if (ContID == 1) then
		MinArchDigsites.kalimdorButton:SetAlpha(1.0);
	elseif (ContID == 2) then
		MinArchDigsites.easternButton:SetAlpha(1.0);
	elseif (ContID == 3) then
		MinArchDigsites.outlandsButton:SetAlpha(1.0);
	elseif (ContID == 4) then
		MinArchDigsites.northrendButton:SetAlpha(1.0);
	elseif (ContID == 6) then
		MinArchDigsites.pandariaButton:SetAlpha(1.0);
	elseif (ContID == 7) then
		MinArchDigsites.draenorButton:SetAlpha(1.0);
	elseif (ContID == 8) then
		MinArchDigsites.brokenIslesButton:SetAlpha(1.0);
	elseif (ContID == 9) then
		MinArchDigsites.kulTirasButton:SetAlpha(1.0);
	elseif (ContID == 10) then
		MinArchDigsites.zandalarButton:SetAlpha(1.0);
	end
	
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
	MinArchDigsites.kalimdorButton:SetAlpha(0.5);
	MinArchDigsites.easternButton:SetAlpha(0.5);
	MinArchDigsites.outlandsButton:SetAlpha(0.5);
	MinArchDigsites.northrendButton:SetAlpha(0.5);
	MinArchDigsites.pandariaButton:SetAlpha(0.5);
	MinArchDigsites.draenorButton:SetAlpha(0.5);
	MinArchDigsites.brokenIslesButton:SetAlpha(0.5);
	MinArchDigsites.kulTirasButton:SetAlpha(0.5);
	MinArchDigsites.zandalarButton:SetAlpha(0.5);
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

	if (nearestDistance ~= nil and nearestDistance <= 5) then
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

	ax = playerPos.x * 100;
	ay = playerPos.y * 100;

	for key, digsite in pairs(C_ResearchInfo.GetDigSitesForMap(uiMapID)) do
		local name = tostring(digsite.name)
		local digsitex = digsite.position.x * 100;
		local digsitey = digsite.position.y * 100;

		local xd = math.abs(ax - tonumber(digsitex));
		local yd = math.abs(ay - tonumber(digsitey));
		local d = math.sqrt((xd*xd)+(yd*yd));

		if (MinArchDigsitesDB["continent"][ContID][name] and MinArchDigsitesDB["continent"][ContID][name]["status"] == true) then
			if (nearestDigSite == nil or d < nearestDistance) then
				nearestDigSite = name;
				nearestDistance = d;
				nearestDigSiteDetails = MinArchDigsitesGlobalDB["continent"][ContID][nearestDigSite];
			end
		end
	end

	return nearestDigSite, nearestDistance, nearestDigSiteDetails;
end

function MinArch:IsNearDigSite(distance)
	if (IsInInstance()) then
		return false;
	end

	if (distance == nil) then
		distance = 4
	end

	local nearestDistance = nil;
	local nearestDigSite = nil;
	local ax = 0;
	local ay = 0;
	local ContID = MinArch:GetInternalContId();

	local uiMapID = C_Map.GetBestMapForUnit("player");
	if (ContID == nil or uiMapID == nil) then
		return false;
	end
	
	local playerPos = C_Map.GetPlayerMapPosition(uiMapID, "player");
	if (playerPos == nil) then
		return false;
	end

	local contId, worldPos = C_Map.GetWorldPosFromMapPos(uiMapID, playerPos);

	ax = playerPos.x * 100;
	ay = playerPos.y * 100;
	
	for key, digsite in pairs(C_ResearchInfo.GetDigSitesForMap(uiMapID)) do
		local name = tostring(digsite.name)
		local digsitex = digsite.position.x * 100;
		local digsitey = digsite.position.y * 100;

		local xd = math.abs(ax - tonumber(digsitex));
		local yd = math.abs(ay - tonumber(digsitey));
		local d = math.sqrt((xd*xd)+(yd*yd));

		if (MinArchDigsitesDB["continent"][ContID][name] and MinArchDigsitesDB["continent"][ContID][name]["status"] == true) then
			if (nearestDigSite == nil or d < nearestDistance) then
				nearestDigSite = name;
				nearestDistance = d;
			end
		end
	end

	return nearestDistance ~= nil and nearestDistance < distance;
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
			WorldMapTooltip:Hide();
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
	
	MinArchTooltipIcon:SetParent(WorldMapTooltip);
	MinArchTooltipIcon:SetPoint("TOPRIGHT", WorldMapTooltip, "TOPLEFT");
	WorldMapTooltip:SetOwner(self, "ANCHOR_BOTTOM");	
	
	MinArch:DigsiteTooltip(self, name, digsite, WorldMapTooltip);
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

function MinArch:ToggleDigsites()
	if (MinArchDigsites:IsVisible()) then
		MinArchDigsites:Hide()
	else
		MinArchDigsites:Show()
	end
end