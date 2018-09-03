assert(MinArch);
MinArch.Options = MinArch:NewModule("Options");

local Options = MinArch.Options;
local parent = MinArch;

local general = {
	name = "Minimal Archaeology",
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
					get = function () return MinArch.db.profile.hideMinimapButton end,
					set = function (_, newValue)
						MinArch.db.profile.hideMinimapButton = newValue;

						if newValue then
							MinArchMinimapButton:Hide();
						else
							MinArchMinimapButton:Show();
						end
					end,
					order = 1,
				},
				--MinArch.db.profile.disableSound
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
				showWorldMapOverlay = {
					type = "toggle",
					name = "Show world map overlay icons",
					desc = "Show race icons next to dig sites on the world map.",
					get = function () return MinArch.db.profile.showWorldMapOverlay end,
					set = function (_, newValue)
						MinArch.db.profile.showWorldMapOverlay = newValue;
						MinArch:ShowRaceIconsOnMap(MinArch['activeUiMapID']);
					end,
					width = "double",
					order = 4,
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
		autoHide = {
			type = 'group',
			name = 'Auto-hide main window',
			inline = true,
			order = 3,
			args = {
				hideAfterDigsite = {
					type = "toggle",
					name = "Auto-hide after dig sites",
					desc = "Hide Minimal Archaeology after completing a dig site.",
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
				}
			}
		},
		autoShow = {
			type = 'group',
			name = 'Auto-show main window',
			inline = true,
			order = 4,
			args = {
				autoShowOnSurvey = {
					type = "toggle",
					name = "Show when surveying",
					desc = "Auto-show Minimal Archaeology when surveying in a dig site.",
					get = function () return MinArch.db.profile.autoShowOnSurvey end,
					set = function (_, newValue)
						MinArch.db.profile.autoShowOnSurvey = newValue;
						MinArchShowOnSurvey = true;
					end,
					order = 1,
				},
				autoShowOnSolve = {
					type = "toggle",
					name = "Show for solves",
					desc = "Auto-show Minimal Archaeology when a solve becomes available.",
					get = function () return MinArch.db.profile.autoShowOnSolve end,
					set = function (_, newValue)
						MinArch.db.profile.autoShowOnSolve = newValue;
					end,
					order = 2,
				},
				autoShowInDigsites = {
					type = "toggle",
					name = "Show in dig sites",
					desc = "Auto-show Minimal Archaeology when moving around in a dig site.",
					get = function () return MinArch.db.profile.autoShowInDigsites end,
					set = function (_, newValue)
						MinArch.db.profile.autoShowInDigsites = newValue;
						MinArchShowInDigsite = true;
					end,
					order = 3,
				},
			}
		},
		dev = {
			type = 'group',
			name = 'Developer Options',
			inline = true,
			order = 5,
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

local raceSettings = {
	name = "Race Settings",
	handler = MinArch,
	type = "group",	
	childGroups = "tab",
	args = {
		hide = {
			type = "group",
			name = "Hide",
			order = 1,
			inline = false,
			args = {
			}
		},
		cap = {
			type = "group",
			name = "Cap",
			order = 2,
			inline = false,
			args = {
			}
		},
		keystone = {
			type = "group",
			name = "Keystone",
			order = 3,
			inline = false,
			args = {
			}
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

function Options:OnInitialize()
	local count = 0;
	for group, races in pairs(ArchRaceGroups) do
		local groupkey = 'group' .. tostring(group);

		raceSettings.args.hide.args[groupkey] = {
			type = 'group',
			name = ArchRaceGroupText[group],
			order = count,
			inline = true,
			args = {

			}
		};
		raceSettings.args.cap.args[groupkey] = {
			type = 'group',
			name = ArchRaceGroupText[group],
			order = count,
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
    self.settings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch Race Settings", "Race Settings", "Minimal Archaeology");

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MinArch Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(parent.db));
    self.profiles = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinArch Profiles", "Profiles", "Minimal Archaeology");
end