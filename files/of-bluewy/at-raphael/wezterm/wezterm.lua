-- yoinked from https://github.com/theopn/dotfiles

local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
   config = wezterm.config_builder()
end

-- [ Colorscheme ]

config.colors = {
   foreground = "#abb2bf",
   background = "#282C34",

   cursor_bg = "#528BFF",
   cursor_fg = "#DAE6FF",

   selection_bg = "#404859",

   scrollbar_thumb = "#373C47",
   split = "#282C34",

   ansi = {
      "#282C34",
      "#e06c75",
      "#98c379",
      "#e5c07b",
      "#61afef",
      "#c678dd",
      "#56b6c2",
      "#abb2bf",
   },

   brights = {
      "#7f848e",
      "#e06c75",
      "#98c379",
      "#e5c07b",
      "#61afef",
      "#c678dd",
      "#56b6c2",
      "#abb2bf",
   },

   compose_cursor = "#d19a66",

   tab_bar = {
      background = "#21252B",

      active_tab = {
         bg_color = "#282C34",
         fg_color = "#abb2bf",
      },

      inactive_tab = {
         bg_color = "#21252B",
         fg_color = "#7f848e",
      },
   },
}

-- [ Settings ]

config.default_prog =
   { "/usr/bin/nu", "-l", "--experimental-options=[reorder-cell-paths pipefail enforce-runtime-annotations]" }

config.font_size = 18

config.font = wezterm.font_with_fallback({
   { family = "IosevkaTerm Nerd Font Mono", scale = 1.0 },
})

config.window_decorations = "NONE"
config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 3000
config.default_workspace = "main"

config.inactive_pane_hsb = {
   saturation = 0.5,
   brightness = 0.5,
}

config.window_padding = {
   top = "0.5cell",
   right = "1cell",
   left = "1cell",
   bottom = "0.5cell",
}

config.warn_about_missing_glyphs = false

-- [ Binds ]

config.disable_default_key_bindings = true
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
   { key = "a", mods = "LEADER|CTRL", action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }) },
   { key = "phys:Space", mods = "LEADER", action = wezterm.action.ActivateCommandPalette },

   -- [[ Pane ]]

   { key = "h", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
   { key = "v", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
   { key = "n", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
   { key = "e", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
   { key = "u", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
   { key = "i", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },
   { key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
   { key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
   { key = "o", mods = "LEADER", action = wezterm.action.RotatePanes("Clockwise") },

   {
      key = "r",
      mods = "LEADER",
      action = wezterm.action.ActivateKeyTable({ name = "resize_pane", one_shot = false }),
   },

   -- [[ TAB ]]

   { key = "t", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
   { key = "[", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },
   { key = "]", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
   { key = "s", mods = "LEADER", action = wezterm.action.ShowTabNavigator },
   { key = "m", mods = "LEADER", action = wezterm.action.ActivateKeyTable({ name = "move_tab", one_shot = false }) },

   {
      key = "k",
      mods = "LEADER",

      action = wezterm.action.PromptInputLine({
         description = wezterm.format({
            { Attribute = { Intensity = "Bold" } },
            { Foreground = { AnsiColor = "Fuchsia" } },
            { Text = "Renaming Tab Title...:" },
         }),

         action = wezterm.action_callback(function(window, pane, line)
            if line then
               window:active_tab():set_title(line)
            end
         end),
      }),
   },

   -- [[ Workspace ]]

   { key = "w", mods = "LEADER", action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },

   -- [[ Clipboard ]]

   { key = "c", mods = "CTRL | SHIFT", action = wezterm.action.CopyTo("Clipboard") },
   { key = "v", mods = "CTRL | SHIFT", action = wezterm.action.PasteFrom("Clipboard") },

   { key = "c", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
}

config.key_tables = {
   resize_pane = {
      { key = "n", action = wezterm.action.AdjustPaneSize({ "Left", 1 }) },
      { key = "e", action = wezterm.action.AdjustPaneSize({ "Down", 1 }) },
      { key = "u", action = wezterm.action.AdjustPaneSize({ "Up", 1 }) },
      { key = "i", action = wezterm.action.AdjustPaneSize({ "Right", 1 }) },
      { key = "Escape", action = "PopKeyTable" },
      { key = "Enter", action = "PopKeyTable" },
   },

   move_tab = {
      { key = "n", action = wezterm.action.MoveTabRelative(-1) },
      { key = "e", action = wezterm.action.MoveTabRelative(-1) },
      { key = "u", action = wezterm.action.MoveTabRelative(1) },
      { key = "i", action = wezterm.action.MoveTabRelative(1) },
      { key = "Escape", action = "PopKeyTable" },
      { key = "Enter", action = "PopKeyTable" },
   },
}

for i = 1, 9 do
   table.insert(config.keys, {
      key = tostring(i),
      mods = "LEADER",
      action = wezterm.action.ActivateTab(i - 1),
   })
end

config.mouse_bindings = {
   {
      event = { Down = { streak = 1, button = { WheelUp = 1 } } },
      mods = "NONE",
      action = wezterm.action.ScrollByLine(-1),
   },
   {
      event = { Down = { streak = 1, button = { WheelDown = 1 } } },
      mods = "NONE",
      action = wezterm.action.ScrollByLine(1),
   },
}

-- [ Tab ]

config.use_fancy_tab_bar = false
config.status_update_interval = 1000
config.tab_bar_at_bottom = true

wezterm.on("update-status", function(window, pane)
   -- workspace name
   local status = window:active_workspace()
   local status_color = "#E06C75"

   -- Constantly displaying the workspace name seems unnecessary.
   -- This space could be better used to showcase LDR or the current key table name.
   if window:active_key_table() then
      status = window:active_key_table()
      status_color = "#61AFEF"
   end

   if window:leader_is_active() then
      status = "LDR"
      status_color = "#C678DD"
   end

   local basename = function(s)
      -- Nothing a little regex can't fix.
      return string.gsub(s, "(.*[/\\])(.*)", "%2")
   end

   local current_working_directory = pane:get_current_working_dir()

   if current_working_directory then
      if type(current_working_directory) == "userdata" then
         current_working_directory = basename(current_working_directory.file_path)
      else
         current_working_directory = basename(current_working_directory)
      end
   else
      current_working_directory = ""
   end

   local current_command = pane:get_foreground_process_name()
   current_command = current_command and basename(current_command) or ""

   window:set_left_status(wezterm.format({
      { Foreground = { Color = status_color } },
      { Text = "  " },
      { Text = wezterm.nerdfonts.oct_table .. "  " .. status },
      { Foreground = { Color = "#7f848e" } },
      { Text = " |" },
   }))

   window:set_right_status(wezterm.format({
      { Text = wezterm.nerdfonts.md_folder .. "  " .. current_working_directory },
      { Text = " | " },
      { Foreground = { Color = "#d19a66" } },
      { Text = wezterm.nerdfonts.fa_code .. "  " .. current_command },
      { Text = "  " },
   }))
end)

return config
