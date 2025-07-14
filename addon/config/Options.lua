local ADDON, _ = ...
---@type MinArch

---@class MinArchOptions
local Options = MinArch:LoadModule("MinArchOptions");
---@type MinArchMain
local Main = MinArch:LoadModule("MinArchMain")
---@type MinArchDigsites
local Digsites = MinArch:LoadModule("MinArchDigsites")
---@type MinArchHistory
local History = MinArch:LoadModule("MinArchHistory")
---@type MinArchCompanion
local Companion = MinArch:LoadModule("MinArchCompanion")
---@type MinArchCommon
local Common = MinArch:LoadModule("MinArchCommon")
---@type MinArchLDB
local MinArchLDB = MinArch:LoadModule("MinArchLDB")
---@type MinArchNavigation
local Navigation = MinArch:LoadModule("MinArchNavigation")

local L = LibStub("AceLocale-3.0"):GetLocale("MinArch")

local ArchRaceGroupText = {
	L["GLOBAL_KUL_TIRAS"] .. ", " .. L["GLOBAL_ZANDALAR"],
	L["GLOBAL_BROKEN_ISLES"],
	L["GLOBAL_DRAENOR"],
	L["GLOBAL_PANDARIA"],
	L["GLOBAL_NORTHREND"],
	L["GLOBAL_OUTLAND"],
	L["GLOBAL_EASTERN_KINGDOMS"] .. ", " .. L["GLOBAL_KALIMDOR"]
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
    Companion:Update();
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
            name = L["OPTIONS_THANKS"],
            fontSize = "small",
            width = "full",
            order = 1,
        },
		info = {
            type = "description",
            name = L["OPTIONS_INTRO"],
            fontSize = "small",
            width = "full",
            order = 2,
        },
		general = {
			type = "group",
            name = L["OPTIONS_GENERAL_MAIN_TITLE"],
            inline = true,
            order = 3,
			args = {
				message = {
					type = "description",
					name = L["OPTIONS_GENERAL_MAIN_WINDOWS"],
					fontSize = "small",
					width = "full",
					order = 1,
				},
				main = {
					type = "execute",
					name = L["OPTIONS_TOGGLE_MAIN"],
					order = 2,
					func = function ()
						Main:ToggleWindow()
					end,
                },
                digsites = {
					type = "execute",
					name = L["OPTIONS_TOGGLE_HISTORY"],
					order = 3,
					func = function ()
						History:ToggleWindow()
					end,
				},
				history = {
					type = "execute",
					name = L["OPTIONS_TOGGLE_DIGSITES"],
					order = 4,
					func = function ()
						Digsites:ToggleWindow()
					end,
				},
			}
		},
		companion = {
			type = "group",
            name = L["OPTIONS_COMPANION_TITLE"],
            inline = true,
            order = 4,
			args = {
				message = {
					type = "description",
					name = L["OPTIONS_COMPANION_DESCRIPTION"],
					fontSize = "small",
					width = "full",
					order = 1,
				},
			}
		},
		race = {
			type = "group",
            name = L["OPTIONS_RACE_TITLE"],
            inline = true,
            order = 5,
			args = {
				message = {
					type = "description",
					name = L["OPTIONS_RACE_DESCRIPTION"],
					fontSize = "small",
					width = "full",
					order = 1,
				},
			}
		},

		navigation = {
			type = "group",
            name = L["OPTIONS_NAVIGATION_TITLE"],
            inline = true,
            order = 6,
			args = {
				message = {
					type = "description",
					name = L["OPTIONS_NAVIGATION_DESCRIPTION"],
					fontSize = "small",
					width = "full",
					order = 1,
				},
			}
		}
	}
}

