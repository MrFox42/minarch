local ADDON, _ = ...
---@class MinArchCompanion
local Companion = MinArch:LoadModule("MinArchCompanion")

---@type MinArchMain
local Main = MinArch:LoadModule("MinArchMain")
---@type MinArchOptions
local Options = MinArch:LoadModule("MinArchOptions")
---@type MinArchCommon
local Common = MinArch:LoadModule("MinArchCommon")
---@type MinArchDigsites
local Digsites = MinArch:LoadModule("MinArchDigsites")
---@type MinArchHistory
local History = MinArch:LoadModule("MinArchHistory")

local L = LibStub("AceLocale-3.0"):GetLocale("MinArch")

Companion.frame = CreateFrame("Frame", "MinArchCompanion", UIParent)
Companion.events = {}
Companion.initialized = false
Companion.showInDigsite = true

local cx, cy, cInstance;
local timer;
local baseHeight = 31;
local updateTimer

if HelpPlate_TooltipHide == nil then
    HelpPlate_TooltipHide = function ()
        HelpPlateTooltip:Hide()
    end
end

local MinArchDistanceTrackerShapes = {
    "Interface\\Addons\\MinimalArchaeology\\Textures\\Indicator.tga",
    "Interface\\Addons\\MinimalArchaeology\\Textures\\IndicatorSquare.tga",
    "Interface\\Addons\\MinimalArchaeology\\Textures\\IndicatorTriangle.tga"
}

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

    return Common:Round(((ax - bx) ^ 2 + (ay - by) ^ 2) ^ 0.5)
end

local function OpenSettingsAndHideHelp(self, button)
    if (button == "RightButton") then
        Common:OpenSettings(Options.companionSettings);

        MinArch.db.profile.companion.showHelpTip = false;
        HelpPlate_TooltipHide();
    end
end

