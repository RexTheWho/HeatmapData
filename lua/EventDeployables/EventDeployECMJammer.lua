
-- ECM Spawn
Hooks:PostHook(ECMJammerBase, "init", "Heatmap_spawn_bodybag", function(self, unit)
	local id = self._unit:id()
	local pos = self._unit:position()
	local battery = self._battery_life
	local event_data = {"deploy", id, "ecm_jammer", math.round(pos.x), math.round(pos.y), math.round(pos.z), battery}
	HeatMap:EventAdd(event_data, true)
end)

-- ECM Jamming low battery
Hooks:PostHook(ECMJammerBase, "_set_battery_low", "Heatmap_battery_low", function(self)
	local id = self._unit:id()
	HeatMap:EventAdd({"deploy", id, "low"}, true)
end)

-- ECM Jamming over
Hooks:PostHook(ECMJammerBase, "_set_battery_empty", "Heatmap_battery_empty", function(self)
	local id = self._unit:id()
	HeatMap:EventAdd({"deploy", id, "empty"}, true)
end)

-- ECM Feedback
Hooks:PostHook(ECMJammerBase, "_set_feedback_active", "Heatmap_feedback_state", function(self, state)
	local id = self._unit:id()
	if state then
		HeatMap:EventAdd({"deploy", id, "feedback_on"}, true)
	else
		HeatMap:EventAdd({"deploy", id, "feedback_off"}, true)
	end
end)
