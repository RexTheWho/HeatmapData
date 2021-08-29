_G.HeatMap = _G.HeatMap or {
	record_heist = true,
    update_delay = 0.125,
-- update_delay quality: super_low = 1.0, low = 0.75, 2fps = 0.5, 4fps = 0.25, 8fps = 0.125, 15fps = 0.067
    filename = ModPath,
    rec_folder = "records",
	nav_folder = "nav_data",
	track_save_per_frame = false,
	
	track_path = "",
	heist_started = false,
	track_header = {},
	stringdex = {},
	track_frames = {},
	frame_events = {},
	units_to_track = {}
}


-- 
-- File headers are made on level load regardless of settings, for now they can be tweaked during play if track_save_per_frame is false.
-- 'track_header' is preserved until its saved where it is thrown away afterwards.
-- 'track_frames' is preserved until its saved where it is thrown away afterwards.
-- 'track_events' will filter specific events and can only happen once per frame. Applies on level load.
-- 


-- I save the path on level init for the sake of not spamming this.
function HeatMap:GetTrackPath()
	local lvl_id = Global.level_data and Global.level_data.level_id or "err"
	local dates = Application:date("%Y-%m-%d_%H_%M_%S")
	local file = HeatMap.filename..HeatMap.rec_folder.."/"..dates.."_"..lvl_id..".pdheat"
	return file
end

function HeatMap:GetTrackDirectory()
	return HeatMap.filename..HeatMap.rec_folder
end


-- Same as GetTrackPath but sets the track path directly.
function HeatMap:UpdateTrackPath()
	local lvl_id = Global.level_data and Global.level_data.level_id or "err"
	local dates = Application:date("%Y-%m-%d_%H_%M_%S")
	local file = HeatMap.filename..HeatMap.rec_folder.."/"..dates.."_"..lvl_id..".pdheat"
	HeatMap.track_path = file
end


-- Simple date get
function HeatMap:GetTrackDate()
	return Application:date("%Y-%m-%d_%H_%M_%S")
end


-- We dont support multiple heists per recording, Used to clear any doubles.
function HeatMap:ClearAll()
	if HeatMap.track_path ~= "" then
		local file = io.open(HeatMap.track_path, "w+")
		if file then
			file:write("")
			file:close()
		end
	end
end


-- Add data, if we have save per frame on itll save instantly, otherwise should append to a temporary data value until it needs to be saved.
function HeatMap:Append(data, save_instant)
	if save_instant == true and HeatMap.track_path ~= "" then
		local file = io.open(HeatMap.track_path, "a")
		if file then
			file:write(data.."\n")
			file:close()
		end
	else
		table.insert(HeatMap.track_frames, data)
    end
end


-- Used for saving whole track data
function HeatMap:SaveTrackData()
	log("PDHeat: Saving track data!")
	local file = io.open(HeatMap.track_path, "a")
	
	if not file then
		-- I should probs make this use a proper dir check instead of a valid file but whatever...
		log("PDHeat: Missing records folder, generating a new one.")
		os.execute("mkdir " .. string.gsub(HeatMap.GetTrackDirectory(), "/", "\\") .. "\\")
		file = io.open(HeatMap.track_path, "a")
	end
	
	if file then
		HeatMap.track_header.stringdex = HeatMap.stringdex
		if HeatMap.track_save_per_frame == false then
			HeatMap.track_header.frame_total = #HeatMap.track_frames
			HeatMap:Append(json.encode(HeatMap.track_header), true)
		end
		
		for i, data in pairs(HeatMap.track_frames) do
			file:write( json.encode(data).."\n" )
		end
		
		log("PDHeat: Saved track data!")
		file:close()
		HeatMap.track_header = {}
		HeatMap.stringdex = {}
		HeatMap.track_frames = {}
	else
		log("PDHeat: Failed to save tracking data!")
	end
end

-- Exports the navigation data of the current heist if not already present
function HeatMap:DumpNavData(level_id, path)
	local output_path = Path:Combine(HeatMap.filename, HeatMap.nav_folder, level_id .. ".nav_data")
	
	if not FileIO:Exists(output_path) then
		if DB:has("nav_data", path) and managers.worlddefinition then
			local data = managers.worlddefinition:_serialize_to_script("nav_data", path)
			FileIO:WriteScriptData(output_path, data, "generic_xml")
			log("PDHeat: Converted Nav Data!")
		end
	end
end

-- Add events to the frames event array.
-- ToDo: I would like to implement a value to better mark events and when they happen;
--		eg. ["obj","start","obj_id",0-9]
--		Where a single number defines where in the time frame it was triggered.
--		This will leave even 1s recording quality to at least have 0.1s details for relatively cheap.
function HeatMap:EventAdd(event_data, before_spawn)
	if HeatMap.heist_started or before_spawn and before_spawn == true then
		-- log("PDHeat: Appending frame event.")
		table.insert(HeatMap.frame_events, event_data)
	end
end


-- Add events while ignoring duplicates. ["event_type", "value_were_filtering"]
function HeatMap:EventAddIgnoreDupes(event_data)
	local function has_array(tab, val)
		for index, value in ipairs(tab) do
			if value[1] == val[1] then
				return true
			end
		end
		return false
	end
	
	if HeatMap.heist_started and not has_array(HeatMap.frame_events, event_data) then
		-- log("PDHeat: Appending frame event. (no dupes)")
		table.insert(HeatMap.frame_events, event_data)
	end
end


-- Add tracker to unit ID
function HeatMap:UnitAddTracker(unit_id)
	if HeatMap.heist_started then
		-- log("PDHeat: Appending unit tracker.")
		table.insert(HeatMap.units_to_track, unit_id)
	end
end


-- Remove tracker to unit ID
function HeatMap:UnitRemoveTracker(unit_id)
	if HeatMap.heist_started and HeatMap.units_to_track[unit_id] then
		table.remove( HeatMap.units_to_track, unit_id )
	end
end


-- shark 'root'
-- Unfinished
-- Add tracker to unit ID at selected bone (ToDo)
function HeatMap:UnitAddTrackerOnBone(unit_id, bone_id)
	if HeatMap.heist_started then
		-- log("PDHeat: Appending unit object tracker.")
		local object_id = unit_id:get_object(Idstring(bone_id))
		table.insert(HeatMap.units_to_track, object_id)
	end
end


-- Tracklist
function HeatMap:GetTrackListID(character)
	for i, value in ipairs(HeatMap.stringdex) do
		if value == character then
			return i-1
		end
	end
	return false
end




