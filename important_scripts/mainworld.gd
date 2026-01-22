extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	$Player/Panel4.visible = false
	$Player/Camera2D/pause.visible = true


func _on_pause_pressed():
	$Player/Panel4.visible = true
	$Player/Camera2D/pause.visible = false
