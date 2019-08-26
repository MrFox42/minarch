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

    Companion.trackerFrame.indicator.tex = Companion.trackerFrame.indicator:CreateTexture(nil, "BACKGROUND")
    Companion.trackerFrame.indicator.tex:SetAllPoints()
    Companion.trackerFrame.indicator.tex:SetColorTexture(0, 0, 0, 0.5)
    Companion.trackerFrame.indicator.texture = Companion.trackerFrame.indicator.tex

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
end

local function InitSurveyButton()

end

local function InitProjectFrame()

end

local function InitTutorial()

end

function Companion.events:PLAYER_ENTERING_WORLD(...)

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

function Companion:UpdateDistance()
    nx, ny, _, nInstance = UnitPosition("player")

    if (cx == nil or cInstance ~= nInstance) then return end

    local distance = MinArch:CalculateDistance(cx, cy, nx, ny)
    Companion.trackerFrame.fontString:SetText(distance)

    if (distance >= 0 and distance <= 40) then
        Companion.trackerFrame.indicator.tex:SetColorTexture(0, 1, 0, 1)
    elseif (distance > 40 and distance <= 80) then
        Companion.trackerFrame.indicator.tex:SetColorTexture(1, 0.65, 0, 1)
    elseif (distance >80 and distance < 300) then
        Companion.trackerFrame.indicator.tex:SetColorTexture(1, 0, 0, 1)
    else
        Companion.trackerFrame.indicator.tex:SetColorTexture(0, 0, 0, 0)
        Companion.trackerFrame.fontString:SetText("")
        MinArch:CancelTimer(timer)
    end

end

function Companion:EventHandler(event, ...)
    Companion.events[event](self, ...)
end

function Companion:Init()
    MinArch:DisplayStatusMessage("Initializing Companion", MINARCH_MSG_DEBUG)

    Companion:SetFrameStrata("BACKGROUND")
    Companion:SetWidth(108)
    Companion:SetHeight(24)

    local tex = Companion:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints()
    tex:SetColorTexture(0, 0, 0, 0.5)
    Companion.texture = tex

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
    InitTutorial()
end

function Companion:Resize()
    -- TODO: get visible child frames, resize accordingly
end

function Companion:Update()

end

