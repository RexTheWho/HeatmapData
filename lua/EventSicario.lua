-- Sicario smokes

Hooks:PostHook(SmokeScreenGrenade, "_detonate", "Heatmap_detonate_sicario_smoke", function(self, id)
	local pos = self._unit:position()
	local event_data = {"grenade", "sicario", math.round(pos.x), math.round(pos.y), math.round(pos.z), tweak_data.projectiles.smoke_screen_grenade.duration}
	
	HeatMap:EventAdd(event_data, true)
end)