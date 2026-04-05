extends Node

func _on_pressed() -> void:
	ProgressManager.current_exp += 10
	SceneSwitcher.switch_scene("main_world","none")
