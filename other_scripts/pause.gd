extends Control

# =============================
# State
# =============================
var paused := false

# =============================
# Lifecycle
# =============================
func _ready() -> void:
	visible = false
	var btn_path := "CenterContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/"
	get_node(btn_path + "continue").pressed.connect(toggle_pause)
	get_node(btn_path + "exit").pressed.connect(_on_exit_pressed)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()

# =============================
# Pause Menu
# =============================
func toggle_pause() -> void:
	paused = !paused
	visible = paused
	if paused: Engine.time_scale = 0
	else: Engine.time_scale = 1

func _on_exit_pressed() -> void:
	get_tree().quit()
