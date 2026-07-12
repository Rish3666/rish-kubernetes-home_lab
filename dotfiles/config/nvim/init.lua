-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Window navigation mappings
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left split window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to down split window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to up split window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right split window' })