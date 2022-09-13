local ADDON, MinArch = ...

MinArch.Companion = CreateFrame("Frame", "MinArchCompanion", UIParent)

local Companion = MinArch.Companion
Companion.events = {}
Companion.initialized = false;

local cx, cy, cInstance;
local timer;
local baseHeight = 31;

local function RegisterForDrag(frame)
    local function OnDragStart(self)
        local f = self:GetParent();
        if f:GetName() == "UIParent" then
            f = self
        end

        if not MinArch.db.profile.companion.lock then
            f:StartMoving();
        end
    end
    local function OnDragStop(self)
        local f = self:GetParent();
        if f:GetName() == "UIParent" then
            f = self
        end

        f:StopMovingOrSizing();
        if MinArch.db.profile.companion.savePos then
            Companion:SavePosition();
        end
    end
    frame:RegisterForDrag("LeftButton"); -- Register for left drag
    frame:SetScript("OnDragStart", OnDragStart);
    frame:SetScript("OnDragStop", OnDragStop);
end


local function CalculateDistance(ax, ay, bx, by)
    local xd = math.abs(ax - bx);
    local yd = math.abs(ay - by);

    return MinArch:Round(((ax - bx) ^ 2 + (ay - by) ^ 2) ^ 0.5)
end

local function InitDistanceTracker()
    Companion.trackerFrame = CreateFrame("Frame", "$parentTracker", Companion)

    Companion.trackerFrame:SetPoint("LEFT", 0, 0)
    Companion.trackerFrame:SetWidth(40)
    Companion.trackerFrame:SetHeight(24)
    Companion.trackerFrame:SetFrameStrata("LOW")
    Companion.trackerFrame:Show()

    Companion.trackerFrame.indicator = CreateFrame("Frame", "$parentIndicator", Companion.trackerFrame)
    Companion.trackerFrame.indicator:SetPoint("LEFT", 2, 0)
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

    RegisterForDrag(Companion.trackerFrame);

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
    fontString:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE, MONOCHROME")
    fontString:SetText("")
    fontString:SetTextColor(0.0, 1.0, 0.0, 1.0)
    fontString:SetPoint("LEFT", Companion.trackerFrame.indicator, "LEFT", 19, -1)
    fontString:Show()

    Companion:SetScript("OnEvent", Companion.EventHandler)

    Companion.trackerFrame.fontString = fontString;
end

function Companion:SavePosition()
    local point, _, relativePoint, xOfs, yOfs = MinArchCompanion:GetPoint();
    MinArch.db.profile.companion.point = point;
    MinArch.db.profile.companion.relativePoint = relativePoint;
    MinArch.db.profile.companion.posX = xOfs;
    MinArch.db.profile.companion.posY = yOfs;
end

function Companion:ResetPosition()
    local point, relativeTo, relativePoint, xOfs, yOfs = MinArchCompanion:GetPoint();
    MinArch.Companion:ClearAllPoints();
    MinArch.Companion:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
    if (MinArch.db.profile.companion.savePos) then
        MinArch.Companion:SavePosition()
    end
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
    surveyButton:RegisterForClicks("AnyUp", "AnyDown");
    surveyButton:SetAttribute("type", "spell");
    surveyButton:SetAttribute("spell", SURVEY_SPELL_ID);
    surveyButton:SetPoint("LEFT", 44, 0);
    surveyButton:SetWidth(28);
    surveyButton:SetHeight(28);

    surveyButton:SetNormalTexture("Interface/Icons/inv_misc_shovel_01")
    surveyButton:SetHighlightTexture("Interface/Icons/inv_misc_shovel_01")
    surveyButton:SetPushedTexture("Interface/Icons/inv_misc_shovel_01")

    surveyButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
        GameTooltip:SetSpellByID(SURVEY_SPELL_ID);

		GameTooltip:Show();
    end)

	surveyButton:SetScript("OnLeave", function()
		GameTooltip:Hide();
    end)

    RegisterForDrag(surveyButton);

    Companion.surveyButton = surveyButton;
end

