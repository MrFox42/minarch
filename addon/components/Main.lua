local ADDON, MinArch = ...

MinArchArtifactBars = {};

function MinArch:SetRelevancyToggleButtonTexture()
	local button = MinArchMainRelevancyButton;
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
	local button = MinArchMainRelevancyButton;
	if (MinArch.db.profile.relevancy.relevantOnly) then
		MinArch:ShowWindowButtonTooltip(button, "Show all races. \n\n|cFF00FF00Right click to open settings and customize relevancy options.|r");
	else
		MinArch:ShowWindowButtonTooltip(button, "Only show relevant races. \n\n|cFF00FF00Right click to open settings and customize relevancy options.|r");
	end
end

local function CreateRelevancyToggleButton(parent, x, y)
	local button = CreateFrame("Button", "$parentRelevancyButton", parent, BackdropTemplateMixin and "BackdropTemplate");
	button:SetSize(23.5, 23.5);
	button:SetPoint("TOPLEFT", x, y);
	MinArch:SetRelevancyToggleButtonTexture();

	button:SetScript("OnClick", function(self, button)
		if (button == "LeftButton") then
			MinArch.db.profile.relevancy.relevantOnly = (not MinArch.db.profile.relevancy.relevantOnly);
			MinArch:SetRelevancyToggleButtonTexture();
			MinArch:UpdateMain();
			ShowRelevancyButtonTooltip();
		end
	end);
	button:SetScript("OnMouseUp", function(self, button)
		if (button == "RightButton") then
			MinArch:OpenSettings(MinArch.Options.menu);
		end
	end);
	button:SetScript("OnEnter", ShowRelevancyButtonTooltip)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end)
end

