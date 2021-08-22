

-- None of this information is included in the telemetry sent to overkill.
-- None of this should be modifying any telemetry data that would be sent to overkill.
-- Telemetry lua is just being used here for easy key events.


Hooks:PostHook(Telemetry, "on_end_heist", "Heatmap_on_end_heist", function(self)
	if HeatMap.record_heist == true then
		HeatMap.SaveTrackData()
	end
end)


Hooks:PostHook(Telemetry, "on_start_objective", "Heatmap_on_start_objective", function(self, id)
	if HeatMap.record_heist == true then
		local objective = { "obj", "start", id }
		HeatMap:EventAdd(objective)
	end
end)


Hooks:PostHook(Telemetry, "on_end_objective", "Heatmap_on_end_objective", function(self, id)
	if HeatMap.record_heist == true then
		local objective = { "obj", "end", id }
		HeatMap:EventAdd(objective)
	end
end)