function MinArch:UpdateArchaeologySkillBar()
	local _, _, arch = GetProfessions();
	if (arch) then
		local name, _, rank, maxRank = GetProfessionInfo(arch);
		
		if (rank ~= maxRank) then
			MinArchMain.skillBar:SetMinMaxValues(0, maxRank);
			MinArchMain.skillBar:SetValue(rank);
			MinArchMain.skillBar.text:SetText(name.." "..rank.."/"..maxRank);
		else
			MinArchMain.skillBar:Hide();
			MinArch['frame']['height'] = MinArch['frame']['defaultHeight'] - 25;
			MinArch.artifactbars[1]:SetPoint("TOP", -25, -25);
		end		
	else
		MinArchMain.skillBar:SetMinMaxValues(0, 100);
		MinArchMain.skillBar:SetValue(0);
		MinArchMain.skillBar.text:SetText(ARCHAEOLOGY_RANK_TOOLTIP);
	end
end

function MinArch:UpdateArtifact(RaceIndex)
	local numArtifacts = GetNumArtifactsByRace(RaceIndex);
	local rName, rTexture, rItemID, numFragmentsCollected = GetArchaeologyRaceInfo(RaceIndex);

	-- no data available yet?
	if numArtifacts == nil or not rName then return nil end

	MinArch['artifacts'][RaceIndex]['race'] = rName;
	MinArch['artifacts'][RaceIndex]['raceitemid'] = rItemID;
	MinArch['artifacts'][RaceIndex]['raceicon'] = rTexture;
	
	if (numArtifacts == 0) then
		MinArch['artifacts'][RaceIndex]['numKeystones'] = 0;
		MinArch['artifacts'][RaceIndex]['heldKeystones'] = 0;
		MinArch['artifacts'][RaceIndex]['progress'] = 0;
		MinArch['artifacts'][RaceIndex]['modifier'] = 0;
		MinArch['artifacts'][RaceIndex]['total'] = 0;
		MinArch['artifacts'][RaceIndex]['canSolve'] = false;
		MinArch['artifacts'][RaceIndex]['canSolvePrev'] = false;
	else
		SetSelectedArtifact(RaceIndex);
		
		-- KeyStones
		local availablekeystones = 0;
		if (MinArchOptions['ABOptions'][RaceIndex]['AlwaysUseKeystone']) then
			MinArch['artifacts'][RaceIndex]['appliedKeystones'] = 4;
		end		
		for i=1, MinArch['artifacts'][RaceIndex]['appliedKeystones'] do
			SocketItemToArtifact();			
			if (ItemAddedToArtifact(i)) then
				availablekeystones = availablekeystones + 1;
			end
		end
		
		MinArch['artifacts'][RaceIndex]['appliedKeystones'] = availablekeystones;
		
		local name, description, rarity, icon, spellDescription, numKeystones, bgTexture = GetSelectedArtifactInfo();
		local progress, modifier, total = GetArtifactProgress();
		
		MinArch['artifacts'][RaceIndex]['numKeystones'] = numKeystones;
		MinArch['artifacts'][RaceIndex]['heldKeystones'] =  GetItemCount(rItemID, false, false);
		MinArch['artifacts'][RaceIndex]['progress'] = progress;
		MinArch['artifacts'][RaceIndex]['modifier'] = modifier;
		MinArch['artifacts'][RaceIndex]['total'] = total;
		MinArch['artifacts'][RaceIndex]['canSolvePrev'] = MinArch['artifacts'][RaceIndex]['canSolve'];
		MinArch['artifacts'][RaceIndex]['canSolve'] = CanSolveArtifact();
		MinArch['artifacts'][RaceIndex]['project'] = name;
		MinArch['artifacts'][RaceIndex]['rarity'] = rarity;
		MinArch['artifacts'][RaceIndex]['description'] = description;
		MinArch['artifacts'][RaceIndex]['spelldescription'] = spellDescription;
		MinArch['artifacts'][RaceIndex]['icon'] = icon;
		MinArch['artifacts'][RaceIndex]['bg'] = bgTexture;		
	end

	return 1
