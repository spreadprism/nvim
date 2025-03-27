local overseer = function()
	local ok, _
	pcall(require, "overseer")
	if ok then
		return {
			{
				"overseer",
				unique = true,
				symbols = {
					[require("overseer").STATUS.RUNNING] = "󰦖 ",
				},
			},
		}
	end
end

return {
	overseer(),
}
