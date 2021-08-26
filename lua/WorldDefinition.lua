Hooks:PostHook(WorldDefinition, "init", "HeatmapDumpNav", function(self, params)
	if Global.game_settings and Global.game_settings.level_id and self._definition then
		local level_id = Global.game_settings.level_id
		local nav_data = self._definition.ai_nav_graphs
		local path = self:world_dir() .. nav_data.file
		
		HeatMap:DumpNavData(level_id, path)
	end
end)