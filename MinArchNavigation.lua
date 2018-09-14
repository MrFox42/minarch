MinArch.waypoint = nil;
MinArch.TomTomAvailable = (_G.TomTom ~= nil);

local previousDigsite = nil;

local function IsNavivagationEnabled()
	return (MinArch.TomTomAvailable and MinArch.db.profile.TomTom.enable);
end

local function SetWayToDigsite(digsiteName, digsite)
	if not IsNavivagationEnabled() then return end;

	if (MinArch.waypoint ~= nil and MinArch.db.profile.TomTom.exclusive) then
		_G.TomTom:RemoveWaypoint(MinArch.waypoint);
	end

	-- print(digsite.uiMapID, digsite.x/100, digsite.y/100)
	MinArch.waypoint = _G.TomTom:AddWaypoint(digsite.uiMapID, digsite.x/100, digsite.y/100, {
		title = digsiteName,
		crazy = MinArch.db.profile.TomTom.arrow,
		persistent = MinArch.db.profile.TomTom.persistance,
	});

	MinArch.db.profile.TomTom.waypoints[digsiteName] = MinArch.waypoint;
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

function MinArch:RefreshDigsiteWaypoints()
	for title, waypoint in pairs(MinArch.db.profile.TomTom.waypoints) do
		if (_G.TomTom:WaypointExists(waypoint[1], waypoint[2], waypoint[3], title)) then
			-- readd waypoint so we have the correct data
			local newWaypoint = _G.TomTom:AddWaypoint(waypoint[1], waypoint[2], waypoint[3], {
				title = title,
				crazy = waypoint.crazy,
				persistent = waypoint.persistent,
			});
			MinArch.db.profile.TomTom.waypoints[title] = newWaypoint;
		else
			MinArch.db.profile.TomTom.waypoints[title] = nil;
		end
	end
end

function MinArch:ClearAllDigsiteWaypoints()
	for title, waypoint in pairs(MinArch.db.profile.TomTom.waypoints) do
		MinArch.db.profile.TomTom.waypoints[title] = nil;
		_G.TomTom:RemoveWaypoint(waypoint);
	end
end