local function InitProjectFrame()
    -- Project Solve button
    local solveButton = CreateFrame("Button", "$parentSolveButton", Companion);
    solveButton:SetPoint("LEFT", 74, 2);
    solveButton:SetWidth(28);
    solveButton:SetHeight(28);

    RegisterForDrag(solveButton);

    Companion.solveButton = solveButton;
end

local function InitCrateButton()
    -- Crate Button
    local crateButton = CreateFrame("Button", "$parentCrateButton", Companion, "InsecureActionButtonTemplate");
    crateButton:RegisterForClicks("AnyUp", "AnyDown");
    crateButton:SetAttribute("type", "item");
    crateButton:SetPoint("LEFT", 108, 2);
    crateButton:SetWidth(28);
    crateButton:SetHeight(28);

    crateButton:SetNormalTexture("Interface/Icons/inv_crate_04")
    crateButton:SetHighlightTexture("Interface/Icons/inv_crate_04")
    crateButton:SetPushedTexture("Interface/Icons/inv_crate_04")

    MinArch:SetCrateButtonTooltip(crateButton);
    RegisterForDrag(crateButton);

    Companion.crateButton = crateButton;
end

function Companion:showCrateButton(itemID)
    if MinArch.db.profile.companion.enable and MinArch.db.profile.companion.features.crateButton.enabled and MinArch.Companion.initialized then
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
    if MinArch.db.profile.companion.savePos then
        Companion:ClearAllPoints();
        Companion:SetPoint(MinArch.db.profile.companion.point, UIParent, MinArch.db.profile.companion.relativePoint, MinArch.db.profile.companion.posX, MinArch.db.profile.companion.posY)
    end
    Companion:SetFrameScale(MinArch.db.profile.companion.frameScale);
end

function Companion.events:PLAYER_STARTED_MOVING(...)
    timer = MinArch.Ace:ScheduleRepeatingTimer(Companion.UpdateDistance, 0.1)
end

function Companion.events:ARCHAEOLOGY_SURVEY_CAST(...)
    cx, cy, _, cInstance = UnitPosition("player")
end

function Companion.events:PLAYER_STOPPED_MOVING(...)
    MinArch.Companion:AutoToggle();
    MinArch.Ace:CancelTimer(timer)
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

    local distance = CalculateDistance(cx, cy, nx, ny)
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
    MinArch.Ace:CancelTimer(timer)
    Companion:Update();
end

function Companion:EventHandler(event, ...)
    Companion.events[event](self, ...)
end

function Companion:HideFrame()
    Companion:Hide();
    if MinArch.db.profile.companion.enable then
        MinArch.CompanionShowInDigsite = true;
    end
end

function Companion:ShowFrame()
    if MinArch.db.profile.companion.enable then
        Companion:Show();
        MinArch.CompanionShowInDigsite = false;

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

    if MinArch.db.profile.companion.alwaysShow or (MinArch.CompanionShowInDigsite == true and MinArch:IsNearDigSite()) then
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
        Companion:SetHeight(baseHeight + MinArch.db.profile.companion.padding * 2)

        local tex = Companion:CreateTexture(nil, "BACKGROUND")
        tex:SetAllPoints()
        tex:SetColorTexture(MinArch.db.profile.companion.bg.r, MinArch.db.profile.companion.bg.g, MinArch.db.profile.companion.bg.b, MinArch.db.profile.companion.bg.a)
        Companion.texture = tex

        Companion.waypointButton = MinArch:CreateAutoWaypointButton(Companion, 12, 0)
        Companion.waypointButton:ClearAllPoints();
        Companion.waypointButton:SetPoint("LEFT", 26, 0);
        Companion.waypointButton:SetFrameStrata("MEDIUM");
        RegisterForDrag(Companion.waypointButton);

        Companion:SetMovable(true)
        Companion:EnableMouse(true)
        RegisterForDrag(Companion);

        Companion:SetPoint("CENTER", 0, 0)
        Companion:Show()

        InitDistanceTracker()
        InitSurveyButton()
        InitProjectFrame()
        InitCrateButton()

        Companion.initialized = true;
    end

    Companion:RegisterEvents();
    Companion:AutoToggle();
    Companion:Update();
end

