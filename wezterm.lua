-- 📚 WEZTERM CONFIGURATION (Tacitus Edition - v8 Spawn Fix)
-- =========================================================

local wezterm = require("wezterm")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- =========================================================
-- 🎨 APPEARANCE
-- =========================================================
config.color_scheme = "BlulocoDark"
config.font = wezterm.font("Victor Mono", { weight = 600 })
config.font_size = 12.5
config.line_height = 1.15
config.window_background_opacity = 0.95
config.window_decorations = "RESIZE"
config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.colors = {
	split = "#444444",
}
config.inactive_pane_hsb = {
	saturation = 1,
	brightness = 0.7,
}
-- =========================================================
-- 🧠 HELPER FUNCTIONS
-- =========================================================
local function is_vim(pane)
	local success, process_name = pcall(function()
		local process_info = pane:get_foreground_process_info()
		return process_info and process_info.name
	end)
	if not success or not process_name then
		return false
	end
	return process_name:find("n?vim") ~= nil
end

local function workspace_exists(name)
	for _, workspace in ipairs(wezterm.mux.get_workspace_names()) do
		if workspace == name then
			return true
		end
	end
	return false
end
local notification_state = { message = nil, expires = 0 }
local function show_notification(message, duration_secs)
	duration_secs = duration_secs or 5
	notification_state.message = message
	notification_state.expires = os.time() + duration_secs
	for _, window in ipairs(wezterm.gui.gui_windows()) do
		window:set_right_status(wezterm.format({
			{ Background = { Color = "#f38ba8" } },
			{ Foreground = { Color = "#1e1e2e" } },
			{ Text = "  " .. message .. "  " },
		}))
	end
end

local direction_keys = { h = "Left", j = "Down", k = "Up", l = "Right" }
local resize_keys = { h = "Left", j = "Up", k = "Down", l = "Right" }

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "META" or "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					local tab = pane:tab()
					if tab then
						if key == "h" then -- Shrink Width
							if tab:get_pane_direction("Right") then
								win:perform_action({ AdjustPaneSize = { "Left", 3 } }, pane)
							else
								win:perform_action({ AdjustPaneSize = { "Right", 3 } }, pane)
							end
						elseif key == "l" then -- Grow Width
							if tab:get_pane_direction("Right") then
								win:perform_action({ AdjustPaneSize = { "Right", 3 } }, pane)
							else
								win:perform_action({ AdjustPaneSize = { "Left", 3 } }, pane)
							end
						elseif key == "j" then -- Shrink Height
							if tab:get_pane_direction("Down") then
								win:perform_action({ AdjustPaneSize = { "Up", 3 } }, pane)
							else
								win:perform_action({ AdjustPaneSize = { "Down", 3 } }, pane)
							end
						elseif key == "k" then -- Grow Height
							if tab:get_pane_direction("Down") then
								win:perform_action({ AdjustPaneSize = { "Down", 3 } }, pane)
							else
								win:perform_action({ AdjustPaneSize = { "Up", 3 } }, pane)
							end
						end
					end
				else
					local dir = direction_keys[key]
					local tab = pane:tab()
					if tab and tab:get_pane_direction(dir) then
						win:perform_action({ ActivatePaneDirection = dir }, pane)
					else
						local awesome_dir = ({ h = "left", j = "down", k = "up", l = "right" })[key]
						if os.getenv("DESKTOP_SESSION") == "awesome" then
							os.execute(
								string.format(
									"/usr/bin/awesome-client \"awesome.emit_signal('focus_direction', '%s')\" > /dev/null 2>&1 &",
									awesome_dir
								)
							)
						end
					end
				end
			end
		end),
	}
end

local function smart_split(direction)
	return wezterm.action_callback(function(window, pane)
		if is_vim(pane) then
			window:perform_action(
				wezterm.action.Multiple({
					{ SendKey = { key = "w", mods = "CTRL" } },
					{ SendKey = { key = direction == "Vertical" and "v" or "s" } },
				}),
				pane
			)
		else
			if direction == "Vertical" then
				window:perform_action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }, pane)
			else
				window:perform_action({ SplitVertical = { domain = "CurrentPaneDomain" } }, pane)
			end
		end
	end)
end

