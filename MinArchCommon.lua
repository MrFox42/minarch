MinArch = {};
MinArch['artifacts'] = {};
MinArch['artifactbars'] = {};
MinArch['barlinks'] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20};
MinArch['frame'] = {};
MinArchOptions = {};
MinArchOptions['ABOptions'] = {};
MinArch['ContIDMap'] = {
	[0] = 1, -- Kalimdor
	[1] = 2, -- EK
	[530] = 3, -- Outland
	[571] = 4, -- Northrend
	[730] = 5, -- Maelstrom
	[870] = 6, -- Pandaria
	[1116] = 7, -- Draenor
	[1220] = 8, -- Broken Isles
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

function MinArch:TranslateContinentId(ContID)
	if (MinArch.ContIDMap[ContID] ~= nil) then
		return MinArch.ContIDMap[ContID];
	end

	return -1;
end

function MinArch:DisplayStatusMessage(message)
	if (MinArchOptions['ShowStatusMessages'] == true) then
		ChatFrame1:AddMessage(message);
	end
end