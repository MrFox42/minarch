-- TODO: documentation

MinArch.Companion = CreateFrame("Frame", "MinArchCompanion", UIParent)

local Companion = MinArch.Companion
Companion.events = {}

local cx, cy, cInstance;
local timer;

local function InitDistanceTracker()
    Companion.trackerFrame = CreateFrame("Frame", "MinArchCompanion", Companion)

    Companion.trackerFrame:SetPoint("LEFT", 0, 0)
    Companion.trackerFrame:SetWidth(36)
    Companion.trackerFrame:SetHeight(24)
    Companion.trackerFrame:Show()

    Companion.trackerFrame.indicator = CreateFrame("Frame", "$parentIndicator", Companion.trackerFrame)
    Companion.trackerFrame.indicator:SetPoint("LEFT", 5, 0)
    Companion.trackerFrame.indicator:SetWidth(16)
    Companion.trackerFrame.indicator:SetHeight(16)

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

    -- Register events
    Companion:RegisterEvent("PLAYER_STARTED_MOVING")
    Companion:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST")
    Companion:RegisterEvent("PLAYER_STOPPED_MOVING")
    Companion:RegisterEvent("PLAYER_ENTERING_WORLD")
    Companion:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE")
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

function Companion:showCrateButton()
    Companion.crateButton:Show();
    Companion:Resize()
end

function Companion:hideCrateButton()
    MinArch.Companion.crateButton:Hide();
    Companion:Resize()
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
    MinArch:CancelTimer(timer)
end

function Companion.events:ARTIFACT_DIGSITE_COMPLETE(...)
    Companion:HideDistance()
end

function Companion:UpdateDistance()
    nx, ny, _, nInstance = UnitPosition("player")

    if (cx == nil or cInstance ~= nInstance) then return end

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
    Companion.trackerFrame.indicator.texture:SetTexCoord(0.5, 1, 0.5, 1)
    Companion.trackerFrame.fontString:SetText("")
    MinArch:CancelTimer(timer)
    Companion.waypointButton:Show();
end

function Companion:EventHandler(event, ...)
    Companion.events[event](self, ...)
end

function Companion:HideFrame()
    MinArch.Companion:Hide();
    MinArchCompanionShowInDigsite = true;
end

function Companion:ShowFrame()
    MinArch.Companion:Show();
    MinArchCompanionShowInDigsite = false;
end

function Companion:AutoToggle()
    if IsInInstance() or (MinArch.db.profile.hideInCombat and UnitAffectingCombat("player")) then
        MinArch.Companion:Hide();
        return;
    end

    if MinArch.db.profile.companion.alwaysShow or (MinArchCompanionShowInDigsite == true and MinArch:IsNearDigSite()) then
        Companion:ShowFrame()
    end

    if not MinArch.db.profile.companion.alwaysShow and not MinArch:IsNearDigSite() then
        Companion:HideFrame()
    end
end

function Companion:Init()
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

    Companion:SetFrameScale(MinArch.db.profile.companion.frameScale);

    Companion:Resize()
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
    for i = 1, ARCHAEOLOGY_NUM_RACES do
        -- if relevant
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

