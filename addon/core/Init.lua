local ADDON, _ = ...
local isClassic = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE

---@type MinArchOptions
local Options = MinArch:LoadModule("MinArchOptions")
---@type MinArchMain
local Main = MinArch:LoadModule("MinArchMain")
---@type MinArchCompanion
local Companion = MinArch:LoadModule("MinArchCompanion")
---@type MinArchDigsites
local Digsites = MinArch:LoadModule("MinArchDigsites")
---@type MinArchHistory
local History = MinArch:LoadModule("MinArchHistory")
---@type MinArchCommon
local Common = MinArch:LoadModule("MinArchCommon")
---@type MinArchLDB
local MinArchLDB = MinArch:LoadModule("MinArchLDB")

local function InitHelperFrame()
    MinArch.HelperFrame = CreateFrame("Frame", "MinArchHelper");

	MinArch.HelperFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
    MinArch.HelperFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
	MinArch.HelperFrame:RegisterEvent("GLOBAL_MOUSE_DOWN");

	Main.showAfterCombat = false;
	History.showAfterCombat = false;
    Digsites.showAfterCombat = false;
    Companion.showAfterCombat = false;

    MinArch.HelperFrame:Hide();

	MinArch.HelperFrame:SetScript("OnEvent", function(_, event, ...)
		MinArch:EventHelper(event, ...);
	end)

    local button = CreateFrame("Button", "MinArchHiddenSurveyButton", nil, "SecureActionButtonTemplate");
    button:RegisterForClicks("AnyDown", "AnyUp");
    button:SetAttribute("type", "spell");
    button:SetAttribute("spell", SURVEY_SPELL_ID);
    -- button:Hide();

	button:SetScript("PostClick", function(self, button, down)
		MouselookStart()
		if down then return end
		MouselookStop()
    end)
	SecureHandlerWrapScript(button, "PostClick", button, string.format([[
      local isClassic = %s
      if isClassic == true then
        self:ClearBindings()
      else
        if not down then
          self:ClearBindings()
        end
      end
    ]], tostring(isClassic)))

	MinArch.hiddenButton = button
end

local function SetDynamicDefaults ()
	for i=1, ARCHAEOLOGY_NUM_RACES do
		MinArch.defaults.profile.raceOptions.hide[i] = false;
		MinArch.defaults.profile.raceOptions.cap[i] = false;
		MinArch.defaults.profile.raceOptions.keystone[i] = false;
	end
end

local function InitDatabase()
	MinArch.db = LibStub("AceDB-3.0"):New("MinArchDB", MinArch.defaults, true);
	MinArch.db.RegisterCallback(MinArch, "OnProfileChanged", "RefreshConfig");
    MinArch.db.RegisterCallback(MinArch, "OnProfileCopied", "RefreshConfig");
    MinArch.db.RegisterCallback(MinArch, "OnProfileReset", "RefreshConfig");
	MinArch.db.RegisterCallback(MinArch, "OnDatabaseShutdown", "Shutdown");

	MinArch:UpgradeSettings()
end

function MinArch:OnInitialize ()
	-- Initialize Settings Database
	SetDynamicDefaults();
	InitDatabase();
	MinArch:MainEventAddonLoaded();

	InitHelperFrame();
	Main:Init();
	History:Init();
	Digsites:Init()

	Companion:Init();

	MinArchLDB:Init();
	-- TODO Add to UISpecialFrames so windows close when the escape button is pressed
	--[[C_Timer.After(0.5, function()
		tinsert(UISpecialFrames, "MinArchMain");
		-- TODO: close one by one
		tinsert(UISpecialFrames, "MinArchHist");
		tinsert(UISpecialFrames, "MinArchDigsites");
	end)]]--

	Common:FrameScale(MinArch.db.profile.frameScale);
    Digsites:ShowRaceIconsOnMap();
    -- MinArch:HookDoubleClick();
	Options:OnInitialize()

	MinArch.IsReady = true;
	Common:DisplayStatusMessage("Minimal Archaeology Loaded!");
end


function MinArch:RefreshConfig()
	Common:DisplayStatusMessage("RefreshConfig called", MINARCH_MSG_DEBUG);

	MinArchLDB:RefreshMinimapButton();
	Digsites:ShowRaceIconsOnMap();
	Common:FrameScale(MinArch.db.profile.frameScale);
	MinArch.ShowOnSurvey = true;
    MinArch.ShowInDigsite = true;
    Companion.showInDigsite = true;
	Main:Update();
end

function MinArch:Shutdown()
	Common:DisplayStatusMessage("ShutDown called", MINARCH_MSG_DEBUG);
end

