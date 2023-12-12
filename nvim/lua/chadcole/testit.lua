local function visual_selection_range()
  local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
  local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
  if csrow < cerow or (csrow == cerow and cscol <= cecol) then
    return csrow, cscol, cerow, cecol
  else
    return cerow, cecol, csrow, cscol
  end
end

function TestIt()
  local _, full_path = string.match(vim.fn.expand('%:p'), '.*github.com/([%w-]+/[%w-]+)/(.*)')
  local extension = vim.fn.expand('%:e')

  if(not full_path or not extension) then return end
  local test_cmd = ''

  if (extension == 'rb')
  then
    test_cmd = 'dev test ' .. full_path
  else
    -- We (you) don't support this yet
    return
  end

  if (vim.fn.mode() == 'V')
  then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', false, true, true), 'nx', false)
    local csrow, _, _, _ = visual_selection_range()

    test_cmd = test_cmd .. ':' .. csrow
  end

  vim.cmd(':let @+ = "' .. test_cmd .. '"')
end
