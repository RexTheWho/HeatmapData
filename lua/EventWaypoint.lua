
-- For now ignoring unit triggered waypoints, only static waypoints.

Hooks:PostHook(HUDManager, "add_waypoint", "Heatmap_add_waypoint", function(self, id, data)
	if data.position then
		local pos = data.position
		local track_unit = nil
		if data.unit then
			-- atm seems like were not getting any unit data.
			track_unit = data.unit:id()
		end
		if not track_unit then
			HeatMap:EventAdd({ "wp", "add", id, data.icon, math.round(pos.x), math.round(pos.y), math.round(pos.z) })
		else
			HeatMap:EventAdd({ "wp", "add", id, data.icon, math.round(pos.x), math.round(pos.y), math.round(pos.z), track_unit })
		end
	end
end)


Hooks:PostHook(HUDManager, "change_waypoint_icon", "Heatmap_change_waypoint_icon", function(self, id, icon)
	HeatMap:EventAdd({ "wp", "edt", id, icon })
end)


Hooks:PostHook(HUDManager, "remove_waypoint", "Heatmap_remove_waypoint", function(self, id)
	HeatMap:EventAdd({ "wp", "rmv", id })
end)