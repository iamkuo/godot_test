extends Node

@export var scripts: Array[CutsceneScript]

var _script_map := {}

func _ready() -> void:

	# 建立 ID → Script 對照表
	for script in scripts:
		_script_map[script.id] = script

# =============================
# 對外 API（你只需要這一行）
# =============================
func play(id: String) -> void:
	if not _script_map.has(id):
		push_error("Cutscene ID not found: " + id)
		return
	await _run_script(_script_map[id])

# =============================
# 內部執行邏輯
# =============================
func _run_script(script: CutsceneScript) -> void:
	for step in script.steps:
		await _run_step(step)

func _run_step(step: CutsceneStep) -> void:
	match step.type:
		CutsceneStep.StepType.DIALOG:
			await dialog(step.speaker, step.text)

		CutsceneStep.StepType.MOVE:
			var actor := get_node(step.actor_path) as Node2D
			if actor:
				await move_actor(actor, step.target_position, step.duration)

		CutsceneStep.StepType.FULLSCREEN_TEXT:
			await fullscreen_text(
				step.text,
				step.wait_for_input,
				step.time
			)

		CutsceneStep.StepType.FULLSCREEN_IMAGE:
			await fullscreen_image(
				step.texture,
				step.wait_for_input,
				step.time
			)

# =============================
# 原本的 awaitable functions
# =============================
func dialog(speaker: String, text: String) -> void:
	var display_text = text
	if speaker != "":
		display_text = "%s: %s" % [speaker, text]
	GuiManager.queue_text(display_text)
	await GuiManager.dialog_finished

func move_actor(actor: Node2D, target: Vector2, duration: float) -> void:
	if not is_instance_valid(actor):
		push_error("Invalid actor node provided for movement")
		return
		
	var tween := create_tween()
	tween.tween_property(actor, "global_position", target, duration)
	await tween.finished

func fullscreen_text(text: String, wait: bool, time: float) -> void:
	await GuiManager.show_fullscreen_text(text, wait, time)

func fullscreen_image(texture: Texture2D, wait: bool, time: float) -> void:
	if not texture:
		push_error("No texture provided for fullscreen image")
		return
		
	await GuiManager.show_fullscreen_image(texture, wait, time)
