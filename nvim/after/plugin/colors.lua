function ColorMyPencils(color)
  color = color or "melange"
  vim.cmd.colorscheme(color)

  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
  vim.api.nvim_set_hl(0, "LineNr", { bg = "#867462", fg = "#18181a" })
  vim.api.nvim_set_hl(0, "LineNrAbove", { bg = "#18181a", fg = "#867462" })
  vim.api.nvim_set_hl(0, "LineNrBelow", { bg = "#18181a", fg = "#867462" })
  vim.api.nvim_set_hl(0, "SignColumn", { bg = "#18181a" })
end

function SetColorColumnFromRubocop()
  local files = {'.rubocop.yml', '.rubocop_todo.yml'}
  local max_length
  for _, file_name in ipairs(files) do
    local rubocop_file = io.open(file_name, 'r')
    if rubocop_file then
      local previous_line
      for line in rubocop_file:lines() do
        if previous_line and previous_line:match('Layout/LineLength:') then
          max_length = tonumber(line:match('Max: (%d+)'))
          if max_length then
            break
          end
        end
        previous_line = line
      end
      rubocop_file:close()
    end
    if max_length then
      break
    end
  end
  vim.opt.colorcolumn = tostring(max_length or 120)
end

SetColorColumnFromRubocop()
ColorMyPencils()
