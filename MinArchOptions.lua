-- Options Panel Functions

function MinArch:OptionsLoad()
	MinArchOptionPanel.AddonName:SetText("Minimal Archaeology");
	MinArchOptionPanel.AddonVersion:SetText(GetAddOnMetadata("MinimalArchaeology", "Version"));
	MinArchOptionPanel.name = "Minimal Archaeology";
	
	MinArchOptionPanel.hideArtifact.title:SetText("Hide");
	MinArchOptionPanel.useKeystones.title:SetText("Auto Keystones");
	MinArchOptionPanel.miscOptions.title:SetText("Miscellaneous Options");
	
	MinArchOptionPanelFrameScale.title:SetText("Scale");
	MinArchOptionPanelFrameScaleSliderLow:SetText("30");
	MinArchOptionPanelFrameScaleSliderHigh:SetText("100");
	MinArchOptionPanel.frameScale.slider:SetMinMaxValues(30, 100);
	MinArchOptionPanel.frameScale.slider:SetValueStep(5);
	
	MinArchOptionPanel.okay = MinArchOptionPanel:Hide();
	MinArchOptionPanel.cancel = MinArchOptionPanel:Hide();
		
	InterfaceOptions_AddCategory(MinArchOptionPanel);
end

function MinArch:HideOptionToolTip(HideID)
	if (MinArchIsReady == true) then
		GameTooltip:SetOwner(MinArchOptionPanel.hideArtifact, "ANCHOR_TOPLEFT");
		GameTooltip:AddLine("Hide the "..MinArch['artifacts'][HideID]['race'].." artifact bar even if it has been discovered.", 1.0, 1.0, 1.0, 1);
		GameTooltip:Show();
	end
end

function MinArch:UseKeystoneOptionToolTip(UseKeystoneID)
	if (MinArchIsReady == true) then
		local RuneName, _, _, _, _, _, _, _, _, _ = GetItemInfo(MinArch['artifacts'][UseKeystoneID]['raceitemid']);
		local RaceName = MinArch['artifacts'][UseKeystoneID]['race'];
		
		if (RuneName ~= nil and RaceName ~= nil) then
			GameTooltip:SetOwner(MinArchOptionPanel.useKeystones, "ANCHOR_TOPLEFT");
			GameTooltip:AddLine("Always use all available "..RuneName.."s to solve "..RaceName.." artifacts.", 1.0, 1.0, 1.0, 1);
			GameTooltip:Show();
		end
	end
end

function MinArch:MiscOptionToolTip(MiscID)
	GameTooltip:SetOwner(MinArchOptionPanel.miscOptions, "ANCHOR_TOPLEFT");
	
	if (MiscID == 4) then
		GameTooltip:AddLine("Hide Minimal Archaeology after completing a digsite.", 1.0, 1.0, 1.0, 1);
	elseif (MiscID == 5) then
		GameTooltip:AddLine("Wait until all artifacts are solved before auto-hiding.", 1.0, 1.0, 1.0, 1);
	elseif (MiscID == 6) then
		GameTooltip:AddLine("Show Minimal Archaeology status messages in the chat.", 1.0, 1.0, 1.0, 1);
    elseif (MiscID == 7) then
		GameTooltip:AddLine("Show race icons next to digsites on the world map.", 1.0, 1.0, 1.0, 1);
	end
	
	GameTooltip:Show();
end

function MinArch:HideOptionToggle()
	if (MinArchIsReady == true) then
		for i=1, ARCHAEOLOGY_NUM_RACES do
			MinArchOptions['ABOptions'][i]['Hide'] = MinArchOptionPanel.hideArtifact["hide"..i]:GetChecked()
		end
	end
	MinArch:UpdateMain();
end

function MinArch:UseKeystoneOptionToggle()
	if (MinArchIsReady == true) then
		for i=1, ARCHAEOLOGY_NUM_RACES do
			if (i ~= ARCHAEOLOGY_RACE_FOSSIL) then -- no keystones for fossils
				MinArchOptions['ABOptions'][i]['AlwaysUseKeystone'] = MinArchOptionPanel.useKeystones["usekeystone"..i]:GetChecked()
			end
		end
	end
	MinArch:UpdateMain();
end

function MinArch:MiscOptionsToggle()
	if (MinArchIsReady == true) then
		-- Show status messages
		MinArchOptions['ShowStatusMessages'] = MinArchOptionPanel.miscOptions.showStatusMessages:GetChecked()

		-- Show world map overlay icons
		MinArchOptions['ShowWorldMapOverlay'] = MinArchOptionPanel.miscOptions.showWorldMapOverlay:GetChecked()
		MinArch:ShowRaceIconsOnMap(MinArch['activeUiMapID']);

		-- Hide after completing a digsite
		MinArchOptions['HideAfterDigsite'] = MinArchOptionPanel.miscOptions.hideAfter:GetChecked()
		if MinArchOptions['HideAfterDigsite'] then
			MinArchOptionPanel.miscOptions.waitSolve:Enable();
			MinArchOptionPanel.miscOptions.waitSolve.text:SetAlpha(1.0);
		else
			MinArchOptionPanel.miscOptions.waitSolve:Disable();
			MinArchOptionPanel.miscOptions.waitSolve.text:SetAlpha(0.5);
		end
		
		-- Wait to solve artifacts
		MinArchOptions['WaitForSolve'] = MinArchOptionPanel.miscOptions.waitSolve:GetChecked()
	end
