-- TODO: documentation

MinArch.Companion = CreateFrame("Frame", "MinArchCompanion", UIParent)

local Companion = MinArch.Companion
Companion.events = {}
Companion.initialized = false;

local cx, cy, cInstance;
local timer;

local function InitDistanceTracker()
    Companion.trackerFrame = CreateFrame("Frame", "$parentTracker", Companion)

    Companion.trackerFrame:SetPoint("LEFT", 0, 0)
    Companion.trackerFrame:SetWidth(36)
    Companion.trackerFrame:SetHeight(24)
    Companion.trackerFrame:Show()

    Companion.trackerFrame.indicator = CreateFrame("Frame", "$parentIndicator", Companion.trackerFrame)
    Companion.trackerFrame.indicator:SetPoint("LEFT", 5, 0)
    Companion.trackerFrame.indicator:SetWidth(16)
    Companion.trackerFrame.indicator:SetHeight(16)

    Companion.trackerFrame:SetScript("OnMouseUp", function(self, button)
        if (button == "RightButton") then
            InterfaceOptionsFrame_OpenToCategory(MinArch.Options.companionSettings);
            InterfaceOptionsFrame_OpenToCategory(MinArch.Options.companionSettings);

            MinArch.db.profile.companion.showHelpTip = false;
            HelpPlate_TooltipHide();
        end
    end)

    Companion.trackerFrame:SetScript("OnEnter", function(self)
        if (MinArch.db.profile.companion.showHelpTip) then
            HelpPlate_TooltipHide();
            HelpPlateTooltip.ArrowUP:Show();
            HelpPlateTooltip.ArrowGlowUP:Show();
            HelpPlateTooltip:SetPoint("BOTTOM", MinArchCompanion, "TOP", 0, 20);
            HelpPlateTooltip.Text:SetText("This is the Mininimal Archaeology Companion frame with distance tracker and more."
                                            .. "|n|n"
                                            .. "|cFFFFD100[Right-Click]|r to disable this tutorial tooltip and to show customization settings.");
            HelpPlateTooltip:Show();
        end
    end)

    Companion.trackerFrame:SetScript("OnLeave", function()
        if (MinArch.db.profile.companion.showHelpTip) then
            HelpPlate_TooltipHide();
        end
	end)

    local tex = Companion.trackerFrame.indicator:CreateTexture("IndicatorTexture", "BACKGROUND")
    tex:SetAllPoints(true)
    tex:SetWidth(16)
    tex:SetHeight(16)
    tex:SetTexture("Interface\\Addons\\MinimalArchaeology\\Textures\\Indicator.tga")
    tex:SetBlendMode("ADD")
    tex:SetTexCoord(0.5, 1, 0.5, 1)
    Companion.trackerFrame.indicator.texture = tex

    Companion.trackerFrame.indicator:Show()

    local fontString = Companion.trackerFrame.indicator:CreateFontString("$parentDistanceText", "OVERLAY")
    fontString:SetFontObject("ChatFontSmall")
    fontString:SetText("")
    fontString:SetTextColor(0.0, 1.0, 0.0, 1.0)
    fontString:SetPoint("LEFT", Companion.trackerFrame.indicator, "LEFT", 20, 0)
    fontString:Show()

    Companion:SetScript("OnEvent", Companion.EventHandler)

    Companion.trackerFrame.fontString = fontString;
end

function Companion:RegisterEvents()
    Companion:RegisterEvent("PLAYER_STARTED_MOVING")
    Companion:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST")
    Companion:RegisterEvent("PLAYER_STOPPED_MOVING")
    Companion:RegisterEvent("PLAYER_ENTERING_WORLD")
    Companion:RegisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED")
end

function Companion:UnregisterEvents()
    Companion:UnregisterEvent("PLAYER_STARTED_MOVING")
    Companion:UnregisterEvent("ARCHAEOLOGY_SURVEY_CAST")
    Companion:UnregisterEvent("PLAYER_STOPPED_MOVING")
    Companion:UnregisterEvent("PLAYER_ENTERING_WORLD")
    Companion:UnregisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED")
end

local function InitSurveyButton()
    -- Survey button
    local surveyButton = CreateFrame("Button", "$parentSurveyButton", Companion, "InSecureActionButtonTemplate");
    surveyButton:SetAttribute("type", "spell");
    surveyButton:SetAttribute("spell", 80451);
    surveyButton:SetPoint("LEFT", 44, 0);
    surveyButton:SetWidth(28);
    surveyButton:SetHeight(28);

    surveyButton:SetNormalTexture("Interface/Icons/inv_misc_shovel_01")
    surveyButton:SetHighlightTexture("Interface/Icons/inv_misc_shovel_01")
    surveyButton:SetPushedTexture("Interface/Icons/inv_misc_shovel_01")

    surveyButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
        GameTooltip:SetSpellByID(80451);

		GameTooltip:Show();
    end)

	surveyButton:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end)

    Companion.surveyButton = surveyButton;
