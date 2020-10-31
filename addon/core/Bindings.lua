local ADDON, MinArch

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
