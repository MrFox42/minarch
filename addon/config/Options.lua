local ADDON, MinArch = ...

MinArch.Options = MinArch.Ace:NewModule("Options");

local Options = MinArch.Options;
local parent = MinArch;

local ArchRaceGroupText = {
	"Kul Tiras, Zuldazar",
	"Broken Isles",
	"Draenor",
	"Pandaria",
	"Northrend",
	"Outland",
	"Eastern Kingdoms, Kalimdor"
};

local ArchRaceGroups = {
	{ARCHAEOLOGY_RACE_DRUSTVARI, ARCHAEOLOGY_RACE_ZANDALARI},
	{ARCHAEOLOGY_RACE_DEMONIC, ARCHAEOLOGY_RACE_HIGHMOUNTAIN_TAUREN, ARCHAEOLOGY_RACE_HIGHBORNE},
	{ARCHAEOLOGY_RACE_OGRE, ARCHAEOLOGY_RACE_DRAENOR, ARCHAEOLOGY_RACE_ARAKKOA},
	{ARCHAEOLOGY_RACE_MOGU, ARCHAEOLOGY_RACE_PANDAREN, ARCHAEOLOGY_RACE_MANTID},
	{ARCHAEOLOGY_RACE_VRYKUL, ARCHAEOLOGY_RACE_NERUBIAN},
	{ARCHAEOLOGY_RACE_ORC, ARCHAEOLOGY_RACE_DRAENEI},
	{ARCHAEOLOGY_RACE_TOLVIR, ARCHAEOLOGY_RACE_TROLL, ARCHAEOLOGY_RACE_NIGHTELF, ARCHAEOLOGY_RACE_FOSSIL, ARCHAEOLOGY_RACE_DWARF, ARCHAEOLOGY_RACE_NERUBIAN}
};

local function updateOrdering(frame, newValue)
    local oldValue = MinArch.db.profile.companion.features[frame].order;

    for feature, options in pairs(MinArch.db.profile.companion.features) do
        if options.order == newValue then
            MinArch.db.profile.companion.features[feature].order = oldValue;
        end
    end

    MinArch.db.profile.companion.features[frame].order = newValue;
    MinArch.Companion:Update();
end


local function updatePrioOrdering(group, currentRace, newValue, ignoreCrossCheck)
	local oldValue = MinArch.db.profile.raceOptions.priority[currentRace]

	if not oldValue or oldValue > newValue then
		for _, race in pairs(ArchRaceGroups[group]) do
			local currentVal = MinArch.db.profile.raceOptions.priority[race]
			if race ~= currentRace and currentVal and currentVal >= newValue then
				MinArch.db.profile.raceOptions.priority[race] = currentVal + 1
			end
		end
	elseif oldValue and oldValue < newValue then
		for _, race in pairs(ArchRaceGroups[group]) do
			local currentVal = MinArch.db.profile.raceOptions.priority[race]
			if currentVal == newValue then
				MinArch.db.profile.raceOptions.priority[race] = oldValue
			end
		end
	end

	MinArch.db.profile.raceOptions.priority[currentRace] = newValue

	-- fix duplicates / non-numerical order
	local tmp = {}
	for idx, race in pairs(ArchRaceGroups[group]) do
		tmp[idx] = {
			order = MinArch.db.profile.raceOptions.priority[race] or 0,
			race = race
		}
	end
	table.sort(tmp, function(a, b)
		return (tonumber(a.order) or 0) < (tonumber(b.order) or 0)
	end)

	local i = 1
	for _, val in pairs(tmp) do
		if val.order > 0 then
			if group ~= 5 or val.race ~= ARCHAEOLOGY_RACE_NERUBIAN or MinArch.db.profile.raceOptions.priority[ARCHAEOLOGY_RACE_NERUBIAN] <= 2 then
				MinArch.db.profile.raceOptions.priority[val.race] = i
			end
			i = i + 1
		end
	end

	if not ignoreCrossCheck and (group == 5 or group == 7) and MinArch.db.profile.raceOptions.priority[ARCHAEOLOGY_RACE_NERUBIAN] then
		if group == 5 then
			updatePrioOrdering(7, ARCHAEOLOGY_RACE_NERUBIAN, MinArch.db.profile.raceOptions.priority[ARCHAEOLOGY_RACE_NERUBIAN], true)
		else
			updatePrioOrdering(5, ARCHAEOLOGY_RACE_NERUBIAN, MinArch.db.profile.raceOptions.priority[ARCHAEOLOGY_RACE_NERUBIAN], true)
		end
	end
end

local home = {
	name = "Minimal Archaeology v" .. C_AddOns.GetAddOnMetadata("MinimalArchaeology", "Version"),
	handler = MinArch,
	type = "group",
	args = {
        message = {
            type = "description",
            name = "Thanks for using Minimal Archaeology",
            fontSize = "small",
            width = "full",
            order = 1,
        },
		info = {
            type = "description",
            name = "For configration options, please expand the Minimal Archaeology section on the left. Here's an overview for the addon and the settings:",
            fontSize = "small",
            width = "full",
            order = 2,
        },
		general = {
			type = "group",
            name = "General Settings - Main windows",
            inline = true,
            order = 3,
			args = {
				message = {
					type = "description",
					name = "Open this section to configure |cFFF96854double right click surveying|r, and the |cFFF96854Main|r, |cFFF96854History|r and |cFFF96854Digsites|r windows. If you're unfamiliar with MinArch, click the buttons below to toggle each specific window.",
					fontSize = "small",
					width = "full",
					order = 1,
				},
				main = {
					type = "execute",
					name = "Toggle Main",
					order = 2,
					func = function ()
						MinArchMain:Toggle()
					end,
                },
                digsites = {
					type = "execute",
					name = "Toggle History",
					order = 3,
					func = function ()
						MinArchHist:Toggle()
					end,
				},
				history = {
					type = "execute",
					name = "Toggle Digsites",
					order = 4,
					func = function ()
						MinArchDigsites:Toggle()
					end,
				},
			}
		},
		companion = {
			type = "group",
            name = "Companion Settings",
            inline = true,
            order = 4,
			args = {
				message = {
					type = "description",
					name = "The |cFFF96854Companion|r is a tiny floating window that features a skill bar, distance tracker, and buttons for waypoints, solves, crates and a button for summoning a random mount. Each button can be disabled and you can also customize their order. The Companion has separate scaling and auto-show/auto-hide functionality from the rest of the windows.",
					fontSize = "small",
					width = "full",
					order = 1,
				},
			}
		},
		race = {
			type = "group",
            name = "Race Settings",
            inline = true,
            order = 5,
			args = {
				message = {
					type = "description",
					name = "Race related options: |cFFF96854hide|r or |cFFF96854prioritizy|r races, set |cFFF96854farming mode|r or enable |cFFF96854automatic keystone|r application.",
					fontSize = "small",
					width = "full",
					order = 1,
				},
			}
		},

		navigation = {
			type = "group",
            name = "Navigation Settings",
            inline = true,
            order = 6,
			args = {
				message = {
					type = "description",
					name = "Options for |cFFF96854TomTom|r integration and Blizzard |cFFF96854Waypoint|r system support (if available).",
					fontSize = "small",
					width = "full",
					order = 1,
				},
			}
		}
	}
}

