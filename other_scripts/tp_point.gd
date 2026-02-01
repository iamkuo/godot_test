extends Area2D

func _on_area_2d_body_entered(_body: Node2D) -> void:
	SceneSwitcher.switch_scene("test_area","fade")