local function InitDistanceTracker()
    Companion.trackerFrame = CreateFrame("Frame", "$parentTracker", Companion.frame)

    Companion.trackerFrame:SetPoint("LEFT", 0, 0)
    Companion.trackerFrame:SetWidth(40)
    Companion.trackerFrame:SetHeight(24)
    Companion.trackerFrame:SetFrameStrata("LOW")
    Companion.trackerFrame:Show()

    Companion.trackerFrame.indicator = CreateFrame("Frame", "$parentIndicator", Companion.trackerFrame)
    Companion.trackerFrame.indicator:SetPoint("LEFT", 2, 0)
    Companion.trackerFrame.indicator:SetWidth(16)
    Companion.trackerFrame.indicator:SetHeight(16)

    Companion.trackerFrame:SetScript("OnMouseUp", OpenSettingsAndHideHelp)

    Companion.trackerFrame:SetScript("OnEnter", function(self)
        if (MinArch.db.profile.companion.showHelpTip) then
            HelpPlate_TooltipHide();
            if MINARCH_EXPANSION == 'Cata' then
                HelpPlateTooltip.ArrowUP:Show();
                HelpPlateTooltip.ArrowGlowUP:Show();
            else
                HelpPlateTooltip.ArrowUp:Show();
                HelpPlateTooltip.ArrowGlowUp:Show();
            end
            HelpPlateTooltip:SetPoint("BOTTOM", Companion.frame, "TOP", 0, 20);
            HelpPlateTooltip.Text:SetText(L["COMPANION_TUTORIAL_1"]);
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
    tex:SetAllPoints()
    tex:SetWidth(16)
    tex:SetHeight(16)
    tex:SetBlendMode("ADD")
    tex:SetTexCoord(0.5, 1, 0.5, 1)
    Companion.trackerFrame.indicator.texture = tex
    Companion:UpdateIndicatorFrameTexture()

    Companion.trackerFrame.indicator:Show()

    local fontString = Companion.trackerFrame.indicator:CreateFontString("$parentDistanceText", "OVERLAY")
    fontString:SetFontObject(GameFontWhiteSmall)
    fontString:SetText("")
    fontString:SetTextColor(0.0, 1.0, 0.0, 1.0)
    fontString:SetPoint("LEFT", Companion.trackerFrame.indicator, "LEFT", 19, 0)
    fontString:Show()

    Companion.frame:SetScript("OnEvent", Companion.EventHandler)

    Companion.trackerFrame.fontString = fontString;
end

function Companion:UpdateIndicatorFrameTexture()
    Companion.trackerFrame.indicator.texture:SetTexture(MinArchDistanceTrackerShapes[MinArch.db.profile.companion.features.distanceTracker.shape])
end

function Companion:SavePosition()
    local point, _, relativePoint, xOfs, yOfs = Companion.frame:GetPoint();
    MinArch.db.profile.companion.point = point;
    MinArch.db.profile.companion.relativePoint = relativePoint;
    MinArch.db.profile.companion.posX = xOfs;
    MinArch.db.profile.companion.posY = yOfs;
end

function Companion:ResetPosition()
    local point, relativeTo, relativePoint, xOfs, yOfs = Companion.frame:GetPoint();
    Companion.frame:ClearAllPoints();
    Companion.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
    if (MinArch.db.profile.companion.savePos) then
        Companion:SavePosition()
    end
end

function Companion:RegisterEvents()
    Companion.frame:RegisterEvent("PLAYER_STARTED_MOVING")
    Companion.frame:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST")
    Companion.frame:RegisterEvent("PLAYER_STOPPED_MOVING")
    Companion.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    Companion.frame:RegisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED")
    Companion.frame:RegisterEvent("SPELL_UPDATE_USABLE")
    Companion.frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    Companion.frame:RegisterEvent("BAG_UPDATE_COOLDOWN")
    Companion.frame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    Companion.frame:RegisterEvent("GLOBAL_MOUSE_DOWN")
end

function Companion:UnregisterEvents()
    Companion.frame:UnregisterEvent("PLAYER_STARTED_MOVING")
    Companion.frame:UnregisterEvent("ARCHAEOLOGY_SURVEY_CAST")
    Companion.frame:UnregisterEvent("PLAYER_STOPPED_MOVING")
    Companion.frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    Companion.frame:UnregisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED")
    Companion.frame:UnregisterEvent("SPELL_UPDATE_USABLE")
    Companion.frame:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
    Companion.frame:UnregisterEvent("BAG_UPDATE_COOLDOWN")
    Companion.frame:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    Companion.frame:UnregisterEvent("GLOBAL_MOUSE_DOWN")
end

function Companion:UpdateSurveyButton()
    if Companion.surveyButton:IsVisible() then
        local canCast = Common:CanCast()
        Companion.surveyButton:GetNormalTexture():SetDesaturated(not canCast)
        if canCast then
            Companion.surveyButton:SetAttribute("spell", SURVEY_SPELL_ID);
        else
            Companion.surveyButton:SetAttribute("spell", nil);
        end
    end
end

local function InitSurveyButton()
    -- Survey button
    local surveyButton = CreateFrame("Button", "$parentSurveyButton", Companion.frame, "InSecureActionButtonTemplate");
    surveyButton:RegisterForClicks("AnyUp", "AnyDown")
    surveyButton:SetAttribute("type", "spell")
    surveyButton:SetAttribute("spell", SURVEY_SPELL_ID)
    surveyButton:SetPoint("LEFT", 44, 0)
    surveyButton:SetWidth(28)
    surveyButton:SetHeight(28)

    local cd = CreateFrame("Cooldown", "$parentCooldown", surveyButton, "CooldownFrameTemplate")
    cd:SetAllPoints()
    cd:SetSwipeColor(1, 1, 1)
    surveyButton.cd = cd

    surveyButton:SetNormalTexture("Interface/Icons/inv_misc_shovel_01")
    surveyButton:SetHighlightTexture("Interface/Icons/inv_misc_shovel_01")
    surveyButton:SetPushedTexture("Interface/Icons/inv_misc_shovel_01")

    surveyButton:SetScript("OnEnter", function(self)
        Companion:UpdateSurveyButton()
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
        GameTooltip:SetSpellByID(SURVEY_SPELL_ID);

        if not Common:CanCast() then
            GameTooltip:AddLine(L["TOOLTIP_SURVEY_CANTCAST"])
        end

		GameTooltip:Show()
    end)

	surveyButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
    end)

    -- surveyButton:SetScript("OnClick", function ()
    --     Companion:UpdateSurveyButton()
    -- end)

    RegisterForDrag(surveyButton)

    Companion.surveyButton = surveyButton
end

