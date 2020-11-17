local ADDON, MinArch = ...

-- MinArch.db.profile.
MinArch.defaults = {
	char = {
		WindowStates = {
			main = false,
			history = false,
			digsites = false,
			companion = false
		},
		TomTom = {
            waypoints = {},
            uiMapPoint = false
		}
	},
	profile = {
		settingsVersion = 0,
		disableSound = false,
		startHidden = false,
		hideMain = false,
		frameScale = 100,
		showStatusMessages = false,
		showDebugMessages = false,
		showWorldMapOverlay = true,
		hideAfterDigsite = false,
		hideInCombat = false,
		waitForSolve = false,
		autoShowOnSurvey = false,
		autoShowOnSolve = false,
		autoShowInDigsites = false,
		autoShowOnCap = true,
        rememberState = true,
        showSolvePopup = true,
        surveyOnDoubleClick = true,
        dblClick = {
            disableMounted = false,
            disableInFlight = false,
        },
		relevancy = {
			relevantOnly = false,
			nearby = true,
			continentSpecific = false,
            solvable = true,
            hideCapped = false
		},
		minimap = {
			minimapPos = 45,
			hide = false
		},
		TomTom = {
            enable = true,
            enableTomTom = true,
            enableBlizzWaypoint = true,
            superTrack = true,
			arrow = true,
			persistent = false,
			autoWayOnMove = false,
            autoWayOnComplete = true,
            prioRace = -1,
		},

		-- dynamic options
		raceOptions = {
			hide = {},
			cap = {},
			keystone = {}
        },

        ProgressBar = {
            attachToCompanion = false
        },

        -- Companion (added in 9.0)
        companion = {
            showHelpTip = true,
            enable = true,
            alwaysShow = true,
            frameScale = 100,
            savePos = true,
            point = "CENTER",
            relativePoint = "CENTER",
            posX = 1,
            posY = 1,
            buttonSpacing = 2,
            padding = 3,
            lock = false,
            relevantOnly = true,
            bg = {
                r = 0,
                g = 0,
                b = 0,
                a = 0.5
            },
            features = {
                distanceTracker = {enabled = true, order = 1},
                waypointButton  = {enabled = true, order = 2},
                surveyButton    = {enabled = true, order = 3},
                solveButton     = {enabled = true, order = 4},
                crateButton     = {enabled = true, order = 5},
            }
        },

        history = {
            autoResize = true,
        },

		-- deprecated, left for compatibility
		hideMinimapButton = false, -- moved into minimap (databroker)
		minimapPos = 45,           -- not needed anymore (databroker)
	},
}
