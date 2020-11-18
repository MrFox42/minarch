local ADDON, MinArch = ...

MinArch.Options = MinArch.Ace:NewModule("Options");

local Options = MinArch.Options;
local parent = MinArch;

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

local general = {
	name = "Minimal Archaeology v" .. GetAddOnMetadata("MinimalArchaeology", "Version"),
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
		welcome = {
			type = "group",
			name = "Settings",
			order = 2,
			inline = true,
			args = {
				raceButton = {
					type = "execute",
					name = "Race Settings",
					order = 2,
					func = function ()
						InterfaceOptionsFrame_OpenToCategory(MinArch.Options.raceSettings);
					end,
                },
                companionButton = {
					type = "execute",
					name = "Companion Settings",
					order = 3,
					func = function ()
						InterfaceOptionsFrame_OpenToCategory(MinArch.Options.companionSettings);
					end,
				},
				TomTomButton = {
					type = "execute",
					name = "Navigation Settings",
					order = 4,
					func = function ()
						InterfaceOptionsFrame_OpenToCategory(MinArch.Options.TomTomSettings);
					end,
				},
				deBbutton = {
					type = "execute",
					name = "Dev Settings",
					order = 5,
					func = function ()
						InterfaceOptionsFrame_OpenToCategory(MinArch.Options.devSettings);
					end,
				},
			}
        },
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
            }
        },
		misc = {
			type = 'group',
			name = 'Miscellaneous options',
			inline = true,
			order = 4,
			args = {
				hideMinimapButton = {
					type = "toggle",
					name = "Hide Minimap Button",
					desc = "Hide the minimap button",
					get = function () return MinArch.db.profile.minimap.hide end,
					set = function (_, newValue)
						MinArch.db.profile.minimap.hide = newValue;

						MinArch:RefreshMinimapButton();
					end,
					order = 1,
				},
				disableSound = {
					type = "toggle",
					name = "Disable Sound",
					desc = "Disable the sound that is played when an artifact can be solved.",
					get = function () return MinArch.db.profile.disableSound end,
					set = function (_, newValue)
						MinArch.db.profile.disableSound = newValue;
					end,
					order = 2,
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
				scale = {
					type = "range",
					name = "Scale",
					desc = "...",
					min = 30,
					max = 200,
					step = 5,
					get = function () return MinArch.db.profile.frameScale end,
					set = function (_, newValue)
						MinArch.db.profile.frameScale = newValue;
						MinArch:CommonFrameScale(newValue);
					end,
					order = 99,
				}
			}
        },
        startup = {
            type = "group",
            name = "Startup settings",
            inline = true,
            order = 5,
            args = {
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
				hideAfterDigsite = {
					type = "toggle",
					name = "Auto-hide after digsites",
					desc = "Hide Minimal Archaeology after completing a digsite.",
					get = function () return MinArch.db.profile.hideAfterDigsite end,
					set = function (_, newValue)
						MinArch.db.profile.hideAfterDigsite = newValue;
					end,
					order = 1,
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
					order = 2
				},
				hideInCombat = {
					type = "toggle",
					name = "Auto-hide in combat",
					desc = "Hide Minimal Archaeology when combat starts, and re-open it after combat.",
					get = function () return MinArch.db.profile.hideInCombat end,
					set = function (_, newValue)
						MinArch.db.profile.hideInCombat = newValue;
					end,
					order = 3,
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
							name = "Hide irrelevant solves for fragment-capped races",
							desc = "Enable to treat fragment-capped races as irrelevant when they have a solve available, but they would be irrelevant based on other relevancy settings.",
							get = function () return MinArch.db.profile.relevancy.hideCapped end,
							set = function (_, newValue)
								MinArch.db.profile.relevancy.hideCapped = newValue;
                                MinArch:UpdateMain();
                            end,
                            width = 2,
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
			}
		},
		cap = {
			type = "group",
			name = "Fragment-Cap",
			order = 3,
			inline = false,
			args = {
                solveConfirmation = {
                    width = "full",
					type = "toggle",
					name = "Show confirmation for fragment-capped solves",
					desc = "Show confirmation before solving artifacts for fragment-capped races",
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
			name = "Keystone",
			order = 4,
			inline = false,
			args = {
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
			name = "General settings!",
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
					desc = "Enable to always show regardless of other options (except in instances and in combat).",
					get = function () return MinArch.db.profile.companion.alwaysShow end,
					set = function (_, newValue)
                        MinArch.db.profile.companion.alwaysShow = newValue;
                        MinArch.Companion:AutoToggle()
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false) end,
					order = 2,
                },
                hrC = {
                    type = "description",
                    name = "|nColoring",
                    width = "full",
                    order = 3,
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
                    order = 4,
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
                    order = 5,
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
                    name = "Scale",
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
                            Companion:SavePosition()
                        end
                    end,
                    disabled = function () return (MinArch.db.profile.companion.enable == false or MinArch.db.profile.companion.savePos == false) end,
					order = 5,
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
                            values = {1, 2, 3, 4, 5},
                            get = function () return MinArch.db.profile.companion.features.distanceTracker.order end,
                            set = function (info, newValue)
                                updateOrdering("distanceTracker", newValue)
                            end,
                            width = 0.5,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 2,
                        },
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
                            values = {1, 2, 3, 4, 5},
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
                            values = {1, 2, 3, 4, 5},
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
                            values = {1, 2, 3, 4, 5},
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
                            name = "For relevant only",
                            desc = "Enable to only show solves for relevant races",
                            width = "full",
                            get = function () return MinArch.db.profile.companion.relevantOnly end,
                            set = function (_, newValue)
                                MinArch.db.profile.companion.relevantOnly = newValue;
                                MinArch.Companion:Update();
                            end,
                            disabled = function () return (MinArch.db.profile.companion.enable == false) end,
                            order = 53,
                        },
                    }
                },
                crateButton = {
                    type = "group",
                    name = "Distance Tracker settings",
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
                            values = {1, 2, 3, 4, 5},
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


            }
        }
    }
}

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
	{ARCHAEOLOGY_RACE_TOLVIR, ARCHAEOLOGY_RACE_TROLL, ARCHAEOLOGY_RACE_NIGHTELF, ARCHAEOLOGY_RACE_FOSSIL, ARCHAEOLOGY_RACE_DWARF}
};

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
					desc = "Enable to create a map pin over digsites.",
					get = function () return MinArch.db.profile.TomTom.enableBlizzWaypoint end,
					set = function (_, newValue)
                        MinArch.db.profile.TomTom.enableBlizzWaypoint = newValue;
                        if MinArch.db.char.TomTom.uiMapPoint and not newValue then
                            MinArch:ClearUiWaypoint()
                        end
					end,
					order = 2,
                },
                superTrack = {
					type = "toggle",
					name = "Show floating pin",
					desc = "Enable to show the floating pin over the destination.",
					get = function () return MinArch.db.profile.TomTom.superTrack end,
					set = function (_, newValue)
                        MinArch.db.profile.TomTom.superTrack = newValue;
                        if MinArch.db.char.TomTom.uiMapPoint then
                            C_SuperTrack.SetSuperTrackedUserWaypoint(newValue);
                        end
					end,
					disabled = function () return (MinArch.db.profile.TomTom.enableBlizzWaypoint == false) end,
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
                prioRace = {
                    type = "select",
                    values = function ()
                        local raceSelectTable = {}
                        raceSelectTable[-1] = 'Do not Prioritize';
                        for i=1,ARCHAEOLOGY_NUM_RACES do
                            raceSelectTable[i] = GetArchaeologyRaceInfo(i);
                        end

                        return raceSelectTable
                    end,
					name = "Prioritize a Race",
                    desc = "Select a race to prioritize, even if there are closer digsites with different races.",
                    get = function () return MinArch.db.profile.TomTom.prioRace end,
                    set = function (_, newValue)
						MinArch.db.profile.TomTom.prioRace = newValue;
					end,
                    disabled = function () return (MinArch:IsNavigationEnabled() == false) end,
                    order = 3,
                },
			},
		},
	}
}