local general = {
	name = "General Settings",
	handler = MinArch,
	type = "group",
	args = {
        surveying = {
            type = "group",
            name = "Surveying",
            inline = true,
            order = 3,
            args = {
                dblClick = {
					type = "toggle",
					name = "Survey on Double Right Click",
					desc = "Enable to cast survey when you double-click with your right mouse button.",
					get = function () return MinArch.db.profile.surveyOnDoubleClick end,
					set = function (_, newValue)
						MinArch.db.profile.surveyOnDoubleClick = newValue;
                    end,
                    width = "full",
					order = 1,
                },
                disableMounted = {
                    type = "toggle",
					name = "Don't cast while mounted",
					desc = "Check this option to prevent casting survey while you're mounted.",
					get = function () return MinArch.db.profile.dblClick.disableMounted end,
					set = function (_, newValue)
						MinArch.db.profile.dblClick.disableMounted = newValue;
                    end,
                    width = 1.5,
					order = 2,
                },
                disableInFlight = {
                    type = "toggle",
					name = "Don't cast while flying",
					desc = "Check this option to prevent casting survey while you're flying.",
					get = function () return MinArch.db.profile.dblClick.disableInFlight end,
					set = function (_, newValue)
						MinArch.db.profile.dblClick.disableInFlight = newValue;
                    end,
                    width = 1.5,
					order = 3,
                },
				doubleClickButton = {
					name = 'Double click button',
					desc = "Button for double click surveying.",
					type = "select",
					values = {[1] = 'Right Mouse Button', [2] = 'Left Mouse Button'},
					get = function () return MinArch.db.profile.dblClick.button end,
					set = function (_, newValue)
						MinArch.db.profile.dblClick.button = newValue;
					end,
					width = 1.5,
					order = 4,
				}
            }
        },
		misc = {
			type = 'group',
			name = 'Miscellaneous options',
			inline = true,
			order = 4,
			args = {
				scale = {
					type = "range",
					name = "Window Scale",
					desc = "Scale for the Main, History and Digsites windows. The Companion is scaled using a separate slider in the Companion section.",
					min = 30,
					max = 200,
					step = 5,
					get = function () return MinArch.db.profile.frameScale end,
					set = function (_, newValue)
						MinArch.db.profile.frameScale = newValue;
						MinArch:CommonFrameScale(newValue);
					end,
					order = 1,
				},
				spacer = {
					name = "",
					fontSize = "normal",
					type = "description",
					desc = "",
					width = "full",
					order = 2,
				},
				hideMinimapButton = {
					type = "toggle",
					name = "Hide Minimap Button",
					desc = "Hide the minimap button",
					get = function () return MinArch.db.profile.minimap.hide end,
					set = function (_, newValue)
						MinArch.db.profile.minimap.hide = newValue;

						MinArch:RefreshMinimapButton();
					end,
					order = 3,
				},
				disableSound = {
					type = "toggle",
					name = "Disable Sound",
					desc = "Disable the sound that is played when an artifact can be solved.",
					get = function () return MinArch.db.profile.disableSound end,
					set = function (_, newValue)
						MinArch.db.profile.disableSound = newValue;
					end,
					order = 4,
				},
				showWorldMapOverlay = {
					type = "toggle",
					name = "Show world map overlay icons",
					desc = "Show race icons next to digsites on the world map.",
					get = function () return MinArch.db.profile.showWorldMapOverlay end,
					set = function (_, newValue)
						MinArch.db.profile.showWorldMapOverlay = newValue;
						MinArch:ShowRaceIconsOnMap();
					end,

					width = "double",
					order = 5,
				},
				pinScale = {
					type = "range",
					name = "Map Pin Scale",
					desc = "Scale for the digsite icons on the world map. Reopen your map after changing.",
					min = 50,
					max = 500,
					step = 5,
					get = function () return MinArch.db.profile.mapPinScale end,
					set = function (_, newValue)
						MinArch.db.profile.mapPinScale = newValue;
					end,
					disabled = function () return not MinArch.db.profile.showWorldMapOverlay end,
					order = 6,
				},

			}
        },
        startup = {
            type = "group",
            name = "Startup settings",
            inline = true,
            order = 5,
            args = {
				note = {
                    type = "description",
                    name = "Note: these settings do not affect the Companion frame.",
                    -- fontSize = "small",
                    width = "full",
                    order = 1,
			    },
                startHidden = {
					type = "toggle",
					name = "Start Hidden",
					desc = "Always start Minimal Archaeology hidden.",
					get = function () return MinArch.db.profile.startHidden end,
					set = function (_, newValue)
						MinArch.db.profile.startHidden = newValue;
					end,
					order = 3,
				},
				rememberState = {
					type = "toggle",
					name = "Remember window states",
					desc = "Rembember which MinArch windows were open when logging out (or reloading UI).",
					get = function () return MinArch.db.profile.rememberState end,
					disabled = function () return MinArch.db.profile.startHidden end,
					set = function (_, newValue)
						MinArch.db.profile.rememberState = newValue;
                    end,
                    width = 1.5,
					order = 4,
				},
            }
		},
		autoHide = {
			type = "group",
			name = "Auto-hide main window",
			inline = true,
			order = 6,
			args = {
			    note = {
                    type = "description",
                    name = "Note: these settings do not affect the Companion frame.",
                    -- fontSize = "small",
                    width = "full",
                    order = 1,
			    },
				hideAfterDigsite = {
					type = "toggle",
					name = "Auto-hide after digsites",
					desc = "Hide Minimal Archaeology after completing a digsite.",
					get = function () return MinArch.db.profile.hideAfterDigsite end,
					set = function (_, newValue)
						MinArch.db.profile.hideAfterDigsite = newValue;
					end,
					order = 2,
				},
				waitForSolve = {
					type = "toggle",
					name = "Wait to solve artifacts",
					desc = "Wait until all artifacts are solved before auto-hiding.",
					get = function () return MinArch.db.profile.waitForSolve end,
					set = function (_, newValue)
						MinArch.db.profile.waitForSolve = newValue;
					end,
					disabled = function () return (MinArch.db.profile.hideAfterDigsite == false) end,
					order = 3
				},
				hideInCombat = {
					type = "toggle",
					name = "Auto-hide in combat",
					desc = "Hide Minimal Archaeology when combat starts, and re-open it after combat.",
					get = function () return MinArch.db.profile.hideInCombat end,
					set = function (_, newValue)
						MinArch.db.profile.hideInCombat = newValue;
					end,
					order = 4,
				},
			}
		},
		autoShow = {
			type = 'group',
			name = 'Auto-show main window',
			inline = true,
			order = 7,
			args = {
				autoShowInDigsites = {
					type = "toggle",
					name = "Show in digsites",
					desc = "Auto-show Minimal Archaeology when moving around in a digsite.",
					get = function () return MinArch.db.profile.autoShowInDigsites end,
					set = function (_, newValue)
						MinArch.db.profile.autoShowInDigsites = newValue;
						MinArch.ShowInDigsite = true;
					end,
					order = 1,
				},
				autoShowOnSurvey = {
					type = "toggle",
					name = "Show when surveying",
					desc = "Auto-show Minimal Archaeology when surveying in a digsite.",
					get = function () return MinArch.db.profile.autoShowOnSurvey end,
					set = function (_, newValue)
						MinArch.db.profile.autoShowOnSurvey = newValue;
						MinArch.ShowOnSurvey = true;
					end,
					order = 2,
				},
				autoShowOnSolve = {
					type = "toggle",
					name = "Show for solves",
					desc = "Auto-show Minimal Archaeology when a solve becomes available.",
					get = function () return MinArch.db.profile.autoShowOnSolve end,
					set = function (_, newValue)
						MinArch.db.profile.autoShowOnSolve = newValue;
					end,
					order = 3,
				},
				autoShowOnCap = {
					type = "toggle",
					name = "Show on cap",
					desc = "Auto-show Minimal Archaeology when the fragment cap is reached with a race.",
					get = function () return MinArch.db.profile.autoShowOnCap end,
					set = function (_, newValue)
						MinArch.db.profile.autoShowOnCap = newValue;
					end,
					order = 3,
				},
			}
        },
        history = {
			type = 'group',
			name = 'History Window settings',
			inline = true,
			order = 8,
			args = {
                autoResize = {
					type = "toggle",
					name = "Auto-resize",
					desc = "Enable to automatically resize the history window to fit all items",
					get = function () return MinArch.db.profile.history.autoResize end,
					set = function (_, newValue)
                        MinArch.db.profile.history.autoResize = newValue;
                        MinArch:CreateHistoryList(MinArchOptions['CurrentHistPage'], "Options");
					end,
					order = 1,
				},
				showStats = {
					type = "toggle",
					name = "Show statistics",
					desc = "Show progress and number of total solves for each race.",
					get = function () return MinArch.db.profile.history.showStats end,
					set = function (_, newValue)
                        MinArch.db.profile.history.showStats = newValue;
						if newValue then
							MinArchHist.statsFrame:Show()
						else
							MinArchHist.statsFrame:Hide()
						end
					end,
					order = 2,
				},
				groupByProgress = {
					type = "toggle",
					name = "Group by progress",
					desc = "If enabled, artifacts will be grouped by progress: current > incomplete > completed.",
					get = function () return MinArch.db.profile.history.groupByProgress end,
					set = function (_, newValue)
                        MinArch.db.profile.history.groupByProgress = newValue;
                        MinArch:CreateHistoryList(MinArchOptions['CurrentHistPage'], "Options");
					end,
					order = 3,
				},
            }
        },
	}
}

