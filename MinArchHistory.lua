MinArchScroll = {}

function MinArch:LoadItemDetails(RaceID)
	local allGood = true
	for itemid, details in pairs(MinArchHistDB[RaceID]) do
		local name, _, rarity, _, _, _, _, _, _, icon, sellPrice = GetItemInfo(itemid);

		if name ~= nil and icon ~= nil then
			MinArchHistDB[RaceID][itemid]["name"] = name;
			MinArchHistDB[RaceID][itemid]["rarity"] = rarity;
			MinArchHistDB[RaceID][itemid]["icon"] = "interface\\icons\\"..LibIconPath_getName(icon)..".blp";
			MinArchHistDB[RaceID][itemid]["sellprice"] = sellPrice;
		else
			-- item info not available yet, need to retry later
			allGood = false
		end
	end
	return allGood
end

function MinArch:GetHistory(RaceID)
	local i = 1;
	while (i > 0) do
		local name, desc, rarity, icon, spelldesc, itemrare, _, firstcomplete, totalcomplete = GetArtifactInfoByRace(RaceID, i);

		if not name then
			i = -1;
		else
			icon = icon:lower()
			if  MinArchIconDB[RaceID] and MinArchIconDB[RaceID][icon] then
				 icon = MinArchIconDB[RaceID][icon]
			end
			icon = icon..".blp"

			for itemid, details in pairs(MinArchHistDB[RaceID]) do
				if (details["name"] == name and details["icon"] ~= icon) then
					MinArchIconDB[RaceID] = MinArchIconDB[RaceID] or {}
					MinArchIconDB[RaceID][icon] = details["icon"]
					ChatFrame1:AddMessage("Minimal Archeology - icon discrepancy detected")
					ChatFrame1:AddMessage("Race " .. RaceID .. ": " .. MinArch['artifacts'][RaceID]['race'])
					ChatFrame1:AddMessage("Item " .. itemid .. ": " .. name)
					ChatFrame1:AddMessage("Item icon '" .. details["icon"] .. "'")
					ChatFrame1:AddMessage("Artifact icon '" .. icon .. "'")
					ChatFrame1:AddMessage("Please submit a bug report with the contents of this message.")
					icon = details["icon"]
				end

				if (details["icon"] == icon) then
					MinArchHistDB[RaceID][itemid]["firstcomplete"] = firstcomplete;
					MinArchHistDB[RaceID][itemid]["totalcomplete"] = totalcomplete;
					MinArchHistDB[RaceID][itemid]["description"] = desc;
					MinArchHistDB[RaceID][itemid]["spelldescription"] = spelldesc;
					
					if (MinArch['artifacts'][RaceID]['project'] == name) then
						MinArch['artifacts'][RaceID]['firstcomplete'] = firstcomplete;
						MinArch['artifacts'][RaceID]['totalcomplete'] = totalcomplete;
						MinArch['artifacts'][RaceID]['sellprice'] = MinArchHistDB[RaceID][itemid]["sellprice"];
					end
				end
			end
		end
		i=i+1;
	end
end

HistoryListLoaded = false

