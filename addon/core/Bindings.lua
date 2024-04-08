local ADDON, MinArch = ...

MinArch.clearBinding = false;

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
    elseif (msg == "comp") then
        ChatFrame1:AddMessage("Minimal Archaeology Companion related Commands");
        ChatFrame1:AddMessage(" Usage: /minarch [cmd]");
		ChatFrame1:AddMessage(" Commands:");
        ChatFrame1:AddMessage("  comp resetpos - Resets the position of the Companion box");
    elseif (msg == "comp resetpos") then
        MinArch.Companion:ResetPosition();
	else
		ChatFrame1:AddMessage("Minimal Archaeology Commands");
		ChatFrame1:AddMessage(" Usage: /minarch [cmd]");
		ChatFrame1:AddMessage(" Commands:");
		ChatFrame1:AddMessage("  hide - Hide the main Minimal Archaeology Frame");
		ChatFrame1:AddMessage("  show - Show the main Minimal Archaeology Frame");
		ChatFrame1:AddMessage("  toggle - Toggle the main Minimal Archaeology Frame");
        ChatFrame1:AddMessage("  comp - Companion related commands, for more information type: /minarch comp");
		ChatFrame1:AddMessage("  version - Display the running version of Minimal Archaeology");
	end
end

local function CanCast()
    -- Prevent casting in combat
    if (InCombatLockdown()) then
        MinArch:DisplayStatusMessage('Can\'t cast: combat lockdown', MINARCH_MSG_DEBUG)
        return false;
    end

    -- Check if casting is enabled at all
    if not MinArch.db.profile.surveyOnDoubleClick then
        MinArch:DisplayStatusMessage('Can\'t cast: disabled in settings', MINARCH_MSG_DEBUG)
        return false;
    end

    -- Check general conditions
    if InCombatLockdown() or not CanScanResearchSite() or GetSpellCooldown(SURVEY_SPELL_ID) ~= 0 then
        MinArch:DisplayStatusMessage('Can\'t cast: not in research site or spell on cooldown', MINARCH_MSG_DEBUG)
        return false;
    end

    -- Check custom conditions (mounted, flying)
    if IsMounted() and MinArch.db.profile.dblClick.disableMounted then
        MinArch:DisplayStatusMessage('Can\'t cast: disabled in settings - mounted', MINARCH_MSG_DEBUG)
        return false;
    end
    if IsFlying() and MinArch.db.profile.dblClick.disableInFlight then
        MinArch:DisplayStatusMessage('Can\'t cast: disabled in settings - flying', MINARCH_MSG_DEBUG)
        return false;
    end

    return true;
end

local threshold = 0.5;
local prevTime;
local clickTime = 0;
function MinArch:DoubleClickSurvey(event, button)
    if button == "RightButton" then
        MinArch:DisplayStatusMessage('Right button down', MINARCH_MSG_DEBUG)
        if prevTime then
            local diff = GetTime() - prevTime;
            local diff2 = GetTime() - clickTime;

            -- print(prevTime, clickTime, diff, diff2, threshold);
            if diff < threshold and diff2 > threshold then
                MinArch:DisplayStatusMessage('Double click in threshold', MINARCH_MSG_DEBUG)
                -- print("shoudcast");
                clickTime = GetTime();
                if (CanCast()) then
                    if ( IsMouselooking() ) then
                        MouselookStop();
                    end

                    MinArch:DisplayStatusMessage('Should be casting', MINARCH_MSG_DEBUG)
                    SetOverrideBindingClick(MinArchHiddenSurveyButton, true, "button2", "MinArchHiddenSurveyButton");
                    MinArch.clearBinding = true;
                end
            end
        end

        prevTime = GetTime();
    end
end