local raceSettings = {
	name = "Race Settings",
	handler = MinArch,
	type = "group",
	childGroups = "tab",
	args = {
		relevancy = {
			type = 'group',
			name = 'Relevancy',
			inline = false,
			order = 1,
			args = {
				message = {
					type = "description",
					name = "Customize which races you would like to be displayed in the Main window when the relevant races switch is toggled.\n",
					fontSize = "medium",
					width = "full",
					order = 1,
				},
				relevancySub = {
					type = 'group',
					name = 'Customize relevancy',
					order = 2,
					inline = true,
					args = {
						nearby = {
							type = "toggle",
							name = "Available nearby",
							desc = "Show races which have currently available digsites on your current continent.",
							get = function () return MinArch.db.profile.relevancy.nearby end,
							set = function (_, newValue)
								MinArch.db.profile.relevancy.nearby = newValue;
								MinArch:UpdateMain();
							end,
							order = 1,
						},
						continentSpecific = {
							type = "toggle",
							name = "Expansion-specific",
							desc = "Show races which could be available on your current continent (or expansion), even if they don't have an active digsite at the moment.",
							get = function () return MinArch.db.profile.relevancy.continentSpecific end,
							set = function (_, newValue)
								MinArch.db.profile.relevancy.continentSpecific = newValue;
								MinArch:UpdateMain();
							end,
							order = 2,
						},
						solvable = {
							type = "toggle",
							name = "Solvable",
							desc = "Show races which have a solve available, even if they're neither available nor related to your current continent.",
							get = function () return MinArch.db.profile.relevancy.solvable end,
							set = function (_, newValue)
								MinArch.db.profile.relevancy.solvable = newValue;
								MinArch:UpdateMain();
							end,
							order = 3,
                        },
                    },
                },
                relevancyOverrides = {
					type = 'group',
					name = 'Relevancy overrides',
					order = 2,
					inline = true,
					args = {
                        hideCapped = {
                            type = "toggle",
							name = "Hide irrelevant solves for races set to Farming mode (fragment-capped)",
							desc = "Enable to treat races with farming mode enabled (fragment-capped) as irrelevant when they have a solve available, but they would be irrelevant based on other relevancy settings.",
							get = function () return MinArch.db.profile.relevancy.hideCapped end,
							set = function (_, newValue)
								MinArch.db.profile.relevancy.hideCapped = newValue;
                                MinArch:UpdateMain();
                            end,
                            width = "full",
							order = 5,
                        },
                    },
                },
			}
		},
		hide = {
			type = "group",
			name = "Hide",
			order = 2,
			inline = false,
			args = {
				message = {
					type = "description",
					name = "Check races you would like to hide at all times. This overrides relevancy settings.\n\n Hidden races won't show up in the main window, and the Companion will not show solves for them.",
					fontSize = "medium",
					width = "full",
					order = 1,
				},
				wpIgnoreHidden = {
					type = "toggle",
					name = "Ignore hidden races when creating waypoints",
					desc = "Enable this to also ignore hidden races when creating waypoints.",
					get = function () return MinArch.db.profile.TomTom.ignoreHidden end,
                    set = function (_, newValue)
						MinArch.db.profile.TomTom.ignoreHidden = newValue;
					end,
                    disabled = function () return (MinArch:IsNavigationEnabled() == false) end,
					width = "full",
					order = 2,
                },
			}
		},
		cap = {
			type = "group",
			name = "Farming mode",
			order = 3,
			inline = false,
			args = {
				message = {
					type = "description",
					name = "If you enable farming mode for a race, the Main window will show the fragment cap for the race instead of the fragments required for the current solve. Useful for collecting fossil fragments for Darkmoon Faire.",
					fontSize = "medium",
					width = "full",
					order = 1,
				},
                solveConfirmation = {
                    width = "full",
					type = "toggle",
					name = "Show confirmation for fragment-capped solves",
					desc = "Show confirmation before solving artifacts for races with farming mode enabled",
					get = function () return MinArch.db.profile.showSolvePopup end,
					set = function (_, newValue)
						MinArch.db.profile.showSolvePopup = newValue;
					end,
					order = 1,
				},
			}
		},
		keystone = {
			type = "group",
			name = "Auto-keystone",
			order = 4,
			inline = false,
			args = {
				message = {
					type = "description",
					name = "Automatically applies keystones (uncommon fragments) for checked races.",
					fontSize = "medium",
					width = "full",
					order = 1,
				},
			}
		},
		priority = {
			type = "group",
			name = "Priority",
			order = 5,
			inline = false,
			args = {
				message = {
					type = "description",
					name = "Priority currently only applies to waypoint generation order. Automatic waypoints will point to the prioritized races before pointing to other (otherwise closer) digsites. Smaller number means higher priority.",
					fontSize = "medium",
					width = "full",
					order = 1,
				},
				reset = {
					type = "execute",
					name = "Reset All",
					order = 2,
					func = function ()
						for i=1, ARCHAEOLOGY_NUM_RACES do
							MinArch.db.profile.raceOptions.priority[i] = nil
						end
						MinArch:UpdateMain();
					end,
				}
			}
		},
	}
}

