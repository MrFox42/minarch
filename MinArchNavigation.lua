MinArch.waypoint = nil;
MinArch.TomTomAvailable = (_G.TomTom ~= nil);

function MinArch:SetWayToDigsite(digsiteName, digsite)
	if not MinArch.TomTomAvailable then return end;

	if (MinArch.waypoint ~= nil) then
		_G.TomTom:RemoveWaypoint(MinArch.waypoint);
	end

	print(digsite.uiMapID, digsite.x/100, digsite.y/100)
	MinArch.waypoint = _G.TomTom:AddWaypoint(digsite.uiMapID, digsite.x/100, digsite.y/100, {
		title = digsiteName,
		persistent = false,
	});
end

function MinArch:SetWayToNearestDigsite()
    if not MinArch.TomTomAvailable then return end;
    
	local digsiteName, distance, digsite = MinArch:GetNearestDigsite();
	MinArch:SetWayToDigsite(digsiteName, digsite);
end