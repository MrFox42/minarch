local ADDON, _ = ...

---@class MinArchNavigation
local Navigation = MinArch:LoadModule("MinArchNavigation")
Navigation.waypointOnLanding = false

---@type MinArchDigsites
local Digsites = MinArch:LoadModule("MinArchDigsites")
---@type MinArchCommon
local Common = MinArch:LoadModule("MinArchCommon")
---@type HereBeDragons-2.0
local HBD = LibStub("HereBeDragons-2.0")
local TomTom = _G["TomTom"];

local L = LibStub("AceLocale-3.0"):GetLocale("MinArch")

MinArch.autoWaypoint = nil;
local previousDigsite = nil;

function Navigation:IsTomTomAvailable()
    return TomTom ~= nil and MinArch.db.profile.TomTom.enableTomTom;
end

function Navigation:SetTomTom()
	TomTom = _G["TomTom"];
end

function Navigation:IsNavigationEnabled()
    return MinArch.db.profile.TomTom.enableBlizzWaypoint or Navigation:IsTomTomAvailable();
end

local function SetWayToDigsite(title, position, isAuto)
	if not Navigation:IsNavigationEnabled() then return end;

	Navigation:ClearUiWaypoint()
    if MinArch.db.profile.TomTom.enableBlizzWaypoint and MINARCH_EXPANSION == 'Mainline' then
        local uiMapPoint = UiMapPoint.CreateFromCoordinates(position.uiMapID, position.x/100, position.y/100, 0);
		C_Map.SetUserWaypoint(uiMapPoint);
        MinArch.db.char.TomTom.uiMapPoint = C_Map.GetUserWaypoint();
		C_SuperTrack.SetSuperTrackedUserWaypoint(MinArch.db.profile.TomTom.superTrack);
    end

	if Navigation:IsTomTomAvailable() then
		local persistent = MinArch.db.profile.TomTom.persistent;
		if (isAuto) then
			persistent = false
		end

		local newWaypoint = TomTom:AddWaypoint(position.uiMapID, position.x/100, position.y/100, {
			title = title,
			crazy = MinArch.db.profile.TomTom.arrow,
			persistent = persistent,
		});

		return newWaypoint
	end
end

function Navigation:ClearUiWaypoint()
	if (MINARCH_EXPANSION == 'Mainline') then
		local activeWaypoint = C_Map.GetUserWaypoint()
		if (MinArch.db.char.TomTom.uiMapPoint and activeWaypoint and activeWaypoint.uiMapID == MinArch.db.char.TomTom.uiMapPoint.uiMapID
			and Vector2DMixin.IsEqualTo(activeWaypoint.position, MinArch.db.char.TomTom.uiMapPoint.position)
		) then
			C_Map.ClearUserWaypoint();
		end
	end
    MinArch.db.char.TomTom.uiMapPoint = nil;
end

function Navigation:GetNearestFlightMaster()
	local factions = {
		['Horde'] = 1,
		['Alliance'] = 2
	}
	local unitFaction = UnitFactionGroup("player")
	local factionID = factions[unitFaction]

	local contID = Common:GetInternalContId();

	local cUiMapID = Common:GetUiMapIdByContId(contID);
	if (contID == nil or cUiMapID == nil) then
		return false
	end

	local uiMapID = C_Map.GetBestMapForUnit("player");
	if not uiMapID then
		return false
	end
	local playerPos = C_Map.GetPlayerMapPosition(uiMapID, "player")
	if (playerPos == nil) then
		return false;
	end
	-- local ax, ay = MinArch:ConvertMapPosToWorldPosIfNeeded(contID, uiMapID, playerPos, true)
	local ax, ay, instance = HBD:GetPlayerWorldPosition()

	local nearestTaxiNode, distance, x, y, idx

	local nodes = C_TaxiMap.GetTaxiNodesForMap(uiMapID)

	for i=1, #nodes do
		if (nodes[i].faction == 0 or nodes[i].faction == factionID) then
			-- local tx, ty = MinArch:ConvertMapPosToWorldPosIfNeeded(contID, uiMapID, nodes[i].position, true)
			local tx, ty = HBD:GetWorldCoordinatesFromZone(nodes[i].position.x, nodes[i].position.y, uiMapID)

			-- local xd = math.abs(ax - tonumber(tx))
			-- local yd = math.abs(ay - tonumber(ty))
			-- local d = math.sqrt((xd*xd)+(yd*yd))
			local _, d = HBD:GetWorldVector(instance, ax, ay, tx, ty)

			if nearestTaxiNode == nil or d < distance then
				nearestTaxiNode = nodes[i]
				distance = d
				x = tx
				y = ty
				idx = i
			end
		end
	end

	return {
		uiMapID = uiMapID,
		name = nearestTaxiNode.name,
		x = nearestTaxiNode.position.x * 100,
		y = nearestTaxiNode.position.y * 100,
		idx = idx,
		distance = distance
	}
