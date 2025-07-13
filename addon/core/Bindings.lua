local ADDON, _ = ...

---@type MinArchMain
local Main = MinArch:LoadModule("MinArchMain")
---@type MinArchCompanion
local Companion = MinArch:LoadModule("MinArchCompanion")
---@type MinArchCommon
local Common = MinArch:LoadModule("MinArchCommon")

local L = LibStub("AceLocale-3.0"):GetLocale("MinArch")

BINDING_HEADER_MINARCH_HEADER = L["OPTIONS_REGISTER_MINARCH"]
BINDING_NAME_MINARCH_SHOWHIDE = L["BINDINGS_MINARCH_SHOWHIDE"]
BINDING_NAME_MINARCH_CASTSURVEY = L["BINDINGS_MINARCH_CASTSURVEY"]
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
		ChatFrame1:AddMessage(L["OPTIONS_REGISTER_MINARCH"] .. " " .. tostring(C_AddOns.GetAddOnMetadata("MinimalArchaeology", "Version")));
    elseif (msg == "comp") then
        ChatFrame1:AddMessage(L["BINDINGS_MINARCH_COMPANION_COMMANDS"]);
        ChatFrame1:AddMessage(" " .. L["BINDINGS_USAGE"] .. ": /minarch [cmd]");
		ChatFrame1:AddMessage(" " .. L["BINDINGS_COMMANDS"] .. ":");
        ChatFrame1:AddMessage("  comp resetpos - " .. L["BINDINGS_COMPANION_RESETPOS"]);
    elseif (msg == "comp resetpos") then
        Companion:ResetPosition();
	else
		ChatFrame1:AddMessage(L["BINDINGS_MINARCH_MAIN_COMMANDS"]);
		ChatFrame1:AddMessage(" " .. L["BINDINGS_USAGE"] .. ": /minarch [cmd]");
		ChatFrame1:AddMessage(" " .. L["BINDINGS_COMMANDS"] .. ":");
		ChatFrame1:AddMessage("  hide - " .. L["BINDINGS_HIDEMAIN"]);
		ChatFrame1:AddMessage("  show - " .. L["BINDINGS_SHOWMAIN"]);
		ChatFrame1:AddMessage("  toggle - " .. L["BINDINGS_TOGGLEMAIN"]);
        ChatFrame1:AddMessage("  comp - " .. L["BINDINGS_COMPANION_MORE"] .. " /minarch comp");
		ChatFrame1:AddMessage("  version - " .. L["BINDINGS_MINARCH_VERSION"]);
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
            SetOverrideBindingSpell(MinArch.hiddenButton, true, key1, localizedName)
        end
        if key2 then
            SetOverrideBindingSpell(MinArch.hiddenButton, true, key2, localizedName)
        end
    end
end

function MinArch:DblClick(button, down)
    -- Check if casting is enabled at all
    if button == buttonName[MinArch.db.profile.dblClick.button] then
        Common:DisplayStatusMessage('Right button down', MINARCH_MSG_DEBUG)

        if not MinArch.db.profile.surveyOnDoubleClick then
            Common:DisplayStatusMessage('Can\'t cast: disabled in settings', MINARCH_MSG_DEBUG)
            return false
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

    return false
end

-- WorldFrame:HookScript("OnMouseUp", function(_, button, down)
--     return MinArch:DblClick(button, down)
-- end)