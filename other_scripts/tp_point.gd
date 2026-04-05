extends AnimatedSprite2D

@export var battlefield_name : String

func _on_area_2d_body_entered(_body: Node2D) -> void:
	SceneSwitcher.switch_scene(battlefield_name,"fade")
