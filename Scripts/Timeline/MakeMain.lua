fusion = Fusion()
project = fusion:GetResolve():GetProjectManager():GetCurrentProject()

if not project then return end
project_id = project:GetUniqueId()

timeline = project:GetCurrentTimeline()
if not timeline then return end

main_timelines = fusion:GetData("main_timelines") or {}
main_timelines[project_id] = timeline:GetUniqueId()

fusion:SetData("main_timelines", main_timelines)
