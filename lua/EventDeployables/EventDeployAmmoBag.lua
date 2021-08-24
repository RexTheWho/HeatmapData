
-- Ammo Spawn
Hooks:PostHook(AmmoBagBase, "setup", "Heatmap_spawn_ammobag", function(self)
	local id = self._unit:id()
	local pos = self._unit:position()
	local amount = self._ammo_amount
	local event_data = {"deploy", id, "ammo_bag", math.round(pos.x), math.round(pos.y), math.round(pos.z), amount}
	HeatMap:EventAdd(event_data, true)
end)

-- Ammo Used
Hooks:PostHook(AmmoBagBase, "take_ammo", "Heatmap_used_ammobag", function(self)
	local id = self._unit:id()
	local amount = self._ammo_amount
	if amount > 0 then
		HeatMap:EventAdd({"deploy", id, "used", amount}, true)
	else
		HeatMap:EventAdd({"deploy", id, "empty"}, true)
	end
end)
