
-- Medic Spawn
Hooks:PostHook(DoctorBagBase, "setup", "Heatmap_spawn_medicbag", function(self, unit)
	local id = self._unit:id()
	local pos = self._unit:position()
	local amount = self._amount
	local event_data = {"deploy", id, "doctor_bag", math.round(pos.x), math.round(pos.y), math.round(pos.z), amount}
	HeatMap:EventAdd(event_data, true)
end)

-- Medic Used
Hooks:PostHook(DoctorBagBase, "_take", "Heatmap_used_medicbag", function(self)
	local id = self._unit:id()
	local amount = self._amount
	if amount > 0 then
		HeatMap:EventAdd({"deploy", id, "used", amount}, true)
	else
		HeatMap:EventAdd({"deploy", id, "empty"}, true)
	end
end)