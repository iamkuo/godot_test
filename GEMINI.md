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
---

## Documentation on Game Data Storage

This section details how core game elements like levels, animations, and memory shards are stored and managed within the project.

### 1. Level Storage and Progression

**Current Implementation:**

*   **Scene Files:** Individual game levels and UI screens are stored as `.tscn` (scene) files within the `scenes/` directory. Examples include `main_world.tscn`, `test_area.tscn`, and `gui.tscn`.
*   **Progression Management:** Game progression is managed by the `ProgressManager.gd` Autoload singleton. It defines stages of progression using arrays (`stages_test`, `stages_full`) containing dictionaries. Each dictionary maps required experience (`req_exp`) to a stage name and a `cutscene` identifier.
*   **Scene Transitions:** The `SceneSwitcher` singleton is responsible for handling animated transitions between these scenes. The `ProgressManager` likely triggers scene changes upon progression milestones.

**Suggestions:**

*   **Data-Driven Stages:** The `stages_test` and `stages_full` arrays are hardcoded within `ProgressManager.gd`. Consider externalizing this data into dedicated `Resource` files (e.g., `stages_data.tres` or multiple `StageData.tres` files) or even a configuration file (like JSON or CSV if GDScript can parse it easily). This would allow for easier expansion and modification of game progression without altering core script logic.
*   **Centralized Scene References:** While scenes are in the `scenes/` directory, ensure a consistent naming convention and potentially a central registry or enumeration for scene paths if the project grows significantly, to prevent typos and simplify management.
*   **Clearer Stage Definitions:** For more complex level structures (e.g., non-linear progression, unlockable areas), the current dictionary format might need expansion. Consider a dedicated `StageData` resource that can hold more properties like required items, specific unlock conditions, or associated environment assets.

### 2. Animation Storage

**Current Implementation:**

*   **Asset Organization:** Visual assets, including sprites that form the basis of animations, are stored within the `/assets/sprites/` directory.
*   **Godot's Animation System:** Animations are primarily handled using Godot's built-in animation tools.
    *   For character and object animations, this typically involves using `AnimatedSprite2D` nodes within `.tscn` files. The `backpack_ui.gd` script explicitly uses `AnimatedSprite2D` to play animations like `"light_torch"` and `"unlit"` on memory shard visual representations.
    *   More complex animations or those requiring fine-grained control (like character skeletal animations, complex UI animations) would utilize Godot's `AnimationPlayer` node.
*   **Animation Definitions:** Animations themselves are defined within the respective scene files (`.tscn`) or attached to their respective nodes.

**Suggestions:**

*   **Organized Sprite Sheets:** Ensure sprite sheets are organized logically within `assets/sprites/` (e.g., `assets/sprites/characters/player/idle.png`, `assets/sprites/characters/player/run.png`). This aids in managing and finding animation frames.
*   **AnimationPlayer for Complex Needs:** If animations become more intricate (e.g., requiring multiple tracks, blend shapes, or sophisticated timing), leverage the `AnimationPlayer` node for greater control and flexibility over `AnimatedSprite2D`.
*   **Animation States and Transitions:** For characters with many states (idle, walk, jump, attack), consider using Godot's `AnimationTree` node to manage complex animation blending and transitions, providing a more fluid visual experience.

### 3. Memory Shard Storage

**Current Implementation:**

*   **Data Definition (`MemoryData.gd`):** The `MemoryData` script (`resources/data_structures/memory_data.gd`) defines the structure for each memory shard. It includes properties such as `id` (unique identifier), `name`, `description`, `cutscene_id` (linking to a cutscene), and `icon` (a `Texture2D`).
*   **Resource Files (`.tres`):** Individual memory shards are instantiated as `Resource` files (e.g., `memory_ancient_bones.tres`, `memory_eternal_flame.tres`) located in the `resources/memories/` directory. These `.tres` files contain the specific data for each memory, populating the fields defined in `MemoryData.gd`.
*   **Loading and Tracking (`ProgressManager.gd`):**
    *   The `ProgressManager.gd` script is responsible for loading all `MemoryData` resources from `res://resources/memories/` into an `active_memories` array upon game start.
    *   Player progress is tracked via the `unlocked_memory_ids` array, which stores the `id` strings of collected memories.
*   **UI Representation (`backpack_ui.gd`):**
    *   The `BackpackUI.gd` script loads memory `Resource` data and displays them visually, often as "torches," within the backpack UI.
    *   It uses the `ProgressManager.unlocked_memory_ids` to determine whether a memory shard has been collected and updates the visual state of its corresponding UI element (e.g., lighting up a torch using `AnimatedSprite2D`).
    *   When a memory shard is interacted with (e.g., clicking its torch), the `cutscene_id` from the `MemoryData` is used to trigger a cutscene via `CutsceneManager.play()`.

**Suggestions:**

*   **Consistency in IDs and Resources:**
    *   Ensure all `id` fields in `MemoryData` resources are unique and follow a clear, consistent naming convention (e.g., `mem_ancient_bones`).
    *   Verify that the `cutscene_id` in `MemoryData` resources correctly matches the `id` of an existing `CutsceneScript` resource in `resources/cutscenes/`.
    *   The `ProgressManager._load_memories_from_directory` function should be reviewed. If `id` is an `@export var` in `MemoryData.gd`, it should be accessed directly as `resource.id` instead of using `resource.has_meta("id")` and `resource.get_meta("id")`.
*   **`ProgressManager.gd` Enhancements:**
    *   **Direct Memory Data Access:** Consider adding a helper method like `get_memory_data_by_id(memory_id: String) -> MemoryData` to `ProgressManager` to provide easy access to a specific memory's data. This can be implemented by creating a dictionary mapping IDs to `MemoryData` objects during loading, improving lookup efficiency.
    *   **Data Structure for Unlocked IDs:** For games with a very large number of collectibles, a `Dictionary` (e.g., `{ "mem_id": true }`) or a `Set` could offer slightly faster lookup times for checking if a memory is unlocked, though an `Array` is generally sufficient for most cases.
*   **`backpack_ui.gd` Enhancements:**
    *   **Resource Loading Ownership:** The current approach of loading all memory resources within `backpack_ui.gd` is acceptable. For very large projects, you might consider consolidating all resource loading logic under `ProgressManager` to be the sole owner of collectible data, and then providing access to `BackpackUI` as needed.
    *   **Signal Robustness:** Ensure `ProgressManager` signals (`data_updated`, `memory_collected`) are emitted reliably and at the correct times to keep the UI synchronized.
*   **Cutscene Integration:** The `cutscene_id` in `MemoryData` provides a clean link between collecting a memory and experiencing its associated lore. Ensure that cutscene IDs are unique and that the `CutsceneManager` can reliably play them.
*   **`@resources/data_structures/cutscene_step.gd`:** If cutscenes require more complex interactions (e.g., character animations, camera pans, UI elements appearing/disappearing, branching dialogue), the `CutsceneStep` enum and its properties might need to be extended with new `StepType` values and corresponding export variables.