-- =========================================================
-- ⚡ KEYBINDINGS
-- =========================================================
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- SMART NAV
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),
	split_nav("resize", "h"),
	split_nav("resize", "j"),
	split_nav("resize", "k"),
	split_nav("resize", "l"),
	{ key = "-", mods = "LEADER", action = smart_split("Vertical") },
	{ key = "\\", mods = "LEADER", action = smart_split("Horizontal") },
	{
		key = "|",
		mods = "LEADER|SHIFT",
		action = wezterm.action.SplitPane({
			direction = "Right",
			size = { Percent = 50 },
		}),
	},
	{
		key = "_",
		mods = "LEADER|SHIFT",
		action = wezterm.action.SplitPane({
			direction = "Down",
			size = { Percent = 50 },
		}),
	},
	{
		key = "x",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{ key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "&", mods = "LEADER|SHIFT", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
	{ key = "1", mods = "LEADER", action = wezterm.action.ActivateTab(0) },
	{ key = "2", mods = "LEADER", action = wezterm.action.ActivateTab(1) },
	{ key = "3", mods = "LEADER", action = wezterm.action.ActivateTab(2) },
	{ key = "4", mods = "LEADER", action = wezterm.action.ActivateTab(3) },
	{ key = "5", mods = "LEADER", action = wezterm.action.ActivateTab(4) },
	{ key = "6", mods = "LEADER", action = wezterm.action.ActivateTab(5) },
	{ key = "7", mods = "LEADER", action = wezterm.action.ActivateTab(6) },
	{ key = "8", mods = "LEADER", action = wezterm.action.ActivateTab(7) },
	{ key = "9", mods = "LEADER", action = wezterm.action.ActivateTab(8) },
	{ key = "0", mods = "LEADER", action = wezterm.action.ActivateTab(9) },
	{ key = "f", mods = "LEADER", action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|TABS" }) },
	{
		key = ",",
		mods = "LEADER",
		action = wezterm.action.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{ key = "1", mods = "LEADER|ALT", action = wezterm.action.MoveTab(0) },
	{ key = "2", mods = "LEADER|ALT", action = wezterm.action.MoveTab(1) },
	{ key = "3", mods = "LEADER|ALT", action = wezterm.action.MoveTab(2) },
	{ key = "4", mods = "LEADER|ALT", action = wezterm.action.MoveTab(3) },
	{ key = "5", mods = "LEADER|ALT", action = wezterm.action.MoveTab(4) },
	{ key = "6", mods = "LEADER|ALT", action = wezterm.action.MoveTab(5) },
	{ key = "7", mods = "LEADER|ALT", action = wezterm.action.MoveTab(6) },
	{ key = "8", mods = "LEADER|ALT", action = wezterm.action.MoveTab(7) },
	{ key = "9", mods = "LEADER|ALT", action = wezterm.action.MoveTab(8) },
	{ key = "0", mods = "LEADER|ALT", action = wezterm.action.MoveTab(9) },
	{ key = "<", mods = "LEADER|SHIFT", action = wezterm.action.MoveTabRelative(-1) },
	{ key = ">", mods = "LEADER|SHIFT", action = wezterm.action.MoveTabRelative(1) },

	-- WORKSPACES
	{ key = "w", mods = "LEADER", action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
	{
		key = "$",
		mods = "LEADER|SHIFT",
		action = wezterm.action.PromptInputLine({
			description = "Enter new name for workspace",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
				end
			end),
		}),
	},
	{
		key = "D",
		mods = "LEADER|SHIFT",
		action = wezterm.action.SwitchToWorkspace({ name = "default" }),
	},
	-- =========================================================
	-- 💾 RESURRECT (CORRECTED WORKFLOW)
	-- =========================================================

	-- SAVE STATE (Leader + S)

	{
		key = "S",
		mods = "LEADER",
		action = wezterm.action_callback(function(win, pane)
			resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
			show_notification("Saving Workspace...", 10)
		end),
	},
	{
		key = "R",
		mods = "LEADER",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
				local type = string.match(id, "^([^/]+)") -- match before '/'
				id = string.match(id, "([^/]+)$") -- match after '/'
				id = id:gsub("%.json$", "") -- remove file extension safely
				local opts = {
					relative = true,
					restore_text = true,
					on_pane_restore = resurrect.tab_state.default_on_pane_restore,
					resize_window = false,
				}
				if type == "workspace" then
					local state = resurrect.state_manager.load_state(id, "workspace")
					if not state then
						return
					end
					if workspace_exists(id) then
						win:perform_action(wezterm.action.SwitchToWorkspace({ name = id }), pane)
					else
						win:perform_action(wezterm.action.SwitchToWorkspace({ name = id }), pane)
						local window_id = wezterm.gui.gui_windows()[1]:window_id()
						opts.window = wezterm.mux.get_window(window_id)
						opts.close_open_tabs = true
						opts.spawn_in_workspace = id
						resurrect.workspace_state.restore_workspace(state, opts)
					end
				elseif type == "window" then
					local state = resurrect.state_manager.load_state(id, "window")
					if state then
						resurrect.window_state.restore_window(win:window_id(), state, opts)
					end
				elseif type == "tab" then
					local state = resurrect.state_manager.load_state(id, "tab")
					if state then
						resurrect.tab_state.restore_tab(pane:tab(), state, opts)
					end
				end
			end, {
				show_state_with_date = true,
			})
		end),
	},
	-- DELETE STATE (Leader + D)
	{
		key = "X",
		mods = "LEADER",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
				resurrect.state_manager.delete_state(id)
			end, {
				title = "Delete State",
				description = "Select State to Delete",
				fuzzy_description = "Search State to Delete: ",
				is_fuzzy = true,
			})
		end),
	},

	-- SYSTEM
	{ key = "Q", mods = "LEADER|SHIFT", action = wezterm.action.QuitApplication },
}

