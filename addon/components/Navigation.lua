local ADDON, MinArch = ...

MinArch.autoWaypoint = nil;
local previousDigsite = nil;

function MinArch:IsTomTomAvailable()
    return _G.TomTom ~= nil and MinArch.db.profile.TomTom.enableTomTom;
end

function MinArch:IsNavigationEnabled()
    return MinArch.db.profile.TomTom.enableBlizzWaypoint or MinArch:IsTomTomAvailable();
end

local function SetWayToDigsite(title, digsite, isAuto)
	if not MinArch:IsNavigationEnabled() then return end;

	MinArch:ClearUiWaypoint()
    if MinArch.db.profile.TomTom.enableBlizzWaypoint then
        local uiMapPoint = UiMapPoint.CreateFromCoordinates(digsite.uiMapID, digsite.x/100, digsite.y/100, 0);
        C_Map.SetUserWaypoint(uiMapPoint);
        MinArch.db.char.TomTom.uiMapPoint = C_Map.GetUserWaypoint();
        C_SuperTrack.SetSuperTrackedUserWaypoint(MinArch.db.profile.TomTom.superTrack);
    end

	if MinArch:IsTomTomAvailable() then
		local persistent = MinArch.db.profile.TomTom.persistent;
		if (isAuto) then
			persistent = false
		end

		local newWaypoint = _G.TomTom:AddWaypoint(digsite.uiMapID, digsite.x/100, digsite.y/100, {
			title = title,
			crazy = MinArch.db.profile.TomTom.arrow,
			persistent = persistent,
		});

		return newWaypoint
	end
end

function MinArch:ClearUiWaypoint()
    local activeWaypoint = C_Map.GetUserWaypoint()
    if (MinArch.db.char.TomTom.uiMapPoint and activeWaypoint and activeWaypoint.uiMapID == MinArch.db.char.TomTom.uiMapPoint.uiMapID
        and Vector2DMixin.IsEqualTo(activeWaypoint.position, MinArch.db.char.TomTom.uiMapPoint.position)
    ) then
        C_Map.ClearUserWaypoint();
    end
    MinArch.db.char.TomTom.uiMapPoint = nil;
end

function MinArch:SetWayToNearestDigsite()
	if not MinArch:IsNavigationEnabled() then return end;

	local digsiteName, distance, digsite = MinArch:GetNearestDigsite();
	if (digsite and (digsiteName ~= previousDigsite or distance > 1.7)) then
		if (_G.TomTom and MinArch.autoWaypoint ~= nil) then
			_G.TomTom:RemoveWaypoint(MinArch.autoWaypoint);
		end

        previousDigsite = digsiteName;
        local suffix = 'closest';
        if (MinArch.db.profile.TomTom.prioRace > 0 and digsite.raceId == MinArch.db.profile.TomTom.prioRace) then
            suffix = '*' .. digsite.race;
        end
		local newWayPoint = SetWayToDigsite(digsiteName .. ' (' .. suffix .. ')', digsite, true);
		MinArch.autoWaypoint = newWayPoint;
	end
end

function MinArch:SetWayToDigsiteOnClick(digsiteName, digsite)
	if not MinArch:IsNavigationEnabled() then return end;

	previousDigsite = digsiteName;
	local newWaypoint = SetWayToDigsite(digsiteName, digsite);
	MinArch.db.char.TomTom.waypoints[digsiteName] = newWaypoint;
end

function MinArch:RefreshDigsiteWaypoints(forceRefresh)
	if not MinArch:IsNavigationEnabled() and not forceRefresh then return end;

	if MinArch:IsTomTomAvailable() then
		for title, waypoint in pairs(MinArch.db.char.TomTom.waypoints) do
			if (_G.TomTom:WaypointExists(waypoint[1], waypoint[2], waypoint[3], title)) then
				-- re-add waypoint so we have the correct data
				local newWaypoint = _G.TomTom:AddWaypoint(waypoint[1], waypoint[2], waypoint[3], {
					title = title,
					crazy = waypoint.crazy,
					persistent = waypoint.persistent,
				});
				MinArch.db.char.TomTom.waypoints[title] = newWaypoint;
			else
				MinArch.db.char.TomTom.waypoints[title] = nil;
			end
		end
	end
end

function MinArch:ClearAllDigsiteWaypoints()
	-- Make sure waypoints are up to date
	MinArch:RefreshDigsiteWaypoints(true);

	if _G.TomTom then
		if (MinArch.autoWaypoint ~= nil) then
			_G.TomTom:RemoveWaypoint(MinArch.autoWaypoint);
		end

		for title, waypoint in pairs(MinArch.db.char.TomTom.waypoints) do
			MinArch.db.char.TomTom.waypoints[title] = nil;
			_G.TomTom:RemoveWaypoint(waypoint);
		end
	end
end
