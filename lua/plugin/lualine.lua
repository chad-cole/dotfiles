require('lualine').setup {
  options = {
      icons_enabled = true,
      theme  = 'gruvbox',
      section_separators = { left = '', right = '' },
      component_separators = { left = '', right = '' }
  },
  sections = {
      lualine_a = { 'mode'},
      lualine_b = {
          {
              'buffers',
              show_filename_only = true,   -- Shows shortened relative path when set to false.
              hide_filename_extension = false,   -- Hide filename extension when set to true.
              show_modified_status = true, -- Shows indicator when the buffer is modified.
              mode = 0,
              max_length = vim.o.columns * 2 / 3, -- Maximum width of buffers component,

              symbols = {
                  modified = ' 💩',
                  alternate_file = '#', -- Text to show to identify the alternate file
                  directory =  '',     -- Text to show when the buffer is a directory
              },
          },
      },
      lualine_c = { 'branch' },
      lualine_d = { 'diff' },
      lualine_e = { 'fileformat' },
      lualine_x = {},
      lualine_y = { 'filetype', 'progress' },
      lualine_z = {
          { 'location', separator = { right = '' }, left_padding = 2 },
      },
  },
  inactive_sections = {
      lualine_a = { 'filename' },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = { 'location' },
  },
  tabline = {},
  extensions = {},
}
