-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Run code in terminal
vim.keymap.set("n", "<leader>r", function()
  local filetype = vim.bo.filetype
  local filepath = vim.fn.expand("%:p")
  local filename = vim.fn.expand("%:t")
  local filename_noext = vim.fn.expand("%:t:r")
  local cmd = ""
  
  if filetype == "python" then
    cmd = "python3 " .. vim.fn.shellescape(filepath)
  elseif filetype == "c" then
    cmd = "gcc " .. vim.fn.shellescape(filepath) .. " -o " .. vim.fn.shellescape(filename_noext) .. " && ./" .. vim.fn.shellescape(filename_noext)
  elseif filetype == "cpp" then
    cmd = "g++ " .. vim.fn.shellescape(filepath) .. " -o " .. vim.fn.shellescape(filename_noext) .. " && ./" .. vim.fn.shellescape(filename_noext)
  elseif filetype == "java" then
    cmd = "javac " .. vim.fn.shellescape(filepath) .. " && java " .. vim.fn.shellescape(filename_noext)
  elseif filetype == "javascript" then
    cmd = "node " .. vim.fn.shellescape(filepath)
  elseif filetype == "typescript" then
    cmd = "ts-node " .. vim.fn.shellescape(filepath)
  elseif filetype == "go" then
    cmd = "go run " .. vim.fn.shellescape(filepath)
  elseif filetype == "rust" then
    cmd = "rustc " .. vim.fn.shellescape(filepath) .. " -o " .. vim.fn.shellescape(filename_noext) .. " && ./" .. vim.fn.shellescape(filename_noext)
  elseif filetype == "ruby" then
    cmd = "ruby " .. vim.fn.shellescape(filepath)
  elseif filetype == "php" then
    cmd = "php " .. vim.fn.shellescape(filepath)
  elseif filetype == "lua" then
    cmd = "lua " .. vim.fn.shellescape(filepath)
  elseif filetype == "sh" or filetype == "bash" then
    cmd = "bash " .. vim.fn.shellescape(filepath)
  elseif filetype == "zsh" then
    cmd = "zsh " .. vim.fn.shellescape(filepath)
  else
    print("No run command configured for filetype: " .. filetype)
    return
  end
  
  vim.cmd("split | terminal " .. cmd)
  vim.cmd("startinsert")
end, { desc = "Run code in terminal" })

-- View image with viu
vim.keymap.set("n", "<leader>iv", function()
  local filepath = vim.fn.expand("%:p")
  vim.cmd("split | terminal viu " .. vim.fn.shellescape(filepath))
end, { desc = "View image" })