local function InitProjectFrame()
    -- Project Solve button
    local solveButton = CreateFrame("Button", "$parentSolveButton", Companion.frame);
    solveButton:SetPoint("LEFT", 74, 2);
    solveButton:SetWidth(28);
    solveButton:SetHeight(28);

    RegisterForDrag(solveButton);

    local keystoneButton = CreateFrame("Button", "$parentKeystoneButton", solveButton, "MATKeystone");
    keystoneButton:SetPoint("BOTTOMRIGHT", 3, -3);
    keystoneButton:SetWidth(20);
    keystoneButton:SetHeight(20);
    keystoneButton:RegisterForClicks("LeftButtonUp","RightButtonUp");

    keystoneButton.text:SetFontObject(NumberFontNormal)

    keystoneButton:SetScript("OnLeave", function ()
        GameTooltip:Hide();
    end)

    solveButton.keystone = keystoneButton;
    Companion.solveButton = solveButton;
    Companion.solveButton.keystone:Hide();
end

local function InitCrateButton()
    -- Crate Button
    local crateButton = CreateFrame("Button", "$parentCrateButton", Companion.frame, "InsecureActionButtonTemplate");
    crateButton:RegisterForClicks("AnyUp", "AnyDown");
    crateButton:SetAttribute("type", "item");
    crateButton:SetPoint("LEFT", 108, 2);
    crateButton:SetWidth(28);
    crateButton:SetHeight(28);

    crateButton:SetNormalTexture("Interface/Icons/inv_crate_04")
    crateButton:SetHighlightTexture("Interface/Icons/inv_crate_04")
    crateButton:SetPushedTexture("Interface/Icons/inv_crate_04")

    Common:SetCrateButtonTooltip(crateButton);
    RegisterForDrag(crateButton);

    Companion.crateButton = crateButton;
end

local function InitRandomMountButton()
    -- Random mount Button
    local mountButton = CreateFrame("Button", "$parentMountButton", Companion.frame, "InsecureActionButtonTemplate");
    mountButton:RegisterForClicks("AnyUp", "AnyDown");
    mountButton:SetAttribute("type", "item");
    mountButton:SetPoint("LEFT", 142, 2);
    mountButton:SetWidth(28);
    mountButton:SetHeight(28);

    mountButton:SetNormalTexture("interface\\icons\\achievement_guildperk_mountup")
    mountButton:SetHighlightTexture("interface\\icons\\achievement_guildperk_mountup")
    mountButton:SetPushedTexture("interface\\icons\\achievement_guildperk_mountup")

    mountButton:SetScript("OnClick", function(self, button)
        if not InCombatLockdown() then
            C_MountJournal.SummonByID(0);
        end
    end);

    RegisterForDrag(mountButton);

    Companion.mountButton = mountButton;
end

local function InitSkillBar()
    local anchorPoint = "TOPLEFT"
    local posMod = 1
    local expandedHeight = 14;

    local skillBar = CreateFrame("Frame", "$parentSkillBar", Companion.frame)
    skillBar:SetPoint(anchorPoint, 0, 5 * posMod)
    skillBar:SetWidth(Companion.frame:GetWidth())
    skillBar:SetHeight(5)

    local tex = skillBar:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints()
    tex:SetColorTexture(MinArch.db.profile.companion.bg.r, MinArch.db.profile.companion.bg.g, MinArch.db.profile.companion.bg.b, MinArch.db.profile.companion.bg.a)
    skillBar.texture = tex

    local progressBar = CreateFrame("Frame", "$parentProgress", skillBar)
    progressBar:SetPoint("TOPLEFT", 0, 0)
    progressBar:SetHeight(5);
    skillBar.progressBar = progressBar

    local tex2 = progressBar:CreateTexture(nil, "BACKGROUND")
    tex2:SetAllPoints()
    tex2:SetColorTexture(0, 1, 0.5, 0.5)
    progressBar.texture = tex2

    local fontString = skillBar:CreateFontString("$parentProgressText", "OVERLAY")
    fontString:SetFontObject("GameFontWhiteSmall")
    fontString:SetText("")
    fontString:SetTextColor(1, 1, 1, 1.0)
    fontString:Hide()

    skillBar.fontString = fontString;

    RegisterForDrag(skillBar);

    skillBar:SetScript("OnEnter", function()
        skillBar:SetHeight(expandedHeight)
        progressBar:SetHeight(expandedHeight);
        skillBar:SetPoint(anchorPoint, 0, expandedHeight * posMod)
        fontString:SetPoint("CENTER", skillBar)
        fontString:Show()

        -- GameTooltip:SetOwner(skillBar, "ANCHOR_TOPRIGHT");
        -- GameTooltip:AddLine("Skill in Archaeology");
        -- GameTooltip:Show();
    end)

    skillBar:SetScript("OnLeave", function()
        skillBar:SetHeight(5)
        progressBar:SetHeight(5);
        skillBar:SetPoint(anchorPoint, 0, 5 * posMod)
        fontString:Hide()
        -- GameTooltip:Hide()
    end)

    skillBar:SetScript("OnMouseUp", OpenSettingsAndHideHelp)

    Companion.skillBar = skillBar
