
-- FirstAidKit Spawn
Hooks:PostHook(FirstAidKitBase, "setup", "Heatmap_spawn_fak", function(self, bits)
	local upgrade_lvl, auto_recovery = self:_get_upgrade_levels(bits)
	local id = self._unit:id()
	local pos = self._unit:position()
	local recover_radius = nil
	
	if auto_recovery == 1 then
		recover_radius = tweak_data.upgrades.values.first_aid_kit.first_aid_kit_auto_recovery[1]
	end
	
	local event_data = {"deploy", id, "first_aid_kit", math.round(pos.x), math.round(pos.y), math.round(pos.z), recover_radius}
	HeatMap:EventAdd(event_data, true)
end)

-- FirstAidKit Used
Hooks:PostHook(FirstAidKitBase, "Remove", "Heatmap_used_fak", function(self, obj)
	local id = self._unit:id()
	HeatMap:EventAdd({"deploy", id, "empty"}, true)
end)