local function CreateCrateButton(parent, x, y)
	local button = CreateFrame("Button", "$parentCrateButton", parent, "InsecureActionButtonTemplate");
    button:RegisterForClicks("AnyUp", "AnyDown");
	button:SetAttribute("type", "item");
	button:SetSize(25, 25);
	button:SetPoint("TOPLEFT", x, y);

	button:SetNormalTexture([[Interface\AddOns\MinimalArchaeology\Textures\CrateButtonUp]]);
	button:SetPushedTexture([[Interface\AddOns\MinimalArchaeology\Textures\CrateButtonDown]]);
	button:SetHighlightTexture([[Interface\Addons\MinimalArchaeology\Textures\CloseButtonHighlight]]);

	local overlay = CreateFrame("Frame", "$parentGlow", button);
	overlay:SetSize(28, 28);
	overlay:SetPoint("TOPLEFT", button, "TOPLEFT", -5, 5);
	overlay.texture = overlay:CreateTexture(nil, "OVERLAY");
	overlay.texture:SetAllPoints(overlay);
	overlay.texture:SetTexture([[Interface\Buttons\CheckButtonGlow]]);
	overlay:Hide();

	MinArch:SetCrateButtonTooltip(button);
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
            MinArch:ShowArtifactTooltip(self, self.race);
        end)
        artifactBar:SetScript("OnLeave", function (self)
            MinArch:HideArtifactTooltip();
        end)

        artifactBar.keystone:SetScript("OnClick", function(self, button, down)
            MinArch:KeystoneClick(self, i, button, down);
        end)
        artifactBar.keystone:SetScript("OnEnter", function(self)
            MinArch:KeystoneTooltip(self, i);
        end)

        artifactBar.buttonSolve:SetScript("OnClick", function(self)
            MinArch:SolveArtifact(self:GetParent().race);
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

function MinArch:InitMain(self)
    -- Init frame scripts

    self:SetScript("OnEvent", function(_, event, ...)
		MinArch:EventMain(event, ...);
    end)

	self:SetScript('OnShow', function ()
		MinArch:UpdateMain();
		if (MinArch:IsNavigationEnabled()) then
			MinArchMainAutoWayButton:Show();
		else
			MinArchMainAutoWayButton:Hide();
		end
	end)

    InitArtifactBars(self);

    self.openADIButton:SetScript("OnEnter", function(self)
        MinArch:ShowWindowButtonTooltip(self, "Open Digsites");
    end)
    self.buttonOpenHist:SetScript("OnEnter", function(self)
        MinArch:ShowWindowButtonTooltip(self, "Open History");
    end)

	local skillBarTexture = [[Interface\PaperDollInfoFrame\UI-Character-Skills-Bar]];
	self.skillBar:SetStatusBarTexture(skillBarTexture);
	self.skillBar:SetStatusBarColor(0.03125, 0.85, 0);

	MinArch:CreateAutoWaypointButton(self, 53, 3);
	CreateCrateButton(self, 32, 1);
    CreateRelevancyToggleButton(self, 10, 4);

	RegisterEvents(self);

	-- Values that don't need to be saved
	MinArch['frame']['defaultHeight'] = MinArchMain:GetHeight();
    MinArch['frame']['height'] = MinArchMain:GetHeight();

    MinArch:CommonFrameLoad(self);

	MinArch:DisplayStatusMessage("Minimal Archaeology Initialized!");
end

function MinArch:UpdateArchaeologySkillBar()
	local _, _, arch = GetProfessions();
	if (arch) then
		local name, _, rank, maxRank = GetProfessionInfo(arch);

		if (rank ~= ARCHAEOLOGY_MAX_RANK) then
			MinArchMain.skillBar:Show();
			MinArchMain.skillBar:SetMinMaxValues(0, maxRank);
			MinArchMain.skillBar:SetValue(rank);
            MinArchMain.skillBar.text:SetText(name.." "..rank.."/"..maxRank);
			if (maxRank ~= ARCHAEOLOGY_MAX_RANK and rank + 25 >= maxRank) then
				MinArchMain.skillBar.text:SetTextColor(1,1,0,1)
			else
				MinArchMain.skillBar.text:SetTextColor(1,1,1,1)
			end
            MinArch['frame']['height'] = MinArch['frame']['defaultHeight'];
            -- MinArch.artifactbars[1]:SetPoint("TOP", -25, -50);

			if MinArch.db.profile.companion.enable then
				if MinArch.db.profile.companion.features.skillBar.enabled then
					local width = math.floor(MinArch.Companion:GetWidth() * (rank / maxRank))
					MinArch.Companion.skillBar.progressBar:SetWidth(width);
					MinArch.Companion.skillBar.fontString:SetText(rank .. '/' .. maxRank)
					MinArch.Companion.skillBar:Show()
				else
					MinArch.Companion.skillBar:Hide()
				end
			end
		else
			MinArchMain.skillBar:Hide();
			if MinArch.db.profile.companion.enable then
				MinArch.Companion.skillBar:Hide()
			end
			MinArch['frame']['height'] = MinArch['frame']['defaultHeight'] - 25;
			-- MinArch.artifactbars[1]:SetPoint("TOP", -25, -25);
		end
	else
		if MinArch.db.profile.companion.enable then
        	MinArch.Companion.skillBar:Hide()
		end
		MinArchMain.skillBar:SetMinMaxValues(0, 100);
		MinArchMain.skillBar:SetValue(0);
		MinArchMain.skillBar.text:SetText(ARCHAEOLOGY_RANK_TOOLTIP);
	end
end

function MinArch:UpdateArtifact(RaceIndex)
	local numArtifacts = GetNumArtifactsByRace(RaceIndex);
	local rName, rTexture, rItemID, numFragmentsCollected, projectAmount = GetArchaeologyRaceInfo(RaceIndex);

    -- no data available yet?
	if numArtifacts == nil or not rName then return nil end

	MinArch['artifacts'][RaceIndex]['race'] = rName;
	MinArch['artifacts'][RaceIndex]['raceitemid'] = rItemID;
	MinArch['artifacts'][RaceIndex]['raceicon'] = rTexture;

	if (numArtifacts == 0 or projectAmount == 0) then
		MinArch['artifacts'][RaceIndex]['numKeystones'] = 0;
		MinArch['artifacts'][RaceIndex]['heldKeystones'] = 0;
		MinArch['artifacts'][RaceIndex]['progress'] = 0;
		MinArch['artifacts'][RaceIndex]['modifier'] = 0;
		MinArch['artifacts'][RaceIndex]['total'] = 0;
		MinArch['artifacts'][RaceIndex]['canSolve'] = false;
		MinArch['artifacts'][RaceIndex]['canSolvePrev'] = false;
	else
		SetSelectedArtifact(RaceIndex);

		-- KeyStones
		local availablekeystones = 0;
		if (MinArch.db.profile.raceOptions.keystone[RaceIndex]) then
			MinArch['artifacts'][RaceIndex]['appliedKeystones'] = 4;
		end
        for i=1, MinArch['artifacts'][RaceIndex]['appliedKeystones'] do
            MinArchHist:UnregisterEvent("RESEARCH_ARTIFACT_UPDATE");
            SocketItemToArtifact();
			if (ItemAddedToArtifact(i)) then
				availablekeystones = availablekeystones + 1;
            end
            MinArchHist:RegisterEvent("RESEARCH_ARTIFACT_UPDATE");
		end

		MinArch['artifacts'][RaceIndex]['appliedKeystones'] = availablekeystones;

		local name, description, rarity, icon, spellDescription, numKeystones, bgTexture = GetSelectedArtifactInfo();
		local progress, modifier, total = GetArtifactProgress();

		MinArch['artifacts'][RaceIndex]['numKeystones'] = numKeystones;
		MinArch['artifacts'][RaceIndex]['heldKeystones'] = GetItemCount(rItemID, false, false);
		MinArch['artifacts'][RaceIndex]['progress'] = progress;
		MinArch['artifacts'][RaceIndex]['modifier'] = modifier;
		MinArch['artifacts'][RaceIndex]['total'] = total;
		MinArch['artifacts'][RaceIndex]['canSolvePrev'] = MinArch['artifacts'][RaceIndex]['canSolve'];
		MinArch['artifacts'][RaceIndex]['canSolve'] = CanSolveArtifact();
		MinArch['artifacts'][RaceIndex]['project'] = name;
		MinArch['artifacts'][RaceIndex]['rarity'] = rarity;
		MinArch['artifacts'][RaceIndex]['description'] = description;
		MinArch['artifacts'][RaceIndex]['spelldescription'] = spellDescription;
		MinArch['artifacts'][RaceIndex]['icon'] = icon;
		MinArch['artifacts'][RaceIndex]['bg'] = bgTexture;
	end

	return 1
end

function MinArch:UpdateKeystones(keystoneFrame, RaceIndex)
	local artifact = MinArch['artifacts'][RaceIndex];
	if not artifact or not artifact['raceitemid'] then
		return
	end

	local runeName, _, _, _, _, _, _, _, _, runeStoneIconPath = C_Item.GetItemInfo(artifact['raceitemid']);

	keystoneFrame.icon:SetTexture(runeStoneIconPath);

	if (artifact['appliedKeystones'] == 0 or artifact['numKeystones'] == 0) then
		keystoneFrame.icon:SetAlpha(0.1);
	else
		keystoneFrame.icon:SetAlpha((artifact['appliedKeystones']/artifact['numKeystones']));
	end

	if (artifact['numKeystones'] > 0 and artifact['total'] > 0) then
		keystoneFrame.text:SetText(artifact['appliedKeystones'].."/"..artifact['numKeystones']);
		keystoneFrame:Show();
		keystoneFrame.icon:Show();
	else
		keystoneFrame:Hide();
	end
end

function MinArch:UpdateArtifactBar(RaceIndex)
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
	MinArch:UpdateKeystones(ArtifactBar.keystone, RaceIndex);

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
			if (MinArch.db.profile.autoShowOnSolve and MinArch:IsRaceRelevant(RaceIndex)) then
				if (MinArch.firstRun) then
					MinArch.overrideStartHidden = true;
				else
					MinArch:ShowMain();
				end
			end
			artifact['canSolvePrev'] = artifact['canSolve'];
		end

		ArtifactBar.buttonSolve:Enable();
	else
		ArtifactBar.buttonSolve:Disable();
	end

	if (MinArch.db.profile.autoShowOnCap and artifact['progress'] ~= 0 and artifact['progress'] == MinArchRaceConfig[RaceIndex].fragmentCap) then
		MinArch:ShowMain();
	end
end

function MinArch:SolveArtifact(RaceIndex, confirmed)
    if confirmed ~= true and MinArch.db.profile.showSolvePopup and MinArch.db.profile.raceOptions.cap[RaceIndex] then
        StaticPopupDialogs["MINARCH_SOLVE_CONFIRMATION"] = {
            text = "Are you sure you want to solve this artifact for this fragment-capped race?",
            button1 = "Yes",
            button2 = "No",
            button3 = "Yes, always!",
            OnAccept = function()
                MinArch:SolveArtifact(RaceIndex, true)
            end,
            OnAlt = function()
                MinArch.db.profile.showSolvePopup = false;
                MinArch:SolveArtifact(RaceIndex, true)
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }

        StaticPopup_Show ("MINARCH_SOLVE_CONFIRMATION")

        return
    end

	SetSelectedArtifact(RaceIndex);

    RemoveItemFromArtifact()
    for i=1, MinArch['artifacts'][RaceIndex]['appliedKeystones'] do
		SocketItemToArtifact();
	end
	
	SolveArtifact();

	MinArch:CreateHistoryList(RaceIndex, "SolveArtifact");
end

function MinArch:UpdateMain()
	if (InCombatLockdown()) then
		MinArch:DisplayStatusMessage("Main update delayed until combat ends", MINARCH_MSG_DEBUG);
		MinArchMain:RegisterEvent("PLAYER_REGEN_ENABLED");
		return;
	end

	local point, relativeTo, relativePoint, xOfs, yOfs = MinArchMain:GetPoint()
	local x1, size1 = MinArchMain:GetSize();

	local MinArchFrameHeight = ARCHAEOLOGY_NUM_RACES * 25 + 40

	local barY = -25;
	if (MinArchMain.skillBar:IsVisible()) then
		barY = -50;
		MinArchFrameHeight = MinArchFrameHeight + 20
	end

	for i=1,ARCHAEOLOGY_NUM_RACES do
        MinArch:UpdateArtifact(i);

		if (MinArch.db.profile.raceOptions.hide[i] == false and MinArch:IsRaceRelevant(i)) then
			MinArch:UpdateArtifactBar(i);
			MinArch.artifactbars[i]:Show();
			MinArch.artifactbars[i]:SetPoint("TOP", MinArchMain, "TOP", -25, barY);
			barY = barY - 25;
		else
			if (MinArch['artifactbars'][i] ~= nil) then
				MinArch['artifactbars'][i]:Hide();
				MinArchFrameHeight = MinArchFrameHeight - 25;
			end
		end
	end

	MinArchMain:ClearAllPoints();
	if (MinArch.firstRun == false and relativeTo == nil) then
		MinArchMain:SetPoint(point, UIParent, relativePoint, xOfs, yOfs);
	end

	if (MinArch.firstRun == false) then
		MinArchMain:ClearAllPoints();
		if (point ~= "TOPLEFT" and point ~= "TOP" and point ~= "TOPRIGHT") then
			MinArchMain:SetPoint(point, UIParent, relativePoint, xOfs, (yOfs + ( (size1 - MinArchFrameHeight) / 2 )));
		else
			MinArchMain:SetPoint(point, UIParent, relativePoint, xOfs, yOfs);
		end
	else
		MinArchMain:SetPoint(point, "UIParent", relativePoint, xOfs, yOfs);
		MinArch.firstRun = false;
	end
	MinArchMain:SetHeight(MinArchFrameHeight);

	MinArch:RefreshLDBButton();
	MinArch:RefreshCrateButtonGlow();
    MinArch:DimHistoryButtons();
    MinArch.Companion:AutoToggle();
    MinArch.Companion:Update();
end

function MinArch:ShowArtifactTooltip(self, RaceIndex)
    local artifact = MinArch['artifacts'][RaceIndex];

    if artifact.total == 0 then
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
        GameTooltip:AddLine("You haven't discovered this race yet.")
        GameTooltip:Show();
        return
    end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");

	MinArchTooltipIcon.icon:SetTexture(artifact['icon']);
	if (artifact['rarity'] == 1) then
		GameTooltip:AddLine(artifact['project'], 0.0, 0.4, 0.8, 1.0);
	else
		GameTooltip:AddLine(artifact['project'], GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1);
	end

	GameTooltip:AddLine(artifact['description'], 1.0, 1.0, 1.0, 1.0);
	GameTooltip:AddLine(artifact['spelldescription'], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);

	if (artifact["sellprice"] ~= nil) then
		GameTooltip:AddLine(" ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);

		if (tonumber(artifact["sellprice"]) > 0) then
			GameTooltip:AddLine("|cffffffff"..GetCoinTextureString(artifact["sellprice"]), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		end
	end

	if (artifact["firstcomplete"] ~= nil) then
		if (tonumber(artifact["firstcomplete"]) > 0) then
			if (artifact["sellprice"] == nil or artifact["sellprice"] == 0) then
				GameTooltip:AddLine(" ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
			end
			local discovereddate = date("*t", artifact["firstcomplete"]);
			GameTooltip:AddDoubleLine("Discovered On: |cffffffff"..discovereddate["month"].."/"..discovereddate["day"].."/"..discovereddate["year"], "x"..artifact["totalcomplete"], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		end
	end

	MinArchTooltipIcon:Show();
	GameTooltip:Show();
end

function MinArch:HideArtifactTooltip()
	MinArchTooltipIcon:Hide();
	GameTooltip:Hide();
end

function MinArch:KeystoneTooltip(self, raceID)
	local artifact = MinArch['artifacts'][raceID];
	local name = C_Item.GetItemInfo(artifact['raceitemid']);

	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");

	local plural = "s";
	if (artifact['heldKeystones'] == 1) then
		plural = "";
	end

	GameTooltip:SetItemByID(artifact['raceitemid']);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine("You have "..artifact['heldKeystones'].." "..tostring(name)..plural .. " in your bags", GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine("Left click to apply a keystone");
	GameTooltip:AddLine("Right click to remove a keystone");
	GameTooltip:Show();
end

function MinArch:KeystoneClick(self, raceID, button, down)
	local numofappliedkeystones = MinArch['artifacts'][raceID]['appliedKeystones'];
	local numoftotalkeystones = MinArch['artifacts'][raceID]['numKeystones'];

	if (button == "LeftButton") then
		if (numofappliedkeystones < numoftotalkeystones) then
			 MinArch['artifacts'][raceID]['appliedKeystones'] = numofappliedkeystones + 1;
		end
	elseif (button == "RightButton") then
		if (numofappliedkeystones > 0) then
			 MinArch['artifacts'][raceID]['appliedKeystones'] = numofappliedkeystones - 1;
		end
	end

	MinArch:UpdateArtifact(raceID);
	MinArch:UpdateArtifactBar(raceID);
	MinArch:RefreshLDBButton();
	MinArch.Companion:Update()
end

function MinArch:HideMain()
	MinArchMain:Hide();
	-- MinArch.db.profile.hideMain = true;
	MinArch.db.char.WindowStates.main = false;
end

function MinArch:ShowMain()
	--if (UnitAffectingCombat("player")) then
	--	MinArchMain.showAfterCombat = true;
	--else
		MinArchMain:Show();
		-- MinArch.db.profile.hideMain = false;
		MinArch.db.char.WindowStates.main = MinArch.db.profile.rememberState;
	--end
end

function MinArchMain:Toggle(overrideHideNext)
	if (MinArchMain:IsVisible()) then
		MinArch:HideMain()
	else
        MinArch:ShowMain()
        if (overrideHideNext) then
            MinArch.HideNext = false;
        end
	end
end

function MinArch:OpenWindow(button)
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
		MinArch:OpenSettings(MinArch.Options.menu);
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