function MinArch:CreateHistoryList(RaceID)
	local scrollf = MinArchScrollFrame or CreateFrame("ScrollFrame", "MinArchScrollFrame", MinArchHist);
	
	if (not HistoryListLoaded) then
		local allGood = true
		for i = 1, 18 do
			allGood = MinArch:LoadItemDetails(i) and allGood
		end

		if allGood then
			HistoryListLoaded = true;
		end
	end

	for i=1, 18 do
		if (MinArchScroll[i]) then
			MinArchScroll[i]:Hide();
		end
	end

	MinArch:GetHistory(RaceID);

	MinArchScroll[RaceID] = MinArchScroll[RaceID] or CreateFrame("Frame", "MinArchScroll");
	local scrollc = MinArchScroll[RaceID];
	
	MinArchScroll[RaceID]:Show();
	
	local scrollb = MinArchScrollBar or CreateFrame("Slider", "MinArchScrollBar", scrollf);
	
	if (not scrollb.bg) then
		scrollb.bg = scrollb:CreateTexture(nil, "BACKGROUND");
		scrollb.bg:SetAllPoints(true);
		scrollb.bg:SetTexture(0, 0, 0, 0.80);
	end
	
	if (not scrollf.bg) then
		scrollf.bg = scrollf:CreateTexture(nil, "BACKGROUND");
		scrollf.bg:SetAllPoints(true);
		scrollf.bg:SetTexture(0, 0, 0, 0.60);
	end
	
	if (not scrollb.thumb) then
		scrollb.thumb = scrollb:CreateTexture(nil, "OVERLAY");
		scrollb.thumb:SetTexture("Interface\\Buttons\\UI-ScrollBar-Knob");
		scrollb.thumb:SetSize(25, 25);
		scrollb:SetThumbTexture(scrollb.thumb);
	end
	
	scrollc.artifacts = scrollc.artifacts or {};

	local PADDING = 5;
	
	local height = 0;
	local width = 460; -- fixme get parent width
	
	local count = 1;
	
	for i=4, 0, -1 do
		for itemid, details in pairs(MinArchHistDB[RaceID]) do
			if details["rarity"] == i then
				if not scrollc.artifacts[count] then
					scrollc.artifacts[count] = scrollc:CreateFontString("Artifact" .. count, "OVERLAY")
				end
				
				local currentArtifact = scrollc.artifacts[count];
				currentArtifact:SetFontObject("ChatFontSmall");
				currentArtifact:SetWordWrap(true);
				currentArtifact:SetText(" "..details["name"]);
				if (details["rarity"] == 4) then
					currentArtifact:SetTextColor(0.65, 0.2, 0.93, 1.0)
				elseif (details["rarity"] == 3) then
					currentArtifact:SetTextColor(0.0, 0.4, 0.8, 1.0)
				else
					currentArtifact:SetTextColor(1.0, 1.0, 1.0, 1.0)
				end
				
				local cwidth = currentArtifact:GetStringWidth()
				local cheight = currentArtifact:GetStringHeight()
				currentArtifact:SetWidth(cwidth+18)
				currentArtifact:SetHeight(cheight)
				
				if count == 1 then
				  currentArtifact:SetPoint("TOPLEFT",scrollc, "TOPLEFT", 0, 0)
				  height = height + cheight
				else
				  currentArtifact:SetPoint("TOPLEFT", scrollc.artifacts[count - 2], "BOTTOMLEFT", 0, - PADDING)
				  height = height + cheight + PADDING
				end
				
				count = count+1
				
				-- STATUS
					
				if not scrollc.artifacts[count] then
				  scrollc.artifacts[count] = scrollc:CreateFontString("Artifact" .. count, "OVERLAY");
				end
				
				currentArtifact = scrollc.artifacts[count]
				currentArtifact:SetFontObject("ChatFontSmall")
				currentArtifact:SetWordWrap(true)
				if not details["firstcomplete"] then
					currentArtifact:SetText("Incomplete")
					currentArtifact:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1)
				elseif details["firstcomplete"] == 0 then
					currentArtifact:SetText("In Progress")
					currentArtifact:SetTextColor(1.0, 0.8, 0.0, 1.0)
				else
					currentArtifact:SetText(details["totalcomplete"] .. " Completed")
					currentArtifact:SetTextColor(0.0, 1.0, 0.0, 1.0)
				end
				
				cwidth = currentArtifact:GetStringWidth()
				cheight = currentArtifact:GetStringHeight()
				currentArtifact:SetSize(cwidth+5, cheight)
				
				if count == 2 then
				  currentArtifact:SetPoint("TOPRIGHT",scrollc, "TOPRIGHT", 0, 0)
				else
				  currentArtifact:SetPoint("TOPRIGHT", scrollc.artifacts[count - 2], "BOTTOMRIGHT", 0, - PADDING)
				end
			
				local mouseframe = CreateFrame("Frame", "MouseFrame")
				mouseframe:SetSize(370, cheight)
				mouseframe:SetParent(scrollc)
				mouseframe:SetPoint("BOTTOMRIGHT", currentArtifact, "BOTTOMRIGHT", 0, 0)
				
				mouseframe:SetScript("OnEnter", function(self)
											MinArch:HistoryTooltip(self, RaceID, itemid)
										end)
				mouseframe:SetScript("OnLeave", function()
											MinArchTooltipIcon:Hide();
											GameTooltip:Hide()
										end)
				
				count = count+1
				
			end
		end
	end
	
	-- Set the size of the scroll child
	scrollc:SetSize(width, height-2)
	 
	-- Size and place the parent frame, and set the scrollchild to be the
	-- frame of font strings we've created
	scrollf:SetSize(width, 260)
	scrollf:SetPoint("BOTTOMLEFT", MinArchHist, "BOTTOMLEFT", 12, 10)
	scrollf:SetScrollChild(scrollc)
	scrollf:Show()
	 
	scrollc:SetSize(width, height-2)
	 
	-- Set up the scrollbar to work properly
	local scrollMax = 0
	if height > 260 then
		scrollMax = height - 250
	end
	
	if (scrollMax == 0) then
		scrollb.thumb:Hide();
	else
		scrollb.thumb:Show();
	end
	
	scrollb:SetOrientation("VERTICAL");
	scrollb:SetSize(16, 260)
	scrollb:SetPoint("TOPLEFT", scrollf, "TOPRIGHT", 0, 0)
	scrollb:SetMinMaxValues(0, scrollMax)
	scrollb:SetValue(0)
	scrollb:SetScript("OnValueChanged", function(self)
		  scrollf:SetVerticalScroll(self:GetValue())
	end)
	 
	-- Enable mousewheel scrolling
	scrollf:EnableMouseWheel(true)
	scrollf:SetScript("OnMouseWheel", function(self, delta)
		  local current = scrollb:GetValue()
		   
		  if IsShiftKeyDown() and (delta > 0) then
			 scrollb:SetValue(0)
		  elseif IsShiftKeyDown() and (delta < 0) then
			 scrollb:SetValue(scrollMax)
		  elseif (delta < 0) and (current < scrollMax) then
			 scrollb:SetValue(current + 20)
		  elseif (delta > 0) and (current > 1) then
			 scrollb:SetValue(current - 20)
		  end
	end)
