--[[
  project-page.lua
  Builds the layout of every project page from its front matter, so each
  projects/<name>/index.qmd only needs YAML (and optionally extra text).
  Runs only on pages that have a `course:` field.

  Fields read: title, description, categories (first one = subject), image,
  course, course-name, school, term, team, tools (list), review (true/false),
  materials (list of: label, file OR url, type = pdf | site | code | link)
]]

local stringify = pandoc.utils.stringify

local function s(x)
  if x == nil then return nil end
  local v = stringify(x)
  if v == "" then return nil end
  return v
end

local function esc(t)
  return (tostring(t):gsub('[&<>"]', { ["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;", ['"'] = "&quot;" }))
end

local subject_key = {
  ["Data Science"] = "ds", ["Economics"] = "econ",
  ["Mathematics"] = "math", ["Computer Science"] = "cs"
}

local function list(x)
  if x == nil then return {} end
  if pandoc.utils.type(x) == "List" or type(x) == "table" and x[1] ~= nil then return x end
  return { x }
end

local function raw(html) return pandoc.RawBlock("html", html) end

function Pandoc(doc)
  local m = doc.meta
  if m.course == nil then return nil end

  local title = s(m.title) or ""
  local cats = list(m.categories)
  local subject = s(cats[1]) or "Data Science"
  local key = subject_key[subject] or "ds"
  local course = s(m.course) or ""
  local course_name = s(m["course-name"])
  local school = s(m.school)
  local term = s(m.term)
  local team = s(m.team)
  local thumb = s(m.image)

  -- tools
  local tools_html = {}
  for _, t in ipairs(list(m.tools)) do
    tools_html[#tools_html + 1] = '<span class="lh-tool">' .. esc(stringify(t)) .. "</span>"
  end
  local tools = '<div class="lh-tools">' .. table.concat(tools_html) .. "</div>"

  -- materials: buttons + viewer tabs
  local buttons, tabs, labels = {}, {}, {}
  for i, mat in ipairs(list(m.materials)) do
    local label = s(mat.label) or "File"
    local href = s(mat.file) or s(mat.url) or "#"
    local mtype = s(mat.type) or "link"
    local cls = (i == 1) and "lh-btn primary" or "lh-btn"
    local text, tag
    if mtype == "pdf" then
      text = "Open " .. esc(label:lower()); tag = '<span class="lh-mono">PDF</span>'
    elseif mtype == "site" then
      text = "Launch " .. esc(label:lower()) .. " ↗"; tag = ""
    elseif mtype == "code" then
      text = esc(label) .. " ↗"; tag = '<span class="lh-mono">code</span>'
    else
      text = esc(label) .. " ↗"; tag = ""
    end
    buttons[#buttons + 1] = string.format('<a class="%s" href="%s" target="_blank" rel="noopener">%s%s</a>', cls, esc(href), text, tag)
    if mtype == "pdf" or mtype == "site" then
      tabs[#tabs + 1] = string.format('<button type="button" data-type="%s" data-src="%s" aria-pressed="false">%s</button>', mtype, esc(href), esc(label))
    end
    labels[#labels + 1] = esc(label)
  end

  -- facts box
  local facts = { '<div class="lh-facts"><dl>' }
  facts[#facts + 1] = "<div><dt>Course</dt><dd>" .. esc(course) .. (course_name and (": " .. esc(course_name)) or "") .. "</dd></div>"
  if school then facts[#facts + 1] = "<div><dt>School</dt><dd>" .. esc(school) .. "</dd></div>" end
  if term then facts[#facts + 1] = "<div><dt>When</dt><dd>" .. esc(term) .. "</dd></div>" end
  if team then facts[#facts + 1] = "<div><dt>Team</dt><dd>" .. esc(team) .. "</dd></div>" end
  if #tools_html > 0 then facts[#facts + 1] = "<div><dt>Tools</dt><dd>" .. tools .. "</dd></div>" end
  if #labels > 0 then facts[#facts + 1] = "<div><dt>Materials</dt><dd>" .. table.concat(labels, ", ") .. "</dd></div>" end
  facts[#facts + 1] = "</dl></div>"

  -- body: the description first, then any extra text written below the front matter
  local body = pandoc.Blocks({})
  if m.description ~= nil then
    local d = m.description
    if pandoc.utils.type(d) == "Blocks" then body:extend(d)
    elseif pandoc.utils.type(d) == "Inlines" then body:insert(pandoc.Para(d))
    else body:insert(pandoc.Para(pandoc.Inlines(stringify(d)))) end
  end
  for _, b in ipairs(doc.blocks) do
    if not (b.t == "RawBlock" and b.text:match("^%s*<!%-%-.-%-%->%s*$")) then body:insert(b) end
  end

  local out = pandoc.Blocks({})
  out:insert(raw(string.format(
    '<div class="lh-block"><div class="lh-wrap lh-project" style="--c: var(--%s)">' ..
    '<a class="lh-back" href="../../projects.html">← All projects</a>' ..
    '<div class="lh-detail"><div>' ..
    '<div class="lh-meta" style="justify-content:flex-start;gap:14px"><span class="subj">%s</span><span>%s%s</span></div>' ..
    '<h1>%s</h1><div class="lh-lead">',
    key, esc(subject), esc(course), term and (" · " .. esc(term)) or "", esc(title))))
  out:extend(body)
  local after = '</div><div class="lh-materials">' .. table.concat(buttons) .. "</div>"
  if m.review == true then
    after = after .. '<div class="lh-draftnote"><strong>Draft text.</strong> Review this summary, then delete the <code>review: true</code> line in this page\'s index.qmd.</div>'
  end
  after = after .. "</div>" .. table.concat(facts) .. "</div>"
  if #tabs > 0 then
    after = after .. string.format(
      '<section class="lh-viewer" data-lh-viewer data-thumb="%s"><div class="lh-viewer-bar"><div class="tabs">%s</div>' ..
      '<a data-open href="#" target="_blank" rel="noopener">Open in new tab ↗</a></div>' ..
      '<div class="lh-stage">%s</div></section>',
      thumb and esc(thumb) or "", table.concat(tabs),
      thumb and ('<img src="' .. esc(thumb) .. '" alt="">') or "")
  end
  after = after .. "</div></div>"
  out:insert(raw(after))
  doc.blocks = out
  return doc
end
