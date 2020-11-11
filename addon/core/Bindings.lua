local ADDON, MinArch = ...

local clearBinding = false;

BINDING_HEADER_MINARCH_HEADER = "Minimal Archaeology"
BINDING_NAME_MINARCH_SHOWHIDE = "Show/Hide Minimal Archaeology"
setglobal("BINDING_NAME_SPELL Survey", "Survey")

SLASH_MINARCH1 = "/minarch"
SlashCmdList["MINARCH"] = function(msg, editBox)
	if (msg == "hide") then
		MinArch:HideMain();
	elseif (msg == "show") then
		MinArch:ShowMain();
	elseif (msg == "toggle") then
		MinArchMain:Toggle();
	elseif (msg == "version") then
		ChatFrame1:AddMessage("Minimal Archaeology " .. tostring(GetAddOnMetadata("MinimalArchaeology", "Version")));
	else
		ChatFrame1:AddMessage("Minimal Archaeology Commands");
		ChatFrame1:AddMessage(" Usage: /minarch [cmd]");
		ChatFrame1:AddMessage(" Commands:");
		ChatFrame1:AddMessage("  hide - Hide the main Minimal Archaeology Frame");
		ChatFrame1:AddMessage("  show - Show the main Minimal Archaeology Frame");
		ChatFrame1:AddMessage("  toggle - Toggle the main Minimal Archaeology Frame");
		ChatFrame1:AddMessage("  version - Display the running version of Minimal Archaeology");
	end
end

local function CanCast()
    -- Check if casting is enabled at all
    if not MinArch.db.profile.surveyOnDoubleClick then
        return false;
    end

    -- Check general conditions
    if InCombatLockdown() or not CanScanResearchSite() or GetSpellCooldown(SURVEY_SPELL_ID) ~= 0 then
        return false;
    end

    -- Check custom conditions (mounted, flying)
    if IsMounted() and MinArch.db.profile.dblClick.disableMounted then
        return false;
    end
    if IsFlying() and MinArch.db.profile.dblClick.disableInFlight then
        return false;
    end

    return true;
end

function MinArch:HookDoubleClick()
    local button = CreateFrame("Button", "MinArchHiddenSurveyButton", MinArch.HelperFrame, "InSecureActionButtonTemplate");
    button:SetAttribute("type", "spell");
    button:SetAttribute("spell", SURVEY_SPELL_ID);
    button:Hide();

    local threshold = 0.5;
    local prevTime;

    button:SetScript("PostClick", function(self)
        if clearBinding then
            ClearOverrideBindings(self)
        end
    end)

    WorldFrame:HookScript("OnMouseDown", function(_, button)
        if button == "RightButton" and CanCast() then
            if prevTime then
                local diff = GetTime() - prevTime;

                if diff < threshold then
                    SetOverrideBindingClick(MinArchHiddenSurveyButton, true, "BUTTON2", "MinArchHiddenSurveyButton");
                    clearBinding = true;
                end
            end

            prevTime = GetTime();
        end
    end)
end