end

function MinArch:UpdateArtifactBar(RaceIndex, ArtifactBar)
	if (MinArchIsReady == false) then
		return false;
	end

	local artifact = MinArch['artifacts'][RaceIndex];
	local runeName, _, _, _, _, _, _, _, _, runeStoneIconPath = GetItemInfo(artifact['raceitemid']);
	local total = artifact['total']

	if (MinArch.db.profile.raceOptions.cap[RaceIndex] == true) then
		total = 200;
		if (RaceIndex < ARCHAEOLOGY_RACE_MOGU and RaceIndex > ARCHAEOLOGY_RACE_ZANDALARI) then
			total = 250;
		end
	end
	
	ArtifactBar:SetMinMaxValues(0, total);
	ArtifactBar:SetValue(min(artifact['progress']+artifact['modifier'], total));
	
	ArtifactBar.keystone.icon:SetTexture(runeStoneIconPath);
	if (artifact['appliedKeystones'] == 0) then
		ArtifactBar.keystone.icon:SetAlpha(0.1);
	else
		ArtifactBar.keystone.icon:SetAlpha((artifact['appliedKeystones']/artifact['numKeystones']));
	end	
	
	if (artifact['numKeystones'] > 0 and artifact['total'] > 0) then
		ArtifactBar.keystone.text:SetText(artifact['appliedKeystones'].."/"..artifact['numKeystones']);
		ArtifactBar.keystone:Show();
		ArtifactBar.keystone.icon:Show();
	else
		ArtifactBar.keystone:Hide();
	end
	
	if (artifact['rarity'] == 1) then
		ArtifactBar.text:SetTextColor(0.0, 0.3922, 0.7843, 1.0);
	else
		ArtifactBar.text:SetTextColor(1.0, 1.0, 1.0, 1.0);
	end
	
	if (artifact['modifier'] > 0) then
		ArtifactBar.text:SetText(artifact['race'].." (+"..artifact['modifier']..") "..(artifact['progress']+artifact['modifier']).."/"..total);
	else
		ArtifactBar.text:SetText(artifact['race'].." "..artifact['progress'].."/"..total);
	end
	
	if (artifact['canSolve']) then
		if (MinArchOptions['DisableSound'] == false and artifact['canSolvePrev'] ~= artifact['canSolve']) then
			PlaySoundFile("Sound\\interface\\MapPing.wav")
			artifact['canSolvePrev'] = artifact['canSolve'];
		end
		ArtifactBar.buttonSolve:Enable();
	else
		ArtifactBar.buttonSolve:Disable();
	end	
end

function MinArch:SolveArtifact(BarIndex)
	SetSelectedArtifact(MinArch['barlinks'][BarIndex]);
	
	for i=1, MinArch['artifacts'][MinArch['barlinks'][BarIndex]]['appliedKeystones'] do
		SocketItemToArtifact();
	end	
	MinArch['artifacts'][MinArch['barlinks'][BarIndex]]['appliedKeystones'] = 0;
	
	SolveArtifact();
end

function MinArch:UpdateMain()
	local activeBarIndex = 0;
	
	for i=1,ARCHAEOLOGY_NUM_RACES do
		if not MinArch:UpdateArtifact(i) then return end
		
		local artifact = MinArch['artifacts'][i];
		local options = MinArchOptions['ABOptions'][i];
		
		if (artifact['total'] > 0 and options['Hide'] == false) then
			activeBarIndex = activeBarIndex + 1;
			MinArch:UpdateArtifactBar(i,MinArch['artifactbars'][activeBarIndex]);
			MinArch['artifactbars'][activeBarIndex]:Show();
			MinArch['barlinks'][activeBarIndex] = i;
		end		
	end
	
	local MinArchFrameHeight = MinArch['frame']['height'];
	
	for i=activeBarIndex+1, ARCHAEOLOGY_NUM_RACES do
		if (MinArch['artifactbars'][i] ~= nil) then
			MinArch['artifactbars'][i]:Hide();
			MinArchFrameHeight = MinArchFrameHeight - 25;
		end
	end
		
	MinArchMain:SetHeight(MinArchFrameHeight);
