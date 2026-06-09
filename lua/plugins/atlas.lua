plugin("atlas")
	:opts(function()
		local base = {
			pulls = {
				diff = {
					open_cmd = "CodeDiff",
				},
				providers = {
					github = {}, -- See configuration below
				},
			},
			issues = {
				providers = {
					github = {}, -- See configuration below
				},
			},
		}
		local jira_base_url = vim.env.JIRA_BASE_URL
		local jira_email = vim.env.JIRA_EMAIL
		local jira_api_token = vim.env.JIRA_API_TOKEN
		if jira_base_url and jira_email and jira_api_token then
			base.issues.providers.jira = {
				base_url = jira_base_url,
				email = jira_email,
				api_token = jira_api_token,
			}
		end
		return base
	end)
	:event("DeferredUIEnter")