end

local function InitProjectFrame()
    -- Project Solve button
    local solveButton = CreateFrame("Button", "$parentSolveButton", Companion);
    solveButton:SetPoint("LEFT", 74, 2);
    solveButton:SetWidth(28);
    solveButton:SetHeight(28);

    Companion.solveButton = solveButton;
end

local function InitCrateButton()
    -- Crate Button
    local crateButton = CreateFrame("Button", "$parentCrateButton", Companion, "InsecureActionButtonTemplate");
    crateButton:SetAttribute("type", "item");
    crateButton:SetPoint("LEFT", 108, 2);
    crateButton:SetWidth(28);
    crateButton:SetHeight(28);

    crateButton:SetNormalTexture("Interface/Icons/inv_crate_04")
    crateButton:SetHighlightTexture("Interface/Icons/inv_crate_04")
    crateButton:SetPushedTexture("Interface/Icons/inv_crate_04")

    MinArch:SetCrateButtonTooltip(crateButton);

    Companion.crateButton = crateButton;
end

function Companion:showCrateButton(itemID)
    if MinArch.db.profile.companion.enable and MinArch.Companion.initialized then
        if itemID then
            MinArch.Companion.crateButton:SetAttribute("item", "item:" .. itemID);
        end
        Companion.crateButton:Show();
        Companion:Resize()
    end
end

function Companion:hideCrateButton()
    if MinArch.db.profile.companion.enable and MinArch.Companion.initialized then
        MinArch.Companion.crateButton:Hide();
        Companion:Resize()
    end
end

function Companion.events:PLAYER_ENTERING_WORLD(...)
  --
end

function Companion.events:PLAYER_STARTED_MOVING(...)
    timer = MinArch:ScheduleRepeatingTimer(Companion.UpdateDistance, 0.1)
end

function Companion.events:ARCHAEOLOGY_SURVEY_CAST(...)
    cx, cy, _, cInstance = UnitPosition("player")
end

function Companion.events:PLAYER_STOPPED_MOVING(...)
    MinArch.Companion:AutoToggle();
    MinArch:CancelTimer(timer)
end

function Companion.events:RESEARCH_ARTIFACT_DIG_SITE_UPDATED(...)
    Companion:HideDistance()
end

function Companion:UpdateDistance()
    local nx, ny, _, nInstance = UnitPosition("player")

    if (cx == nil or cInstance ~= nInstance) then
        Companion:HideDistance()
        return
    end

    local distance = MinArch:CalculateDistance(cx, cy, nx, ny)
    Companion.trackerFrame.fontString:SetText(distance)

    if (distance >= 0 and distance <= 40) then
        Companion.trackerFrame.indicator.texture:SetTexCoord(0, 0.5, 0, 0.5)
        Companion.trackerFrame.fontString:SetTextColor(0, 1, 0, 1);
        Companion.waypointButton:Hide();
    elseif (distance > 40 and distance <= 80) then
        Companion.trackerFrame.indicator.texture:SetTexCoord(0, 0.5, 0.5, 1)
        Companion.trackerFrame.fontString:SetTextColor(1, 0.65, 0, 1);
        Companion.waypointButton:Hide();
    elseif (distance > 80 and distance < 300) then
        Companion.trackerFrame.indicator.texture:SetTexCoord(0.5, 1, 0, 0.5)
        Companion.trackerFrame.fontString:SetTextColor(1, 0, 0, 1);
        Companion.waypointButton:Hide();
    else
        Companion:HideDistance();
    end

end

function Companion:HideDistance()
    cx = nil;
    Companion.trackerFrame.indicator.texture:SetTexCoord(0.5, 1, 0.5, 1)
    Companion.trackerFrame.fontString:SetText("")
    MinArch:CancelTimer(timer)
    Companion.waypointButton:Show();
end

function Companion:EventHandler(event, ...)
    Companion.events[event](self, ...)
end

function Companion:HideFrame()
    Companion:Hide();
    if MinArch.db.profile.companion.enable then
        MinArchCompanionShowInDigsite = true;
    end
end

function Companion:ShowFrame()
    if MinArch.db.profile.companion.enable then
        Companion:Show();
        MinArchCompanionShowInDigsite = false;

        Companion:Resize()
    end
end