end

function MinArch:ShowArtifactTooltip(BarIndex)
	local artifact = MinArch['artifacts'][MinArch['barlinks'][BarIndex]];
	
	GameTooltip:SetOwner(MinArch['artifactbars'][BarIndex], "ANCHOR_BOTTOMRIGHT");
	
	MinArchTooltipIcon.icon:SetTexture(artifact['icon']);
	if (artifact['rarity'] == 1) then
		GameTooltip:AddLine(artifact['project'], 0.0, 0.4, 0.8, 1.0);
	else
		GameTooltip:AddLine(artifact['project'], GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1);
	end
	
	GameTooltip:AddLine(artifact['description'], 1.0, 1.0, 1.0, 1.0);
	GameTooltip:AddLine(artifact['spelldescription'], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
	
	if (artifact["sellprice"] ~= nil) then
		GameTooltip:AddLine(" ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		
		if (tonumber(artifact["sellprice"]) > 0) then
			GameTooltip:AddLine("|cffffffff"..GetCoinTextureString(artifact["sellprice"]), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		end	
	end
	
	if (artifact["firstcomplete"] ~= nil) then
		if (tonumber(artifact["firstcomplete"]) > 0) then
			if (artifact["sellprice"] == nil or artifact["sellprice"] == 0) then
				GameTooltip:AddLine(" ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
			end
			discovereddate = date("*t", artifact["firstcomplete"]);
			GameTooltip:AddDoubleLine("Discovered On: |cffffffff"..discovereddate["month"].."/"..discovereddate["day"].."/"..discovereddate["year"], "x"..artifact["totalcomplete"], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		end
	end
	
	
	
	MinArchTooltipIcon:Show();
	GameTooltip:Show();
end

function MinArch:HideArtifactTooltip()
	MinArchTooltipIcon:Hide();
	GameTooltip:Hide();
end

function MinArch:KeystoneTooltip(self)
	local artifact = MinArch['artifacts'][MinArch['barlinks'][self:GetID()]];
	local name = GetItemInfo(artifact['raceitemid']);
	
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
	
	local plural = "s";
	if (artifact['heldKeystones'] == 1) then
		plural = "";
	end
	
	GameTooltip:SetItemByID(artifact['raceitemid']);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine("You have "..artifact['heldKeystones'].." "..tostring(name)..plural .. " in your bags", GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1);
	GameTooltip:Show();
end

function MinArch:KeystoneClick(self, button, down)
	local artifactIndex = MinArch['barlinks'][self:GetID()];
	local numofappliedkeystones = MinArch['artifacts'][artifactIndex]['appliedKeystones'];
	local numoftotalkeystones = MinArch['artifacts'][artifactIndex]['numKeystones'];
	
	if (button == "LeftButton") then
		if (numofappliedkeystones < numoftotalkeystones) then
			 MinArch['artifacts'][artifactIndex]['appliedKeystones'] = numofappliedkeystones + 1;
		end
	elseif (button == "RightButton") then
		if (numofappliedkeystones > 0) then
			 MinArch['artifacts'][artifactIndex]['appliedKeystones'] = numofappliedkeystones - 1;
		end
	end
		
	MinArch:UpdateArtifact(artifactIndex);
	MinArch:UpdateArtifactBar(artifactIndex,MinArch['artifactbars'][self:GetID()]);
	
end

function MinArch:HideMain()
	MinArchMain:Hide();
	MinArchOptions['HideMain'] = true;
end

function MinArch:ShowMain()
	MinArchMain:Show();
	MinArchOptions['HideMain'] = false;
end

function MinArch:ToggleMain()
	if (MinArchMain:IsVisible()) then
		MinArch:HideMain()
	else
		MinArch:ShowMain()
	end
end