local general = {
	name = L["OPTIONS_GENERAL_TITLE"],
	handler = MinArch,
	type = "group",
	args = {
        surveying = {
            type = "group",
            name = L["OPTIONS_SURVEYING_TITLE"],
            inline = true,
            order = 3,
            args = {
                dblClick = {
					type = "toggle",
					name = L["OPTIONS_SURVEY_ON_DBL_RCLICK_TITLE"],
					desc = L["OPTIONS_SURVEY_ON_DBL_RCLICK_DESC"],
					get = function () return MinArch.db.profile.surveyOnDoubleClick end,
					set = function (_, newValue)
						MinArch.db.profile.surveyOnDoubleClick = newValue;
                    end,
                    width = "full",
					order = 1,
                },
                disableMounted = {
                    type = "toggle",
					name = L["OPTIONS_SURVEY_DONT_MOUNTED_TITLE"],
					desc = L["OPTIONS_SURVEY_DONT_MOUNTED_DESC"],
					get = function () return MinArch.db.profile.dblClick.disableMounted end,
					set = function (_, newValue)
						MinArch.db.profile.dblClick.disableMounted = newValue;
                    end,
                    width = 1.5,
					order = 2,
                },
                disableInFlight = {
                    type = "toggle",
					name = L["OPTIONS_SURVEY_DONT_FLYING_TITLE"],
					desc = L["OPTIONS_SURVEY_DONT_FLYING_DESC"],
					get = function () return MinArch.db.profile.dblClick.disableInFlight end,
					set = function (_, newValue)
						MinArch.db.profile.dblClick.disableInFlight = newValue;
                    end,
                    width = 1.5,
					order = 3,
                },
				doubleClickButton = {
					name = L["OPTIONS_SURVEY_ON_DBL_CLICK_BTN_TITLE"],
					desc = L["OPTIONS_SURVEY_ON_DBL_CLICK_BTN_DESC"],
					type = "select",
					values = {[1] = L["OPTIONS_SURVEY_ON_DBL_CLICK_BTN_RMB"], [2] = L["OPTIONS_SURVEY_ON_DBL_CLICK_BTN_LMB"]},
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
			name = L["OPTIONS_MISC_TITLE"],
			inline = true,
			order = 4,
			args = {
				scale = {
					type = "range",
					name = L["OPTIONS_WINDOW_SCALE_TITLE"],
					desc = L["OPTIONS_WINDOW_SCALE_DESC"],
					min = 30,
					max = 200,
					step = 5,
					get = function () return MinArch.db.profile.frameScale end,
					set = function (_, newValue)
						MinArch.db.profile.frameScale = newValue;
						Common:FrameScale(newValue);
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
					name = L["OPTIONS_HIDE_MINIMAPBUTTON_TITLE"],
					desc = L["OPTIONS_HIDE_MINIMAPBUTTON_DESC"],
					get = function () return MinArch.db.profile.minimap.hide end,
					set = function (_, newValue)
						MinArch.db.profile.minimap.hide = newValue;

						MinArchLDB:RefreshMinimapButton();
					end,
					order = 3,
				},
				disableSound = {
					type = "toggle",
					name = L["OPTIONS_DISABLE_SOUND_TITLE"],
					desc = L["OPTIONS_DISABLE_SOUND_DESC"],
					get = function () return MinArch.db.profile.disableSound end,
					set = function (_, newValue)
						MinArch.db.profile.disableSound = newValue;
					end,
					order = 4,
				},
				showWorldMapOverlay = {
					type = "toggle",
					name = L["OPTIONS_SHOW_WORLD_MAP_ICONS_TITLE"],
					desc = L["OPTIONS_SHOW_WORLD_MAP_ICONS_DESC"],
					get = function () return MinArch.db.profile.showWorldMapOverlay end,
					set = function (_, newValue)
						MinArch.db.profile.showWorldMapOverlay = newValue;
						Digsites:ShowRaceIconsOnMap();
					end,

					width = "double",
					order = 5,
				},
				pinScale = {
					type = "range",
					name = L["OPTIONS_MAP_PIN_SCALE_TITLE"],
					desc = L["OPTIONS_MAP_PIN_SCALE_DESC"],
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
            name = L["OPTIONS_STARTUP_SETTINGS_TITLE"],
            inline = true,
            order = 5,
            args = {
				note = {
                    type = "description",
                    name = L["OPTIONS_STARTUP_NOTE"],
                    -- fontSize = "small",
                    width = "full",
                    order = 1,
			    },
                startHidden = {
					type = "toggle",
					name = L["OPTIONS_START_HIDDEN_TITLE"],
					desc = L["OPTIONS_START_HIDDEN_DESC"],
					get = function () return MinArch.db.profile.startHidden end,
					set = function (_, newValue)
						MinArch.db.profile.startHidden = newValue;
					end,
					order = 3,
				},
				rememberState = {
					type = "toggle",
					name = L["OPTIONS_REMEMBER_WINDOW_STATES_TITLE"],
					desc = L["OPTIONS_REMEMBER_WINDOW_STATES_DESC"],
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
			name = L["OPTIONS_AUTOHIDE_TITLE"],
			inline = true,
			order = 6,
			args = {
			    note = {
                    type = "description",
                    name = L["OPTIONS_STARTUP_NOTE"],
                    -- fontSize = "small",
                    width = "full",
                    order = 1,
			    },
				hideAfterDigsite = {
					type = "toggle",
					name = L["OPTIONS_HIDE_AFTER_DIGSITES_TITLE"],
					desc = L["OPTIONS_HIDE_AFTER_DIGSITES_DESC"],
					get = function () return MinArch.db.profile.hideAfterDigsite end,
					set = function (_, newValue)
						MinArch.db.profile.hideAfterDigsite = newValue;
					end,
					order = 2,
				},
				waitForSolve = {
					type = "toggle",
					name = L["OPTIONS_HIDE_WATE_FOR_SOLVES_TITLE"],
					desc = L["OPTIONS_HIDE_WATE_FOR_SOLVES_DESC"],
					get = function () return MinArch.db.profile.waitForSolve end,
					set = function (_, newValue)
						MinArch.db.profile.waitForSolve = newValue;
					end,
					disabled = function () return (MinArch.db.profile.hideAfterDigsite == false) end,
					order = 3
				},
				hideInCombat = {
					type = "toggle",
					name = L["OPTIONS_HIDE_IN_COMBAT_DESC"],
					desc = L["OPTIONS_HIDE_IN_COMBAT_TITLE"],
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
			name = L["OPTIONS_AUTOSHOW_TITLE"],
			inline = true,
			order = 7,
			args = {
				autoShowInDigsites = {
					type = "toggle",
					name = L["OPTIONS_AUTOSHOW_DIGSITES_TITLE"],
					desc = L["OPTIONS_AUTOSHOW_DIGSITES_DESC"],
					get = function () return MinArch.db.profile.autoShowInDigsites end,
					set = function (_, newValue)
						MinArch.db.profile.autoShowInDigsites = newValue;
						MinArch.ShowInDigsite = true;
					end,
					order = 1,
				},
				autoShowOnSurvey = {
					type = "toggle",
					name = L["OPTIONS_AUTOSHOW_SURVEY_TITLE"],
					desc = L["OPTIONS_AUTOSHOW_SURVEY_DESC"],
					get = function () return MinArch.db.profile.autoShowOnSurvey end,
					set = function (_, newValue)
						MinArch.db.profile.autoShowOnSurvey = newValue;
						MinArch.ShowOnSurvey = true;
					end,
					order = 2,
				},
				autoShowOnSolve = {
					type = "toggle",
					name = L["OPTIONS_AUTOSHOW_SOLVES_TITLE"],
					desc = L["OPTIONS_AUTOSHOW_SOLVES_DESC"],
					get = function () return MinArch.db.profile.autoShowOnSolve end,
					set = function (_, newValue)
						MinArch.db.profile.autoShowOnSolve = newValue;
					end,
					order = 3,
				},
				autoShowOnCap = {
					type = "toggle",
					name = L["OPTIONS_AUTOSHOW_CAP_TITLE"],
					desc = L["OPTIONS_AUTOSHOW_CAP_DESC"],
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
			name = L["OPTIONS_HISTORY_WINDOW_TITLE"],
			inline = true,
			order = 8,
			args = {
                autoResize = {
					type = "toggle",
					name = L["OPTIONS_HISTORY_AUTORESIZE_TITLE"],
					desc = L["OPTIONS_HISTORY_AUTORESIZE_DESC"] ,
					get = function () return MinArch.db.profile.history.autoResize end,
					set = function (_, newValue)
                        MinArch.db.profile.history.autoResize = newValue;
                        History:CreateHistoryList(MinArchOptions['CurrentHistPage'], "Options");
					end,
					order = 1,
				},
				showStats = {
					type = "toggle",
					name = L["OPTIONS_HISTORY_SHOW_STATS_TITLE"],
					desc = L["OPTIONS_HISTORY_SHOW_STATS_DESC"],
					get = function () return MinArch.db.profile.history.showStats end,
					set = function (_, newValue)
                        MinArch.db.profile.history.showStats = newValue;
						if newValue then
							History.statsFrame:Show()
						else
							History.statsFrame:Hide()
						end
					end,
					order = 2,
				},
				groupByProgress = {
					type = "toggle",
					name = L["OPTIONS_HISTORY_GROUP_TITLE"],
					desc = L["OPTIONS_HISTORY_GROUP_DESC"],
					get = function () return MinArch.db.profile.history.groupByProgress end,
					set = function (_, newValue)
                        MinArch.db.profile.history.groupByProgress = newValue;
                        History:CreateHistoryList(MinArchOptions['CurrentHistPage'], "Options");
					end,
					order = 3,
				},
            }
        },
	}
}

local raceSettings = {
	name = L["OPTIONS_RACE_SECTION_TITLE"],
	handler = MinArch,
	type = "group",
	childGroups = "tab",
	args = {
		relevancy = {
			type = 'group',
			name = L["OPTIONS_RACE_RELEVANCY_TITLE"],
			inline = false,
			order = 1,
			args = {
				message = {
					type = "description",
					name = L["OPTIONS_RACE_RELEVANCY_DESC"],
					fontSize = "medium",
					width = "full",
					order = 1,
				},
				relevancySub = {
					type = 'group',
					name = L["OPTIONS_RACE_RELEVANCY_CUSTOMIZE"],
					order = 2,
					inline = true,
					args = {
						nearby = {
							type = "toggle",
							name = L["OPTIONS_RACE_RELEVANCY_NEARBY_TITLE"],
							desc = L["OPTIONS_RACE_RELEVANCY_NEARBY_DESC"],
							get = function () return MinArch.db.profile.relevancy.nearby end,
							set = function (_, newValue)
								MinArch.db.profile.relevancy.nearby = newValue;
								Main:Update();
							end,
							order = 1,
						},
						continentSpecific = {
							type = "toggle",
							name = L["OPTIONS_RACE_RELEVANCY_EXPANSION_TITLE"],
							desc = L["OPTIONS_RACE_RELEVANCY_EXPANSION_DESC"],
							get = function () return MinArch.db.profile.relevancy.continentSpecific end,
							set = function (_, newValue)
								MinArch.db.profile.relevancy.continentSpecific = newValue;
								Main:Update();
							end,
							order = 2,
						},
						solvable = {
							type = "toggle",
							name = L["OPTIONS_RACE_RELEVANCY_SOLVABLE_TITLE"],
							desc = L["OPTIONS_RACE_RELEVANCY_SOLVABLE_DESC"],
							get = function () return MinArch.db.profile.relevancy.solvable end,
							set = function (_, newValue)
								MinArch.db.profile.relevancy.solvable = newValue;
								Main:Update();
							end,
							order = 3,
                        },
                    },
                },
                relevancyOverrides = {
					type = 'group',
					name = L["OPTIONS_RACE_RELEVANCY_OVERRIDES_TITLE"],
					order = 2,
					inline = true,
					args = {
                        hideCapped = {
                            type = "toggle",
							name = L["OPTIONS_RACE_RELEVANCY_OVERRIDE_FRAGCAP_TITLE"],
							desc = L["OPTIONS_RACE_RELEVANCY_OVERRIDE_FRAGCAP_DESC"],
							get = function () return MinArch.db.profile.relevancy.hideCapped end,
							set = function (_, newValue)
								MinArch.db.profile.relevancy.hideCapped = newValue;
                                Main:Update();
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
			name = L["OPTIONS_RACE_HIDE_TITLE"],
			order = 2,
			inline = false,
			args = {
				message = {
					type = "description",
					name = L["OPTIONS_RACE_HIDE_DESC"],
					fontSize = "medium",
					width = "full",
					order = 1,
				},
				wpIgnoreHidden = {
					type = "toggle",
					name = L["OPTIONS_RACE_HIDE_WPIGNORE_TITLE"],
					desc = L["OPTIONS_RACE_HIDE_WPIGNORE_DESC"],
					get = function () return MinArch.db.profile.TomTom.ignoreHidden end,
                    set = function (_, newValue)
						MinArch.db.profile.TomTom.ignoreHidden = newValue;
					end,
                    disabled = function () return (Navigation:IsNavigationEnabled() == false) end,
					width = "full",
					order = 2,
                },
			}
		},
		cap = {
			type = "group",
			name = L["OPTIONS_RACE_CAP_TITLE"],
			order = 3,
			inline = false,
			args = {
				message = {
					type = "description",
					name = L["OPTIONS_RACE_CAP_DESC"],
					fontSize = "medium",
					width = "full",
					order = 1,
				},
                solveConfirmation = {
                    width = "full",
					type = "toggle",
					name = L["OPTIONS_RACE_CAP_CONFIRM_TITLE"],
					desc = L["OPTIONS_RACE_CAP_CONFIRM_DESC"],
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
			name = L["OPTIONS_RACE_CAP_KEYSTONE_TITLE"],
			order = 4,
			inline = false,
			args = {
				message = {
					type = "description",
					name = L["OPTIONS_RACE_CAP_KEYSTONE_DESC"],
					fontSize = "medium",
					width = "full",
					order = 1,
				},
			}
		},
		priority = {
			type = "group",
			name = L["OPTIONS_RACE_CAP_PRIORITY_TITLE"],
			order = 5,
			inline = false,
			args = {
				message = {
					type = "description",
					name = L["OPTIONS_RACE_CAP_PRIORITY_DESC"],
					fontSize = "medium",
					width = "full",
					order = 1,
				},
				reset = {
					type = "execute",
					name = L["OPTIONS_RACE_CAP_PRIORITY_RESETALL"],
					order = 2,
					func = function ()
						for i=1, ARCHAEOLOGY_NUM_RACES do
							MinArch.db.profile.raceOptions.priority[i] = nil
						end
						Main:Update();
					end,
				}
			}
		},
	}
}

local companionSettings = {
    name = L["OPTIONS_COMPANION_TITLE"],
	handler = MinArch,
	type = "group",
	args = {
        general = {
			type = "group",
			name = L["OPTIONS_COMPANION_GENERAL_TITLE"],
			order = 1,
			inline = true,
			args = {
                enable = {
					type = "toggle",
					name = L["OPTIONS_COMPANION_GENERAL_ENABLE_TITLE"],
                    desc = L["OPTIONS_COMPANION_GENERAL_ENABLE_DESC"],
                    width = 1.5,
					get = function () return MinArch.db.profile.companion.enable end,
					set = function (_, newValue)
						MinArch.db.profile.companion.enable = newValue;

						if (newValue) then
							Companion:Enable();
						else
							Companion:Disable();
						end
					end,
					order = 1,
				},
				alwaysShow = {
					type = "toggle",
					name = L["OPTIONS_COMPANION_GENERAL_ALWAYS_SHOW_TITLE"],
					desc = L["OPTIONS_COMPANION_GENERAL_ALWAYS_SHOW_DESC"],
					get = function () return MinArch.db.profile.companion.alwaysShow end,
					set = function (_, newValue)
                        MinArch.db.profile.companion.alwaysShow = newValue;
                        Companion:AutoToggle()
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
					order = 2,
                },
                hideInCombat = {
                    type = "toggle",
                    name = L["OPTIONS_COMPANION_GENERAL_HIDEINCOMBAT_TITLE"],
                    desc = L["OPTIONS_COMPANION_GENERAL_HIDEINCOMBAT_DESC"],
                    get = function () return MinArch.db.profile.companion.hideInCombat end,
                    set = function (_, newValue)
                        MinArch.db.profile.companion.hideInCombat = newValue;
                        Companion:AutoToggle()
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                    order = 3,
                },
				hideWhenUnavailable = {
                    type = "toggle",
                    name = L["OPTIONS_COMPANION_GENERAL_HIDENA_TITLE"],
                    desc = L["OPTIONS_COMPANION_GENERAL_HIDENA_DESC"],
                    get = function () return MinArch.db.profile.companion.hideWhenUnavailable end,
                    set = function (_, newValue)
                        MinArch.db.profile.companion.hideWhenUnavailable = newValue;
                        Companion:AutoToggle()
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                    order = 3,
                },
                hrC = {
                    type = "description",
                    name = L["OPTIONS_COMPANION_GENERAL_COLORING_TITLE"],
                    width = "full",
                    order = 4,
                },
                background = {
                    type = "color",
                    name = L["OPTIONS_COMPANION_GENERAL_COLORING_BG_TITLE"],
                    get = function () return MinArch.db.profile.companion.bg.r, MinArch.db.profile.companion.bg.g, MinArch.db.profile.companion.bg.b end,
                    set = function (_, r, g, b, a)
                        MinArch.db.profile.companion.bg.r = r;
                        MinArch.db.profile.companion.bg.g = g;
                        MinArch.db.profile.companion.bg.b = b;
                        Companion:Update();
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                    order = 5,
                },
                bgOpacity = {
                    type = "range",
                    name = L["OPTIONS_COMPANION_GENERAL_COLORING_OPACITY_TITLE"],
                    min = 0,
                    max = 100,
                    step = 1,
                    get = function () return MinArch.db.profile.companion.bg.a * 100 end,
                    set = function (_, newValue)
                        MinArch.db.profile.companion.bg.a = newValue / 100;
                        Companion:Update();
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                    order = 6,
                },
                hr = {
                    type = "description",
                    name = L["OPTIONS_COMPANION_GENERAL_SIZING_TITLE"],
                    width = "full",
                    order = 97,
                },
                buttonSpacing = {
                    type = "range",
                    name = L["OPTIONS_COMPANION_GENERAL_SIZING_SPACING_TITLE"],
                    desc = L["OPTIONS_COMPANION_GENERAL_SIZING_SPACING_DESC"],
                    min = 0,
                    max = 20,
                    step = 1,
                    get = function () return MinArch.db.profile.companion.buttonSpacing end,
                    set = function (_, newValue)
                        MinArch.db.profile.companion.buttonSpacing = newValue;
                        Companion:Update();
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                    order = 98,
                },
                padding = {
                    type = "range",
                    name = L["OPTIONS_COMPANION_GENERAL_SIZING_PADDING_TITLE"],
                    desc = L["OPTIONS_COMPANION_GENERAL_SIZING_PADDING_DESC"],
                    min = 0,
                    max = 20,
                    step = 1,
                    get = function () return MinArch.db.profile.companion.padding end,
                    set = function (_, newValue)
                        MinArch.db.profile.companion.padding = newValue;
                        Companion:Update();
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                    order = 98,
                },
                scale = {
                    type = "range",
                    name = L["OPTIONS_COMPANION_GENERAL_SIZING_SCALE_TITLE"],
                    desc = L["OPTIONS_COMPANION_GENERAL_SIZING_SCALE_DESC"],
                    min = 30,
                    max = 300,
                    step = 5,
                    get = function () return MinArch.db.profile.companion.frameScale end,
                    set = function (_, newValue)
                        MinArch.db.profile.companion.frameScale = newValue;
                        Companion:SetFrameScale(newValue);
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                    order = 99,
                },
            },
        },
        positioning = {
            type = "group",
            name = L["OPTIONS_COMPANION_POSITION_TITLE"],
            order = 2,
            inline = true,
            args = {
                lock = {
					type = "toggle",
					name = L["OPTIONS_COMPANION_POSITION_LOCK_TITLE"],
					desc = L["OPTIONS_COMPANION_POSITION_LOCK_DESC"],
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
					name = L["OPTIONS_COMPANION_POSITION_SAVEPOS_TITLE"],
					desc = L["OPTIONS_COMPANION_POSITION_SAVEPOS_DESC"],
					get = function () return MinArch.db.profile.companion.savePos end,
					set = function (_, newValue)
                        MinArch.db.profile.companion.savePos = newValue;
                        if newValue then
                            Companion:SavePosition()
                        end
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
					order = 3,
                },
                x = {
					type = "input",
					name = L["OPTIONS_COMPANION_POSITION_HOFFSET_TITLE"],
					desc = L["OPTIONS_COMPANION_POSITION_HOFFSET_DESC"],
					get = function () return tostring(MinArch.db.profile.companion.posX) end,
                    set = function (_, newValue)
                        if (MinArch.db.profile.companion.enable and MinArch.db.profile.companion.savePos) then
                            MinArch.db.profile.companion.posX = tonumber(newValue);
                            local point, relativeTo, relativePoint, xOfs, yOfs = Companion.frame:GetPoint();
                            Companion.frame:ClearAllPoints();
                            Companion.frame:SetPoint(point, UIParent, relativePoint, tonumber(newValue), yOfs);
                            Companion.frame:SavePosition()
                        end
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false or MinArch.db.profile.companion.savePos == false) end,
					order = 4,
                },
                y = {
					type = "input",
					name = L["OPTIONS_COMPANION_POSITION_VOFFSET_TITLE"],
					desc = L["OPTIONS_COMPANION_POSITION_VOFFSET_DESC"],
					get = function () return tostring(MinArch.db.profile.companion.posY) end,
                    set = function (_, newValue)
                        if (MinArch.db.profile.companion.enable and MinArch.db.profile.companion.savePos) then
                            MinArch.db.profile.companion.posY = tonumber(newValue);
                            local point, relativeTo, relativePoint, xOfs, yOfs = Companion.frame:GetPoint();
                            Companion.frame:ClearAllPoints();
                            Companion.frame:SetPoint(point, UIParent, relativePoint, xOfs, tonumber(newValue));
                            Companion.frame:SavePosition();
                        end
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false or MinArch.db.profile.companion.savePos == false) end,
					order = 5,
				},
                resetButton = {
					type = "execute",
					name = L["OPTIONS_COMPANION_POSITION_RESET"],
					order = 6,
					func = function ()
                        Companion:ResetPosition();
					end,
                },
            }
        },
        featureOpts = {
            type = "group",
            name = L["OPTIONS_COMPANION_FEATURES_TITLE"],
            order = 3,
            inline = true,
            args = {
                distanceTracker = {
                    type = "group",
                    name = L["OPTIONS_COMPANION_POSITION_FEATURES_DT_TITLE"],
                    order = 1,
                    inline = true,
                    args = {
                        toggleDistanceTracker = {
                            type = "toggle",
                            name = L["OPTIONS_COMPANION_POSITION_FEATURES_DT_SHOW_TITLE"],
                            desc = L["OPTIONS_COMPANION_POSITION_FEATURES_DT_SHOW_DESC"],
                            get = function () return MinArch.db.profile.companion.features.distanceTracker.enabled end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.distanceTracker.enabled = newValue;
                                Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 1,
                        },
                        distanceTrackerOrder = {
                            type = "select",
                            name = L["OPTIONS_GLOBAL_ORDER_TITLE"],
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
                            name = L["OPTIONS_COMPANION_POSITION_FEATURES_DT_SHAPE_TITLE"],
                            values = {L["OPTIONS_GLOBAL_CIRCLE"], L["OPTIONS_GLOBAL_SQUARE"], L["OPTIONS_GLOBAL_TRIANGLE"]},
                            get = function () return MinArch.db.profile.companion.features.distanceTracker.shape end,
                            set = function (info, newValue)
                                MinArch.db.profile.companion.features.distanceTracker.shape = newValue
                                Companion:UpdateIndicatorFrameTexture()
                            end,
                        }
                    }
                },
                waypointButton = {
                    type = "group",
                    name = L["OPTIONS_COMPANION_POSITION_FEATURES_WP_TITLE"],
                    order = 2,
                    inline = true,
                    args = {
                        toggleWaypointButton = {
                            type = "toggle",
                            name = L["OPTIONS_COMPANION_POSITION_FEATURES_WP_SHOW_TITLE"],
                            desc = L["OPTIONS_COMPANION_POSITION_FEATURES_WP_SHOW_DESC"],
                            get = function () return MinArch.db.profile.companion.features.waypointButton.enabled end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.waypointButton.enabled = newValue;
                                Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 6,
                        },
                        waypointButtonOrder = {
                            type = "select",
                            name = L["OPTIONS_GLOBAL_ORDER_TITLE"],
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
                    name = L["OPTIONS_COMPANION_POSITION_FEATURES_SURVEY_TITLE"],
                    order = 3,
                    inline = true,
                    args = {
                        toggleSurveyButton = {
                            type = "toggle",
                            name = L["OPTIONS_COMPANION_POSITION_FEATURES_SURVEY_SHOW_TITLE"],
                            desc = L["OPTIONS_COMPANION_POSITION_FEATURES_SURVEY_SHOW_DESC"],
                            get = function () return MinArch.db.profile.companion.features.surveyButton.enabled end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.surveyButton.enabled = newValue;
                                Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 3,
                        },
                        solveButtonOrder = {
                            type = "select",
                            name = L["OPTIONS_GLOBAL_ORDER_TITLE"],
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
                    name = L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_TITLE"],
                    order = 4,
                    inline = true,
                    args = {
                        toggleSolveButton = {
                            type = "toggle",
                            name = L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_TITLE"],
                            desc = L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_DESC"],
                            get = function () return MinArch.db.profile.companion.features.solveButton.enabled end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.solveButton.enabled = newValue;
                                Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 20,
                        },
                        solveButtonOrder = {
                            type = "select",
                            name = L["OPTIONS_GLOBAL_ORDER_TITLE"],
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
                            name = L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_RELEVANT_TITLE"],
                            desc = L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_RELEVANT_DESC"],
                            get = function () return MinArch.db.profile.companion.relevantOnly end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.relevantOnly = newValue;
                                Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
							width = "full",
                            order = 53,
                        },
						alwaysShowNearest = {
                            type = "toggle",
                            name = L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_NEAREST_TITLE"],
                            desc = L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_NEAREST_DESC"],
                            get = function () return MinArch.db.profile.companion.features.solveButton.alwaysShowNearest end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.solveButton.alwaysShowNearest = newValue;
                                Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
							width = 1.5,
                            order = 54,
                        },
						alwaysShowSolvable = {
                            type = "toggle",
                            name = L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_SOLVABLE_TITLE"],
                            desc = L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_SOLVABLE_DESC"],
                            get = function () return MinArch.db.profile.companion.features.solveButton.alwaysShowSolvable end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.solveButton.alwaysShowSolvable = newValue;
                                Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
							width = 1.5,
                            order = 55,
                        },
						keystone = {
                            type = "toggle",
                            name = L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_KEYSTONES_TITLE"],
                            desc = L["OPTIONS_COMPANION_POSITION_FEATURES_SOLVE_SHOW_KEYSTONES_DESC"],
                            get = function () return MinArch.db.profile.companion.features.solveButton.keystone end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.solveButton.keystone = newValue;
                                Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 57,
                        },
                    }
                },
                crateButton = {
                    type = "group",
                    name = L["OPTIONS_COMPANION_POSITION_FEATURES_CRATE_TITLE"],
                    order = 5,
                    inline = true,
                    args = {
                        toggleCrateButton = {
                            type = "toggle",
                            name = L["OPTIONS_COMPANION_POSITION_FEATURES_CRATE_SHOW_TITLE"],
                            desc = L["OPTIONS_COMPANION_POSITION_FEATURES_CRATE_SHOW_DESC"],
                            get = function () return MinArch.db.profile.companion.features.crateButton.enabled end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.crateButton.enabled = newValue;
                                Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 51,
                        },
                        crateButtonOrder = {
                            type = "select",
                            name = L["OPTIONS_GLOBAL_ORDER_TITLE"],
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
                    name = L["OPTIONS_COMPANION_POSITION_FEATURES_MOUNT_TITLE"],
                    order = 6,
                    inline = true,
                    args = {
                        toggleMountButton = {
                            type = "toggle",
                            name = L["OPTIONS_COMPANION_POSITION_FEATURES_MOUNT_SHOW_TITLE"],
                            desc = L["OPTIONS_COMPANION_POSITION_FEATURES_MOUNT_SHOW_DESC"],
                            get = function () return MinArch.db.profile.companion.features.mountButton.enabled end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.mountButton.enabled = newValue;
                                Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 6,
                        },
                        mountButtonOrder = {
                            type = "select",
                            name = L["OPTIONS_GLOBAL_ORDER_TITLE"],
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
                    name = L["OPTIONS_COMPANION_POSITION_FEATURES_SKILLBAR_TITLE"],
                    order = 6,
                    inline = true,
                    args = {
                        toggleMountButton = {
                            type = "toggle",
                            name = L["OPTIONS_COMPANION_POSITION_FEATURES_SKILLBAR_SHOW_TITLE"],
                            desc = L["OPTIONS_COMPANION_POSITION_FEATURES_SKILLBAR_SHOW_DESC"],
                            get = function () return MinArch.db.profile.companion.features.skillBar.enabled end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.skillBar.enabled = newValue;
                                Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 1,
                        },
                    }
                },
				progressBar = {
                    type = "group",
                    name = L["OPTIONS_COMPANION_POSITION_FEATURES_PROGBAR_TITLE"],
                    order = 8,
                    inline = true,
                    args = {
                        toggleMountButton = {
                            type = "toggle",
                            name = L["OPTIONS_COMPANION_POSITION_FEATURES_PROGBAR_SHOW_TITLE"],
                            desc = L["OPTIONS_COMPANION_POSITION_FEATURES_PROGBAR_SHOW_DESC"],
                            get = function () return MinArch.db.profile.companion.features.progressBar.enabled end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.progressBar.enabled = newValue;
                                Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 1,
                        },
						showTooltip = {
                            type = "toggle",
                            name = L["OPTIONS_COMPANION_POSITION_FEATURES_PROGBAR_TOOLTIP_TITLE"],
                            desc = L["OPTIONS_COMPANION_POSITION_FEATURES_PROGBAR_TOOLTIP_DESC"],
                            get = function () return MinArch.db.profile.companion.features.progressBar.showTooltip end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.progressBar.showTooltip = newValue;
                                Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 1,
                        },
						solveOnClick = {
                            type = "toggle",
                            name = L["OPTIONS_COMPANION_POSITION_FEATURES_PROGBAR_CLICK_TITLE"],
                            desc = L["OPTIONS_COMPANION_POSITION_FEATURES_PROGBAR_CLICK_DESC"],
                            get = function () return MinArch.db.profile.companion.features.progressBar.solveOnClick end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.features.progressBar.solveOnClick = newValue;
                                Companion:Update();
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
	name = L["OPTIONS_DEV_TITLE"],
	handler = MinArch,
	type = "group",
	args = {
		dev = {
			type = 'group',
			name = L["OPTIONS_DEV_DEBUG_TITLE"],
			inline = true,
			order = 1,
			args = {
				showStatusMessages = {
					type = "toggle",
					name = L["OPTIONS_DEV_DEBUG_STATUS_TITLE"],
					desc = L["OPTIONS_DEV_DEBUG_STATUS_DESC"],
					get = function () return MinArch.db.profile.showStatusMessages end,
					set = function (_, newValue)
						MinArch.db.profile.showStatusMessages = newValue;
					end,
					order = 1,
				},
				showDebugMessages = {
					type = "toggle",
					name = L["OPTIONS_DEV_DEBUG_DEV_TITLE"],
					desc = L["OPTIONS_DEV_DEBUG_DEV_DESC"],
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
            name = L["OPTIONS_DEV_EXPERIMENTAL_DESC"],
            fontSize = "normal",
            width = "full",
            order = 1,
        },
		experimental = {
			type = 'group',
			name = L["OPTIONS_DEV_EXPERIMENTAL_TITLE"],
			inline = true,
			order = 2,
			args = {
				optimizePath = {
                    type = "toggle",
					name = L["OPTIONS_DEV_EXPERIMENTAL_OPTIMIZE_TITLE"],
                    desc = L["OPTIONS_DEV_EXPERIMENTAL_OPTIMIZE_DESC"],
                    get = function () return MinArch.db.profile.TomTom.optimizePath end,
                    set = function (_, newValue)
						MinArch.db.profile.TomTom.optimizePath = newValue;
					end,
                    order = 1,
                },
				optimizeModifier = {
					type = "range",
					name = L["OPTIONS_DEV_EXPERIMENTAL_OPTIMIZE_MOD_TITLE"],
					desc = L["OPTIONS_DEV_EXPERIMENTAL_OPTIMIZE_MOD_DESC"],
					min = 1,
					max = 5,
					step = 0.05,
					get = function () return MinArch.db.profile.TomTom.optimizationModifier end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.optimizationModifier = newValue;
						Navigation:SetWayToNearestDigsite()
					end,
					order = 2,
				},
			}
		}
	}
}

local TomTomSettings = {
	name = L["OPTIONS_NAV_TITLE"],
	handler = MinArch,
	type = "group",
	args = {
        blizzway = {
			type = 'group',
			name = L["OPTIONS_NAV_BLIZZ_TITLE"],
			inline = true,
			order = 1,
			args = {
                uiMapPoint = {
					type = "toggle",
					name = L["OPTIONS_NAV_BLIZZ_PIN_TITLE"],
					desc = L["OPTIONS_NAV_BLIZZ_PIN_DESC"],
					get = function () return MinArch.db.profile.TomTom.enableBlizzWaypoint end,
					set = function (_, newValue)
                        MinArch.db.profile.TomTom.enableBlizzWaypoint = newValue;
                        if MinArch.db.char.TomTom.uiMapPoint and not newValue then
                            Navigation:ClearUiWaypoint()
                        end
					end,
					disabled = function () return (MINARCH_EXPANSION == 'Cata' or MINARCH_EXPANSION == 'MoP') end,
					order = 2,
                },
                superTrack = {
					type = "toggle",
					name = L["OPTIONS_NAV_BLIZZ_FLOATPIN_TITLE"],
					desc = L["OPTIONS_NAV_BLIZZ_FLOATPIN_DESC"],
					get = function () return MinArch.db.profile.TomTom.superTrack end,
					set = function (_, newValue)
                        MinArch.db.profile.TomTom.superTrack = newValue;
                        if MinArch.db.char.TomTom.uiMapPoint then
							if (MINARCH_EXPANSION == 'Mainline') then
                            	C_SuperTrack.SetSuperTrackedUserWaypoint(newValue);
							end
                        end
					end,
					disabled = function () return (MinArch.db.profile.TomTom.enableBlizzWaypoint == false or MINARCH_EXPANSION == 'Cata' or MINARCH_EXPANSION == 'MoP') end,
					order = 2,
				},
            }
        },
		tomtom = {
			type = 'group',
			name = L["OPTIONS_NAV_TOMTOM_TITLE"],
			inline = true,
			order = 2,
			disabled = function () return (_G["TomTom"] == nil) end,
			args = {
				enable = {
					type = "toggle",
					name = L["OPTIONS_NAV_TOMTOM_ENABLE_TITLE"],
					desc = L["OPTIONS_NAV_TOMTOM_ENABLE_DESC"],
					width = "full",
					get = function () return MinArch.db.profile.TomTom.enableTomTom end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.enableTomTom = newValue;

						if (newValue) then
							Main.frame.autoWaypointButton:Show();
							Digsites.wpButton:Show();
						else
							Navigation:ClearAllDigsiteWaypoints();
							Main.frame.autoWaypointButton:Hide();
							Digsites.wpButton:Hide();
						end
					end,
					order = 1,
				},
				arrow = {
					type = "toggle",
					name = L["OPTIONS_NAV_TOMTOM_ARROW_TITLE"],
					desc = L["OPTIONS_NAV_TOMTOM_ARROW_DESC"],
					get = function () return MinArch.db.profile.TomTom.arrow end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.arrow = newValue;
					end,
					disabled = function () return (Navigation:IsTomTomAvailable() == false) end,
					order = 2,
				},
				persistent = {
					type = "toggle",
					name = L["OPTIONS_NAV_TOMTOM_WP_TITLE"],
					desc = L["OPTIONS_NAV_TOMTOM_WP_DESC"],
					get = function () return MinArch.db.profile.TomTom.persistent end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.persistent = newValue;
					end,
					disabled = function () return (Navigation:IsTomTomAvailable() == false) end,
					order = 3,
				},
			},
		},
		autoway = {
			type = 'group',
			name = L["OPTIONS_NAV_AUTO_TITLE"],
			inline = true,
			order = 3,
			args = {
				autoWayOnMove = {
					type = "toggle",
					name = L["OPTIONS_NAV_AUTO_CONT_TITLE"],
					desc = L["OPTIONS_NAV_AUTO_CONT_DESC"],
					get = function () return MinArch.db.profile.TomTom.autoWayOnMove end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.autoWayOnMove = newValue;
					end,
					disabled = function () return (Navigation:IsNavigationEnabled() == false) end,
					order = 1,
				},
				autoWayOnComplete = {
					type = "toggle",
					name = L["OPTIONS_NAV_AUTO_ONCOMPLETE_TITLE"],
					desc = L["OPTIONS_NAV_AUTO_ONCOMPLETE_DESC"],
					get = function () return MinArch.db.profile.TomTom.autoWayOnComplete end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.autoWayOnComplete = newValue;
					end,
					disabled = function () return (Navigation:IsNavigationEnabled() == false) end,
					order = 2,
                },
				ignoreHidden = {
					type = "toggle",
					name = L["OPTIONS_NAV_AUTO_IGNOREHIDDEN_TITLE"],
					desc = L["OPTIONS_NAV_AUTO_IGNOREHIDDEN_DESC"],
					get = function () return MinArch.db.profile.TomTom.ignoreHidden end,
                    set = function (_, newValue)
						MinArch.db.profile.TomTom.ignoreHidden = newValue;
					end,
                    disabled = function () return (Navigation:IsNavigationEnabled() == false) end,
					order = 4,
                },
				message = {
					type = "description",
					name = L["OPTIONS_NAV_AUTO_PRIORITY_NOTE"],
					fontSize = "normal",
					width = "full",
					order = 5,
				},
			},
		},
		taxi = {
			type = 'group',
			name = L["OPTIONS_NAV_TAXI_TITLE"],
			inline = true,
			order = 4,
			args = {
				enable = {
					type = "toggle",
					name = L["OPTIONS_NAV_TAXI_ENABLE_TITLE"],
					desc = L["OPTIONS_NAV_TAXI_ENABLE_DESC"],
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
					name = L["OPTIONS_NAV_TAXI_DISTANCE_TITLE"],
					desc = L["OPTIONS_NAV_TAXI_DISTANCE_DESC"],
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
					name = L["OPTIONS_NAV_TAXI_PINOPA_TITLE"],
					desc = L["OPTIONS_NAV_TAXI_PINOPA_DESC"],
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
					name = L["OPTIONS_NAV_TAXI_AUTOENABLE_TITLE"],
					desc = L["OPTIONS_NAV_TAXI_AUTOENABLE_DESC"],
					get = function () return MinArch.db.profile.TomTom.taxi.autoEnableArchMode end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.taxi.autoEnableArchMode = newValue;
					end,
					order = 5,
				},
				disableOnLogin = {
					type = "toggle",
					name = L["OPTIONS_NAV_TAXI_AUTODISABLE_TITLE"],
					desc = L["OPTIONS_NAV_TAXI_AUTODISABLE_DESC"],
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
	name = L["OPTIONS_PATRONS_TITLE"],
	handler = MinArch,
	type = "group",
	args = {
		message = {
            type = "description",
            name = L["OPTIONS_PATRONS_DESC"],
            fontSize = "normal",
            width = "full",
            order = 1,
        },
		patrons = {
			type = "group",
			name = L["OPTIONS_PATRONS_SUBTITLE"],
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
                            return L["OPTIONS_RACE_HIDE_THE"]..MinArch['artifacts'][i]['race']..L["OPTIONS_RACE_HIDE_EVEN"]
                        end,
                        order = i,
                        get = function () return MinArch.db.profile.raceOptions.hide[i] end,
                        set = function (_, newValue)
                            MinArch.db.profile.raceOptions.hide[i] = newValue;
                            Main:Update();
                        end,
                    };
                    raceSettings.args.cap.args[groupkey].args['race' .. tostring(i)] = {
                        type = "toggle",
                        name = function () return GetArchaeologyRaceInfo(i) end,
                        desc = function ()
                            return L["OPTIONS_RACE_CAP_USE"]..MinArch['artifacts'][i]['race']..L["OPTIONS_RACE_CAP_USE_FOR"]
                        end,
                        order = i,
                        get = function () return MinArch.db.profile.raceOptions.cap[i] end,
                        set = function (_, newValue)
                            MinArch.db.profile.raceOptions.cap[i] = newValue;
                            Main:Update();
                        end,
                    };
                    raceSettings.args.keystone.args[groupkey].args['race' .. tostring(i)] = {
                        type = "toggle",
                        name = function () return GetArchaeologyRaceInfo(i) end,
                        desc = function ()
                            local RuneName, _, _, _, _, _, _, _, _, _ = C_Item.GetItemInfo(MinArch['artifacts'][i]['raceitemid']);
                            local RaceName = MinArch['artifacts'][i]['race'];

                            if (RuneName ~= nil and RaceName ~= nil) then
                                return L["OPTIONS_RACE_CAP_ALWAYS"]..RuneName..L["OPTIONS_RACE_CAP_ALWAYS_USE_TO_SOLVE"]..RaceName..L["OPTIONS_RACE_CAP_ALWAYS_USE"];
                            end
                        end,
                        order = i,
                        get = function () return MinArch.db.profile.raceOptions.keystone[i] end,
                        set = function (_, newValue)
                            MinArch.db.profile.raceOptions.keystone[i] = newValue;
                            Main:Update();
                        end,
                        disabled = (i == ARCHAEOLOGY_RACE_FOSSIL)
                    };
					raceSettings.args.priority.args[groupkey].args['race' .. tostring(i)] = {
                        type = "select",
						values = values,
                        name = function ()
							local suffix = ''
							if i == ARCHAEOLOGY_RACE_NERUBIAN then
								suffix = L["OPTIONS_RACE_AFFECTS_BOTH"]
							end
							return MinArch['artifacts'][i]['race'] .. suffix
						end,
                        desc = function ()
                            local RaceName = MinArch['artifacts'][i]['race'];

                            if (RaceName ~= nil) then
                                return L["OPTIONS_RACE_SET"] .. RaceName .. L["OPTIONS_RACE_SET_PRIORITY"];
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
                            Main:Update();
                        end,
                    };
                end
            end

            count = count + 1;

			if group == #ArchRaceGroups then
				raceSettings.args.keystone.args[groupkey].args['note'] = {
					type = "description",
					name = L["OPTIONS_RACE_CAP_KEYSTONE_FOSSIL_NOTE"],
					fontSize = "medium",
					width = "full",
					order = 99,
				}
			end
        end
	end

	self:RegisterMenus();
end

function Options:RegisterMenus()
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch", home);
	self.menu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch", L["OPTIONS_REGISTER_MINARCH"]);

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(L["OPTIONS_REGISTER_MINARCH_GENERAL_TITLE"], general);
	self.general = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(L["OPTIONS_REGISTER_MINARCH_GENERAL_TITLE"], L["OPTIONS_REGISTER_MINARCH_GENERAL_SUBTITLE"], L["OPTIONS_REGISTER_MINARCH"]);

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(L["OPTIONS_REGISTER_MINARCH_COMPANION_TITLE"], companionSettings);
	self.companionSettings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(L["OPTIONS_REGISTER_MINARCH_COMPANION_TITLE"], L["OPTIONS_REGISTER_MINARCH_COMPANION_SUBTITLE"], L["OPTIONS_REGISTER_MINARCH"]);

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(L["OPTIONS_REGISTER_MINARCH_RACE_TITLE"], raceSettings);
	self.raceSettings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(L["OPTIONS_REGISTER_MINARCH_RACE_TITLE"], L["OPTIONS_REGISTER_MINARCH_RACE_SUBTITLE"], L["OPTIONS_REGISTER_MINARCH"]);

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(L["OPTIONS_REGISTER_MINARCH_NAV_TITLE"], TomTomSettings);
	self.TomTomSettings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(L["OPTIONS_REGISTER_MINARCH_NAV_TITLE"], L["OPTIONS_REGISTER_MINARCH_NAV_SUBTITLE"], L["OPTIONS_REGISTER_MINARCH"]);

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(L["OPTIONS_REGISTER_MINARCH_DEV_TITLE"], devSettings);
    self.devSettings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(L["OPTIONS_REGISTER_MINARCH_DEV_TITLE"], L["OPTIONS_REGISTER_MINARCH_DEV_SUBTITLE"], L["OPTIONS_REGISTER_MINARCH"]);

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(L["OPTIONS_REGISTER_MINARCH_PATRONS_TITLE"], PatronSettings);
    self.patrons = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(L["OPTIONS_REGISTER_MINARCH_PATRONS_TITLE"], L["OPTIONS_REGISTER_MINARCH_PATRONS_SUBTITLE"], L["OPTIONS_REGISTER_MINARCH"]);

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(L["OPTIONS_REGISTER_MINARCH_PROFILES_TITLE"], LibStub("AceDBOptions-3.0"):GetOptionsTable(MinArch.db));
    self.profiles = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(L["OPTIONS_REGISTER_MINARCH_PROFILES_TITLE"], L["OPTIONS_REGISTER_MINARCH_PROFILES_SUBTITLE"], L["OPTIONS_REGISTER_MINARCH"]);
end
