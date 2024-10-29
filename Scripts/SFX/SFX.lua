--[[
This is a more complete version of the SFX script.
It maps sound files in the media pool on the first run, storing the data in the fusion global,
allowing for faster subsequent runs.

In a perfect world, BMD would provide a way to retrieve MP items by name or location,
but this is not a perfect world.
]]--
local function setup()
    local fusion = Fusion()
    local project = fusion:GetResolve():GetProjectManager():GetCurrentProject()
    if not project then return end

    return {
        fusion = fusion,
        project = project,
        media_pool = project:GetMediaPool(),
        timeline = project:GetCurrentTimeline(),
        fps = project:GetCurrentTimeline():GetSetting("timelineFrameRate"),
        project_id = project:GetUniqueId()
    }
end

local CONFIG = {
    OMIT_EXT = true, -- If true, you can pass clip names without extensions e.g. "audio" instead of "audio.wav"
    FORMATS = {".wav", ".mp3"}, -- Only these formats will be mapped
    DEFAULT_CLIP_NAME = "audio", -- If no clip name is provided, this will be used
    DEFAULT_TRACK = 1, -- If no index is provided, this track will be used
    FALLBACK_TO_HIGHEST_TRACK = false, -- If the specified track exceeds the track count, use the highest available instead of DEFAULT_TRACK
}

local function shallow_copy(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end

local function hash_path(path)
    local hash = #path
    for i, str in ipairs(path) do
        for j = 1, #str do
            hash = hash + string.byte(str, j) * i
        end
    end
    return hash
end

local function tc_to_frames(timecode, fps)
    local h, m, s, f = timecode:match("(%d+):(%d+):(%d+):(%d+)")
    return fps * (h * 3600 + m * 60 + s) + f
end

local function find_clip(media_pool, name, path)
    local folder = media_pool:GetRootFolder()
    
    for _, dir in ipairs(path) do
        for _, sub in ipairs(folder:GetSubFolders()) do
            if sub:GetName() == dir then
                folder = sub
                break
            end
        end
    end

    for _, clip in ipairs(folder:GetClipList()) do
        if clip:GetName() == name then
            return clip
        end
    end
end

local function map_folder(folder, path, is_root, sfx_map)
    local current_path = {}
    if not is_root then
        current_path = shallow_copy(path)
        table.insert(current_path, folder:GetName())
    end

    local path_hash = hash_path(current_path)

    for _, item in ipairs(folder:GetClipList()) do
        local name = item:GetName()
        if sfx_map[name] and sfx_map[name].hash == path_hash then goto continue end
        
        for _, format in ipairs(CONFIG.FORMATS) do
            if name:sub(-#format) == format then
                local ref = CONFIG.OMIT_EXT and name:sub(1, -#format - 1) or name
                sfx_map[ref] = {
                    path = current_path,
                    hash = path_hash,
                    ext = format
                }
                break
            end
        end
        ::continue::
    end

    for _, sub in ipairs(folder:GetSubFolders()) do
        map_folder(sub, current_path, false, sfx_map)
    end
end

local function add_clip_to_timeline(clip, track_index, timeline, fps)
    local duration = tc_to_frames(clip:GetClipProperty("Duration"), fps)
    local record_frame = tc_to_frames(timeline:GetCurrentTimecode(), fps)

    local track_count = timeline:GetTrackCount("audio")
    if track_index > track_count then
        track_index = CONFIG.FALLBACK_TO_HIGHEST_TRACK and track_count or CONFIG.DEFAULT_TRACK
    end

    return {{
        mediaPoolItem = clip,
        startFrame = 0,
        endFrame = duration,
        trackIndex = track_index,
        recordFrame = record_frame
    }}
end

local function main(clip_name, track_index)
    local env = setup()
    if not env or not env.timeline then return end

    local sfx_map = env.fusion:GetData("sfx_map") or {project_id = env.project_id}
    
    if sfx_map.project_id ~= env.project_id or not sfx_map[clip_name] then
        sfx_map = {project_id = env.project_id}
        map_folder(env.media_pool:GetRootFolder(), {}, true, sfx_map)
        env.fusion:SetData("sfx_map", sfx_map)
    end

    if sfx_map[clip_name] then
        local clip = find_clip(env.media_pool, 
                             clip_name .. sfx_map[clip_name].ext, 
                             sfx_map[clip_name].path)
        if clip then
            env.media_pool:AppendToTimeline(
                add_clip_to_timeline(clip, track_index, env.timeline, env.fps)
            )
        end
    end
end

main(arg[1] or CONFIG.DEFAULT_CLIP_NAME, tonumber(arg[2]) or CONFIG.DEFAULT_TRACK)