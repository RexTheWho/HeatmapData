
-- GrenadeCrate Spawn
Hooks:PostHook(GrenadeCrateBase, "init", "Heatmap_spawn_grenadecase", function(self, unit)
	local id = self._unit:id()
	local pos = self._unit:position()
	local amount = tweak_data.upgrades.grenade_crate_base
	local event_data = {"deploy", id, "grenade_crate", math.round(pos.x), math.round(pos.y), math.round(pos.z), amount}
	HeatMap:EventAdd(event_data, true)
end)

-- GrenadeCrate Used
Hooks:PostHook(GrenadeCrateBase, "take_grenade", "Heatmap_used_grenadecase", function(self)
	local id = self._unit:id()
	local amount = self._grenade_amount
	if amount > 0 then
		HeatMap:EventAdd({"deploy", id, "used", amount}, true)
	else
		HeatMap:EventAdd({"deploy", id, "empty"}, true)
	end
end)
