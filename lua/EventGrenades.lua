-- GRANATA!!
-- Just kidding, its just smokes and flashes.

Hooks:PostHook(GroupAIStateBase, "detonate_world_smoke_grenade", "Heatmap_detonate_world_smoke_grenade", function(self, id)
	self._smoke_grenades = self._smoke_grenades or {}

	if not self._smoke_grenades[id] then
		return
	end

	local data = self._smoke_grenades[id]
	
	local pos = data.detonate_pos
	local type_of_grenade = "smoke"
	
	if data.flashbang then
		type_of_grenade = "flash"
	end
	
	local event_data = {"grenade", id, type_of_grenade, math.round(pos.x), math.round(pos.y), math.round(pos.z), data.duration}
	
	HeatMap:EventAdd(event_data, true)
end)

Hooks:PostHook(SmokeScreenGrenade, "_detonate", "Heatmap_detonate_sicario_smoke", function(self, id)
	local pos = self._unit:position()
	local event_data = {"grenade", id, "sicario", math.round(pos.x), math.round(pos.y), math.round(pos.z), tweak_data.projectiles.smoke_screen_grenade.duration}
	
	HeatMap:EventAdd(event_data, true)
end)