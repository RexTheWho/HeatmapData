
-- Handles bag tracking.

Hooks:PostHook(PlayerManager, "sync_carry_data", "Heatmap_sync_carry_data", function(self, unit, carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer_id)
	local event_data = unit
	HeatMap:UnitAddTracker(event_data)
end)