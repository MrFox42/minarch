local ADDON, MinArch = ...

MinArch.DigsiteLocales = {};
local GAME_LOCALE = GetLocale();

function DS(name)
	if (MinArch.DigsiteLocales[GAME_LOCALE] ~= nil and MinArch.DigsiteLocales[GAME_LOCALE][name] ~= nil) then
		return MinArch.DigsiteLocales[GAME_LOCALE][name]
	else
		return name
	end
end
