local ADDON, _ = ...

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
        expansion = nil,
		settingsVersion = 0,
		disableSound = false,
		startHidden = false,
		hideMain = false,
		frameScale = 100,
        mapPinScale = 120,
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
            disableInFlight = true,
            button = 1,
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
            prioRace = true, -- Removed in 10.2.12
            ignoreHidden = false,
            optimizePath = false,
            optimizationModifier = 2,
            taxi = {
                enabled = true,
                archMode = false,
                autoEnableArchMode = false,
                autoDisableArchMode = false,
                distance = 4000,
                alpha = 50,
                zoneCheck = false
            }
		},

		-- dynamic options
		raceOptions = {
			hide = {},
			cap = {},
			keystone = {},
            priority = {}
        },

        ProgressBar = {
            attachToCompanion = false
        },

        -- Companion (added in 9.0)
        companion = {
            showHelpTip = true,
            enable = true,
            alwaysShow = true,
            hideInCombat = true,
            hideWhenUnavailable = false,
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
                distanceTracker = {enabled = true,  order = 1, shape = 2}, -- 1: circle, 2: square, 3: triangle
                waypointButton  = {enabled = true,  order = 2},
                surveyButton    = {enabled = true,  order = 3},
                solveButton     = {enabled = true,  order = 4, keystone = true, alwaysShowSolvable = true, alwaysShowNearest = true},
                crateButton     = {enabled = true,  order = 5},
                mountButton     = {enabled = false, order = 6},
                skillBar        = {enabled = true},
                progressBar     = {enabled = true, showTooltip = true, solveOnClick = true}
            },
        },

        history = {
            autoResize = true,
            showStats = true,
            groupByProgress = true,
        },

		-- deprecated, left for compatibility
		hideMinimapButton = false, -- moved into minimap (databroker)
		minimapPos = 45,           -- not needed anymore (databroker)
	},
}