function Companion:AutoToggle()
    if not Companion.initialized or not MinArch.db.profile.companion.enable then
        return;
    end

    if IsInInstance() or (MinArch.db.profile.hideInCombat and UnitAffectingCombat("player")) then
        Companion:HideFrame();
        return;
    end

    if MinArch.db.profile.companion.alwaysShow or (MinArchCompanionShowInDigsite == true and MinArch:IsNearDigSite()) then
        Companion:ShowFrame()
    end

    if not MinArch.db.profile.companion.alwaysShow and not MinArch:IsNearDigSite() then
        Companion:HideFrame()
    end
end

function Companion:Enable()
    Companion:Init();
end

function Companion:Disable()
    Companion:Hide();
    Companion:UnregisterEvents();
end

function Companion:Init()
    if not MinArch.db.profile.companion.enable then
        return
    end

    if not Companion.initialized then
        MinArch:DisplayStatusMessage("Initializing Companion", MINARCH_MSG_DEBUG)

        Companion:SetFrameStrata("BACKGROUND")
        Companion:SetWidth(142)
        Companion:SetHeight(38)

        local tex = Companion:CreateTexture(nil, "BACKGROUND")
        tex:SetAllPoints()
        tex:SetColorTexture(0, 0, 0, 0.5)
        Companion.texture = tex

        Companion.waypointButton = MinArch:CreateAutoWaypointButton(Companion, 12, 0)
        Companion.waypointButton:ClearAllPoints();
        Companion.waypointButton:SetPoint("LEFT", 22, 0);

        Companion:SetMovable(true)
        Companion:EnableMouse(true)
        Companion:RegisterForDrag("LeftButton")
        Companion:SetScript("OnDragStart", Companion.StartMoving)
        Companion:SetScript("OnDragStop", Companion.StopMovingOrSizing)

        Companion:SetPoint("CENTER", 0, 0)
        Companion:Show()

        InitDistanceTracker()
        InitSurveyButton()
        InitProjectFrame()
        InitCrateButton()

        Companion.initialized = true;
    end

    Companion:RegisterEvents();
    Companion:SetFrameScale(MinArch.db.profile.companion.frameScale);
    Companion:AutoToggle();
    Companion:Update();
end

function Companion:SetFrameScale(scale)
    local previousScale = Companion:GetScale();
    local point, relativeTo, relativePoint, xOfs, yOfs = MinArch.Companion:GetPoint()

    scale = tonumber(scale)/100;
    Companion:SetScale(scale);

    Companion:ClearAllPoints()
    Companion:SetPoint(point, UIParent, relativePoint, xOfs * (previousScale/scale), yOfs * (previousScale/scale));
end

function Companion:Resize()
    if not MinArch.db.profile.companion.enable then
        return false;
    end

    -- Get visible child frames, resize accordingly
    local width = 44;

    local surveyBtnVisible = Companion.surveyButton:IsVisible() and 1 or 0;
    local solveBtnVisible = Companion.solveButton:IsVisible() and 1 or 0;
    local crateBtnVisible = Companion.crateButton:IsVisible() and 1 or 0;

    width = width + (surveyBtnVisible + solveBtnVisible + crateBtnVisible) * 34;
    Companion.solveButton:SetPoint("LEFT", 44 + surveyBtnVisible * 34, 0);
    Companion.crateButton:SetPoint("LEFT", 44 + (surveyBtnVisible + solveBtnVisible) * 34, 0);

    Companion:SetWidth(width);
end

function Companion:Update()
    if not MinArch.db.profile.companion.enable then
        return false;
    end

    for i = 1, ARCHAEOLOGY_NUM_RACES do
        -- if MinArch:IsRaceRelevant(i) then
            local artifact = MinArch['artifacts'][i]

            if (artifact.canSolve) then
                Companion.solveButton:SetNormalTexture(artifact.icon)
                Companion.solveButton:SetHighlightTexture(artifact.icon)
                Companion.solveButton:SetPushedTexture(artifact.icon)

                Companion.solveButton:SetScript("OnClick", function(self, button)
                    MinArch:SolveArtifact(i)
                end);
                Companion.solveButton:SetScript("OnEnter", function(self)
                    MinArch:ShowArtifactTooltip(self, i)
                    GameTooltip:AddLine(" ");
                    GameTooltip:AddLine("Left click to solve this artifact");
                    GameTooltip:Show();
                end)
                Companion.solveButton:SetScript("OnLeave", function()
                    MinArch:HideArtifactTooltip();
                end)

                Companion.solveButton:Show();
                Companion:Resize()
                return;
            end
        -- end
    end

    Companion.solveButton:Hide();
    Companion:Resize()
end

