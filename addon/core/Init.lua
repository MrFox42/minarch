local ADDON, MinArch = ...
local isClassic = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE

function MinArch:InitHelperFrame()
    MinArch.HelperFrame = CreateFrame("Frame", "MinArchHelper");

	MinArch.HelperFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
    MinArch.HelperFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
	MinArch.HelperFrame:RegisterEvent("GLOBAL_MOUSE_DOWN");

	MinArchMain.showAfterCombat = false;
	MinArchHist.showAfterCombat = false;
    MinArchDigsites.showAfterCombat = false;
    MinArch.Companion.showAfterCombat = false;

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

function MinArch.Ace:OnInitialize ()
	-- Initialize Settings Database
	MinArch:SetDynamicDefaults();
	MinArch:InitDatabase();
	MinArch:MainEventAddonLoaded();

	MinArch:InitHelperFrame();
	MinArch:InitMain(MinArchMain);
	MinArch:InitHist(MinArchHist);
	MinArch:InitDigsites(MinArchDigsites);

	MinArch.Companion:Init();

	MinArch:InitLDB();
	-- TODO Add to UISpecialFrames so windows close when the escape button is pressed
	--[[C_Timer.After(0.5, function()
		tinsert(UISpecialFrames, "MinArchMain");
		-- TODO: close one by one
		tinsert(UISpecialFrames, "MinArchHist");
		tinsert(UISpecialFrames, "MinArchDigsites");
	end)]]--

	MinArch:CommonFrameScale(MinArch.db.profile.frameScale);
    MinArch:ShowRaceIconsOnMap();
    -- MinArch:HookDoubleClick();
	MinArch.IsReady = true;
	MinArch:DisplayStatusMessage("Minimal Archaeology Loaded!");
end

function MinArch:SetDynamicDefaults ()
	for i=1, ARCHAEOLOGY_NUM_RACES do
		MinArch.defaults.profile.raceOptions.hide[i] = false;
		MinArch.defaults.profile.raceOptions.cap[i] = false;
		MinArch.defaults.profile.raceOptions.keystone[i] = false;
	end
end

function MinArch:RefreshConfig()
	MinArch:DisplayStatusMessage("RefreshConfig called", MINARCH_MSG_DEBUG);

	MinArch:RefreshMinimapButton();
	MinArch:ShowRaceIconsOnMap();
	MinArch:CommonFrameScale(MinArch.db.profile.frameScale);
	MinArch.ShowOnSurvey = true;
    MinArch.ShowInDigsite = true;
    MinArch.CompanionShowInDigsite = true;
	MinArch:UpdateMain();
end

function MinArch:Shutdown()
	MinArch:DisplayStatusMessage("ShutDown called", MINARCH_MSG_DEBUG);
end

function MinArch:InitDatabase()
	MinArch.db = LibStub("AceDB-3.0"):New("MinArchDB", MinArch.defaults, true);
	MinArch.db.RegisterCallback(MinArch, "OnProfileChanged", "RefreshConfig");
    MinArch.db.RegisterCallback(MinArch, "OnProfileCopied", "RefreshConfig");
    MinArch.db.RegisterCallback(MinArch, "OnProfileReset", "RefreshConfig");
	MinArch.db.RegisterCallback(MinArch, "OnDatabaseShutdown", "Shutdown");

	MinArch:UpgradeSettings()
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
end