function Options:OnInitialize()
	local count = 1;
	for group, races in pairs(ArchRaceGroups) do
		local groupkey = 'group' .. tostring(group);

		raceSettings.args.hide.args[groupkey] = {
			type = 'group',
			name = ArchRaceGroupText[group],
			order = count + 1,
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
		for idx=1, #races do
			local i = races[idx];
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
					local RuneName, _, _, _, _, _, _, _, _, _ = GetItemInfo(MinArch['artifacts'][i]['raceitemid']);
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
		end

		count = count + 1;
	end

	self:RegisterMenus();
end

function Options:RegisterMenus()
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch", general);
	self.menu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch", "Minimal Archaeology");

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch Race Settings", raceSettings);
	self.raceSettings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch Race Settings", "Race Settings", "Minimal Archaeology");

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch Companion Settings", companionSettings);
	self.companionSettings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch Companion Settings", "Companion Settings", "Minimal Archaeology");

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch Navigation Settings", TomTomSettings);
	self.TomTomSettings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch Navigation Settings", "Navigation Settings", "Minimal Archaeology");

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch Developer Settings", devSettings);
    self.devSettings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch Developer Settings", "Developer Settings", "Minimal Archaeology");

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(parent.db));
    self.profiles = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch Profiles", "Profiles", "Minimal Archaeology");
end
