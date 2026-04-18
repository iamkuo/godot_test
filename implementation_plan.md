# Implementation Plan: Merging Battle System into Test Project

This plan outlines the steps to integrate the advanced lane-based battle system from `battle_system_test` into the main `test_project`.

## User Review Required

> [!IMPORTANT]
> - **Filename Collisions**: Both projects have `important_scripts` and `assets` folders. I will create a dedicated `battle` subfolder within `important_scripts` and `scenes` to avoid overwriting existing work.
> - **Player Scene**: `battle_system_test` has a `player.tscn` which is specific to the battle mechanics. I will rename this to `battle_player.tscn` to distinguish it from the world-roaming `player.tscn` in `test_project`.
> - **Autoloads**: `MessageManager` exists in both. I will need to merge their functionality or choose one.

## Proposed Changes

### File Migration [NEW/MOVE]

#### [NEW] Assets Migration
- Copy all files from `battle_system_test/assets/images/` to `test_project/assets/images/`.
- Ensure directories like `characters`, `objects`, `projectiles`, and `particles` are merged correctly.

#### [NEW] Script Integration
- Create `test_project/important_scripts/battle/` directory.
- Move core battle scripts there:
    - `battle_manager.gd`
    - `projectile_manager.gd`
    - `player_in_battle.gd` (rename or keep)
    - `tower/` (tower_base, tower_manager)
    - `unit/` (allies_manager, enemies_manager, unit_base, behavior_pattern, unit_stats)
    - `ui/` (card, spawn_ui, unit_control_panel, etc.)

#### [NEW] Scene Migration
- Copy and rename `battle_system_test/scenes/Main.tscn` to `test_project/scenes/battle_scene.tscn`.
- Copy other battle-related scenes: `Tower.tscn`, `unit.tscn`, `projectile.tscn`, `card.tscn`, `spawn_ui.tscn`, `ending_screen.tscn`.

#### [NEW] Resource Migration
- Copy `battle_system_test/resources/unit_stats/` to `test_project/resources/unit_stats/`.

### Configuration Integration

#### [MODIFY] `project.godot`
- Add `ProjectileManager` as an Autoload.
- Merge `MessageManager` (or update target path).
- Add new Input Map actions: `spawn_ai_unit`, `po`, `pu`, `py`.

### Code & Scene Reconciliation

#### [MODIFY] `battle_scene.tscn` (formerly Main.tscn)
- Update all `ExtResource` paths to point to the new locations in `test_project`.
- Update references to the renamed `battle_player.tscn`.

#### [MODIFY] Battle Scripts
- Fix `res://` paths in scripts that load resources (like `battle_manager.gd` loading stats).
- Hook `battle_manager.gd` into the `ProgressManager` to reward the player or update game state upon victory.

## Open Questions

- Should I replace the existing `test_project/other_scripts/battle_manager.gd` entirely, or keep it as a legacy/reference?
- Are there specific world-map locations where the battle should be triggered?
- Do you want the `BattleWorldLink` to be converted into a Global Autoload to maintain state between world and battle?

## Verification Plan

### Automated Tests
- I'll use a script to check for broken dependencies (broken UIDs or paths) after moving files.

### Manual Verification
- Test that `test_project` still boots into the main menu/world.
- Trigger the new battle scene and verify:
    - Units can be spawned using elixir.
    - AI spawns opponent units.
    - Combat, projectiles, and tower destruction work.
    - The ending screen appears correctly.
