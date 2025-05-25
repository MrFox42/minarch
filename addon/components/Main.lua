local ADDON, _ = ...
---@class MinArchMain
local Main = MinArch:LoadModule("MinArchMain")
Main.frame = _G["MinArchMain"];

---@type MinArchOptions
local Options = MinArch:LoadModule("MinArchOptions")
---@type MinArchDigsites
local Digsites = MinArch:LoadModule("MinArchDigsites")
---@type MinArchHistory
local History = MinArch:LoadModule("MinArchHistory")
---@type MinArchCompanion
local Companion = MinArch:LoadModule("MinArchCompanion")
---@type MinArchCommon
local Common = MinArch:LoadModule("MinArchCommon")
---@type MinArchLDB
local MinArchLDB = MinArch:LoadModule("MinArchLDB")
---@type MinArchNavigation
local Navigation = MinArch:LoadModule("MinArchNavigation")

local L = LibStub("AceLocale-3.0"):GetLocale("MinArch")

MinArchArtifactBars = {};

local function SetRelevancyToggleButtonTexture()
	local button = Main.frame.relevancyButton;
	if (MinArch.db.profile.relevancy.relevantOnly) then
		button:SetNormalTexture([[Interface\Buttons\UI-Panel-ExpandButton-Up]]);
		button:SetPushedTexture([[Interface\Buttons\UI-Panel-ExpandButton-Down]]);
	else
		button:SetNormalTexture([[Interface\Buttons\UI-Panel-CollapseButton-Up]]);
		button:SetPushedTexture([[Interface\Buttons\UI-Panel-CollapseButton-Down]]);
	end

	button:SetBackdrop({
		bgFile = [[Interface\GLUES\COMMON\Glue-RightArrow-Button-Up]],
		edgeFile = nil, tile = false, tileSize = 0, edgeSize = 0,
		insets = { left = 0.5, right = 1, top = 2.4, bottom = 1.4 }
	});
	button:SetHighlightTexture([[Interface\Addons\MinimalArchaeology\Textures\CloseButtonHighlight]]);
	button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", 10, -10);
end

local function ShowRelevancyButtonTooltip()
	local button = Main.frame.relevancyButton;
	if (MinArch.db.profile.relevancy.relevantOnly) then
		Common:ShowWindowButtonTooltip(button, L["TOOLTIP_MAIN_RELEVANCY_DISABLE"]);
	else
		Common:ShowWindowButtonTooltip(button, L["TOOLTIP_MAIN_RELEVANCY_ENABLE"]);
	end
end

local function CreateRelevancyToggleButton(parent, x, y)
	local button = CreateFrame("Button", "$parentRelevancyButton", parent, BackdropTemplateMixin and "BackdropTemplate");
	button:SetParentKey('relevancyButton')
	button:SetSize(23.5, 23.5);
	button:SetPoint("TOPLEFT", x, y);
	SetRelevancyToggleButtonTexture();

	button:SetScript("OnClick", function(self, button)
		if (button == "LeftButton") then
			MinArch.db.profile.relevancy.relevantOnly = (not MinArch.db.profile.relevancy.relevantOnly);
			SetRelevancyToggleButtonTexture();
			Main:Update();
			ShowRelevancyButtonTooltip();
		end
	end);
	button:SetScript("OnMouseUp", function(self, button)
		if (button == "RightButton") then
			Common:OpenSettings(Options.raceSettings);
		end
	end);
	button:SetScript("OnEnter", ShowRelevancyButtonTooltip)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end)
end

local function CreateCrateButton(parent, x, y)
	local button = CreateFrame("Button", "$parentCrateButton", parent, "InsecureActionButtonTemplate");
	button:SetParentKey('crateButton')
    button:RegisterForClicks("AnyUp", "AnyDown");
	button:SetAttribute("type", "item");
	button:SetSize(25, 25);
	button:SetPoint("TOPLEFT", x, y);

	button:SetNormalTexture([[Interface\AddOns\MinimalArchaeology\Textures\CrateButtonUp]]);
	button:SetPushedTexture([[Interface\AddOns\MinimalArchaeology\Textures\CrateButtonDown]]);
	button:SetHighlightTexture([[Interface\Addons\MinimalArchaeology\Textures\CloseButtonHighlight]]);

	local overlay = CreateFrame("Frame", "$parentGlow", button);
	overlay:SetParentKey('glow')
	overlay:SetSize(28, 28);
	overlay:SetPoint("TOPLEFT", button, "TOPLEFT", -5, 5);
	overlay.texture = overlay:CreateTexture(nil, "OVERLAY");
	overlay.texture:SetAllPoints(overlay);
	overlay.texture:SetTexture([[Interface\Buttons\CheckButtonGlow]]);
	overlay:Hide();

	Common:SetCrateButtonTooltip(button);
