
-- Bodybag Spawn
Hooks:PostHook(BodyBagsBagBase, "init", "Heatmap_spawn_bodybag", function(self, unit)
	local id = self._unit:id()
	local pos = self._unit:position()
	local amount = tweak_data.upgrades.bodybag_crate_base
	local event_data = {"deploy", id, "bodybags_bag", math.round(pos.x), math.round(pos.y), math.round(pos.z), amount}
	HeatMap:EventAdd(event_data, true)
end)

-- Bodybag Used
Hooks:PostHook(BodyBagsBagBase, "take_bodybag", "Heatmap_used_bodybag", function(self)
	local id = self._unit:id()
	local amount = self._bodybag_amount
	if amount > 0 then
		HeatMap:EventAdd({"deploy", id, "used", amount}, true)
	else
		HeatMap:EventAdd({"deploy", id, "empty"}, true)
	end
end)
