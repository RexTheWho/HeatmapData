-- Did we win?
Hooks:PostHook(ElementMissionEnd, "on_executed", "Heatmap_mission_end_on_executed", function(self)
	if self._values.enabled and self._values.state == "success" then
		HeatMap.job_results.job_successful = true
	end
end)