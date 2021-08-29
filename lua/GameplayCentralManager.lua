-- Level startup
Hooks:PostHook(GamePlayCentralManager, "init", "HeatmapInit", function(self)
	if HeatMap.record_heist == true then
		log("PDHeat: Simulation begin!")
		HeatMap.UpdateTrackPath()
		self._heatmap_update_t = 0
		-- Some of this might be up for organisation, its all Header.
		
		local heat_date = HeatMap.GetTrackDate()
		local job_data = managers.job
		local job_id = job_data and job_data:current_job_id() or "err"
		local contractor_id = job_data and job_data:current_contact_id() or "err"
		local difficulty = job_data and job_data:current_difficulty_stars() or "err"
		
		local level_data = Global.level_data
		local lvl_id = level_data and level_data.level_id or "err"
		local ghost_required = tweak_data.levels[lvl_id].ghost_required and tweak_data.levels[lvl_id].ghost_required or tweak_data.levels[lvl_id].ghost_required_visual and tweak_data.levels[lvl_id].ghost_required_visual or false
		local loud_optional = tweak_data.levels[lvl_id].ghost_bonus and tweak_data.levels[lvl_id].ghost_bonus > 0 or false
		local environment = tweak_data.levels[lvl_id].environment_effects and tweak_data.levels[lvl_id].environment_effects or nil
		
		local json_data = {
			start_date_time = heat_date,
			update_delay = HeatMap.update_delay,
			job_id = job_id,
			level_id = lvl_id,
			contractor_id = contractor_id,
			difficulty = difficulty,
			stealth_only = ghost_required,
			loud_only = not loud_optional,
			environment_effects = environment
		}
		
		if HeatMap.save_instant == true then
			HeatMap:ClearAll()
			HeatMap:Append(json.encode(json_data), true)
		else
			HeatMap.track_header = json_data
		end
		
		-- global event connector
		local global_events = {
			"police_called",
			"police_weapons_hot",
			"start_assault",
			"end_assault",
			"end_assault_late",
			"ecm_jammer_on",
			"ecm_jammer_off"
		}
		for _, event_value in pairs(global_events) do
			managers.mission:add_global_event_listener(
				event_value, {event_value},
				callback(self, HeatMap, "EventAddIgnoreDupes", {"glev", event_value})
			)
		end
	end
end)



