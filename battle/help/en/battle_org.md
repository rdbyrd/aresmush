---
toc: Using Battle
summary: Manage battle scenes.
- battle_organizer
- battle_organizing
- battle_start
- battle_team
- battle_stop
- battle_newturn
- battle_log
- battle_target
---

# Organizing Battles

These references are for managing battle commands:

`battle/start [<mock or real>]` - Starts a battle (default is real).
`battle/stop <battle #>` - Stops battle.
`battles` - Shows all active battle.
`battle/newturn` - Starts the first turn.

`battle/join <list of names>=<battle #>[/<type>]` - Adds people to battle.

`battle/summary` - Summary of everyone's skills/gear. Also shows who hasn't posed or set their actions. Note: gear does not exist yet in this Battle plugin, neither are their any skills as of yet.
`battle/idle <name>` - Set a user to idle (or wipe idle status). Idle excludes users from pose tracking.

`battle/transfer <name>` - Transfer organizer's powers to another person who is in battle.

`battle/scene <scene id>` - Allows combat messages in scene log. It happens automatically.

`combat/log <page>` - View combat log with messages about rolls and effects.

## Targeting

`battle/targets` - Show target of target.

`battle/team <list of names>=<team#>` - Switches teams (needs tested to make sure functionality passed through).