function MinArch:UpgradeSettings()
	if (MinArch.db.profile.settingsVersion == 0) then
		for i=1, ARCHAEOLOGY_NUM_RACES do
			if (MinArchOptions['ABOptions'][i] ~= nil) then
				if (MinArchOptions['ABOptions'][i]['Cap'] ~= nil) then
					MinArch.db.profile.raceOptions.cap[i] = MinArchOptions['ABOptions'][i]['Cap'];
				end

				if (MinArchOptions['ABOptions'][i]['Hide'] ~= nil) then
					MinArch.db.profile.raceOptions.hide[i] = MinArchOptions['ABOptions'][i]['Hide'];
				end

				if (MinArchOptions['ABOptions'][i]['AlwaysUseKeystone'] ~= nil) then
					MinArch.db.profile.raceOptions.keystone[i] = MinArchOptions['ABOptions'][i]['AlwaysUseKeystone'];
				end
			end
		end

		if (MinArchOptions['HideMinimap'] ~= nil) then
			MinArch.db.profile.hideMinimapButton = MinArchOptions['HideMinimap'];
		end

		if (MinArchOptions['DisableSound'] ~= nil) then
			MinArch.db.profile.disableSound = MinArchOptions['DisableSound'];
		end

		if (MinArchOptions['StartHidden'] ~= nil) then
			MinArch.db.profile.startHidden = MinArchOptions['StartHidden'];
		end

		if (MinArchOptions['FrameScale'] ~= nil) then
			MinArch.db.profile.frameScale = MinArchOptions['FrameScale'];
		end

		if (MinArchOptions['ShowStatusMessages'] ~= nil) then
			MinArch.db.profile.showStatusMessages = MinArchOptions['ShowStatusMessages'];
		end

		if (MinArchOptions['ShowWorldMapOverlay'] ~= nil) then
			MinArch.db.profile.showWorldMapOverlay = MinArchOptions['ShowWorldMapOverlay'];
		end

		if (MinArchOptions['HideAfterDigsite'] ~= nil) then
			MinArch.db.profile.hideAfterDigsite = MinArchOptions['HideAfterDigsite'];
		end

		if (MinArchOptions['WaitForSolve'] ~= nil) then
			MinArch.db.profile.waitForSolve = MinArchOptions['WaitForSolve'];
		end

		if (MinArchOptions['MinimapPos'] ~= nil) then
			MinArch.db.profile.minimapPos = MinArchOptions['MinimapPos'];
		end

		MinArch.db.profile.settingsVersion = 1;
	end

	if (MinArch.db.profile.settingsVersion == 1) then
		MinArch.db.profile.minimap.hide = MinArch.db.profile.hideMinimapButton;

		MinArch.db.profile.settingsVersion = 2;
	end

	if (MinArch.db.profile.settingsVersion == 2) then
		if (MinArch.db.profile.startHidden == true) then
			MinArch.db.profile.rememberState = false;
		end

		MinArch.db.profile.settingsVersion = 3;
    end

    if (MinArch.db.profile.settingsVersion == 3) then
        MinArch.db.profile.TomTom.enableTomTom = MinArch.db.profile.TomTom.enable;

        MinArch.db.profile.settingsVersion = 4;
    end

	-- Convert priority to the new multi-prio system
	if (MinArch.db.profile.settingsVersion == 4) then
		local raceID = MinArch.db.profile.TomTom.prioRace
		if raceID then
			MinArch.db.profile.raceOptions.priority[raceID] = 1
		end
		MinArch.db.profile.TomTom.prioRace = nil

        MinArch.db.profile.settingsVersion = 5;
    end

	-- Cata -> MoP
	if MinArch.db.profile.expansion == 3 and LE_EXPANSION_LEVEL_CURRENT == 4 then
		local keyStonesTmp = {}
		local priorityTmp = {}
		local capTmp = {}
		local hideTmp = {}

		for i=4, ARCHAEOLOGY_NUM_RACES do
			capTmp[i] = MinArch.db.profile.raceOptions.cap[i - 3] or false
			hideTmp[i] = MinArch.db.profile.raceOptions.hide[i - 3] or false
			priorityTmp[i] = MinArch.db.profile.raceOptions.priority[i - 3] or false
			keyStonesTmp[i] = MinArch.db.profile.raceOptions.keystone[i - 3] or false
		end

		for i=1, ARCHAEOLOGY_NUM_RACES do
			MinArch.db.profile.raceOptions.cap[i] = capTmp[i] or false
			MinArch.db.profile.raceOptions.hide[i] = hideTmp[i] or false
			MinArch.db.profile.raceOptions.priority[i] = priorityTmp[i] or false
			MinArch.db.profile.raceOptions.keystone[i] = keyStonesTmp[i] or false
		end

		MinArch.db.profile.expansion = LE_EXPANSION_LEVEL_CURRENT
	end

	if MinArch.db.profile.expansion == nil then
		MinArch.db.profile.expansion = LE_EXPANSION_LEVEL_CURRENT
	end

end
