local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Theme and Appearance
config.color_scheme = 'Everforest Dark Hard'
config.window_decorations = "NONE"
-- config.window_background_opacity = 0.90
-- config.macos_window_background_blur = 20

-- Font Configuration
config.font = wezterm.font_with_fallback {
    'JetBrains Mono',
    'Symbols Nerd Font Mono'
}
config.font_size = 14.0
config.line_height = 1.2

-- Window Configuration
config.initial_cols = 120
config.initial_rows = 40
config.window_padding = {
    left = 15,
    right = 15,
    top = 15,
    bottom = 15,
}

-- Leader Key Configuration
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

-- Enhanced Keybindings
config.keys = {
    -- Pane Management
    { key = '|', mods = 'LEADER|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = '-', mods = 'LEADER', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
    
    -- Pane Navigation
    { key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Left' },
    { key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Down' },
    { key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Up' },
    { key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Right' },
    
    -- Pane Resizing
    { key = 'H', mods = 'LEADER|SHIFT', action = wezterm.action.AdjustPaneSize { 'Left', 5 } },
    { key = 'J', mods = 'LEADER|SHIFT', action = wezterm.action.AdjustPaneSize { 'Down', 5 } },
    { key = 'K', mods = 'LEADER|SHIFT', action = wezterm.action.AdjustPaneSize { 'Up', 5 } },
    { key = 'L', mods = 'LEADER|SHIFT', action = wezterm.action.AdjustPaneSize { 'Right', 5 } },
    
    -- Tab Management
    { key = 'c', mods = 'LEADER', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
    { key = 'x', mods = 'LEADER', action = wezterm.action.CloseCurrentTab { confirm = true } },
    { key = 'n', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(1) },
    { key = 'p', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(-1) },
    
    -- Copy/Paste Mode
    { key = '[', mods = 'LEADER', action = wezterm.action.ActivateCopyMode },
    
    -- Search Mode
    { key = '/', mods = 'LEADER', action = wezterm.action.Search { CaseSensitiveString = '' } },
}

-- Tab Bar Configuration
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true
config.tab_max_width = 32

-- Performance and Rendering
config.enable_wayland = true
config.front_end = 'WebGpu'

-- Scrollback
config.scrollback_lines = 10000

return config
