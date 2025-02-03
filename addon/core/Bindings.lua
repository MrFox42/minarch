local ADDON, _ = ...

---@type MinArchMain
local Main = MinArch:LoadModule("MinArchMain")
---@type MinArchCompanion
local Companion = MinArch:LoadModule("MinArchCompanion")
---@type MinArchCommon
local Common = MinArch:LoadModule("MinArchCommon")

BINDING_HEADER_MINARCH_HEADER = "Minimal Archaeology"
BINDING_NAME_MINARCH_SHOWHIDE = "Show/Hide Minimal Archaeology"
BINDING_NAME_MINARCH_CASTSURVEY = "Cast Survey"
setglobal("BINDING_NAME_SPELL Survey", "Survey")

SLASH_MINARCH1 = "/minarch"
SlashCmdList["MINARCH"] = function(msg, editBox)
	if (msg == "hide") then
		Main:HideWindow();
	elseif (msg == "show") then
		Main:ShowWindow();
	elseif (msg == "toggle") then
		Main:ToggleWindow();
	elseif (msg == "version") then
		ChatFrame1:AddMessage("Minimal Archaeology " .. tostring(C_AddOns.GetAddOnMetadata("MinimalArchaeology", "Version")));
    elseif (msg == "comp") then
        ChatFrame1:AddMessage("Minimal Archaeology Companion related Commands");
        ChatFrame1:AddMessage(" Usage: /minarch [cmd]");
		ChatFrame1:AddMessage(" Commands:");
        ChatFrame1:AddMessage("  comp resetpos - Resets the position of the Companion box");
    elseif (msg == "comp resetpos") then
        Companion:ResetPosition();
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

local threshold = 0.5;
local prevTime;
local clickTime = 0;
local buttonName = {
    [1] = "RightButton",
    [2] = "LeftButton"
}
local buttonId = {
    [1] = "BUTTON2",
    [2] = "BUTTON1"
}

function MinArch:BindingCast()
    if (Common:CanCast()) then
        local key1, key2 = GetBindingKey("MINARCH_CASTSURVEY")
        local localizedName = C_Spell.GetSpellInfo(SURVEY_SPELL_ID).name

        if key1 then
            SetOverrideBindingSpell(MinArch.hiddenButton, 1, key1, localizedName)
        end
        if key2 then
            SetOverrideBindingSpell(MinArch.hiddenButton, 2, key2, localizedName)
        end
    end
end

WorldFrame:HookScript("OnMouseDown", function(_, button, down)
    -- Check if casting is enabled at all
    if button == buttonName[MinArch.db.profile.dblClick.button] then
        Common:DisplayStatusMessage('Right button down', MINARCH_MSG_DEBUG)

        if not MinArch.db.profile.surveyOnDoubleClick then
            Common:DisplayStatusMessage('Can\'t cast: disabled in settings', MINARCH_MSG_DEBUG)
            return
        end
        if prevTime then
            local diff = GetTime() - prevTime;
            local diff2 = GetTime() - clickTime;

            -- print(prevTime, clickTime, diff, diff2, threshold);
            if diff <= threshold and diff2 > threshold then
                Common:DisplayStatusMessage('Double click in threshold', MINARCH_MSG_DEBUG)
                clickTime = GetTime();
                if (Common:CanCast()) then
                    if ( IsMouselooking() ) then
                        MouselookStop();
                    end

                    Common:DisplayStatusMessage('Should be casting', MINARCH_MSG_DEBUG)
                    SetOverrideBindingClick(MinArch.hiddenButton, true, buttonId[MinArch.db.profile.dblClick.button], "MinArchHiddenSurveyButton");
                end
            end
        end

        prevTime = GetTime();
    else
        prevTime = nil
    end
end)
