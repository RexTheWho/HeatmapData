-- Bag secured?
Hooks:PostHook(ElementCarry, "on_executed", "Heatmap_mission_end_on_executed", function(self, instigator)
	if self._values.enabled or alive(instigator) then
		if self._values.operation == "secure" or self._values.operation == "secure_silent" then
			HeatMap.AddBagSecured()
		end
	end
end)
