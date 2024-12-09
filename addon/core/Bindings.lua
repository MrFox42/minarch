local ADDON, MinArch = ...

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
		ChatFrame1:AddMessage("Minimal Archaeology " .. tostring(C_AddOns.GetAddOnMetadata("MinimalArchaeology", "Version")));
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

WorldFrame:HookScript("OnMouseDown", function(_, button, down)
    -- Check if casting is enabled at all
    if button == buttonName[MinArch.db.profile.dblClick.button] then
        MinArch:DisplayStatusMessage('Right button down', MINARCH_MSG_DEBUG)

        if not MinArch.db.profile.surveyOnDoubleClick then
            MinArch:DisplayStatusMessage('Can\'t cast: disabled in settings', MINARCH_MSG_DEBUG)
            return
        end
        if prevTime then
            local diff = GetTime() - prevTime;
            local diff2 = GetTime() - clickTime;

            -- print(prevTime, clickTime, diff, diff2, threshold);
            if diff <= threshold and diff2 > threshold then
                MinArch:DisplayStatusMessage('Double click in threshold', MINARCH_MSG_DEBUG)
                clickTime = GetTime();
                if (MinArch:CanCast()) then
                    if ( IsMouselooking() ) then
                        MouselookStop();
                    end

                    MinArch:DisplayStatusMessage('Should be casting', MINARCH_MSG_DEBUG)
                    SetOverrideBindingClick(MinArch.hiddenButton, true, buttonId[MinArch.db.profile.dblClick.button], "MinArchHiddenSurveyButton");
                end
            end
        end

        prevTime = GetTime();
    else
        prevTime = nil
    end
end)