end

local function InitArtifactBars(self)
    -- Create the artifact bars for the main window
	local barY = -25;
	for i=1,ARCHAEOLOGY_NUM_RACES do
        local artifactBar = CreateFrame("StatusBar", "MinArchArtifactBar" .. i, self, "MATArtifactBar", i);
        artifactBar.parentKey = "artifactBar" .. i;
        artifactBar.race = i;
		artifactBar:SetPoint("TOP", self, "TOP", -25, barY);
		barY = barY - 25;

        local barTexture = [[Interface\Archeology\Arch-Progress-Fill]];
        artifactBar:SetStatusBarTexture(barTexture);

        MinArch['artifacts'][i] = {};
        MinArch['artifacts'][i]['appliedKeystones'] = 0;
        MinArch['artifactbars'][i] = artifactBar;
        MinArchArtifactBars[i] = MinArch['artifactbars'][i]; -- AddonSkins compatibility

        artifactBar:SetScript("OnEnter", function (self)
            History:ShowArtifactTooltip(self, self.race);
        end)
        artifactBar:SetScript("OnLeave", function (self)
            History:HideArtifactTooltip();
        end)

        artifactBar.keystone:SetScript("OnClick", function(self, button, down)
            Common:KeystoneClick(self, i, button, down);
        end)
        artifactBar.keystone:SetScript("OnEnter", function(self)
            Common:KeystoneTooltip(self, i);
        end)

        artifactBar.buttonSolve:SetScript("OnClick", function(self)
            History:SolveArtifact(self:GetParent().race);
        end)
    end
end

local function RegisterEvents(self)
    -- Update Artifacts
    self:RegisterEvent("RESEARCH_ARTIFACT_COMPLETE");
    self:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE");
    self:RegisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED");
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
    self:RegisterEvent("SKILL_LINES_CHANGED");
    self:RegisterEvent("PLAYER_ALIVE");
    self:RegisterEvent("LOOT_CLOSED");
    self:RegisterEvent("BAG_UPDATE");
    -- self:RegisterEvent("RESEARCH_ARTIFACT_HISTORY_READY");
    self:RegisterEvent("ARCHAEOLOGY_FIND_COMPLETE");
    self:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST");
    self:RegisterEvent("ARCHAEOLOGY_CLOSED");
    self:RegisterEvent("QUEST_TURNED_IN");
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LEAVE_COMBAT");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
    self:RegisterEvent("QUEST_LOG_UPDATE");
    self:RegisterEvent("PLAYER_STOPPED_MOVING");
    self:RegisterEvent("ZONE_CHANGED");
    self:RegisterEvent("ZONE_CHANGED_INDOORS");
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
    -- Tracking
    self:RegisterEvent("CVAR_UPDATE");

    -- Apply SavedVariables
    self:RegisterEvent("ADDON_LOADED");
end

function Main:Init()
    -- Init frame scripts

    Main.frame:SetScript("OnEvent", function(_, event, ...)
		MinArch:EventMain(event, ...);
    end)

	Main.frame:SetScript('OnShow', function ()
		Main:Update();
		if (Navigation:IsNavigationEnabled()) then
			Main.frame.autoWaypointButton:Show();
		else
			Main.frame.autoWaypointButton:Hide();
		end
	end)

    InitArtifactBars(Main.frame);

    Main.frame.openADIButton:SetScript("OnEnter", function(self)
        Common:ShowWindowButtonTooltip(self, L["TOOLTIP_OPEN_DIGSITES"]);
    end)
    Main.frame.openHistButton:SetScript("OnEnter", function(self)
        Common:ShowWindowButtonTooltip(self, L["TOOLTIP_OPEN_HISTORY"]);
    end)
	Main.frame.openADIButton:SetScript("OnClick", function()
		Digsites:ToggleWindow()
	end)
	Main.frame.openHistButton:SetScript("OnClick", function()
		History:ToggleWindow()
	end)

	Main.frame.closeButton:SetScript("OnClick", function()
		Main:HideWindow()
	end)

	local skillBarTexture = [[Interface\PaperDollInfoFrame\UI-Character-Skills-Bar]];
	Main.frame.skillBar:SetStatusBarTexture(skillBarTexture);
	Main.frame.skillBar:SetStatusBarColor(0.03125, 0.85, 0);

	Common:CreateAutoWaypointButton(Main.frame, 53, 3);
	CreateCrateButton(Main.frame, 32, 1);
    CreateRelevancyToggleButton(Main.frame, 10, 4);

	RegisterEvents(Main.frame);

	-- Values that don't need to be saved
	MinArch['frame']['defaultHeight'] = Main.frame:GetHeight();
    MinArch['frame']['height'] = Main.frame:GetHeight();

    Common:FrameLoad(Main.frame);

	Common:DisplayStatusMessage("Minimal Archaeology Initialized!");
