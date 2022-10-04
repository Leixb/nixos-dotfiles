require("auto-session").setup({
	log_level = "info",
	auto_session_create_enabled = false,
	auto_session_allowed_dirs = { "~/Documents" },
	auto_session_use_git_branch = true,
})
