extends Node

@export var scripts: Array[CutsceneScript]

var _script_map := {}

func _ready() -> void:
	# Load all .tres files from cutscenes directory recursively
	_load_cutscenes_recursive("res://resources/cutscenes/")
	
	# 建立 ID → Script 對照表
	for script in scripts:
		_script_map[script.id] = script

func _load_cutscenes_recursive(path: String) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		push_error("Failed to open directory: " + path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path.plus_file(file_name)
		if dir.current_is_dir():
			if not file_name.begins_with("."):
				_load_cutscenes_recursive(full_path + "/")
		elif file_name.ends_with(".tres"):
			var cutscene_script = load(full_path) as CutsceneScript
			if cutscene_script:
				scripts.append(cutscene_script)
				print("Loaded cutscene: ", file_name)
			else:
				push_warning("Failed to load cutscene script: " + file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()

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
				GuiManager.queue_text("%s: %s" % [step.speaker, step.text])
				await GuiManager.dialog_finished # 等待 GUI 宣告播放完畢

			CutsceneStep.StepType.FULLSCREEN_TEXT:
				GuiManager.queue_fullscreen({ "type": "text", "text": step.text })
				await GuiManager.fullscreen_finished

			CutsceneStep.StepType.FULLSCREEN_IMAGE:
				GuiManager.queue_fullscreen({ "type": "image", "texture": step.texture })
				await GuiManager.fullscreen_finished