end

local function UpdateSolveButtonScripts(frame, artifact, raceID, solveOnClick, showTooltip)
    frame:SetScript("OnClick", function(self, button)
        if not solveOnClick then
            return
        end
        History:SolveArtifact(raceID)
    end);
    frame:SetScript("OnEnter", function(self)
        if showTooltip then
            History:ShowArtifactTooltip(self, raceID)
            GameTooltip:AddLine(" ");
            if (artifact.canSolve) then
                GameTooltip:AddLine(L["TOOLTIP_LEFTCLICK_SOLVE"]);
            else
                local progress = artifact.progress or 0;
                if (artifact.appliedKeystones > 0) then
                    progress = progress + (artifact.modifier)
                end
                GameTooltip:AddLine(L["TOOLTIP_PROGRESS"] .. ": " .. progress .. "/" .. artifact.total);
            end
            GameTooltip:Show();
        end

        if frame:GetName() == 'MinArchCompanionProgressBar' then
            frame:DefaultOnEnter()
        end
    end)
    frame:SetScript("OnLeave", function()
        if showTooltip then
            History:HideArtifactTooltip();
        end

        if frame:GetName() == 'MinArchCompanionProgressBar' then
            frame:DefaultOnLeave()
        end
    end)
end

local function UpdateProgressBar(raceID)
    if MinArch.db.profile.companion.enable then
        if MinArch.db.profile.companion.features.progressBar.enabled then
            local artifact = MinArch.artifacts[raceID]

            if (artifact and artifact.total) then
                local progress = artifact.progress or 0
                if (artifact.appliedKeystones > 0) then
                    progress = progress + (artifact.modifier)
                end
                local total = artifact.total;
                if (MinArch.db.profile.raceOptions.cap[raceID] == true) then
                    total = MinArchRaceConfig[raceID].fragmentCap
                end
                local pct = 0
                if total > 0 then
                    pct = progress / total
                end

                if pct >= 1 then
                    Companion.progressBar.progressBarFrame.texture:SetColorTexture(0, 1, 0.5, 0.5)
                    pct = 1
                else
                    Companion.progressBar.progressBarFrame.texture:SetColorTexture(0.7, 0.7, 0.7, 0.5)
                end

                local width = math.floor(Companion.frame:GetWidth() * pct)
                Companion.progressBar.progressBarFrame:SetWidth(width);
                Companion.progressBar.fontString:SetText(progress .. '/' .. total)
                Companion.progressBar:Show()

                UpdateSolveButtonScripts(Companion.progressBar, artifact, raceID, MinArch.db.profile.companion.features.progressBar.solveOnClick, MinArch.db.profile.companion.features.progressBar.showTooltip)
            end
        else
            Companion.progressBar:Hide()
        end
    end
end

