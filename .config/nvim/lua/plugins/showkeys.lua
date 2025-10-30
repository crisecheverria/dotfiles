vim.pack.add({
	{ src = "https://github.com/NvChad/showkeys", opt = true },
}, { load = true })

require("showkeys").setup({ position = "top-right" })
