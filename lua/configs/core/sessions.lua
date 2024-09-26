plugin("rmagatti/auto-session"):event("VimEnter"):opts({
	auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
	auto_restore_enabled = false,
})