local companionSettings = {
    name = "Companion Settings",
	handler = MinArch,
	type = "group",
	args = {
        general = {
			type = "group",
			name = "General settings",
			order = 1,
			inline = true,
			args = {
                enable = {
					type = "toggle",
					name = "Enable the Companion frame",
                    desc = "Toggles the Companion frame plugin of MinArch. The companion is a tiny frame with a distance tracker and waypoint/survey/solve/crate buttons.",
                    width = 1.5,
					get = function () return MinArch.db.profile.companion.enable end,
					set = function (_, newValue)
						MinArch.db.profile.companion.enable = newValue;

						if (newValue) then
							MinArch.Companion:Enable();
						else
							MinArch.Companion:Disable();
						end
					end,
					order = 1,
				},
				alwaysShow = {
					type = "toggle",
					name = "Always show",
					desc = "Enable to always show the companion frame, even if you're not in a digsite (except in instances and if 'Hide in combat' is enabled).",
					get = function () return MinArch.db.profile.companion.alwaysShow end,
					set = function (_, newValue)
                        MinArch.db.profile.companion.alwaysShow = newValue;
                        MinArch.Companion:AutoToggle()
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
					order = 2,
                },
                hideInCombat = {
                    type = "toggle",
                    name = "Hide in combat",
                    desc = "Enable to hide in combat (even if alway show is enabled).",
                    get = function () return MinArch.db.profile.companion.hideInCombat end,
                    set = function (_, newValue)
                        MinArch.db.profile.companion.hideInCombat = newValue;
                        MinArch.Companion:AutoToggle()
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                    order = 3,
                },
				hideWhenUnavailable = {
                    type = "toggle",
                    name = "Hide when unavailable",
                    desc = "Enable to hide when there are no digsites available on the world map.",
                    get = function () return MinArch.db.profile.companion.hideWhenUnavailable end,
                    set = function (_, newValue)
                        MinArch.db.profile.companion.hideWhenUnavailable = newValue;
                        MinArch.Companion:AutoToggle()
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                    order = 3,
                },
                hrC = {
                    type = "description",
                    name = "|nColoring",
                    width = "full",
                    order = 4,
                },
                background = {
                    type = "color",
                    name = "Background color",
                    get = function () return MinArch.db.profile.companion.bg.r, MinArch.db.profile.companion.bg.g, MinArch.db.profile.companion.bg.b end,
                    set = function (_, r, g, b, a)
                        MinArch.db.profile.companion.bg.r = r;
                        MinArch.db.profile.companion.bg.g = g;
                        MinArch.db.profile.companion.bg.b = b;
                        MinArchCompanion:Update();
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                    order = 5,
                },
                bgOpacity = {
                    type = "range",
                    name = "Background opacity",
                    desc = "Set the size of the companion. Default: 50%.",
                    min = 0,
                    max = 100,
                    step = 1,
                    get = function () return MinArch.db.profile.companion.bg.a * 100 end,
                    set = function (_, newValue)
                        MinArch.db.profile.companion.bg.a = newValue / 100;
                        MinArch.Companion:Update();
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                    order = 6,
                },
                hr = {
                    type = "description",
                    name = "Sizing",
                    width = "full",
                    order = 97,
                },
                buttonSpacing = {
                    type = "range",
                    name = "Button spacing",
                    desc = "Set the size of the spacing between buttons. Default: 2.",
                    min = 0,
                    max = 20,
                    step = 1,
                    get = function () return MinArch.db.profile.companion.buttonSpacing end,
                    set = function (_, newValue)
                        MinArch.db.profile.companion.buttonSpacing = newValue;
                        MinArch.Companion:Update();
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                    order = 98,
                },
                padding = {
                    type = "range",
                    name = "Padding size",
                    desc = "Set the size of the padding of the Companion frame. Default: 3.",
                    min = 0,
                    max = 20,
                    step = 1,
                    get = function () return MinArch.db.profile.companion.padding end,
                    set = function (_, newValue)
                        MinArch.db.profile.companion.padding = newValue;
                        MinArch.Companion:Update();
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                    order = 98,
                },
                scale = {
                    type = "range",
                    name = "Companion scale",
                    desc = "Set the size of the companion. Default: 100.",
                    min = 30,
                    max = 300,
                    step = 5,
                    get = function () return MinArch.db.profile.companion.frameScale end,
                    set = function (_, newValue)
                        MinArch.db.profile.companion.frameScale = newValue;
                        MinArch.Companion:SetFrameScale(newValue);
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                    order = 99,
                },
            },
        },
        positioning = {
            type = "group",
            name = "Positioning",
            order = 2,
            inline = true,
            args = {
                lock = {
					type = "toggle",
					name = "Lock in place",
					desc = "Disables dragging on the companion frame, but you can still move it by modifying the offset manually on this options page.",
					get = function () return MinArch.db.profile.companion.lock end,
					set = function (_, newValue)
                        MinArch.db.profile.companion.lock = newValue;
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
					order = 1,
                },
                hr = {
                    type = "description",
                    name = "",
                    width = "full",
                    order = 2,
                },
                savePos = {
					type = "toggle",
					name = "Save position in profile",
					desc = "Enable to save position in settings profile so the companion will be in the same spot on all your characters using the same settings profile.",
					get = function () return MinArch.db.profile.companion.savePos end,
					set = function (_, newValue)
                        MinArch.db.profile.companion.savePos = newValue;
                        if newValue then
                            MinArch.Companion:SavePosition()
                        end
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
					order = 3,
                },
                x = {
					type = "input",
					name = "Horizontal offset",
					desc = "Horizontal position on the screen",
					get = function () return tostring(MinArch.db.profile.companion.posX) end,
                    set = function (_, newValue)
                        if (MinArch.db.profile.companion.enable and MinArch.db.profile.companion.savePos) then
                            MinArch.db.profile.companion.posX = tonumber(newValue);
                            local point, relativeTo, relativePoint, xOfs, yOfs = MinArchCompanion:GetPoint();
                            MinArch.Companion:ClearAllPoints();
                            MinArch.Companion:SetPoint(point, UIParent, relativePoint, tonumber(newValue), yOfs);
                            MinArch.Companion:SavePosition()
                        end
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false or MinArch.db.profile.companion.savePos == false) end,
					order = 4,
                },
                y = {
					type = "input",
					name = "Vertical offset",
					desc = "Vertical position on the screen",
					get = function () return tostring(MinArch.db.profile.companion.posY) end,
                    set = function (_, newValue)
                        if (MinArch.db.profile.companion.enable and MinArch.db.profile.companion.savePos) then
                            MinArch.db.profile.companion.posY = tonumber(newValue);
                            local point, relativeTo, relativePoint, xOfs, yOfs = MinArchCompanion:GetPoint();
                            MinArch.Companion:ClearAllPoints();
                            MinArch.Companion:SetPoint(point, UIParent, relativePoint, xOfs, tonumber(newValue));
                            MinArch.Companion:SavePosition();
                        end
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false or MinArch.db.profile.companion.savePos == false) end,
					order = 5,
				},
                resetButton = {
					type = "execute",
					name = "Reset position",
					order = 6,
					func = function ()
                        MinArch.Companion:ResetPosition();
					end,
                },
            }
        },
        featureOpts = {
            type = "group",
            name = "Customize Companion features",
            order = 3,
            inline = true,
            args = {
                distanceTracker = {
                    type = "group",
                    name = "Distance Tracker settings",
                    order = 1,
                    inline = true,
                    args = {
                        toggleDistanceTracker = {
                            type = "toggle",
                            name = "Show distance tracker",
                            desc = "Toggles the distance tracker on the companion frame",
                            get = function () return MinArch.db.profile.companion.features.distanceTracker.enabled end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.distanceTracker.enabled = newValue;
                                MinArch.Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 1,
                        },
                        distanceTrackerOrder = {
                            type = "select",
                            name = "Order",
                            values = {1, 2, 3, 4, 5, 6},
                            get = function () return MinArch.db.profile.companion.features.distanceTracker.order end,
                            set = function (info, newValue)
                                updateOrdering("distanceTracker", newValue)
                            end,
                            width = 0.5,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 2,
                        },
                        shape = {
                            type = "select",
                            name = "Shape",
                            values = {"Circle", "Square", "Triangle"},
                            get = function () return MinArch.db.profile.companion.features.distanceTracker.shape end,
                            set = function (info, newValue)
                                MinArch.db.profile.companion.features.distanceTracker.shape = newValue
                                MinArch.Companion:UpdateIndicatorFrameTexture()
                            end,
                        }
                    }
                },
                waypointButton = {
                    type = "group",
                    name = "Waypoint button settings",
                    order = 2,
                    inline = true,
                    args = {
                        toggleWaypointButton = {
                            type = "toggle",
                            name = "Show waypoint button",
                            desc = "Show the auto-waypoint button on the companion frame",
                            get = function () return MinArch.db.profile.companion.features.waypointButton.enabled end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.waypointButton.enabled = newValue;
                                MinArch.Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 6,
                        },
                        waypointButtonOrder = {
                            type = "select",
                            name = "Order",
                            values = {1, 2, 3, 4, 5, 6},
                            get = function () return MinArch.db.profile.companion.features.waypointButton.order end,
                            set = function (info, newValue)
                                updateOrdering("waypointButton", newValue)
                            end,
                            width = 0.5,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 7,
                        },
                    }
                },
                surveyButton = {
                    type = "group",
                    name = "Survey button settings",
                    order = 3,
                    inline = true,
                    args = {
                        toggleSurveyButton = {
                            type = "toggle",
                            name = "Show Survey button",
                            desc = "Show the survey button on the companion frame",
                            get = function () return MinArch.db.profile.companion.features.surveyButton.enabled end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.surveyButton.enabled = newValue;
                                MinArch.Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 3,
                        },
                        solveButtonOrder = {
                            type = "select",
                            name = "Order",
                            values = {1, 2, 3, 4, 5, 6},
                            get = function () return MinArch.db.profile.companion.features.surveyButton.order end,
                            set = function (info, newValue)
                                updateOrdering("surveyButton", newValue)
                            end,
                            width = 0.5,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 7,
                        },
                    }
                },
                solveButton = {
                    type = "group",
                    name = "Solve button settings",
                    order = 4,
                    inline = true,
                    args = {
                        toggleSolveButton = {
                            type = "toggle",
                            name = "Show Solve button",
                            desc = "Show the solve button on the companion frame",
                            get = function () return MinArch.db.profile.companion.features.solveButton.enabled end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.solveButton.enabled = newValue;
                                MinArch.Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 20,
                        },
                        solveButtonOrder = {
                            type = "select",
                            name = "Order",
                            values = {1, 2, 3, 4, 5, 6},
                            get = function () return MinArch.db.profile.companion.features.solveButton.order end,
                            set = function (info, newValue)
                                updateOrdering("solveButton", newValue)
                            end,
                            width = 0.5,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 52,
                        },
                        relevantOnly = {
                            type = "toggle",
                            name = "Only show relevant",
                            desc = "Enable to only show solves for relevant races (customized in the Races section)",
                            get = function () return MinArch.db.profile.companion.relevantOnly end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.relevantOnly = newValue;
                                MinArch.Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
							width = "full",
                            order = 53,
                        },
						alwaysShowNearest = {
                            type = "toggle",
                            name = "Show artifacts in progress",
                            desc = "Enable to displays the project related to the nearest digsite, even if you can't solve the project yet",
                            get = function () return MinArch.db.profile.companion.features.solveButton.alwaysShowNearest end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.solveButton.alwaysShowNearest = newValue;
                                MinArch.Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
							width = 1.5,
                            order = 54,
                        },
						alwaysShowSolvable = {
                            type = "toggle",
                            name = "Always show solvable artifacts",
                            desc = "Enable to override the previous setting by displaying projects that can be solved, even if it's not related to the nearest digsite",
                            get = function () return MinArch.db.profile.companion.features.solveButton.alwaysShowSolvable end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.solveButton.alwaysShowSolvable = newValue;
                                MinArch.Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
							width = 1.5,
                            order = 55,
                        },
						keystone = {
                            type = "toggle",
                            name = "Show keystones",
                            desc = "Enable to displays keystones on the solve button if available for the current solve. Also allows you to and apply/remove keystones (if auto-apply is not set)",
                            get = function () return MinArch.db.profile.companion.features.solveButton.keystone end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.solveButton.keystone = newValue;
                                MinArch.Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 57,
                        },
                    }
                },
                crateButton = {
                    type = "group",
                    name = "Crate button settings",
                    order = 5,
                    inline = true,
                    args = {
                        toggleCrateButton = {
                            type = "toggle",
                            name = "Show Crate button",
                            desc = "Show the crate button on the companion frame",
                            get = function () return MinArch.db.profile.companion.features.crateButton.enabled end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.crateButton.enabled = newValue;
                                MinArch.Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 51,
                        },
                        crateButtonOrder = {
                            type = "select",
                            name = "Order",
                            values = {1, 2, 3, 4, 5, 6},
                            get = function () return MinArch.db.profile.companion.features.crateButton.order end,
                            set = function (info, newValue)
                                updateOrdering("crateButton", newValue)
                            end,
                            width = 0.5,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 52,
                        },
                    }
                },
                mountButton = {
                    type = "group",
                    name = "Random mount button settings",
                    order = 6,
                    inline = true,
                    args = {
                        toggleMountButton = {
                            type = "toggle",
                            name = "Show random mount button",
                            desc = "Show the random mount button on the companion frame",
                            get = function () return MinArch.db.profile.companion.features.mountButton.enabled end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.mountButton.enabled = newValue;
                                MinArch.Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 6,
                        },
                        mountButtonOrder = {
                            type = "select",
                            name = "Order",
                            values = {1, 2, 3, 4, 5, 6},
                            get = function () return MinArch.db.profile.companion.features.mountButton.order end,
                            set = function (info, newValue)
                                updateOrdering("mountButton", newValue)
                            end,
                            width = 0.5,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 7,
                        },
                    }
                },
				skillBar = {
                    type = "group",
                    name = "Skill bar settings",
                    order = 6,
                    inline = true,
                    args = {
                        toggleMountButton = {
                            type = "toggle",
                            name = "Show skill bar",
                            desc = "Display the skill progress bar on the Companion frame",
                            get = function () return MinArch.db.profile.companion.features.skillBar.enabled end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.skillBar.enabled = newValue;
                                MinArch.Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 1,
                        },
                    }
                },
				progressBar = {
                    type = "group",
                    name = "Progress bar settings",
                    order = 8,
                    inline = true,
                    args = {
                        toggleMountButton = {
                            type = "toggle",
                            name = "Show progress bar",
                            desc = "Display the artifact progress progress bar on the Companion frame",
                            get = function () return MinArch.db.profile.companion.features.progressBar.enabled end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.progressBar.enabled = newValue;
                                MinArch.Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 1,
                        },
						showTooltip = {
                            type = "toggle",
                            name = "Show tooltip",
                            desc = "Display the artifact tooltip when hovering over the progress bar",
                            get = function () return MinArch.db.profile.companion.features.progressBar.showTooltip end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.progressBar.showTooltip = newValue;
                                MinArch.Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 1,
                        },
						solveOnClick = {
                            type = "toggle",
                            name = "Solve on click",
                            desc = "Solve the currently activate artifact when clicking the progress bar",
                            get = function () return MinArch.db.profile.companion.features.progressBar.solveOnClick end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.progressBar.solveOnClick = newValue;
                                MinArch.Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 1,
                        },
                    }
                },


            }
        }
    }
}

