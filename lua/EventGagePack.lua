
-- Ammodrops

Hooks:PostHook(GageAssignmentBase, "init", "Heatmap_gage_package_spawn", function(self)
	local id = self._unit:id()
	local pos = self._unit:position()
	local assignment = self:assignment()
	HeatMap:EventAdd({ "gage", id, math.round(pos.x), math.round(pos.y), math.round(pos.z), assignment }, true)
end)

Hooks:PreHook(GageAssignmentBase, "_pickup", "Heatmap_gage_package_pickup", function(self)
	local id = self._unit:id()
	HeatMap:EventAdd({ "gage", id }, true)
end)