-- =========================================================
-- 🚦 STATUS BAR
-- =========================================================

wezterm.on("update-right-status", function(window, pane)
	if notification_state.message and os.time() < notification_state.expires then
		window:set_right_status(wezterm.format({
			{ Background = { Color = "#f38ba8" } },
			{ Foreground = { Color = "#1e1e2e" } },
			{ Text = "  " .. notification_state.message .. "  " },
		}))
		return
	end

	local leader = ""
	if window == nil then
		return
	end
	if window:leader_is_active() then
		leader = "LEADER"
	end
	local workspace = window:active_workspace() or "default"
	local color_leader = { fg = "#1e1e2e", bg = "#f38ba8" }
	local color_workspace = { fg = "#cdd6f4", bg = "#313244" }

	if leader ~= "" then
		window:set_right_status(wezterm.format({
			{ Background = { Color = color_leader.bg } },
			{ Foreground = { Color = color_leader.fg } },
			{ Text = " ! " .. leader .. " ! " },
		}))
	else
		window:set_right_status(wezterm.format({
			{ Background = { Color = color_workspace.bg } },
			{ Foreground = { Color = color_workspace.fg } },
			{ Text = " ~ " .. workspace .. " ~ " },
		}))
	end
end)
local resurrect_event_listeners = {
	"resurrect.error",
	"resurrect.state_manager.save_state.finished",
}
wezterm.on("resurrect.periodic_save", function()
	show_notification("Autosaving State...", 3)
end)
for _, event in ipairs(resurrect_event_listeners) do
	wezterm.on(event, function(...)
		local args = { ... }
		local msg = event
		for _, v in ipairs(args) do
			msg = msg .. " " .. tostring(v)
		end
		show_notification(msg, 4)
	end)
end
-- =========================================================
-- 💾 BACKGROUND SERVER
-- =========================================================
config.unix_domains = { { name = "unix" } }
config.default_gui_startup_args = { "connect", "unix" }
resurrect.state_manager.periodic_save({
	interval_seconds = 900,
	save_workspaces = true,
	save_windows = true,
})

wezterm.on("gui-startup", function(win, pane)
	local state = resurrect.state_manager.load_state("default", "workspace")
	if state then
		local opts = {
			relative = true,
			restore_text = true,
			on_pane_restore = resurrect.tab_state.default_on_pane_restore,
			resize_window = false,
			close_open_tabs = true,
			spawn_in_workspace = "default",
		}
		resurrect.workspace_state.restore_workspace(state, opts)
		show_notification("default workspace loaded!")
	else
		wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), "default")
		show_notification("default workspace created!")
	end
end)
return config
