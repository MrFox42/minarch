MinArch.waypoint = nil;
MinArch.TomTomAvailable = (_G.TomTom ~= nil);

local previousDigsite = nil;

local function IsNavivagationEnabled()
	return (MinArch.TomTomAvailable and MinArch.db.profile.TomTom.enable);
end

local function SetWayToDigsite(digsiteName, digsite)
	if not IsNavivagationEnabled() then return end;

	if (MinArch.waypoint ~= nil) then
		_G.TomTom:RemoveWaypoint(MinArch.waypoint);
	end

	-- print(digsite.uiMapID, digsite.x/100, digsite.y/100)
	MinArch.waypoint = _G.TomTom:AddWaypoint(digsite.uiMapID, digsite.x/100, digsite.y/100, {
		title = digsiteName,
		persistent = false,
	});
end

function MinArch:SetWayToNearestDigsite()
    if not IsNavivagationEnabled() then return end;
	
	local digsiteName, distance, digsite = MinArch:GetNearestDigsite();
	if (digsite and (digsiteName ~= previousDigsite or distance > 1.7)) then
		previousDigsite = digsiteName;
		SetWayToDigsite(digsiteName, digsite);
	end
end

function MinArch:SetWayToDigsiteOnClick(digsiteName, digsite)
	previousDigsite = digsiteName;
	SetWayToDigsite(digsiteName, digsite);
end