local function InitProgressBar()
    local anchorPoint = "BOTTOMLEFT"
    local posMod = -1
    local expandedHeight = 14;

    local progressBar = CreateFrame("Button", "$parentProgressBar", Companion.frame)
    progressBar:SetPoint(anchorPoint, 0, 5 * posMod)
    progressBar:SetWidth(Companion.frame:GetWidth())
    progressBar:SetHeight(5)

    local tex = progressBar:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints()
    tex:SetColorTexture(MinArch.db.profile.companion.bg.r, MinArch.db.profile.companion.bg.g, MinArch.db.profile.companion.bg.b, MinArch.db.profile.companion.bg.a)
    progressBar.texture = tex

    local progressBarFrame = CreateFrame("Frame", "$parentProgress", progressBar)
    progressBarFrame:SetPoint("TOPLEFT", 0, 0)
    progressBarFrame:SetHeight(5);
    progressBar.progressBarFrame = progressBarFrame

    local tex2 = progressBarFrame:CreateTexture(nil, "BACKGROUND")
    tex2:SetAllPoints()
    tex2:SetColorTexture(0, 1, 0.5, 0.5)
    progressBarFrame.texture = tex2

    local fontString = progressBar:CreateFontString("$parentProgressText", "OVERLAY")
    fontString:SetFontObject("GameFontWhiteSmall")
    fontString:SetText("")
    fontString:SetTextColor(1, 1, 1, 1.0)
    fontString:Hide()

    progressBar.fontString = fontString;

    RegisterForDrag(progressBar);

    function progressBar:DefaultOnEnter ()
        progressBar:SetHeight(expandedHeight)
        progressBarFrame:SetHeight(expandedHeight);
        progressBar:SetPoint(anchorPoint, 0, expandedHeight * posMod)
        fontString:SetPoint("CENTER", progressBar)
        fontString:Show()
    end

    function progressBar:DefaultOnLeave ()
        progressBar:SetHeight(5)
        progressBarFrame:SetHeight(5);
        progressBar:SetPoint(anchorPoint, 0, 5 * posMod)
        fontString:Hide()
    end

    progressBar:SetScript("OnEnter", function ()
        progressBar:DefaultOnEnter()
    end)

    progressBar:SetScript("OnLeave", function ()
        progressBar:DefaultOnLeave()
    end)

    progressBar:SetScript("OnMouseUp", OpenSettingsAndHideHelp)

    Companion.progressBar = progressBar
end

function Companion:showCrateButton(itemID)
    if MinArch.db.profile.companion.enable and MinArch.db.profile.companion.features.crateButton.enabled and Companion.initialized then
        if itemID then
            Companion.crateButton:SetAttribute("item", "item:" .. itemID);
        end
        Companion.crateButton:Show();
        Companion:Resize()
    end
end

function Companion:hideCrateButton()
    if MinArch.db.profile.companion.enable and Companion.initialized then
        Companion.crateButton:Hide();
        Companion:Resize()
    end
end

function Companion.events:PLAYER_ENTERING_WORLD(...)
    if MinArch.db.profile.companion.savePos and MinArch.db.profile.companion.posX and MinArch.db.profile.companion.posY then
        Companion.frame:ClearAllPoints();
        Companion.frame:SetPoint(MinArch.db.profile.companion.point, UIParent, MinArch.db.profile.companion.relativePoint, MinArch.db.profile.companion.posX, MinArch.db.profile.companion.posY)
    end
    Companion:SetFrameScale(MinArch.db.profile.companion.frameScale);
end

function Companion.events:PLAYER_STARTED_MOVING(...)
    timer = MinArch:ScheduleRepeatingTimer(Companion.UpdateDistance, 0.1)
    Companion:Update()
end

function Companion.events:ARCHAEOLOGY_SURVEY_CAST(...)
    Companion.surveyButton.cd:SetCooldown(GetTime(), 3)
    cx, cy, _, cInstance = UnitPosition("player")
    Companion:UpdateDistance();

end

function Companion.events:PLAYER_STOPPED_MOVING(...)
    Companion:AutoToggle();
    MinArch:CancelTimer(timer)
    Companion:Update()
end

function Companion.events:RESEARCH_ARTIFACT_DIG_SITE_UPDATED(...)
    Companion:HideDistance()
end

function Companion.events:SPELL_UPDATE_COOLDOWN(...)
    Companion:Update()
end
function Companion.events:SPELL_UPDATE_USABLE(...)
    Companion:Update()
end
function Companion.events:BAG_UPDATE_COOLDOWN(...)
    Companion:UpdateSurveyButton()
end
function Companion.events:ACTIONBAR_UPDATE_COOLDOWN(...)
    Companion:UpdateSurveyButton()
end
function Companion.events:GLOBAL_MOUSE_DOWN(...)
    Companion:UpdateSurveyButton()
end

function Companion:UpdateDistance()
    local nx, ny, _, nInstance = UnitPosition("player")

    if (cx == nil or cInstance ~= nInstance) then
        Companion:HideDistance()
        return
    end

    local distance = CalculateDistance(cx, cy, nx, ny)
    Companion.trackerFrame.fontString:SetText(tostring(distance))

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
    Companion:Update();
end

