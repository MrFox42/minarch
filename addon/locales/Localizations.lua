local ADDON, _ = ...

local GAME_LOCALE = GetLocale();

if GAME_LOCALE == 'enGB' then
	GAME_LOCALE = 'enUS'
end

function DS(name)
	if (MinArch.DigsiteLocales[GAME_LOCALE] ~= nil and MinArch.DigsiteLocales[GAME_LOCALE][name] ~= nil) then
		return MinArch.DigsiteLocales[GAME_LOCALE][name]
	else
		return name
	end
end