local devSettings = {
	name = "Tester/Developer Settings",
	handler = MinArch,
	type = "group",
	args = {
		dev = {
			type = 'group',
			name = 'Debug messages',
			inline = true,
			order = 1,
			args = {
				showStatusMessages = {
					type = "toggle",
					name = "Show status messages",
					desc = "Show Minimal Archaeology status messages in the chat.",
					get = function () return MinArch.db.profile.showStatusMessages end,
					set = function (_, newValue)
						MinArch.db.profile.showStatusMessages = newValue;
					end,
					order = 1,
				},
				showDebugMessages = {
					type = "toggle",
					name = "Show debug messages",
					desc = "Show debug messages in the chat. Debug messages show more detailed information about the addon than status messages.",
					get = function () return MinArch.db.profile.showDebugMessages end,
					set = function (_, newValue)
						MinArch.db.profile.showDebugMessages = newValue;
					end,
					order = 2,
				}
			}
		},
		message = {
            type = "description",
            name = "Experimental Features are placed here, because they're in a beta state, and might need additional work and feedback. Experimental features can be used without debug messages enabled, but I might ask for them in some cases if there are any issues.",
            fontSize = "normal",
            width = "full",
            order = 1,
        },
		experimental = {
			type = 'group',
			name = 'Experimental Features',
			inline = true,
			order = 2,
			args = {
				optimizePath = {
                    type = "toggle",
					name = "Optimize Path",
                    desc = "The waypoint will not always point to the nearest site, but tries to optimize travel times on the long run.",
                    get = function () return MinArch.db.profile.TomTom.optimizePath end,
                    set = function (_, newValue)
						MinArch.db.profile.TomTom.optimizePath = newValue;
					end,
                    order = 1,
                },
				optimizeModifier = {
					type = "range",
					name = "Optimization Modifier",
					desc = "Sets the optimization modifier to a custom value.",
					min = 1,
					max = 5,
					step = 0.05,
					get = function () return MinArch.db.profile.TomTom.optimizationModifier end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.optimizationModifier = newValue;
						MinArch:SetWayToNearestDigsite()
					end,
					order = 2,
				},
			}
		}
	}
}