function Companion:EventHandler(event, ...)
    Companion.events[event](self, ...)
end

function Companion:HideFrame()
    Companion.frame:Hide();
    if MinArch.db.profile.companion.enable then
        Companion.showInDigsite = true;
    end
end

function Companion:ShowFrame()
    if MinArch.db.profile.companion.enable then
        Companion.frame:Show();
        Companion.showInDigsite = false;

        Companion:Resize()
    end
end

function Companion:AutoToggle()
    if not Companion.initialized or not MinArch.db.profile.companion.enable then
        return;
    end

    if IsInInstance() or (MinArch.db.profile.companion.hideInCombat and UnitAffectingCombat("player")) then
        Companion:HideFrame();
        return;
    end

    if MinArch.db.profile.companion.alwaysShow or (Companion.showInDigsite == true and Digsites:IsPlayerNearDigSite()) then
        Companion:ShowFrame()
    end

    if not MinArch.db.profile.companion.alwaysShow and not Digsites:IsPlayerNearDigSite() then
        Companion:HideFrame()
        return
    end

    local digSite = Digsites:GetNearestDigsite();
    if not digSite and MinArch.db.profile.companion.hideWhenUnavailable then
        Companion:HideFrame()
        return
    end
end

function Companion:Enable()
    Companion:Init();
end

function Companion:Disable()
    Companion.frame:Hide();
    Companion:UnregisterEvents();
end

function Companion:Init()
    if not MinArch.db.profile.companion.enable then
        return
    end

    if not Companion.initialized then
        Common:DisplayStatusMessage("Initializing Companion", MINARCH_MSG_DEBUG)

        Companion.frame:SetFrameStrata("BACKGROUND")
        Companion.frame:SetWidth(142)
        Companion.frame:SetHeight(baseHeight + MinArch.db.profile.companion.padding * 2)

        local tex = Companion.frame:CreateTexture(nil, "BACKGROUND")
        tex:SetAllPoints()
        tex:SetColorTexture(MinArch.db.profile.companion.bg.r, MinArch.db.profile.companion.bg.g, MinArch.db.profile.companion.bg.b, MinArch.db.profile.companion.bg.a)
        Companion.texture = tex

        Companion.waypointButton = Common:CreateAutoWaypointButton(Companion.frame, 12, 0)
        Companion.waypointButton:ClearAllPoints();
        Companion.waypointButton:SetPoint("LEFT", 26, 0);
        Companion.waypointButton:SetFrameStrata("MEDIUM");
        RegisterForDrag(Companion.waypointButton);

        Companion.frame:SetMovable(true)
        Companion.frame:EnableMouse(true)
        RegisterForDrag(Companion.frame);
        Companion.frame:ClearAllPoints();

        if not MinArch.db.profile.companion.posX or not MinArch.db.profile.companion.posY then
            Companion.frame:SetPoint("CENTER", 0, 0)
        end

        Companion.frame:SetScript("OnShow", function ()
            if MinArch.db.profile.companion.posX and MinArch.db.profile.companion.posY then
                Companion.frame:SetPoint(MinArch.db.profile.companion.point, UIParent, MinArch.db.profile.companion.relativePoint, MinArch.db.profile.companion.posX, MinArch.db.profile.companion.posY)
            end
        end)

        Companion.frame:Show()

        InitDistanceTracker()
        InitSurveyButton()
        InitProjectFrame()
        InitCrateButton()
        InitRandomMountButton()
        InitSkillBar()
        InitProgressBar()

        Companion.initialized = true;
    end

    Companion:RegisterEvents();
    Companion:AutoToggle();
    Companion:Update();
end

function Companion:SetFrameScale(scale)
    local previousScale = Companion.frame:GetScale();
    local point, _, relativePoint, xOfs, yOfs = Companion.frame:GetPoint()

    scale = tonumber(scale)/100;
    Companion.frame:SetScale(scale);

    Companion.frame:ClearAllPoints()
    Companion.frame:SetPoint(point, UIParent, relativePoint, xOfs * (previousScale/scale), yOfs * (previousScale/scale));
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

    if MinArch.db.profile.companion.features.mountButton.enabled then
        Companion.mountButton:Show();
    else
        Companion.mountButton:Hide();
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
    buttons[MinArch.db.profile.companion.features.mountButton.order] = Companion.mountButton;

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

    Companion.frame:SetWidth(width + baseOffset);
    Companion.frame:SetHeight(baseHeight + MinArch.db.profile.companion.padding * 2)

    Companion.skillBar:SetWidth(width + baseOffset)
    Companion.progressBar:SetWidth(width + baseOffset)
    Main:UpdateArchaeologySkillBar()
