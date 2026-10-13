# coi_no_clip — F1 Noclip for VORP RedM

Simple admin-only noclip toggle. No menu, no prompts, no UI. Press **F1** to toggle.

## How it works

- Client presses F1 (`Config.ToggleKey = 0xA8E3F467`)
- Client asks server via callback `coi_no_clip:canUse`
- Server checks `vorp_core` user group (or character group if `Config.UseCharacterGroup = true`) against `Config.AllowedGroups`
- If allowed, noclip toggles on/off locally

Permission is re-checked on every toggle, so group revokes apply instantly.

## Install

1. Drop `coi_no_clip` into your `resources` folder
2. `ensure coi_no_clip` (after `vorp_core` in server.cfg)
3. Give staff `admin` / `moderator` group in VORP

Requires `vorp_core` (declared in `fxmanifest.lua` dependencies).

## Controls

| Action | Key | Hash |
|---|---|---|
| Toggle noclip | F1 | `0xA8E3F467` |
| Move forward / back | W / S | `0x8FD015D8` / `0xD27782E3` |
| Up / down | Q / Z | `0xF84FA74F` / `0x07CE1E61` (also accepts `0x26E9DC00` for Z) |
| Cycle speed | L-Shift | `0x8FFC75D6` |
| Force off | Delete | `0x4AF4D473` |

Speeds cycle: Very Slow → Slow → Normal (default) → Fast → Very Fast → Max.

Works on foot, on mount, and in vehicles (moves the mount/vehicle entity). Noclip auto-resets on force respawn (`vorp:PlayerForceRespawn`).

## Config (`config.lua`)

```lua
Config.ToggleKey = 0xA8E3F467       -- F1
Config.Controls = { ... }           -- movement keys
Config.Speeds = { ... }             -- speed steps, starts at index 3 (Normal)
Config.Offsets = { y = 0.2, z = 0.1 }
Config.AllowedGroups = { admin = true, moderator = true }
Config.UseCharacterGroup = false    -- true = check character group (like vorp_admin UseCharactersAdmin)
Config.Notify = true                -- false = fully silent, no vorp:TipRight at all
```

## Files

- `fxmanifest.lua` — cerulean / rdr3 / lua54, `shared_script 'config.lua'`
- `client/client.lua` — toggle thread + movement thread (noclip logic: freeze, no collision, invincible, invisible)
- `server/server.lua` — `HasAdminPower()` + `Core.Callback.Register('coi_no_clip:canUse')`