end

function Navigation:SetWayToNearestDigsite(afterFlight)
	if not Navigation:IsNavigationEnabled() then return end

	local taxiNode
	local newWayPoint
	local digsiteName, distance, digsite, priority = Digsites:GetNearestDigsite()
	if (MinArch.db.profile.TomTom.taxi.enabled and distance and distance > MinArch.db.profile.TomTom.taxi.distance) then
		taxiNode = Navigation:GetNearestFlightMaster()

		if (afterFlight and taxiNode and taxiNode.distance < 100) then
			return
		end
	end

	if (taxiNode or ( digsite and (digsiteName ~= previousDigsite or distance > 2000)) ) then
		if (TomTom and MinArch.autoWaypoint ~= nil) then
			TomTom:RemoveWaypoint(MinArch.autoWaypoint)
		end

        local suffix = L["NAVIGATION_CLOSEST"];
        if priority > 0 and priority < 99 and digsite then
            suffix = '*' .. digsite.race;
        end
		if taxiNode then
			newWayPoint = SetWayToDigsite(taxiNode.name .. ' (' .. L["NAVIGATION_FLIGHTMASTER"] .. ')', taxiNode, true);
			previousDigsite = taxiNode.name
		else
			newWayPoint = SetWayToDigsite(digsiteName .. ' (' .. suffix .. ')', digsite, true);
			previousDigsite = digsiteName
		end
		MinArch.autoWaypoint = newWayPoint
	end

	if MinArch.db.profile.TomTom.taxi.enabled and MinArch.db.profile.TomTom.taxi.autoEnableArchMode then
		MinArch.db.profile.TomTom.taxi.archMode = true
	end
end

function Navigation:SetWayToDigsiteOnClick(digsiteName, digsite)
	if not Navigation:IsNavigationEnabled() then return end;

	previousDigsite = digsiteName;
	local newWaypoint = SetWayToDigsite(digsiteName, digsite);
	MinArch.db.char.TomTom.waypoints[digsiteName] = newWaypoint;
end

---@param forceRefresh? boolean @default: false
function Navigation:RefreshDigsiteWaypoints(forceRefresh)
	if not Navigation:IsNavigationEnabled() and not forceRefresh then return end;

	if Navigation:IsTomTomAvailable() then
		for title, waypoint in pairs(MinArch.db.char.TomTom.waypoints) do
			if (TomTom:WaypointExists(waypoint[1], waypoint[2], waypoint[3], title)) then
				-- re-add waypoint so we have the correct data
				local newWaypoint = TomTom:AddWaypoint(waypoint[1], waypoint[2], waypoint[3], {
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

function Navigation:RemoveTomTomWaypoint(waypoint)
	if TomTom then
		TomTom:RemoveWaypoint(waypoint);
	end
end

function Navigation:ClearAllDigsiteWaypoints()
	-- Make sure waypoints are up to date
	Navigation:RefreshDigsiteWaypoints(true);

	if TomTom then
		if (MinArch.autoWaypoint ~= nil) then
			TomTom:RemoveWaypoint(MinArch.autoWaypoint);
		end

		for title, waypoint in pairs(MinArch.db.char.TomTom.waypoints) do
			MinArch.db.char.TomTom.waypoints[title] = nil;
			TomTom:RemoveWaypoint(waypoint);
		end
	end
end