end

function MinArch:DimHistoryButtons()
	MinArchHist.demonicButton:SetAlpha(0.5);
	MinArchHist.highmountainTaurenButton:SetAlpha(0.5);
	MinArchHist.highborneButton:SetAlpha(0.5);
	MinArchHist.draeneiButton:SetAlpha(0.5);
	MinArchHist.fossilButton:SetAlpha(0.5);
	MinArchHist.nightelfButton:SetAlpha(0.5);
	MinArchHist.nerubianButton:SetAlpha(0.5);
	MinArchHist.orcButton:SetAlpha(0.5);
	MinArchHist.tolvirButton:SetAlpha(0.5);
	MinArchHist.trollButton:SetAlpha(0.5);
	MinArchHist.vrykulButton:SetAlpha(0.5);
	MinArchHist.mantidButton:SetAlpha(0.5);
	MinArchHist.pandarenButton:SetAlpha(0.5);
	MinArchHist.moguButton:SetAlpha(0.5);
	MinArchHist.arakkoaButton:SetAlpha(0.5);
	MinArchHist.draenorClansButton:SetAlpha(0.5);
	MinArchHist.ogreButton:SetAlpha(0.5);
	MinArchHist.dwarfButton:SetAlpha(0.5);
end

function MinArch:HistoryTooltip(self, RaceID, ItemID)
	local artifact = MinArchHistDB[RaceID][ItemID];
	local discovereddate = {};
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	
	MinArchTooltipIcon.icon:SetTexture(artifact['icon']);
	if (artifact['rarity'] == 4) then
		GameTooltip:AddLine(artifact['name'], 0.65, 0.2, 0.93, 1.0);
	elseif (artifact['rarity'] == 3) then
		GameTooltip:AddLine(artifact['name'], 0.0, 0.4, 0.8, 1.0);
	else
		GameTooltip:AddLine(artifact['name'], GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1);
	end
	
	GameTooltip:AddLine(artifact['description'], 1.0, 1.0, 1.0, 1.0);
	GameTooltip:AddLine(artifact['spelldescription'], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
	
	if not artifact["firstcomplete"] then
		GameTooltip:AddLine("Incomplete", GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1);
	elseif artifact["firstcomplete"] == 0 then
		GameTooltip:AddLine(" ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		if (artifact["sellprice"] ~= nil) then
			if (tonumber(artifact["sellprice"]) > 0) then
				GameTooltip:AddLine("|cffffffff"..GetCoinTextureString(artifact["sellprice"]), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
			end	
		end
		GameTooltip:AddLine("In Progress", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
	else
		GameTooltip:AddLine(" ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		if (artifact["sellprice"] ~= nil) then
			if (tonumber(artifact["sellprice"]) > 0) then
				GameTooltip:AddLine("|cffffffff"..GetCoinTextureString(artifact["sellprice"]), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
			end	
		end
		discovereddate = date("*t", artifact["firstcomplete"]);
		GameTooltip:AddDoubleLine("Discovered On: |cffffffff"..discovereddate["month"].."/"..discovereddate["day"].."/"..discovereddate["year"], "x"..artifact["totalcomplete"], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
	
	
	
	MinArchTooltipIcon:Show();
	GameTooltip:Show();
end

function MinArch:HistoryButtonTooltip(RaceID)
	GameTooltip:SetOwner(MinArchHist, "ANCHOR_TOPLEFT");
	GameTooltip:AddLine(MinArch['artifacts'][RaceID]['race'], 1.0, 1.0, 1.0, 1.0);
	GameTooltip:Show();
end