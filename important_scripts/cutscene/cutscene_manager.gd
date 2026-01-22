extends Node

@export var scripts: Array[CutsceneScript]

var _script_map := {}

func _ready() -> void:
	# Load all .tres files from cutscenes directory
	# Load cutscene files from directory
	var dir = DirAccess.open("res://cutscenes/")
	if not dir:
		push_error("Failed to open cutscenes directory")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tres"):
			var full_path = "res://cutscenes/" + file_name
			var cutscene_script = load(full_path) as CutsceneScript
			if cutscene_script:
				scripts.append(cutscene_script)
				print("Loaded cutscene: ", file_name)
			else:
				push_warning("Failed to load cutscene script: " + file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
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
	
	# Run the cutscene script
	var script = _script_map[id]
	for step in script.steps:
		# Run each step based on type
		match step.type:
			CutsceneStep.StepType.DIALOG:
				# Display dialog
				var display_text = step.text
				if step.speaker != "":
					display_text = "%s: %s" % [step.speaker, step.text]
				GuiManager.queue_text(display_text)
				await GuiManager.dialog_finished

			CutsceneStep.StepType.MOVE:
				# Move actor
				var actor := get_node(step.actor_path) as Node2D	
				var tween := create_tween()
				tween.tween_property(actor, "global_position", step.target_position, step.duration)
				await tween.finished

			CutsceneStep.StepType.FULLSCREEN_TEXT:
				# Show fullscreen text
				var display_text = step.text
				if step.speaker != "":
					display_text = "%s: %s" % [step.speaker, step.text]
				GuiManager.queue_fullscreen_text(display_text)
				await GuiManager.fullscreen_finished

			CutsceneStep.StepType.FULLSCREEN_IMAGE:
				# Show fullscreen image
				GuiManager.queue_fullscreen_image(step.texture)
				await GuiManager.fullscreen_finished
