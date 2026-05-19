plugin("atlas")
	:opts({
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
				jira = {}, -- See configuration below
				github = {}, -- See configuration below
			},
		},
	})
	:event("DeferredUIEnter")