end

function Main:UpdateArchaeologySkillBar()
	local _, _, arch = GetProfessions();
	if (arch) then
		local name, _, rank, maxRank = GetProfessionInfo(arch);

		if (rank ~= ARCHAEOLOGY_MAX_RANK) then
			Main.frame.skillBar:Show();
			Main.frame.skillBar:SetMinMaxValues(0, maxRank);
			Main.frame.skillBar:SetValue(rank);
            Main.frame.skillBar.text:SetText(name.." "..rank.."/"..maxRank);
			if (maxRank ~= ARCHAEOLOGY_MAX_RANK and rank + 25 >= maxRank) then
				Main.frame.skillBar.text:SetTextColor(1,1,0,1)
			else
				Main.frame.skillBar.text:SetTextColor(1,1,1,1)
			end
            MinArch['frame']['height'] = MinArch['frame']['defaultHeight'];
            -- MinArch.artifactbars[1]:SetPoint("TOP", -25, -50);

			if MinArch.db.profile.companion.enable then
				if MinArch.db.profile.companion.features.skillBar.enabled then
					local width = math.floor(Companion.frame:GetWidth() * (rank / maxRank))
					Companion.skillBar.progressBar:SetWidth(width);
					Companion.skillBar.fontString:SetText(rank .. '/' .. maxRank)
					Companion.skillBar:Show()
				else
					Companion.skillBar:Hide()
				end
			end
		else
			Main.frame.skillBar:Hide();
			if MinArch.db.profile.companion.enable then
				Companion.skillBar:Hide()
			end
			MinArch['frame']['height'] = MinArch['frame']['defaultHeight'] - 25;
			-- MinArch.artifactbars[1]:SetPoint("TOP", -25, -25);
		end
	else
		if MinArch.db.profile.companion.enable then
        	Companion.skillBar:Hide()
		end
		Main.frame.skillBar:SetMinMaxValues(0, 100);
		Main.frame.skillBar:SetValue(0);
		Main.frame.skillBar.text:SetText(ARCHAEOLOGY_RANK_TOOLTIP);
	end
end

function Main:UpdateArtifactBar(RaceIndex)
	if (MinArch.IsReady == false) then
		return false;
	end

	local artifact = MinArch['artifacts'][RaceIndex];
	local runeName, _, _, _, _, _, _, _, _, runeStoneIconPath = C_Item.GetItemInfo(artifact['raceitemid']);
	local total = artifact['total']

	if (MinArch.db.profile.raceOptions.cap[RaceIndex] == true) then
		total = MinArchRaceConfig[RaceIndex].fragmentCap
	end

	ArtifactBar = MinArch['artifactbars'][RaceIndex]
	ArtifactBar:SetMinMaxValues(0, total);
    ArtifactBar:SetValue(min(artifact['progress']+artifact['modifier'], total));
    ArtifactBar.race = RaceIndex;

	-- Keystone
	Common:UpdateKeystones(ArtifactBar.keystone, RaceIndex);

	-- Rarity
	if (artifact['rarity'] == 1) then
		ArtifactBar.text:SetTextColor(0.0, 0.3922, 0.7843, 1.0);
	else
		ArtifactBar.text:SetTextColor(1.0, 1.0, 1.0, 1.0);
	end

	if (artifact['modifier'] > 0) then
		ArtifactBar.text:SetText(artifact['race'].." (+"..artifact['modifier']..") "..(artifact['progress']+artifact['modifier']).."/"..total);
	else
		ArtifactBar.text:SetText(artifact['race'].." "..artifact['progress'].."/"..total);
	end

	if (artifact['canSolve']) then
		if (artifact['canSolvePrev'] ~= artifact['canSolve']) then
			if (MinArch.db.profile.disableSound == false) then
				PlaySound(3175, "SFX");
			end
			if (MinArch.db.profile.autoShowOnSolve and Common:IsRaceRelevant(RaceIndex)) then
				if (MinArch.firstRun) then
					MinArch.overrideStartHidden = true;
				else
					Main:ShowWindow();
				end
			end
			artifact['canSolvePrev'] = artifact['canSolve'];
		end

		ArtifactBar.buttonSolve:Enable();
	else
		ArtifactBar.buttonSolve:Disable();
	end

	if (MinArch.db.profile.autoShowOnCap and artifact['progress'] ~= 0 and artifact['progress'] == MinArchRaceConfig[RaceIndex].fragmentCap) then
		Main:ShowWindow();
	end
