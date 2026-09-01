plugin("atlas")
	:opts(function()
		local base = {
			-- Provider credentials/connection are top-level; a provider is
			-- enabled by being present here.
			providers = {
				github = {},
			},
			pulls = {
				diff = {
					open_cmd = "CodeDiff",
				},
			},
		}
		local jira_base_url = vim.env.JIRA_BASE_URL
		local jira_email = vim.env.JIRA_EMAIL
		local jira_api_token = vim.env.JIRA_API_TOKEN
		if jira_base_url and jira_email and jira_api_token then
			base.providers.jira = {
				base_url = jira_base_url,
				email = jira_email,
				token = jira_api_token,
			}
		end
		return base
	end)
	:event("DeferredUIEnter")
