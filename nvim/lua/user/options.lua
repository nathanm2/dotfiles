local options = {
	wildmode = "longest:full,full"
}

for k, v in pairs(options) do
	vim.opt[k] = v
end
