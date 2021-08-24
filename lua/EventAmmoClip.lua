
-- Ammodrops

Hooks:PostHook(AmmoClip, "init", "Heatmap_ammo_drop", function(self)
	local id = self._unit:id()
	local pos = self._unit:position()
	HeatMap:EventAdd({ "ammo", id, math.round(pos.x), math.round(pos.y), math.round(pos.z) }, true)
end)

Hooks:PreHook(AmmoClip, "_pickup", "Heatmap_ammo_pickup", function(self)
	local id = self._unit:id()
	local pos = self._unit:position()
	HeatMap:EventAdd({ "ammo", id }, true)
end)