end

local function shouldShowRace(raceID)
    -- Don't show hidden races
    if (MinArch.db.profile.raceOptions.hide[raceID]) then
        return false;
    end

    -- Don't show irrelevant races
    if (MinArch.db.profile.companion.relevantOnly and not Common:IsRaceRelevant(raceID)) then
        return false;
    end

    return true;
end

function Companion:ShowSolveButtonForRace(raceID, alwaysShow)
    local artifact = MinArch['artifacts'][raceID]

    if not artifact then
        Common:DisplayStatusMessage('Artifact not found for ' .. raceID, MINARCH_MSG_STATUS)
        return false;
    end

    if (artifact.canSolve or alwaysShow) then
        local icon = 'Interface/Icons/Inv_misc_questionmark';
        if (artifact.icon) then
            icon = artifact.icon
        end
        Companion.solveButton:SetNormalTexture(icon)
        Companion.solveButton:SetHighlightTexture(icon)
        Companion.solveButton:SetPushedTexture(icon)

        Companion.solveButton:GetNormalTexture():SetDesaturated(not artifact.canSolve)
        Companion.solveButton:GetHighlightTexture():SetDesaturated(not artifact.canSolve)
        Companion.solveButton:GetPushedTexture():SetDesaturated(not artifact.canSolve)

        UpdateSolveButtonScripts(Companion.solveButton, artifact, raceID, true, true)

        Companion.solveButton.keystone:SetScript("OnClick", function(self, button, down)
            Common:KeystoneClick(self, raceID, button, down);
        end)
        Companion.solveButton.keystone:SetScript("OnEnter", function(self)
            Common:KeystoneTooltip(self, raceID);
        end)

        if MinArch.db.profile.companion.features.solveButton.enabled then
            Companion.solveButton:Show();

            if not MinArch.db.profile.companion.features.solveButton.keystone then
                Companion.solveButton.keystone:Hide();
            else
                Common:UpdateKeystones(Companion.solveButton.keystone, raceID);
            end

        end
        Companion:Resize()

        return true;
    end

    return false;
end

function Companion:Update()
    if not MinArch.db.profile.companion.enable then
        return false;
    end

    if MinArch.db.profile.companion.features.skillBar.enabled then
        Companion.skillBar:Show()
    else
        Companion.skillBar:Hide()
    end

    Companion:UpdateSurveyButton()

    Companion.texture:SetColorTexture(MinArch.db.profile.companion.bg.r, MinArch.db.profile.companion.bg.g, MinArch.db.profile.companion.bg.b, MinArch.db.profile.companion.bg.a)
    Companion.skillBar.texture:SetColorTexture(MinArch.db.profile.companion.bg.r, MinArch.db.profile.companion.bg.g, MinArch.db.profile.companion.bg.b, MinArch.db.profile.companion.bg.a)
    Companion.progressBar.texture:SetColorTexture(MinArch.db.profile.companion.bg.r, MinArch.db.profile.companion.bg.g, MinArch.db.profile.companion.bg.b, MinArch.db.profile.companion.bg.a)
    Companion.solveButton:Hide();
    Companion:Resize();

    for i = 1, ARCHAEOLOGY_NUM_RACES do
        if shouldShowRace(i) then
            if (Companion:ShowSolveButtonForRace(i)) then
                UpdateProgressBar(i)
                if MinArch.db.profile.companion.features.solveButton.alwaysShowSolvable then
                    return;
                end
            end
        end
    end


    local digSite, distance, digSiteData = Digsites:GetNearestDigsite();
    for i = 1, ARCHAEOLOGY_NUM_RACES do

        if digSiteData then
            local text = digSiteData.race;

            local raceID = Common:GetRaceIdByName(digSiteData.race);
            if not MinArch.db.profile.raceOptions.hide[raceID] then
                if MinArch.db.profile.companion.features.solveButton.alwaysShowNearest then
                    Companion:ShowSolveButtonForRace(raceID, true)
                end
                UpdateProgressBar(raceID)
                return
            end
        end
    end
end