function Companion:SetFrameScale(scale)
    local previousScale = Companion:GetScale();
    local point, _, relativePoint, xOfs, yOfs = MinArch.Companion:GetPoint()

    scale = tonumber(scale)/100;
    Companion:SetScale(scale);

    Companion:ClearAllPoints()
    Companion:SetPoint(point, UIParent, relativePoint, xOfs * (previousScale/scale), yOfs * (previousScale/scale));
end

local function toggleChildFrames()
    if MinArch.db.profile.companion.features.distanceTracker.enabled then
        Companion.trackerFrame:Show();
    else
        Companion.trackerFrame:Hide();
    end

    if MinArch.db.profile.companion.features.waypointButton.enabled and cx == nil then
        Companion.waypointButton:Show();
    else
        Companion.waypointButton:Hide();
    end

    if MinArch.db.profile.companion.features.surveyButton.enabled then
        Companion.surveyButton:Show();
    else
        Companion.surveyButton:Hide();
    end

    if not MinArch.db.profile.companion.features.solveButton.enabled then
        Companion.solveButton:Hide();
    end

    if not MinArch.db.profile.companion.features.crateButton.enabled then
        Companion.crateButton:Hide();
    end
end

function Companion:Resize()
    local buttons = {};
    local baseOffset =  MinArch.db.profile.companion.padding;
    local width = baseOffset;
    local buttonSpacing = MinArch.db.profile.companion.buttonSpacing;
    local waypointException = false;

    if not MinArch.db.profile.companion.enable then
        return false;
    end

    toggleChildFrames();

    -- Get visible child frames, resize accordingly
    buttons[MinArch.db.profile.companion.features.distanceTracker.order] = Companion.trackerFrame;
    buttons[MinArch.db.profile.companion.features.waypointButton.order] = Companion.waypointButton;
    buttons[MinArch.db.profile.companion.features.surveyButton.order] = Companion.surveyButton;
    buttons[MinArch.db.profile.companion.features.solveButton.order] = Companion.solveButton;
    buttons[MinArch.db.profile.companion.features.crateButton.order] = Companion.crateButton;

    if (Companion.waypointButton:IsVisible() and Companion.trackerFrame:IsVisible() and MinArch.db.profile.companion.features.waypointButton.order == MinArch.db.profile.companion.features.distanceTracker.order + 1) then
        waypointException = true;
        width = width - Companion.waypointButton:GetWidth();
    end

    for order, button in pairs(buttons) do
        local btnOffset = 0;

        if (button:IsVisible()) then
            if (order > 1) then
                if (waypointException and order > MinArch.db.profile.companion.features.distanceTracker.order) then
                    btnOffset = btnOffset - Companion.waypointButton:GetWidth() + buttonSpacing;
                end

                for i = 1, order - 1 do
                    if (buttons[i]:IsVisible()) then
                        btnOffset = btnOffset + buttons[i]:GetWidth() + buttonSpacing;
                    end
                end
            end

            width = width + button:GetWidth() + buttonSpacing;
            button:ClearAllPoints();
            button:SetPoint("LEFT", baseOffset + btnOffset, 0);
        end
    end

    Companion:SetWidth(width + baseOffset);
    Companion:SetHeight(baseHeight + MinArch.db.profile.companion.padding * 2)
end

local function shouldShowRace(raceID)
    -- Don't show hidden races
    if (MinArch.db.profile.raceOptions.hide[raceID]) then
        return false;
    end

    -- Don't show irrelevant races
    if (MinArch.db.profile.companion.relevantOnly and not MinArch:IsRaceRelevant(raceID)) then
        return false;
    end

    return true;
end

function Companion:Update()
    if not MinArch.db.profile.companion.enable then
        return false;
    end

    Companion.texture:SetColorTexture(MinArch.db.profile.companion.bg.r, MinArch.db.profile.companion.bg.g, MinArch.db.profile.companion.bg.b, MinArch.db.profile.companion.bg.a)

    Companion.solveButton:Hide();
    Companion:Resize();

    for i = 1, ARCHAEOLOGY_NUM_RACES do
        if shouldShowRace(i) then
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

                if MinArch.db.profile.companion.features.solveButton.enabled then
                    Companion.solveButton:Show();
                end
                Companion:Resize()
                return;
            end
        end
    end

end