-- Recording frame data, Collects players enemies ect...
Hooks:PostHook(GamePlayCentralManager, "update", "HeatmapUpdate", function(self, t, dt)
    if HeatMap.record_heist == true and self._heist_timer.running and (self._heatmap_update_t <= t) then
		if HeatMap.heist_started == false then
			HeatMap.heist_started = true
		end
		
        local last_frame = HeatMap.track_frames[#HeatMap.track_frames]
        local heatmap = {}
		
		local characters = {}
		
		-- Players [uID, X, Y, Z, R, tID]
		-- BUG: managers.criminals:characters() is based on the tweakdata order not the peer order.
		-- BUG: CriminalsManager:character_color_id_by_unit(unit) might work but seems bots will always be bot blue.
		for _, data in pairs(managers.criminals:characters()) do
			if data.taken and alive(data.unit) and data.unit:id() ~= -1 then
				local id = data.unit:id()
				local pos = data.unit:position()
				local rot
				if not data.unit:base().is_husk_player and not data.data.ai then
					rot = data.unit:camera():rotation()
				else
					rot = data.unit:rotation()
				end
				local exists_already = false
				local same_pos = false
				
				-- if valid last frame
				if last_frame and last_frame[1] and #last_frame[1] > 0 then
					-- for all characters in last frame
					for _, char_arr in pairs(last_frame[1]) do
						-- If character array has my ID continue
						if char_arr[1] == id then
							-- I exist now
							exists_already = true
							-- While we cant find the last position info we iterate backwards through older frames until we find the frame that contains our positions
							local back = 0
							while not same_pos or back < 8 do
								local tfb = HeatMap.track_frames[#HeatMap.track_frames-back]
								if tfb then
									for _, char_arr in pairs(tfb[1]) do
										if char_arr[1] == id then
											tfb = char_arr
											break
										end
									end
									if #tfb > 5 and tfb[2] == math.round(pos.x) and tfb[3] == math.round(pos.y) and tfb[4] == math.round(pos.z) and tfb[5] == math.round(rot:yaw()) then
										same_pos = true
										break
									else
										back = back + 1
									end
								else
									break
								end
							end
						end
					end
				end
				
				-- Save
				local char_data
				local tweak_id
				if exists_already then
					if same_pos then
						char_data = {id}
					else
						char_data = {id, math.round(pos.x), math.round(pos.y), math.round(pos.z), math.round(rot:yaw())}
					end
				else
					-- Get Tweakdata
					local heister = data.name
					local tweak_id = HeatMap:GetTrackListID(heister)
					if not tweak_id then
						tweak_id = #HeatMap.stringdex
						table.insert(HeatMap.stringdex, heister)
					end
					
					char_data = {id, math.round(pos.x), math.round(pos.y), math.round(pos.z), math.round(rot:yaw()), tweak_id}
				end
				table.insert(characters, char_data)
			end
		end
		
		
		-- Custom enemies and civilians both use identical functions, I should make a function to handle it multiple times
		-- Enemies [uID, X, Y, Z, R, tID]
		for _, data in pairs(managers.enemy:all_enemies()) do
			local id = data.unit:id()
			local pos = data.unit:position()
			local rot = data.unit:rotation()
			local exists_already = false
			local same_pos = false
			
			-- if valid last frame
			if last_frame and last_frame[1] and #last_frame[1] > 0 then
				-- for all characters in last frame
				for _, char_arr in pairs(last_frame[1]) do
					-- If character array has my ID continue
					if char_arr[1] == id then
						-- I exist now
						exists_already = true
						-- While we cant find the last position info we iterate backwards through older frames until we find the frame that contains our positions
						local back = 0
						while not same_pos or back < 8 do
							local tfb = HeatMap.track_frames[#HeatMap.track_frames-back]
							if tfb then
								for _, char_arr in pairs(tfb[1]) do
									if char_arr[1] == id then
										tfb = char_arr
										break
									end
								end
								if #tfb > 5 and tfb[2] == math.round(pos.x) and tfb[3] == math.round(pos.y) and tfb[4] == math.round(pos.z) and tfb[5] == math.round(rot:yaw()) then
									same_pos = true
									break
								else
									back = back + 1
								end
							else
								break
							end
						end
					end
				end
			end
			
			-- Save
			local char_data
			local tweak_id
			local grp_id
			if exists_already then
				if same_pos then
					char_data = {id}
				else
					char_data = {id, math.round(pos.x), math.round(pos.y), math.round(pos.z), math.round(rot:yaw())}
				end
			else
				-- Get Tweakdata
				local tweak = data.unit:base()._tweak_table
				tweak_id = HeatMap:GetTrackListID(tweak)
				if not tweak_id then
					tweak_id = #HeatMap.stringdex
					table.insert(HeatMap.stringdex, tweak)
				end
				
				-- Get Ai Group
				local grp = nil
				grp_id = nil
				if data.group and data.group.id then
					grp = data.group.id
					grp_id = HeatMap:GetTrackListID(grp)
					if not grp_id then
						grp_id = #HeatMap.stringdex
						table.insert(HeatMap.stringdex, grp)
					end
				end
				
				char_data = {id, math.round(pos.x), math.round(pos.y), math.round(pos.z), math.round(rot:yaw()), tweak_id, grp_id}
			end
			table.insert(characters, char_data)
		end
		
		
		-- Civilians [uID, X, Y, Z, R, tID]
		for _, data in pairs(managers.enemy:all_civilians()) do
			local id = data.unit:id()
			local pos = data.unit:position()
			local rot = data.unit:rotation()
			local exists_already = false
			local same_pos = false
			
			-- if valid last frame
			if last_frame and last_frame[1] and #last_frame[1] > 0 then
				-- for all characters in last frame
				for _, char_arr in pairs(last_frame[1]) do
					-- If character array has my ID continue
					if char_arr[1] == id then
						-- I exist now
						exists_already = true
						-- While we cant find the last position info we iterate backwards through older frames until we find the frame that contains our positions
						local back = 0
						while not same_pos or back < 8 do
							local tfb = HeatMap.track_frames[#HeatMap.track_frames-back]
							if tfb then
								for _, char_arr in pairs(tfb[1]) do
									if char_arr[1] == id then
										tfb = char_arr
										break
									end
								end
								if #tfb > 5 and tfb[2] == math.round(pos.x) and tfb[3] == math.round(pos.y) and tfb[4] == math.round(pos.z) and tfb[5] == math.round(rot:yaw()) then
									same_pos = true
									break
								else
									back = back + 1
								end
							else
								break
							end
						end
					end
				end
			end
			
			-- Save
			local char_data
			local tweak_id
			if exists_already then
				if same_pos then
					char_data = {id}
				else
					char_data = {id, math.round(pos.x), math.round(pos.y), math.round(pos.z), math.round(rot:yaw())}
				end
			else
				-- Get Tweakdata
				local tweak = data.unit:base()._tweak_table
				tweak_id = HeatMap:GetTrackListID(tweak)
				if not tweak_id then
					tweak_id = #HeatMap.stringdex
					table.insert(HeatMap.stringdex, tweak)
				end
				
				char_data = {id, math.round(pos.x), math.round(pos.y), math.round(pos.z), math.round(rot:yaw()), tweak_id}
			end
			table.insert(characters, char_data)
		end
		
		
		-- ADDS THE CHARACTERS WE JUST FOUND
		table.insert(heatmap, characters)
		
		
		-- Misc Units (FWB ball, Shark, Turrets, Vehicles... Anything that we want to track without calling it a character.)
		local units = {}
		if #HeatMap.units_to_track > 0 then
			for i, unit in pairs(HeatMap.units_to_track) do
				if alive(unit) then
					local pos = unit:position()
					local unit_data = {unit:id(), math.round(pos.x), math.round(pos.y), math.round(pos.z)}
					table.insert(units, unit_data)
				else
					HeatMap.units_to_track[i] = nil
				end
			end
		end
		table.insert(heatmap, units)
		
		
		-- Events
		if #HeatMap.frame_events > 0 then
			table.insert(heatmap, HeatMap.frame_events)
			HeatMap.frame_events = {}
		end
		
		
        if #heatmap > 0 then
			if HeatMap.track_save_per_frame == true then
				HeatMap:Append(json.encode(heatmap), true)
			else
				HeatMap:Append(heatmap, false)
			end
        end
        self._heatmap_update_t = t + HeatMap.update_delay
	end
end)