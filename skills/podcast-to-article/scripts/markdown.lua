-- Pandoc filter for the Markdown export: maps the article template's styled
-- components (masthead, .box, .note, <dl>) onto plain Markdown equivalents.

local function emph_paras(blocks)
  return blocks:walk({ Para = function(p) return pandoc.Para({ pandoc.Emph(p.content) }) end })
end

function Div(div)
  local c = div.classes
  if c:includes("masthead") then
    -- kicker, h1, dek, meta: italicise the dek (the Para after the title), then a rule.
    -- The meta <div> has already been unwrapped to a Plain block, so it stays upright.
    local out, seen_h1 = pandoc.Blocks({}), false
    for _, b in ipairs(div.content) do
      if b.t == "Header" then
        seen_h1 = true; out:insert(b)
      elseif seen_h1 then
        out:extend(emph_paras(pandoc.Blocks({ b })))
      else
        out:insert(b)
      end
    end
    out:insert(pandoc.HorizontalRule())
    return out
  elseif c:includes("box") then
    return pandoc.BlockQuote(div.content)
  elseif c:includes("note") then
    local out = pandoc.Blocks({ pandoc.HorizontalRule() })
    out:extend(emph_paras(div.content))
    return out
  end
  return div.content
end

-- GFM has no definition lists: render each entry as "**Term** — definition".
function DefinitionList(dl)
  local out = pandoc.Blocks({})
  for _, item in ipairs(dl.content) do
    local term, defs = item[1], item[2]
    local inlines = pandoc.Inlines({ pandoc.Strong(term), pandoc.Str(" —"), pandoc.Space() })
    for i, def in ipairs(defs) do
      for j, b in ipairs(def) do
        if i == 1 and j == 1 and (b.t == "Para" or b.t == "Plain") then
          inlines:extend(b.content); out:insert(pandoc.Para(inlines))
        else
          out:insert(b)
        end
      end
    end
  end
  return out
end
