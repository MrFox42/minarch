local ADDON, _ = ...

---@class MinArchLDB
local MinArchLDB = MinArch:LoadModule("MinArchLDB")

---@type MinArchCommon
local Common = MinArch:LoadModule("MinArchCommon")
---@type MinArchDigsites
local Digsites = MinArch:LoadModule("MinArchDigsites")

local L = LibStub("AceLocale-3.0"):GetLocale("MinArch")

local ldb = LibStub:GetLibrary("LibDataBroker-1.1");
local dataobj = ldb:NewDataObject("MinimalArchaeology", {label = "MinArch", type = "data source", icon = "Interface\\Icons\\Trade_Archaeology_Dinosaurskeleton", text = ""});
local icon = LibStub("LibDBIcon-1.0", true);

function MinArchLDB:Init()
	icon:Register("MinArch", dataobj, MinArch.db.profile.minimap)

	MinArchLDB:RefreshMinimapButton();
end

function MinArchLDB:RefreshMinimapButton()
	icon:Refresh("MinArch", MinArch.db.profile.minimap)
	if (MinArch.db.profile.minimap.hide) then
		icon:Hide("MinArch");
	else
		icon:Show("MinArch");
	end
end

function MinArchLDB:RefreshLDBButton()
	local digSite, distance, digSiteData = Digsites:GetNearestDigsite();
	if (digSiteData) then
		local text = digSiteData.race;

		local raceID = Common:GetRaceIdByName(digSiteData.race);
		if (MinArch['artifacts'][raceID]) then
			local progress = MinArch['artifacts'][raceID]['progress'] or 0;
			if (MinArch.db.profile.raceOptions.cap[raceID] == true) then
				text = text .. " " .. progress .. "/" .. MinArchRaceConfig[raceID].fragmentCap;
            else
                if (MinArch['artifacts'][raceID]['canSolve']) then
					text = text .. " (" .. L["TOOLTIP_SOLVABLE"] .. ")";
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
	MinArch:OpenWindow(button)
end

function dataobj:OnLeave()
	GameTooltip:Hide()
end

function dataobj:OnEnter()
	---@diagnostic disable-next-line: param-type-mismatch
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	GameTooltip:ClearLines();
	GameTooltip:AddLine(L["OPTIONS_REGISTER_MINARCH"], 1, 0.819, 0.003);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(L["DATABROKER_HINT_LEFTCLICK"], 0, 1, 0)
	GameTooltip:AddLine(L["DATABROKER_HINT_SHIFT_LEFTCLICK"], 0, 1, 0)
	GameTooltip:AddLine(L["DATABROKER_HINT_CTRL_LEFTCLICK"], 0, 1, 0)
	GameTooltip:AddLine(L["DATABROKER_HINT_ALT_LEFTCLICK"], 0, 1, 0)
	GameTooltip:AddLine(L["DATABROKER_HINT_RIGHTCLICK"], 0, 1, 0)

	GameTooltip:Show()
end
