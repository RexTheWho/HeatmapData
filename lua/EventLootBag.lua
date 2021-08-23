
-- Handles bag tracking.

Hooks:PostHook(PlayerManager, "sync_carry_data", "Heatmap_sync_carry_data", function(self, unit)
	local event_data = unit
	HeatMap:UnitAddTracker(event_data)
end)