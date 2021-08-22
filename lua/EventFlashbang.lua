
-- Handles police-on-player flashbang tracking.

Hooks:PostHook(QuickFlashGrenade, "make_flash", "Heatmap_make_flash", function(self, detonate_pos, range)
	if HeatMap.record_heist == true then
		local range = range or 1000
		local pos = detonate_pos
		local event = { "flashbang", math.round(pos.x), math.round(pos.y), math.round(pos.z), range }
		HeatMap:EventAdd(event)
	end
end)