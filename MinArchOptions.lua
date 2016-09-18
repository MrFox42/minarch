-- Options Panel Functions

function MinArch:OptionsLoad()
	MinArchOptionPanel.AddonName:SetText("Minimal Archaeology");
	MinArchOptionPanel.AddonVersion:SetText(GetAddOnMetadata("MinimalArchaeology", "Version"));
	MinArchOptionPanel.name = "Minimal Archaeology";
	
	MinArchOptionPanel.hideArtifact.title:SetText("Hide");
	MinArchOptionPanel.capArtifact.title:SetText("Fragment Cap");
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

function MinArch:CapOptionToolTip(CapID)
	if (MinArchIsReady == true) then
		GameTooltip:SetOwner(MinArchOptionPanel.capArtifact, "ANCHOR_TOPLEFT");
		GameTooltip:AddLine("Use the fragment cap for the "..MinArch['artifacts'][CapID]['race'].." artifact bar.", 1.0, 1.0, 1.0, 1);
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
	
	if (MiscID == 1) then
		GameTooltip:AddLine("Hide the Minimap button.", 1.0, 1.0, 1.0, 1);
	elseif (MiscID == 2) then
		GameTooltip:AddLine("Disable the sound that is played when an artifact can be solved.", 1.0, 1.0, 1.0, 1);
	elseif (MiscID == 3) then
		GameTooltip:AddLine("Always start Minimal Archaeology hidden.", 1.0, 1.0, 1.0, 1);
	elseif (MiscID == 4) then
		GameTooltip:AddLine("Hide Minimal Archaeology after completing a digsite.", 1.0, 1.0, 1.0, 1);
	elseif (MiscID == 5) then
		GameTooltip:AddLine("Wait until all artifacts are solved before auto-hiding.", 1.0, 1.0, 1.0, 1);
	end
	
	GameTooltip:Show();
end

function MinArch:HideOptionToggle()
	if (MinArchIsReady == true) then
		for i=1, 18 do
			MinArchOptions['ABOptions'][i]['Hide'] = MinArchOptionPanel.hideArtifact["hide"..i]:GetChecked()
		end
	end
	MinArch:UpdateMain();
end

function MinArch:CapOptionToggle()
	if (MinArchIsReady == true) then
		for i=1, 18 do
			MinArchOptions['ABOptions'][i]['Cap'] = MinArchOptionPanel.capArtifact["cap"..i]:GetChecked()
		end
	end
	MinArch:UpdateMain();
end

function MinArch:UseKeystoneOptionToggle()
	if (MinArchIsReady == true) then
		for i=1, 18 do
			if (i ~= ARCHAEOLOGY_RACE_FOSSIL) then -- no keystones for fossils
				MinArchOptions['ABOptions'][i]['AlwaysUseKeystone'] = MinArchOptionPanel.useKeystones["usekeystone"..i]:GetChecked()
			end
		end
	end
	MinArch:UpdateMain();
end

function MinArch:MiscOptionsToggle()
	if (MinArchIsReady == true) then
		-- Hide Minimap button
		MinArchOptions['HideMinimap'] = MinArchOptionPanel.miscOptions.hideMinimap:GetChecked()
		if MinArchOptions['HideMinimap'] then
			MinArchMinimapButton:Hide();
		else
			MinArchMinimapButton:Show();
		end
		
		-- Disable Sound
		MinArchOptions['DisableSound'] = MinArchOptionPanel.miscOptions.disableSound:GetChecked()
		
		-- Start hidden
		MinArchOptions['StartHidden'] = MinArchOptionPanel.miscOptions.startHidden:GetChecked()
		
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
		for i=1, 18 do
			MinArchOptionPanel.hideArtifact["hide"..i].text:SetText(MinArch['artifacts'][i]['race']);
			MinArchOptionPanel.hideArtifact["hide"..i]:SetChecked(MinArchOptions['ABOptions'][i]['Hide']);
			
			MinArchOptionPanel.capArtifact["cap"..i].text:SetText(MinArch['artifacts'][i]['race']);
			MinArchOptionPanel.capArtifact["cap"..i]:SetChecked(MinArchOptions['ABOptions'][i]['Cap']);
			
			if (i ~= ARCHAEOLOGY_RACE_FOSSIL) then
				MinArchOptionPanel.useKeystones["usekeystone"..i].text:SetText(MinArch['artifacts'][i]['race']);
				MinArchOptionPanel.useKeystones["usekeystone"..i]:SetChecked(MinArchOptions['ABOptions'][i]['AlwaysUseKeystone']);
			end
		end
		
		-- Misc Options
		MinArchOptionPanel.miscOptions.hideMinimap.text:SetText("Hide the Minimap Button");
		MinArchOptionPanel.miscOptions.hideMinimap:SetChecked(MinArchOptions['HideMinimap']);
		
		MinArchOptionPanel.miscOptions.disableSound.text:SetText("Disable Sound");
		MinArchOptionPanel.miscOptions.disableSound:SetChecked(MinArchOptions['DisableSound']);

		MinArchOptionPanel.miscOptions.startHidden.text:SetText("Always Start Hidden");
		MinArchOptionPanel.miscOptions.startHidden:SetChecked(MinArchOptions['StartHidden']);

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