end

function Main:Update()
	if (InCombatLockdown()) then
		Common:DisplayStatusMessage("Main update delayed until combat ends", MINARCH_MSG_DEBUG);
		Main.frame:RegisterEvent("PLAYER_REGEN_ENABLED");
		return;
	end

	local point, relativeTo, relativePoint, xOfs, yOfs = Main.frame:GetPoint()
	local x1, size1 = Main.frame:GetSize();

	local MinArchFrameHeight = (ARCHAEOLOGY_NUM_RACES - ARCHAEOLOGY_RACE_OTHER) * 25 + 40

	if ARCHAEOLOGY_RACE_OTHER == 1 then
		MinArch.artifactbars[1]:Hide();
	end

	local barY = -25;
	if (Main.frame.skillBar:IsVisible()) then
		barY = -50;
		MinArchFrameHeight = MinArchFrameHeight + 20
	end

	for i=ARCHAEOLOGY_RACE_OTHER+1,ARCHAEOLOGY_NUM_RACES do
        History:UpdateArtifact(i);

		if (MinArch.db.profile.raceOptions.hide[i] == false and Common:IsRaceRelevant(i)) then
			Main:UpdateArtifactBar(i);
			MinArch.artifactbars[i]:Show();
			MinArch.artifactbars[i]:SetPoint("TOP", Main.frame, "TOP", -25, barY);
			barY = barY - 25;
		else
			if (MinArch['artifactbars'][i] ~= nil) then
				MinArch['artifactbars'][i]:Hide();
				MinArchFrameHeight = MinArchFrameHeight - 25;
			end
		end
	end

	Main.frame:ClearAllPoints();
	if (MinArch.firstRun == false and relativeTo == nil) then
		Main.frame:SetPoint(point, UIParent, relativePoint, xOfs, yOfs);
	end

	if (MinArch.firstRun == false) then
		Main.frame:ClearAllPoints();
		if (point ~= "TOPLEFT" and point ~= "TOP" and point ~= "TOPRIGHT") then
			Main.frame:SetPoint(point, UIParent, relativePoint, xOfs, (yOfs + ( (size1 - MinArchFrameHeight) / 2 )));
		else
			Main.frame:SetPoint(point, UIParent, relativePoint, xOfs, yOfs);
		end
	else
		Main.frame:SetPoint(point, "UIParent", relativePoint, xOfs, yOfs);
		MinArch.firstRun = false;
	end
	Main.frame:SetHeight(MinArchFrameHeight);

	MinArchLDB:RefreshLDBButton();
	Common:RefreshCrateButtonGlow();
    History:DimHistoryButtons();
    Companion:AutoToggle();
    Companion:Update();
end

function Main:HideWindow()
	Main.frame:Hide();
	-- MinArch.db.profile.hideMain = true;
	MinArch.db.char.WindowStates.main = false;
end

function Main:ShowWindow()
	--if (UnitAffectingCombat("player")) then
	--	Main.showAfterCombat = true;
	--else
		Main.frame:Show();
		-- MinArch.db.profile.hideMain = false;
		MinArch.db.char.WindowStates.main = MinArch.db.profile.rememberState;
	--end
end

function Main:ToggleWindow(overrideHideNext)
	if (Main.frame:IsVisible()) then
		Main:HideWindow()
	else
        Main:ShowWindow()
        if (overrideHideNext) then
            MinArch.HideNext = false;
        end
	end
end

function MinArch_OnAddonCompartmentClick(_, button)
	MinArch:OpenWindow(button)
end

function MinArch_OnAddonCompartmentEnter()
    --
end
function MinArch_OnAddonCompartmentLeave()
    --
end
