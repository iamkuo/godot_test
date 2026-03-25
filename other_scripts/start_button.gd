extends Node

func _on_pressed() -> void:
	ProgressManager.current_exp += 10
	ProgressManager._check_stage_progression()
	emit_signal("data_updated")
	SceneSwitcher.switch_scene("main_world","none")
