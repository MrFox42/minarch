MinArch = {};
MinArch['artifacts'] = {};
MinArch['artifactbars'] = {};
MinArch['barlinks'] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20}; -- TODO
MinArch['frame'] = {};
MinArchOptions = {};
MinArchOptions['ABOptions'] = {};
MinArch['activeUiMapID'] = nil;
MinArch['MapContinents'] = {};
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
}

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
	if (mapInfo.mapType < 2) then
		return nil;
	end

	if (mapInfo.mapType == 2) then
		return uiMapID;
	end

	if (mapInfo.mapType > 2) then
		return MinArch:GetNearestContinentId(mapInfo.parentMapID);
	end
end

function MinArch:DisplayStatusMessage(message)
	if (MinArchOptions['ShowStatusMessages'] == true) then
		ChatFrame1:AddMessage(message);
	end
end