extends Node2D
var paused = false
@onready var pause_menu = $CanvasLayer/Gui/Pause

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		pause()
func pause():
	if paused :
		pause_menu.visible = true
		Engine.time_scale = 0
	else :
		pause_menu.visible = false
		Engine.time_scale = 1
	paused = !paused


func _on_continue_pressed():
	pass # Replace with function body.


func _on_pausebutton_pressed():
	pause()
