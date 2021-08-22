
-- Handles player state tracking.

-- teamaidamage lua and playerdamagelua are worth looking at.

Hooks:PostHook(PlayerManager, "set_player_state", "Heatmap_set_player_state", function(self, state)
	local unit = self:player_unit()
	if unit then
		HeatMap:EventAdd({ "state", unit:id(), state})
	end
end)





-- Unneeded, for now.

-- Hooks:PostHook(PlayerManager, "spawned_player", "Heatmap_spawned_player", function(self, id, unit)
	-- HeatMap:EventAdd({ "player", "add", unit:id(), id}, true)
-- end)

-- Hooks:PostHook(PlayerManager, "player_destroyed", "Heatmap_player_destroyed", function(self, id)
	-- if unit then
		-- HeatMap:EventAdd({ "player", "rmv", id})
	-- end
-- end)