end

function MinArch:ScaleOptionsAdjust()
	if (MinArchIsReady == true) then
		MinArchOptions['FrameScale'] = MinArchOptionPanel.frameScale.slider:GetValue();
		MinArchOptionPanelFrameScaleSliderText:SetText(tostring(MinArchOptions['FrameScale']));		
		MinArch:CommonFrameScale(MinArchOptions['FrameScale']);
	end
end

function MinArch:OpenOptions()
	if (MinArchIsReady == true) then
		MinArch:UpdateMain();
		for i=1, ARCHAEOLOGY_NUM_RACES do
			MinArchOptionPanel.hideArtifact["hide"..i].text:SetText(MinArch['artifacts'][i]['race']);
			MinArchOptionPanel.hideArtifact["hide"..i]:SetChecked(MinArchOptions['ABOptions'][i]['Hide']);
						
			if (i ~= ARCHAEOLOGY_RACE_FOSSIL) then
				MinArchOptionPanel.useKeystones["usekeystone"..i].text:SetText(MinArch['artifacts'][i]['race']);
				MinArchOptionPanel.useKeystones["usekeystone"..i]:SetChecked(MinArchOptions['ABOptions'][i]['AlwaysUseKeystone']);
			end
		end
		
		-- Misc Options
		MinArchOptionPanel.miscOptions.showStatusMessages.text:SetText("Show status messages");
		MinArchOptionPanel.miscOptions.showStatusMessages:SetChecked(MinArchOptions['ShowStatusMessages']);

		MinArchOptionPanel.miscOptions.showWorldMapOverlay.text:SetText("Show world map overlay icons");
		MinArchOptionPanel.miscOptions.showWorldMapOverlay:SetChecked(MinArchOptions['ShowWorldMapOverlay']);

		MinArchOptionPanel.miscOptions.hideAfter.text:SetText("Auto-Hide After Digsites");
		MinArchOptionPanel.miscOptions.hideAfter:SetChecked(MinArchOptions['HideAfterDigsite']);
	
		MinArchOptionPanel.miscOptions.waitSolve.text:SetText("Wait to Solve Artifacts");
		if (MinArchOptions['HideAfterDigsite'] == false) then
			MinArchOptionPanel.miscOptions.waitSolve:Disable();			
			MinArchOptionPanel.miscOptions.waitSolve.text:SetAlpha(0.5);
		end
		MinArchOptionPanel.miscOptions.waitSolve:SetChecked(MinArchOptions['WaitForSolve']);
		
		-- Scale
		MinArchOptionPanelFrameScaleSliderText:SetText(tostring(MinArchOptions['FrameScale']));
		MinArchOptionPanel.frameScale.slider:SetValue(MinArchOptions['FrameScale']);
	end
end

-- New Code starts here

function MinArch:CapOptionToggle()
	if (MinArchIsReady == true) then
		for i=1, ARCHAEOLOGY_NUM_RACES do
			MinArchOptions['ABOptions'][i]['Cap'] = MinArch.db.profile.raceOptions.cap[i]
		end
	end
	MinArch:UpdateMain();
end

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
			type = 'group',
			name = 'Hide',
			order = 1,
			inline = false,
			args = {
			}
		},
		cap = {
			type = 'group',
			name = 'Cap',
			order = 2,
			inline = false,
			args = {
			}
		},
		keystone = {
			type = 'group',
			name = 'Keystone',
			order = 3,
			inline = false,
			args = {
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
	{ARCHAEOLOGY_RACE_TROLL, ARCHAEOLOGY_RACE_NIGHTELF, ARCHAEOLOGY_RACE_FOSSIL, ARCHAEOLOGY_RACE_DRAENEI, ARCHAEOLOGY_RACE_DWARF}
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
		}
		raceSettings.args.cap.args[groupkey] = {
			type = 'group',
			name = ArchRaceGroupText[group],
			order = count,
			inline = true,
			args = {

			}
		}
		raceSettings.args.keystone.args[groupkey] = {
			type = 'group',
			name = ArchRaceGroupText[group],
			order = count,
			inline = true,
			args = {

			}
		}
		
		for idx=1, #races do
			local i = races[idx];
			raceSettings.args.hide.args[groupkey].args['race' .. tostring(i)] = {
				type = "toggle",
				name = function () return GetArchaeologyRaceInfo(i) end,
				desc = "Hide ",
				order = i,
				get = function () return MinArch.db.profile.raceOptions.hide[i] end,
				set = function (_, newValue)
					MinArch.db.profile.raceOptions.hide[i] = newValue;
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
					MinArch:CapOptionToggle();
				end,
			};
			raceSettings.args.keystone.args[groupkey].args['race' .. tostring(i)] = {
				type = "toggle",
				name = function () return GetArchaeologyRaceInfo(i) end,
				desc = "keystone",
				order = i,
				get = function () return MinArch.db.profile.raceOptions.keystone[i] end,
				set = function (_, newValue)
					MinArch.db.profile.raceOptions.keystone[i] = newValue;
				end,
				disabled = (i == ARCHAEOLOGY_RACE_FOSSIL)
			};
		end

		count = count + 1;
	end

	--[[for i=1, ARCHAEOLOGY_NUM_RACES do
		-- local name = GetArchaeologyRaceInfo(i);
		
	end]]--
	
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