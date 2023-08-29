local function visual_selection_range()
  local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
  local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
  if csrow < cerow or (csrow == cerow and cscol <= cecol) then
    return csrow, cscol, cerow, cecol
  else
    return cerow, cecol, csrow, cscol
  end
end

local function branch_name(file_path, use_primary)
  local branch = nil
  if(file_path)
  then
    if use_primary
    then
      local cmd = "(cd " .. file_path .. " && git rev-parse --abbrev-ref origin/HEAD 2> /dev/null | tr -d '\n' )"
      branch = string.match(vim.fn.system(cmd), 'origin/(%w+)')
    else
      branch = vim.fn.system("(cd " .. file_path .. " && git branch --show-current 2> /dev/null | tr -d '\n' )")
    end
  else
      branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
  end

  return ((branch ~= "") and branch) or nil
end

function CopyGithubURL(use_primary)
  local repo, path_uri = string.match(vim.fn.expand('%:p'), '.*github.com/([%w-]+/[%w-]+)/(.*)')
  local branch = branch_name(vim.fn.expand('%:h'), use_primary)

  if(not repo or not path_uri or not branch) then return end

  local url = 'https://github.com/' .. repo .. '/blob/' .. branch .. '/' .. path_uri

  if(vim.fn.mode() == 'V')
  then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', false, true, true), 'nx', false)
    local csrow, _, cerow, _ = visual_selection_range()
    url = url .. '#L' .. csrow .. '-L' .. cerow
  end
  vim.cmd(':let @+ = "' .. url .. '"')
end