local TomTomSettings = {
	name = "MinArch - TomTom",
	handler = MinArch,
	type = "group",
	args = {
        blizzway = {
			type = 'group',
			name = 'Blizzard Waypoints',
			inline = true,
			order = 1,
			args = {
                uiMapPoint = {
					type = "toggle",
					name = "Map pin",
					desc = "Enable to create a map pin over digsites (only available in Mainline).",
					get = function () return MinArch.db.profile.TomTom.enableBlizzWaypoint end,
					set = function (_, newValue)
                        MinArch.db.profile.TomTom.enableBlizzWaypoint = newValue;
                        if MinArch.db.char.TomTom.uiMapPoint and not newValue then
                            MinArch:ClearUiWaypoint()
                        end
					end,
					disabled = function () return (MINARCH_EXPANSION == 'Cata') end,
					order = 2,
                },
                superTrack = {
					type = "toggle",
					name = "Show floating pin",
					desc = "Enable to show the floating pin over the destination (only available in Mainline).",
					get = function () return MinArch.db.profile.TomTom.superTrack end,
					set = function (_, newValue)
                        MinArch.db.profile.TomTom.superTrack = newValue;
                        if MinArch.db.char.TomTom.uiMapPoint then
							if (MINARCH_EXPANSION == 'Mainline') then
                            	C_SuperTrack.SetSuperTrackedUserWaypoint(newValue);
							end
                        end
					end,
					disabled = function () return (MinArch.db.profile.TomTom.enableBlizzWaypoint == false or MINARCH_EXPANSION == 'Cata') end,
					order = 2,
				},
            }
        },
		tomtom = {
			type = 'group',
			name = 'TomTom Options',
			inline = true,
			order = 2,
			disabled = function () return (_G.TomTom == nil) end,
			args = {
				enable = {
					type = "toggle",
					name = "Enable TomTom integration in MinArch",
					desc = "Toggles TomTom integration in MinArch. Disabling TomTom integration will remove all waypoints created by MinArch",
					width = "full",
					get = function () return MinArch.db.profile.TomTom.enableTomTom end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.enableTomTom = newValue;

						if (newValue) then
							MinArchMainAutoWayButton:Show();
							MinArchDigsitesAutoWayButton:Show();
						else
							MinArch:ClearAllDigsiteWaypoints();
							MinArchMainAutoWayButton:Hide();
							MinArchDigsitesAutoWayButton:Hide();
						end
					end,
					order = 1,
				},
				arrow = {
					type = "toggle",
					name = "Show Arrow",
					desc = "Show arrow for waypoints created by MinArch. This won't change already existing waypoints.",
					get = function () return MinArch.db.profile.TomTom.arrow end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.arrow = newValue;
					end,
					disabled = function () return (MinArch:IsTomTomAvailable() == false) end,
					order = 2,
				},
				persistent = {
					type = "toggle",
					name = "Persist waypoints",
					desc = "Toggle waypoint persistence. This won't change already existing waypoints.",
					get = function () return MinArch.db.profile.TomTom.persistent end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.persistent = newValue;
					end,
					disabled = function () return (MinArch:IsTomTomAvailable() == false) end,
					order = 3,
				},
			},
		},
		autoway = {
			type = 'group',
			name = 'Automatically create waypoints for the closest digsite.',
			inline = true,
			order = 3,
			args = {
				autoWayOnMove = {
					type = "toggle",
					name = "Continuously",
					desc = "Continuously create/update the automatic waypoint to the closest digsite.",
					get = function () return MinArch.db.profile.TomTom.autoWayOnMove end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.autoWayOnMove = newValue;
					end,
					disabled = function () return (MinArch:IsNavigationEnabled() == false) end,
					order = 1,
				},
				autoWayOnComplete = {
					type = "toggle",
					name = "When completed",
					desc = "Automatically create a waypoint to the closest digsite after completing one.",
					get = function () return MinArch.db.profile.TomTom.autoWayOnComplete end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.autoWayOnComplete = newValue;
					end,
					disabled = function () return (MinArch:IsNavigationEnabled() == false) end,
					order = 2,
                },
				ignoreHidden = {
					type = "toggle",
					name = "Ignore hidden races",
					desc = "Enable this to ignore hidden races when creating waypoints.",
					get = function () return MinArch.db.profile.TomTom.ignoreHidden end,
                    set = function (_, newValue)
						MinArch.db.profile.TomTom.ignoreHidden = newValue;
					end,
                    disabled = function () return (MinArch:IsNavigationEnabled() == false) end,
					order = 4,
                },
				message = {
					type = "description",
					name = "Note: Priority options have been moved to the Race Settings section",
					fontSize = "normal",
					width = "full",
					order = 5,
				},
			},
		},
		taxi = {
			type = 'group',
			name = 'Taxi Options',
			inline = true,
			order = 4,
			args = {
				enable = {
					type = "toggle",
					name = "Navigate to nearest Flight Master",
					desc = "Enable to set the waypoint to the nearest flight master, if the nearest digsite is farther than the configured distance limit.",
					get = function () return MinArch.db.profile.TomTom.taxi.enabled end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.taxi.enabled = newValue;
						if not newValue then
							MinArch.db.profile.TomTom.taxi.archMode = false
						end
					end,
					width = 1.5,
					order = 1,
				},
				distance = {
					type = "range",
					name = "Distance limit",
					desc = "If enabled, waypoints will be created to the nearest flight master, if the nearest digsite is farther than the configured distance limit.",
					min = 2000,
					max = 10000,
					step = 100,
					get = function () return MinArch.db.profile.TomTom.taxi.distance end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.taxi.distance = newValue;
					end,
					order = 2,
				},
				spacer = {
					fontSize = "normal",
					type = "description",
					name = "",
					width = "full",
					order = 3,
				},
				pinAlpha = {
					type = "range",
					name = "Pin Opacity",
					desc = "Set the opacity of unrelated taxi nodes on the flight map",
					min = 0,
					max = 100,
					step = 5,
					get = function () return MinArch.db.profile.TomTom.taxi.alpha end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.taxi.alpha = newValue;
					end,
					order = 4,
				},
				autoToggle = {
					type = "toggle",
					name = "Auto Enable",
					desc = "Automatically enable Archeology Mode on flight maps when a waypoint is created by MinArch",
					get = function () return MinArch.db.profile.TomTom.taxi.autoEnableArchMode end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.taxi.autoEnableArchMode = newValue;
					end,
					order = 5,
				},
				disableOnLogin = {
					type = "toggle",
					name = "Auto-Disable",
					desc = "Automatically disable Archaeology Mode on flight maps when there are no digsites on the world map and upon login",
					get = function () return MinArch.db.profile.TomTom.taxi.autoDisableArchMode end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.taxi.autoDisableArchMode = newValue;
					end,
					order = 6,
				},				
			}
		}
	}
}

