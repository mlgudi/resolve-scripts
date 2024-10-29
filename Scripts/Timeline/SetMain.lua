fusion = Fusion()
project = fusion:GetResolve():GetProjectManager():GetCurrentProject()
if not project then return end

tl_id = fusion:GetData("main_timelines")[project:GetUniqueId()]
if not tl_id then return end

for i=1, project:GetTimelineCount() + 1 do
    tl = project:GetTimelineByIndex(i)
    if tl:GetUniqueId() == tl_id then
        project:SetCurrentTimeline(tl)
        break
    end
end

project:SetCurrentTimeline(main_timeline)
