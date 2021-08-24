
-- Heavilly unfinished!!!

-- Sentry Spawn
Hooks:PostHook(SentryGunBase, "setup", "Heatmap_spawn_sentrygun", function(self)
	local id = self._unit:id()
	local pos = self._unit:position()
	local shield = self:has_shield()
	local sentry_type = self:get_type()
	local event_data = {"deploy", id, sentry_type, math.round(pos.x), math.round(pos.y), math.round(pos.z), shield}
	HeatMap:EventAdd(event_data, true)
end)

-- Sentry Used
Hooks:PostHook(SentryGunBase, "on_interaction", "Heatmap_used_sentrygun", function(self)
	local id = self._unit:id()
	HeatMap:EventAdd({"deploy", id, "empty"}, true)
end)
