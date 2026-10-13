Config = {}

-- Key to toggle noclip (default F1)
Config.ToggleKey = 0xA8E3F467 -- F1

-- Movement keys (same defaults as vorp_admin)
Config.Controls = {
    goUp       = 0xF84FA74F, -- Q
    goDown     = 0x07CE1E61, -- Z (see note below)
    goForward  = 0x8FD015D8, -- W
    goBackward = 0xD27782E3, -- S
    changeSpeed = 0x8FFC75D6, -- L-Shift (cycles speed)
    cancel     = 0x4AF4D473, -- Delete (extra off switch, F1 always toggles too)
}

-- NOTE: some RDR keymaps report Z as 0x26E9DC00. Both are handled client-side.

Config.Speeds = {
    { label = 'Very Slow', speed = 0 },
    { label = 'Slow',      speed = 0.5 },
    { label = 'Normal',    speed = 2 },
    { label = 'Fast',      speed = 10 },
    { label = 'Very Fast', speed = 15 },
    { label = 'Max',       speed = 29 },
}

Config.Offsets = {
    y = 0.2, -- forward/back multiplier
    z = 0.1, -- up/down multiplier
}

-- Groups allowed to use noclip. Uses vorp_core user group
-- (or character group if Config.UseCharacterGroup = true).
Config.AllowedGroups = {
    admin = true,
    moderator = true,
}

-- If true, checks character group instead of user group
-- (mirrors vorp_admin Config.UseCharactersAdmin)
Config.UseCharacterGroup = false

-- Show a small tip on toggle on/off. Set false for fully silent (no UI at all)
Config.Notify = true
