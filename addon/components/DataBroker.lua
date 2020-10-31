local ADDON, MinArch = ...

local ldb = LibStub:GetLibrary("LibDataBroker-1.1");
local dataobj = ldb:NewDataObject("MinArch", {label = "MinArch", type = "data source", icon = "Interface\\Icons\\Trade_Archaeology_Dinosaurskeleton", text = ""});
local icon = LibStub("LibDBIcon-1.0", true);

function MinArch:InitLDB()
	icon:Register("MinArch", dataobj, MinArch.db.profile.minimap)

	MinArch:RefreshMinimapButton();
end

function MinArch:RefreshMinimapButton()
	icon:Refresh("MinArch", MinArch.db.profile.minimap)
	if (MinArch.db.profile.minimap.hide) then
		icon:Hide("MinArch");
	else
		icon:Show("MinArch");
	end
end

function MinArch:RefreshLDBButton()
	local digSite, distance, digSiteData = MinArch:GetNearestDigsite();
	if (digSiteData) then
		local text = digSiteData.race;

		local raceID = MinArch:GetRaceIdByName(digSiteData.race);
		if (MinArch['artifacts'][raceID]) then
			local progress = MinArch['artifacts'][raceID]['progress'] or 0;
			if (MinArch.db.profile.raceOptions.cap[raceID] == true) then
				text = text .. " " .. progress .. "/" .. MinArchRaceConfig[raceID].fragmentCap;
            else
                if (MinArch['artifacts'][raceID]['canSolve']) then
					text = text .. " (Solvable)";
                end

                if (MinArch['artifacts'][raceID]['progress'] ~= nil and MinArch['artifacts'][raceID]['total'] ~= nil) then
					if (MinArch['artifacts'][raceID]['appliedKeystones'] > 0) then
						progress = progress + (MinArch['artifacts'][raceID]['modifier'])
					end
					text = text .. " " .. progress .. "/" .. MinArch['artifacts'][raceID]['total'];
                end
			end
		end

		dataobj.text = text;
	else
		dataobj.text = 'n/a';
	end
end

-- Hide/Show the minimap button
function dataobj:OnClick(button)
	if (button == "LeftButton") then
		local shiftKeyIsDown = IsShiftKeyDown();
		local ctrlKeyIsDown = IsControlKeyDown();
		local altKeyDown = IsAltKeyDown();

		if shiftKeyIsDown then
			MinArchHist:Toggle();
		elseif ctrlKeyIsDown then
			MinArchDigsites:Toggle();
		else
			if (MinArchMain:IsVisible()) then
				MinArch:HideMain();
				if (altKeyDown) then
					MinArch:HideHistory();
					MinArch:HideDigsites();
				end
			else
				MinArch:ShowMain();
				MinArch.HideNext = false;
			end
		end

	elseif (button == "RightButton") then
		InterfaceOptionsFrame_OpenToCategory(MinArch.Options.menu);
		InterfaceOptionsFrame_OpenToCategory(MinArch.Options.menu);
	end
end

function dataobj:OnLeave()
	GameTooltip:Hide()
end

function dataobj:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	GameTooltip:ClearLines();
	GameTooltip:AddLine("Minimal Arcaeology", 1, 0.819, 0.003);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine("Hint: Left-Click to toggle MinArch main window.", 0, 1, 0)
	GameTooltip:AddLine("Shift + Left-Click to toggle MinArch history window.", 0, 1, 0)
	GameTooltip:AddLine("Ctrl + Left-Click to toggle MinArch dig sites window.", 0, 1, 0)
	GameTooltip:AddLine("Alt + Left-Click to hide every MinArch window.", 0, 1, 0)
	GameTooltip:AddLine("Right-click to open settings", 0, 1, 0)

	GameTooltip:Show()
end
