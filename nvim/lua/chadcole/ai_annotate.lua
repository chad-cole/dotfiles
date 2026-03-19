-- ai_annotate.lua — visual-select code, pop a floating note, batch for Claude
local M = {}

-- All annotations for this session
-- { { file, start_line, end_line, selected_text, note }, ... }
M.annotations = {}

local ns = vim.api.nvim_create_namespace("ai_annotate")

-- Resolve the real file path from diffview buffer names
-- Diffview uses names like "diffview:///abs/path" or "diffview://sha/path"
local function resolve_file_path(bufname)
  if not bufname or bufname == "" then
    return "[unnamed]"
  end

  -- diffview:// panel buffers — extract the real path
  local dv_path = bufname:match("^diffview://[^/]*(/.+)$")
  if dv_path then
    -- Could be an absolute path or relative; mark it as a diff-side annotation
    local side = "working"
    if bufname:match("^diffview://[0-9a-f]") then
      side = "old"
    end
    return dv_path, side
  end

  return bufname, "file"
end

-- Detect if we're in a PR review worktree, return PR number or nil
local function detect_pr()
  local cwd = vim.fn.getcwd()
  local pr = cwd:match("/reviews/pr%-(%d+)")
  return pr
end

local function get_visual_selection()
  -- Get the visual selection range and text
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local end_line = end_pos[2]
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  return start_line, end_line, table.concat(lines, "\n")
end

function M.open_note()
  local start_line, end_line, selected_text = get_visual_selection()
  local source_buf = vim.api.nvim_get_current_buf()
  local raw_name = vim.api.nvim_buf_get_name(source_buf)
  local source_file, source_side = resolve_file_path(raw_name)

  -- Build prompt
  local side_label = ""
  if source_side == "old" then
    side_label = " [old side]"
  elseif source_side == "working" then
    side_label = " [new side]"
  end

  local prompt = "@ai (lines " .. start_line .. "-" .. end_line .. ")" .. side_label .. ": "

  vim.ui.input({ prompt = prompt }, function(note)
    if not note or vim.fn.trim(note) == "" then
      vim.notify("Annotation cancelled", vim.log.levels.WARN)
      return
    end
    note = vim.fn.trim(note)
    table.insert(M.annotations, {
      file = source_file,
      side = source_side,
      start_line = start_line,
      end_line = end_line,
      selected_text = selected_text,
      note = note,
    })
    -- Add virtual text marker in the source buffer (pcall for read-only buffers)
    pcall(vim.api.nvim_buf_set_extmark, source_buf, ns, start_line - 1, 0, {
      virt_text = { { " @ai: " .. note, "DiagnosticInfo" } },
      virt_text_pos = "eol",
    })
    vim.notify("Annotation added (" .. #M.annotations .. " total)", vim.log.levels.INFO)
  end)
end

function M.collect()
  if #M.annotations == 0 then
    vim.notify("No annotations to collect", vim.log.levels.WARN)
    return
  end

  local cwd = vim.fn.getcwd()
  local pr = detect_pr()
  local lines
  if pr then
    lines = { "# PR Review: shop/world#" .. pr, "" }
  else
    lines = { "# Batched Change Requests", "" }
  end

  for i, a in ipairs(M.annotations) do
    -- Make path relative to cwd
    local rel = a.file
    if vim.startswith(rel, cwd) then
      rel = string.sub(rel, #cwd + 2)
    end

    local side_tag = ""
    if a.side == "old" then
      side_tag = " *(old side — was removed/changed)*"
    elseif a.side == "working" then
      side_tag = " *(new side — current code)*"
    end
    table.insert(lines, "## " .. i .. ". " .. rel .. ":" .. a.start_line .. "-" .. a.end_line .. side_tag)
    table.insert(lines, "")
    table.insert(lines, "**Note:** " .. a.note)
    table.insert(lines, "")
    table.insert(lines, "```")
    table.insert(lines, a.selected_text)
    table.insert(lines, "```")
    table.insert(lines, "")
  end

  local output = table.concat(lines, "\n")

  -- Copy to system clipboard
  vim.fn.setreg("+", output)
  vim.notify(#M.annotations .. " annotations copied to clipboard", vim.log.levels.INFO)
  M.clear()
end

function M.clear()
  -- Clear all extmarks across all buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    end
  end
  M.annotations = {}
  vim.notify("All annotations cleared", vim.log.levels.INFO)
end

function M.count()
  vim.notify(#M.annotations .. " annotation(s)", vim.log.levels.INFO)
end

-- Commands
vim.api.nvim_create_user_command("AiCollect", function() M.collect() end, {})
vim.api.nvim_create_user_command("AiClear", function() M.clear() end, {})
vim.api.nvim_create_user_command("AiCount", function() M.count() end, {})

-- Keymap: visual mode -> open floating note
vim.keymap.set("v", "<leader>ai", function()
  -- Exit visual mode first so '< and '> marks are set
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
  vim.schedule(M.open_note)
end, { desc = "Add AI annotation to selection" })

-- Ensure keymaps work in diffview buffers (diffview sets its own keymaps per buffer)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "DiffviewFiles", "DiffviewFileHistory" },
  callback = function(ev)
    vim.keymap.set("v", "<leader>ai", function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
      vim.schedule(M.open_note)
    end, { buffer = ev.buf, desc = "Add AI annotation to selection" })
  end,
})
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "diffview://*",
  callback = function(ev)
    vim.keymap.set("v", "<leader>ai", function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
      vim.schedule(M.open_note)
    end, { buffer = ev.buf, desc = "Add AI annotation to selection (diffview)" })
    vim.keymap.set("n", "<leader>ais", function() M.collect() end, { buffer = ev.buf, desc = "AI collect (send)" })
    vim.keymap.set("n", "<leader>aic", function() M.clear() end, { buffer = ev.buf, desc = "AI clear annotations" })
    vim.keymap.set("n", "<leader>ait", function() M.count() end, { buffer = ev.buf, desc = "AI annotation total/count" })
  end,
})

-- Normal mode shortcuts
vim.keymap.set("n", "<leader>ais", function() M.collect() end, { desc = "AI collect (send)" })
vim.keymap.set("n", "<leader>aic", function() M.clear() end, { desc = "AI clear annotations" })
vim.keymap.set("n", "<leader>ait", function() M.count() end, { desc = "AI annotation total/count" })

return M