local PatronSettings = {
	name = "MinArch Patrons",
	handler = MinArch,
	type = "group",
	args = {
		message = {
            type = "description",
            name = "Thanks for using Minimal Archaeology. If you like this addon, please consider supporting development by becoming a patron at |cFFF96854patreon.com/minarch|r.",
            fontSize = "normal",
            width = "full",
            order = 1,
        },
		patrons = {
			type = "group",
			name = "Patrons",
			inline = true,
			order = 3,
			args = {
				message = {
					type = "description",
					name = "Ice Reaper",
					fontSize = "medium",
					width = "full",
					order = 1,
				},
			}
		},
	}
	}

function Options:OnInitialize()
	local count = 1;
	for group, races in pairs(ArchRaceGroups) do
        if races[1] > 0 then
            local groupkey = 'group' .. tostring(group);

            raceSettings.args.hide.args[groupkey] = {
                type = 'group',
                name = ArchRaceGroupText[group],
                order = count + 2,
                inline = true,
                args = {
                }
            };
            raceSettings.args.cap.args[groupkey] = {
                type = 'group',
                name = ArchRaceGroupText[group],
                order = count + 1,
                inline = true,
                args = {
                }
            };
            raceSettings.args.keystone.args[groupkey] = {
                type = 'group',
                name = ArchRaceGroupText[group],
                order = count,
                inline = true,
                args = {
                }
            };
			raceSettings.args.priority.args[groupkey] = {
                type = 'group',
                name = ArchRaceGroupText[group],
                order = count + 2,
                inline = true,
                args = {
                }
            };
			local values = {}
			values[0] = 'No priority'
			for idx=1, #races do
				values[idx] = tostring(idx)
			end
            for idx=1, #races do
                local i = races[idx];
                if i > 0 then
                    raceSettings.args.hide.args[groupkey].args['race' .. tostring(i)] = {
                        type = "toggle",
                        name = function () return GetArchaeologyRaceInfo(i) end,
                        desc = function ()
                            return "Hide the "..MinArch['artifacts'][i]['race'].." artifact bar even if it has been discovered."
                        end,
                        order = i,
                        get = function () return MinArch.db.profile.raceOptions.hide[i] end,
                        set = function (_, newValue)
                            MinArch.db.profile.raceOptions.hide[i] = newValue;
                            MinArch:UpdateMain();
                        end,
                    };
                    raceSettings.args.cap.args[groupkey].args['race' .. tostring(i)] = {
                        type = "toggle",
                        name = function () return GetArchaeologyRaceInfo(i) end,
                        desc = function ()
                            return "Use the fragment cap for the "..MinArch['artifacts'][i]['race'].." artifact bar."
                        end,
                        order = i,
                        get = function () return MinArch.db.profile.raceOptions.cap[i] end,
                        set = function (_, newValue)
                            MinArch.db.profile.raceOptions.cap[i] = newValue;
                            MinArch:UpdateMain();
                        end,
                    };
                    raceSettings.args.keystone.args[groupkey].args['race' .. tostring(i)] = {
                        type = "toggle",
                        name = function () return GetArchaeologyRaceInfo(i) end,
                        desc = function ()
                            local RuneName, _, _, _, _, _, _, _, _, _ = C_Item.GetItemInfo(MinArch['artifacts'][i]['raceitemid']);
                            local RaceName = MinArch['artifacts'][i]['race'];

                            if (RuneName ~= nil and RaceName ~= nil) then
                                return "Always use all available "..RuneName.."s to solve "..RaceName.." artifacts.";
                            end
                        end,
                        order = i,
                        get = function () return MinArch.db.profile.raceOptions.keystone[i] end,
                        set = function (_, newValue)
                            MinArch.db.profile.raceOptions.keystone[i] = newValue;
                            MinArch:UpdateMain();
                        end,
                        disabled = (i == ARCHAEOLOGY_RACE_FOSSIL)
                    };
					raceSettings.args.priority.args[groupkey].args['race' .. tostring(i)] = {
                        type = "select",
						values = values,
                        name = function ()
							local suffix = ''
							if i == ARCHAEOLOGY_RACE_NERUBIAN then
								suffix = ' (affects both Northrend and Eastern Kingdom)'
							end
							return MinArch['artifacts'][i]['race'] .. suffix
						end,
                        desc = function ()
                            local RaceName = MinArch['artifacts'][i]['race'];

                            if (RuneName ~= nil and RaceName ~= nil) then
                                return "Set " .. RaceName .. " pirority";
                            end
                        end,
                        order = i,
                        get = function () return MinArch.db.profile.raceOptions.priority[i] or 0 end,
                        set = function (_, newValue)
							if (newValue == 0) then
								MinArch.db.profile.raceOptions.priority[i] = 0
							else
								updatePrioOrdering(group, i, newValue)
							end
                            MinArch:UpdateMain();
                        end,
                    };
                end
            end

            count = count + 1;
        end
	end

	self:RegisterMenus();
end

function Options:RegisterMenus()
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch", home);
	self.menu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch", "Minimal Archaeology");

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch General Settings", general);
	self.general = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch General Settings", "General Settings", "Minimal Archaeology");

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch Companion Settings", companionSettings);
	self.companionSettings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch Companion Settings", "Companion Settings", "Minimal Archaeology");

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch Race Settings", raceSettings);
	self.raceSettings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch Race Settings", "Race Settings", "Minimal Archaeology");

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch Navigation Settings", TomTomSettings);
	self.TomTomSettings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch Navigation Settings", "Navigation Settings", "Minimal Archaeology");

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch Developer Settings", devSettings);
    self.devSettings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch Developer Settings", "Developer Settings", "Minimal Archaeology");

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch Patrons", PatronSettings);
    self.patrons = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch Patrons", "Patrons", "Minimal Archaeology");

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(parent.db));
    self.profiles = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch Profiles", "Profiles", "Minimal Archaeology");
end
