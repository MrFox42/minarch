assert(MinArch);
MinArch.Options = MinArch:NewModule("Options");

local Options = MinArch.Options;
local parent = MinArch;

local general = {
	name = "Minimal Archaeology v" .. GetAddOnMetadata("MinimalArchaeology", "Version"),
	handler = MinArch,
	type = "group",
	args = {
		welcome = {
			type = "group",
			name = "Welcome!",
			order = 1,
			inline = true,
			args = {
				message = {
					type = "description",
					name = "Thanks for using Minimal Archaeology",
					fontSize = "small",
					width = "full",
					order = 1,
				},
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
					name = "TomTom Settings",
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
		misc = {
			type = 'group',
			name = 'Miscellaneous options',
			inline = true,
			order = 2,
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
            order = 3,
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
					order = 4,
				},
            }
		},
		autoHide = {
			type = "group",
			name = "Auto-hide main window",
			inline = true,
			order = 4,
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
			order = 5,
			args = {
				autoShowInDigsites = {
					type = "toggle",
					name = "Show in digsites",
					desc = "Auto-show Minimal Archaeology when moving around in a digsite.",
					get = function () return MinArch.db.profile.autoShowInDigsites end,
					set = function (_, newValue)
						MinArch.db.profile.autoShowInDigsites = newValue;
						MinArchShowInDigsite = true;
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
						MinArchShowOnSurvey = true;
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
		}
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
							name = "Continent-specific",
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
			name = "Cap",
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
					width = "full",
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
        message = {
            type = "description",
            name = "More features and customizations coming soon! Please feel free to provide feedback so I can prioritize features based on interest.",
            fontSize = "medium",
            width = "full",
            order = 100,
        },
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
		tomtom = {
			type = 'group',
			name = 'TomTom Options',
			inline = true,
			order = 1,
			disabled = function () return (MinArch.TomTomAvailable == false) end,
			args = {
				enable = {
					type = "toggle",
					name = "Enable TomTom integration in MinArch",
					desc = "Toggles TomTom integration in MinArch. Disabling TomTom integration will remove all waypoints created by MinArch",
					width = "full",
					get = function () return MinArch.db.profile.TomTom.enable end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.enable = newValue;

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
					disabled = function () return (MinArch.db.profile.TomTom.enable == false) end,
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
					disabled = function () return (MinArch.db.profile.TomTom.enable == false) end,
					order = 3,
				},
			},
		},
		autoway = {
			type = 'group',
			name = 'Automatically create waypoints for the closest digsite.',
			inline = true,
			order = 2,
			args = {
				autoWayOnMove = {
					type = "toggle",
					name = "Continuously",
					desc = "Continuously create/update the automatic waypoint to the closest digsite.",
					get = function () return MinArch.db.profile.TomTom.autoWayOnMove end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.autoWayOnMove = newValue;
					end,
					disabled = function () return (MinArch.db.profile.TomTom.enable == false) end,
					order = 1,
				},
				autoWayOnComplete = {
					type = "toggle",
					name = "When completed",
					desc = "Automatically create a waypoint to the closest digsite after completing one.",
					get = function () return MinArch.db.profile.TomTom.autoWayOnComplete end,
					set = function (_, newValue)
						MinArch.db.profile.TomTom.prio = newValue;
					end,
					disabled = function () return (MinArch.db.profile.TomTom.enable == false) end,
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
                    disabled = function () return (MinArch.db.profile.TomTom.enable == false) end,
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

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch TomTom Settings", TomTomSettings);
	self.TomTomSettings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch TomTom Settings", "TomTom Settings", "Minimal Archaeology");

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch Developer Settings", devSettings);
    self.devSettings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch Developer Settings", "Developer Settings", "Minimal Archaeology");

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(parent.db));
    self.profiles = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch Profiles", "Profiles", "Minimal Archaeology");
end
