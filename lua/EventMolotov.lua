
-- Spicey drink grenade

Hooks:PostHook(EnvironmentFire, "on_spawn", "Heatmap_molotov_on_spawn", function(self)
	local pos = self._unit:position()
	local duration = self._burn_duration
	
	local raycast = nil
	local vec_test = pos + Vector3(0, 0, -1500)
	raycast = World:raycast("ray", pos, vec_test, "slot_mask", managers.slot:get_mask("molotov_raycasts"))
	pos = raycast.position
	
	local event_data = {"grenade", "molotov", math.round(pos.x), math.round(pos.y), math.round(pos.z), duration}
	
	HeatMap:EventAdd(event_data, true)
end)