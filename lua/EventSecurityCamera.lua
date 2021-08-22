
-- Tracking enabled cameras.

Hooks:PostHook(SecurityCamera, "set_detection_enabled", "Heatmap_set_detection_enabled", function(self, state, settings)
	if state == true and self._unit.enabled then
		local pos = self._yaw_obj:position()
		local fov = settings.fov
		local camera = { "cam", "add", self._unit:id(), math.round(pos.x), math.round(pos.y), math.round(pos.z), settings.yaw, settings.pitch, fov, settings.detection_range }
		HeatMap:EventAdd(camera, true)
	else
		local camera = { "cam", "rmv", self._unit:id()}
		HeatMap:EventAdd(camera, true)
	end
end)


Hooks:PostHook(SecurityCamera, "destroy", "Heatmap_destroy", function(self)
	local camera = { "cam", "rmv", self._unit:id()}
	HeatMap:EventAdd(camera, true)
end)


Hooks:PostHook(SecurityCamera, "_deactivate_tape_loop", "Heatmap_deactivate_tape_loop", function(self)
	local camera = { "cam", "hack_end", self._unit:id()}
	HeatMap:EventAdd(camera, true)
end)


Hooks:PostHook(SecurityCamera, "_start_tape_loop", "Heatmap_deactivate_start_tape_loop", function(self)
	local camera = { "cam", "hack", self._unit:id()}
	HeatMap:EventAdd(camera, true)
end)