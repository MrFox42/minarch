local ADDON, MinArch = ...

function MinArch:SetCrateButtonTooltip(button)
    button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
		if (MinArch.nextCratable ~= nil) then
			GameTooltip:SetItemByID(MinArch.nextCratable.itemID);
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine("Click to crate this artifact");
		else
			GameTooltip:AddLine("You don't have anything to crate.");
		end

		GameTooltip:Show();
	end)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end)
end

MinArch.nextCratable = nil;
function MinArch:RefreshCrateButtonGlow()
    MinArchMainCrateButtonGlow:Hide();
    MinArch.Companion:hideCrateButton()
    MinArch.nextCratable = nil;

	for i = 1, ARCHAEOLOGY_RACE_MANTID do
		for artifactID, data in pairs(MinArchHistDB[i]) do
			if (data.pqid) then
				-- iterate containers
				for bagID = 0, 4 do
					local numSlots = C_Container.GetContainerNumSlots(bagID);
					for slot = 0, numSlots do
						local itemID = C_Container.GetContainerItemID(bagID, slot);
						if (itemID == artifactID) then
							MinArch.nextCratable = {
								itemID = itemID,
								bagID = bagID,
								slot = slot
							}

                            MinArchMainCrateButton:SetAttribute("item", "item:" .. itemID);
                            MinArchMainCrateButtonGlow:Show();
                            MinArch.Companion:showCrateButton(itemID);

							return;
						end
					end
				end
			end
		end
	end
end

