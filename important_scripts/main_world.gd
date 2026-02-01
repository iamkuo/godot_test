extends Node2D
var paused = false
@onready var pause_menu = $Player/Camera2D/pauseuid

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		pause()
func pause():
	if paused :
		$Player/Camera2D/pauseuid.show()
		Engine.time_scale = 0
	else :
		$Player/Camera2D/pauseuid.hide()
		Engine.time_scale = 1
	paused = !paused
func _on_pause_pressed():
	pause()


func _on_continue_pressed():
	pass # Replace with function body.
