# Godot Project: godot_test

## Project Overview
This is a 2D RPG/Adventure game developed with **Godot 4.5 (Forward Plus)**. The game features a data-driven architecture using Godot Resources, a centralized management system through Autoloads, and a standard 4-way movement player character.

### Core Technologies
- **Engine**: Godot 4.5
- **Language**: GDScript
- **Rendering**: Forward Plus
- **Resolution**: 1024x540 (Viewport Stretch)

### Key Architecture & Singletons
The project relies on several global singletons (Autoloads) defined in `project.godot`:
- **`SceneSwitcher`**: Handles animated transitions between game scenes.
- **`GuiManager`**: Manages the user interface.
- **`CutsceneManager`**: Executes sequence-based cutscenes and dialogue.
- **`ProgressManager`**: Tracks game state, player experience, crystals, and unlocked "memories."
- **`BackpackManager`**: Manages inventory logic.

### Data Structures
The game uses custom `Resource` types for managing data:
- `CutsceneScript` / `CutsceneStep`: Defines sequence of events in cutscenes.
- `MemoryData`: Stores collectible lore/items.
- `SkillData`: Stores player/unit abilities.

---

## Directory Structure
- `/assets`: Contains sprites, fonts, music, and sound effects.
- `/important_scripts`: Core logic, managers (singletons), and the player controller.
- `/other_scripts`: Game-specific logic like battle management, interactables (signs, teleport points), and UI scripts.
- `/resources`: Custom `.tres` files and their corresponding GDScript definitions.
- `/scenes`: Godot `.tscn` files for levels, UI, and game objects.

---

## Building and Running
### Prerequisites
- **Godot 4.5** or later.

### Key Commands
- **Open in Editor**: Open `project.godot` with the Godot executable.
- **Run Game**: Press `F5` in the editor or run `godot --path .` from the command line.
- **Export**: Use the Godot Export menu (`Project > Export`) to build for specific platforms (Windows/Linux/Web).

---

## Development Conventions
### Coding Style
- **Naming**: Follows standard GDScript conventions (`snake_case` for variables/functions, `PascalCase` for classes).
- **Signals**: Used extensively for decoupling logic (e.g., `ProgressManager` emits `data_updated`).
- **Input Map**:
  - `ui_left`, `ui_right`, `ui_up`, `ui_down`: Movement (WASD/Arrows).
  - `interact`: `E` key.
  - `pause`: `Esc` key.

### Physics Layers
1. **Player**
2. **Enemy**
3. **Environment**
4. **Interactables**

### Asset Workflow
- Sprites should use **Nearest Neighbor** filtering (set globally in `project.godot` as `default_texture_filter=0`).
- UI elements are generally managed via `GuiManager` and located in `scenes/gui.tscn`.
